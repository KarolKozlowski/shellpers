export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
ss -a 2>/dev/null | grep -q $SSH_AUTH_SOCK
if [ $? -ne 0   ]; then
    if [ "$(systemd-detect-virt)" == "wsl" ]; then
        rm -f $SSH_AUTH_SOCK
        ( setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"/mnt/c/ProgramData/chocolatey/lib/npiperelay/tools/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork & ) >/dev/null 2>&1
    fi
fi
