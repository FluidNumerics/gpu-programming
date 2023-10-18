# Debugging with roc-gdb

You've probably found this page because your AMD GPU accelerated application has crashed, and you don't have much information as to why that crash has happened. You may have started thinking about which lines in your code to comment out or where to insert print statements so that you can narrow this down. Maybe you've even remembered the compiler flags to use to dump a stack trace. Maybe the problem is more subtle; your code runs "fine" but the results are filled with Inf's and NaN's and other garbage and you'd like to pinpoint the source of the issue. If you don't regularly use debuggers, it's easy to forget the commands to launch your code with the debugger and how to interrogate more deeply what your code is doing. This page will walk you through some basic steps for debugging AMD GPU accelerated applications with rocgdb. This process is meant for developers working with HIP, OpenMP, OpenCL, or other ROCm accelerated applications.


## Compiler flags for debugging

### hipcc / rocmcc / whatever name AMD is using this week for their clang compiler

### GNU compilers