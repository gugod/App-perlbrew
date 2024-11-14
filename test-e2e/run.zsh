#!/usr/bin/zsh

local e2eDir=$(dirname $0)
source $e2eDir/lib.zsh
source $e2eDir/lib-tests.zsh

echo "# uname -a"
uname -a

test-perlbrew-self-install
