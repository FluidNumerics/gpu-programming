# OpenMP Basics

The [OpenMP](htttps://openmp.org) 4 standard introduced directives for offloading regions of code to GPU hardware. This includes directives for parallelizing loop structures as well as those for managing device memory. Additionally, the OpenMP API provides methods for managing devices. With the OpenMP 5 standard, the OpenMP API is expanded to provide more explicit control over host and device pointer management, which allows for interoperability with HIP, CUDA, and GPU accelerated libraries. Although the OpenMP standard has progressed into version 5 (as of 2022), implementations within compilers varies; for example see [LLVM Clang/Flang OpenMP supported features](https://clang.llvm.org/docs/OpenMPSupport.html).

In this section, you will learn 

* How to offload regions of code to GPU Accelerators with OpenMP `target` directives
* How to parallelize for/do loops with OpenMP `teams`
* How to use data regions to minimize memory copies between CPU and GPU
* How to compile Fortran and C/C++ applications with `amdflang` and `amdclang`.


## Offloading Compute to GPUs

### Target Regions
With OpenMP, you can use the `omp target` directive to mark regions of code that you want the compiler to offload to the GPU. When you open a target region a target task is created on the GPU and with no other directives, all code within the target region is run in serial on a single thread. Since GPUs have a distinct memory space in comparison to host CPUs, you also need to hint to the compiler what data needs to be copied to and from the GPUs when opening a target region; this is done using the `map` directive.

The examples below show how to use the `target` and `map` directives in Fortran and C/C++ in a simple matrix-vector multiply method.

```fortran
INTEGER, PARAMETER :: N=1000
REAL :: axloc
REAL, ALLOCATABLE, A(:,:), Ax(:), x(:)

ALLOCATE(A(1:N,1:N), Ax(1:N), x(1:N))

! Initialize values
x = 1.0
A = 1.0

!$omp target map(to:A,x) map(from:Ax)
DO i = 1, N
 axloc = 0.0
 DO r = 1, N
   axloc = axloc+A(r,i)*x(r)
 ENDDO
 Ax(i) = axloc
ENDDO
!$omp end target

DEALLOCATE(A,Ax,x)
```

```c
int N=1000;
float *A, *Ax, *x;

malloc(A, sizeof(float)*N*N);
malloc(Ax, sizeof(float)*N);
malloc(x, sizeof(float)*N);

// Initialize values
for( int i = 0; i < N; i++ ){
  x[i] = 1.0;
  for( int j = 0; j < N; j++ ){
    A[j+i*N] = 1.0;
  }
}

float axloc = 0.0;
#pragma omp target map(to:A,x) map(from:Ax)
{ 
  for( int i = 0; i < N; i++ ){
    axloc = 0.0;
    for( int r = 0; r < N; r++) {
      axloc += A[r+N*i]*x[r];
    }
    Ax[i] = axloc;
  }
}

free(A);
free(Ax);
free(x);
```

In these examples,

* OpenMP directives begin with `!$omp` in Fortran and `#pragma omp` in C/C++.
* In Fortran, the OpenMP target region is closed using the `!$omp end target` directive.
* In C/C++, the OpenMP target region is enclosed with brackets `{` and `}` to indicate clearly the region that is offloaded to the GPU.
* The arrays `A` and `x` are mapped to the GPU using the `map(to:A,x)` directive. The `to` modifier allows us to eliminate an unnecessary copy back to the CPU at the end of the target region, since `A` and `x` are not updated in the code included in the target region.
* The `Ax` array if mapped from the GPU at the end of the target region using the `map(from:Ax)` directive. The `from` modifier eliminates and unnecessary copy to the GPU at the beginning of the target region, since `Ax` is only written to in the code included in the target region.
* Scalar values, like `axloc` and the loop iterators are automatically thread private and copied to the GPU, if necessary. Because of this, you do not need to explicitly include scalar values in `map` directives.

### Teams Distribute Parallel

Within a target region, with no other directives, a single thread of execution is launched on the GPU. However, GPUs are capable of running thousands of threads simultaneously. Before the teams directive was introduced in OpenMP 4.0, parallelization was limited to parallelizing with a single group of threads. Since OpenMP 4.0, the teams directive can be used to express another dimension of parallelism that is appropriate for GPUs.

The `teams` directive creates a “league” of teams that each have a single thread by default. OpenMP teams execute instructions concurrently. Following a `teams` directive with a `distribute` will cause future instructions, such as `for` or `do` loops to be distributed across the teams.

The `parallel` directive creates multiple threads within each team and the number of threads can be set with the optional `num_threads` clause after the parallel directive. On a GPU, the number of threads per team is ideally a multiple of the Wavefront or Warp size (64 threads on AMD GPUs or 32 threads on Nvidia GPUs).

When working with applications that have tightly nested loops, you can increase the amount of exposed parallelism by using the `collapse(n)` directive, where `n` is the number of loops to collapse. Loop collapsing is ideal when you have tightly nested loops with instructions that do not have dependencies between iterations.

The examples below show how we would parallelize the matrix-vector multiply from the previous example. 

```fortran
INTEGER, PARAMETER :: N=1000
REAL :: axloc
REAL, ALLOCATABLE, A(:,:), Ax(:), x(:)

ALLOCATE(A(1:N,1:N), Ax(1:N), x(1:N))

! Initialize values
x = 1.0
A = 1.0

!$omp target map(to:A,x) map(from:Ax)
!$omp teams distribute parallel for num_threads(256)
DO i = 1, N
 axloc = 0.0
 DO r = 1, N
   axloc = axloc+A(r,i)*x(r)
 ENDDO
 Ax(i) = axloc
ENDDO
!$omp end target

DEALLOCATE(A,Ax,x)
```

```c
int N=1000;
float *A, *Ax, *x;

malloc(A, sizeof(float)*N*N);
malloc(Ax, sizeof(float)*N);
malloc(x, sizeof(float)*N);

// Initialize values
for( int i = 0; i < N; i++ ){
  x[i] = 1.0;
  for( int j = 0; j < N; j++ ){
    A[j+i*N] = 1.0;
  }
}

float axloc = 0.0;
#pragma omp target map(to:A,x) map(from:Ax)
{ 
  #pragma omp teams distribute parallel for num_threads(256)
  for( int i = 0; i < N; i++ ){
    axloc = 0.0;
    for( int r = 0; r < N; r++) {
      axloc += A[r+N*i]*x[r];
    }
    Ax[i] = axloc;
  }
}

free(A);
free(Ax);
free(x);
```

In this example, we only parallelize the outer loop with the `teams distribute parallel for` compound directive. The inner loop is a reduction and is left serialized in this example. For large enough loops, the `reduce` can be beneficial and may improve the runtime by exposing more parallelism. The number of threads per team here is set to 256 using the `num_threads` modifier. When parallelizing your own codes, you should consider varying this value between your GPUs warp or wavefront size and 1024 (the upper bound for threads per team on current GPUs) and measuring kernel runtime.

## Data Regions

## Compiling Applications

## Try it yourself
To accompany these notes, we have created hands-on codelabs that walk you through porting a mini application to the GPU using OpenMP. You will offload two kernels using `target` and `teams distribute parallel` directives. From here, you will learn how to use the `rocprof` profiler to create hotspot and trace profiles of the application to identify memory copies as a bottleneck for performance. From here, you will use OpenMP data regions to minimize memory copies to reduce the application's runtime.

* [Porting a Fortran mini-application to GPUs with OpenMP](../../codelabs/build-a-gpu-app-openmp-fortran/index.html)
* [Porting a C/C++ mini-application to GPUs with OpenMP](../../codelabs/build-a-gpu-app-openmp-c/index.html)
