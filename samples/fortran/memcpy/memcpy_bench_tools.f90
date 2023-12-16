module memcpy_bench_tools

use iso_fortran_env
use iso_c_binding
use hipfort
use hipfort_check

implicit none

  interface to_char
    module procedure :: real64_to_char
    module procedure :: int_to_char
  end interface to_char

contains

function real64_to_char( val ) result( val_as_char )
  implicit none 
  real(real64) :: val
  character(24) :: val_as_char

  write (val_as_char, "(E10.4)") val

end function real64_to_char

function int_to_char( val ) result( val_as_char )
  implicit none 
  integer :: val
  character(24) :: val_as_char

  write (val_as_char, "(I10)") val

end function int_to_char

subroutine float32_pageable_memcpy_h2d( array_length, nreps, walltime, bandwidth_gb_s )
!! This subroutine does the following actions
!!  * allocates pageable memory on the host using a real32 fortran pointer of size array_length
!!  * allocates a device pointer using a type(c_ptr) of the same size
!!  * performs "nreps" host-to-device memory copies and measures wall time
!!  * calculates per memcpy wall time and bandwidth in units of gb/s
!!
  implicit none
  integer, intent(in) :: array_length
  integer, intent(in) :: nreps 
  real(real64), intent(out) :: walltime
  real(real64), intent(out) :: bandwidth_gb_s
  ! Local
  real(real32), pointer :: host_data(:)
  type(c_ptr) :: dev_data
  integer :: i
  real(real64) :: t1
  real(real64) :: t2

  allocate(host_data(1:array_length))

  call hipcheck(hipmalloc(dev_data,sizeof(host_data)))

  call cpu_time(t1)
  do i = 1, nreps
  
    call hipcheck(hipmemcpy(dev_data, &
                            c_loc(host_data), &
                            sizeof(host_data), &
                            hipMemcpyHostToDevice))
  enddo
  call cpu_time(t2)

  walltime = (t2-t1)/real(nreps,real64)
  bandwidth_gb_s = real(sizeof(host_data),real64)/walltime/1.0E9

  call hipcheck(hipfree(dev_data))
  deallocate(host_data)

end subroutine float32_pageable_memcpy_h2d

subroutine float32_pageable_memcpy_d2h( array_length, nreps, walltime, bandwidth_gb_s )
!! This subroutine does the following actions
!!  * allocates pageable memory on the host using a real32 fortran pointer of size array_length
!!  * allocates a device pointer using a type(c_ptr) of the same size
!!  * performs "nreps" device-to-host memory copies and measures wall time
!!  * calculates per memcpy wall time and bandwidth in units of gb/s
!!
  implicit none
  integer, intent(in) :: array_length
  integer, intent(in) :: nreps 
  real(real64), intent(out) :: walltime
  real(real64), intent(out) :: bandwidth_gb_s
  ! Local
  real(real32), pointer :: host_data(:)
  type(c_ptr) :: dev_data
  integer :: i
  real(real64) :: t1
  real(real64) :: t2

  allocate(host_data(1:array_length))

  call hipcheck(hipmalloc(dev_data,sizeof(host_data)))

  call cpu_time(t1)
  do i = 1, nreps
  
    call hipcheck(hipmemcpy(c_loc(host_data), &
                            dev_data, &
                            sizeof(host_data), &
                            hipMemcpyDeviceToHost))
  enddo
  call cpu_time(t2)

  walltime = (t2-t1)/real(nreps,real64)
  bandwidth_gb_s = real(sizeof(host_data),real64)/walltime/1.0E9

  call hipcheck(hipfree(dev_data))
  deallocate(host_data)

end subroutine float32_pageable_memcpy_d2h

