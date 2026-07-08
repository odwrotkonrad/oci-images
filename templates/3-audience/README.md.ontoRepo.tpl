# ci-images

Shared CI container images for the `konradodwrot` repos.

{{ renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" }}

## Image

`registry.gitlab.com/konradodwrot/infra/ci-images/ci-linux:bookworm`

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

Tags: `:bookworm` (pinned ref consumers use), `:latest` (moving), `:$CI_COMMIT_SHORT_SHA` (immutable).

## Consume

```yaml
variables:
  CI_IMAGE: registry.gitlab.com/konradodwrot/infra/ci-images/ci-linux:bookworm

validate-pre-commit-all:
  image: $CI_IMAGE
  script:
    - make run-repo-ci-precommit-all
```

The image is public-pullable (public repo), so cross-project pulls need no auth.

## Versions

Tool pins live in one place: `ci/tool-versions.env`. Bump there; the file is
`COPY`-ed into the build and sourced per `RUN` in `ci/Dockerfile`. This is the
single source of truth for CI-image tool versions (host provisioning still lives in
`configs/ci/zsh/scripts/installs/00-ci-deps.zsh`).

## Build

CI builds the image with Docker buildx on changes to `ci/Dockerfile` / `ci/tool-versions.env`,
on `main`, or manually. See `.gitlab-ci.yml`.

## License

MIT — see [LICENSE](LICENSE).
