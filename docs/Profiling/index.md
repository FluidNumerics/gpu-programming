# Profiling

Application profiling is an important skill to learn to help you improve your application's performance.  Profiling will help you uncover where your code spends most of its time and can shed light on why you're spending so much time there. With the right kind of analysis, you can determine whether or not you can achieve more performance for a given algorithm. In turn, these insights can help you learn more about the hardware you are running on and design more performant code.

There are three types of profiles we will discuss in this documentation

1. **Hotspot profiling** - Provides a summary of time spent within each subroutine or labeled section of code. 
2. **Trace profiling** - Provides a time-series view of your application from start to finish.
3. **Hardware event profiling** - Provides a summary of time spent performing specific hardware activities for a given subroutine or labeled section of code.

A good approach to profiling your application is to start with hotspot and trace profiling. Identifying where most of the time is spent in your code will immediately show you where to focus your optimization efforts. A trace profile is particularly useful when investigating memory copy or MPI dependency issues, identifying opportunities for asynchronous operations, or uncovering potential kernel launch latency problems with your application. When you want to focus on optimizing a specific subroutine/kernel, hardware event profiling (often coupled with roofline analysis), will help you find performance opportunities.

