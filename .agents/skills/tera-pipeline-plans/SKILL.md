---
name: tera-pipeline-plans
description: Take a feature from a design to verified merges in the autonomous dev pipeline. File a `design-and-plan` Work Order and take it in place, in the harness session you are already in (an attended session is opened for it only when the person says yes to one), which lands the requirements, the decisions and the plan in one pull request, then ratifies the plan and starts its plan execution, each on the person's explicit yes; ratify and start a `plan-execution` by hand as the escape hatch with `work_order.create` on the `tera` MCP server or `tera workorder create`; and check its waves with `work_order.tree`. Follows the repository's process profile, `.tera/process.md`.
metadata:
  tera-stamp: "plugin.autonomous-dev-pipeline@3.2.1/b98560cb7fc1bd09450100d0268d26d0e314d9c3226fbd3a18005acecc3c14e5"
---

# tera-pipeline-plans

Use this skill when the person wants to design a feature and have the
autonomous dev pipeline build it, to plan from a design that already exists,
to start a plan that is already ratified, or to check on one that is running
("design the search feature", "start the plan", "how is the search plan
execution doing?", "what is wave 2 waiting on?").

The pipeline's words, which this skill uses and nothing else:

- A **plan** is a document: the order the work for a feature lands in, as
  waves.
- A **plan execution** is that plan running: one `plan-execution` Work Order,
  which runs the plan wave by wave and records each wave's verdict in the
  plan.
- A **wave** is one `wave` Work Order, filed by the plan execution: it writes
  the wave's brief, derives its implementations from the code, files them,
  waits on them, files its wave verification and writes its closeout.
- An **implementation** is one item, from a branch to a reviewed, gated pull
  request its session merges itself.
- A **wave verification** checks a drained wave against what was written down
  and changes nothing.

People design and ratify. The plan execution does the rest, as the person who
started it. It and its waves decide whatever the plan, its requirements, its
decisions and the profile clearly settle, citing the line and recording each
decision, and ask a person only what no document settles, what a document
reserves for a person, a merge refused, or work the plan gave nobody. They
never stop to report progress or to ask whether to continue.

## Read the profile first

Read `.tera/process.md` before anything else. It says:

- where requirements, decisions, plans and briefs live, and how plans are
  written (its documents section);
- who decides, who ratifies and who performs out-of-band acts (its people
  section);
- how Work Orders, pull requests and cohorts are named (its naming section);
- how a change is reviewed and merged, and which paths need a person's
  approval before a session merges a change to them.

Everything below defers to it. If the repository has no profile, ask the
person where its design documents and plans live and who ratifies a plan
before you write anything, and suggest writing a profile: every session the
pipeline runs reads one first.

## How this skill names a tool

A tool is named here as "`work_order.<verb>` on the `tera` MCP server". Your
harness spells an MCP tool its own way, so call whatever it maps that name
to. **The `tera workorder` command is the fallback** when no `tera` MCP
server is connected to your session; it reaches the same Work Orders with
your own credentials, and `tera workorder -h` is the authority on its flags.

Read a type's inputs from the deployment before filing it:
`tera workorder types <type>` prints what it accepts. Where another pipeline
installed beside this one carries a type of the same name, address it
through its installation, `autonomous-dev-pipeline/work-order-types/<type>`.

## 1. Design and plan

The design and its plan come out of one session with the person who
decides. **File one `design-and-plan` Work Order per design, and take it in
place**: in the harness session you are already in, at the person's desk, in
their checkout, signed in to tera as them, as the `tera-off-tera-work` skill
works an off-tera item. `design-and-plan` is off-tera work: tera tracks it and
never dispatches it. The Work Order is the record of how the design was made
and what it started.

**Ask once whether the person wants an attended session for it instead, and
take no for the answer unless they say yes.** An attended session is the
person's own session on a runner, sandboxed by default, opened as a child of
the `design-and-plan`; it takes the item as the person. Open one only on the
person's explicit yes to that question, never because the deployment has
attended sessions or because a guide lists them. Silence, a yes to filing, or a
general "go ahead" is a no. Either way the session follows the same method and
ends in the same documents, the same acts and the same result.

### Filing `design-and-plan`

It takes:

| Input | Value |
|---|---|
| `topic` | what to design and plan, in the person's words |
| `repo` | the repository, as an absolute URL: `https://<host>/<owner>/<repo>` |
| `branch` | the branch the documents land on, usually the default branch |
| `existing_design` | optional: the paths of an existing design's documents, to plan from them instead of designing |
| `starting_point` | optional: a tracker issue or a document page to start from, as its URL or its key, read first through the person's own reach |

```json
{
  "type": "design-and-plan",
  "title": "<feature>: design and plan",
  "inputs": {
    "topic": "<what to design>",
    "repo": "https://<host>/<owner>/<repo>",
    "branch": "<branch>"
  }
}
```

Or, as the fallback:

```sh
tera workorder create --type design-and-plan \
  --title "<feature>: design and plan" \
  --inputs '{"topic":"<what to design>","repo":"https://<host>/<owner>/<repo>","branch":"<branch>"}'
```

**Where the work starts from a tracker issue or a document page**, name it
in `starting_point`, beside `topic` (and `existing_design`, when there is
one), never instead of them. Use the reference the person gives you, its URL
or the key its system gives it; never look one up and choose it for them.

It lands at `scheduled` on the off-tera work board. **Then take it here**
(`work_order.take`, or `tera workorder take <id>`), read its instructions
(`work_order.get`), and work it as they say: the method below, then the three
acts, each on the person's explicit yes. End it with
`work_order.submit_result` carrying the pull requests, the plan's path, the
ratification and the plan execution, as its output schema says.

**Only when the person said yes to an attended session**, leave it untaken and
open one for it: an `attended-session` (or, on Codex, an
`attended-codex-session`) filed with `parent_id` naming the `design-and-plan`,
and attached to from the person's terminal:

```sh
tera workorder create --type attended-session --parent-id <design id> \
  --inputs '{"harness":"claude-code"}'
tera workorder attach <attended session id>
```

It starts with a checkout of the design's `repo` at its `branch`, and takes
the item as the person in the same way. It needs the deployment's
**`attended`** plugin, and **`attended-codex`** for Codex; this pipeline
installs neither, and its adoption says how. Installed beside the
pipeline, each plugin's session type narrates into the pipeline's activity
partition, so file the plugin's own type as above: where the deployment's
`platform { attended_default_type }` names another attended type,
`tera workorder types` shows it, and that one is filed instead. Never
hand-write an attended type to give one a partition.

### A tracker issue or a document page as the starting point

When the Work Order names a `starting_point`, or the topic names an issue or a
page, **the session reads it first**: after the process profile, before the
rest of the repository and any question, and before an existing design's
documents. It reads it **through
the person's own reach**: that system's integration on tera, through its
exposure, as the person and with the connection they consented to. In an
attended session that is the integration's server, handed beside `attendee`
when the person's role reaches the exposure (`attendee` itself reaches Work
Orders only); in the person's own harness session it is their own MCP client
on the exposure. Either reads it alike. `design-and-plan` is handed no set and
no reach of a Work Order's, and the session uses none.

