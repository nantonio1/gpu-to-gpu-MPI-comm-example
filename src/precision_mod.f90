module precision_mod
  implicit none

  integer, parameter :: sp = selected_real_kind(6, 37)
  integer, parameter :: dp = selected_real_kind(15, 307)
  integer, parameter :: qp = selected_real_kind(33, 4931)

  ! define a working precision parameter.
  integer, parameter :: wp = dp

end module precision_mod
