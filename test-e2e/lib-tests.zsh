PERLBREW_E2E=/tmp/e2e
export PERLBREW_ROOT=$PERLBREW_E2E/root
export PERLBREW_HOME=$PERLBREW_E2E/home

PERLBREW=$PERLBREW_ROOT/bin/perlbrew

e2e-begin() {
    mkdir $PERLBREW_E2E
    mkdir $PERLBREW_ROOT
    mkdir $PERLBREW_HOME
    echo 'E2E BEGIN -- preapre $PERLBREW_E2E'
}

e2e-end() {
    rm -rf $PERLBREW_E2E
    echo 'E2E END -- cleanup $PERLBREW_E2E'
}

test-perlbrew-self-install() {
    echo 'TEST - perlbrew self-install'

    assert-file-missing $PERLBREW_ROOT/bin/perlbrew

    assert-ok ./perlbrew self-install

    assert-file-exists $PERLBREW_ROOT/bin/perlbrew

    $PERLBREW_ROOT/bin/perlbrew install-patchperl
    assert-file-exists $PERLBREW_ROOT/bin/patchperl

    eval "$($PERLBREW init-in-bash)"
}

test-perlbrew-install() {
    local installation=$1
    shift

    echo "TEST - perlbrew install $installation"

    assert-file-exists $PERLBREW

    assert-dir-missing $PERLBREW_ROOT/perls/$installation

    if [[ -n "$PERLBREW_E2E_INSTALL_NOTEST" ]]
    then
        $PERLBREW install --verbose --notest $installation
    else
        $PERLBREW install --verbose $installation
    fi

    assert-dir-exists $PERLBREW_ROOT/perls/$installation
    assert-file-exists $PERLBREW_ROOT/perls/$installation/bin/perl

    assert-ok $PERLBREW_ROOT/perls/$installation/bin/perl -v

    echo "OK - perlbrew install $installation"
}

test-perlbrew-uninstall() {
    local installation=$1
    shift

    echo "TEST - perlbrew uninstall $installation"

    assert-dir-exists $PERLBREW_ROOT/perls/$installation
    assert-file-exists $PERLBREW_ROOT/perls/$installation/bin/perl

    $PERLBREW uninstall --verbose --yes $installation

    assert-dir-missing $PERLBREW_ROOT/perls/$installation

    echo "OK - perlbrew uninstall $installation"
}
