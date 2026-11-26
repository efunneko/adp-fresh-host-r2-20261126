This is this repository's process profile. Every session the autonomous dev
pipeline runs here reads it before anything else, and where it speaks to a
matter of this repository it outranks the session's own defaults. Each choice
below is followed by its reason, so whoever changes a choice knows what the
change gives up. A section may point at a document in this repository instead
of repeating it.

**These rules are conventions.** Sessions read them and follow them, as the
members of a team follow their own conventions; tera enforces none of them. A
repository that wants a rule enforced uses its forge's enforcement, such as
branch protection and a `CODEOWNERS` file, which nothing here prevents.

## Gate

```sh
sh scripts/gate.sh
```

- **Run it once, last, on the rebased branch**: after the change is finished,
  reviewed and rebased once onto the freshly fetched default branch, and
  right before the session merges it. *Why:* what the gate verifies is then exactly what
  merges. A gate run earlier proves a tree that no longer exists.
- **Commit before you gate, and note the commit it ran on.** The pull request
  records each gate run: its flags, the commit it ran on and what it
  selected. *Why:* the gate tests the working
  tree, and a later gate's scope can only be named from a commit.
- **A gate that finished its test step proves, at its commit, every test it
  passed; a later gate tests only what changed since.** After a red in the
  test step, find why, fix it, run the failing tests alone until they pass,
  commit, and run the scoped gate, `sh scripts/gate.sh --base <R>`, where
  `<R>` is the commit the red gate ran on. The same holds after a green gate
  at `<G>`: an edit for any reason, such as a review's fix or a ruling after
  a park, is committed and gated with `sh scripts/gate.sh --base <G>`. The
  scoped gate must select the package that was red; if it does not, the fix
  did not reach that package. Never rebase after the first gate, since
  `--base` would then take in everything the default branch brought. Only a red in a step before the
  test, such as formatting, build, lint or vet, which stops the gate before
  any test runs, is followed by the whole gate: fix it, run that step's
  command from `scripts/gate.sh` alone until it is clean, and gate once.
  *Why:* a test the earlier gate passed, which nothing since has touched,
  would pass again, and a whole gate after every fix costs as much as the
  first, multiplied by every other session gating on the same host.
- **When the default branch moves after a green gate, merge without
  updating the branch, and do not gate again.** That it moved is not a
  reason to rebase. Only when the forge refuses the merge for a conflict,
  rebase onto the freshly
  fetched default branch, note the files each stop leaves conflicted, and
  test those alone and nothing else: for each package with a resolved code
  file, that package's tests, as the test step of `scripts/gate.sh` runs
  them (`go test -race -count=1 ./<package>`, `cargo test -p <crate>`,
  `dotnet test <test project>` for each test project that is or references
  the project; for Python and Node, whose gate selects nothing
  narrower, the whole test step). A resolved document needs no test, since this repository has no document check; a repository
  that adds one names it here. Then force-push with lease and merge.
  *Why:* the change was proven at its green gate, and what the default
  branch brought was proven by its own gates; a rebase after the gate
  re-opens both, and `--base <G>` after it would select everything merged
  since `<G>`. The resolution is the only code neither proved. CI runs the
  whole gate on the default branch after every merge, so an interaction
  with what merged beside the change is found there, a little later, and
  fixed like any red on the default branch (`## CI`). While other items
  merge, the default branch moves about as often as a gate takes.
- **It is the only check a change must pass before it merges**, and nothing
  else stands in for it: not a pull-request check, not a person's local run.
  *Why:* with one command, a session and a person cannot disagree about what
  green means.
- **A red the change did not cause is one line in the pull request**, naming
  the test and how it was shown not to be the change's, and is not fixed in
  the same pull request. *Why:* one pull request stays one item, and the
  unrelated red gets an owner instead of a drive-by fix nobody reviewed as
  one.
- **No run on another platform is required before a merge.** *Why:* the gate
  runs on one host; a repository that ships to another adds the run here and
  names how to start it.
- **A wave verification runs the gate once on the merged tree, exactly as
  written above.** Whatever the gate script itself runs, such as a race build,
  is the gate; nothing is added to it. The gate takes no list of commits to
  select from, and the verification runs it without `--base`, so it runs
  whole on the branch's head, and the verification says that it selected the
  whole tree. No second configuration of the gate
  runs, and no whole suite in another configuration is a probe. *Why:* the gate is the same command for every
  change, and a second configuration is a second gate nobody agreed to.

## Build and test

- **Build and test through the steps `scripts/gate.sh` runs.** Read the
  script for the exact commands. *Why:* the build that passes locally is then
  the build the gate runs.
- **While you work, run the directed proofs**: the tests you added, the tests
  of the code you changed, and the end-to-end tests of the behaviour, before
  the gate. *Why:* a red found early is cheap, and the gate is the slowest
  proof there is.
- **Every change in behaviour comes with a test that fails without it.**
  *Why:* a test that also passes on the old code proves nothing about the new
  code.
