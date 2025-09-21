#!/bin/bash
#
export ROCR_VISIBLE_DEVICES=$SLURM_LOCALID
echo $SLURM_LOCALID
../mpi_comm.exe
