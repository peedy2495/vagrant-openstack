#!/bin/bash

exe=$(realpath $0)
exedir=$(dirname $exe)

if [ ! -f assets/base/id_rsa ]; then
    ssh-keygen -t rsa -P "" -f $exedir/base/id_rsa
fi