- **An interface with more than one implementation gets its contract suite
  as its own item**, written from the requirements and decisions ahead of the
  implementations, which depend on it; a plan offers one first. *Why:* a
  contract suite written by an implementation's author inherits that
  implementation's assumptions, and cannot tell two implementations apart
  where they differ.
- **A flaky test is investigated, never re-run until it passes, and never
  fixed by loosening its assertion or raising a timeout.** *Why:* a retried
  flake hides a real race, and a widened assertion stops testing anything.

## Branches and pull requests

- **Branches are named `<type>/<short-description>`**, cut from the
  up-to-date default branch, with `<type>` as in the pull request's title.
  *Why:* a fresh base keeps the rebase small, and the name says what the
  branch is for.
- **One pull request per Work Order.** *Why:* a reviewer judges one change at
  a time, and reverting an item is one action.
- **A pull request is titled `<type>(<scope>): <change>`**, where `<type>` is
  one of `feat`, `fix`, `docs`, `test`, `refactor` or `chore` (Conventional
  Commits). A plan's pull requests take the plan's feature as their scope:
  `feat(search): index titles by language`. *Why:* the history reads as a
  changelog, and a plan's pull requests can be found by its feature.
- **The body says what changed and why, how it was verified, what the review
  found** (each finding with its failure scenario and what was done about it,
  or that it found nothing), **every acceptance criterion and named clause it
  did not build, with why**, and any red that is not the change's, with how
  that was shown. It carries `Closes #<n>` when the item has an issue. *Why:*
  the wave verification reads the body, and a clause left out without a word
  is found only after merge.
- **Attribution: no commit and no pull request carries a harness's credit** —
  no co-author trailer, no footer naming a tool. The author of a change is
  the person whose Work Order made it. *Why:* a trailer names a tool rather
  than an author, and the Work Order already records which session wrote the
  change.

## Review and merge

- **Every change is reviewed with the `tera-change-review` skill before the
  gate runs**: a fresh reviewer that did not write the change reads it with
  the task, the documents it cites, this repository's instructions, this
  profile and `.tera/review-checklist.md`, and none of the author's
  reasoning. A finding counts only with a failure scenario, and the author
  fixes what it finds. *Why:* the cheapest time to fix a problem is before
  anyone else has read it, and a reader that shares the author's assumptions
  finds only what the author would have found.
- **These paths need a person's approval before a session merges a change to
  them:** `.tera/process.md`, `scripts/gate.sh` and
  `.github/workflows/gate.yml`. A session whose change touches one leaves its
  pull request open and asks a person. *Why:* those files decide how every
  later change is judged, so changing them is a decision, not an edit.
- **The session merges its own pull request** once the gate it ran on the
  rebased branch is green and the review is done, **by squash**, keeping the
  pull request's title as the squash subject. It never merges with an
  administrator's override, and never past a red. *Why:* the default branch
  gets one commit per item, so `git bisect` and `git revert` work in whole
  items, and a pull request that waits approved and unmerged goes stale
  against its base.
- **The branch is deleted once it has merged.** *Why:* a merged branch left
  behind reads as work still in progress.
- **A change of documents alone** — a brief, a plan's recorded verdict, a
  reconciliation — **is reviewed, gated and merged like any other change.**
  *Why:* a document governs the code that follows it, and the gate is cheap on
  a change that touches no code.

## CI

- **CI is never a pull-request check here.** The session's gate on the
  rebased branch is the check before a merge. CI runs `scripts/gate.sh` on
  every push to the default branch, in `.github/workflows/gate.yml`, and
  proves what merged. *Why:* a pull-request check would run the same command
  a second time on a tree the session already gated, and make every merge
  wait for it.
- **A session does not start, wait on or re-run the default branch's CI.**
  *Why:* that run belongs to what has already merged. Its red is fixed as its
  own item, not by whichever session happens to notice it.
- **A check is never disabled, skipped or marked optional to get a merge
  through.** *Why:* a check switched off once stays off, and nobody notices.

## Naming

- **A plan's item's Work Order** is titled `<feature> - wave <N> - <what the
  item does>`, `<feature>` being the plan's feature as its `**Feature:**` line
  names it. *Why:* a plan's work stays findable by its feature and its wave.
- **A wave's Work Order** is titled `<feature> - wave <N> - <short
  description>`. *Why:* the wave is a step people see, and its title says
  which plan and which wave it is.
- **A plan's cohort** is labelled `<feature> - <short description>`, and **a
  wave's cohort** beneath it `<feature> - wave <N> - <short description>`.
  *Why:* the queue then groups a plan execution the way the plan does.
- **Any other Work Order a plan files**, such as an out-of-band act, is
  titled `<feature> - <what it does>`. Work outside a plan is titled by what
  it does. *Why:* every Work Order of a plan carries its feature.
- **Pull requests** are titled as `## Branches and pull requests` says.

## Documents

