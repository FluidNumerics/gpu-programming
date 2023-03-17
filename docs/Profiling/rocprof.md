# Profiling applications with ROCprof
[rocprof](https://docs.amd.com/bundle/ROCProfiler-User-Guide-v5.1/page/rocprof_Command_Line_Tool.html)

## Hotspot profiling

## Trace profiling

## Roofline Modeling

Roofline Modeling on AMD Instinct GPUs is currently possible on MI200 series (and newer) GPUs. Older Instinct GPUs do not have FLOP specific counters in the hardware to count FP32 or FP64 specific addition, multiplication, and fused-multiply-add operations. The pre-MI200 series GPUs instead have a more generalized `VALUInsts` counter, which counts all operations performed in the vector arithmetic logic unit (VALU). The `VALUInsts` metric in `rocprof` will measure the overall “floppiness” of your kernel and will not be able to count FLOPs for a specific datatype or math operation. 


