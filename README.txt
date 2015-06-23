//////////////////////////////////////////////////////////////////////
////                                                              ////
////  README.txt                                                  ////
////                                                              ////
////  This file is part of the Ethernet IP core project           ////
////  http://www.opencores.org/project,ethmac                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Igor Mohor (igorM@opencores.org)                      ////
////      - Olof Kindgren (olof@opencores.org)                    ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001, 2002 Authors                             ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//
//

RUNNING the simulation/Testbench in Icarus Verilog:

Go to the scripts directory and write "make rtl-tests"
All logs will be saved in the log directory

To activate VCD dumps, run with "make rtl-tests VCD=1". The VCD is saved
in build/sim/ethmac.vcd


RUNNING the simulation/Testbench in ModelSIM:

Open ModelSIM project: ethernet/sim/rtl_sim/modelsim_sim/bin/ethernet.mpf
Run the macro do.do (write "do do.do" in the command window).
Simulation will be automatically started. Logs are stored in the /log 
directory. tb_ethernet test is performed.



RUNNING the simulation/Testbench in Ncsim:

Go to the ethernet\sim\rtl_sim\ncsim_sim\run directory. Run the 
run_eth_sim_regr.scr script. Simulation is automatically started. Logs are 
stored in the /log directory. Before running the script for another time,
run the clean script that deletes files from previous runs. tb_ethernet test
is performed.






Why are eth_cop.v, eth_host.v, eth_memory, tb_cop.v and tb_ethernet_with_cop.v
files used for?

Although the testbench does not include the traffic coprocessor, the 
coprocessor is part of the ethernet environment. eth_cop multiplexes
two wishbone interface between 4 modules: 
- First wishbone master interface is connected to the HOST (eth_host)
- Second wishbone master interface is connected to the Ethernet Core (for
  accessing data in the memory (eth_memory)).
- First wishbone slave interface is connected to the Ethernet Core (for 
  accessing registers and buffer descriptors).
- Second wishbone slave interface is connected to the memory (eth_memory)
  so host can write data to the memory (or read data from the memory. 

tb_cop.c is a testbench just for the traffic coprocessor (eth_cop).
tb_ethernet_with_cop.v is a simple testbench where all above mentioned
modules are connected into a single environment. Few packets are transmitted
and received. The "main" testbench is tb_ethernet.v file. It performs several
tests (eth_cop is not part of the simulation environment).





