##[>] 🤖🤖
#[what] Project's Makefile
SHELL := zsh
.SHELLFLAGS := -c
export PATH := $(CURDIR)/ci/zsh/scripts:$(PATH)

WRAPPERS := run-image-build-all
COMMANDS := render-templates run-repo-ci-prepare-hooks run-repo-ci-precommit-all run-image-build-ci-linux run-image-build-dev-sandbox

.PHONY: $(WRAPPERS) $(COMMANDS)

##[>] Environment Variables [genai-include]
#[what] dev-sandbox base image ref, unset -> ci-linux:local (built by run-image-build-ci-linux)
#[vals] image ref
export BASE_IMAGE
##[<] Environment Variables

##[>] Wrappers [genai-include]
#[what] build both images for the host arch: ci-linux:local, then dev-sandbox:local FROM it
run-image-build-all: run-image-build-ci-linux run-image-build-dev-sandbox
##[<] Wrappers

##[>] Images [genai-include]
#[what] build ci-linux:local for the host arch
run-image-build-ci-linux:
	@run-image-build-ci-linux.zsh

#[what] build dev-sandbox:local for the host arch (BASE_IMAGE base, configs main baked fresh)
run-image-build-dev-sandbox:
	@run-image-build-dev-sandbox.zsh
##[<] Images

##[>] Docs [genai-include]
#[what] render *.ontoRepo.tpl onto the repo (makefile.agents.md, repo-structure.md, CLAUDE.md, AGENTS.md, README.md)
render-templates:
	@che render-templates
##[<] Docs

##[>] CI [genai-include]
#[what] install lefthook git hooks
run-repo-ci-prepare-hooks:
	@lefthook install --force

#[what] run pre-commit hooks over all files (not just staged)
run-repo-ci-precommit-all: run-repo-ci-prepare-hooks
	@lefthook run pre-commit --all-files --force
##[<] CI
##[<] 🤖🤖
