#!/usr/bin/zsh

## assert_ok <CMD> [ARGS]...

assert_ok() {
    echo "#" $*
    $*
    rc=$?

    if [[ $rc -ne 0 ]]; then
        echo FAIL. Exit Status: $rc
        echo
        exit $rc
    fi
}
