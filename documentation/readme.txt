Some notes on using the code 

Notes on code layout:

      C_implementation - this directory contains the golden C implementation

      common - this directory contains some definition files which are
      shared among the the other directories

      compressionFunction - this directory contains the implementation
      and testbenches for the compression function.

      documentation - this directory contains relevant documentation

      lib - this directory mirrors the Bluespec Board support package.
      It contains useful library functionality - like bus
      implementations.

      MD6Control - contains the memory controller implementations and
      the full system testbenches

      toolflow - some scripts for synthesis - not really useful to the
      outside world

Building the code: 

      There are many targets in the build directories -
      the most useful of these are:

      MD6Verify - builds the full system verification

      MD6ControlEngine_fpga - builds an FPGA version of the control engine

      SimpleCompressionFunctionTestbench64 - a test bench for the
      compression function in isolation


What you will need:

Latest version of the Bluespec compiler.  Visit www.bluespec.com We
may be able to provide you with one-of verilog.  Please contact us if
you would like verilog.


Further documentation about the operation, theory, security, and
practical implementation of MD6 can be found at:

http://groups.csail.mit.edu/cis/md6/

