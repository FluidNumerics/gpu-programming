# GPU Aware MPI & AMD GPUs
Ultimately, when an MPI+HIP application is run, we need to be able to determine whether or not we can use device pointers in MPI API calls. When using device pointers, we expect that, under the hood, the MPI library we are using will handle direct communications between GPUs. If GPU Aware MPI support is not available for the target system, we need to manually copy data from device to host, exchange information using host data, and then copy the exchanged data back to the device. 

Application developers vary in their preference in how this is implemented. Some will opt to bake in the GPU-Aware MPI approach or the less scalable alternative at build time, while others want to be able to determine which approach is allowable at runtime. When deciding at build time, developers will often resort to pre-processing, conditionally including code based on the values of CPP flags. During runtime, developers will need to rely on library methods to check for GPU-awareness in their MPI installation.
CUDA-Aware MPI for Nvidia GPUs is available in almost all MPI implementations, including OpenMPI, MPICH, and MVAPICH. ROCm-Aware MPI for AMD GPUs, on the other hand, is not in the mainstream currently. Below, we document the GPU-aware (both CUDA and ROCm) support in popular MPI flavors, covering available CPP flags and API calls, which can help detect GPU aware support for a given MPI  installation. 

## OpenMPI

[CUDA Aware MPI](https://www.open-mpi.org/faq/?category=runcuda)

To find if OpenMPI is built with CUDA-Aware Support
```
ompi_info --parsable --all | grep mpi_built_with_cuda_support:value
mca:mpi:base:param:mpi_built_with_cuda_support:value:true
```

At compile time, you can check for CUDA Aware Support using the `MPIX_CUDA_AWARE_SUPPORT` CPP flag
```
#if defined(MPIX_CUDA_AWARE_SUPPORT) && MPIX_CUDA_AWARE_SUPPORT
```

At runtime, you can check for CUDA Aware support using the `MPIX_Query_cuda_support()` API call.

[OpenUCX + OpenMPI installations](https://github.com/openucx/ucx/wiki/Build-and-run-ROCM-UCX-OpenMPI) provide support for ROCm Aware OpenMPI
Currently, OpenMPI does not have documentation on CPP flags or API calls for detecting ROCm Aware Support

## MVAPICH2
Support for AMD GPUs since MVAPICH2-GDR-2.3.5 ( See [MVAPICH2-GDR-2.3.7](http://mvapich.cse.ohio-state.edu/userguide/gdr/)) 

[At runtime, user’s must set one of the following environment variables](http://mvapich.cse.ohio-state.edu/userguide/gdr/#_running_applications)

* For AMD GPU Support `export MV2_USE_ROCM=1`
* For Nvidia GPU Support `export MV2_USE_CUDA=1`

[At compile time, you can check for CUDA Aware Support using the `MPIX_CUDA_AWARE_SUPPORT` CPP flag](http://mvapich.cse.ohio-state.edu/userguide/gdr/#_compile_time_and_run_time_check_for_cuda_aware_support)
```
#if defined(MPIX_CUDA_AWARE_SUPPORT) && MPIX_CUDA_AWARE_SUPPORT
```

[At runtime, you can check for CUDA Aware support using the `MPIX_Query_cuda_support()` API call](http://mvapich.cse.ohio-state.edu/userguide/gdr/#_compile_time_and_run_time_check_for_cuda_aware_support)


## CRAY MPICH
[Cray-MPICH GPU Aware Support (Video)](https://vimeo.com/554872977) + [Slides](https://www.olcf.ornl.gov/wp-content/uploads/2021/04/HPE-Cray-MPI-Update-nfr-presented.pdf)
Set the following environment variable at runtime to enable GPU aware support
```
MPICH_GPU_SUPPORT_ENABLED=1
```

