#!/bin/sh
yes | cpanm --verbose local::lib

if perl -e 'exit( ($] < 5.010) ? 0 : 1)'
then
    cpanm -n PJCJ/Devel-Cover-1.23.tar.gz
else
    cpanm -n Devel::Cover
fi

cpanm -n App::ModuleBuildTiny Devel::Cover::Report::Coveralls
hash -r
mbtiny listdeps | cpanm --verbose --notest
