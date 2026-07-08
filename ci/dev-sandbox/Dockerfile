##[>] 🤖🤖
ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG SANDBOX_USER=ko

RUN useradd -m -s /bin/zsh -G root "$SANDBOX_USER" \
 && echo "$SANDBOX_USER ALL=(ALL) NOPASSWD: ALL" >"/etc/sudoers.d/$SANDBOX_USER"

USER $SANDBOX_USER
WORKDIR /home/$SANDBOX_USER

RUN set -eux; \
    mkdir -p ~/projects/gitlab/konradodwrot; \
    git clone https://gitlab.com/konradodwrot/configs.git ~/projects/gitlab/konradodwrot/configs

RUN cd ~/projects/gitlab/konradodwrot/configs \
 && CI=1 container=docker MK_DRY_RUN_RENDER_SECRETS=true CHE_PROFILE=cli/linux make run-sync-full

CMD ["zsh", "-l"]
##[<] 🤖🤖
