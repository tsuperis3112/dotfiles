#!/bin/sh

function check-command {
    type -P "$@" >/dev/null 2>&1
}

