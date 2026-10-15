#!/usr/bin/env bash
# Builds Strata's own Dockerfile (Niko1221/Strata) with strata-portable.patch and pushes it to GHCR.
# The patch builds the engine for any AVX2 CPU instead of only the CPU that ran the build.
#
#   docker login ghcr.io -u williamkunz      once, with a token that has write:packages
#   bash build/build.sh                      the tag in build/STRATA_VERSION
#   bash build/build.sh v0.1.45              another Strata release tag
#
# Environment:
#   PUSH=0                   build only, push nothing (what CI does for a pull request)
#   IMAGE=...                default ghcr.io/williamkunz/strata
#   CUDA_ARCHITECTURES=...   default: the Dockerfile's (75;80;86;89;120); fewer builds faster
#
# If the patch no longer applies, the new Dockerfile changed the build step: redo the edit by hand and
# regenerate the patch with `git diff > strata-portable.patch` in the Strata checkout.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
tag="${1:-$(tr -d '[:space:]' < "$here/STRATA_VERSION")}"
image="${IMAGE:-ghcr.io/williamkunz/strata}"
src="$(mktemp -d)"
trap 'rm -rf "$src"' EXIT

# Windows: autocrlf off so the Dockerfile's heredoc and the shell scripts keep LF line endings, and
# longpaths on because some of Strata's bench/results files are past the 260-character path limit.
# --config (not -c) writes them into the clone, so `git apply` below obeys them too.
git -c advice.detachedHead=false clone -q --config core.autocrlf=false --config core.longpaths=true \
    --depth 1 -b "$tag" https://github.com/Niko1221/Strata.git "$src"
git -C "$src" apply "$here/strata-portable.patch"

# the source label links the GHCR package to this repository
args=(--label org.opencontainers.image.source=https://github.com/williamkunz/strata-docker
      --label org.opencontainers.image.version="$tag"
      -t "$image:$tag" -t "$image:latest")
if [ -n "${CUDA_ARCHITECTURES:-}" ]; then args+=(--build-arg "CUDA_ARCHITECTURES=$CUDA_ARCHITECTURES"); fi
if [ "${PUSH:-1}" != "0" ]; then args+=(--push); fi

docker buildx build "${args[@]}" "$src"
