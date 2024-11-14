#!/usr/bin/zsh

local e2eDir=$(dirname $0)

source $e2eDir/lib.zsh

assert_ok ./perlbrew self-install
