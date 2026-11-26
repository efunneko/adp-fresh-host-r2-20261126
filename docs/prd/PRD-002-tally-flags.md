# PRD-002: tally-flags

**Status:** Accepted

Under [PRD-001](PRD-001-tally.md).

## Problem

tally always prints all three counts, and gives no total over several files.
A script that wants one count has to cut it out of the line, and a person
counting several files has to add them up by hand. `wc` users expect `-l`,
`-w`, `-c` and a `total` line.

## Who has it

The same people and scripts as PRD-001.

## Requirements

- **R1. Selecting counts.** `-l` selects lines, `-w` words and `-c` bytes.
  Given no selecting flag, tally prints all three, exactly as it does today.
- **R2. Combining flags.** Flags combine as separate arguments (`-l -w`) and
  bundled in one argument (`-lw`, `-wl`, `-lwc`). A flag given twice is the
  same as given once.
- **R3. Order.** The selected counts always print in the order lines, words,
  bytes, whatever order the flags were given in: `-wl` prints lines, then
  words.
- **R4. `-c` is bytes.** `-c` selects the byte count tally already computes.
  There is no `-m`.
- **R5. Format.** Each output line is the selected counts separated by single
  spaces, then, for a named file, a single space and the file's name as
  given. Standard input's line carries no name. Today's output with no flags
  is unchanged: `%d %d %d name`.
- **R6. Total.** This refines PRD-001 R3: when two or more file names are
  given, after the per-file
  lines tally prints one more line: each selected count summed over the
  files, then a space and `total`. With standard input or one file name it
  prints no total.
- **R7. Errors.** When a file cannot be opened or read, tally writes the
  error to standard error, exits 1 and prints no total. Files before it have
  already printed their lines; files after it are not read. This is today's
  behaviour, unchanged.
- **R8. Usage.** Flags are read only before the first file name and before
  `--`; every argument after either is a file name, however it is spelled.
  Among the flags, an argument that starts with `-`, is not `-` or `--`, and
  holds any letter other than `l`, `w` and `c` is a usage error: tally writes
  exactly the line `usage: tally [-lwc] [--] [file ...]` to standard error,
  nothing to standard output, and exits 2. `--` ends the flags, so a file
  named `-l` is counted with `tally -- -l`, and `tally a.txt -x` counts
  `a.txt` and then fails to open a file named `-x` (R7).

## How success is measured

Each case below is a test of tally's standard output and exit status,
compared exactly, and of its standard error: compared exactly for the usage
line of R8, and otherwise checked only for being empty or not, since an
error's text names a path and comes from the operating system. With `a.txt` holding `hello world\n` and
`b.txt` holding `one\ntwo three\n`:

| Command | Standard output | Exit |
|---|---|---|
| `tally a.txt` | `1 2 12 a.txt` | 0 |
| `tally -l a.txt` | `1 a.txt` | 0 |
| `tally -w a.txt` | `2 a.txt` | 0 |
| `tally -c a.txt` | `12 a.txt` | 0 |
| `tally -wl a.txt` | `1 2 a.txt` | 0 |
| `tally -l -c a.txt` | `1 12 a.txt` | 0 |
| `tally a.txt b.txt` | `1 2 12 a.txt`, `2 3 14 b.txt`, `3 5 26 total` | 0 |
| `tally -l a.txt b.txt` | `1 a.txt`, `2 b.txt`, `3 total` | 0 |
| `tally -l` with `a.txt` on standard input | `1` | 0 |
| `tally -x a.txt` | nothing; `usage: tally [-lwc] [--] [file ...]` on standard error | 2 |
| `tally a.txt -x` | `1 2 12 a.txt`; an error on standard error; no total | 1 |
| `tally a.txt missing.txt` | `1 2 12 a.txt`; the error on standard error; no total | 1 |

## Not in scope

`wc`'s padded columns, `-m`, `-` as standard input, flags after a file name,
and carrying on past a file that cannot be read.
