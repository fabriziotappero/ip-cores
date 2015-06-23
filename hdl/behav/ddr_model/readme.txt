********************************************************************************************
The sim folder has sample test_bench files to simulate the designs in Modelsim environment. 
This folder has the memory model, test bench, glbl file and required parameter files. 
Read the steps in this file before simulations are done.

To run simulations for this sample configuration, user has to generate the RTL from the tool for the following GUI 
options.

Data_width                : 64
HDL                       : Verilog or VHDL
Memory configuration      : x16
DIMM/Component            : Component 
Memory Part No            : MT46V16M16XX-5
Add test bench            : Yes
Use DCM                   : Yes
Number of controllers     : 1
Number of Write pipelines : 4

-----------------------------------------------For Verilog or VHDL----------------------------------------------------------
 
1. After the rtl is generated, create the Model sim project file. Add all the rtl files from the rtl folder 
   to the project Also add the memory model, test bench and glbl files from the sim folder. 

2. Compile the design.

3. After successful compilation of design load the design using the following comamnd. 

   vsim -t ps +notimingchecks -L ../Modeltech_6.1a/unisims_ver work.ddr1_test_tb glbl
   Note : User should set proper path for unisim verilog libraries

4. After the design is successfully loaded, run the simulations and view the waveforms. 


Notes : 

1. To run simulations for different data widths and configurations, users should modify the test bench files
    with right memory models and design files.

2. User must manually change the frequency of the test bench for proper simulations.
   
3. Users should modify the test bench files for without test bench case.
   


