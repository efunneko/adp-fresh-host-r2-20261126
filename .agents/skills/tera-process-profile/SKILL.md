---
name: tera-process-profile
description: Write a repository's process profile, `.tera/process.md`, which every session of the autonomous dev pipeline reads before anything else, with its starter gate script, CI workflow, documents layout and review checklist. Draft it from the repository's evidence where there is some, and ask only what the evidence leaves open; otherwise interview the person in a few numbered groups, each decision with a recommendation, so they agree to a group or name the numbers to change. Land the drafts as one pull request and give its link.
metadata:
  tera-stamp: "plugin.autonomous-dev-pipeline@3.2.1/80cf62e960b6a8233f096709ad752e8321d77545e23359f0cc9ad1fc7e40c751"
---

# tera-process-profile

Use this skill when a repository adopts the autonomous dev pipeline, whose
adoption rules install it, or when the person asks to write or change
`.tera/process.md`.

**You write the files, not tera.** tera serves this skill and checks the
profile's shape. It never writes the profile or the starter files, and they
belong to the repository from the moment they exist: they carry no stamp,
and nothing refreshes them.

The pipeline's words, which this skill uses and nothing else:

- a **plan** is the document that orders a feature's work into waves;
- a **plan execution** is a plan running, one `plan-execution` Work Order;
- a **wave** is one `wave` Work Order, which a plan execution files;
- an **implementation** is one item, from a branch to a pull request its
  session merges itself;
- a **wave verification** checks a drained wave and changes nothing.

## What the profile is

One Markdown file at `<repository>/.tera/process.md`, committed like code.
Every session the pipeline runs in the repository reads it first, from its
own checkout. Where it speaks to a matter of the repository it outranks the
session's own defaults; where it is silent, the defaults apply. It is
repository content, not configuration: a change merged while a plan
execution runs reaches that plan execution's later sessions.

**Its rules are conventions.** Sessions read them and follow them, as the
members of a team follow their own conventions; **tera enforces none of
them**. A plan execution that checks its plan reads `Ratified` is a session
keeping a rule, not the daemon refusing. A deployment that wants a rule
enforced uses its forge's enforcement, such as branch protection and a
`CODEOWNERS` file, which nothing here prevents. Say this to the person once,
when you start, so nobody mistakes the profile for a lock.

It carries these sections, each heading spelled exactly so. Other sections
are allowed:

| Heading | What it says |
|---|---|
| `## Gate` | the one command that verifies a change before it merges, in exactly one fenced block; when it runs; how a wave verification runs it |
| `## Build and test` | how to build and test while working, and the directed proofs |
| `## Branches and pull requests` | branch naming, one pull request per Work Order, the title and body, attribution |
| `## Review and merge` | the review skill and rules, the paths that need a person's approval, the merge method, who merges, the branch after merge |
| `## CI` | what CI runs and when; never a pull-request check in this pipeline |
| `## Naming` | the Work Orders of a plan's items and waves, a plan's and a wave's cohort |
| `## Documents` | where requirements, decisions, plans and briefs go, their names, numbers, index and statuses, how a plan is written, the documents kept current, the backlog |
| `## People` | the maintainers, who decides and ratifies, the second ratifier, the type of an out-of-band act |
| `## Rules` | the repository's own musts and must-nots |

Each of the pipeline's types reads a matter from the section the table puts
it in, in the words the template uses, so keep a matter where the template
keeps it. `tera config validate --dir <repository>` checks that every heading
is present and that `## Gate` holds exactly one fenced block. Whether the
gate command works is shown when the first Work Order runs it.

**One more section is optional: `## Work systems`.** Write it only when the
person confirms a work system outside GitHub, as "Work systems" below says. It
is not a required heading, and `tera config validate` does not ask for it: a
repository whose work lives only in GitHub writes no such section.

## The references

