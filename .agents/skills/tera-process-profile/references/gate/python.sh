#!/bin/sh
# The gate for a Python project: the one check a change passes before it merges.
# It is written to scripts/gate.sh, and the profile's `## Gate` runs it as
# `sh scripts/gate.sh`. A session runs it on its rebased branch before it
# merges its own pull request; CI runs the same line on every push to the
# default branch, and never as a pull-request check.
#
# It needs only the interpreter. It runs ruff and pytest when the project
# has them installed, and says so when it falls back.
#
# Usage: sh scripts/gate.sh [--base <rev>]
#
# With --base, every step before the test runs as it does without it, and the
# test step runs only when something it could read changed since <rev>, the
# commit an earlier gate ran on: each file that differs from it in the
# working tree, committed or not, and each untracked file. A Python test can
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
PY=${PYTHON:-python3}

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
# __pycache__ directories, which the compile step writes.
changed() {
	{
		git diff --name-only "$base" --
		git ls-files --others --exclude-standard
	} | grep -v -E -e '\.md$' -e '\.rst$' -e '^docs/' -e '(^|/)__pycache__/' | sort -u
}

# A repository with no Python code yet has nothing to check, and its gate is
# green: a new repository's first commit passes the gate it adopts. Once a
# .py file exists every step below runs.
if [ -z "$(find . \( -path ./.git -o -path ./.venv -o -path ./venv -o -path ./node_modules \) -prune -o -name '*.py' -print | head -n 1)" ]; then
	step "no .py file: nothing to check yet, gate green"
	exit 0
fi

# Every file must at least compile: the one check a bare interpreter can make.
step compile
"$PY" -m compileall -q -x '(^|/)(\.venv|venv|\.git|node_modules)/' .

step lint
if "$PY" -m ruff --version >/dev/null 2>&1; then
	"$PY" -m ruff check .
	"$PY" -m ruff format --check .
else
	echo "ruff is not installed: lint and formatting were NOT checked (add ruff to the project's dev dependencies)"
fi

step test
if [ -n "$base" ] && [ -z "$(changed)" ]; then
	echo "nothing but documents changed since $base: no test to run"
else
	if [ -n "$base" ]; then
		echo "files other than documents changed since $base: every test runs"
	fi
	if "$PY" -c 'import pytest' >/dev/null 2>&1; then
		"$PY" -m pytest -q
	else
		"$PY" -m unittest discover -s tests -t .
	fi
fi

step "gate green"
