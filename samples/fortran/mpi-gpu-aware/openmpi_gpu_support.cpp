
#include <mpi.h>
#include <mpi-ext.h>

extern "C" {
  bool MPIX_Query_gpu_support()
  {
      bool rocmaware = false;
#if defined(OMPI_HAVE_MPI_EXT_ROCM) && OMPI_HAVE_MPI_EXT_ROCM
      rocmaware = (bool) MPIX_Query_rocm_support();
#endif
      bool cudaaware = false;
#if defined(OMPI_HAVE_MPI_EXT_CUDA) && OMPI_HAVE_MPI_EXT_CUDA
      cudaaware = (bool) MPIX_Query_cuda_support();
#endif

      return (rocmaware || cudaaware);
  }

}
