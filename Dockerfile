##[>] 🤖🤖🤖
FROM debian:bookworm-slim

ARG GO_VERSION=1.26.4
ARG GO_SHA256_LINUX_AMD64=1153d3d50e0ac764b447adfe05c2bcf08e889d42a02e0fe0259bd47f6733ad7f
ARG CHE_VERSION=v0.0.12
ARG RENDER_TPL_VERSION=v0.0.6
ARG LEFTHOOK_VERSION=v2.1.9
ARG YQ_VERSION=v4.53.3
ARG ZIG_VERSION=0.16.0
ARG GORELEASER_VERSION=2.16.0
ARG TERRAFORM_VERSION=1.15.7
ARG GLAB_VERSION=1.75.0

ENV GOPATH=/usr/local/go-tools
ENV GOROOT=/usr/local/go
ENV PATH=/usr/local/go/bin:/usr/local/go-tools/bin:/usr/local/bin:$PATH

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

RUN set -eux; \
    install -d -m 0777 "$GOPATH"; \
    export GOMODCACHE=/tmp/go-mod GOCACHE=/tmp/go-build CC=clang; \
    go install "github.com/evilmartians/lefthook/v2@${LEFTHOOK_VERSION}"; \
    go install "github.com/mikefarah/yq/v4@${YQ_VERSION}"; \
    go install "gitlab.com/konradodwrot/go/che@${CHE_VERSION}"; \
    go install "gitlab.com/konradodwrot/go/render-files/cmd/render-tpl@${RENDER_TPL_VERSION}"; \
    chmod -R a+rX "$GOPATH" /usr/local/go; \
    rm -rf /tmp/go-mod /tmp/go-build

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

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    curl -fsSL -o /tmp/glab.tar.gz "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_${arch}.tar.gz"; \
    tar -xz -C /usr/local -f /tmp/glab.tar.gz bin/glab; \
    rm /tmp/glab.tar.gz
##[<] 🤖🤖🤖
