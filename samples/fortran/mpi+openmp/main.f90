program main

use openmpi_gpu_support
use iso_c_binding
use omp_lib

implicit none

  include 'mpif.h'
  integer :: N=1000
  integer :: rank_id, n_ranks, ierror, tag
  integer :: mpi_status(MPI_STATUS_SIZE)
  logical :: gpu_aware
  real, allocatable :: f(:)
  

  call mpi_init(ierror)
  call mpi_comm_size(MPI_COMM_WORLD, n_ranks, ierror)
  call mpi_comm_rank(MPI_COMM_WORLD, rank_id, ierror)

  ! Set rank 0 to device 0; rank 1 to device 1
  call omp_set_default_device(rank_id)

  print *, 'Hello World from process: ', rank_id, 'of ', n_ranks

  gpu_aware = MPIX_Query_gpu_support()

  if( gpu_aware )then
    print*, "GPU aware MPI detected!"
  else
    call mpi_finalize(ierror)
    stop 1
  endif


  ! Allocate memory on host and device
  allocate(f(1:N))
  !$omp target enter data map(alloc:f)

  f = 0.0

  if(rank_id == 0)then

    ! Set the values of the data to send to 1.0
    f = 1.0
    !$omp target update to(f)

    ! Send data using GPU aware MPI
    !$omp target data use_device_ptr(f)
    call MPI_Send(f, N, MPI_REAL, 1, 123, MPI_COMM_WORLD, ierror)
    !$omp end target data

  elseif(rank_id == 1)then

    !$omp target data use_device_ptr(f)
    ! Receive data from rank 1 using GPU aware MPI
    call MPI_Recv(f, N, MPI_REAL, 0, 123, MPI_COMM_WORLD, mpi_status, ierror)
    !$omp end target data

    ! Copy data held by GPU pointer to CPU
    !$omp target update from(f)

    if( maxval(f) /= 1.0 )then
      print*, "something bad happened!"
    elseif( minval(f) /= 1.0 )then
      print*, "something bad happened!"
    else
      print*, "rank 1 : data received correctly!"
    endif
      
  endif

  ! deallocate memory
  !$omp target exit data map(delete:f)
  deallocate(f)

  call mpi_finalize(ierror)

end program main
