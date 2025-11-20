#!/bin/bash

ROCKY_RELEASE=9

REPO_URL="https://download.rockylinux.org/pub/rocky/${ROCKY_RELEASE}/BaseOS/x86_64/os/Packages/r"
PKG_LIST="/tmp/rocky-${ROCKY_RELEASE}-pkg.txt"

BACKUPS=()
BACKUPS+=(/usr/share/redhat-logos)

curl -sS -L "${REPO_URL}" | grep href | sed 's/.*href="\(.*\)".*/\1/' > "${PKG_LIST}"

RELEASE_PKG=$(grep rocky-release "${PKG_LIST}" | head -n 1)
REPOS_PKG=$(grep rocky-repos "${PKG_LIST}" | head -n 1)
GPG_KEYS_PKG=$(grep rocky-gpg-keys "${PKG_LIST}" | head -n 1)

dnf install "${REPO_URL}/${RELEASE_PKG}" \
            "${REPO_URL}/${REPOS_PKG} \
            "${REPO_URL}/${GPG_KEYS_PKG}

rm "${PKG_LIST}"

for item in ${BACKUPS[*]}; do
    if [ -e "${item}" ]; then
      mv "${item}" "${item}.bak"
    fi
done

mv /usr/share/redhat-logos /usr/share/redhat-logos.bak

dnf -y --releasever=${ROCKY_RELEASE} --allowerasing --setopt=deltarpm=false distro-sync

rpm --rebuilddb
