#!/usr/bin/env bash

# --- Configuration ---
# Replace with your Home Assistant SSH user and hostname/IP
HA_SSH_TARGET="root@home-assistant.np.dotnot.pl"
# Replace with the path to the HA CLI if your setup uses a different path
HA_CLI_PATH="ha"
# ---------------------

# -t forces pseudo-terminal allocation (required for interactive CLI outputs)
# -q suppresses SSH greeting banners
exec ssh -t -q "$HA_SSH_TARGET" "$HA_CLI_PATH" "$@"
