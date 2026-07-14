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

#[why] CHE_OTEL_ENABLED=false: no otel collector exists during the image build, so che's exporter would spew "connect: connection refused" to the baked localhost:4317 on every op. master-disable telemetry for the build (runtime sessions re-enable via CHE_OTEL_ENDPOINT -> sandbox-otelcol)
RUN cd ~/projects/gitlab/konradodwrot/configs \
 && CI=1 container=docker MK_DRY_RUN_RENDER_SECRETS=true CHE_PROFILE=cli/linux \
    CHE_OTEL_ENABLED=false \
    make run-sync-full

CMD ["zsh", "-l"]
##[<] 🤖🤖
