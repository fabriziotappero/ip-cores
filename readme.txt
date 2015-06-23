There are many files included in this distribution.  However, the following 
files implement the core functionality of the design and should be examined
to get a flavor of the design operation.  All path names are given relative
to the base directory.

memocodeDesignContest07/hardware/Feeder/BRAMFeeder.bsv
memocodeDesignContest2008/aesCores/bsv/aesCipherTop.bsv - controller for aesCores
memocodeDesignContest2008/sort/Sort.bsv - Builds a full sort treee from VLevel FIFOs
memocodeDesignContest2008/sort/BRAMLevelFIFOAdders/BRAMVLevelFIFO.bsv - time multiplexes a BRAM between multiple
logical fifos.  This is the key module in the sort tree.
memocodeDesignContest2008/ctrl/mkCtrl.bsv - control module orchestrating memory, the sorter, and the aes.
memocodeDesignContest2008/xup/PLBMaster/PLBMaster.bsv - Parametric PLB bus master  
memocodeDesignContest2008/xup/Top/Sorter.bsv - top level module


If you would like to build the code, there are a few useful targets to
consider.  The xup directory contains several fpga implementations.
These were built using Xilinx EDK 9.2. The precise build recipe is below:

cd memocodeDesignContest2008/xup/build/
make top_verilog

Of course, this merely builds the hardware. Some effort is required to
place a working copy on the fpga.  Please email the project owners for
details on how to do this.




