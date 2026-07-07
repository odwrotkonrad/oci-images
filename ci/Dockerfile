##[>] 🤖🤖🤖
FROM debian:bookworm-slim

ARG GO_VERSION=1.26.4
ARG GO_SHA256_LINUX_AMD64=1153d3d50e0ac764b447adfe05c2bcf08e889d42a02e0fe0259bd47f6733ad7f
ARG CHE_VERSION=0.0.14
ARG CHE_SHA256_LINUX_AMD64=d145e7d0197a3198109551c8833f53aaea80a063b61bc023d3773e58dbd97cda
ARG RENDER_TPL_VERSION=0.0.7
ARG RENDER_TPL_SHA256_LINUX_AMD64=15b4464212a2ccafbb17ea1448386f1c6f533d3fcf9e24c76022c74356c2853f
ARG LEFTHOOK_VERSION=2.1.9
ARG LEFTHOOK_SHA256_LINUX_AMD64=0d60b0d350c923963729574f6431171f0277788884ad0c6284fa0160c36e3877
ARG YQ_VERSION=v4.53.3
ARG YQ_SHA256_LINUX_AMD64=fa52a4e758c63d38299163fbdd1edfb4c4963247918bf9c1c5d31d84789eded4
ARG ZIG_VERSION=0.16.0
ARG GORELEASER_VERSION=2.16.0
ARG TERRAFORM_VERSION=1.15.7
ARG GLAB_VERSION=1.75.0

ENV GOPATH=/usr/local/go-tools
ENV GOROOT=/usr/local/go
ENV PATH=/usr/local/go/bin:/usr/local/go-tools/bin:/usr/local/bin:$PATH
ENV CLICOLOR=0
ENV TF_PLUGIN_CACHE_DIR=/usr/local/terraform.d/plugin-cache

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      make git zsh curl ca-certificates clang sudo unzip xz-utils file procps perl \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/zsh ko \
 && echo 'ko ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/ko

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) goplat=linux-amd64; gosha="$GO_SHA256_LINUX_AMD64" ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.${goplat}.tar.gz"; \
    echo "${gosha}  /tmp/go.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/go.tar.gz -C /usr/local; \
    rm /tmp/go.tar.gz; \
    ln -sf /usr/local/go/bin/go /usr/local/bin/go; \
    ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

#[why] prebuilt bins, not go install: skip compiling their dep trees
RUN set -eux; \
    curl -fsSL -o /usr/local/bin/lefthook "https://github.com/evilmartians/lefthook/releases/download/v${LEFTHOOK_VERSION}/lefthook_${LEFTHOOK_VERSION}_Linux_x86_64"; \
    echo "${LEFTHOOK_SHA256_LINUX_AMD64}  /usr/local/bin/lefthook" | sha256sum -c -; \
    chmod +x /usr/local/bin/lefthook; \
    curl -fsSL -o /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64"; \
    echo "${YQ_SHA256_LINUX_AMD64}  /usr/local/bin/yq" | sha256sum -c -; \
    chmod +x /usr/local/bin/yq

#[why] prebuilt tarballs from the package registry, not go install: skip che's slow CGO build (tree-sitter + 1Password sdk)
RUN set -eux; \
    che_base="https://gitlab.com/api/v4/projects/konradodwrot%2Fgo%2Fche/packages/generic/che/${CHE_VERSION}"; \
    curl -fsSL -o /tmp/che.tar.gz "${che_base}/che_${CHE_VERSION}_linux_amd64.tar.gz"; \
    echo "${CHE_SHA256_LINUX_AMD64}  /tmp/che.tar.gz" | sha256sum -c -; \
    tar -xz -C /usr/local/bin -f /tmp/che.tar.gz che; \
    rm /tmp/che.tar.gz; \
    rt_base="https://gitlab.com/api/v4/projects/konradodwrot%2Fgo%2Frender-files/packages/generic/render-files/${RENDER_TPL_VERSION}"; \
    curl -fsSL -o /tmp/render-tpl.tar.gz "${rt_base}/render-tpl_${RENDER_TPL_VERSION}_linux_amd64.tar.gz"; \
    echo "${RENDER_TPL_SHA256_LINUX_AMD64}  /tmp/render-tpl.tar.gz" | sha256sum -c -; \
    tar -xz -C /usr/local/bin -f /tmp/render-tpl.tar.gz render-tpl; \
    rm /tmp/render-tpl.tar.gz

RUN set -eux; \
    arch="$(uname -m)"; \
    curl -fsSL "https://ziglang.org/download/${ZIG_VERSION}/zig-${arch}-linux-${ZIG_VERSION}.tar.xz" | tar -xJ -C /usr/local; \
    ln -sf "/usr/local/zig-${arch}-linux-${ZIG_VERSION}/zig" /usr/local/bin/zig

RUN set -eux; \
    curl -fsSL "https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_Linux_x86_64.tar.gz" \
      | tar -xz -C /usr/local/bin goreleaser

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    curl -fsSL -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${arch}.zip"; \
    unzip -d /usr/local/bin /tmp/terraform.zip; \
    rm /tmp/terraform.zip

#[why] seed the plugin cache so consumers' 'terraform init' copies providers from disk, no re-download; seed files rendered from git-repos by che (docsgen), tracking its lock
COPY ci/terraform-providers.tf /tmp/tf-cache-seed/versions.tf
COPY ci/terraform.lock.hcl /tmp/tf-cache-seed/.terraform.lock.hcl
RUN set -eux; \
    mkdir -p "$TF_PLUGIN_CACHE_DIR"; \
    terraform -chdir=/tmp/tf-cache-seed init -input=false -backend=false; \
    chmod -R a+rX "$TF_PLUGIN_CACHE_DIR"; \
    rm -rf /tmp/tf-cache-seed

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    curl -fsSL -o /tmp/glab.tar.gz "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_${arch}.tar.gz"; \
    tar -xz -C /usr/local -f /tmp/glab.tar.gz bin/glab; \
    rm /tmp/glab.tar.gz
##[<] 🤖🤖🤖
