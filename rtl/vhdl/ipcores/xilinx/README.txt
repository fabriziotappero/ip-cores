The IP Core XCO files are xilinx core generator configuration files.
They are provided as examples only and you may need to do some tweaking
to the generated code to get it to work.

mac_layer_v2_2.xco - is the current core I last tested with.

mac_layer_v2_1.xco - is an earlier xilinx core that I originally developed with. 
The interface may have changed slightly, so you may need to make some small changes
to the ml605/xv6mac_straight.vhd module to get it to work with this version.
