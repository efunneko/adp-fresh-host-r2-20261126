# ADR-002: Put tally's behaviour behind a testable run function

**Status:** Accepted

Carries [PRD-002](../prd/PRD-002-tally-flags.md)'s "How success is
measured", and PRD-001's.

## Context

PRD-002 measures every requirement by tally's exact standard output,
standard error and exit status. Today `main` reads `os.Args`, writes to the
process's streams and calls `os.Exit`, so the only way to check those is to
build the binary and run it as a subprocess.

## Decision

tally's behaviour moves into
`run(args []string, stdin io.Reader, stdout, stderr io.Writer) int`, which
returns the exit status. `main` does nothing but
`os.Exit(run(os.Args[1:], os.Stdin, os.Stdout, os.Stderr))`. `Count` stays
as it is.

## Alternatives rejected

- **Tests that build and run the binary.** Each test is slower, and needs a
  build step and temporary files for every case.
- **Leaving `main` as it is and testing only `parseArgs` and `Count`.** The
  format, the total line and the exit status would have no test.

## Consequences

- Each case of PRD-002's table is one in-process test of `run`, with files
  from `t.TempDir()`.
- `main` holds no logic left untested.
