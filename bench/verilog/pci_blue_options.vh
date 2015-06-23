//===========================================================================
// $Id: pci_blue_options.vh,v 1.3 2003-08-03 18:04:44 mihad Exp $
//
// Copyright 2001 Blue Beaver.  All Rights Reserved.
//
// Summary:  Constants which select various configuration options used
//           throughout the pci_blue_interface.  The user will have to
//           make several choices to select these options for each
//           particular use of this IP.
//
// This library is free software; you can distribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, write to
// Free Software Foundation, Inc.
// 59 Temple Place, Suite 330
// Boston, MA 02111-1307 USA
//
// Author's note about this license:  The intention of the Author and of
// the Gnu Lesser General Public License is that users should be able to
// use this code for any purpose, including combining it with other source
// code, combining it with other logic, translated it into a gate-level
// representation, or projected it into gates in a programmable or
// hardwired chip, as long as the users of the resulting source, compiled
// source, or chip are given the means to get a copy of this source code
// with no new restrictions on redistribution of this source.
//
// If you make changes, even substantial changes, to this code, or use
// substantial parts of this code as an inseparable part of another work
// of authorship, the users of the resulting IP must be given the means
// to get a copy of the modified or combined source code, with no new
// restrictions on redistribution of the resulting source.
//
// Seperate parts of the combined source code, compiled code, or chip,
// which are NOT derived from this source code do NOT need to be offered
// to the final user of the chip merely because they are used in
// combination with this code.  Other code is not forced to fall under
// the GNU Lesser General Public License when it is linked to this code.
// The license terms of other source code linked to this code might require
// that it NOT be made available to users.  The GNU Lesser General Public
// License does not prevent this code from being used in such a situation,
// as long as the user of the resulting IP is given the means to get a
// copy of this component of the IP with no new restrictions on
// redistribution of this source.
//
// This code was developed using VeriLogger Pro, by Synapticad.
// Their support is greatly appreciated.
//
// NOTE:  This code has only been tested and might be functional with the
//          following set of options:
//
//===========================================================================

// Include to cause the Monitor Device to report activity.
//`define VERBOSE_MONITOR_DEVICE

// define this to get the PCI model to do normal consistency checking
// undefine this if simulation speed is more important than correctness.
`define NORMAL_PCI_CHECKS

// define this to get the monitor to create a PCI Bus Activity Transcript
`define MONITOR_CREATE_BUS_ACTIVITY_TRANSCRIPT

// define to cause the Test Device to report top-level activity.
`define REPORT_TEST_DEVICE

// define in addition to the above to cause the Test Device to
// report detailed activity.
//`define VERBOSE_TEST_DEVICE

// Indicate whether the PCI Bus will be 64-bit or 32-bit
// Comment this out if the bus size is 32 bits
// `define PCI_BUS_SIZE_64

// Indicate whether the PCI Blue Interface FIFOs are 64-bit or 32-bit
// Comment this out of the FIFO size is 32 bits
// `define PCI_FIFO_SIZE_64

// Indicate whether the intended application is 33 MHz or 66 MHz.
// If 33 MHz is desired, simply comment out the define line.
//`define PCI_CLK_66

// These are the delays that the PCI Pad Drivers in the Test verilog exhibit.
// They delays are from the PCI Local Bus Spec Revision 2.2 section 7.6.4.2
`ifdef PCI_CLK_66
`define PCI_CLK_PERIOD                         15.0
`define PAD_MIN_DATA_DLY                        2.0
`define PAD_MAX_DATA_DLY                        6.0
`define PAD_MIN_OE_DLY                          2.0
`define PAD_MAX_OE_DLY                         14.0
`define PAD_DATA_SETUP                          3.0
`define PAD_DATA_HOLD                           0.0
`define PROP_PLUS_SKEW                          6.0
`else  // PCI_CLK_66
`define PCI_CLK_PERIOD                         30.0
`define PAD_MIN_DATA_DLY                        2.0
`define PAD_MAX_DATA_DLY                       11.0
`define PAD_MIN_OE_DLY                          2.0
`define PAD_MAX_OE_DLY                         11.0
`define PAD_DATA_SETUP                          7.0
`define PAD_DATA_HOLD                           0.0
`define PROP_PLUS_SKEW                         12.0
`endif  // PCI_CLK_66

// Derive Bus Definitions based on declared interface sizes
// The FIFOs and the PCI Bus are the same width.
`ifdef PCI_BUS_SIZE_64
  parameter PCI_BUS_DATA_RANGE  = 63;
`define PCI_BUS_DATA_X            64'hXXXXXXXX_XXXXXXXX
`define PCI_BUS_DATA_Z            64'hZZZZZZZZ_ZZZZZZZZ
`define PCI_BUS_DATA_ZERO         64'h00000000_00000000
  parameter PCI_BUS_CBE_RANGE   =  7;
`define PCI_BUS_CBE_X              8'hXX
`define PCI_BUS_CBE_Z              8'hZZ
`define PCI_BUS_CBE_ZERO           8'h00
`define PCI_BUS_Address_Mask      64'hFFFFFFFF_FFFFFFF8
`define PCI_BUS_Address_Step      64'h00000000_00000008
`else  // PCI_BUS_SIZE_64
  parameter PCI_BUS_DATA_RANGE  = 31;
`define PCI_BUS_DATA_X            32'hXXXXXXXX
`define PCI_BUS_DATA_Z            32'hZZZZZZZZ
`define PCI_BUS_DATA_ZERO         32'h00000000
  parameter PCI_BUS_CBE_RANGE   =  3;