- **Requirements go in `docs/prd/`, decisions in `docs/adr/`, and plans in
  `docs/plans/`.** A wave's brief goes beside its plan, named
  `brief-<plan>-wave<N>.md`, and its closeout is appended to it. Each
  directory's `README.md` says what belongs there. *Why:* a session told where
  a kind of document lives reads it before acting, and never invents one that
  already exists.
- **Requirements and decisions are numbered, plans are dated**:
  `PRD-<nnn>-<slug>.md`, `ADR-<nnn>-<slug>.md` and
  `PLAN-<yyyy>-<mm>-<feature>.md`. **The index is each directory's
  `README.md`**, which lists its documents with their status; a new document
  adds its line there. *Why:* a number never changes when a title does, so a
  citation stays true.
- **A plan is written in the format a plan execution reads**: a header block
  of `**Name:** value` lines with a `**Status:**` and a `**Feature:**` line, a
  sequencing table with a `Wave` and a `Status` column whose rows run top to
  bottom, and a section per wave headed `Wave <N>`. **Each wave's verdict
  goes** in that wave's row of the sequencing table and under a `Verdict`
  heading at the end of its section. *Why:* a plan execution runs the plan
  from those parts and records each wave's verdict in them.
- **A document awaiting its decision opens `**Status:** Proposed`.** A plan
  becomes `Ratified` when a maintainer ratifies it, and a plan execution runs
  only a plan whose status reads `Ratified`. A requirement or a decision
  becomes `Accepted`. *Why:* the status is what a session checks before it
  acts on a document, and it must never build to a decision nobody accepted.
- **The documents this repository keeps current** are `README.md`, the
  repository's instructions files and everything under `docs/`. *Why:* a
  reconciliation audits these against the code, and a document nobody keeps
  current misleads whoever reads it next.
- **Backlog: this repository keeps none.** Every finding a wave verification
  raises is filed as a Work Order. *Why:* a finding filed as work has an
  owner; a backlog entry waits for someone to remember it.
  <!-- Where the backlog lives in a tracker, this item says so instead and
  names where findings go: the tracker, the project, and the type that files
  there, which holds the set that does it, as `## Work systems` records. -->

<!-- ## Work systems

Optional, and not a required heading: write this section only when an
integration is confirmed, and delete this comment otherwise. A repository
whose work lives only in GitHub has no such section.

- **<system>**: this repository's work lives in <project keys, spaces,
  boards>.
- **Where work lives**: tickets in <system and place>; specs in <...>;
  designs in <...>; the backlog in <system and project, or "this repository
  keeps none">.
- **What each type does there**, in the maintainers' words, and the sets that
  follow from it:
  - `<type>` in <system>: "<what it does, in the person's words>". Sets:
    `<set>`.
  - A type the process gives nothing to do in a system gets no set for it
    and is not listed for that system.

*Why:* each type's `<type>_mcp_server_sets` parameter then has a stated
reason a later reader can check it against, and a later session can derive
it again. -->

## People

- **The maintainers** are the people `.github/CODEOWNERS` names. **They decide
  requirements and designs**, in a design-and-plan conversation a maintainer
  holds. *Why:* one named group decides, so a design never waits on someone
  who was never asked.
- **A maintainer ratifies a plan** before a plan execution runs it, by landing
  the change that sets its status to `Ratified`. **A second ratifier is not
  required**: the maintainer who wrote the plan may ratify it. *Why:* a plan
  execution runs only on a plan a person has accepted, and on a small team a
  second ratifier would make every plan wait.
- **Out-of-band acts** — whatever a session cannot do, such as a release, a
  credential, a deployment or a physical device — **are filed as
  `person-task`**, the pipeline's off-tera type, and a maintainer takes them.
  *Why:* every act still has a record and an owner, even when no session can
  perform it.
- **The pipeline's sessions decide what the documents clearly settle.** A
  plan execution and its waves decide whatever a ratified plan, its
  requirements and decisions, and this profile settle, citing the line and
  recording each decision, and ask a maintainer only a fork no document
  settles, something a document reserves for a person, a merge refused, or
  work the plan gave nobody. A choice reserved for a maintainer is named here
  or in the plan. *Why:* a ratified plan is the maintainers' answer to every
  question it settles, and asking again only interrupts them.

## Rules

- **Never commit a secret**: no token, password or key in a file, a commit
  message or a pull request. A gate that needs a credential reads it from the
  environment. *Why:* a pushed secret is published, and rotating it is the
  only remedy.
- **Never push to the default branch directly.** Every change goes through a
  pull request. *Why:* the gate and review only protect what goes through
  them.
- **Stage files by name, never with `git add -A` or `git add .`.** *Why:* a
  bulk add commits whatever else is in the tree.
- **Ask before anything destructive or hard to undo**: deleting a branch
  someone else uses, or rewriting the default branch's history. *Why:* those
  cannot be taken back by the next commit.
- **A choice the documents leave open is asked, not made in passing.** *Why:*
  a choice made inside an item is a decision nobody reviewed as one.
