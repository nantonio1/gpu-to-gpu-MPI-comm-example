#!/bin/bash 
#SBATCH --account=d35-gpu
#SBATCH --partition=gpu-dev
#SBATCH --nodes=1              
#SBATCH --gres=gpu:8           
#SBATCH --time=00:05:00
#SBATCH --exclusive

$mode=$1

# load modules
. ../modules.sh $mode

export MPICH_GPU_SUPPORT_ENABLED=1
export OMP_NUM_THREADS=1

srun -N 1 -n 8 -c $OMP_NUM_THREADS --gres=gpu:8 ../selectGPU_X.sh > output.txt
