##[>] 🤖🤖
ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG SANDBOX_USER=ko

RUN useradd -m -s /bin/zsh -G root "$SANDBOX_USER" \
 && echo "$SANDBOX_USER ALL=(ALL) NOPASSWD: ALL" >"/etc/sudoers.d/$SANDBOX_USER"

USER $SANDBOX_USER
WORKDIR /home/$SANDBOX_USER

#[why] CONFIGS_REF busts this layer only when configs main moved: CI passes the current main SHA, so an unchanged configs keeps the cached clone + sync-install, a new push re-runs both. Checkout pins the build to that exact SHA (reproducible)
ARG CONFIGS_REF=main
RUN set -eux; \
    mkdir -p ~/projects/gitlab/konradodwrot; \
    git clone https://gitlab.com/konradodwrot/configs.git ~/projects/gitlab/konradodwrot/configs; \
    git -C ~/projects/gitlab/konradodwrot/configs checkout --quiet "${CONFIGS_REF}"

#[why] CHE_OTEL_ENABLED=false: no otel collector exists during the image build, so che's exporter would spew "connect: connection refused" to the baked localhost:4317 on every op. master-disable telemetry for the build (runtime sessions re-enable via CHE_OTEL_ENDPOINT -> sandbox-otelcol)
RUN cd ~/projects/gitlab/konradodwrot/configs \
 && CI=1 container=docker MK_DRY_RUN_RENDER_SECRETS=true CHE_PROFILE=cli/linux \
    CHE_OTEL_ENABLED=false \
    make sync-install

CMD ["zsh", "-l"]
##[<] 🤖🤖
