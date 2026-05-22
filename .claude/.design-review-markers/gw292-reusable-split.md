# Design-review marker — gw292-reusable-split

Ran at: 2026-05-22 (UTC; see file mtime)
Depth: thorough
Kind: engineering
Buckets matched: infra_deployment, auth_credential
Reviewers invoked: DevOps Automator, SRE (Site Reliability Engineer), Software Architect, Security Engineer, Code Reviewer
Reviewers timed out: none
Findings: 4 Critical, 6 High, 4 Medium, 0 Low
Verdict: GO WITH CHANGES

## Plan summary

Bundle GW-292 (split `node-ci-reusable.yml` into 3 focused reusables — node, shell, secret-scan) + GW-293 (Slack `#bb-alerts` failure-notify) into one effort. 6 callers across org pin `@v1`; user has live P3bp-2 Sub-PR 4 commits 5-6 in beannbean-mcp.

## Unresolved Critical/High findings

**Critical**
1. Atomic-vs-additive: ALL 5 reviewers demand additive migration; beannbean-mcp migrates LAST after P3bp-2 Sub-PR 4 ships to prod.
2. Ship a `dot-github` smoke caller (`smoke-v2.yml`) before any real caller migrates. Gate caller migration on smoke green.
3. Webhook URL regex validation before curl (Slack URL injection sink).
4. Fork-PR guard on notify step (`pull_request_target` would expose webhook to forks).

**High**
5. Drop `secrets: inherit` — explicit `SLACK_ALERTS_WEBHOOK` pass-through per caller. [all 5]
6. Per-reusable tags (`node-ci-v1`, `shell-ci-v1`, `secret-scan-v1`), not shared `@v2`. [DevOps + SwArch]
7. Defer GW-333 docker-build fold-in to a separate follow-up issue. [all 5]
8. Preserve job IDs `build-test` + `secret-scan` to protect required-check names. Update PLATFORM_PLAN.md §7 in the same PR. [DevOps + SwArch + SRE + CodeRev]
9. Slack-notify exit-code hardening: drop `|| true`, use `curl --fail`, redirect stderr, `set +x`, never echo webhook. [SRE + Sec + CodeRev]
10. Sanitize attacker-controlled strings (PR title, fork branch name) before Slack payload. [Sec]

## Convergent risks

- Additive migration (5/5)
- Drop `secrets: inherit` (5/5)
- Defer GW-333 (5/5)
- PLATFORM_PLAN.md §7 in same PR (4/5)
- Per-reusable tags (3/5)
- Fork-PR guard (3/5: Sec, SRE, CodeRev)
- Slack-notify exit-code/cancellation hardening (3+/5)

## Disagreements

1. Keep `notify-failures` input (DevOps, SRE, Sec, CodeRev) vs drop and hardcode (SwArch). Recommendation: KEEP — cheap surface, real opt-out value for future tenant forks.
2. Slack-notify on secret-scan: enabled (Sec) vs default-off (DevOps, CodeRev). Recommendation: DEFAULT-OFF on secret-scan, ON for node + shell; gitleaks failures are author-actionable and would alarm-fatigue.
3. Per-job notify steps (DevOps, SRE, Sec) vs single aggregator (CodeRev). Recommendation: PER-JOB — matches GitHub idiom; no `needs:` gymnastics.

## Open question to resolve before tagging

Matrix-test shape (SwArch Medium): does `node-ci-reusable` v1 accept `inputs.packages: JSON` for the future groundwork-platform monorepo, or leave orchestration to callers? Decide before cutting `node-ci-v1` — changing later is `v2`.
