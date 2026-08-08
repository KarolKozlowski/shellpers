#!/usr/bin/env bash

# This file is intended to be sourced. Avoid redeclaring readonly variables.
[[ -n ${__AGENT_BRIDGE_SH_LOADED:-} ]] && return 0
readonly __AGENT_BRIDGE_SH_LOADED=1

readonly DEFAULT_SSH_AGENT_SOCKET="${HOME}/.ssh/agent.sock"
readonly SSH_AGENT_SOCKET="${SSH_AGENT_SOCKET:-$DEFAULT_SSH_AGENT_SOCKET}"
readonly SSH_AGENT_PIPE="${SSH_AGENT_PIPE:-//./pipe/openssh-ssh-agent}"
readonly NPIPE_RELAY_BINARY="${NPIPE_RELAY_BINARY:-/mnt/c/ProgramData/chocolatey/lib/npiperelay/tools/npiperelay.exe}"
readonly SSH_AGENT_CHECK_TIMEOUT="${SSH_AGENT_CHECK_TIMEOUT:-2}"
readonly SSH_AGENT_LOCK_FILE="${SSH_AGENT_LOCK_FILE:-${XDG_RUNTIME_DIR:-/tmp}/ssh-agent-bridge.lock}"
readonly VIRTUALIZATION_TYPE="${VIRTUALIZATION_TYPE:-$(systemd-detect-virt 2>/dev/null)}"
readonly SOCAT_LISTEN_OPTIONS="UNIX-LISTEN:${SSH_AGENT_SOCKET},fork"
readonly SOCAT_EXEC_TARGET="${NPIPE_RELAY_BINARY} -ei -s ${SSH_AGENT_PIPE}"

export SSH_AUTH_SOCK="$SSH_AGENT_SOCKET"

has_agent_socket() {
    [[ -S "$SSH_AUTH_SOCK" ]]
}

is_agent_bridge_healthy() {
    local ssh_add_output
    local ssh_add_exit_code

    has_agent_socket || return 1

    ssh_add_output=$(timeout "$SSH_AGENT_CHECK_TIMEOUT" ssh-add -l 2>&1)
    ssh_add_exit_code=$?

    [[ $ssh_add_exit_code -eq 0 ]] && return 0
    [[ "$ssh_add_output" == *"The agent has no identities."* ]]
}

is_wsl_environment() {
    [[ "$VIRTUALIZATION_TYPE" == "wsl" ]]
}

list_agent_bridge_pids() {
    ps -eo pid=,args= | awk \
        -v socket="$SSH_AGENT_SOCKET" \
        -v relay="$NPIPE_RELAY_BINARY" \
        -v pipe="$SSH_AGENT_PIPE" '
            {
                pid = $1
                $1 = ""
                sub(/^ /, "", $0)

                expected = "socat UNIX-LISTEN:" socket ",fork EXEC:" \
                    relay " -ei -s " pipe ",nofork"

                if ($0 == expected) {
                    print pid
                }
            }
        '
}

stop_agent_bridges() {
    local bridge_pid

    while read -r bridge_pid; do
        [[ -n "$bridge_pid" ]] || continue
        kill "$bridge_pid" 2>/dev/null || true
    done < <(list_agent_bridge_pids)
}

start_agent_bridge() {
    stop_agent_bridges
    rm -f "$SSH_AUTH_SOCK"

    (
        setsid socat \
            "$SOCAT_LISTEN_OPTIONS" \
            EXEC:"$SOCAT_EXEC_TARGET",nofork &
    ) >/dev/null 2>&1
}

ensure_agent_bridge() {
    local lock_fd

    mkdir -p "$(dirname "$SSH_AGENT_LOCK_FILE")"

    exec {lock_fd}>"$SSH_AGENT_LOCK_FILE"
    flock -x "$lock_fd"

    if ! is_agent_bridge_healthy && is_wsl_environment; then
        start_agent_bridge
    fi

    flock -u "$lock_fd"
    exec {lock_fd}>&-
}

ensure_agent_bridge
