//////////////////////////////////////////////////////////////////////
////                                                              ////
////  README.txt                                                  ////
////                                                              ////
////  This file is part of the Mac Layer Switch project           ////
////                                                              ////
////  Author:                                                     ////
////      - Ran Minerbi (ranminervi@yahoo.com)		          ////
////							          ////
////  this project is using Igor Mohor (igorM@opencores.org)      ////
////  ethernet IP core project as a benchmark to the Ethernet 
////  Switch platform                                             ////
////							          ////
//////////////////////////////////////////////////////////////////////
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
   



Package description:

The package Simulate a cluster including an Ethernet MAC layer switch 
Connected to 6  Network Adapters ( one per Host).
in the cluster Simulation each Network Adapter send an Ethernet
Bit stream to the switch .
The switch send the packet to the destination Network adapter.


BUGS:
WHEN THE RUN COMES TO AN END NEED TO CTRL+C
