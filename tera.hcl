# tera-init: this file is authored by `tera init`.
# Delete that line and this file is yours: a re-run of tera init leaves it alone.
#
# This repository's deployment manifest. It maps the repository's own
# .tera/ onto its vault on the deployment, so `tera config plan` and
# `tera config apply`, run here, change this vault and nothing else.

target {
  context = "local"
}

vault "adp-fresh-host-r2-20261126" {
  source = "."
}
# tera-init-digest: sha256:99331dfc148f7fcafbc0a75c3fd4f99870ed2f189a9aaf6333c34ce0c60232a3 (edit this file and it is yours: init then replaces it only with --force <path>)
