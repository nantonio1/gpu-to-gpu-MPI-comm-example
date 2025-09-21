program main
    use precision_mod
    use mpi_data
    use mpi_mod, only: get_static_partition
    use openacc
    implicit none
    include 'mpif.h'
    integer, parameter :: N = 7000 !10000
    integer, parameter :: steps = 601
    !
    !
    real(kind=8) :: mats_flat(1:N*(N+1)/2)
    real(kind=8), allocatable :: my_submat(:)
    integer :: my_mat_start,my_mat_end
    integer, allocatable :: counts(:)
    integer, allocatable :: displs(:)
    !
    integer :: i
    real(kind=8) :: time_mat_comm
    real(kind=8) :: mat_t1
    real :: time_sol_comm
    integer :: iz
    integer :: local_count

    !--------------------------------------------------------------------------
    ! set up MPI
    !--------------------------------------------------------------------------
    call MPI_Init(ierr)
    call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, nprocs, ierr)

    !--------------------------------------------------------------------------
    ! parition submatrix indexes
    !--------------------------------------------------------------------------
    call get_static_partition(N*(N+1)/2,my_mat_start,my_mat_end)
    call mpi_barrier(MPI_COMM_WORLD,ierr)

    !--------------------------------------------------------------------------
    ! allocate submatrix and put it in the device memory
    !--------------------------------------------------------------------------
    allocate(my_submat(my_mat_start:my_mat_end))
    !$acc enter data create(my_submat)

    
    !--------------------------------------------------------------------------
    ! set submatrix elements to the number 1 (use GPU is available)
    !--------------------------------------------------------------------------
    !$acc parallel num_gangs(128) vector_length(1024) default(present)
    !$acc loop gang vector private(i)
    do i = my_mat_start,my_mat_end
        my_submat(i) = 1.0d0
    enddo 
    !$acc end parallel

    !--------------------------------------------------------------------------
    ! allocate some arrays needed for MPI comm
    !--------------------------------------------------------------------------
    allocate(counts(1:nprocs))
    allocate(displs(1:nprocs))
    counts(:) = 0
    call MPI_barrier(MPI_COMM_WORLD,ierr)
    
    !--------------------------------------------------------------------------
    ! declare some arrays and variables to the GPU
    !--------------------------------------------------------------------------
    !$acc enter data create(mats_flat)
    !$acc enter data copyin(my_mat_start)
    !$acc enter data copyin(my_mat_end)
    !$acc enter data copyin(counts)
    !$acc enter data create(ierr)
    !$acc enter data create(displs)
    !$acc enter data copyin(nprocs)
    !$acc enter data copyin(rank)
    !$acc enter data create(local_count)

    !--------------------------------------------------------------------------
    ! communicate submatrix to all tasks and populate mats entirely on all ranks
    !--------------------------------------------------------------------------
    do iz=1,steps
        mat_t1 = MPI_Wtime()

        !$acc host_data use_device(local_count,counts,displs,my_submat,mats_flat,ierr,rank)
        local_count = my_mat_end-my_mat_start+1
        call mpi_allgather(local_count,1,MPI_INTEGER,counts,1,MPI_INTEGER,MPI_COMM_WORLD,ierr)
        displs(1) = 0
        do i = 2, nprocs
            displs(i) = displs(i-1) + counts(i-1)
        enddo
        call mpi_allgatherv(my_submat,counts(rank+1),MPI_DOUBLE,mats_flat,counts,displs,MPI_DOUBLE,MPI_COMM_WORLD,ierr)
        !$acc end host_data

        time_mat_comm = time_mat_comm + (MPI_Wtime() - mat_t1)

        call mpi_barrier(mpi_comm_world,ierr)

    enddo

    call MPI_barrier(MPI_COMM_WORLD,ierr)

#ifdef GPU
    if (sum(mats_flat)/dble((N*(N+1)/2)) .ne. 0.0d0) then 
        print *, 'ERROR ON RANK:', rank
        print *, 'ratio is not zero as expected'
        flush(6)
        stop
    endif
#endif

    !$acc exit data copyout(mats_flat)

    if (sum(mats_flat)/dble((N*(N+1)/2)) .ne. 1.0d0) then 
        print *, 'ERROR ON RANK:', rank
        print *, 'ratio is not 1 as expected'
        flush(6)
        stop
    endif

    print *, 'run done successful. no error messages means everything works as expected', time_mat_comm, rank
    flush(6)
 
end program
