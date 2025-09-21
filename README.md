# gpu-to-gpu-comm-example

This is small example of using the GPU aware MPI communication capability on the
GPU nodes apart of the Setonix cluster. It statically partitions some 1D double
precision matrix across MPI tasks and then performs an MPI allgatherv to
construct the entire 1D matrix on all MPI tasks. To check for correctness when
running on GPUs the program will first make sure the entire 1D array is empty
before executing an OpenACC directive to extract the matrix of the device
memeory. It will then make sure that the sum of all the elements of the array on
the host memory is then equal to the total number of elements, which is the
correct result.

# How to compile 
As this is a basic example I just put together a bash script to handle the
compiling. Therefore to compile the code simply run
```
./compile.sh mode
```
where ```mode``` can either be ```cpu``` or ```gpu``` depending on the hardware
you wish to run this toy code on.

# How to run
Code can be run interactively or by submitting the job to the slurm scheduler.
How to do each is outlined below.

## Interactively

Change into the ```interactive``` directory. Then run the following
command

```
salloc -p gpu-dev -A <account> -N 1 --gres=gpu:8 --gpus-per-node=8
```
wherre <account> is your Pawsey allocation account ID. Lastly execute the
following script
```
./run-interactive.sh <mode>
```
where ```mode``` can either be ```cpu``` or ```gpu``` depending on the hardware
you wish to run this toy code on.

## Slurm Scheduler

Change into the ```sbatch``` directory. Then enter the following command
```
sbatch job.sbatch
```

