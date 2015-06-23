1-edit run.tcl and replace . with your project directory (that contains tcl files) 

2-edit setup.tcl at line 218 begin to add your files as shown  
3-edit setup.tcl at line 230 set your top module   

4-open xilinx bash shell and point to the directory that contains tcl files then write xtclsh 
5-write the command: source run.tcl
6-after running all processes the sdf file and the verilog netlist can be found in netgen folder 
