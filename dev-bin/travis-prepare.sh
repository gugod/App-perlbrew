#!/bin/sh
yes | cpanm --verbose local::lib
cpanm -n Module::Install Devel::Cover Devel::Cover::Report::Coveralls
