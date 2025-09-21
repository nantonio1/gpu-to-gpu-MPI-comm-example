module mpi_mod
    use precision_mod, only: wp
    use mpi_data
    implicit none
    include 'mpif.h'

contains

    subroutine get_static_partition(N,start_idx, end_idx)
        implicit none
        integer, intent(in)  :: N
        integer, intent(out) :: start_idx, end_idx
        !
        integer :: chunk, remainder

        chunk     = N / nprocs          
        remainder = mod(N, nprocs)

        if (rank == nprocs-1) then
            ! last rank gets chunk + remainder elements
            start_idx = rank*chunk + 1
            end_idx   = rank*chunk + chunk + remainder
        else
            ! all earlier ranks get exactly 'chunk' elements
            start_idx = rank*chunk + 1
            end_idx   = (rank+1)*chunk
        end if

    end subroutine get_static_partition

end module mpi_mod