**Where it cannot be read, the session says so and asks.** No integration on
tera reaches that system, the person has not connected to it, the integration
refused them, or their role on its exposure does not reach the tool that reads
it: an attended session's instructions name each integration it was not handed
and why, with the link to connect one not connected. The session tells the
person which and what would mend it (in an attended session, a mended
integration is handed on its next resume), then asks whether to wait, to work
from content they paste, or to go on without it. **It never invents the
content**, not from a title, a key or a URL. What it reads starts the
conversation and decides nothing: the requirements and decisions are still the person's, and
the documents that rest on it cite it. It changes nothing in that system
unless the person asks.

### The method

Whether here or in an attended session, the session produces
three kinds of document, in this order, in the places the profile's documents
section names. **Planning from an existing design**, read every one of its
documents first and write only the plan; change none of the design's
documents, and take a question that would change the design back to the
person.

**Ask in groups, with a recommendation each.** Number the questions, group
the ones that belong together, and recommend an answer to each with its
reasoning. The person agrees to a group or names the numbers to change. Never
ask one decision per message.

**Requirements: what must be true, and why.** What problem the feature
solves and for whom; what done looks like from the outside. Numbered
requirements (R1, R2, …), each testable, with how success is measured, and
nothing about how they will be met.

**Decisions: how the requirements will be met.** For each design question,
the options with what each costs, and a recommendation. When the person
chooses, record the decision with its context, the options rejected and why,
and its consequences. A question the person leaves open stays open, and the
decision says so: never decide it for them.

**Offer a contract suite first** where the feature has an interface with more
than one implementation: its own item, written from the requirements and
decisions ahead of the implementations, which depend on it. A suite written
by one implementation's author inherits that implementation's assumptions.

