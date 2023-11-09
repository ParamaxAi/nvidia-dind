#!/usr/bin/env bash
# Setup container image
set -euo pipefail

# renovate: datasource=repology depName=debian_12/curl versioning=loose
CURL_VER=7.88.1-10+deb12u4
# renovate: datasource=repology depName=debian_12/ca-certificates versioning=loose
CA_CERTS_VER=20230311
# renovate: datasource=repology depName=debian_12/gpg versioning=loose
GPG_VER=2.2.40-1.1
# renovate: datasource=repology depName=debian_12/fuse-overlayfs versioning=loose
FUSE_VER=1.10-1
# renovate: datasource=github-releases depName=docker/cli
DOCKER_VER=24.0.7
# renovate: datasource=github-releases depName=NVIDIA/libnvidia-container
NVIDIA_CONTAINER_TOOLKIT_VER=1.14.3

apt-get update
apt-get install --no-install-recommends -y \
    "curl=$CURL_VER" \
    "ca-certificates=$CA_CERTS_VER" \
    "gpg=$GPG_VER" \

# Docker repository
curl \
    --silent \
    --location \
    --fail \
    https://download.docker.com/linux/debian/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

arch=$(dpkg --print-architecture)
version=$(source /etc/os-release && echo "$VERSION_CODENAME")
echo "deb [arch=$arch signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $version stable" \
| tee /etc/apt/sources.list.d/docker.list

# Nvidia repository
curl \
    --silent \
    --location \
    --fail \
    https://nvidia.github.io/libnvidia-container/gpgkey \
    | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl \
    --silent \
    --location \
    --fail \
    https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt-get update
docker_ver=$(apt-cache madison docker-ce | grep "$DOCKER_VER" | cut -d "|" -f 2 | tr -d "[:blank:]")
nvidia_ver=$(apt-cache madison nvidia-container-toolkit | grep "${NVIDIA_CONTAINER_TOOLKIT_VER}" | cut -d "|" -f 2 | tr -d "[:blank:]")
apt-get install --no-install-recommends -y \
    "docker-ce=$docker_ver" \
    "fuse-overlayfs=$FUSE_VER" \
    "nvidia-container-toolkit=$nvidia_ver"

# Disable cgroups for Docker-IN-Docker
sed -e "s|#no-cgroups.*|no-cgroups = true|" \
    -i /etc/nvidia-container-runtime/config.toml

# Add nvidia libraries from the host
echo "/usr/local/nvidia/lib64" >/etc/ld.so.conf.d/nvidia.conf

# Docker requires iptables-legacy not iptables-nft (default)
update-alternatives --set iptables /usr/sbin/iptables-legacy

# Clean
apt-get clean
rm -rf /var/lib/apt/list/*
