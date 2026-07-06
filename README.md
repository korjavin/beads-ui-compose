# Beads UI Compose

A git-ops docker-compose project to self-host [Beads UI](https://github.com/mantoni/beads-ui) via Portainer and GitHub Actions.

## Setup

1. **GitHub Repository:**
   This project uses a GitHub Action to build the Beads UI Docker image and push it to GitHub Container Registry (`ghcr.io`). Ensure that packages created by your GitHub account have the correct visibility settings (e.g. public or private, as per your preference).

2. **Add GitHub Secret:**
   Go to `Settings → Secrets → Actions → New repository secret`
   - Name: `PORTAINER_REDEPLOY_HOOK`
   - Value: (get this from your Portainer stack → Webhooks)

3. **Configure Portainer Stack:**
   - **Repository URL:** `https://github.com/korjavin/beads-ui-compose`
   - **Branch:** `deploy` *(Important: Not `master`)*
   - **Compose path:** `docker-compose.yml`
   - **Environment variables:** Use values from `.env.example`. Specifically, `DATA_PATH` needs to be an absolute path on your host (or a docker volume) containing your `.beads` database directory.

## How it works

When changes are pushed to `master`, the GitHub Action (`deploy.yml`) will:
1. Build the Dockerfile containing `beads-ui`.
2. Push the resulting image to GHCR.
3. Push the compose configuration to the `deploy` branch.
4. Trigger Portainer to redeploy the stack automatically using the new image and configuration.
