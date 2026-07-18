##[>] 🤖🤖🤖
FROM debian:bookworm-slim

COPY ci/tool-versions.env /tmp/tool-versions.env

ENV GOPATH=/usr/local/go-tools
ENV GOROOT=/usr/local/go
ENV PATH=/usr/local/go/bin:/usr/local/go-tools/bin:/usr/local/bin:$PATH
ENV CLICOLOR=0
ENV TF_PLUGIN_CACHE_DIR=/usr/local/terraform.d/plugin-cache

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      make git zsh curl ca-certificates clang sudo unzip xz-utils file procps perl \
 && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) goplat=linux-amd64; gosha="$GO_SHA256_LINUX_AMD64" ;; \
      arm64) goplat=linux-arm64; gosha="$GO_SHA256_LINUX_ARM64" ;; \
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
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) lhplat=Linux_x86_64; lhsha="$LEFTHOOK_SHA256_LINUX_AMD64"; yqplat=linux_amd64; yqsha="$YQ_SHA256_LINUX_AMD64" ;; \
      arm64) lhplat=Linux_arm64; lhsha="$LEFTHOOK_SHA256_LINUX_ARM64"; yqplat=linux_arm64; yqsha="$YQ_SHA256_LINUX_ARM64" ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /usr/local/bin/lefthook "https://github.com/evilmartians/lefthook/releases/download/v${LEFTHOOK_VERSION}/lefthook_${LEFTHOOK_VERSION}_${lhplat}"; \
    echo "${lhsha}  /usr/local/bin/lefthook" | sha256sum -c -; \
    chmod +x /usr/local/bin/lefthook; \
    curl -fsSL -o /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_${yqplat}"; \
    echo "${yqsha}  /usr/local/bin/yq" | sha256sum -c -; \
    chmod +x /usr/local/bin/yq

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) gclplat=linux-amd64; gclsha="$GOLANGCI_LINT_SHA256_LINUX_AMD64" ;; \
      arm64) gclplat=linux-arm64; gclsha="$GOLANGCI_LINT_SHA256_LINUX_ARM64" ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/golangci-lint.tar.gz "https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-${gclplat}.tar.gz"; \
    echo "${gclsha}  /tmp/golangci-lint.tar.gz" | sha256sum -c -; \
    tar -xz -C /usr/local/bin --strip-components=1 -f /tmp/golangci-lint.tar.gz "golangci-lint-${GOLANGCI_LINT_VERSION}-${gclplat}/golangci-lint"; \
    rm /tmp/golangci-lint.tar.gz

#[why] prebuilt tarballs from the package registry, not go install: skip che's slow CGO build (tree-sitter + 1Password sdk)
#   one che tarball bundles che + render-tpl (one fetch, one checksum)
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) plat=linux_amd64 ;; \
      arm64) plat=linux_arm64 ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    che_base="https://gitlab.com/api/v4/projects/konradodwrot%2Fgo-modules/packages/generic/che/latest"; \
    curl -fsSL -o /tmp/che.tar.gz "${che_base}/che_latest_${plat}.tar.gz"; \
    tar -xz -C /usr/local/bin -f /tmp/che.tar.gz che render-tpl; \
    rm /tmp/che.tar.gz

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(uname -m)"; \
    curl -fsSL "https://ziglang.org/download/${ZIG_VERSION}/zig-${arch}-linux-${ZIG_VERSION}.tar.xz" | tar -xJ -C /usr/local; \
    ln -sf "/usr/local/zig-${arch}-linux-${ZIG_VERSION}/zig" /usr/local/bin/zig

RUN set -eux; \
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) grplat=Linux_x86_64 ;; \
      arm64) grplat=Linux_arm64 ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_${grplat}.tar.gz" \
      | tar -xz -C /usr/local/bin goreleaser

RUN set -eux; \
    . /tmp/tool-versions.env; \
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
    . /tmp/tool-versions.env; \
    arch="$(dpkg --print-architecture)"; \
    curl -fsSL -o /tmp/glab.tar.gz "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_${arch}.tar.gz"; \
    tar -xz -C /usr/local -f /tmp/glab.tar.gz bin/glab; \
    rm /tmp/glab.tar.gz
##[<] 🤖🤖🤖
