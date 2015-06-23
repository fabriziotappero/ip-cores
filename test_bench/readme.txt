
This is a quick 'cheat sheet' on how to create a project and run a simulation.
For a more complete explanation, please refer to the documentation.

This code was tested with Xilinx ISE Design Suite 11.

**** I Creating a Project.*****
Steps to create a Xilinx Project:

1 - Un-compress all the verilog sources under the same folder (ie. flatten the directory strucure)
 (easier for later steps).

2 - Start ISE Project Navigator.

3 - Go to File->New Project.
Under the 'Create new project' screen:
Enter the name, and location you want (the location
doesn't necesarely has to match the folder where you
 un-compressed Theia's sources).
Under 'Top-level source type' select 'HDL'.
Click the 'Next' Button.

4 - Under the 'Device Properties' screen:
Select the Product category and family (choose a big device, since the
design has not yet being optimized for size)
Select 'Verilog' as the preferred language.
Select 'ISim (VHDL/Verilog)' as the simulator.

5 - Under the 'Create New Source' screen:
Do nothing, just click 'Next'.


6 - Under the 'Add Existing Sources' screen:
Click the 'Add source' button.

Select all the verilog sources (.v files), you can
select all at once using CNTR+A.
Click 'Open', then click 'Next'.

7 - Click Finish.

8 - Under the 'Source for:' drop down list, select 'Behavioral Simulation'.

9 - Under the 'Hierarchy' tree control, select the File named 'TestBench_Theia(TestBench_THEIA.v)
Then, under the 'Process: TestBench_Theia', right click on the 'Simulate Behavioral Model' icon and
select the 'Process Properties...' option.
 
Under the 'Process properties' screen:
Select the 'Specify 'define Macro Name and Value' Option and put the following:
type: 'DEBUG=1|DUMP_CODE=1|DEBUG_CORE=0' if you want to create code dump dis-assembly files and other log files
(option is recommended for debug)
type: 'DEBUG=1|DEBUG_CORE=0' if you want verbose output including dis-assembly of code to the standard output.
type: '' leave it blank if you want no output.

**** II Preparing the inputs ****
1 - Download one of the example scenes to the same folder where the Simulation executable is.

**** III Running behavioral simulation *****


1 - Make sure you have the *.mem files under the same folder where the simulation executable is.

2 - From the ISE Project Navigator, double click on the 'Simulate Behavioral Model' to start the simulation.
Note: The simulation can take from minutes to hours depending on the scene that you want to render and the 
complexity of your shaders.

**** IV Looking at the results *****

The main output is a file called 'Output.ppm'.
This is an image file written using the 'Netpbm format'.
PPM file is image format at plain text (http://en.wikipedia.org/wiki/Netpbm_format).
Under Linux You can view this picture with many tools such as 'gimp' or 'ee', for windows
you can use a free program called 'XnView' or also 'gimp' for windows will work.


The simulation executable generates several other files depending on the macros you specified at step I.9.
Please see the documentation for more information on this files.

