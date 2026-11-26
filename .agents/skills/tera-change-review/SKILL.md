---
name: tera-change-review
description: Review a change before its gate runs, as an implementation's review step in the autonomous dev pipeline. Hand the whole change to a fresh reviewer that did not write it, with the task and the repository's rules but none of the author's reasoning; hold every finding to a failure scenario; settle what reading cannot with a throwaway test; fix what it finds; and record the review in the pull request. Use it after the directed tests pass and before the repository's gate.
metadata:
  tera-stamp: "plugin.autonomous-dev-pipeline@3.2.1/5b975f5de59744e731d7ebee04f157beac001f6d8b809edeec73f2a341b1757c"
---

# tera-change-review

Use this skill to review a change you made, before the repository's gate runs
on it and before anyone else reads it. That is the review step of every
`implementation` in the autonomous dev pipeline, and the review a person asks
for when they want their own work read the same way.

**Review while the tree is still cheap to change.** Run it once the directed
tests pass, and before the gate: the gate then proves the tree the review
left, and runs once.

**The repository's process profile outranks this skill.** Read
`.tera/process.md` before you start. Where it names its own review steps, a
gate, or a rule about tests, follow it, and use this skill for what it is
silent on.

## Who reviews: a fresh reviewer

**The review is done by a fresh sub-agent, not by you.** You wrote the change,
and you read it with the assumptions that wrote it; a reader that never held
them sees what they hide. Start a sub-agent and give it only:

- **the change**: committed, staged, unstaged and untracked, found as step 1
  says;
- **the task**, as you were given it;
- **the documents the task cites**: requirements, decisions, a plan or a
  wave's brief;
- **the repository's instructions**: `AGENTS.md`, `CLAUDE.md` or whatever its
  harnesses read;
- **the process profile**, `.tera/process.md`;
- **the repository's checklist**, `.tera/review-checklist.md`, where it
  exists.

**Give it none of your reasoning**: not your plan, not why you chose what you
chose, not what you already checked, not where you think the risk is. Hand
it paths and the task's text, and let it read. Give it steps 1 to 3 of this
skill as its instructions, and ask for its findings or for a plain statement
that it found none. Never ask it for a number of findings, or tell it that
it should find something.

**You fix what it finds** (step 4), and you record the review (step 6).

**Where the harness cannot run a sub-agent, read the diff afresh yourself**:
from the files and the diff on disk rather than from memory of writing them,
every file in full, as if someone else had written it. Say in the pull
request that the review was yours and not a fresh reviewer's.

## 1. Find the whole change

The change is everything that differs from the base the work started from:
commits on the branch, uncommitted edits, and new files nobody has staged.

```sh
git fetch origin
git diff --stat origin/<default-branch>...HEAD   # committed on the branch
git diff --stat HEAD                             # staged and unstaged
git ls-files --others --exclude-standard         # untracked
```

Review the union of all three. Read every file in it in full, tests
included: a test can be wrong in the same way as the code it tests.

## 2. Read it against what it was for

**The review judges this item's correctness, and only this item's.** Whether
the change composes with the other implementations of its wave — a seam two
items both touch, a caller another item changed — is the wave verification's
to judge, not this review's.

Before you read for defects, read for fit. Open the task, every document it
names, the repository's instructions and `.tera/process.md`. Then check, and
report what fails as a finding — the reviewer reads and reports, and the
author builds, fixes and asks (step 4):

1. **Every clause was built.** List each acceptance criterion and each clause
   of a named decision the task asks for. For each, find the code and the test
   that hold it. A clause with neither was not built: it is a finding, which
   the author builds or names in the pull request as not built, with why.
   Never report a change complete while a clause is silently missing.
2. **Nothing was decided that was not the author's to decide.** A choice the
   documents make differently, or do not make at all, is a departure: a new
   permission or grant, a different rule for who may act, scope moved from a
   later wave. If the documents name a mechanism that does not exist, building
   on what does exist is fine and is said in the pull request. Any other
   departure is a finding, which goes back to whoever decides, as a question,
   before merge.
3. **A second way in is decided alike.** Where an action can be reached two
   ways (a page and an API, a route and a tool, a command and its library
   call), both must reach the same decision, and a test must hold the relation
   between them, not one test each.
4. **A test that is the evidence of a refusal, limit or permission check fails
   without the change.** Where the only proof that a check exists is its test,
   remove the check or invert its condition, watch the test go red, put it
   back and watch it go green. A test of a check that passes either way proves
   the check is not there. Other tests are judged by what they hold, not by
   this.

## 3. Read it for defects