**A screen is decided by a picture**, drawn on the repository's UI kit as its
UI design procedure says; the mockup the person accepts lands with the
documents. A screen that cannot be drawn yet is left to the implementation
that builds it, and the plan says so in that wave's scope.

**The plan: the waves the work lands in.** A wave is a stretch of work that
is finished, verified and learned from before the next one starts. Start a
new wave where what comes next depends on what this one will teach, or where
a person must act in between; a typical feature is two to four waves. For
each wave, state its objective and the requirements and decisions it
carries; its scope as an outline, with acceptance criteria a wave
verification can check one at a time; what must not break while it runs; and
the out-of-band acts it needs. **Do not list a wave's items**: the wave
derives them from the code when it starts.

**Write the plan in the format `plan-execution` reads**, unless the profile
says how its plans are written:

- a header block of `**Name:** value` lines, with a `**Status:**` line and a
  `**Feature:**` line naming the feature slug, which every title and cohort of
  the plan execution carries;
- a sequencing table with a `Wave` column and a `Status` column, one row per
  wave, whose rows top to bottom are the order the waves run in;
- a section per wave, headed `Wave <N>`, which is that wave's scope; the plan
  execution adds each wave's `Verdict` at the end of its section, and writes
  the wave's status in its row;
- optionally, a table of out-of-band acts, each with the act, `When` (a wave,
  or after the last wave), its `Type`, `Before` and notes. An act whose
  `Before` names a wave is one the plan execution waits on before it files
  that wave, without asking anyone: say there what the next wave needs the
  act to report, and what happens if it does not.

