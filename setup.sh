#!/usr/bin/env bash
set -euo pipefail

# Reload to pick up nvidia libraries from the host
ldconfig

args=(
    # Create socket in a custom location to be shared with the other container
    --host="${DOCKER_HOST}"
    # Set docker.sock group the same as the one for the runner
    --group="${DOCKER_GROUP_GID}"
)

dockerd "${args[@]}"
