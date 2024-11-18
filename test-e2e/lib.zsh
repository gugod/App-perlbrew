
## assert_ok <CMD> [ARGS]...
assert-ok() {
    local what="$*"

    echo "RUN $what"
    echo "--------8<--------"
    $*
    rc=$?
    echo "-------->8--------"

    if [[ $rc -ne 0 ]]; then
        echo "FAIL - exit_status: $rc, command: $what"
        echo
        exit $rc
    else
        echo "OK - $what"
    fi
}

assert-file-exists() {
    local path=$1

    if [[ -f $path ]]; then
        echo "OK - file exists $path"
    else
        echo "FAIL - file do not exist: $path"
        exit 1
    fi
}

assert-file-missing() {
    local path=$1

    if [[ ! -f $path ]]; then
        echo "OK - file missing $path"
    else
        echo "FAIL - file do exist: $path"
        exit 1
    fi
}

assert-dir-exists() {
    local path=$1

    if [[ -d $path ]]; then
        echo "OK - dir exists $path"
    else
        echo "FAIL - dir do not exist: $path"
        exit 1
    fi
}

assert-dir-missing() {
    local path=$1

    if [[ ! -d $path ]]; then
        echo "OK - dir missing $path"
    else
        echo "FAIL - dir do exist: $path"
        exit 1
    fi
}
