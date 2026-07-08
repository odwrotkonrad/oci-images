##[>] 🤖🤖
ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG CONFIGS_SHA

RUN set -eux; \
    mkdir -p /home/ko/projects/gitlab/konradodwrot; \
    git clone https://gitlab.com/konradodwrot/configs.git /home/ko/projects/gitlab/konradodwrot/configs; \
    git -C /home/ko/projects/gitlab/konradodwrot/configs checkout "$CONFIGS_SHA"; \
    chown -R ko:ko /home/ko/projects/gitlab/konradodwrot

RUN sudo -u ko -H sh -c 'cd /home/ko/projects/gitlab/konradodwrot/configs && CI=1 container=docker MK_DRY_RUN_RENDER_SECRETS=true CHE_PROFILE=cli/linux make run-sync-full'

USER ko
WORKDIR /home/ko
CMD ["zsh", "-l"]
##[<] 🤖🤖
