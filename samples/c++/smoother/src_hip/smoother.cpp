
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "precision.h"
#include "smoother.h"
#include <hip/hip_runtime.h>

void smootherInit( struct smoother *smoothOperator)
{

  // Hard-set the smoothing stencil to 5x5 grid cells
  int N = 5;
  smoothOperator->dim = N; 
  smoothOperator->weights = (real*)malloc( N*N*sizeof(real) ); 

  real shift = (real)(N-1)/2.0;
  real wsum = 0.0;
  real x;
  real y;
  real r;
  // Initialize memory to 0.0
  for( int j=0; j < N; j++ ){
    y = (real)j -shift;
    for( int i=0; i < N; i++ ){
      x = (real)i -shift;
      r = -(pow(x,2.0)+pow(y,2.0));
      wsum += exp(r);
      smoothOperator->weights[i+j*N] = exp(r);
    }
  }

  for( int j=0; j < N; j++ ){
    for( int i=0; i < N; i++ ){
      smoothOperator->weights[i+j*N] = smoothOperator->weights[i+j*N]/wsum;
    }
  }

  hipMalloc(&smoothOperator->weights_dev,N*N*sizeof(real));
  
  hipMemcpy(smoothOperator->weights_dev,
            smoothOperator->weights,
            N*N*sizeof(real),
            hipMemcpyHostToDevice);
}  

// Manual Destructor : Frees space held by the smoothOperator
void smootherFree( struct smoother *smoothOperator )
{
  free( smoothOperator->weights );

  hipFree(smoothOperator->weights_dev);
}

void resetF( real *f, real *smoothF, int nx, int ny, int buf ){
  int iel;
  // Reassign smoothF to f
  for( int iy=buf; iy<ny-buf; iy++ ){
    for( int ix=buf; ix<nx-buf; ix++ ){
      iel = ix + nx*iy;
      f[iel] = smoothF[iel];
    }
  } 
}

void smoothField( struct smoother *smoothOperator, real *f, real *smoothF, int nX, int nY )
{
  int iloc, ism, iel;
  int N = (real)smoothOperator->dim;
  int buf = (real)(smoothOperator->dim-1)/2.0;
  real smLocal;

  for( int j=buf; j < nY-buf; j++ ){
    for( int i=buf; i < nX-buf; i++ ){
      smLocal = 0.0;
      for( int jj=-buf; jj <= buf; jj++ ){
        for( int ii=-buf; ii <= buf; ii++ ){
          iloc = (i+ii)+(j+jj)*nX;
          ism = (ii+buf) + (jj+buf)*N;
          smLocal += f[iloc]*smoothOperator->weights[ism];
        }
      }
      iel = i+j*nX;
      smoothF[iel] = smLocal;
    }
  }
}

__global__ void smoothField_gpu( real *weights_dev, real *f_dev, real *smoothF_dev, int nX, int nY, int N )
{
  int buf = (real)(N-1)/2.0;
  size_t i = hipThreadIdx_x + hipBlockIdx_x*hipBlockDim_x + buf;
  size_t j = hipThreadIdx_y + hipBlockIdx_y*hipBlockDim_y + buf;
  int iloc, ism;
  
  if( i >= buf && i < nX-buf && j >= buf && j< nY-buf){
    real smLocal = 0.0;
    for( int jj=-buf; jj <= buf; jj++ ){
      for( int ii=-buf; ii <= buf; ii++ ){
        iloc = (i+ii)+(j+jj)*nX;
        ism = (ii+buf) + (jj+buf)*N;
        smLocal += f_dev[iloc]*weights_dev[ism];
      }
    }
    int iel= i+j*nX;
    smoothF_dev[iel] = smLocal;
  }
}

__global__ void resetF_gpu( real *f, real *smoothF, int nX, int nY, int buf )
{
  size_t i = hipThreadIdx_x + hipBlockIdx_x*hipBlockDim_x + buf;
  size_t j = hipThreadIdx_y + hipBlockIdx_y*hipBlockDim_y + buf;
  int iel = i + nX*j;
  if( i >= buf && i < nX-buf && j >= buf && j< nY-buf){
    f[iel] = smoothF[iel];
  }
}
