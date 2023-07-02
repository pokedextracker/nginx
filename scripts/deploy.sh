#!/bin/bash -e

NOW=$(date +'%s')
REPO="pokedextracker/nginx"
TAG="$(git rev-parse --short HEAD)"
[[ -z $(git status -s) ]] || TAG="${TAG}-dirty-${NOW}"

if ! docker buildx ls | grep -q multiarch; then
  echo
  echo -e "\033[1;32m==> Creating multiarch builder instance...\033[0m"
  echo

  docker buildx create --name multiarch --node multiarch
fi

echo
echo -e "\033[1;32m==> Building and pushing ${TAG}...\033[0m"
echo

# When building for other architectures, we can't keep the image locally, so we
# need to push it in the same command that we build it. We build and push for
# x86_64 and ARM64v8, just so we have both just in case. This will fail if
# you're not logged in.
DOCKER_BUILDKIT=1 docker buildx build \
  --push \
  --builder multiarch \
  --platform linux/arm64,linux/amd64 \
  --tag ${REPO}:${TAG} \
  .

echo
echo -e "\033[1;32m==> Deploying ${TAG} to production...\033[0m"
echo

fly deploy \
  --config fly.toml \
  --image ${REPO}:${TAG} \
  --vm-size shared-cpu-1x
