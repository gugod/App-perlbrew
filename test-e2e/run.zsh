#!/usr/bin/zsh

local e2eDir=$(dirname $0)
source $e2eDir/lib.zsh
source $e2eDir/lib-tests.zsh

echo "# uname -a"
uname -a
local testName=$1

e2e-begin

TRAPEXIT() {
    e2e-end
}

if [[ ! -z $testName ]]; then
    $testName
else
    test-perlbrew-self-install

    test-perlbrew-available

    if [[ ! ( "$OSTYPE" =~ ^cygwin ) ]]; then
        test-perlbrew-install skaji-relocatable-perl-5.40.2.1
        test-perlbrew-uninstall skaji-relocatable-perl-5.40.2.1
    fi

    test-perlbrew-install perl-5.40.2
    test-perlbrew-uninstall perl-5.40.2
fi
