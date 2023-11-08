module openmpi_gpu_support


implicit none

  interface
    function MPIX_Query_gpu_support() bind(c,name="MPIX_Query_gpu_support")
      implicit none
      logical :: MPIX_Query_gpu_support
    end function MPIX_Query_gpu_support
  end interface


end module openmpi_gpu_support
