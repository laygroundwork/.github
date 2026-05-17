# laygroundwork Org RUNBOOK

> Operational reference for the platform. Sections marked **TBD — fill in P0-X** depend on later phases of the Platform Consolidation v3.0 plan (see [`infra/PLATFORM_PLAN.md`](https://github.com/laygroundwork/infra/blob/main/PLATFORM_PLAN.md)). Update them as those phases land.

**Last reviewed:** 2026-05-17
**Next review due:** 2026-08-17 (quarterly)

---

## 1. Rollback procedure

Applies to any laygroundwork service that publishes SHA-tagged container images to `ghcr.io/laygroundwork/<app>:<git-sha>` and is deployed via `deploy.sh` (currently `beannbean-mcp`; `groundwork-support-bot` after P3c).

### Quick rollback (current host: Mac Mini, Caddy blue-green per P3c-2)

1. SSH to the production host.
   ```bash
   ssh lncafe@192.168.30.111   # LN cafe Mac Mini (LAN only)
   ```
2. List recent image SHAs for the service:
   ```bash
   docker images ghcr.io/laygroundwork/<app> --format '{{.Tag}} {{.CreatedAt}}'
   ```
3. Roll back by re-running `deploy.sh` with the previous SHA tag:
   ```bash
   cd /opt/laygroundwork/<app>
   ./deploy.sh <previous-git-sha>
   ```
   `deploy.sh` flips Caddy's upstream from the blue port to the green port (or vice versa) — see P3c-2.
4. Verify:
   ```bash
   curl -sf https://<host>/healthz   # liveness
   curl -sf https://<host>/readyz    # readiness (DB + tokens)
   ```
5. Post in `#bb-alerts` Slack channel with the rolled-back SHA and the reason.

### When rolling back is not enough

If the new image already wrote a destructive Postgres migration:
- See **§3 Doppler rotation** if the issue is a leaked credential.
- See **§2 Restic restore** for `/data/` (warehouse + tenant tokens).
- Schema rollback requires a manual `pg_restore` from the most recent backup; do not attempt without coordinating with @simba-beannbean.

### Fly.io rollback (after P5 / Picolot onboarding)

```bash
fly releases -a <app-name>
fly deploy --image registry.fly.io/<app>:<previous-sha>
```

---

## 2. Restic restore procedure (Mac Mini `/data/` ← Cloudflare R2)

**TBD — fill in P0-4.** Restic-to-R2 backup will be set up in P0-4.

When complete, this section should contain:
- Location of the Restic repository password (Doppler key TBD).
- R2 bucket name and S3-compatible endpoint URL.
- Latest-snapshot listing command: `restic -r s3:<endpoint>/<bucket> snapshots --latest 5`.
- Restore-to-temp-dir command: `restic -r ... restore <snap-id> --target /data.restored --include /data/tenants/<id>/`.
- Verification: re-check token files exist for each tenant and `/readyz` returns 200 after pointing the service at the restored dir.
- Whoever runs a restore: paste the snapshot ID + restore reason in `#bb-alerts`.

See: [[backup-r2]] in user memory for current state of R2 setup.

---

## 3. Doppler token rotation

**TBD — fill in P0-5.** Doppler will become the source of truth for production secrets in P0-5.

When complete, this section should contain:
- Doppler project + config naming convention (e.g., `bb-mcp`, environment configs `prd_main`, `prd_picolot`).
- Step-by-step token rotation for each integration:
  - **Shopify:** rotate Admin API access token, update the relevant tenant config in Doppler, redeploy.
  - **Klaviyo:** rotate private API key, update Doppler, redeploy.
  - **Google OAuth:** refresh-token rotation is automatic; client-secret rotation requires Doppler update + redeploy of all instances.
  - **Square:** rotate access token at squareup.com → Apps → API → Production, update Doppler.
  - **Gorgias / Slack / Asana / Canva:** see per-integration rotation pages.
- Emergency revocation: revoke at the upstream provider first, then update Doppler, then redeploy. Document timing in `#bb-alerts`.

Until P0-5 lands, secrets live in `~/.zshrc` on the Mac Mini and in `.env` files outside git. **Rotation today:** rotate at the provider, then `ssh lncafe@192.168.30.111`, edit the relevant `.env`, restart the service (`pm2 restart <app>` or `docker compose restart <app>`).

---

## 4. Observability — Axiom dashboard URLs

**TBD — fill in P0-3.** Axiom datasets and dashboards will be created in P0-3.

When complete, this section should contain:
- Axiom org URL.
- Dataset names: `bb-mcp`, `bb-support-bot` (per plan §P0-3).
- Dashboard URLs:
  - **Service overview** — request rate, error rate, p95 latency per route.
  - **OAuth token freshness** — `oauth_token_age_seconds{service,tenant}` per integration.
  - **Tenant traffic** — request volume keyed by `tenantId`.
- Alert routing: all alerts → Slack `#bb-alerts`.
  - Token age >85d (rotation imminent at 90d).
  - Error rate >5/min over 5 minutes.
  - Any `/readyz` failure on a tenant.

Until P0-3 lands, logs are `console.log` to stdout, captured by `pm2 logs`. Use [[observability-axiom]] memory note for current state.

---

## 5. On-call

- Primary: **@simba-beannbean** (Chinedum Egbosimba).
- Notifications: Slack `#bb-alerts` (Betteruptime + Axiom alerts route here once P0-3 ships).
- LAN-only host (Mac Mini at LN cafe) is reachable at `lncafe@192.168.30.111` from the cafe network. Remote access requires Tailscale.

---

## 6. Quarterly review checklist

Run this on the **first Monday of each quarter**. Update `last_reviewed` at the top of this file when complete.

- [ ] All four sections above (§1–§4) reflect current infrastructure — no stale URLs, paths, or commands.
- [ ] Every TBD marker is either resolved or still pointing at an unfinished P-phase issue (check Linear).
- [ ] Rollback procedure exercised once per quarter on a non-prod tag (dry run): SSH in, list SHAs, run `deploy.sh` with the current SHA against the standby port, verify `/readyz` returns 200, flip back. Note the result here:

  | Date       | Operator           | Result | Notes |
  |------------|--------------------|--------|-------|
  | _next run_ |                    |        |       |

- [ ] Restic snapshot listing confirms backups landed within the last 24h (after P0-4).
- [ ] Doppler audit log scanned for unexpected reads/writes (after P0-5).
- [ ] Axiom dashboards load and show data for the last 7d (after P0-3).
- [ ] All laygroundwork repos still have `staging` and `main` branch protection enabled (after P2-1).
- [ ] Bump `last_reviewed` at the top of this file and commit.
