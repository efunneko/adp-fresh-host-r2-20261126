#!/bin/sh
# The gate for a Go module: the one check a change passes before it merges.
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
# not, and each untracked file. A package is selected when it holds a changed
# .go file, or when a changed file of another kind, such as testdata or an
# embedded file, sits in its directory or below it; each package that imports
# a selected one, directly or through others, is selected too, so a fix in a
# package selects the package whose test was red. A change to go.mod or
# go.sum tests every package, and a file outside every package, such as one
# under docs/ when no package sits above it, selects nothing. <rev> must be a commit HEAD descends from;
# any other is refused with exit status 2. The profile's `## Gate` says when
# a session passes it.
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
# working tree, committed or not, and each untracked file. A document counts
# like any other file: `//go:embed` and golden tests read them.
changed() {
	{
		git diff --name-only "$base" --
		git ls-files --others --exclude-standard
	} | sort -u
}

# A repository with no Go code yet has nothing to check, and its gate is
# green: a new repository's first commit passes the gate it adopts. Once
# go.mod exists every step below runs. A .go file without a go.mod is red,
# because `go build` cannot build it.
if [ ! -f go.mod ]; then
	if [ -n "$(find . -path ./.git -prune -o -name '*.go' -print | head -n 1)" ]; then
		echo "there are .go files but no go.mod: run \`go mod init\` to make this a module"
		exit 1
	fi
	step "no go.mod and no .go file: nothing to check yet, gate green"
	exit 0
fi

# Formatting first: it is the cheapest check, and an unformatted tree makes
# every later diff noisier to review.
step gofmt
unformatted=$(gofmt -l .)
if [ -n "$unformatted" ]; then
	printf 'these files are not gofmt-formatted; run `gofmt -w` on them:\n%s\n' "$unformatted"
	exit 1
fi

step build
go build ./...

# vet compiles the test files too, so a change that breaks only a test file
# is caught here and not halfway through the test run.
step vet
go vet ./...

# has_go says whether a directory holds Go source of its own.
has_go() {
	for g in "$1"/*.go; do
		[ -e "$g" ] && return 0
	done
	return 1
}

# changed_dirs prints the directory of the package each changed file belongs
# to: its own, or the nearest one above it that holds Go source. A testdata
# tree belongs to the package that holds it.
changed_dirs() {
	changed | while IFS= read -r f; do
		d=$(dirname "$f")
		case /$d/ in
		*/testdata/*) d=$(printf '%s\n' "/$d/" | sed 's,/testdata/.*,,; s,^/,,') ;;
		esac
		[ -n "$d" ] || d=.
		while :; do
			if [ -d "$d" ] && has_go "$d"; then
				echo "./$d"
				break
			fi
			[ "$d" = . ] && break
			d=$(dirname "$d")
		done
	done | sort -u
}

# -race costs time and finds the bugs no other check finds.
step test
if [ -z "$base" ]; then
	go test -race -count=1 ./...
elif changed | grep -qx -e go.mod -e go.sum; then
	echo "go.mod or go.sum changed since $base: every package is tested"
	go test -race -count=1 ./...
else
	dirs=$(changed_dirs)
	pkgs=
	if [ -n "$dirs" ]; then
		# shellcheck disable=SC2086 # one directory per word
		want=$(go list -e $dirs | tr '\n' ' ')
		# Each test binary's line names its package in brackets and lists
		# every package it is built from; one built from a selected package
		# is selected.
		pkgs=$(go list -e -test -f '{{.ImportPath}} {{join .Deps " "}}' ./... |
			awk -v want="$want" '
				BEGIN { n = split(want, w, " "); for (i = 1; i <= n; i++) sel[w[i]] = 1 }
				$2 ~ /^\[.*\.test\]$/ {
					p = $2; sub(/^\[/, "", p); sub(/\.test\]$/, "", p)
					for (i = 1; i <= NF; i++) if ($i in sel) { print p; break }
				}' | sort -u)
	fi
	if [ -z "$pkgs" ]; then
		echo "the change since $base touches no package with tests: nothing to test"
	else
		echo "tested, for the change since $base:" $pkgs
		# shellcheck disable=SC2086 # one import path per word
		go test -race -count=1 $pkgs
	fi
fi

step "gate green"
