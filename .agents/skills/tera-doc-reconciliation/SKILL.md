---
name: tera-doc-reconciliation
description: Audit a repository's documents against its code and land one pull request that reconciles them, as the autonomous dev pipeline's document reconciliation does. Decide the scope, find the claims the code no longer bears out, verify what reading cannot settle, fix each document in its own voice, leave a drift that is a decision to a person, review, gate and merge through the repository's rules — or report a clean audit with no pull request. Use it whenever a session reconciles documents, filed by a person or on a schedule.
metadata:
  tera-stamp: "plugin.autonomous-dev-pipeline@3.2.1/7b9b3fbd1626c2ae96d7d54ce2ad5f1a4d031a18b9732e56a710ea3606d57d6e"
---

# tera-doc-reconciliation

Use this skill to audit a repository's documents against its code and land
the pull request that reconciles them. It is the method of the autonomous dev
pipeline's document reconciliation: a `doc-reconciliation` a person files,
and a `scheduled-doc-reconciliation` the unattended add-on files on its
schedule, both follow it as written. A person reconciling documents in their
own session follows it the same way.

**Your Work Order's instructions outrank this skill on the contract**: whose
credentials you act with, which endings you may write and how you report.
**The repository's process profile outranks it on the repository**: its
gate, its branches and pull requests, how it reviews and merges, and where
its documents live. Read `.tera/process.md` before you start, and use this
skill for what both are silent on.

## What a reconciliation is for

You are the backstop for cumulative drift. Each change keeps its own
documents current; you catch what no single change could see — a status that
stopped being true three changes ago, a path that moved, an interface
documented after it was retired, a phase still marked open.

**Do not manufacture drift to have something to open a pull request about,
and never invent a pull request URL.** A clean audit is a real finding, and
reporting one is an ending your Work Order gives you at no cost.

## The scope

What you were asked to audit is the whole specification: the documents it
names, any focus or design to weight, and any commit to anchor the audit to
when it should be about recent change rather than the current state. When it
names no scope, audit the documents the profile says the repository keeps;
with no profile, audit its top-level documents, its instructions files and
its documents tree. The repository's own instructions file may itself be one
of the documents you audit.

Your checkout is the base: the branch you were asked for, or the remote's
default branch. Work in it rather than cloning the repository again.

## The method

1. **Branch from the checked-out base.** Cut a docs branch, named the way the
   profile names branches; never commit to the base.

2. **Audit.** For each document in scope, find the claims that do not match
   the current code. `git log` and `git blame` tell you when a claim was last
   accurate and what changed underneath it, which is often faster than
   deciding whether it is true now.

3. **Verify what reading cannot settle.** The toolchains the repository
   requires are on your PATH. When a document makes a claim about behaviour
   and reading does not settle it, run the thing. A document corrected on a
   guess is drift moved, not fixed.

4. **Fix.** Edit each document to match the code. Keep edits surgical, and
   keep each document's own voice and structure. **Drift that is a choice is
   not yours to settle in passing**: where the code grants a permission,
   follows a different rule for who may act or moves scope between phases,
   and the documents decide it differently or not at all, editing the
   document to match makes that choice. Leave it unedited and report it as
   the decision the drift is waiting on, in the way your Work Order's
   endings allow. A document you amend is ratified whole: never mark a
   passage in it as awaiting a person's ratification.

5. **Review your change** and fix what you find: with the review method the
   profile names, and otherwise by reading your diff afresh against the code
   it describes. **List every document or claim in scope you did not audit
   or fix**, with why, in the pull request and in your record's summary,
   rather than ending as if the whole scope were done.

6. **Run the repository's gate** as its profile or instructions say, and
   follow what they say about a documents-only change rather than assuming
   it is exempt.

7. **Open the pull request and land it** the way the profile says, and delete
   the branch. Its body says what you audited, what you changed and what
   your review found. Landing it is the ending to aim for: an open pull
   request is not a finished reconciliation. **Never merge with an
   administrator's override, and never past a red gate, a failing required
   check or a review the pull request still requires**: each stops you, and
   you report the pull request with its real status.

## What the record says

- **Drift found and a pull request landed**: what you audited, what drift
  you found and how you fixed it, the pull request and its status as you
  last saw it, and only the files you actually edited.
- **The documents already match the code**: what you audited and against
  what. Be specific about coverage: this is the whole record that the audit
  happened. Name no pull request.
- **The audit could not be completed**, or the drift needs a decision rather
  than a document edit: what stopped the audit, or the decision the drift is
  waiting on. Name no pull request you did not land.