| Reference | What it is | Written to |
|---|---|---|
| [`references/process-template.md`](references/process-template.md) | the profile, every choice stated with its reason | `.tera/process.md` |
| [`references/gate/go.sh`](references/gate/go.sh), [`rust.sh`](references/gate/rust.sh), [`python.sh`](references/gate/python.sh), [`node.sh`](references/gate/node.sh), [`dotnet.sh`](references/gate/dotnet.sh) | the gate script for each language | `scripts/gate.sh` |
| [`references/ci/gate.yml`](references/ci/gate.yml) | a GitHub Actions workflow that runs the gate on every push to the default branch, never on a pull request | `.github/workflows/gate.yml` |
| [`references/documents-layout.md`](references/documents-layout.md) | the documents layout, with a `README.md` for each directory | `docs/<kind>/README.md` |
| [`references/review-checklist.md`](references/review-checklist.md) | the starter review checklist: the kinds of defect code is prone to, each as a state to put the code in and what would be wrong there | `.tera/review-checklist.md` |

The template is the pipeline's recommendations, and every choice in it
states its reason. A repository that accepts every recommendation keeps the
template almost as it is. A repository that differs changes the choice and
gives its own reason. Keep the `*Why:*` lines: they tell the next reader
what changing a choice gives up.

If you were not given the references as files, `tera skills show
tera-process-profile <reference>`, such as `tera skills show
tera-process-profile references/process-template.md`, prints each one.

## First, read the repository

Read the evidence before you ask anything, and note where each answer came
from:

- **CI configuration**: `.github/workflows/`, `.gitlab-ci.yml` and any other
  CI files, for the command a change must pass.
- **Build and test files**: `Makefile`, `package.json` scripts,
  `Cargo.toml`, `pyproject.toml`, `go.mod`, `*.sln`, `*.slnx`, `*.csproj`,
  `global.json`, a `justfile`, `scripts/`. They
  also say the language, and so the gate script.
- **Existing documents**: `README.md`, `CONTRIBUTING.md`, `docs/`, and where
  requirements, decisions and plans already live.
- **The repository's instructions files**: `AGENTS.md`, `CLAUDE.md`, and
  whatever other files its harnesses read.
- **History**: recent merged pull requests and their titles, which show the
  naming and the merge method in practice
  (`gh pr list --state merged --limit 30 --json title,mergeCommit,author`),
  and `git log` for branch names, trailers and past fixes.
- **The forge's rules**: `.github/CODEOWNERS`, pull request templates, and
  branch protection
  (`gh api repos/<owner>/<repo>/branches/<default-branch>/protection`).
- **Work systems outside the repository**: for each integration built-in the
  deployment offers, the signals its adoption rules name, such as issue keys
  in commits, branch names and pull request titles, links in the documents,
  and tracker URLs in configuration. What you find is a guess until the
  person confirms it, as "Work systems" below says.

**Where the evidence settles a matter, draft it from the evidence** and do
not ask about it. Where the repository already decides something, the
profile says what it decides and points at the document that says it; do
not replace a working process with the template's. **Ask only what the
evidence leaves open**, in the groups below, leaving out every decision the
evidence settled. When the evidence disagrees with itself — a contribution
guide saying "rebase" while the history shows merge commits — ask it as a
decision, recommending the one the history shows.

A repository with no history worth reading has nothing to draft from: every
decision below is open, and you ask them all in the groups.

## The interview: a few numbered groups

Open with one or two sentences: what you read, what it settled, and that
the profile's rules are conventions tera does not enforce. Then ask the open
decisions **in numbered groups, one group per message**, in the order
below. Every decision carries its number, your recommendation and its
reason in a line, taken from the template or from the evidence. End each
group with: *"Agree to the group, or name the numbers to change and what to
change them to."*

- A reply of "agree", "yes" or "fine" takes every recommendation of the
  group. A reply naming numbers changes those and takes the rest. Ask for a
  reason only where the person changes a choice and gives none; record it as
  the choice's *Why:*.
- **Never ask one decision per message**, and never ask about something the
  evidence or an earlier answer settled. A group the evidence settled whole is
  not asked.
- **Each answer is the person's**: send the group and wait for the reply.
  Never answer your own group or carry on before it is answered.

The groups, with the template's recommendations:

**1. The gate and CI**

