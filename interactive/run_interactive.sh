#!/bin/bash

# Ensure exactly one argument is given
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <mode>"
    echo "Where <mode> is either 'cpu' or 'gpu'"
    exit 1
fi
mode=$1

# load modules
. ../modules.sh $mode

if [[ $mode == "gpu" ]]; then
    srun -N 1 -n 8 -c 8 --gres=gpu:8 ../selectGPU_X.sh
else
    srun -N 1 -n 8 -c 16 ../mpi_comm.exe
fi

