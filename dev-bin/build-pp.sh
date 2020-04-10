#!/bin/bash

# Assumes `cpanm` exists

cd $(dirname $0)/..
mkdir -p .build

cpanm -L .build/pp/ --installdeps .
cpanm -L .build/pp/ PAR::Packer

export PERL5LIB="lib":".build/pp/lib/perl5":$PERL5LIB

.build/pp/bin/pp -M App::perlbrew:: -M App::Perlbrew:: -o .build/pp/perlbrew script/perlbrew || echo "pp FAILED: $?" && exit 1

echo "DONE:" .build/pp/perlbrew