1. **The gate**: `sh scripts/gate.sh`, the starter script for the
   repository's language, or the single command the repository already
   runs. Say in plain words what a gate is: the one command a change passes
   before it merges. Where nothing in the tree shows the language, recommend
   the language the person names in reply, from Go, Rust, Python, Node and
   .NET, and offer to call each language's script in turn for more than one.
   The gate runs on the toolchain of its language, which reaches every Work
   Order on the repository as the repository's toolchain requirement, in
   `.tera/toolchain-requirements/`. For .NET that toolchain is
   `plugin.dotnet/toolchains/dotnet`, the `dotnet` built-in's .NET SDK: a
   .NET repository requires it. `tera init` writes the requirement, and
   installs the built-in, where the checkout's root holds a `global.json` or a
   `Directory.Build.props`, the files the built-in detects a .NET
   repository by. Where it holds neither, only solutions and project files,
   init wrote none, and every gate would fail on a missing `dotnet`:
   recommend adding a `global.json` that pins the SDK, in the same pull
   request, and running `tera init` again with the adoption's arguments once
   it merges. The .NET gate gates the one solution at the root, or the one
   project with none there, and refuses a tree with more than one of either,
   naming them; where the repository has two, ask which to gate and set
   `target` in `scripts/gate.sh`.
2. **When it runs**: once, last, on the rebased branch, right before the
   session merges; while working, the directed proofs. After a gate, a fix
   or a review's edit is gated with `sh scripts/gate.sh --base <G>`, `<G>`
   being the commit that gate ran on, which tests only what changed since,
   and the branch is never rebased after its first gate; when the default
   branch moves after a green gate, the session merges without updating the
   branch and with no second gate, and only a merge the forge refuses is
   rebased, testing only what it resolved.
3. **CI's role**: CI runs the gate on every push to the default branch and is
   **never a pull-request check**; the session's gate on the rebased branch
   is the check. The starter workflow is written to
   `.github/workflows/gate.yml`, or translated to the host's CI elsewhere.
4. **A wave verification** runs the gate once on the merged tree, exactly as
   written, with nothing added to it and no second configuration.
5. **Contract suites**: an interface with more than one implementation gets
   its contract suite as its own item, ahead of the implementations.

**2. Branches, pull requests and merging**

1. **Branches**: `<type>/<short-description>`, from the up-to-date default
   branch.
2. **Pull request titles**: `<type>(<scope>): <change>` (Conventional
   Commits), a plan's pull requests taking its feature as their scope.
3. **The body**: what changed and why, how it was verified, what the review
   found, every criterion not built with why.
4. **Review**: the `tera-change-review` skill, a fresh reviewer, before the
   gate.
5. **Merge**: the session merges its own pull request by squash once its gate
   is green, keeping the title, and deletes the branch.
6. **Attribution**: no harness credit in commits or pull requests — no
   co-author trailer, no footer naming a tool. See "Attribution" below.

**3. People and approvals**

1. **The maintainers**, who decide designs and ratify plans: the people
   `.github/CODEOWNERS` names, or, with no such file, the people the person
   names in reply.
2. **A second ratifier**, a maintainer other than the plan's author: **off**.
   The maintainer who wrote a plan may ratify it.
3. **Paths that need a person's approval before a session merges a change to
   them**: `.tera/process.md`, `scripts/gate.sh` and
   `.github/workflows/gate.yml`.
4. **Out-of-band acts**: filed as `person-task`, which a maintainer takes.

**4. Naming and documents**

1. **Naming**: a plan's item's and a wave's Work Order
   `<feature> - wave <N> - <description>`; a plan's cohort
   `<feature> - <short description>`, a wave's
   `<feature> - wave <N> - <short description>`.
2. **Where documents go and how they are named**: offer the directories and
   the prefixes together, recommending decisions as architecture decision
   records, `docs/adr/ADR-<nnn>-<slug>.md`, requirements as product
   requirements documents, `docs/prd/PRD-<nnn>-<slug>.md`, and plans as
   `docs/plans/PLAN-<yyyy>-<mm>-<feature>.md`, because ADR is the name for a
   decision record that people and tools already know; a wave's brief beside
   its plan, each directory's `README.md` its index, as the documents layout
   says; offer to write those directories with their `README.md`. **A
   repository that already names its requirements or decisions keeps its
   names**: draft them from the evidence and do not offer these.
