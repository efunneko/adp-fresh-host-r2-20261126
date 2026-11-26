# adp-fresh-host-r2-20261126

A QA fixture for a manual fresh-host round of tera's autonomous dev pipeline
(2026-11-26). It is a tiny, harmless Go command-line tool, `tally`, that
counts the lines, words and bytes of the files it is given, like `wc`.

Nothing here is meant for real use; the repository may be archived or deleted
after the round.

## Build and test

    go build ./...
    go test ./...
