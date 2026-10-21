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

An **API key is always on**. Set your own in the template, or leave it empty and the first start makes one and keeps it in the Data folder; show it with `docker exec Strata strata launch --show-key --preset docker`. Keep the port on your LAN either way.

Upgrading from a 0.1.x image keeps the model: the first start moves the old files into `Data/Strata-data` instead of downloading them again. The old `Reinstall` and `Low-RAM mode` settings no longer exist; edit any setting and apply, and it takes effect on the next start.

## Updating to a new Strata release

Change the tag in `build/STRATA_VERSION` and merge it to `main`. CI builds Strata's own source `Dockerfile` at that tag, unchanged, and pushes `:<tag>` and `:latest`. If a release renames or drops environment variables (see `docker/entrypoint.sh` upstream), update `templates/strata.xml` to match.

## Credits and licence

[Strata](https://github.com/Niko1221/Strata) is by Niko1221 and the Strata contributors, under the MIT licence. The icon is Strata's own. This repository is MIT licensed; see [LICENSE](LICENSE).
