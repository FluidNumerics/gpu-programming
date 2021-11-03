
#include "precision.h"
#include <hip/hip_runtime.h>

__global__ void ApplySmoother_gpu(real *f_dev, real *weights_dev, real *smoothF_dev, int nW, int nX, int nY )
{
  size_t i = hipThreadIdx_x + hipBlockIdx_x*hipBlockDim_x + nW;
  size_t j = hipThreadIdx_y + hipBlockIdx_y*hipBlockDim_y + nW;
  int iel, ism;

  if( i >= nW && i < nX-nW && j >= nW && j< nY-nW){
    real smLocal = 0.0;
    for( int jj=-nW; jj <= nW; jj++ ){
      for( int ii=-nW; ii <= nW; ii++ ){
        iel = (i+ii)+(j+jj)*nX;
        ism = (ii+nW) + (jj+nW)*(2*nW+1);
        smLocal += f_dev[iel]*weights_dev[ism];
      }
    }
    iel = i+j*nX;
    smoothF_dev[iel] = smLocal;
  }
}

extern "C"
{
  void ApplySmoother_HIP(real **f_dev, real **weights_dev, real **smoothF_dev, int nW, int nX, int nY)
  {
    int threadsPerBlock = 16;
    int gridDimX = (nX-2*nW)/threadsPerBlock + 1;
    int gridDimY = (nY-2*nW)/threadsPerBlock + 1;

    hipLaunchKernelGGL((ApplySmoother_gpu), dim3(gridDimX,gridDimY,1), dim3(threadsPerBlock,threadsPerBlock,1), 0, 0, *f_dev, *weights_dev, *smoothF_dev, nW, nX, nY);
  }
}

__global__ void ResetF_gpu(real *f_dev, real *smoothF_dev, int nW, int nX, int nY)
{
  size_t i = hipThreadIdx_x + hipBlockIdx_x*hipBlockDim_x + nW;
  size_t j = hipThreadIdx_y + hipBlockIdx_y*hipBlockDim_y + nW;
  int iel = i + nX*j;
  if( i >= nW && i < nX-nW && j >= nW && j< nY-nW){
    f_dev[iel] = smoothF_dev[iel];
  }
}

extern "C"
{
  void ResetF_HIP(real **f_dev, real **smoothF_dev, int nW, int nX, int nY)
  {
    int threadsPerBlock = 16;
    int gridDimX = (nX-2*nW)/threadsPerBlock + 1;
    int gridDimY = (nY-2*nW)/threadsPerBlock + 1;

    hipLaunchKernelGGL((ResetF_gpu), dim3(gridDimX,gridDimY,1), dim3(threadsPerBlock,threadsPerBlock,1), 0, 0, *f_dev, *smoothF_dev, nW, nX, nY);
  }
}

