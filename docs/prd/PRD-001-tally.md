# PRD-001: tally

**Status:** Accepted

## Problem

A person or a script needs the line, word and byte counts of some files, or
of standard input, in a form that is easy to read and easy to parse.

## Who has it

People at a terminal, and shell scripts that read tally's output.

## Requirements

- **R1.** tally counts the lines, words and bytes of each file named on its
  command line, and of standard input when it is given no file.
- **R2.** A line is counted for each newline byte (`\n`). A word is a maximal
  run of bytes that are none of space, `\n`, `\t` and `\r`. A byte is a byte
  of the input.
- **R3.** tally's output is plain text, one line per input, with counts
  separated by single spaces, so a script can split it on spaces. A feature
  may add a summary line after them, as PRD-002 R6 does.
- **R4.** On success tally exits 0. When a file cannot be opened or read it
  writes the error to standard error and exits non-zero.

## How success is measured

Each requirement is checked by a test that runs tally on a fixed input and
compares its standard output and exit status exactly, and checks whether
its standard error is empty.

## Not in scope

Matching `wc`'s output byte for byte. Counting characters as opposed to
bytes.
