#!/usr/bin/zsh

local e2eDir=$(dirname $0)
source $e2eDir/lib.zsh

echo "# uname -a"
uname -a

test-perlbrew-self-install() {
    echo '# Test: perlbrew self-install'

    assert-file-missing ~/perl5/perlbrew/bin/perlbrew

    assert-ok ./perlbrew self-install

    assert-file-exists ~/perl5/perlbrew/bin/perlbrew
}

test-perlbrew-self-install
