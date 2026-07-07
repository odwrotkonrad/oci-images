# Purpose

## What It Is

Shared CI container images for the `konradodwrot` repos. Owns a
`debian:bookworm-slim` linux base image baking the common CI toolchain (go, che,
render-tpl, lefthook, yq, zsh, clang, make, git, zig, goreleaser, terraform,
glab), built by kaniko and published to this project's container registry.

## Why It Exists

Every repo's CI repeated the same expensive bootstrap: pull a golang base,
`apt-get` clang/make/zsh, then `go install che@latest` + `lefthook@latest`.
Compiling che from source (1Password CGO SDK + tree-sitter) cost ~4–5 min per
pipeline, per repo, every run. Baking the toolchain once here drops that toil to
a cached image pull.

## Goals

- One shared, versioned CI base image every repo pulls.
- Single source of truth for CI tool versions (`ci/tool-versions.env`).
- Public-pullable, so cross-project pulls need no auth.
- Fast pipelines: no per-job compile of che, no per-job tool downloads.

## How To Use

Consumers pin `registry.gitlab.com/konradodwrot/infra/ci-images/ci-linux:bookworm`
as their job `image:`. Bump a tool by editing `ci/tool-versions.env`; CI rebuilds
and republishes the image via kaniko.

## Future Direction

- Multi-arch (arm64) linux image if a runner needs it.
- A darwin image only if a self-hosted Tart runner is adopted (SaaS macOS
  runners cannot use custom images).