3. **Statuses**: a document awaiting its decision is `Proposed`; a ratified
   plan reads `Ratified`.
4. **The documents kept current**, which a reconciliation audits:
   `README.md`, the instructions files and `docs/`.
5. **A backlog, and where findings go**: none; every finding is filed as a
   Work Order. Where the person confirmed a work system that holds the
   backlog, recommend it instead: findings go to that tracker and that
   project, filed by the type the person names, which holds the set that
   files there.
6. **The review checklist** at `.tera/review-checklist.md`, drafted for this
   repository, as "The review checklist" below says.

With an answer to the last group, you have everything: go straight to
landing the drafts. **The person's agreement to the groups is the go-ahead
for the files and their pull request**; do not ask again before each one.

## Work systems

A repository's tickets, specs, designs and backlog may live outside it, in a
work system such as an issue tracker or a documents space, which an
integration built-in reaches. Find them in this session, before the
interview's groups, and **infer first, then ask**. Where the adoption already
found and confirmed them, and asked what each type does there, take those
answers as given and ask none of this again:

1. **Infer from the signals.** Read the repository for each available
   integration's signals, as "First, read the repository" says, and note what
   each signal pointed at: the system, and where in it this repository's work
   lives (project keys, spaces, boards).
2. **Tell the person what you found and ask them to confirm it**, in one
   message: each system and where the work lives in it, and anything they
   would add that you missed. Nothing is installed or written for a system
   they do not confirm.
3. **For each confirmed system, ask what each type does there, in the
   person's words**: whether it reads, comments, moves an item's status, or
   creates and edits, and where the findings it raises go. A type the process
   gives nothing to do in a system gets no set for it.

The adoption rules say the rest: installing only the confirmed integrations,
choosing the narrowest set per type, writing the pipeline's
`<type>_mcp_server_sets` parameters and the installation decision the person
approves. No integration ships an assignment of sets to types; the person's
answers are the only source of one.

**Write the `## Work systems` section only when an integration is
confirmed.** It holds:

- **each system, and where in it this repository's work lives**: its project
  keys, spaces or boards;
- **where tickets, specs and designs live, and where the backlog is**;
- **per type, what it does in each system, in the person's words, and the
  sets that follow from it.**

The parameters then have a stated reason a later reader can check them
against, and a later session can derive them again. The section is optional:
`tera config validate`'s required headings do not change, and a repository
with no work system outside GitHub writes none. The template carries the
section's shape, commented out.

## Attribution

The profile's `## Branches and pull requests` records what the repository
credits in its commits and pull requests. Recommend no harness credit, and
record the answer there in the template's words, as a rule a session keeps.

The answer also belongs to the deployment. A harness adds its own credit —
Claude Code's co-author trailer and pull-request footer — from its own
settings, which a session cannot reliably override on instruction, so the
pipeline's `attribution` parameter says whether a harness adds it. It
defaults to `false`, no harness credit. The parameter and the profile should
agree.

**Hand the answer to init as an argument**, once the person has given it:
run `tera init` in the repository again with the arguments the adoption
used, its answer about unattended work included and never changed, adding
`--attribution=true` if they want the harness's credit or
`--attribution=false` if not. Init sets the parameter from that argument, on
the pipeline and on its unattended add-on where the deployment holds one;
without it, the parameter stays `false`.

## The review checklist

`.tera/review-checklist.md` lists the kinds of defect the repository's code
is prone to, each as a state to put the code in and what would be wrong
there. An implementation's fresh reviewer and a wave verification read it
beside `.tera/process.md`. It is not configuration, `tera config validate`
does not judge it, and **the profile outranks it**.

Draft it for this repository rather than copying the starter:

- **With history, draft from the evidence**: past fixes and the defects they
  repaired, incident notes, and the kinds of component in the tree — queues,
  pools, caches, workers, parsers, permission checks, several
  implementations of one interface. Keep the starter's entries that fit,
  leave out the ones the code can never reach, and add what the fixes point
  at. Each entry names a state, never a known defect: a known defect is
  filed and fixed.
