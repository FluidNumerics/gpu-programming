
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "precision.h"
#include "smoother.h"
#include <hip/hip_runtime.h>


int main( int argc, char *argv[] )  {
  smoother smoothOperator;
  int nx, ny, nElements;
  int nIter;
  real dx;
  real *f, *smoothF;
  real *f_dev, *smoothF_dev;

  if( argc == 3 ) {
     nx = atoi(argv[1]);
     ny = nx;
     nElements = nx*ny;
     dx = 1.0/(real)nx;

     nIter = atoi(argv[2]);
  }
  else if( argc > 3 ) {
     printf("Too many arguments supplied.\n");
     return -2;
  }
  else {
     printf("Two argument expected.\n");
     return -1;
  }
  

  // Create the smoother
  smootherInit(&smoothOperator);
  int buf = (real)(smoothOperator.dim-1)/2.0;

  int threadsPerBlockX = 8;
  int threadsPerBlockY = 8;
  int gridDimX = (nx-2*buf)/threadsPerBlockX+1;
  int gridDimY = (ny-2*buf)/threadsPerBlockY+1;

  // Allocate space for the function we want to smooth
  f  = (real*)malloc( nElements*sizeof(real) );
  smoothF = (real*)malloc( nElements*sizeof(real) );

  hipMalloc(&f_dev, nElements*sizeof(real));
  hipMalloc(&smoothF_dev, nElements*sizeof(real));

  real y;
  real x;
  int iel;
  // Initialize the function we want to smooth and the smoothed function
  for( int iy=0; iy<ny; iy++ ){
    y = (real)iy*dx;
    for( int ix=0; ix<nx; ix++ ){
      x = (real)ix*dx;
      iel = ix + nx*iy;
      f[iel] = tanh( (x-0.5)/0.01 )*tanh( (y-0.5)/0.01 );
      smoothF[iel] = 0.0;
    }
  } 

  // Write f to file
  FILE *fp;
  fp = fopen("./function.txt", "w");
  for( int iy=0; iy<ny; iy++ ){
    for( int ix=0; ix<nx; ix++ ){
      iel = ix + nx*iy;
      fprintf(fp, "%10.4e \n",f[iel]);
    }
  } 
  fclose(fp);


  hipMemcpy(smoothF_dev, smoothF, nElements*sizeof(real), hipMemcpyHostToDevice);
  hipMemcpy(f_dev, f, nElements*sizeof(real), hipMemcpyHostToDevice);

  for( int iter=0; iter<nIter; iter++){
    // Run the smoother
    hipLaunchKernelGGL((smoothField_gpu), dim3(gridDimX,gridDimY,1), dim3(threadsPerBlockX,threadsPerBlockY,1), 0, 0,
                        smoothOperator.weights_dev, f_dev, smoothF_dev, nx, ny, smoothOperator.dim );
    // Reassign smoothF to f
    hipLaunchKernelGGL((resetF_gpu), dim3(gridDimX,gridDimY,1), dim3(threadsPerBlockX,threadsPerBlockY,1), 0, 0,
                        f_dev, smoothF_dev, nx, ny, buf );
  }
  // Copy smoothF_dev from device to host
  hipMemcpy(smoothF, smoothF_dev, nElements*sizeof(real), hipMemcpyDeviceToHost);

  // Write smoothF to file
  fp = fopen("./smooth-function.txt", "w");
  for( int iy=0; iy<ny; iy++ ){
   for( int ix=0; ix<nx; ix++ ){
     iel = ix + nx*iy;
     fprintf(fp, "%10.4e \n",smoothF[iel]);
   }
  } 
  fclose(fp);

  // Free space
  free(f);
  free(smoothF);

  hipFree(f_dev);
  hipFree(smoothF_dev);

  smootherFree(&smoothOperator);

  return 0;

}
