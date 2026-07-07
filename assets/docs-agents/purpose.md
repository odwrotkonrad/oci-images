# Purpose

## What It Is

Shared CI container images for the `konradodwrot` repos. Owns a
`debian:bookworm-slim` linux base image baking the common CI toolchain (go, che,
render-tpl, lefthook, yq, zsh, clang, make, git, zig, goreleaser, terraform,
glab), built by Docker buildx and published to this project's container registry.

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

