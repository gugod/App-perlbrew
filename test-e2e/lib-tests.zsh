PERLBREW_E2E=/tmp/e2e
export PERLBREW_ROOT=$PERLBREW_E2E/root
export PERLBREW_HOME=$PERLBREW_E2E/home

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
}

test-perlbrew-install-skaji-relocatable-perl() {
    echo 'TEST - perlbrew install skaji-relocatable-perl'

    local PERLBREW=~/perl5/perlbrew/bin/perlbrew

    assert-file-exists $PERLBREW

    assert-dir-missing ~/perl5/perlbrew/perls/skaji-relocatable-perl-5.40.0.1

    $PERLBREW install skaji-relocatable-perl-5.40.0.1

    assert-dir-exists ~/perl5/perlbrew/perls/skaji-relocatable-perl-5.40.0.1
    assert-file-exists ~/perl5/perlbrew/perls/skaji-relocatable-perl-5.40.0.1/bin/perl

    assert-ok ~/perl5/perlbrew/perls/skaji-relocatable-perl-5.40.0.1/bin/perl -v

    echo 'OK - perlbrew install skaji-relocatable-perl-5.40.0.1'
}

test-perlbrew-install-perl-5-40() {
    echo 'TEST - perlbrew install perl-5.40.0'

    local PERLBREW=~/perl5/perlbrew/bin/perlbrew

    assert-file-exists $PERLBREW
    assert-dir-missing ~/perl5/perlbrew/perls/perl-5.40.0

    $PERLBREW install perl-5.40.0

    assert-dir-exists ~/perl5/perlbrew/perls/perl-5.40.0
    assert-file-exists ~/perl5/perlbrew/perls/perl-5.40.0/bin/perl
    assert-ok ~/perl5/perlbrew/perls/perl-5.40.0/bin/perl -v

    echo 'OK - perlbrew install perl-5.40.0'
}

test-perlbrew-uninstall-perl-5-40() {
    echo 'TEST - perlbrew uninstall perl-5.40.0'

    assert-dir-exists ~/perl5/perlbrew/perls/perl-5.40.0
    assert-file-exists ~/perl5/perlbrew/perls/perl-5.40.0/bin/perl

    $PERLBREW uninstall perl-5.40.0

    assert-dir-missing ~/perl5/perlbrew/perls/perl-5.40.0

    echo 'OK - perlbrew uninstall perl-5.40.0'
}
