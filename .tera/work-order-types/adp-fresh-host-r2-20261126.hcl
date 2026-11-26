version = "v1"

# tera-init: this file is authored by `tera init`.
# Delete the line above to take ownership: a later run then leaves this file
# alone and reports the difference instead of rewriting it.
#
# ── A derived type: what this repository changes about a shared kind of work ──
#
# `tera init --use-case autonomous-dev-pipeline`, for the harness it dispatches on, wrote this type over its base. The type is
# the base with the attributes below substituted in: each one declared here
# replaces the base's whole value, and everything else is the base's — its
# harness, its inputs, its instructions, its postconditions — and follows an
# edit to the base with no edit here. `tera workorder types <name>`
# shows, attribute by attribute, which came from where.
#
# The base's contract (input_schema, output_schema, postconditions, tags and
# the other attributes a derived type may not declare) cannot be declared
# here: a different contract is a different type.

work_order_type "adp-fresh-host-r2-20261126" {
  based_on    = "plugin.autonomous-dev-pipeline/work-order-types/task"
  description = "Work on the adp-fresh-host-r2-20261126 repository, with the toolchains its checkout implies."

  # The activity partition every run of this type narrates into, which an
  # activity_partition recipe of that name declares. People file this type, so
  # no worker owns its work to lend it one, and it declares its own. Watching a
  # run needs read on it, which a role binding grants.
  activity_partition = "autonomous-dev-pipeline"

  # The repository this type is about, which init read from the checkout. A
  # Work Order of this type filed with no `repo` takes it, and one filed with
  # `repo` empty is refused at create naming it, so no Work Order of this
  # type starts in an empty workspace. A filer may still name another.
  input_defaults  = { repo = "https://github.com/efunneko/adp-fresh-host-r2-20261126.git" }
  required_inputs = ["repo"]

  # This repository's toolchains are not declared here: they are its toolchain
  # requirements, in this vault's .tera/toolchain-requirements/, which every
  # Work Order that clones the repository is given whatever its type. The
  # type inherits its base's own toolchains.
}
# tera-init-digest: sha256:21cb9d8f00b04f732accbb634caacfafabf0ed29252f4aa80e7bcb291bab9fc6 (edit this file and it is yours: init then replaces it only with --force <path>)
