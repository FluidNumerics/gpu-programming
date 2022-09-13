/*
 * This application is used to measure bandwidth of host to device and device to host memory
 * transfers on GPU accelerated systems. We look at transfers for both pinned and pageable
 * memory on the host while varying the size of memory buffers that are transferred. 
 */
#include <hip/hip_runtime.h>
#include <time.h>
#include <stdio.h>

double host_to_device( int N, int nReps ){

  float *f_cpu;
  float *f_gpu;
  clock_t t;
  double wallTime;

  // Allocate the host array
  f_cpu = (float*)malloc( N*sizeof(float) );

  // Allocate the device array
  hipMalloc(&f_gpu, N*sizeof(float));

  t = clock();
  for( int i=0; i < nReps; i++ ){
    hipMemcpy(f_gpu,f_cpu,N*sizeof(float), hipMemcpyHostToDevice);
  }
  hipDeviceSynchronize();
  t = clock() - t;
  
  wallTime = ((double)t)/CLOCKS_PER_SEC/nReps;

  free(f_cpu);
  hipFree(f_gpu);

  return wallTime;
}

double device_to_host( int N, int nReps ){

  float *f_cpu;
  float *f_gpu;
  clock_t t;
  double wallTime;

  // Allocate the host array
  f_cpu = (float*)malloc( N*sizeof(float) );

  // Allocate the device array
  hipMalloc(&f_gpu, N*sizeof(float));

  t = clock();
  for( int i=0; i < nReps; i++ ){
    hipMemcpy(f_cpu,f_gpu,N*sizeof(float), hipMemcpyDeviceToHost);
  }
  hipDeviceSynchronize();
  t = clock() - t;
  
  wallTime = ((double)t)/CLOCKS_PER_SEC/nReps;

  free(f_cpu);
  hipFree(f_gpu);

  return wallTime;
}

double host_to_device_pinned( int N, int nReps ){

  float *f_cpu;
  float *f_gpu;
  clock_t t;
  double wallTime;

  // Allocate the host array (pinned)
  hipHostMalloc(&f_cpu, N*sizeof(float));

  // Allocate the device array
  hipMalloc(&f_gpu, N*sizeof(float));

  t = clock();
  for( int i=0; i < nReps; i++ ){
    hipMemcpy(f_gpu,f_cpu,N*sizeof(float), hipMemcpyHostToDevice);
  }
  hipDeviceSynchronize();
  t = clock() - t;
  
  wallTime = ((double)t)/CLOCKS_PER_SEC/nReps;

  hipHostFree(f_cpu);
  hipFree(f_gpu);

  return wallTime;
}

double device_to_host_pinned( int N, int nReps ){

  float *f_cpu;
  float *f_gpu;
  clock_t t;
  double wallTime;

  // Allocate the host array (pinned)
  hipHostMalloc(&f_cpu, N*sizeof(float));

  // Allocate the device array
  hipMalloc(&f_gpu, N*sizeof(float));

  t = clock();
  for( int i=0; i < nReps; i++ ){
    hipMemcpy(f_cpu,f_gpu,N*sizeof(float), hipMemcpyDeviceToHost);
  }
  hipDeviceSynchronize();
  t = clock() - t;
  
  wallTime = ((double)t)/CLOCKS_PER_SEC/nReps;

  hipHostFree(f_cpu);
  hipFree(f_gpu);

  return wallTime;
}

int main ( ){

  int nMax = 100000000;
  int nStep = 10;

  printf("Type, Size (Bytes), Wall Time (s), Bandwidth (GB/s) \n" );

  // Do the host to device (pageable) transfers
  for( int i = 1; i<nMax; i *= nStep ){

    double wallTime = host_to_device( i, 1000 );
    int dataSize=sizeof(float)*i;
    double bandwidth=dataSize/wallTime/1024/1024/1024;
    printf("Host to Device (pageable), %d, %f, %f \n",dataSize,wallTime,bandwidth);

  } 

  // Do the host to device (pageable) transfers
  for( int i = 1; i<nMax; i *= nStep ){

    double wallTime = device_to_host( i, 1000 );
    int dataSize=sizeof(float)*i;
    double bandwidth=dataSize/wallTime/1024/1024/1024;
    printf("Device to Host (pageable), %d, %f, %f \n",dataSize,wallTime,bandwidth);

  } 

  // Do the host to device (pinned) transfers
  for( int i = 1; i<nMax; i *= nStep ){

    double wallTime = host_to_device_pinned( i, 1000 );
    int dataSize=sizeof(float)*i;
    double bandwidth=dataSize/wallTime/1024/1024/1024;
    printf("Host to Device (pinned), %d, %f, %f \n",dataSize,wallTime,bandwidth);

  } 

  // Do the host to device (pinned) transfers
  for( int i = 1; i<nMax; i *= nStep ){

    double wallTime = device_to_host_pinned( i, 1000 );
    int dataSize=sizeof(float)*i;
    double bandwidth=dataSize/wallTime/1024/1024/1024;
    printf("Device to Host (pinned), %d, %f, %f \n",dataSize,wallTime,bandwidth);

  } 

}
