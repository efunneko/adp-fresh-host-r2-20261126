#!/bin/sh
# The gate for a Rust crate or workspace: the one check a change passes before it merges.
# It is written to scripts/gate.sh, and the profile's `## Gate` runs it as
# `sh scripts/gate.sh`. A session runs it on its rebased branch before it
# merges its own pull request; CI runs the same line on every push to the
# default branch, and never as a pull-request check.
#
# Usage: sh scripts/gate.sh [--base <rev>]
#
# With --base, every step before the test runs as it does without it, and the
# test step tests only what changed since <rev>, the commit an earlier gate
# ran on: each file that differs from it in the working tree, committed or
# not, and each untracked file. A crate is selected when a changed file of
# any kind sits in its directory or below it; each workspace crate that
# depends on a selected one, directly or through others, as `cargo tree -i`
# reads it, is selected too, so a fix in a crate selects the crate whose test
# was red. The selected crates are tested with `cargo test -p`; where
# `cargo tree` cannot answer, the whole workspace is tested and the gate says
# so. A change to the root Cargo.toml or Cargo.lock tests the whole
# workspace, and a file outside every crate, such as one under docs/,
# selects nothing. <rev> must be a commit HEAD descends from; any other is
# refused with exit status 2. The profile's `## Gate` says when a session
# passes it.
#
# It stops at the first red, and says which step it was.
set -eu
cd "$(dirname "$0")/.."

step() { printf '== %s\n' "$*"; }

usage() { echo "usage: sh scripts/gate.sh [--base <rev>]" >&2; exit 2; }
base=
while [ $# -gt 0 ]; do
	case $1 in
	--base)
		[ $# -ge 2 ] && [ -n "$2" ] || usage
		base=$2
		shift 2
		;;
	*) usage ;;
	esac
done

# --base names the commit an earlier gate ran on, so it must be a commit this
# branch descends from: from any other, the diff would take in work that is
# not this branch's, such as everything the default branch brought since.
if [ -n "$base" ]; then
	if ! git rev-parse --verify --quiet "$base^{commit}" >/dev/null; then
		echo "--base $base is not a commit in this repository" >&2
		exit 2
	fi
	if ! git merge-base --is-ancestor "$base" HEAD; then
		echo "--base $base is not an ancestor of HEAD: name the commit the earlier gate ran on, from this branch's history; after a rebase that commit is no longer in it" >&2
		exit 2
	fi
fi

# changed prints, one to a line, each file that differs from $base in the
# working tree, committed or not, and each untracked file, leaving out
# target/, which the build step writes.
changed() {
	{
		git diff --name-only "$base" --
		git ls-files --others --exclude-standard
	} | grep -v -e '^target/' | sort -u
}

# A repository with no Rust code yet has nothing to check, and its gate is
# green: a new repository's first commit passes the gate it adopts. Once
# Cargo.toml exists every step below runs. A .rs file without a Cargo.toml is
# red, because cargo cannot build it.
if [ ! -f Cargo.toml ]; then
	if [ -n "$(find . -path ./.git -prune -o -name '*.rs' -print | head -n 1)" ]; then
		echo "there are .rs files but no Cargo.toml: run \`cargo init\` to make this a crate"
		exit 1
	fi
	step "no Cargo.toml and no .rs file: nothing to check yet, gate green"
	exit 0
fi

# rustfmt and clippy are rustup components a bare toolchain may not carry.
# Where one is missing the step says so on its own line rather than passing
# in silence; install the component to make the step count.
step rustfmt
if cargo fmt --version >/dev/null 2>&1; then
	cargo fmt --all -- --check
else
	echo "rustfmt is not installed: formatting was NOT checked (rustup component add rustfmt)"
fi

step build
cargo build --workspace --all-targets

step clippy
if cargo clippy --version >/dev/null 2>&1; then
	cargo clippy --workspace --all-targets -- -D warnings
else
	echo "clippy is not installed: lints were NOT checked (rustup component add clippy)"
fi

# crate_name prints the [package] name a Cargo.toml declares.
crate_name() {
	awk '/^\[/ { pkg = ($0 == "[package]") }
		pkg && /^name[ \t]*=/ { sub(/^name[ \t]*=[ \t]*"/, ""); sub(/".*/, ""); print; exit }' "$1"
}

# changed_crates prints the name of the crate each changed file belongs to:
# the nearest directory at or above it whose Cargo.toml declares a package.
changed_crates() {
	changed | while IFS= read -r f; do
		d=$(dirname "$f")
		while :; do
			if [ -f "$d/Cargo.toml" ] && grep -q '^\[package\]' "$d/Cargo.toml"; then
				crate_name "$d/Cargo.toml"
				break
			fi
			[ "$d" = . ] && break
			d=$(dirname "$d")
		done
	done | sort -u
}

step test
if [ -z "$base" ]; then
	cargo test --workspace
elif changed | grep -qx -e Cargo.toml -e Cargo.lock; then
	echo "Cargo.toml or Cargo.lock changed since $base: the whole workspace is tested"
	cargo test --workspace
else
	changed_set=$(changed_crates)
	if [ -z "$changed_set" ]; then
		echo "the change since $base touches no crate: nothing to test"
	# Each crate a changed one reaches: `cargo tree -i` prints the crate and
	# every crate that depends on it, one to a line, its name first.
	elif ! tree=$(for c in $changed_set; do
		cargo tree --workspace -i "$c" -e normal,dev,build --prefix none --format '{p}' || exit 1
	done); then
		echo "cargo tree could not name the crates that depend on" $changed_set": the whole workspace is tested"
		cargo test --workspace
	else
		crates=$(printf '%s\n' "$tree" | awk 'NF { print $1 }' | sort -u)
		echo "tested, for the change since $base:" $crates
		set --
		for c in $crates; do
			set -- "$@" -p "$c"
		done
		cargo test "$@"
	fi
fi

step "gate green"