`define PCI_BUS_CBE_X              4'hX
`define PCI_BUS_CBE_Z              4'hZ
`define PCI_BUS_CBE_ZERO           4'h0
`define PCI_BUS_CBE_F              4'hF
`define PCI_BUS_Address_Mask      32'hFFFFFFFC
`define PCI_BUS_Address_Step      32'h00000004
`endif  // PCI_BUS_SIZE_64

// Define SIMULTANEOUS_MASTER_TARGET if a single interface needs
//   do master references to it's own target interface.
// Also define SIMULTANEOUS_MASTER_TARGET if there will be several
//   PCI interfaces sharing a single set of IO pads.
// See the PCI Local Bus Spec Revision 2.2 section 3.10 item 9.
// Do NOT need to be defined if there is only a single PCI
//   interface or a single multi-function PCI interface on-chip
//   which never talks from it's master to it's target.  This
//   paramater makes it harder to meet PCI timing, and makes it
//   impossible to use the nice Xilinx IO pads.
// NOTE: NOT DEBUGGED.  MAYBE SHOULD BE DONE ABOVE IO PADS
`define SIMULTANEOUS_MASTER_TARGET

// Define SUPPORT_MULTIPLE_ONCHIP_INTERFACES if several totally
//   independent PCI interfaces will exist on-chip which will take
//   turns using a single set of IO pads.  When this option is selected,
//   it is necessary to also define SIMULTANEOUS_MASTER_TARGET.  The
//   interface assumes that one master may want to talk to another target.
// `define SUPPORT_MULTIPLE_ONCHIP_INTERFACES


// The PCI Controller communicates with the Host Controller bu sending
//   and receiving data through 3 FIFOs.  These FIFOs are all the same depth,
//   set here.  Allowable depths are 3 entries, 5 entries, 7 entries, and
//   15 entries.  Only one define should be uncommented to choose the size.
// `define HOST_FIFO_DEPTH_3
 `define HOST_FIFO_DEPTH_5
// `define HOST_FIFO_DEPTH_7
// `define HOST_FIFO_DEPTH_15

