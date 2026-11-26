# Review checklist

This file lists the kinds of defect this repository's code is prone to. Each
entry is a state to put the code in and what would be wrong there. An
implementation's fresh reviewer and a wave verification read it beside
`.tera/process.md`, and put every change in each state it can reach; a wave
draws its verification's suggested probes from it. A defect counts only with
a failure scenario:
this input or state, then this wrong outcome. The process profile outranks
this file.

`tally` is a small command-line tool: it reads files or standard input byte
by byte and prints their lines, words and bytes. Nothing in it is concurrent,
long-lived, networked or shared, so the entries below are about its input,
its errors and its command line. When the code grows a kind of component
these entries do not cover, add the states it can reach. An entry names what
to look for, never a defect already known: a known defect is filed and fixed.

## The edges of the input

**State:** empty input; a single byte; input with no trailing newline; only
whitespace; CRLF line endings; tabs, vertical tabs, form feeds and other
whitespace; runs of whitespace between words; non-ASCII and multi-byte UTF-8
text, including Unicode whitespace; invalid UTF-8; a very large file.
**Wrong there:** a line, word or byte count is off by one, a word is split or
merged at a boundary, or memory grows with the size of the input.

## The edges of numeric ranges

**State:** zero, one, and counts larger than any test file holds.
**Wrong there:** an off-by-one, an overflow or wrap, or a count printed in a
form a caller does not expect.

## Errors partway through

**State:** a file that does not exist, cannot be read, or is a directory; a
read that fails partway through a file; several files of which a middle one
fails.
**Wrong there:** a partial count is printed as if it were whole, the error
goes to standard output or is lost, the exit status is zero after a failure,
a file is left open, or the files after the failing one are handled in a way
nobody decided.

## The command line

**State:** no arguments (standard input), one file, several files, the same
file twice, a file named `-` or starting with `-`.
**Wrong there:** the output format, field order or file-name column differs
between these cases in a way nobody decided, or a name is read as a flag.

## Determinism

**State:** the same input run again, from a file and from standard input,
read in one go and in small chunks.
**Wrong there:** the counts differ, because a result depends on how the
input was read rather than what it holds.

## Tests that prove the counts

**State:** a test of a count, fed the change's edge cases.
**Wrong there:** it checks only that no error was returned, or only one of
the three counts, so it would pass on code that counts wrongly.
