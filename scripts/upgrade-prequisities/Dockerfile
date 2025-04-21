FROM ubuntu:22.04 AS builder

ARG TARGETPLATFORM
ARG TARGETARCH

ARG KUBECTL_VERSION="v1.31.0" 
ARG YQ_VERSION="v4.44.1"     

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    jq \
    lsb-release \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN echo "Building for Platform: ${TARGETPLATFORM}, Architecture: ${TARGETARCH}" && \
    KUBECTL_INSTALL_VERSION=$(echo ${KUBECTL_VERSION} | sed 's/v//') && \
    if [ "${KUBECTL_VERSION}" = "stable" ]; then \
        KUBECTL_INSTALL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt | sed 's/v//'); \
    fi && \
    echo "Installing kubectl version v${KUBECTL_INSTALL_VERSION} for ${TARGETARCH}" && \
    curl -LO "https://dl.k8s.io/release/v${KUBECTL_INSTALL_VERSION}/bin/linux/${TARGETARCH}/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

RUN echo "Installing yq version ${YQ_VERSION} for ${TARGETARCH}" && \
    curl -Lo /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TARGETARCH}" && \
    chmod +x /usr/local/bin/yq

RUN echo "Setting up PostgreSQL APT repository..." && \
    install -d /etc/apt/keyrings && \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/postgresql-archive-keyring.gpg && \
    chmod 644 /etc/apt/keyrings/postgresql-archive-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    echo "Installing postgresql-client-14..." && \
    apt-get install -y --no-install-recommends postgresql-client-14 && \
    rm -rf /var/lib/apt/lists/*

RUN echo "Verifying installations for ${TARGETARCH}:" && \
    kubectl version --client --output=yaml && \
    jq --version && \
    yq --version && \
    psql --version
WORKDIR /app
CMD ["bash"]