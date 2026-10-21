#!/usr/bin/env bash
# Builds Strata's own source Dockerfile (Niko1221/Strata) and pushes it to GHCR.
# Since 0.2 that Dockerfile builds the engine portable (any AVX2 CPU), so it is used unchanged.
#
#   bash build/build.sh                      the tag in build/STRATA_VERSION
#   bash build/build.sh v0.2.3               another Strata release tag
#
# Environment:
#   PUSH=0                   build only, push nothing (what CI does for a pull request)
#   IMAGE=...                default ghcr.io/williamkunz/strata
#   CUDA_ARCHITECTURES=...   default: the Dockerfile's (75;80;86;89;120); fewer builds faster
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
tag="${1:-$(tr -d '[:space:]' < "$here/STRATA_VERSION")}"
image="${IMAGE:-ghcr.io/williamkunz/strata}"
src="$(mktemp -d)"
trap 'rm -rf "$src"' EXIT

# Windows: autocrlf off so the shell scripts copied into the image keep LF line endings, and
# longpaths on because some of Strata's bench/results files are past the 260-character path limit.
git -c advice.detachedHead=false clone -q --config core.autocrlf=false --config core.longpaths=true \
    --depth 1 -b "$tag" https://github.com/Niko1221/Strata.git "$src"

# Since 0.2.2 package_terminal.py refuses to build without the source commit, but .dockerignore drops .git and
# the terminal stage declares no STRATA_COMMIT, so hand it in as a build arg declared in that stage.
grep -q '^FROM .* AS terminal$' "$src/Dockerfile" || { echo "Dockerfile has no terminal stage; redo the STRATA_COMMIT fix" >&2; exit 1; }
if ! grep -q '^ARG STRATA_COMMIT' "$src/Dockerfile"; then
  sed -i.orig '/^FROM .* AS terminal$/a\
ARG STRATA_COMMIT
' "$src/Dockerfile"
  rm "$src/Dockerfile.orig"
fi
commit="$(git -C "$src" rev-parse HEAD)"

# the source label links the GHCR package to this repository
args=(--label org.opencontainers.image.source=https://github.com/williamkunz/strata-docker
      --label org.opencontainers.image.version="$tag"
      --build-arg STRATA_VERSION="${tag#v}"
      --build-arg STRATA_COMMIT="$commit"
      -t "$image:$tag" -t "$image:latest")
if [ -n "${CUDA_ARCHITECTURES:-}" ]; then args+=(--build-arg "CUDA_ARCHITECTURES=$CUDA_ARCHITECTURES"); fi
if [ "${PUSH:-1}" != "0" ]; then args+=(--push); fi

docker buildx build "${args[@]}" "$src"
