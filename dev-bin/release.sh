#!/bin/bash

# Make sure we are at the right directory.
cd $(dirname $0)/..

CURRENT_VERSION=$(egrep 'our \$VERSION = "[\.0-9]+";' lib/App/perlbrew.pm  | egrep -o '[0-9]+' | tail -1)
RELEASE_VERSION=0.$((CURRENT_VERSION+1))
RELEASE_TIMESTAMP=$(date +'%FT%T%z')
RELEASE_THANKS=$(git shortlog -s "$(git tag --list release-'*' | tail -1)"..HEAD | grep -v "$(git config user.name)" | perl -nE 'push@a,(split /[\t\n]/)[1]}{say join(", ",@a)')

echo '# $VERSION++'
(
    cat lib/App/perlbrew.pm | sed 's/our $VERSION = "0.'${CURRENT_VERSION}'";/our $VERSION = "'${RELEASE_VERSION}'";/'
) > lib/App/perlbrew.pm.new
mv  lib/App/perlbrew.pm.new  lib/App/perlbrew.pm

echo '# update Changes' 
(
    echo ${RELEASE_VERSION}
    echo '	- Released at' ${RELEASE_TIMESTAMP}
    echo '	- Thanks to our contributors:' ${RELEASE_THANKS}
    echo
    cat Changes
) > Changes.new
mv Changes.new Changes

echo '# rebuild'
./dev-bin/build.sh

echo '# ' Now, check them:
echo '> git status '
git status
