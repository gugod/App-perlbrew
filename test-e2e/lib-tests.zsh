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

    if [[ -n "$CI" ]]; then
        echo "# CI"
        (
            env | grep -E 'RUNNER_(OS|ARCH)'
        ) | while read line; do echo "# $line"; done
    fi
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

test-perlbrew-available() {
    assert-file-exists $PERLBREW
    assert-ok $PERLBREW available
    assert-ok "$PERLBREW available | grep 'perl-5.42'"
}

test-perlbrew-install-cpm() {
    assert-file-missing $PERLBREW_ROOT/bin/cpm

    echo '# Default is "yes, but do not override."'
    echo | $PERLBREW install-cpm
    assert-file-exists $PERLBREW_ROOT/bin/cpm

    echo '# No, do not override'
    echo "dummy" > $PERLBREW_ROOT/bin/cpm
    echo n | $PERLBREW install-cpm
    assert-file-exists $PERLBREW_ROOT/bin/cpm

    if [[ `head -c 5 $PERLBREW_ROOT/bin/cpm` == "dummy" ]]; then
        echo "OK - not overrided"
    else
        echo "FAIL - overrided"
    fi

    echo '# Yes, do override'
    echo "dummy" > $PERLBREW_ROOT/bin/cpm
    echo y | $PERLBREW install-cpm
    assert-file-exists $PERLBREW_ROOT/bin/cpm
    if [[ `head -c 5 $PERLBREW_ROOT/bin/cpm` == "dummy" ]]; then
        echo "FAIL - not overrided"
    else
        echo "OK - overrided"
    fi
}

test-perlbrew-use() {
    local installation=$1
    shift

    echo "TEST - perlbrew use $installation"

    if (perlbrew list | grep $installation >/dev/null); then
        echo "OK - installation exist: $installation"
    else
        echo "FAIL - installation exist: $installation"
    fi

    # This line (`perlbrew use ...`) is the target of our test and
    # cannot be put into a subshell.  Because it should effect env var
    # in current shell, putting it in a subshell makes it useless.
    perlbrew use $installation | while read line; do echo "# $line"; done

    perlbrew use | read line

    if [[ "$line" == "Currently using $installation" ]]; then
        echo "OK - installation is being used"
    else
        echo "FAIL - installation is being used"
    fi

    (
        echo "# Verifying the effect of perlbrew use $installation"
        type perlbrew
        perlbrew info

        echo "# List of installations we have"
        perlbrew list

        echo "# inspecting info of current perl"
        which perl
        perl -V:osname -V:archname -V:myarchname

    ) | while read line; do echo "# $line"; done

    # Similarly, `perlbrew off` is meant to effect current shell, not
    # subshells, and thus cannot be put into a subshell.
    echo "# # Turning perlbrew off"
    echo -n "# ";
    perlbrew off
}
