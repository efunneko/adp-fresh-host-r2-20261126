# Review checklist

This file lists the kinds of defect this repository's code is prone to. Each
entry is a state to put the code in and what would be wrong there. An
implementation's fresh reviewer and a wave verification read it beside
`.tera/process.md`, and put every change in each state it can reach; a wave
draws its verification's suggested probes from it. A defect counts only with
a failure scenario:
this input or state, then this wrong outcome. The process profile outranks
this file.

Keep the entries that fit this repository's code, delete the ones that never
can, and add the states your own past fixes and incidents point at. An entry
names what to look for, never a defect already known: a known defect is
filed and fixed.

## Partway through work

**State:** a task is stopped, cancelled, timed out or fails in the middle.
**Wrong there:** it keeps working after it was told to stop, or what it had
already done is lost, half-written or acknowledged without being done.

## Held full

**State:** a bounded queue, pool, buffer or connection limit is held full
under sustained load, not just reached once.
**Wrong there:** a required action is deferred for ever, a producer blocks
something it must not, or work is dropped without anyone being told.

## Without a limit

**State:** many in-flight items of one kind, with nothing bounding how many.
**Wrong there:** memory or handles grow until something fails, and the
failure lands on everything that shares the process or the resource.

## Reused after close

**State:** a component is closed and opened again, or an identifier,
counter, handle or sequence number starts over.
**Wrong there:** an event, reply or message from the old life reaches the
new one, or a stale reference acts on the wrong object.

## Ownership of in-flight data

**State:** data handed from one component to another: a buffer, a message,
a write, a record between receipt and storage.
**Wrong there:** it is used after it was released, two owners change it at
once, or it is acknowledged before it is durable.

## The edges of numeric ranges

**State:** empty, zero, one, the limit, one past the limit, negative, the
largest value the type holds.
**Wrong there:** an off-by-one, an overflow or wrap, a division by zero, a
limit that admits one too many.

## Two implementations of one port

**State:** the same input through each implementation of one interface,
including the inputs where they could differ: errors, ordering, empty
results, limits.
**Wrong there:** they give different outcomes for an input the port's
contract says one thing about.

## An enforced rule's ways round

**State:** a refusal, limit, permission check or static-analysis rule, and
every other way to reach what it guards: a second entry point, an alias,
another encoding, an indirection.
**Wrong there:** a caller gets past it by a route the rule never sees.

## Determinism

**State:** the same input run again, in another order, at another time, on
another machine, under concurrency.
**Wrong there:** the result differs: an unordered iteration, a clock, a race
or a random value reaching an output that should be fixed.

## Tooling that judges other changes

**State:** a check, a test selector, a linter or a generator, fed each
ordinary kind of change the repository sees.
**Wrong there:** its verdict is wrong for one kind: always red, always
green, or silent on a change it should catch.
