=========================================
        HyperTransport Tunnel
=========================================

This project describes a HyperTransport tunnel for hardware synthesis using 
the SystemC C++ API.  It was developped to be integrated as a core into a 
larger hardware project.  You can either synthesize the core using a SystemC 
synthesis tool or simulate it using any C++ compiler.  The design was 
developped using SystemC 2.0.1

The tunnel is technology independent, so it can be used with any technology 
(Xilinx FPGAs,  Altera FPGAs, standard cell proces, etc.)  The design uses 
synchronous dual-port (one read and one write port) memories by having input 
and outputs ports to those memories.  So when instanciating the design, you 
must connect those ports either to memories in a real circuit or to a memory 
model in simulation.

The design has many options and to change them, you need to modify the file 
rtl/systemc/core_synth/constants.h.  It contains all the options and 
configuration option available.  This includes various modes : if the retry 
mode is enabled, if DirectRoute is enabled, etc.  It is also used to setup 
the Configuration Space Registers : the address space used by the application, 
the ID number of the application, etc.

For code documentation, you can run doxygen (a documenation tool) with the 
doxygen.config.  It will generate HTML documentation in doc/doxygen/html

For higher level documentation, look in the doc folder.  At the moment of 
writing this readme, the doc folder is empty but hopefully by the time you 
read this there will be some proper documentation.  But at least remember 
that the source code is fairly well documented (in .h files) so don't be 
afraid to go read at least the module descriptions in the .h files.

For synthesis
=============

The design was originally designed for the Synopsys SystemC Compiler tool, 
but it is now discontinued.  Alternatives are Celoxica Agility Compiler and 
Forte Cynthesizer.  Agility 1.0 is not compatible with the core but version 
2.0 might be when it is released.  I have not had the chance to try 
Cynthesizer so I do not know if it works.  If you have the chance of trying 
it, let me know!  I have synthesized multiple configurations of the design 
and tested them in post-synthesis simulation, but those versions are useless 
in a real application since the tunnel needs to be re-synthesized when the 
CSR configuration changes, and every project usually has a different CSR 
configuration.

For simulation in a larger project
==================================

To simulate it within a larger SystemC project, just include all the source 
files in rtl/systemc in your project and instanciate the top level 
vc_ht_tunnel_l1 module to use just like any SystemC module.  But bear in mind 
that this is an RTL description, so simulation is pretty slow.

For simulation in ModelSim
===========================

The .do file contains most of the commands necessary to compile the design 
in ModelSim and run the main testbench, but to simulate it in your project 
you will need a top level that instanciates the design and links it with 
other designs.  In other words, the .do file is only a set of commands to 
get you started and run a testbench.  ModelSim allows to run SystemC alongside 
netlists, VHDL, Verilog or anything supported my ModelSim.

For simulation alone
====================

The bench directory contains many testbenches to test the design.  The tests 
done are VERY limited.  Some tests are self-checking and others simply 
stimulates the design and the output has to be manually checked.

If you are using MS Visual Studio, there are projects files already prepared 
to compile and run the testbenches.  All you have to do is update the location 
of the SystemC include directory and the SystemC link library location in the 
project.

If you are using GCC, I am not too familiar with the configure scripts that 
search to see if SystemC is properly installed, is the correct version, etc. 
etc.,  so there are no configure/makefile files ready to use out of the box.  
Also, the fact that SystemC includes a "main" function often conflicts with 
autoconfigure tests.  I have tried the global testbench using KDevelop and 
it works perfectly.

