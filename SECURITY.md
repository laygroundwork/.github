# Security Policy

This file applies org-wide across [`laygroundwork`](https://github.com/laygroundwork) repositories.

## Reporting a vulnerability

Email **simba@beannbeancoffee.com** with details. Do not open a public issue for suspected vulnerabilities.

Please include:
- A short description of the issue and its impact.
- Steps to reproduce (PoC or minimal example).
- Any relevant logs, request/response payloads, or screenshots (with secrets redacted).

You should expect an acknowledgement within **3 business days**. We will keep you updated on remediation progress and credit reporters in release notes if desired.

## Supported versions

We currently provide security fixes for the `main` branch of each repository. Older release branches are best-effort.

## Container image retention (GHCR)

For repos that publish images to GitHub Container Registry (GHCR) under the `laygroundwork` org:

| Tag type                                          | Retention                                  |
|---------------------------------------------------|--------------------------------------------|
| **SHA-tagged** (`ghcr.io/laygroundwork/<app>:<git-sha>`) | **Retained indefinitely.** Used for reproducible rollbacks. |
| **Semver / `latest` / named tags**                | Retained indefinitely while in use.        |
| **Untagged image manifests** (orphans)            | **Deleted after 14 days.**                 |

Rationale: SHA tags are the rollback contract — `deploy.sh` rolls back to a previous commit's SHA tag. Untagged manifests pile up from rebuilds and waste storage with no recovery value.

## Secrets management

- Production secrets live in **Doppler** (see [P0-5] in `infra/PLATFORM_PLAN.md`).
- `.env` files are never committed. `gitleaks` runs on every PR via the reusable CI workflow.
- If a secret is exposed in git history: rotate the credential first, then scrub history.

## Dependabot

All repos opt into the org-wide Dependabot config in this repo (`dependabot.yml`). Patches auto-merge after CI passes; minor/major updates require human review.
