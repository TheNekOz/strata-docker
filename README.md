# Strata for Unraid

An Unraid Community Applications template and container image for [Strata](https://github.com/Niko1221/Strata), which runs the Qwen3.8-Flash-Next mixture-of-experts model on one NVIDIA GPU plus system RAM. It serves an OpenAI- and Anthropic-compatible API, a chat page and a live monitor.

This is an **unofficial** image. Report template or image problems in this repository's [issues](https://github.com/williamkunz/strata-docker/issues), not to the Strata project.

## Install

Search for **Strata** in the Apps tab. Before installing you need:

- the **Nvidia Driver plugin** on driver 580 or newer
- an NVIDIA RTX 20/30/40/50 card with 12 GB of VRAM or more
- an x86-64 CPU with AVX2
- 48-62 GB of free RAM, depending on the model
- 70-90 GB of disk on an SSD pool, mapped as a direct pool path (`/mnt/cache/...`), not `/mnt/user`

The first start downloads the model and sets it up, which can take a few hours. Later starts go straight to serving. The template's Overview explains each setting.

The server has **no API key by default**: anyone who can reach the port can use the model. Keep it on your LAN, or set the API key.

## Updating to a new Strata release

Change the tag in `build/STRATA_VERSION` and merge it to `main`. If the patch no longer applies, upstream changed its build step: redo the edit in the new Dockerfile and regenerate the patch with `git diff`.

## Credits and licence

[Strata](https://github.com/Niko1221/Strata) is by Niko1221 and the Strata contributors, under the MIT licence. The icon is Strata's own. This repository is MIT licensed; see [LICENSE](LICENSE).
