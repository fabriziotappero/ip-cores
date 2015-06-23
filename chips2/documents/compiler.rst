C2VHDL
======

C2VHDL converts a subset of the C language into Verilog.

The project aims to provide:

 - A simpler, higher level alternative to VHDL and VERILOG.
 - A useful C subset which maps well onto FPGA devices.
 - A very simple implementation which is easy to modify maintain and distribute.
 - A fast and flexible verification environment using C.

Running existing C programs in FPGAs is not a primary objective.

Note:

C2VHDL was designed to target the VHDL language, but this branch outputs code to verilog.

What it Does
============

C2VHDL implements a decent subset of C, enough to do useful things in an FPGA:

 - most statements: if, while, for, break, continue, return, switch, case, default
 - functions
 - single dimension arrays
 - c style comments
 - c++ style comments
 - contstant folding
 - dead code removal
 - instruction level concurrency

What it Doesn't
===============

C2VHDL doesn't implement these thing that either don't work well in FPGAs, or that
I just haven't been implemented yet:

 - no libc
 - no float or double
 - no recursion
 - no pointers
 - no goto statement
 - no forward declarations
 - no struct
 - no union

Download
========

Python script: `c2vhdl.py`_.

.. _`c2vhdl.py` : https://github.com/downloads/dawsonjon/C2VHDL/c2vhdl.py

Installation
=============

1. First `install Python`_. You need *Python* 2.3 or later, but not *Python* 3.
2. Place c2vhdl.py somwhere in your execution path, or execute locally.
3. Thats it! You can now run c2vhdl.py

.. _`install Python` : http://python.org/download

How to use it
=============

Each C file is implemented as a Verilog component that can be used in a design.

Execution Model
---------------

When a design is reset, execution starts with the last function defined in
the C file. This need not be called *main*. The name of the last function
will be used as the name for the generated Verilog component. The C program will
appear to execute in sequence, although the compiler will execute instructions
concurrently if it does not affect the outcome of the program. This will allow
your program to take advantage of the inherent parallelism present in a hardware
design.

Of course if you want even more parallelism, you can have many C2VHDL
components in your device at the same time.

Adding Inputs and Outputs
-------------------------

If you want to add an input or an output to your Verilog component, you can achieve
this by calling functions with *special* names::

  int temp;
  temp = input_spam() //reads from an input called spam
  temp = input_eggs() //reads from an input called eggs
  output_fish(temp)   //writes to an output called fish

Reading or writing from inputs and outputs causes program execution to block
until data is available. This syncronises data tranfers with other components
executing in the same device, this method of passing data beween concurrent
processes is much simpler than the mutex/lock/semaphore mechanisms used in
multithreaded applications.

If you don't want to commit yourself to reading and input and blocking
execution, you can check if data is ready::

  int temp;
  if(ready_spam()){
    temp = input_spam()
  }

There is no equivilent function to check if an output is ready to recieve data,
this could cause deadlocks if both the sending and receiving end were waiting
for one another.

Debugging
---------

Since the language is a subset of C, you can use the usual C based tools for
debugging.  If you want to know what is going on in a Verilog simulation, you can
use these builtin debug functions::

  assert(0); //This will fail
  assert(a == 12); //This will fail if a is not 12
  report(1); //This will cause the simulator to print 1
  report(temp); //This will cause the simulator to print the value of temp

Command Line Usage
------------------

c2vhdl.py [options] <input_file>

compile options:

  no_reuse      : prevent register resuse

  no_concurrent : prevent concurrency

tool options:

  iverilog      : compiles using the iverilog compiler

  run           : runs compiled code, used with iverilog option
