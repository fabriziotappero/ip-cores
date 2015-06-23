
  TosNet rev3.2
  MicroBlaze Peripheral, readme.txt

  Simon Falsig
  University of Southern Denmark
  Copyright 2010

  This file is part of the TosNet MicroBlaze Peripheral

  The TosNet MicroBlaze peripheral is free software: you can redistribute it 
  and/or modify it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the License,
  or (at your option) any later version.

  The TosNet MicroBlaze peripheral is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with the TosNet MicroBlaze peripheral. If not, see
  <http://www.gnu.org/licenses/>.


******************************************
* Description
******************************************
  The TosNet MicroBlaze peripheral provides an implementation of the TosNet
  core, interfaced to the MicroBlaze PLB bus, along with a software driver
  to support the functionality.


******************************************
* Installation
******************************************
  Copy the contents of the 'drivers' and 'pcores' folders to an EDK peripheral
  repository, preserving the original folder structure.

  For instance:
    c:\XilinxEDKRepository\MyProcessorIPLib\pcores\tosnet_v3_20_a
    c:\XilinxEDKRepository\MyProcessorIPLib\drivers\tosnet_v3_20_a

  You should now have access to the TosNet core from within EDKs IP Library.


******************************************
* Usage, XPS
******************************************
  1. Add the TosNet component to your design.

  2. Make 'sig_in' and 'sig_out' external, and connect these to your
     transmission components.

  3. Connect 'clk_50M' to a 50 MHz clock signal.

  4. Connect the 'sync_strobe' and 'system_halt' interrupt signals to an
     interrupt controller, if necessary.

  5. Connect the TosNet component to the PLB bus.

  6. Configure the TosNet component to your likings ('Configure IP').
     Important settings are the 'C_NODE_ID' and 'C_REG_ENABLE', that
     configure the node id and register enables, respectively.

  7. Generate addresses for the memory and register spaces. The memory space
     needs 8 kB, the register space needs 40 B (in both cases, larger spaces
     of course work fine too).

  8. Done!  


******************************************
* Usage, SDK
******************************************
  1. Make sure that SDK is using the TosNet driver for the TosNet component.

  2. Initialize a TosNet structure.

  3. Use the API described in 'tosnet.h' to access the TosNet component.


******************************************
* Important notes
******************************************
  The MicroBlaze peripheral uses the exact same source files as the standard
  TosNet component. This also goes for the BlockRAM and FIFO cores. The cores
  delivered with the peripheral are created for the xc6slx16,csg234 device.

  If you need to use the peripheral with other devices, you may have to
  recreate the cores, using the settings described in the readme in the
  'pcores\tosnet_v3_20_a\netlist' folder.
  

******************************************
* End of file
******************************************
