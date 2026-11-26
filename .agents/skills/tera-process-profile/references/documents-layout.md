# The documents layout

Three directories, one for each kind of document the autonomous dev pipeline
reads and writes, with a wave's brief kept beside its plan. The profile's
`## Documents` section names them, and a session reads that section to find
them. Offer each one as a directory holding a `README.md` that says what
belongs there and lists its documents, using the text below. Write only the
directories the person accepts. If they keep a kind of document somewhere
else, the profile names that place instead.

| Directory | Holds | One file is |
|---|---|---|
| `docs/prd/` | what must be true, and why: product requirements documents (PRDs) | one product area or feature |
| `docs/adr/` | how it will be made true, and what was rejected: architecture decision records (ADRs) | one decision |
| `docs/plans/` | the order the work lands in, as waves, and each wave's brief | one plan, and one brief per wave |

**Why these, and why apart:** each kind answers a different question and
changes at a different rate. Requirements change least, and a plan changes
every wave. Keeping them apart means a session that needs one does not have to
dig it out of the others. A brief sits beside its plan because the wave that
writes it and the plan execution that reads its closeout both start from the
plan.

## Naming

Number requirements and decisions, and date plans:

- `docs/prd/PRD-<nnn>-<slug>.md`, numbered from `001`
- `docs/adr/ADR-<nnn>-<slug>.md`, numbered from `001`
- `docs/plans/PLAN-<yyyy>-<mm>-<feature>.md`
- `docs/plans/brief-<plan>-wave<N>.md`, `<plan>` being the plan file's name
  without its extension, in lower case

**Why:** a number never changes when a title does, so a citation of a
decision by its number stays true. ADR is the established name for a
decision record, and the one tools such as adr-tools and MADR expect; PRD is
the common name for a requirements document. A plan is named for its feature,
which is also how its Work Orders, cohorts and pull requests are named.

**Offer the naming with the directories**: the prefixes and directories
above are the recommendation, and the person may name others. **A repository
that already keeps requirements or decisions under a convention of its own
keeps it**: the profile names its directories and prefixes, and the starter
`README.md` for that kind is not offered.

## Status

Every requirement, decision and plan opens with a status line:

```
**Status:** Proposed
```

Requirements and decisions move from `Proposed` to `Accepted`, and later to
`Superseded by <id>` if they are replaced. A plan moves from `Proposed` to
`Ratified` when a maintainer ratifies it, and stays `Ratified`: its plan
execution records each wave's verdict and its own closeout in it, and leaves
its status line as it is. **Why:** the status is what a session checks before it acts
on a document. A plan execution runs only a plan whose status reads
`Ratified`.

## How a plan is written

A plan opens with a header block of `**Name:** value` lines, among them its
`**Status:**` and a `**Feature:**` line naming the feature slug. It carries a
sequencing table with a `Wave` column and a `Status` column, one row per wave,
whose rows top to bottom are the order the waves run in, and a section per
wave headed `Wave <N>`, which is that wave's scope. It may carry a table of
out-of-band acts, each with the act, `When`, its `Type`, `Before` and notes.
The plan execution records each wave's verdict in the plan: in that wave's row
and under a `Verdict` heading at the end of its section.

## The `README.md` for each directory

Write each directory's `README.md` as below, adjusted to whatever the person
changed. Each is also the index of its directory: a new document adds its
line, with its status.

### `docs/prd/README.md`

```markdown
# Requirements

What must be true, and why: one product requirements document (PRD) per
product area or feature, named `PRD-<nnn>-<slug>.md`. Each states the
problem, who has it, numbered requirements (R1, R2, …) and how success is
measured. It says nothing about how the requirements will be met: that is a
decision.

A requirement opens `**Status:** Proposed` and becomes `Accepted` when a
maintainer accepts it.

| Requirement | Status |
|---|---|
```

### `docs/adr/README.md`

```markdown
# Decisions

How a requirement will be met: one architecture decision record (ADR) per
decision, named `ADR-<nnn>-<slug>.md`, each with its context, the decision,
the alternatives rejected and why, and its consequences. A decision is never
edited after it is accepted. A later decision supersedes it, and both say
so.

| Decision | Status |
|---|---|
```

### `docs/plans/README.md`

```markdown
# Plans

The order work lands in: one file per plan, named
`PLAN-<yyyy>-<mm>-<feature>.md`. A plan names the requirements and decisions
it carries out, then its waves in order. For each wave it gives what the wave
must do, what must not break, and the out-of-band acts a person must perform.
Each wave's brief sits beside its plan, named `brief-<plan>-wave<N>.md`, with
the wave's closeout appended to it.

A plan is `Proposed` until a maintainer ratifies it. No plan execution runs a
plan that is not `Ratified`.

| Plan | Status |
|---|---|
```