- **Without history, ask what the code does** in group 4's message — what
  it runs, what it holds, what it talks to, whether anything is concurrent,
  queued, long-lived or enforces a rule — and draft from the answer.

## Landing the drafts: one pull request

**Do not print the drafts into the conversation.** The person reviews them
as a pull request, where they can read every file whole and comment on a
line. Then, without asking again for each step:

1. **Write the files**: `.tera/process.md` from the template with the
   answers applied, and each starter file agreed: `scripts/gate.sh`,
   `.github/workflows/gate.yml`, the documents directories with their
   `README.md`, and `.tera/review-checklist.md`.
2. **Carry the pipeline's skills.** `tera init --use-case` wrote this
   pipeline's skills into the repository when it adopted it: a directory per skill under `.agents/skills/`, and the
   `.claude/skills` link to it where init made one. It committed them
   on the branch it ran on, unless it ran with `--track`, which leaves
   them for you to commit. A dispatched session reads them from its
   checkout of the default branch, so they land in this pull request:
   make the branch from the commit that holds them, or stage them here.
   When the repository has none, run `tera harness install --for
   <harness> --parts skills --yes`, which writes the same skills, and
   carry what it wrote.
3. **Check the profile**: `tera config validate --dir .` must report no
   finding for `.tera/process.md`. Fix any finding before you commit.
4. **Check the profile against the types it governs.** Validation reads
   its shape, never what it says. Read each type the adoption installed,
   its instructions in its recipe and what it accepts in
   `tera workorder types <type>`, and hold every rule the profile states
   about what a type does to what the type does and can do: where a
   review's findings go, what an implementation does with a non-blocking
   one, what a wave files, which input carries a ticket key. Where the two
   disagree, the profile does not land as written: change the rule to what
   the types do, or say to the person which type or parameter would have
   to change for it, as its own choice. A rule that hands a type a value,
   such as a tracker's issue key, needs an input of that type that carries
   it; where the type declares none, write no such rule, and say why in
   the pull request.
5. **Commit them on a branch** made from the up-to-date default branch and
   named as the profile you just wrote names branches, staging each file by
   name, the skills' files among them. Title the commit and the pull request as the profile titles pull
   requests, for example `chore(process): add the process profile`, with no
   attribution the profile forbids.
6. **Push and open the pull request.** Its body lists each file and what it
   is, the pipeline's skills among them, and, for every choice drawn from the evidence rather than asked, where
   it came from; it names every check that ran in this session with its
   result, and says a check that did not run did not run.
7. **Give the person the pull request's link**, and say in a sentence what
   it holds and that a person merges it, quoting the rule of the profile
   you wrote that reserves it and the reserved paths it touches, such as
   `.tera/process.md`: the reason is that rule, never one of your own, and
   a path the rule does not name is no reason. Never merge it yourself.
   The person merges it by the method the profile names, a squash where
   it says so: never ask for another to keep a commit `tera init` made,
   since the adoption rules say how a squashed adoption's source is
   recorded.

When the person asks for a change, make it on the same branch, push, and
say what changed; do not paste the file. Until the pull request merges, a
session the pipeline dispatches from the default branch does not read the
profile.

## Rules

- **Never print a draft into the conversation**; the pull request is where
  it is read.
- **Never ask one decision per message, and never make a git write its own
  ask.**
- **Claim only what ran.** A commit message, pull request body or report
  names only the checks that ran in this session, with their result.
- **Never put a secret in the profile or a starter file.** A gate that needs
  a credential reads it from the environment, and the profile names the
  variable, never its value.
- **Never edit a file tera manages**, such as `.tera/instructions.md` or the
  block between `<!-- tera:begin` and `<!-- tera:end -->`, to record the
  process. The process belongs in `.tera/process.md`.
- **Do not repeat a document the repository already has.** Point at it.
- **Write no rule as if tera enforced it.** The profile's rules are
  conventions that sessions follow.
