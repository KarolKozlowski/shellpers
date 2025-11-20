#!/bin/bash

ROCKY_RELEASE=9

REPO_URL="https://download.rockylinux.org/pub/rocky/${ROCKY_RELEASE}/BaseOS/x86_64/os/Packages/r"
PKG_LIST="/tmp/rocky-${ROCKY_RELEASE}-pkg.txt"

curl -sS -L "${REPO_URL}" | grep href | sed 's/.*href="\(.*\)".*/\1/' > "${PKG_LIST}"

RELEASE_PKG=$(grep rocky-release "${PKG_LIST}" | head -n 1)
REPOS_PKG=$(grep rocky-repos "${PKG_LIST}" | head -n 1)
GPG_KEYS_PKG=$(grep rocky-gpg-keys "${PKG_LIST}" | head -n 1)

cat ${PKG_LIST}

dnf install "${REPO_URL}/${RELEASE_PKG}" \
            "${REPO_URL}/${REPOS_PKG} \
            "${REPO_URL}/${GPG_KEYS_PKG}

rm "${PKG_LIST}"

mv /usr/share/redhat-logos /usr/share/redhat-logos.bak

dnf -y --releasever=${ROCKY_RELEASE} --allowerasing --setopt=deltarpm=false distro-sync

rpm --rebuilddb

