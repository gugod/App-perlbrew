#!/usr/bin/zsh

# Make sure we are at the right directory.
cd $(dirname $0)/..

git clean -xdf

CURRENT_VERSION=$(grep -E 'our \$VERSION = "[\.0-9]+";' lib/App/perlbrew.pm  | grep -Eo '[\.0-9]+' | tail -1)
RELEASE_VERSION=$((CURRENT_VERSION + 0.01))

RELEASE_TIMESTAMP=$(date +'%FT%T%z')
RELEASE_THANKS=$(git shortlog -s "$(git tag --list release-'*' | tail -1)"..HEAD | grep -v "$(git config user.name)" | perl -nE 'push@a,(split /[\t\n]/)[1]}{say join(", ",@a)')

echo '#' $CURRENT_VERSION '->' $RELEASE_VERSION

(
    cat lib/App/perlbrew.pm | sed 's/our $VERSION = "'${CURRENT_VERSION}'";/our $VERSION = "'${RELEASE_VERSION}'";/'
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

echo '# mbtiny regenerate'
mbtiny regenerate

echo '# ' Now, check them:
echo '> git status '
git status
