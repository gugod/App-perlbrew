#!/bin/bash

cd $(dirname $0)/../

cpm install PAR::Packer
cpm install .

pp -I lib -I local/lib/perl5 -o build/perlbrew script/perlbrew
