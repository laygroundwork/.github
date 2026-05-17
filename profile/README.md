# laygroundwork

The platform team behind **[Bean & Bean Coffee Roasters](https://beannbeancoffee.com)** — café operations, e-commerce, kiosk signage, and the Groundwork platform.

We build the systems that keep the cafés running and the wholesale + DTC business growing.

## What lives here

| Repo | What it does |
|------|--------------|
| **[beannbean-mcp](https://github.com/laygroundwork/beannbean-mcp)** | MCP server that backs the AI agents — Shopify / Square / Klaviyo / Google / Gorgias / Slack / Asana / Canva tool integrations, Postgres warehouse + farms + campaign payloads. |
| **[groundwork-platform](https://github.com/laygroundwork/groundwork-platform)** | Groundwork platform — backend + frontend for the Bean & Bean operations workspace. |
| **[beannbean-kiosk](https://github.com/laygroundwork/beannbean-kiosk)** | Mac Mini four-screen kiosk launcher (AbleSign + custom signage). |
| **[bean-shopify-store](https://github.com/laygroundwork/bean-shopify-store)** | Bean & Bean Shopify theme. |
| **[groundwork-support-bot](https://github.com/laygroundwork/groundwork-support-bot)** | Customer support automation. |
| **[stronghold-scraper](https://github.com/laygroundwork/stronghold-scraper)** | Sourcing intelligence scraper. |
| **[infra](https://github.com/laygroundwork/infra)** | Canonical home of `PLATFORM_PLAN.md` — the locked Platform Consolidation v3.0 plan. |

## Current focus

**Platform Consolidation v3.0** — merging the MCP server and support bot under a `beannbean-platform` mono-repo with shared `packages/clients`, threading `tenantId` through every tool call, moving Postgres off the cafe Mac Mini to Neon, and onboarding the first external tenant (`picolot.shop`) on Fly.io.

See [`infra/PLATFORM_PLAN.md`](https://github.com/laygroundwork/infra/blob/main/PLATFORM_PLAN.md) for the full plan.

## Conventions

- `staging` is the integration branch in every repo. `main` is production. PRs always target `staging` first.
- Never force-push. Never push directly to `main` or `staging`.
- All public-facing CI uses the reusable workflow at [`laygroundwork/.github/.github/workflows/node-ci-reusable.yml`](https://github.com/laygroundwork/.github/blob/main/.github/workflows/node-ci-reusable.yml).
- Security policy: see [`SECURITY.md`](https://github.com/laygroundwork/.github/blob/main/SECURITY.md).
