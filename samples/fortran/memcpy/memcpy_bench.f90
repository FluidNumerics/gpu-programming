program memcpy_bench

use iso_fortran_env
use memcpy_bench_tools
use hipfort_auxiliary
use hipfort_types
use hipfort_check

implicit none

  ! ============================================================================================ !
  ! Parameters
  integer, parameter :: float32_array_low = 50          ! Minimum array size (float32) ~> 200 B
  integer, parameter :: float32_array_high = 500000   ! Maximum array size (float32) ~> 2 MB
  integer, parameter :: float64_array_low = 25          ! Minimum array size (float64) ~> 200 B
  integer, parameter :: float64_array_high = 250000   ! Maximum array size (float64) ~> 2 MB
  integer, parameter :: n_experiments = 50              ! Number of points between low and high
                                                         ! to measure
  integer, parameter :: n_repetitions = 100              ! Number of times to perform memcpy                                                         
  integer, parameter :: deviceId = 0                     ! device ID
  ! ============================================================================================ !
  integer :: i
  integer :: array_length
  integer :: stat
  real(real64) :: walltime
  real(real64) :: bandwidth
  character(24) :: array_length_char
  character(24) :: size_bytes_char
  character(24) :: wall_time_char
  character(24) :: bandwidth_char
  character(24) :: hostname
  character(6) :: gpuarch
  type(hipDeviceProp_t) :: prop

  call hipcheck(hipGetDeviceProperties_(prop,deviceId))
  do i = 1, 6
    gpuarch(i:i) = prop % gcnArchName(i)
  enddo

  stat = hostnm(hostname)
  
  print*, '"Data Type","Array Length","Host Memory Type",'//&
          '"Size (Bytes)","Direction","GPU Model",'//&
          '"Hostname","Wall Time (s)","Bandwidth (GB/s)"'

  do i = 0, n_experiments

    array_length = float32_array_low + &
            ceiling( real((float32_array_high - float32_array_low))/&
                     real(n_experiments) )*i

    ! float32 pageable h2d
    call float32_pageable_memcpy_h2d( array_length, &
                                      n_repetitions, &
                                      walltime, &
                                      bandwidth ) 

    print*, 'real32,'//&
            trim(adjustl(to_char(array_length)))//','//&
            'pageable,'//&
            trim(adjustl(to_char(array_length*4)))//','//&
            'h2d,'//&
            trim(adjustl(gpuarch))//','//&
            trim(adjustl(hostname))//','//&
            trim(adjustl(to_char(walltime)))//','//&
            trim(adjustl(to_char(bandwidth)))

    ! float32 pageable d2h
    call float32_pageable_memcpy_d2h( array_length, &
                                      n_repetitions, &
                                      walltime, &
                                      bandwidth ) 

    print*, 'real32,'//&
            trim(adjustl(to_char(array_length)))//','//&
            'pageable,'//&
            trim(adjustl(to_char(array_length*4)))//','//&
            'd2h,'//&
            trim(adjustl(gpuarch))//','//&
            trim(adjustl(hostname))//','//&
            trim(adjustl(to_char(walltime)))//','//&
            trim(adjustl(to_char(bandwidth)))
    

    ! float32 pinned h2d
    call float32_pinned_memcpy_h2d( array_length, &
                                      n_repetitions, &
                                      walltime, &
                                      bandwidth ) 

    print*, 'real32,'//&
            trim(adjustl(to_char(array_length)))//','//&
            'pinned,'//&
            trim(adjustl(to_char(array_length*4)))//','//&
            'h2d,'//&
            trim(adjustl(gpuarch))//','//&
            trim(adjustl(hostname))//','//&
            trim(adjustl(to_char(walltime)))//','//&
            trim(adjustl(to_char(bandwidth)))

    ! float32 pinned d2h
    call float32_pinned_memcpy_d2h( array_length, &
                                      n_repetitions, &
                                      walltime, &
                                      bandwidth ) 

    print*, 'real32,'//&
            trim(adjustl(to_char(array_length)))//','//&
            'pinned,'//&
            trim(adjustl(to_char(array_length*4)))//','//&
            'd2h,'//&
            trim(adjustl(gpuarch))//','//&
            trim(adjustl(hostname))//','//&
            trim(adjustl(to_char(walltime)))//','//&
            trim(adjustl(to_char(bandwidth)))


    ! ///////////////////////////////////////////////////////// !
    ! Float 64 
    ! ///////////////////////////////////////////////////////// !

    array_length = float64_array_low + &
            ceiling( real((float64_array_high - float64_array_low))/&
                     real(n_experiments) )*i

    ! float64 pageable h2d
    call float64_pageable_memcpy_h2d( array_length, &
                                      n_repetitions, &
                                      walltime, &
                                      bandwidth ) 

    print*, 'real64,'//&
            trim(adjustl(to_char(array_length)))//','//&
            'pageable,'//&
            trim(adjustl(to_char(array_length*8)))//','//&
            'h2d,'//&
            trim(adjustl(gpuarch))//','//&
            trim(adjustl(hostname))//','//&
            trim(adjustl(to_char(walltime)))//','//&
            trim(adjustl(to_char(bandwidth)))

    ! float64 pageable d2h
    call float64_pageable_memcpy_d2h( array_length, &
                                      n_repetitions, &
                                      walltime, &
                                      bandwidth ) 

    print*, 'real64,'//&
            trim(adjustl(to_char(array_length)))//','//&
            'pageable,'//&
            trim(adjustl(to_char(array_length*8)))//','//&
            'd2h,'//&
            trim(adjustl(gpuarch))//','//&
            trim(adjustl(hostname))//','//&
            trim(adjustl(to_char(walltime)))//','//&
            trim(adjustl(to_char(bandwidth)))
    

    ! float64 pinned h2d
    call float64_pinned_memcpy_h2d( array_length, &
                                      n_repetitions, &
                                      walltime, &
                                      bandwidth ) 

    print*, 'real64,'//&
            trim(adjustl(to_char(array_length)))//','//&
            'pinned,'//&
            trim(adjustl(to_char(array_length*8)))//','//&
            'h2d,'//&
            trim(adjustl(gpuarch))//','//&
            trim(adjustl(hostname))//','//&
            trim(adjustl(to_char(walltime)))//','//&
            trim(adjustl(to_char(bandwidth)))

    ! float64 pinned d2h
    call float64_pinned_memcpy_d2h( array_length, &
                                      n_repetitions, &
                                      walltime, &
                                      bandwidth ) 

    print*, 'real64,'//&
            trim(adjustl(to_char(array_length)))//','//&
            'pinned,'//&
            trim(adjustl(to_char(array_length*8)))//','//&
            'd2h,'//&
            trim(adjustl(gpuarch))//','//&
            trim(adjustl(hostname))//','//&
            trim(adjustl(to_char(walltime)))//','//&
            trim(adjustl(to_char(bandwidth)))


  enddo

end program memcpy_bench
