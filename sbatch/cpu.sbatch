#!/bin/bash 
#SBATCH --account=d35
#SBATCH --partition=debug
#SBATCH --nodes=1              
#SBATCH --time=00:05:00
#SBATCH --cpus-per-task=1

# load modules
. ../modules.sh

export OMP_NUM_THREADS=1

srun -N 1 -n 8 -c $OMP_NUM_THREADS ../mpi_comm.exe > output.txt
