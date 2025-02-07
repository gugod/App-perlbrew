#!/usr/bin/zsh

local e2eDir=$(dirname $0)
source $e2eDir/lib.zsh
source $e2eDir/lib-tests.zsh

echo "# uname -a"
uname -a

local testName=$1

if [[ ! -z $testName ]]; then
    $testName
    exit 0
fi

test-perlbrew-self-install
test-perlbrew-install-skaji-relocatable-perl
test-perlbrew-install-perl-5-40