subroutine float32_pinned_memcpy_h2d( array_length, nreps, walltime, bandwidth_gb_s )
!! This subroutine does the following actions
!!  * allocates pinned memory on the host using a real32 fortran pointer of size array_length
!!  * allocates a device pointer using a type(c_ptr) of the same size
!!  * performs "nreps" host-to-device memory copies and measures wall time
!!  * calculates per memcpy wall time and bandwidth in units of gb/s
!!
  implicit none
  integer, intent(in) :: array_length
  integer, intent(in) :: nreps 
  real(real64), intent(out) :: walltime
  real(real64), intent(out) :: bandwidth_gb_s
  ! Local
  type(c_ptr) :: host_data
  type(c_ptr) :: dev_data
  integer :: i
  integer(c_size_t) :: array_size
  real(real64) :: t1
  real(real64) :: t2

  array_size = array_length*real32

  call hipcheck(hipmallochost(host_data,array_size))

  call hipcheck(hipmalloc(dev_data,array_size))

  call cpu_time(t1)
  do i = 1, nreps
  
    call hipcheck(hipmemcpy(dev_data, &
                            host_data, &
                            array_size, &
                            hipMemcpyHostToDevice))
  enddo
  call cpu_time(t2)

  walltime = (t2-t1)/real(nreps,real64)
  bandwidth_gb_s = real(array_size,real64)/walltime/1.0E9

  call hipcheck(hipfree(dev_data))
  call hipcheck(hipfreehost(host_data))

end subroutine float32_pinned_memcpy_h2d

subroutine float32_pinned_memcpy_d2h( array_length, nreps, walltime, bandwidth_gb_s )
!! This subroutine does the following actions
!!  * allocates pinned memory on the host using a real32 fortran pointer of size array_length
!!  * allocates a device pointer using a type(c_ptr) of the same size
!!  * performs "nreps" device-to-host memory copies and measures wall time
!!  * calculates per memcpy wall time and bandwidth in units of gb/s
!!
  implicit none
  integer, intent(in) :: array_length
  integer, intent(in) :: nreps 
  real(real64), intent(out) :: walltime
  real(real64), intent(out) :: bandwidth_gb_s
  ! Local
  type(c_ptr) :: host_data
  type(c_ptr) :: dev_data
  integer :: i
  integer(c_size_t) :: array_size
  real(real64) :: t1
  real(real64) :: t2

  array_size = array_length*real32
  call hipcheck(hipmallochost(host_data,array_size))

  call hipcheck(hipmalloc(dev_data,array_size))

  call cpu_time(t1)
  do i = 1, nreps
  
    call hipcheck(hipmemcpy(host_data, &
                            dev_data, &
                            array_size, &
                            hipMemcpyDeviceToHost))
  enddo
  call cpu_time(t2)

  walltime = (t2-t1)/real(nreps,real64)
  bandwidth_gb_s = real(array_size,real64)/walltime/1.0E9

  call hipcheck(hipfree(dev_data))
  call hipcheck(hipfreehost(host_data))

end subroutine float32_pinned_memcpy_d2h

subroutine float64_pageable_memcpy_h2d( array_length, nreps, walltime, bandwidth_gb_s )
!! This subroutine does the following actions
!!  * allocates pageable memory on the host using a real64 fortran pointer of size array_length
!!  * allocates a device pointer using a type(c_ptr) of the same size
!!  * performs "nreps" host-to-device memory copies and measures wall time
!!  * calculates per memcpy wall time and bandwidth in units of gb/s
!!
  implicit none
  integer, intent(in) :: array_length
  integer, intent(in) :: nreps 
  real(real64), intent(out) :: walltime
  real(real64), intent(out) :: bandwidth_gb_s
  ! Local
  real(real64), pointer :: host_data(:)
  type(c_ptr) :: dev_data
  integer :: i
  real(real64) :: t1
  real(real64) :: t2

  allocate(host_data(1:array_length))

  call hipcheck(hipmalloc(dev_data,sizeof(host_data)))

  call cpu_time(t1)
  do i = 1, nreps
  
    call hipcheck(hipmemcpy(dev_data, &
                            c_loc(host_data), &
                            sizeof(host_data), &
                            hipMemcpyHostToDevice))
  enddo
  call cpu_time(t2)

  walltime = (t2-t1)/real(nreps,real64)
  bandwidth_gb_s = real(sizeof(host_data),real64)/walltime/1.0E9

  call hipcheck(hipfree(dev_data))
  deallocate(host_data)

end subroutine float64_pageable_memcpy_h2d

