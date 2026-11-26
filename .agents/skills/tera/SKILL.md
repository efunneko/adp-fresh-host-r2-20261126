---
name: tera
description: The front door to tera's knowledge. How to search tera's documentation and read it in place without installing anything, which skills a repository installs and why never all of them, and where the audit framework skill is and when to use it beside tera audit. Use when setting tera up, when you need to know how any part of tera works, or before installing a tera skill.
metadata:
  tera-stamp: "tera@v0.8.0-rc.31/b6d3c60c301a64e6ffd50661871ecd302b5354e841ff8329481958050453a526"
---

# tera

Kottera is the project; tera, the Trusted Event Routing Architecture, is its
daemon and CLI.

tera is a work engine: a request becomes a Work Order, which tera dispatches
to a session, holds while it runs, and parks when it needs a person. Its
knowledge (the configuration reference, the operator guides, the CLI map,
worked examples, and the skills that teach a harness to drive it) is carried
in the `tera` binary as skills, always the version of the binary you run.

This skill says how to reach that knowledge, what to install, and where the
audit framework is.

## Search and read in place

Nothing has to be installed to read tera's knowledge. Search it, then read
the part a hit names:

```sh
tera skills search activity partition read grant
tera skills read tera-cli cli-reference.md --section golden-paths
```

- **Search** ranks sections across every skill the binary carries. Each hit
  names its skill, its reference and its section, and the exact
  `tera skills read` line that prints it. Search is lexical: use the words
  the documentation would use, such as a kind's name or a command.
- **Read** prints a whole file, one section by its anchor (`--section`), or
  a range of lines (`--lines 1-40`). Without a reference it prints the
  skill's `SKILL.md`.
- `tera skills list` shows every skill the binary carries, each with the
  questions it answers.

Read the section a hit names rather than a whole reference: references are
long, and each section answers one question.

### Without a `tera` binary

A session in a sandbox (a dispatched session, or an attended one) may have
no `tera` on its `PATH`. Then reach the same text another way, in this
order, and never answer from memory:

1. **Over MCP.** Where the deployment serves them, the daemon's
   `skills.search` and `skills.read` tools answer exactly what the two
   commands print, as `skills.search(query: "...")` and
   `skills.read(skill: "...", reference: "...", section: "...")`. Look for
   them among the tools the session was handed.
2. **Through the person.** Ask the person to run the `tera skills search`
   or `tera skills read` line on their own machine and paste what it
   prints.

Where neither is possible, say what you could not read and leave the
question open. tera's vocabularies, such as a Work Order's states, are
closed sets that a guess gets wrong.

## Setting tera up on Kubernetes

For a Kubernetes setup, start with the guide: `kubernetes.md` in the
`tera-operations` skill, which the binary carries with the Helm chart, its
commented values and its rendered manifests. It states the cluster
requirements first; read them before installing.

## What a repository installs

**Never install all of it.** A repository installs what its sessions need,
and everything else stays searchable in place:

1. **This skill, `tera`**, so a session knows how to reach the rest.
2. **The audit framework skill, `tera-audit`** (below).
3. **The skills each chosen plugin's adoption rules name.** A plugin states,
   in its adoption rules, what a repository adopting it takes on and which
   skills its sessions read. `tera plugin builtins` prints the rules and
   skills of every plugin this binary embeds.

Install them by name:

```sh
tera skills install tera tera-audit
```

`tera harness install` writes the harness kit, which carries these skills,
and no other skill of tera's own, with its instructions and its MCP entry.
Over a kit an earlier tera wrote with more of tera's own skills, it deletes
each extra copy nobody edited, so the repository holds this set. Each
installed `SKILL.md` carries the binary's stamp. Installing over a copy tera
wrote and nobody edited replaces it and says so; an edited copy is refused
unless `--force <path>` names its directory, so a person's edits are never
lost silently.

A dispatched session has no CLI. A work-order type whose sessions need a
skill names it, or the repository has it installed: whoever sets a type up
says which skills its sessions read.

## The audit framework

Setup is done when three things hold: `tera audit` passes, the audit
framework's review is done with its findings fixed or reported, and smoke
Work Orders of the installed types have completed.

- **`tera audit` runs first.** It changes nothing and never opens a browser
  or prompts. Renewing an expired sign-in is the CLI's shared credential
  renewal, which every command does silently: it rewrites the token cache
  and, for a tera-issued sign-in, rotates its refresh token on the daemon.
  It is not counted as the audit's write. The audit checks what software
  can check, and names where in the knowledge to read each fix. Fix what it
  reports and run it again until it passes.
- **Then the review, with the `tera-audit` skill.** It gives you the
  auditor's role and the method for what the audit cannot check: whether the
  installed types agree with each other, with their configuration, and with
  the rules of the use case. Read it with `tera skills read tera-audit`, or
  install it as above.

A person who comes back in a new session starts with `tera audit`.
