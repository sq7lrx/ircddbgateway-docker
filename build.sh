#!/bin/sh
set -e

IMAGE_NAME="${IMAGE:-docker.io/sq7lrx/ircddbgateway}"
#IMAGE_TAG=$(date -u +"%Y%m%d")
IMAGE_TAG=$(git describe --always)
GIT_REV="$(git rev-parse --short HEAD)"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "Creating manifest for image ${IMAGE_NAME}:${IMAGE_TAG}..."

buildah manifest rm ${IMAGE_NAME}:${IMAGE_TAG} >/dev/null 2>&1 || true

buildah manifest create ${IMAGE_NAME}:${IMAGE_TAG}

for arch in amd64 arm arm64; do
    echo "Building ${IMAGE_NAME}:${IMAGE_TAG} for $arch..."
    buildah bud \
    --layers \
    --arch $arch \
    --label org.opencontainers.image.revision="${GIT_REV}" \
    --label org.opencontainers.image.created="${BUILD_DATE}" \
    --build-arg GIT_REV=${GIT_REV} \
    --build-arg IMAGE_TAG=${IMAGE_TAG} \
    --manifest "${IMAGE_NAME}:${IMAGE_TAG}" \
    .
done

echo "Pushing $IMAGE_NAME:$IMAGE_TAG"
buildah manifest push --all --rm \
    ${IMAGE_NAME}:${IMAGE_TAG} \
    "docker://${IMAGE_NAME}:${IMAGE_TAG}"