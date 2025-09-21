#!/bin/bash

mode=$1

module load PrgEnv-cray

if [[ $mode == "gpu" ]]; then
    module load rocm 
    module load craype-accel-amd-gfx90a
fi
