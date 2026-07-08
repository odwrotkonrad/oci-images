#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz fn-exit-with

##[>] 🤖🤖
typeset repo_root=$(git -C ${0:A:h} rev-parse --show-toplevel)
#[why] default base is the local ci-linux build; set BASE_IMAGE to a published ref to skip building it
typeset base=${BASE_IMAGE:-ci-linux:local}

(( $+commands[docker] )) || fn-exit-with 1 "${0:t}: docker not found"

#[why] no-cache: the clone layer must fetch fresh configs; a cached layer would silently bake a stale checkout
docker build \
  --no-cache \
  --file $repo_root/ci/dev-sandbox/Dockerfile \
  --build-arg BASE_IMAGE=$base \
  --tag dev-sandbox:local \
  $repo_root
##[<] 🤖🤖
