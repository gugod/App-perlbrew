#!/bin/sh
yes | cpanm --verbose local::lib

if perl -e 'exit( ($] < 5.010) ? 0 : 1)'
then
    cpanm -n PJCJ/Devel-Cover-1.23.tar.gz
else
    cpanm -n Devel::Cover
fi

cpanm -n Pod::Markdown Module::Install Module::Install::AuthorRequires Devel::Cover::Report::Coveralls
cpanm --verbose --notest --installdeps .
