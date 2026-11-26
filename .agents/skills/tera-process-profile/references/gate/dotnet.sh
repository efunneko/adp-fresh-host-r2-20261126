#!/bin/sh
# The gate for a .NET solution or project: the one check a change passes
# before it merges. It is written to scripts/gate.sh, and the profile's
# `## Gate` runs it as `sh scripts/gate.sh`. A session runs it on its rebased
# branch before it merges its own pull request; CI runs the same line on
# every push to the default branch, and never as a pull-request check.
#
# What it gates is the one solution at the root, a *.sln or *.slnx, or, with
# none there, the one project file (*.csproj, *.fsproj, *.vbproj) in the
# tree. Two solutions at the root, or no solution and two projects, are
# refused naming each: make one solution (`dotnet new sln`, then
# `dotnet sln add`), or set `target` below to the one to gate.
#
# Its steps are `dotnet restore`, `dotnet build --no-restore -warnaserror`,
# `dotnet format --verify-no-changes --no-restore` and
# `dotnet test --no-build`. The build treats every warning as an error: a
# gate a warning passes lets warnings pile up where nobody reads them, and a
# nullable-reference or analyzer warning is often the bug. A repository that
# cannot meet that yet deletes `-warnaserror` and says why in its profile.
# NuGet's audit warnings (NU1901 to NU1904, a published advisory against a
# package the repository uses) are among them, so a new advisory reddens an
# unchanged tree: that is the gate saying the dependency needs upgrading. A
# repository that would rather be told without the red lists those codes in
# `<WarningsNotAsErrors>` in its Directory.Build.props.
# `-getProperty`, used below, needs SDK 8 or later. A repository whose
# global.json runs `dotnet test` on Microsoft.Testing.Platform passes the
# solution to the test lines as `--solution` and a project as `--project`.
#
# Usage: sh scripts/gate.sh [--base <rev>]
#
# With --base, every step before the test runs as it does without it, and the
# test step tests only what changed since <rev>, the commit an earlier gate
# ran on: each file that differs from it in the working tree, committed or
# not, and each untracked file. A project is selected when a changed file of
# any kind sits in its directory or below it; each project that references a
# selected one through <ProjectReference>, directly or through others, as
# `dotnet list reference` reads it, is selected too, so a fix in a library
# selects the test project that references it. Each selected project that
# MSBuild calls a test project (`IsTestProject`, which the test SDKs set) is
# tested with `dotnet test`. Where `dotnet` cannot read the references or the
# property, everything is tested and the gate says so. A change to a
# Directory.Build.props, Directory.Build.targets, Directory.Packages.props,
# global.json, NuGet.config or solution file tests everything, as does a
# *.props or *.targets file outside every project, which such a file can
# import. Any other file outside every project, such as one under docs/,
# selects nothing. <rev> must
# be a commit HEAD descends from; any other is refused with exit status 2.
# The profile's `## Gate` says when a session passes it.
#
# It stops at the first red, and says which step it was.
set -eu
cd "$(dirname "$0")/.."
root=$(pwd -P)

# The solution or project to gate, as a path from the root. Empty finds it as
# the header says.
target=

NL='
'
TAB=$(printf '\t')

step() { printf '== %s\n' "$*"; }
red() { printf 'the %s step is red\n' "$1"; exit 1; }

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
# working tree, committed or not, and each untracked file, leaving out bin/
# and obj/, which the build writes.
changed() {
	{
		git diff --name-only "$base" --
		git ls-files --others --exclude-standard
	} | grep -v -e '^bin/' -e '/bin/' -e '^obj/' -e '/obj/' | sort -u
}

# found prints each file under the root that the find(1) expression in its
# arguments matches, as a path from the root, skipping .git, bin and obj.
found() {
	find . \( -name .git -o -name bin -o -name obj -o -name node_modules \) -prune -o -type f \( "$@" \) -print |
		sed 's|^\./||' | sort
}

