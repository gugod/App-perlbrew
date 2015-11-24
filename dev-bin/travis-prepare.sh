#!/bin/sh
yes | cpanm --verbose local::lib
cpanm -n Pod::Markdown Module::Install Module::Install::AuthorRequires Devel::Cover Devel::Cover::Report::Coveralls
cpanm --verbose --notest --installdeps .