// The user also gets to specify here whether the FIFOs are made out of
//   individual Flip-Flops, or whether they use a vendor-supplied Dual Port
//   SRAM primitive.
// If the FIFOs are 15 entries deep, the FIFOs MUST be made out of SRAMs.
`define HOST_FIFOS_ARE_MADE_FROM_FLOPS

// Events made in the PCI Interface are synchronized into the Host clock domain.
// Synchronizer Flops are prone to metastability, and these Flops are no exception.
// In order to cross between clock domains, signals must be latched and then have
//   enough time to settle to a safe value.
// This interface assumes that the Host Clock is significantly faster than the
//   PCI Clock.  It is possible that the Host Clock is SO FAST that it is
//   difficult to sychronize a PCI Signal and have it settle to a safe value
//   in 1 Host clock period.
// This interface tries to assure that the control information has plenty of
//   time to settle by having special constraints on the signals which cross
//   the clock barrier.  The target is to have the clock-to-data, plus the
//   delay through any following combinational logic, plus the setup to
//   the next flops, together add up to AT LEAST 2 nSec less than the Host
//   clock period.
// If the Synchronizers will need more than 1 clock to settle, then the
//   interface has to be compiled with DOUBLE_SYNC_PCI_HOST_SYNCHRONIZERS
//   defined to have the value 1'b1.
// If the Synchronizers have enough time to settle, define it to 1'b0
`define DOUBLE_SYNC_PCI_HOST_SYNCHRONIZERS     (1'b0)

// Defines to connect up specific AD lines to IDSEL inputs.  Note that
//   the only valid address lines are AD[31:25], because the lower
//   addresses down through AD11 are used to tell the target how to behave.
`define NO_DEVICE_IDSEL_ADDR                   (32'h00000000)
`define REAL_DEVICE_IDSEL_INDEX                24				// NOT used,see SYSTEM.V file
`define REAL_DEVICE_CONFIG_ADDR                (32'h01000000)	// NOT used,see SYSTEM.V file
`define TEST_DEVICE_0_IDSEL_INDEX              25				// NOT used,see SYSTEM.V file
`define TEST_DEVICE_0_CONFIG_ADDR              (32'h02000000)	// NOT used,see SYSTEM.V file
`define TEST_DEVICE_1_IDSEL_INDEX              26				// NOT used,see SYSTEM.V file
`define TEST_DEVICE_1_CONFIG_ADDR              (32'h04000000)	// NOT used,see SYSTEM.V file


// Config Register Area consists of:
//    31  24 23  16 15   8  7   0
//   |  Device ID  |  Vendor ID  | 0x00
//   |   Status    |   Command   | 0x04
//   |       Class Code   | Rev  | 0x08
//   | BIST | HEAD | LTCY | CSize| 0x0C
//   |      Base Address 0       | 0x10
//   |      Base Address 1       | 0x14
//   |          Unused           | 0x18
//   |          Unused           | 0x1C
//   |          Unused           | 0x20
//   |          Unused           | 0x24
//   |      Cardbus Pointer      | 0x28
//   |  SubSys ID  |  SubVnd ID  | 0x2C
//   |   Expansion ROM Pointer   | 0x30
//   |    Reserved        | Cap  | 0x34
//   |          Reserved         | 0x38
//   | MLat | MGnt | IPin | ILine| 0x3C
//

// Device ID's are allocated by a particular Vendor.
// See the PCI Local Bus Spec Revision 2.2 section 6.2.1.
  parameter PCI_DEVICE_ID                         = 16'h1234;
// Vendor Types are allocated by the PCI SIG.
// See the PCI Local Bus Spec Revision 2.2 section 6.2.1.
  parameter PCI_VENDOR_ID                         = 16'h5678;
// Header Type says Normal, Single Function.
// See the PCI Local Bus Spec Revision 2.2 Appendix D.
  parameter PCI_CLASS_CODE                        = 24'hFF_00_00;
// Revision Numbers are allocated by a particular Vendor.
// See the PCI Local Bus Spec Revision 2.2 section 6.2.1.
  parameter PCI_REV_NUM                           = 8'h00;
// Header Type says Normal, Single Function.
// See the PCI Local Bus Spec Revision 2.2 section 6.2.1.
  parameter PCI_HEAD_TYPE                         = 8'h00;
// Minimum Grane and Maximum Latency need to be set based
// on the expected activity of the device.  The unit of
// time is 1/4th uSeconds.
// See the PCI Local Bus Spec Revision 2.2 section 6.2.4.
  parameter PCI_MIN_GRANT                         = 8'h01;
  parameter PCI_MAX_LATENCY                       = 8'h0C;

// The code to support multiple Base Address Registers is in pci_blue_target.v
// Match as few bits as needed.  This example maps 16 MBytes.
`define PCI_BASE_ADDR0_MATCH_RANGE             31:20
`define PCI_BASE_ADDR0_ALL_ZEROS               8'h00
// Match plus Fill plus Qual must together be 32 bits
`define PCI_BASE_ADDR0_FILL                    (16'h0000)
// Address Map Qualifier, described in the PCI specification,
// Revision 2.2, section 6.2.5.1.  The value 0x8 indicates
//   that the Base Address size is 32 bits, that it is a Memory
//   mapped Base Address Register, and that data is pre-fetchable
`define PCI_BASE_ADDR0_MAP_QUAL                (4'h8 )

// Undefine if a second Base Register is not needed
`define PCI_BASE_ADDR1_MATCH_ENABLE

`ifdef PCI_BASE_ADDR1_MATCH_ENABLE
// Match as few bits as needed.  This example maps 32 MBytes.
`define PCI_BASE_ADDR1_MATCH_RANGE             31:20
`define PCI_BASE_ADDR1_ALL_ZEROS               7'h00
// Match plus Fill plus Qual must together be 32 bits
`define PCI_BASE_ADDR1_FILL                    (16'h0000)
// Address Map Qualifier, described in the PCI specification,
// Revision 2.2, section 6.2.5.1.  The value 0x1 indicates
//   that the Base Address size is 32 bits, that it is a IO
//   mapped Base Address Register
`define PCI_BASE_ADDR1_MAP_QUAL                (4'h1)
`endif  // PCI_BASE_ADDR1_MATCH_ENABLE

// nothing checked after this point

// PCI_CONFIG_MASTER is defined if this PCI Code is going to be the root
//   of the PCI bus during the configuration process.
// The result of this define is that an internal wire will be used as the
//   IDSEL wire.  If this verilog is configured to not be the PCI Config
//   Master, an external IO Pin will be allocated to serve as the IDSEL pin.
// In both cases, several values in the Config Data block will need to be
//   initialized before the interface can be initialized for use in a PCI
//   environment.  The variables TODO help set up the Config Data.
// `define PCI_CONFIG_MASTER    1

// PCI_MASTER is defined if this code is going to serve as a PCI Master as
//   well as a PCI Slave.
// The result of this define is that a pair of signals used for Request and
//   Grant will be made available.  If the interface is designalted the PCI
//   Config Master, these two signals will be internal signals.  Otherwise
//   they will go to external IO pads.
// `define PCI_MASTER           1

// define?

// `define PCI_EXTERNAL_IDSEL      1  // define if IDSEL wire driven from offchip
`define PCI_EXTERNAL_MASTER     1  // define if off-chip PCI arbiter to be used
// `define PCI_EXTERNAL_INT        1
// `define PCI_EXTERNAL_CLOCK      1
// `define PCI_MASTER              1

// The Host_Command Fifo and the Host_Reply Fifo have entries which
//   contain addresses or data.  In addition, each entry contains a
//   tag which explains the meaning of the entry.


