# OpenMP 5.0 Memory Management API

This example demonstrates how to use routines from the OpenMP memory management API in Fortran applications.

Specifically, we look at how to create a `TYPE(c_ptr)` that points to a memory address on the GPU that is originally created in OpenMP. This pattern is useful when you want to offload portions of your code to the GPU with OpenMP, while also using kernel based APIs or GPU accelerated libraries for other portions.


**This example will only work when using an [OpenMP 5.1](https://www.openmp.org/spec-html/5.1/openmp.html) compliant compiler**

