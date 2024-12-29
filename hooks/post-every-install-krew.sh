#!/bin/bash

if ! which kubectl >/dev/null; then
    exit 0
fi

if [ ! -d "${KREW_ROOT:-$HOME/.krew}" ]; then
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
fi

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

KREW_LIST=$(kubectl krew list)

# install plugins
daily-run kubectl krew update

for PLUGIN in `cat $(dirname $0)/krew-plugin.txt`; do
    if ! echo $KREW_LIST | grep $PLUGIN 1>/dev/null; then
        kubectl krew install ${PLUGIN}
    fi
done

daily-run kubectl krew upgrade
