---------------------------------------------------------------
-- G729A Codec self-test simulation script
---------------------------------------------------------------

How to use this script:

1) Create Modelsim project into desired directory.

2) Customize script "SRC_DIR" variable, to point to the 
directory holding VHDL source files.

3) Run the script. the script compiles all required VHDL source
file, adds a minimal set of waveforms to wave window and then
starts actual simulation, which runs for 27ms. When simulation
stops, wave window should look like snapshot in file
wave_27ms.bmp (both DONE and PASS signals are '1').

