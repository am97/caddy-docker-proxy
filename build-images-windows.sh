#!/bin/bash

set -e

docker login -u lucaslorentz -p "$DOCKER_PASSWORD"

PLATFORMS=windows/amd64
OUTPUT=local
TAGS_NANOSERVER_1803=
TAGS_NANOSERVER_1809=

if [[ "${BUILD_SOURCEBRANCH}" == "refs/heads/master" ]]; then
    echo "Building and pushing CI images"

    OUTPUT=registry
    TAGS_NANOSERVER_1803="-t lucaslorentz/caddy-docker-proxy:ci-nanoserver-1803"
    TAGS_NANOSERVER_1809="-t lucaslorentz/caddy-docker-proxy:ci-nanoserver-1809"
fi

if [[ "${RELEASE_VERSION}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-.*)?$ ]]; then
    echo "Releasing version ${RELEASE_VERSION}..."

    PATCH_VERSION=$(echo $RELEASE_VERSION | cut -c2-)
    MINOR_VERSION=$(echo $PATCH_VERSION | cut -d. -f-2)

    TAGS_NANOSERVER_1803="-t lucaslorentz/caddy-docker-proxy:nanoserver-1803 \
        -t lucaslorentz/caddy-docker-proxy:${PATCH_VERSION}-nanoserver-1803 \
        -t lucaslorentz/caddy-docker-proxy:${MINOR_VERSION}-nanoserver-1803"

    TAGS_NANOSERVER_1809="-t lucaslorentz/caddy-docker-proxy:nanoserver-1809 \
        -t lucaslorentz/caddy-docker-proxy:${PATCH_VERSION}-nanoserver-1809 \
        -t lucaslorentz/caddy-docker-proxy:${MINOR_VERSION}-nanoserver-1809"
fi

docker buildx build -f Dockerfile-nanoserver-1803 . \
    -o $OUTPUT \
    --platform $PLATFORMS \
    $TAGS_NANOSERVER_1803

docker buildx build --push -f Dockerfile-nanoserver-1809 . \
    -o $OUTPUT \
    --platform $PLATFORMS \
    $TAGS_NANOSERVER_1809
