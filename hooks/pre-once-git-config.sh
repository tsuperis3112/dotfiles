#!/bin/sh

CONF="git config --global"

$CONF user.name "Takeru Furuse"

$CONF url."git@github.com:".insteadOf 'https://github.com/'
$CONF init.defaultBranch main
$CONF push.autoSetupRemote true
$CONF log.date iso
$CONF branch.sort -committerdate
$CONF tag.sort taggerdate
$CONF diff.algorithm histogram
$CONF rerere.enabled true

