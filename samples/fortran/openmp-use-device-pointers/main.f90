PROGRAM main

USE ISO_C_BINDING
USE ISO_FORTRAN_ENV
USE omp_lib

IMPLICIT NONE

  INTEGER, PARAMETER :: prec = real32
  INTEGER, PARAMETER :: N = 50

  REAL(prec), POINTER :: x(:)
  REAL(prec), POINTER :: y(:)
  TYPE(c_ptr) :: y_gpu

  INTEGER :: i, err
  INTEGER(c_size_t) :: nb = prec*N
  REAL(prec) :: a = 2.0_prec

  ! Allocate on the host
  ALLOCATE(x(1:N))
  ALLOCATE(y(1:N))
  !$omp target enter data map(alloc: x, y)
 
  ! Initialize x and y
  x(1:N) = 1.0_prec
  y(1:N) = 0.0_prec

  !$omp target update to(x,y)

  ! Copy data from host to device
  !$omp target map(to:x) map(y)
  !$omp teams distribute parallel do num_threads(256)
  DO i = 1, N
    y(i) = a*x(i) + y(i)
  ENDDO
  !$omp end target

  !$omp target update from(y)

  !$omp target data use_device_ptr(y)

  ! At this stage, you can use the device pointer "y_gpu" in a HIP kernel
  ! or a GPU accelerated library that requires C-pointers as input/output.

  !$omp end target data

  PRINT*, "Error : ",MAXVAL(ABS(y-2.0_prec))

  !$omp target exit data map(delete: x,y)
  DEALLOCATE(x,y)
  

END PROGRAM main

