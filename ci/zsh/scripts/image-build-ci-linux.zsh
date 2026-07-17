#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz fn-exit-with

##[>] 🤖🤖
typeset repo_root=$(git -C ${0:A:h} rev-parse --show-toplevel)

(( $+commands[docker] )) || fn-exit-with 1 "${0:t}: docker not found"

docker build \
  --file $repo_root/ci/ci-linux/Dockerfile \
  --tag ci-linux:local \
  $repo_root
##[<] 🤖🤖
