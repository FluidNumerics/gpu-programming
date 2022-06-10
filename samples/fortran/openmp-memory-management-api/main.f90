PROGRAM main

USE ISO_C_BINDING
USE ISO_FORTRAN_ENV
USE omp_lib

IMPLICIT NONE

  INTERFACE
    TYPE(c_ptr) FUNCTION omp_get_mapped_ptr(ptr,device_num) bind(c)
      USE, INTRINSIC :: ISO_C_BINDING, ONLY : c_ptr, c_int
      TYPE(c_ptr), VALUE :: ptr
      INTEGER(c_int), VALUE :: device_num
    END FUNCTION omp_get_mapped_ptr
  END INTERFACE

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

  ! Obtain the device pointer
  y_gpu = omp_get_mapped_ptr(C_LOC(x), omp_get_default_device())


  ! At this stage, you can use the device pointer "y_gpu" in a HIP kernel
  ! or a GPU accelerated library that requires C-pointers as input/output.

  PRINT*, "Error : ",MAXVAL(ABS(y-2.0_prec))

  !$omp target exit data map(delete: x,y)
  DEALLOCATE(x,y)
  

END PROGRAM main