**A defect counts only with a failure scenario**: this input or state, then
this wrong outcome. "A caller that cancels after the first write leaves the
second row unwritten and the first one acknowledged" is a finding; "this
could be cleaner" is not. Style and taste are not findings, and neither is a
risk nobody can put in a state. An empty review is a normal result for a
sound change: report it as one.

**The repository's checklist comes first.** Where `.tera/review-checklist.md`
exists, it lists the kinds of defect this repository's code is prone to, each
as a state to put the code in and what would be wrong there. Put the change
in every state it can reach. The process profile outranks the checklist.

**Then the generic states.** For each that the change can reach, ask what the
code does there:

- **partway through work**: stopped, cancelled or failed in the middle of a
  task. Does it stop, and is what it did kept, undone or lost?
- **held full**: a bounded queue, pool or buffer full under sustained load.
  What waits, what is dropped, and is a required action deferred for ever?
- **without a limit**: in-flight work of one kind with no bound. What does
  overflow do, and to whom else?
- **reused after close**: an identifier, handle, counter or connection that
  restarts. Can the old life's event reach the new one?
- **in-flight data**: who owns it between hand-offs, whether it is used after
  release, whether a write is acknowledged before it is durable.
- **at the edges of a range**: empty, zero, one, the limit and one past it,
  negative, overflow.
- **two implementations of one port**: the same input through each. Do they
  give the same outcome, errors included?
- **an enforced rule's ways round**: a refusal, limit, permission check or
  static rule. Is there a second way in, an alias, an encoding or an
  indirection that gets past it? Trace a refusal to the line that refuses
  rather than assuming a check exists deeper.
- **run twice**: the same input on another run, another order, another clock.
  Is the result the same?
- **tooling that judges other changes**: a check, a selector, a linter. For
  each ordinary kind of change, is its verdict right, or is it always red or
  always green for one of them?
- **an error on the way**: an error swallowed, or an error path that leaves
  state half-written.
- **input from outside**: input that reaches a query, a shell, a path or a URL
  unchecked; internal detail or a secret that reaches a caller, a log, a
  commit message or a pull request.

**Answer by reading, and where reading cannot settle a question, by a
throwaway test** that puts the code in that state: the cancel mid-batch, the
queue held full, the identifier reused. A test that holds settles the
question; remove it. A test that goes red is the finding's evidence: keep it,
because it becomes the regression test of the fix.

Report each finding with its file and line, its failure scenario, and its
evidence: the lines read, or the throwaway test and its output.

## 4. Fix what it found

Fix every finding, with its test as the regression test of the fix. Where you
leave one, say which and why in the pull request; where a finding is a
decision that is not yours, ask it as a question. Do not run the whole test
suite after each fix: the gate is the one full run, over the finished tree.

## 5. Add the tests the change lacks

The goal is behaviour, not lines. Every test answers: what observable
behaviour does this hold?

**End to end first.** If the change is visible across a boundary (a protocol,
an API, a page, a command), prove it through the repository's own end-to-end
harness, the one its process profile names, against the real system rather
than a fake of it. If the harness cannot yet express what the change does,
extending the harness is part of the change.

**Then the unit tests**, in this order of value:
- **edge cases**: empty, zero, the limit and one past it, concurrent callers;
- **negative paths**: invalid input refused, an operation in the wrong state,
  a dependency that fails, a caller without permission;
- **state transitions**: the whole lifecycle, an interrupted one, two changes
  at once;
- **boundaries between components**: the request through the handler to the
  store, a callback firing when it should.

**Do not write** a test that asserts how the code is built rather than what it
does, repeats an existing test with trivially different input, tests a
library rather than the change, or exists only to raise coverage.

Name each test for the behaviour it holds, and give each a setup, one action,
and an assertion about the outcome.

## 6. Record it

The pull request body records the review: who reviewed (the fresh reviewer, or
you reading afresh where the harness could not run one), and each finding
with its failure scenario and what was done about it — fixed with its
regression test, left with a reason, or asked as a question. A review that
found nothing says so. List every clause from step 2 that was not built.

Then run the gate the process profile names, once, after this review, on the
rebased tree: a gate run before it proved a tree the review has since changed.

## Rules

- **Never mark the review done without every changed file read.**
- **Never pass the reviewer your reasoning.** A reviewer that shares the
  author's assumptions finds what the author would have found.
- **Claim only what ran.** The pull request names the checks that ran and
  their results, and says which did not run.
- **Never widen an assertion or raise a timeout to make a test pass.** Find
  out why it fails.
- **Never fix an unrelated defect in the same change.** Name it in the pull
  request so it gets an owner.
