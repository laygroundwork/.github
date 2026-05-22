#!/usr/bin/env bash
# Tracked *.sh file so shell-ci-reusable has something to shellcheck
# when invoked by smoke-v2.yml. Body is intentionally trivial — the
# point is to exercise the linter, not to do work.

set -euo pipefail

echo "smoke shell ok"
