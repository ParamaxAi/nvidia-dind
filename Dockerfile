FROM docker.io/debian:12.2

# renovate: datasource=repology depName=debian_12/curl versioning=loose
ARG CURL_VER=7.88.1-10+deb12u4
# renovate: datasource=repology depName=debian_12/ca-certificates versioning=loose
ARG CA_CERTS_VER=20230311
# renovate: datasource=repology depName=debian_12/gpg versioning=loose
ARG GPG_VER=2.2.40-1.1
# renovate: datasource=repology depName=debian_12/docker.io versioning=loose
ARG DOCKER_VER=20.10.24+dfsg1-1+b3
# renovate: datasource=repology depName=debian_12/fuse-overlayfs versioning=loose
ARG FUSE_VER=1.10-1
# renovate: datasource=github-releases depName=NVIDIA/libnvidia-container
ARG NVIDIA_CONTAINER_TOOLKIT_VER=1.14.3-1

# Add nvidia binaries from the host
ENV PATH /usr/sbin:/usr/bin:/sbin:/bin:/usr/local/nvidia/bin/

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
        "curl=${CURL_VER}" \
        "ca-certificates=${CA_CERTS_VER}" \
        "gpg=${GPG_VER}" \
 && curl \
        --silent \
        --location \
        --fail \
        https://nvidia.github.io/libnvidia-container/gpgkey \
        | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
 && curl \
        --silent \
        --location \
        --fail \
        https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
        | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
        | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
 && apt-get update \
 && apt-get install --no-install-recommends -y \
        "docker.io=${DOCKER_VER}" \
        "fuse-overlayfs=${FUSE_VER}" \
        "nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VER}" \
 && rm -rf /var/lib/apt/list/* \
# Disable cgroups for Docker-IN-Docker
 && sed -e "s|#no-cgroups.*|no-cgroups = true|" \
    -i /etc/nvidia-container-runtime/config.toml \
# Add nvidia libraries from the host
 && echo "/usr/local/nvidia/lib64" >/etc/ld.so.conf.d/nvidia.conf \
# Docker requires iptables-legacy not iptables-nft (default)
 && update-alternatives --set iptables /usr/sbin/iptables-legacy

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
