FROM docker.io/debian:12.4@sha256:b16cef8cbcb20935c0f052e37fc3d38dc92bfec0bcfb894c328547f81e932d67

# Add nvidia binaries from the host
ENV PATH /usr/sbin:/usr/bin:/sbin:/bin:/usr/local/nvidia/bin/

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY scripts/setup.sh /setup.sh

RUN bash /setup.sh

COPY scripts/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
