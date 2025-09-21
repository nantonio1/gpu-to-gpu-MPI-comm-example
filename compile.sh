#!/bin/bash

# Ensure exactly one argument is given
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <mode>"
    echo "Where <mode> is either 'cpu' or 'gpu'"
    exit 1
fi
mode=$1

# load necessaary modules
module load PrgEnv-cray

if [[ $mode == "gpu" ]]; then
    # load modules specific to GPU nodes
    module load rocm 
    module load craype-accel-amd-gfx90a
    ftn -g -O3 -h acc -J. -I. -e Z -DGPU src/precision_mod.f90 src/mpi_data.f90 src/mpi_routines.f90 src/main.f90 -o mpi_comm.exe
else
    ftn -g -O3 -h noacc -J. -I. -e Z src/precision_mod.f90 src/mpi_data.f90 src/mpi_routines.f90 src/main.f90 -o mpi_comm.exe
fi

rm -rf *.mod *.i
