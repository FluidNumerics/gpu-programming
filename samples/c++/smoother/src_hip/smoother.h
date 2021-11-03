
#include "precision.h"
#include <hip/hip_runtime.h>

typedef struct smoother{
  int dim;
  real *weights;
  real *weights_dev;
}smoother;

// Manual Constructor : Allocates space for the interpolant
void smootherInit( struct smoother *smoothOperator);

// Manual Destructor : Frees space held by the interpolant
void smootherFree( struct smoother *smoothOperator );

// Additional routines
void resetF( real *f, real *smoothF, int nx, int ny, int buf );

void smoothField( struct smoother *smoothOperator, real *f, real *smoothF, int nX, int nY);

__global__ void smoothField_gpu( real *weights_dev, real *f_dev, real *smoothF_dev, int nX, int nY, int N );

__global__ void resetF_gpu( real *f, real *smoothF, int nx, int ny, int buf );
