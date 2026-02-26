#!/usr/bin/env bash
set -euo pipefail

CTR="${1:-opensearch-node-warm-1}"
shift || true

docker-nas exec -it "$CTR" bash -lc \
  "/usr/share/opensearch/config/securityadmin.sh $*"
