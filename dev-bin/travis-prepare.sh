#!/bin/sh
yes | cpanm --verbose local::lib
cpanm -n Module::Install Module::Install::AuthorRequires Devel::Cover Devel::Cover::Report::Coveralls
cpanm --verbose --notest --installdeps .
