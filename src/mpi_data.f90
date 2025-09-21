module mpi_data
    use precision_mod, only: wp
    implicit none
    integer :: nprocs
    integer :: rank
    integer :: ierr
    character(len=3) :: rank_char
end module mpi_data