if [ -z "$target" ]; then
	slns=$(found -path './*.sln' ! -path './*/*' -o -path './*.slnx' ! -path './*/*')
	projs=$(found -name '*.csproj' -o -name '*.fsproj' -o -name '*.vbproj')
	case $slns in
	*"$NL"*)
		echo "more than one solution at the root, so the gate cannot tell which to gate:" $slns
		echo "keep one, or set target in scripts/gate.sh to the one to gate"
		exit 1
		;;
	?*) target=$slns ;;
	*)
		case $projs in
		*"$NL"*)
			echo "no solution at the root and more than one project, so the gate cannot tell which to gate:" $projs
			echo "make a solution that holds them (dotnet new sln, then dotnet sln add), or set target in scripts/gate.sh"
			exit 1
			;;
		?*) target=$projs ;;
		esac
		;;
	esac
fi

# A repository with no .NET code yet has nothing to check, and its gate is
# green: a new repository's first commit passes the gate it adopts. Once a
# solution or project exists every step below runs. Source without a project
# is red, because dotnet cannot build it.
if [ -z "$target" ]; then
	if [ -n "$(found -name '*.cs' -o -name '*.fs' -o -name '*.vb' | head -n 1)" ]; then
		echo "there are .cs, .fs or .vb files but no project: run \`dotnet new classlib\` (or another template) to make one"
		exit 1
	fi
	step "no solution and no project: nothing to check yet, gate green"
	exit 0
fi

step restore
dotnet restore "$target" || red restore

step build
dotnet build "$target" --no-restore -warnaserror || red build

step format
dotnet format "$target" --verify-no-changes --no-restore || red format

