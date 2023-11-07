program main

use openmpi_gpu_support

implicit none

  include 'mpif.h'

  integer :: rank_id, n_ranks, ierror, tag
  logical :: gpu_aware

  call mpi_init(ierror)
  call mpi_comm_size(MPI_COMM_WORLD, n_ranks, ierror)
  call mpi_comm_rank(MPI_COMM_WORLD, rank_id, ierror)
  print *, 'Hello World from process: ', rank_id, 'of ', n_ranks

  gpu_aware = MPIX_Query_gpu_support()

  print*, 'GPU aware support: ',gpu_aware

  call mpi_finalize(ierror)

end program main
