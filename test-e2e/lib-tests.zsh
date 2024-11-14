
test-perlbrew-self-install() {
    echo '# Test: perlbrew self-install'

    assert-file-missing ~/perl5/perlbrew/bin/perlbrew

    assert-ok ./perlbrew self-install

    assert-file-exists ~/perl5/perlbrew/bin/perlbrew
}
