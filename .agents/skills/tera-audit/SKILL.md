---
name: tera-audit
description: Audit a tera setup as its auditor, after tera audit passes. How to read every work-order type a use case installs, follow the types that work together as a chain, check the configuration around them (parameters, workers and credentials, the skills sessions need, the plugin's adoption rules), and report and fix what is inconsistent or unexplained through tera config apply. Use when finishing a setup, after changing a use case's types or configuration, or when asked to review a deployment.
metadata:
  tera-stamp: "tera@v0.8.0-rc.31/08579eeca0496b9da9be726b86953e6d132c26c017a82641fe3176af61d47f3e"
---

# tera-audit

You are the **auditor** of a tera setup. `tera audit` checks what software
can check. Your review covers what it cannot: whether the work-order types a
use case installs make sense together, whether the configuration around them
serves them, and whether the use case's own rules hold. A setup is not done
until this review is done, with each finding fixed or reported.

This method is generic to every use case. Where it gives an example, the
example is one use case, not the only one.

## Before you start: `tera audit` runs first

```sh
tera audit
```

Run it against the repository you are auditing and fix what it reports
until it passes. Each failing check names its evidence and where in tera's
knowledge to read the fix. Do not start the review on a setup the audit
fails: a deployment that is not working gives the review nothing to judge.

`tera audit` deliberately does **not** check:

- **the use case's rules**, its adoption rules and contract, which differ
  from one use case to the next and are judged by reading them;
- **whether types agree with each other**, which shows only when they are
  read together;
- **whether the configuration fits the repository**: its process, its
  instructions, the work it does.

Those are this review.

## The method

### 1. Read every work-order type the use case installs, in full

Not a summary, not the first screen. For each type read its instructions,
its inputs, its outputs, its postconditions, and the connections and tools
it names. Note what it files, what it promises when it ends, and what it
expects to be handed. A type you have not read is a type you have not
audited.

### 2. Follow the types that work together as a chain

Many use cases install types that hand work to each other. A development
pipeline, for example, runs plan, then wave, then implementation, then
verification. Read each link against the next:

- **What one files, the next accepts.** The inputs one type gives a child or
  a successor are the inputs that type declares, by name and shape.
- **What one promises, the next checks.** An output or postcondition one
  type claims is what the next reads and verifies, not something it assumes.
- **Their purposes agree.** No link does work another link also does, and
  none leaves work that no link does.

Some problems only show when the chain is read together: each type reads
correctly alone, and the hand-off between them is broken.

### 3. Check the configuration around them

- **The installation's parameters.** Each one has a value that fits this
  repository and this deployment, and none is left at a default nobody
  chose.
- **Which worker owns each type, and its credentials.** Each type's work is
  owned by the worker meant to run it, and that worker holds the
  credentials and seats the type's sessions use.
- **The skills each type's sessions need.** A dispatched session has no CLI,
  so a type whose sessions read a skill names it, or the repository has it
  installed. Check that each skill a type's instructions rely on reaches its
  sessions.
- **Every trigger that files work from outside.** A trigger on a topic, a
  connector or a mail address files text no principal wrote. Check that it
  follows the golden path: it files a workflow that files a **reader** type
  (`accepts_outside_text = true`), software steps act on the reader's result,
  free text leaves only under `discloses` that is true or a person's
  `approves`, a person approves any filing made from it, and the trigger
  states `limits {}` that fit it. `tera config plan` lists each such path
  under *Outside text reaching a model session*.
  `tera skills read tera-operations work-fed-from-outside.md` is the path and
  its residuals.
- **The plugin's adoption rules, against the repository.** `tera plugin
  builtins` prints the adoption rules of each plugin the binary embeds.
  Read the rules of each installed plugin against the repository's process
  profile and its `AGENTS.md`: what the rules say the repository takes on is
  what the repository actually says and does.

### 4. Report what is inconsistent or unexplained, and fix it

Report each finding with its evidence: what you read, where, and why it does
not hold. A choice that looks wrong but is deliberate is unexplained until
someone says why; ask, or report it.

Fix in the **source tree**, never on the live deployment: edit the
configuration where it lives and land it with `tera config apply`, so the
next apply does not undo the fix and the change is reviewed like any other.
Run `tera config plan` first to see what the apply will change. A finding
you cannot fix, or that needs a person's decision, is reported, not left
out.

Then run `tera audit` again: a fix can break what the audit checks.

## Finding what you need

The reference for every kind a type or its configuration uses is in tera's
knowledge. Search it and read the section a hit names:

```sh
tera skills search work order type postcondition
tera skills read tera-reference work-order-type.md
```

The front door, `tera skills read tera`, says how to search and what a
repository installs.
