#!/bin/sh
# The gate for a Node project: the one check a change passes before it merges.
# It is written to scripts/gate.sh, and the profile's `## Gate` runs it as
# `sh scripts/gate.sh`. A session runs it on its rebased branch before it
# merges its own pull request; CI runs the same line on every push to the
# default branch, and never as a pull-request check.
#
# The project's own package.json scripts say how it lints, builds and tests.
# The gate runs them in that order, so the gate and `npm test` cannot drift
# apart. A missing `lint` or `build` script is skipped and named. `test` is
# required.
#
# Usage: sh scripts/gate.sh [--base <rev>]
#
# With --base, every step before the test runs as it does without it, and the
# test step runs only when something it could read changed since <rev>, the
# commit an earlier gate ran on: each file that differs from it in the
# working tree, committed or not, and each untracked file. A test can
# import any module and read any file, and which tests reach a changed file
# cannot be read from the tree, so any changed file other than a document
# runs every test, and a change to documents alone (*.md, *.rst, docs/) runs
# none and is green. A repository whose tests read its documents, such as
# doctests over its README or docs/, deletes the document patterns from the
# filter in `changed` below. <rev> must be a commit HEAD descends from; any other is
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
# documents (*.md, *.rst and anything under docs/), which this gate's tests
# are taken not to read (see the header), and
# node_modules, which the install step writes.
changed() {
	{
		git diff --name-only "$base" --
		git ls-files --others --exclude-standard
	} | grep -v -E -e '\.md$' -e '\.rst$' -e '^docs/' -e '(^|/)node_modules/' | sort -u
}

# A repository with no package.json yet has nothing to check, and its gate is
# green: a new repository's first commit passes the gate it adopts. Once
# package.json exists every step below runs, and `test` is required.
if [ ! -f package.json ]; then
	step "no package.json: nothing to check yet, gate green"
	exit 0
fi

has_script() {
	node -e 'const s=(require("./package.json").scripts||{}); process.exit(s[process.argv[1]] ? 0 : 1)' "$1"
}

# A clean install from the lockfile, so the gate tests the dependencies the
# lockfile pins rather than whatever is already in node_modules.
step install
if [ -f package-lock.json ]; then
	npm ci
else
	echo "no package-lock.json: installing with npm install, which pins nothing (commit a lockfile)"
	npm install
fi

for s in lint build; do
	step "$s"
	if has_script "$s"; then
		npm run "$s"
	else
		echo "package.json has no \"$s\" script: $s was NOT run"
	fi
done

step test
if [ -n "$base" ] && [ -z "$(changed)" ]; then
	echo "nothing but documents changed since $base: no test to run"
else
	if [ -n "$base" ]; then
		echo "files other than documents changed since $base: every test runs"
	fi
	npm test
fi

step "gate green"
