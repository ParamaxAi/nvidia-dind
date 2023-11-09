FROM docker.io/debian:12.2

# Add nvidia binaries from the host
ENV PATH /usr/sbin:/usr/bin:/sbin:/bin:/usr/local/nvidia/bin/

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY scripts/setup.sh /setup.sh

RUN bash /setup.sh

COPY scripts/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
