
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "precision.h"
#include "smoother.h"

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
}  

// Manual Destructor : Frees space held by the smoothOperator
void smootherFree( struct smoother *smoothOperator )
{
  free( smoothOperator->weights );
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
