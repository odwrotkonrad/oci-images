#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz fn-exit-with

##[>] 🤖🤖
typeset repo_root=$(git -C ${0:A:h} rev-parse --show-toplevel)

(( $+commands[docker] )) || fn-exit-with 1 "${0:t}: docker not found"

#[why] etag of the latest che tarball -> CHE_REF: busts the Dockerfile che layer only when che re-published (unchanged che keeps the cached layer)
typeset che_ref=$(curl -fsSI "https://gitlab.com/api/v4/projects/konradodwrot%2Fgo-modules/packages/generic/che/latest/che_latest_linux_amd64.tar.gz" | tr -d '\r' | awk 'tolower($1)=="etag:"{print $2}')

docker build \
  --file $repo_root/ci/ci-linux/Dockerfile \
  --build-arg CHE_REF=$che_ref \
  --tag ci-linux:local \
  $repo_root
##[<] 🤖🤖
