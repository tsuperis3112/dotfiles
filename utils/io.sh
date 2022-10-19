#!/bin/sh

function warn {
    echo -n -e "\e[33;1mWARNING: \e[0;33m" 1>&2
    echo "$@" 1>&2
    echo -n -e "\e[0m" 1>&2
}

function error {
    local status=$?
    if [ "$status" -eq 0 ]; then
        status=1
    fi

    echo -n -e "\e[31;1mWARNING: \e[0;31m" 1>&2
    echo "$@" 1>&2
    echo -n -e "\e[0m" 1>&2

    return $status
}

