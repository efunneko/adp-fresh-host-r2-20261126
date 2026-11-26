version = "v1"

# tera-init: this file is authored by `tera init`.
# Delete the line above to take ownership: a later run then leaves this file
# alone and reports the difference instead of rewriting it.
#
# `tera init --use-case autonomous-dev-pipeline` found that this repository's checkout
# implies this toolchain. Every Work Order that clones this repository is
# given it, whatever its type: the system vault's
# .tera/vault-repositories/<vault>.hcl, which init writes beside the
# vault's binding, says which repository this vault is. A toolchain named
# plugin.<plugin>/toolchains/<name> resolves through this vault's
# .tera/builds-on/<plugin>.hcl, which init writes beside it.
toolchain_requirement "go" {
  toolchain = "plugin.go/toolchains/go"
}
# tera-init-digest: sha256:7922d5ea147a80fc72f41b38daf39bbb5d1de494e6d341f6b6198f7eaeb97304 (edit this file and it is yours: init then replaces it only with --force <path>)
