############ 
# Overview # 
############ 
This is an elementary generic structural VHDL code for FIR digital filters in transposed-form and direct-form implementations. 
This project covers a wide spectrum of design aspects, in particular design and both functional and formal verification. 
The project is developed in VHDL and modeled in SystemC. The SystemC model is used for functional and formal verification.
TCL scripts for GHDL and SystemC is included within the project files.
This code could be considered for VHDL classes or DSP classes for amateurs or beginners. 
The developed code was synthesized for FPGA and ASIC (0.13um CMOS) using: 
Xilinx 		ISE 
Synopsys 	Design Compiler 
Cadende 	RTL Encounter 

Further, it was implemented using Xilinx Spartan-3E FPGA utilizing the Spartan-3E Starter Kit. It was tested using Xilinx ChipScope and a complete lab setup, as well. The filter output was converted to analog output using the on-board DAC to trace it on a Spectrum analyzer. 

It should be noted that, the developed filters does not employ filter symmetry. However, the recent synthesizers consider symmetry automatically. 

I should acknowledge Alan Fitch and Patrick Grogan for their constructive involvement in the SystemC model.

Enjoy!
Ahmed Shahein
ahmed.shahein@ieee.org
##############
# How to start? #
##############
after unzipping the zipped file you should have two main sub-directories, vhdl and sc. The VHDL codes are located at the vhdl sub-directory and the SystemC model is located in the sc sub-directory.
Execute the TCL script within each folder to see the output. There is a case study for transposed-form (TF) FIR filter with 18 tap and quantization bit-width of 12-bit. The filter is stimulated by a an impulse, therefore, the output is the filter response for a impulse input. I would recommend to change the format of the output signal (fir_out) to signed decimal then to analog-step, in order to have a more representative illustration for the output.
In order to build or generate your specific filter, the user has to modify the fir_pkg.vhd file only. The user has to change three constant parameters, coeff, quantization, and width_out. That's it and That's all. Further, you can change the stimulus file in the test-bench file (fir_filter_stage_tb.vhd) through modifying/replacing the data.txt file.
Regarding the SystemC model, the model initially illustrate a transposed-form FIR filter response for the same filter used in the VHDL implementation. The user has to modify 2 parameters within the firTF.h file, which are:
#define order 18 → integer represents the filter length (number of taps)
static const sc_int<12> fir_coeff[order] = {-51,25,128,77,-203,-372,70,1122,2047,2047,1122,70,-372,-203,77,128,25,-51}; → to the new filter coefficient set
Both VHDL implementation and SystemC model exports the final output into a text file. Which can be loaded to a signal processing software (Matlab or Octave) to plot the time and frequency domain analysis.
#################### 
# Folder Structure # 
#################### 
./src/ 
	adder_gen.vhd 
		Entity and architecture for adder element 
	delay_gen.vhd 
		Entity and architecture for delay element 
	multiplier_gen.vhd 
		Entity and architecture for multiplier element 
	fir_filter_stage.vhd 
		Design top-level 
	fir_pkg.vhd 
		Package for setting the filter coefficeints and quantization bit-width 
		THIS IS THE ONLY FILE THAT THE USER NEED TO CHANGE IT 
	tb_pack.vhd 
		Package for testbench 
	 
./testbench/ 
	fir_filter_stage_tb.vhd 
		Testbench 
	data.txt 
		Stimuli bit-stream for filter input 
	 
./ 
	ghdl.tcl 
		TCL script for GHDL 

./simu/ 
	Temporary folder used by GHDL 
	DON'T DELETE IT or RENAME IT 

./help/
	./html/ 
		This folder contains a complete help for the VHDL codes. 
		The help could be run using the following command: 
		firefox help/html/index.html 
	./doc/
		firTF.jpg
		This is an analytical analysis for a transposed-form FIR with 3 taps
		