**Write the plan so the sessions can decide.** A plan execution and its waves
decide what the plan and its documents clearly settle, and escalate a fork no
document settles. A requirement stated as an observable fact ("totals equal
`du -sk`'s") settles every question it answers; one left vague becomes a
question to a person mid-run. Where a choice is deliberately a person's, say
so in the plan, and it is escalated rather than decided.

**Publish each draft, and ask**: never print a document, or a diff of one,
into the terminal. Publish it with the `artifacts` tool where the session has
it, or push it to the documents' branch where it does not, name its handle or
link and its revision in one line, and ask what to change. Write it on the
person's approval, and land all of them **in one pull request**, named, reviewed and
merged as the profile says. Never merge one that touches a path the profile
reserves for a person: leave it open for that person. Every document opens
with the status the profile gives a document awaiting its decision, by
default `**Status:** Proposed`. **Never `Ratified`**: that is the next step,
and the maintainer's decision.

**Land, ratify, start: three acts, each on an explicit yes.** The person
decides and the session does the work. Ask for each act separately, and act
on it only after the person's explicit yes to it, given after they have seen
what it lands. A general "go ahead", or a yes given before the documents were
published, approves none of them. A `design-and-plan` session does
all three; at the desk, you do them the same way.

## 2. Ratification

A plan execution runs only on a ratified plan, and `plan-execution` refuses
any other: it reads the plan's status before it files anything, and a plan
that does not read `Ratified` gets no wave. Ratification is the decision of a
maintainer the profile's people section names. The work of it is yours, on
their word:

1. Once the documents' pull request has merged, ask the person whether to
   ratify. They read the plan with the requirements and decisions it cites,
   and either ask for changes or say yes.
2. **Check the people rules before you act.** If the person is not a
   maintainer, say so and whose decision it is, and do not ratify. If the
   profile asks for a maintainer other than the plan's author, that
   maintainer's yes is needed as well.
3. On the explicit yes, land the ratifying change through the repository's
   rules, as a pull request on the branch the plan execution will run from:
   the plan's status to `Ratified`, its requirements' and decisions'
   statuses to accepted, the indexes the profile keeps updated, and anything
   else the profile requires, such as a superseded-by note. Where it touches
   a path the profile reserves for a person, open it and leave the merge to
   them.

Without that yes, land no ratifying change: never on your own inference.

## 3. Starting a plan execution

Once the plan reads `Ratified`, ask the person whether to start it.
File **one `plan-execution`** for the plan only on their explicit yes, as a top-level Work Order of its own (never a child), related to the `design-and-plan` with `related`. It runs as you, and so does every
wave, implementation and wave verification beneath it, on your model
credential and your forge connection. It takes:

| Input | Value |
|---|---|
| `plan_path` | the plan's path, relative to the repository's root, already merged on `branch` and reading `Ratified` |
| `repo` | the repository, as an absolute URL: `https://<host>/<owner>/<repo>`; never `owner/repo` |
| `branch` | the branch the plan is merged on and its waves land on, by name |

and optionally `references` (handed to every wave), `harness`, `model_tier`,
`model_override` and `effort` for the plan execution's own session. Read them
with `tera workorder types plan-execution` before filing; that read also says
what create does about the worker.

Open a new cohort for the plan execution, labelled as the profile's naming
labels a plan's (by default `<feature> - <short description>`). Each wave
opens its own cohort beneath it.

Call `work_order.create` on the `tera` MCP server:

```json
{
  "type": "plan-execution",
  "title": "<feature>: run the plan",
  "inputs": {
    "plan_path": "<path to the plan>",
    "repo": "https://<host>/<owner>/<repo>",
    "branch": "<branch>"
  },
  "cohort": { "new": true, "label": "<feature> - <short description>" },
  "idempotency_key": "<feature>-plan-execution-<date>"
}
```

Or, as the fallback:

```sh
tera workorder create --type plan-execution \
  --title "<feature>: run the plan" \
  --inputs '{"plan_path":"<path>","repo":"https://<host>/<owner>/<repo>","branch":"<branch>"}' \
  --new-cohort --cohort-label "<feature> - <short description>" \
  --idempotency-key "<feature>-plan-execution-<date>"
```

Show the person the call before you make it, and tell them what it starts.
Keep the Work Order's id: it is how the plan execution is checked. If it ends
failed because the plan does not read `Ratified`, its summary quotes the
status it read; once a maintainer has ratified the plan, retry it.

## 4. Checking a plan execution

The `plan-execution` is the root. Everything it files is beneath it: one
`wave` at a time, and beneath each wave its implementations, its
out-of-band acts, its wave verification and any fixes.

- **`work_order.tree`** with the plan execution's id
  (`tera workorder tree <id>`) gives all of it in one call: each wave and its
  children, their states, what is blocked on what, and the question of
  anything parked awaiting an answer.
- **`work_order.get`** on one Work Order (`tera workorder show <id>`) gives
  its full state, including a failure's reason and the command that answers a
  pending question.
- **`work_order.events`** (`tera workorder events <id>`) gives what happened
  to it, in order.
- **The plan itself** records each finished wave's verdict, in its row and
  under its section, and each wave's brief records its closeout. Read them
  from the repository.

Report to the person in the pipeline's words, in this order:

1. what is parked waiting on a person, with each question as asked — an
   escalation from the plan execution, with its ground and the documents it
   checked, an implementation waiting for approval of a path the profile
   reserves, or a conflict it could not resolve;
2. what failed, and whether its wave or the plan execution has already
   handled it;
3. which wave is running and where it stands, in terms of its
   implementations and its verification ("wave 2 has merged four of its five
   implementations"; "wave 2 is waiting on its verification");
4. the out-of-band acts that are due, and who performs them. A plan
   execution in `paused:awaiting-event` between waves is waiting on such an
   act, not on an answer: the act is what to end;
5. the decisions the plan execution and its waves made under the documents,
   from their records' `decisions` and the plan's verdicts, when the person
   asks what was decided without them.

A parked question is the person's to answer, or the person's to delegate to
you. Answer it only when they tell you to. Never cancel, retry or approve
anything in a plan execution unless the person asks.

**A question is answered once, where it was asked.** An implementation's
question climbs the tree: its wave relays it, naming the implementation in
`could_not_decide.asked_by`, and the plan execution puts it to the person.
The parks beneath the plan execution's are the same question on its way up,
not more questions: report it once, as the plan execution asks it, and
answer the plan execution, which hands the answer down to the implementation
that asked. Never file new work for a question or a finding a Work Order in
the tree already carries. A wave's non-blocking findings are filed by the
next wave, or by the plan execution after the last, so the Work Order that
files one is still open to answer it. Should a question ever be parked
beneath a completed wave, nothing in the plan can answer it: answer it on
that Work Order itself, where it was asked.

## Rules

- **Never start a plan execution on a plan that is not ratified**, and never
  ratify or start one without the person's explicit yes to that act.
- **Never write a document the person has not seen and approved.**
- **File the `plan-execution` only.** It files the waves, and they file the
  implementations and the wave verifications. A Work Order you file by hand
  inside a running plan execution is invisible to the wave that should have
  filed it.
- **Never invent a type, a worker or an input.** Read them from the
  deployment, and ask the person when you cannot.