# canon prints the project file at path $2, read relative to the directory $1
# (a path from the root), as a path from the root; a path outside the root
# stays absolute. It fails when the file's directory does not exist.
canon() {
	p=$(printf '%s' "$2" | tr '\\' '/')
	case $p in
	/*) ;;
	*) case $1 in
		/*) p=$1/$p ;;
		*) p=$root/$1/$p ;;
		esac ;;
	esac
	d=$(cd "$(dirname "$p")" 2>/dev/null && pwd -P) || return 1
	case $d in
	"$root") printf '%s\n' "$(basename "$p")" ;;
	"$root"/*) printf '%s\n' "${d#"$root"/}/$(basename "$p")" ;;
	*) printf '%s\n' "$d/$(basename "$p")" ;;
	esac
}

# project_lines prints, from the output of a dotnet command listing projects,
# each line naming a project file, carriage returns removed.
project_lines() { tr -d '\r' | sed 's/[[:space:]]*$//' | grep -E '\.(cs|fs|vb)proj$' || true; }

# refs prints, as paths from the root, each project the project $1
# references through <ProjectReference>, as `dotnet list reference` reads it.
refs() {
	out=$(dotnet list "$1" reference) || return 1
	printf '%s\n' "$out" | project_lines | while IFS= read -r r; do
		canon "$(dirname "$1")" "$r" || exit 1
	done
}

# graph sets $projects to every project the gated solution or project holds
# or reaches, and $edges to one line per reference, "<project><TAB><referenced
# project>". It fails when dotnet cannot read a solution or a reference.
graph() {
	case $target in
	*.sln | *.slnx)
		out=$(dotnet sln "$target" list) || return 1
		todo=$(printf '%s\n' "$out" | project_lines | while IFS= read -r r; do
			canon "$(dirname "$target")" "$r" || exit 1
		done) || return 1
		;;
	*) todo=$target ;;
	esac
	projects=
	edges=
	while [ -n "$todo" ]; do
		next=
		while IFS= read -r p; do
			[ -n "$p" ] || continue
			case "$NL$projects$NL" in *"$NL$p$NL"*) continue ;; esac
			projects=$projects$NL$p
			rs=$(refs "$p") || return 1
			while IFS= read -r r; do
				[ -n "$r" ] || continue
				edges=$edges$NL$p$TAB$r
				next=$next$NL$r
			done <<-EOF
				$rs
			EOF
		done <<-EOF
			$todo
		EOF
		todo=$next
	done
}

# owners prints each project of $projects that holds a changed file read from
# stdin: the projects in the nearest directory at or above the file that
# holds any. With the argument `unowned` it prints instead each file no
# project holds.
owners() {
	P=$projects M=${1:-} awk '
	BEGIN {
		n = split(ENVIRON["P"], ps, "\n")
		for (i = 1; i <= n; i++) {
			if (ps[i] == "") continue
			d = ps[i]
			if (d ~ /\//) sub(/\/[^\/]*$/, "", d); else d = "."
			dirs[d] = dirs[d] ps[i] "\n"
		}
	}
	{
		d = $0
		while (1) {
			if (d ~ /\//) sub(/\/[^\/]*$/, "", d); else d = "."
			if (d in dirs) { if (ENVIRON["M"] != "unowned") printf "%s", dirs[d]; break }
			if (d == ".") { if (ENVIRON["M"] == "unowned") print $0; break }
		}
	}' | sort -u
}

# dependents prints the projects on stdin and every project that references
# one of them, directly or through others, by $edges.
dependents() {
	E=$edges awk -F "$TAB" '
	{ sel[$0] = 1 }
	END {
		n = split(ENVIRON["E"], es, "\n")
		for (i = 1; i <= n; i++) if (split(es[i], pr, FS) == 2) { from[i] = pr[1]; to[i] = pr[2] }
		do {
			grew = 0
			for (i in from) if ((to[i] in sel) && !(from[i] in sel)) { sel[from[i]] = 1; grew = 1 }
		} while (grew)
		for (p in sel) print p
	}' | sort -u
}

# whole_inputs prints each changed file from stdin that every project reads:
# MSBuild's and NuGet's directory-wide files, global.json and solutions.
whole_inputs() {
	awk '{ n = split($0, parts, "/"); b = tolower(parts[n]) }
		b == "directory.build.props" || b == "directory.build.targets" || b == "directory.packages.props" ||
		b == "global.json" || b == "nuget.config" || b ~ /\.slnx?$/ || b ~ /\.slnf$/ { print }'
}

test_all() {
	dotnet test "$target" --no-build || red test
}

step test
if [ -z "$base" ]; then
	test_all
elif [ -n "$(changed | whole_inputs)" ]; then
	echo "a file every project reads changed since $base:" $(changed | whole_inputs)": everything is tested"
	test_all
elif ! graph; then
	echo "dotnet could not read the project references of $target: everything is tested"
	test_all
elif imports=$(changed | owners unowned | grep -E '\.(props|targets)$') && [ -n "$imports" ]; then
	echo "an MSBuild file outside every project changed since $base, which any project may import:" $imports": everything is tested"
	test_all
else
	selected=$(changed | owners)
	if [ -z "$selected" ]; then
		echo "the change since $base touches no project: nothing to test"
	else
		reached=$(printf '%s\n' "$selected" | dependents)
		tests=
		unread=
		while IFS= read -r p; do
			[ -n "$p" ] || continue
			if ! v=$(dotnet msbuild "$p" -getProperty:IsTestProject 2>/dev/null); then
				unread=$p
				break
			fi
			case $(printf '%s' "$v" | tr -d '\r[:space:]' | tr '[:upper:]' '[:lower:]') in
			true) tests=$tests$NL$p ;;
			esac
		done <<-EOF
			$reached
		EOF
		if [ -n "$unread" ]; then
			echo "dotnet could not read whether $unread is a test project: everything is tested"
			test_all
		elif [ -z "$tests" ]; then
			echo "the change since $base reaches" $reached", and no test project: nothing to test"
		else
			echo "tested, for the change since $base:" $tests
			while IFS= read -r p; do
				[ -n "$p" ] || continue
				dotnet test "$p" --no-build || red test
			done <<-EOF
				$tests
			EOF
		fi
	fi
fi

step "gate green"
