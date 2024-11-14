
test-perlbrew-self-install() {
    echo 'TEST: perlbrew self-install'

    assert-file-missing ~/perl5/perlbrew/bin/perlbrew

    assert-ok ./perlbrew self-install

    assert-file-exists ~/perl5/perlbrew/bin/perlbrew
}

test-perlbrew-install-skaji-relocatable-perl() {
    echo 'TEST: perlbrew install skaji-relocatable-perl'

    local PERLBREW=~/perl5/perlbrew/bin/perlbrew

    assert-file-exists $PERLBREW

    assert-dir-missing ~/perl5/perlbrew/perls/skaji-relocatable-perl-5.40.0.1

    $PERLBREW install skaji-relocatable-perl-5.40.0.1

    assert-dir-exists ~/perl5/perlbrew/perls/skaji-relocatable-perl-5.40.0.1
    assert-file-exists ~/perl5/perlbrew/perls/skaji-relocatable-perl-5.40.0.1/bin/perl

    assert-ok ~/perl5/perlbrew/perls/skaji-relocatable-perl-5.40.0.1/bin/perl -v

    echo 'OK: perlbrew install skaji-relocatable-perl-5.40.0.1'
}
