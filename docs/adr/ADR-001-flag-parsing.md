# ADR-001: Parse tally's flags by hand, before the first file name

**Status:** Proposed

Carries [PRD-002](../prd/PRD-002-tally-flags.md) R2 and R8.

## Context

tally takes three flags, `-l`, `-w` and `-c`, which PRD-002 R2 requires to
combine both as separate arguments and bundled (`-lw`). Go's standard `flag`
package treats `-lw` as one flag named `lw`, so it cannot meet R2 on its own.
R8 requires a fixed usage error and `--` to end the flags.

## Decision

tally parses its arguments with a small function of its own,
`parseArgs(args []string) (sel selection, files []string, err error)`,
where `selection` is a struct of three booleans,
`type selection struct{ lines, words, bytes bool }`:

- It reads arguments from the first. An argument `--` ends the flags and is
  dropped. An argument that starts with `-` and is longer than `-` is a flag
  group: each letter after the `-` must be `l`, `w` or `c`, and selects that
  count; any other letter is a usage error.
- **Flags may appear only before the first file name.** The first argument
  that is not a flag group, and every argument after it, is a file name. A
  lone `-` is a file name.
- No selecting flag means all three counts: `parseArgs` returns a
  `selection` with all three set.
- A usage error is returned as `err`, and `run` writes PRD-002 R8's usage
  line and exits 2.

## Alternatives rejected

- **The standard `flag` package with a pre-pass that splits bundles.** Two
  mechanisms for one small grammar, and the pre-pass would still have to know
  where flags end.
- **A third-party library such as `pflag`.** A new dependency, and its
  behaviour, for three single-letter flags.
- **Flags anywhere on the line, as GNU `wc` allows.** It is harder to state
  exactly, and PRD-002 does not need it.

## Consequences

- The parser is one pure function, tested directly with each case of R2 and
  R8.
- `tally a.txt -l` counts a file named `-l`. That is the POSIX rule, and
  PRD-002 leaves flags after a file name out of scope.
- A later flag is one more letter in the parser and its tests.
