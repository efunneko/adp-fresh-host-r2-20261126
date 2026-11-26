# PLAN: tally-flags

**Status:** Proposed
**Feature:** tally-flags
**Requirements:** [PRD-001](../prd/PRD-001-tally.md), [PRD-002](../prd/PRD-002-tally-flags.md)
**Decisions:** [ADR-001](../adr/ADR-001-flag-parsing.md), [ADR-002](../adr/ADR-002-testable-entry-point.md)
**Maintainer:** Eduard Funnekotter (`efunneko`)

tally takes `-l`, `-w` and `-c` to print only the counts selected, and prints
a `total` line when given more than one file.

## Sequencing

| Wave | Objective | Status |
|---|---|---|
| 1 | Flags, the total line and their documentation | Not started |

One wave: the total line uses the flags' selection directly, nothing the
flags teach changes how the total is built, and no person acts in between.

## Wave 1

**Objective.** tally meets PRD-002 R1–R8, and its README says how to use the
flags and the total line.

**Carries.** PRD-002 R1–R8; ADR-001; ADR-002. PRD-001 R1–R4 keep holding.

**Scope.**

- `run(args, stdin, stdout, stderr) int` as ADR-002 decides, with `main`
  reduced to calling it.
- `parseArgs` as ADR-001 decides: separate and bundled flags, `--`, flags
  only before the first file name, and the usage error.
- Printing only the selected counts, in the order lines, words, bytes, in
  the format PRD-002 R5 states.
- The total line of PRD-002 R6.
- Today's error behaviour, unchanged, as PRD-002 R7 states.
- `README.md`: the usage line, each flag, the total line, and an example.

**Acceptance criteria**, each checkable on its own:

1. Every row of PRD-002's "How success is measured" table has a test of
   `run` that compares standard output, standard error's emptiness or not,
   and the exit status exactly, and each passes.
2. `parseArgs` has tests for `-l`, `-w`, `-c`, `-lw`, `-wl`, `-lwc`, `-l -w`,
   `-ll`, `--` followed by `-l`, a lone `-`, a flag after a file name (read as
   a file name), and `-x` (a usage error), and each passes.
3. With no flags, tally's output for one file, several files and standard
   input matches today's byte for byte, apart from the new total line for
   several files.
4. `main` contains only the call to `run` and `os.Exit`.
5. `README.md` documents `-l`, `-w`, `-c`, their combination, the total line
   and the exit statuses 0, 1 and 2.
6. `go.mod` gains no dependency.
7. The gate, `sh scripts/gate.sh`, is green.

**Must not break.** `Count`'s results for any input. The existing test,
`TestCount`.

**Out-of-band acts.** None.
