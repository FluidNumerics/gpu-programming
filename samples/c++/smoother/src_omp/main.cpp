
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "precision.h"
#include "smoother.h"

int main( int argc, char *argv[] )  {
  smoother smoothOperator;
  int nx, ny, nElements;
  int nIter;
  real dx;
  real *f, *smoothF;

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
  int N = smoothOperator.dim;

  // Allocate space for the function we want to smooth
  f  = (real*)malloc( nElements*sizeof(real) );
  smoothF = (real*)malloc( nElements*sizeof(real) );
  #pragma omp target enter data map(alloc: f[0:nElements], smoothF[0:nElements])

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

  #pragma omp target update to(f[0:nElements], smoothF[0:nElements], smoothOperator.weights[0:N*N])
  for( int iter=0; iter<nIter; iter++){

    // Run the smoother
    smoothField( &smoothOperator, f, smoothF, nx, ny );

    // Reassign smoothF to f
    resetF( f, smoothF, nx, ny, buf );
  }
  #pragma omp target update from(smoothF[0:nElements])

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
  #pragma omp target exit data map(delete:f[0:nElements],smoothF[0:nElements])
  free(f);
  free(smoothF);

  smootherFree(&smoothOperator);

  return 0;

}
