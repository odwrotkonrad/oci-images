# oci-images

Shared OCI container images for the `konradodwrot` repos.

{{ renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" }}

## Images

Both images are multi-arch (linux/arm64 + linux/amd64), same tags:
`:vX.Y.Z` (immutable release consumers pin), `:latest` (moving),
`:$CI_COMMIT_SHORT_SHA` (immutable).

### ci-linux

`registry.gitlab.com/konradodwrot/infra/oci-images/ci-linux:latest`

`FROM debian:bookworm-slim`, baking the shared CI toolchain so consuming jobs
skip the per-pipeline `apt-get` + `go install` + `curl` bootstrap:

| Tool | Purpose |
| ---- | ------- |
| go, clang, make, git | core build toolchain (CGO for che/tree-sitter) |
| che | dotfile loader, renders repo + host templates |
| render-tpl | ad-hoc template rendering |
| lefthook | git hooks (pre-commit docs check) |
| yq | YAML query |
| zig | linux cross-compile backend (goreleaser) |
| goreleaser | go release builds |
| terraform | IaC (infra/git-repos) |
| glab | GitLab CLI |

### dev-sandbox

`registry.gitlab.com/konradodwrot/infra/oci-images/dev-sandbox:latest`

`FROM ci-linux` (same pipeline's build), cloning the public `configs` repo at a
pinned SHA (`CONFIGS_SHA` build arg, current `main` head at build time) and
running the full che install: `run-sync-full`, `cli/linux` profile, op://
secret renders skipped. The result is a ready config-baked dev shell (zsh,
che-loaded dotfiles, no secrets), pulled by the `sandbox` repo for local
session pods.

## Consume

```yaml
variables:
  CI_IMAGE: registry.gitlab.com/konradodwrot/infra/oci-images/ci-linux:vX.Y.Z

validate-pre-commit-all:
  image: $CI_IMAGE
  script:
    - make run-repo-ci-precommit-all
```

The images are public-pullable (public repo), so cross-project pulls need no auth.

## Versions

Tool pins live in one place: `ci/tool-versions.env`. Bump there; the file is
`COPY`-ed into the build and sourced per `RUN` in `ci/ci-linux/Dockerfile`. This is the
single source of truth for CI-image tool versions (host provisioning still lives in
`configs/ci/zsh/scripts/installs/00-ci-deps.zsh`).

## Build

CI builds both images with Docker buildx on changes to the Dockerfiles /
`ci/tool-versions.env`, on `main`, or manually; `dev-sandbox` builds `FROM` the
`ci-linux` published in the same pipeline. See `.gitlab-ci.yml`.

## License

MIT — see [LICENSE](LICENSE).
