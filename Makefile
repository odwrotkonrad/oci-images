##[>] 🤖🤖
#[what] Project's Makefile
SHELL := zsh
.SHELLFLAGS := -c
export PATH := $(CURDIR)/ci/zsh/scripts:$(PATH)

WRAPPERS := image-build-all
COMMANDS := render-templates repo-ci-prepare-hooks repo-ci-precommit-all image-build-ci-linux image-build-dev-sandbox

.PHONY: $(WRAPPERS) $(COMMANDS)

##[>] Environment Variables [genai-include]
#[what] dev-sandbox base image ref, unset -> ci-linux:local (built by image-build-ci-linux)
#[vals] image ref
export BASE_IMAGE
##[<] Environment Variables

##[>] Wrappers [genai-include]
#[what] build both images for the host arch: ci-linux:local, then dev-sandbox:local FROM it
image-build-all: image-build-ci-linux image-build-dev-sandbox
##[<] Wrappers

##[>] Images [genai-include]
#[what] build ci-linux:local for the host arch
image-build-ci-linux:
	@image-build-ci-linux.zsh

#[what] build dev-sandbox:local for the host arch (BASE_IMAGE base, configs main baked fresh)
image-build-dev-sandbox:
	@image-build-dev-sandbox.zsh
##[<] Images

##[>] Docs [genai-include]
#[what] render *.ontoRepo.tpl onto the repo (makefile.agents.md, repo-structure.md, CLAUDE.md, AGENTS.md, README.md)
render-templates:
	@che render-templates
##[<] Docs

##[>] CI [genai-include]
#[what] install lefthook git hooks
repo-ci-prepare-hooks:
	@lefthook install --force

#[what] run pre-commit hooks over all files (not just staged)
repo-ci-precommit-all: repo-ci-prepare-hooks
	@lefthook run pre-commit --all-files --force
##[<] CI
##[<] 🤖🤖
