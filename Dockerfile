FROM docker.io/debian:12.4@sha256:79becb70a6247d277b59c09ca340bbe0349af6aacb5afa90ec349528b53ce2c9

# Add nvidia binaries from the host
ENV PATH /usr/sbin:/usr/bin:/sbin:/bin:/usr/local/nvidia/bin/

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY scripts/setup.sh /setup.sh

RUN bash /setup.sh

COPY scripts/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