subroutine float64_pageable_memcpy_d2h( array_length, nreps, walltime, bandwidth_gb_s )
!! This subroutine does the following actions
!!  * allocates pageable memory on the host using a real64 fortran pointer of size array_length
!!  * allocates a device pointer using a type(c_ptr) of the same size
!!  * performs "nreps" device-to-host memory copies and measures wall time
!!  * calculates per memcpy wall time and bandwidth in units of gb/s
!!
  implicit none
  integer, intent(in) :: array_length
  integer, intent(in) :: nreps 
  real(real64), intent(out) :: walltime
  real(real64), intent(out) :: bandwidth_gb_s
  ! Local
  real(real64), pointer :: host_data(:)
  type(c_ptr) :: dev_data
  integer :: i
  real(real64) :: t1
  real(real64) :: t2

  allocate(host_data(1:array_length))

  call hipcheck(hipmalloc(dev_data,sizeof(host_data)))

  call cpu_time(t1)
  do i = 1, nreps
  
    call hipcheck(hipmemcpy(c_loc(host_data), &
                            dev_data, &
                            sizeof(host_data), &
                            hipMemcpyDeviceToHost))
  enddo
  call cpu_time(t2)

  walltime = (t2-t1)/real(nreps,real64)
  bandwidth_gb_s = real(sizeof(host_data),real64)/walltime/1.0E9

  call hipcheck(hipfree(dev_data))
  deallocate(host_data)

end subroutine float64_pageable_memcpy_d2h

subroutine float64_pinned_memcpy_h2d( array_length, nreps, walltime, bandwidth_gb_s )
!! This subroutine does the following actions
!!  * allocates pinned memory on the host using a real64 fortran pointer of size array_length
!!  * allocates a device pointer using a type(c_ptr) of the same size
!!  * performs "nreps" host-to-device memory copies and measures wall time
!!  * calculates per memcpy wall time and bandwidth in units of gb/s
!!
  implicit none
  integer, intent(in) :: array_length
  integer, intent(in) :: nreps 
  real(real64), intent(out) :: walltime
  real(real64), intent(out) :: bandwidth_gb_s
  ! Local
  type(c_ptr) :: host_data
  type(c_ptr) :: dev_data
  integer :: i
  integer(c_size_t) :: array_size
  real(real64) :: t1
  real(real64) :: t2

  array_size = array_length*real64

  call hipcheck(hipmallochost(host_data,array_size))

  call hipcheck(hipmalloc(dev_data,array_size))

  call cpu_time(t1)
  do i = 1, nreps
  
    call hipcheck(hipmemcpy(dev_data, &
                            host_data, &
                            array_size, &
                            hipMemcpyHostToDevice))
  enddo
  call cpu_time(t2)

  walltime = (t2-t1)/real(nreps,real64)
  bandwidth_gb_s = real(array_size,real64)/walltime/1.0E9

  call hipcheck(hipfree(dev_data))
  call hipcheck(hipfreehost(host_data))

end subroutine float64_pinned_memcpy_h2d

subroutine float64_pinned_memcpy_d2h( array_length, nreps, walltime, bandwidth_gb_s )
!! This subroutine does the following actions
!!  * allocates pinned memory on the host using a real64 fortran pointer of size array_length
!!  * allocates a device pointer using a type(c_ptr) of the same size
!!  * performs "nreps" device-to-host memory copies and measures wall time
!!  * calculates per memcpy wall time and bandwidth in units of gb/s
!!
  implicit none
  integer, intent(in) :: array_length
  integer, intent(in) :: nreps 
  real(real64), intent(out) :: walltime
  real(real64), intent(out) :: bandwidth_gb_s
  ! Local
  type(c_ptr) :: host_data
  type(c_ptr) :: dev_data
  integer :: i
  integer(c_size_t) :: array_size
  real(real64) :: t1
  real(real64) :: t2

  array_size = array_length*real64
  call hipcheck(hipmallochost(host_data,array_size))

  call hipcheck(hipmalloc(dev_data,array_size))

  call cpu_time(t1)
  do i = 1, nreps
  
    call hipcheck(hipmemcpy(host_data, &
                            dev_data, &
                            array_size, &
                            hipMemcpyDeviceToHost))
  enddo
  call cpu_time(t2)

  walltime = (t2-t1)/real(nreps,real64)
  bandwidth_gb_s = real(array_size,real64)/walltime/1.0E9

  call hipcheck(hipfree(dev_data))
  call hipcheck(hipfreehost(host_data))

end subroutine float64_pinned_memcpy_d2h

end module memcpy_bench_tools
