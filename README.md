# OpenTofu remote-state bucket template (DigitalOcean Spaces)

Creates one Spaces bucket to hold the OpenTofu remote state for one git
repository. Vendor it into a repo as a subtree at
`digitalocean-tofu-backend/`:

```sh
git subtree add --prefix=digitalocean-tofu-backend <template-repo-url> main
```

Then run the two-phase procedure below, and the repo has a dedicated
state bucket that is itself managed as code.

Requires OpenTofu >= 1.10. Spaces speaks the S3 API, so state storage
uses the standard `s3` backend pointed at a Spaces endpoint —
DigitalOcean documents this arrangement officially, including
`use_lockfile` locking.

What the bucket gets:

- **Versioning** — every state write is recoverable; this is the safety
  net for a corrupted or accidentally deleted state file. Noncurrent
  versions expire after 90 days (configurable) so cost doesn't
  accumulate forever.
- **State locking** via `use_lockfile` (a lock object in the same
  bucket), per DigitalOcean's Terraform-backend documentation.
- **Private ACL**; all transfers are TLS.
- **`prevent_destroy`** — `tofu destroy` refuses to delete the bucket
  (and with it, the state) unless you deliberately remove the guard.

## Credentials (the classic Spaces gotcha)

Two credential channels use the *same* Spaces access key pair under
*different* variable names:

```sh
export DIGITALOCEAN_TOKEN="<api token>"            # provider: manages the bucket
export SPACES_ACCESS_KEY_ID="<spaces key>"         # provider: Spaces API
export SPACES_SECRET_ACCESS_KEY="<spaces secret>"
export AWS_ACCESS_KEY_ID="$SPACES_ACCESS_KEY_ID"   # s3 backend: reads/writes state
export AWS_SECRET_ACCESS_KEY="$SPACES_SECRET_ACCESS_KEY"
```

## Bootstrap procedure

### Phase 1 — create the bucket with local state

```sh
tofu init
tofu apply -var repo_name=<repo-name>       # add -var region=... if not nyc3
```

The `backend.tf` block is commented out at this point, so state lands in
a local `terraform.tfstate`. The bucket is named `<repo_name>-tfstate`
unless you override `bucket_name` — note Spaces bucket names are unique
across all DigitalOcean customers, so a collision may force an override.

### Phase 2 — migrate the state into the bucket it just created

```sh
tofu output state_bucket
```

Uncomment the `terraform { backend "s3" { ... } }` block in
`backend.tf`, fill in the bucket name (and the endpoint's region if not
nyc3), then:

```sh
tofu init -migrate-state
rm terraform.tfstate terraform.tfstate.backup   # local copy is now redundant
```

Commit everything. The bootstrap config's own state now lives at
`bootstrap/terraform.tfstate` inside the bucket it manages.

### Phase 3 — point the repo's real configuration at the bucket

```sh
tofu output backend_config
```

Paste that block into the repo's main root module and `tofu init`. Use a
distinct `key` per root module (the bootstrap state uses
`bootstrap/terraform.tfstate`; the main config uses `terraform.tfstate`
by default). One bucket per repo, many keys, is fine — the rule this
template enforces is no bucket shared *across* repos.

## Pulling upstream updates

```sh
git subtree pull --prefix=digitalocean-tofu-backend <template-repo-url> main
```

Do not use `--squash`: upstream commits should land individually in the
consuming repo's history so every change is visible, not collapsed into
one opaque sync commit.

Customize by editing these files in place — that includes the required
edits (uncommenting `backend.tf`) and any repo-specific hardening.
Local edits and upstream changes three-way merge on pull; a conflict
means upstream changed something you customized, which is exactly when
you should be looking at it. Resolve by reading the upstream change and
re-applying your customization on top. A clean merge is still worth a
skim: `git log` the new commits after pulling.

## Compliance notes (weaker guarantees than the AWS/Azure templates)

- **Encryption at rest** is DigitalOcean-managed full-disk AES-256 on
  the Spaces infrastructure. There is no bucket-level SSE and no
  customer-managed key option (SSE-C exists at the object level but the
  s3 backend's key-management burden makes it impractical here). If a
  control requires customer-held keys, state for that repo belongs on
  AWS or Azure instead.
- **No access logging** — Spaces offers no S3-style server access
  logging, so per-object audit trails are not available.
- `region = "us-east-1"` in the backend block is a dummy value the s3
  backend requires; Spaces ignores it. The real region lives in the
  endpoint URL.
