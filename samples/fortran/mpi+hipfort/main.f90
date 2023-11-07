program main

use openmpi_gpu_support
use iso_c_binding
use hipfort
use hipfort_check

implicit none

  include 'mpif.h'
  integer :: N=1000
  integer :: rank_id, n_ranks, ierror, tag
  integer :: mpi_status(MPI_STATUS_SIZE)
  logical :: gpu_aware
  real, pointer :: f_cpu(:)
  type(c_ptr)   :: f_gpu
  real, pointer :: f_gpu_for_mpi(:)
  

  call mpi_init(ierror)
  call mpi_comm_size(MPI_COMM_WORLD, n_ranks, ierror)
  call mpi_comm_rank(MPI_COMM_WORLD, rank_id, ierror)

  ! Set rank 0 to device 0; rank 1 to device 1
  call hipcheck(hipSetDevice(rank_id))

  print *, 'Hello World from process: ', rank_id, 'of ', n_ranks

  gpu_aware = MPIX_Query_gpu_support()

  if( gpu_aware )then
    print*, "GPU aware MPI detected!"
  else
    call mpi_finalize(ierror)
    stop 1
  endif


  ! Allocate memory on host and device
  allocate(f_cpu(1:N))

  f_cpu = 0.0
  call hipcheck(hipmalloc(f_gpu,sizeof(f_cpu)))

  ! Get Fortran pointer from c_ptr
  call c_f_pointer(f_gpu, f_gpu_for_mpi, shape(f_cpu))

  if(rank_id == 0)then

    ! Set the values of the data to send to 1.0
    f_cpu = 1.0

    ! Copy data held by CPU pointer to GPU - gpu pointer points to memory with values of 1.0 stored
    call hipcheck(hipmemcpy(f_gpu,c_loc(f_cpu),sizeof(f_cpu),hipMemcpyHostToDevice))

    ! Send data using GPU aware MPI
    call MPI_Send(f_gpu_for_mpi, N, MPI_REAL, 1, 123, MPI_COMM_WORLD, ierror)

  elseif(rank_id == 1)then

    ! Receive data from rank 1 using GPU aware MPI
    call MPI_Recv(f_gpu_for_mpi, N, MPI_REAL, 0, 123, MPI_COMM_WORLD, mpi_status, ierror)

    ! Copy data held by GPU pointer to CPU
    call hipcheck(hipmemcpy(c_loc(f_cpu),f_gpu,sizeof(f_cpu),hipMemcpyDeviceToHost))

    if( maxval(f_cpu) /= 1.0 )then
      print*, "something bad happened!"
    elseif( minval(f_cpu) /= 1.0 )then
      print*, "something bad happened!"
    else
      print*, "rank 1 : data received correctly!"
    endif
      
  endif

  ! deallocate memory
  deallocate(f_cpu)
  call hipcheck(hipfree(f_gpu))
  f_gpu_for_mpi => null()

  call mpi_finalize(ierror)

end program main
