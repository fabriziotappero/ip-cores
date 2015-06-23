Code samples:
=============

This directory contains a few test applications that can be simulated and run
on real hardware (except for the opcode test which can only be simulated). See
the readme file and the makefile for each program.

The makefiles have been tested with the CodeSourcery toolchain for windows (that
can be downloaded from www.codesourcery.com). They should work with other 
toolchains and have been occasionally tested with the Buildroot toolchain
for GNU/Linux.

Most makefiles have two targets, to create a package for the simulation test
bench or for the synthesizable demo.

Target 'sim' will build a the simulation test bench package as vhdl file 
'/vhdl/tb/sim_params_pkg.vhdl'. The tool used to build the package is the
python script '/tools/build_pkg/build_pkg.py'.

Target 'demo' will build a package for the synthesizable demo as file 
'/vhdl/SoC/bootstrap_code_pkg.vhdl', using the same python script.

The build process will produce a number of binary files that can be run on the 
software simulator. A DOS BATCH file has been provided for each sample that 
runs the simulator with the proper parameters (swsim.bat).

The simulation log produced by the software simulator can be compared to the log
produced by Modelsim (the only hdl simulator supported yet); they should be
identical (but see notes on the project doc).



Support code library:
=====================

Many of the code samples use support code from an ad-hoc library included with 
the project (src/common/libsoc). Before making any of the samples you should 
make the library ('make' with no target). That command will build lib file 
'src/common/libsoc/libsoc.a'.



Building VHDL code from templates:
==================================

The python script '/tools/build_pkg/build_pkg.py' is used by all the samples to
insert binary data on vhdl templates, building VHDL packages.
Assuming you have Python 2.5 or later in your machine, call the script with 

    python build_pkg.py --help

to get a short description and usage instructions.
There's a more detailed description in script source.

