//===========================================================================
// $Id: pci_blue_constants.vh,v 1.1 2002-02-01 13:39:43 mihad Exp $
//
// Copyright 2001 Blue Beaver.  All Rights Reserved.
//
// Summary:  Constants used throughout the pci_blue_interface.  Some of these
//           constants will be used in the Host Interface, so will be known
//           by the user of this IP.  These constants are not expected to
//           change from design to design.
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
//===========================================================================

// define the PCI BUS Command Values so that they can be referred to symbolically
  parameter PCI_COMMAND_INTERRUPT_ACKNOWLEDGE   = 4'b0000;
  parameter PCI_COMMAND_SPECIAL_CYCLE           = 4'b0001;
  parameter PCI_COMMAND_IO_READ                 = 4'b0010;
  parameter PCI_COMMAND_IO_WRITE                = 4'b0011;
  parameter PCI_COMMAND_RESERVED_READ_4         = 4'b0100;
  parameter PCI_COMMAND_RESERVED_WRITE_5        = 4'b0101;
  parameter PCI_COMMAND_MEMORY_READ             = 4'b0110;
  parameter PCI_COMMAND_MEMORY_WRITE            = 4'b0111;
  parameter PCI_COMMAND_RESERVED_READ_8         = 4'b1000;
  parameter PCI_COMMAND_RESERVED_WRITE_9        = 4'b1001;
  parameter PCI_COMMAND_CONFIG_READ             = 4'b1010;
  parameter PCI_COMMAND_CONFIG_WRITE            = 4'b1011;
  parameter PCI_COMMAND_MEMORY_READ_MULTIPLE    = 4'b1100;
  parameter PCI_COMMAND_DUAL_ADDRESS_CYCLE      = 4'b1101;
  parameter PCI_COMMAND_MEMORY_READ_LINE        = 4'b1110;
  parameter PCI_COMMAND_MEMORY_WRITE_INVALIDATE = 4'b1111;
  parameter PCI_COMMAND_ANY_WRITE_MASK          = 4'b0001;


// Config Register Area consists of:
//    31  24 23  16 15   8  7   0
//   |  Device ID  |  Vendor ID  | 0x00
//   |   Status    |   Command   | 0x04
//   |       Class Code   | Rev  | 0x08
//   | BIST | HEAD | LTCY | CSize| 0x0A
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
// Command resets to 0 or maybe 0x80.  It consists of:
// {6'h00, FB2B_En, SERR_En,
//  Step_En, Par_Err_En, VGA_En, Mem_Write_Inv_En,
//  Special_En, Master_En, Target_En, IO_En}
//
// Status consists of:
// {Detected_Perr, Signaled_Serr, Got_Master_Abort, Got_Target_Abort,
//  Signaled_Target_Abort, Devsel_Timing[1:0], Master_Got_Perr,
//  FB2B_Capable, 1'b0, 66MHz_Capable, New_Capabilities,
//  4'h0}
//
// Got_Master_Abort is not set for Special Cycles.
// Devsel_Timing will be 2'h01 in this design.  New_Capabilities is 1'b0.
// All clearable bits in this register are cleared whenever the
//   register is written with the corresponding bit being 1'b1.
// See the PCI Local Bus Spec Revision 2.2 section 6.2.3.
  parameter  CONFIG_CMD_FB2B_EN             = 32'h00000200;
  parameter  CONFIG_CMD_SERR_EN             = 32'h00000100;
  parameter  CONFIG_CMD_PAR_ERR_EN          = 32'h00000040;
  parameter  CONFIG_CMD_MASTER_EN           = 32'h00000004;
  parameter  CONFIG_CMD_TARGET_EN           = 32'h00000002;

  parameter  CONFIG_STAT_DETECTED_PERR      = 32'h80000000;
  parameter  CONFIG_STAT_DETECTED_SERR      = 32'h40000000;
  parameter  CONFIG_STAT_GOT_MABORT         = 32'h20000000;
  parameter  CONFIG_STAT_GOT_TABORT         = 32'h10000000;
  parameter  CONFIG_STAT_CAUSED_TABORT      = 32'h08000000;
  parameter  CONFIG_STAT_CAUSED_PERR        = 32'h01000000;
  parameter  CONFIG_STAT_CLEAR_ALL          = 32'hF9000000;

  parameter  CONFIG_REG_CMD_STAT_CONSTANTS  = 32'h02A00080;


// The Host sends Requests over the Host Request Bus to initiate PCI activity.
//   The Host Interface is required to send Requests in this order:
//   Address, optionally several Data's, Data_Last.  Sequences of Address-Address,
//   Data-Address, Data_Last-Data, or Data_Last-Data_Last are all illegal.
// First, the Request which indicates that nothing should be put in the FIFO.
  parameter PCI_HOST_REQUEST_SPARE                           = 3'h0;
// Second, a Request used during Delayed Reads to mark the Write Command FIFO empty.
// This Request must be issued with Data Bits 16 and 17 both set to 1'b0.
  parameter PCI_HOST_REQUEST_INSERT_WRITE_FENCE              = 3'h1;
// Third, a Request used to read and write the local PCI Controller's Config Registers.
// This Request shares it's tags with the WRITE_FENCE Command.  Config References
//   can be identified by noticing that Bits 16 or 17 are non-zero.
// Data Bits [7:0] are the Byte Address of the Config Register being accessed.
// Data Bits [15:8] are the single-byte Write Data used in writing the Config Register.
// Data Bit  [16] indicates that a Config Write should be done.
// Data Bit  [17] indicates that a Config Read should be done.
// Data Bits [20:18] are used to select individual function register sets in the
//   case that a multi-function PCI interface is created.
// This Request must be issued with either Data Bits 16 or 17 set to 1'b1.
// `define PCI_HOST_REQUEST_READ_WRITE_CONFIG_REGISTER   (3'h1)
// Fourth, the Requests which start a Read or a Write.  Writes can be started
//   before previous Writes complete, but only one Read can be issued at a time.
  parameter PCI_HOST_REQUEST_ADDRESS_COMMAND                 = 3'h2;
  parameter PCI_HOST_REQUEST_ADDRESS_COMMAND_SERR            = 3'h3;
// Fifth, Requests saying Write Data, Read or Write Byte Masks, and End Burst.
  parameter PCI_HOST_REQUEST_W_DATA_RW_MASK                  = 3'h4;
  parameter PCI_HOST_REQUEST_W_DATA_RW_MASK_PERR             = 3'h5;
  parameter PCI_HOST_REQUEST_W_DATA_RW_MASK_LAST             = 3'h6;
  parameter PCI_HOST_REQUEST_W_DATA_RW_MASK_LAST_PERR        = 3'h7;
// These Address and Data Requests always are acknowledged by either a Master Abort,
//   a Target Abort, or a Status Data Last.  Each data item which is delivered over
//   the PCI Bus gets acknowledged by the PCI interface, and each data item not used
//   gets flushed silently after the Master Abort or Target Abort is announced.


// Responses the PCI Controller sends over the Host Response Bus to indicate that
//   progress has been made on transfers initiated over the Request Bus by the Host.
// First, the Response which indicates that nothing should be put in the FIFO.
  parameter PCI_HOST_RESPONSE_SPARE                          = 4'h0;
// Second, a Response saying when the Write Fence has been disposed of.  After this
//   is received, and the Delayed Read done, it is OK to queue more Write Requests.
// This command will be returned in response to a Request issued with Data
//   Bits 16 and 17 both set to 1'b0.
  parameter PCI_HOST_RESPONSE_UNLOADING_WRITE_FENCE          = 4'h1;
// Third, a Response repeating the Host Request the PCI Bus is presently servicing.
  parameter PCI_HOST_RESPONSE_EXECUTED_ADDRESS_COMMAND       = 4'h2;
// Fourth, a Response which gives commentary about what is happening on the PCI bus.
// These bits follow the layout of the PCI Config Register Status Half-word.
// When this Response is received, bits in the data field indicate the following:
// Bit 31: PERR Detected (sent if a Parity Error occurred on the Last Data Phase)
// Bit 30: SERR Detected
// Bit 29: Master Abort received
// Bit 28: Target Abort received
// Bit 27: Caused Target Abort
// Bit 24: Caused PERR
// Bit 19: Data Flushed by Master due to Master Abort or Target Abort
// Bit 18: Discarded a Delayed Read due to timeout
// Bit 17: Target Retry or Disconnect (document that a Master Retry is requested)
// Bit 16: Got Illegal sequence of commands over Host Request Bus.
  parameter PCI_HOST_RESPONSE_REPORT_SERR_PERR_M_T_ABORT     = 4'h3;
// Fifth, a Response used to read and write the local PCI Controller's Config Registers.
// This Response shares it's tags with the WRITE_FENCE Command.  Config References
//   can be identified by noticing that Bits 16 or 17 are non-zero.
// Data Bits [7:0] are the Byte Address of the Config Register being accessed.
// Data Bits [15:8] are the single-byte Read Data returned when writing the Config Register.
// Data Bit  [16] indicates that a Config Write has been done.
// Data Bit  [17] indicates that a Config Read has been done.
// This Response will be issued with either Data Bits 16 or 17 set to 1'b1.
// parameter PCI_HOST_RESPONSE_READ_WRITE_CONFIG_REGISTER    = 4'h3;
// Sixth, Responses indicating that Write Data was delivered, Read Data is available,
//   End Of Burst, and that a Parity Error occurred the previous data cycle.
// NOTE:  If a Master or Target Abort happens, the contents of the Request
//   FIFO will be flushed until the DATA_LAST is removed.  The Response FIFO
//   will have a FLUSH entry for each data item flushed by the Master.
  parameter PCI_HOST_RESPONSE_R_DATA_W_SENT                  = 4'h4;
  parameter PCI_HOST_RESPONSE_R_DATA_W_SENT_PERR             = 4'h6;
  parameter PCI_HOST_RESPONSE_R_DATA_W_SENT_LAST             = 4'h5;
  parameter PCI_HOST_RESPONSE_R_DATA_W_SENT_LAST_PERR        = 4'h7;


// Responses the PCI Controller sends over the Host Response Bus to indicate
//   that an external PCI Master has started a reference.
// The PCI Controller will do a Target Disconnect on each data phase of a Read
//   in which the Byte Strobes command less than a full 4-byte read.
// First, the Response which indicates that a Delayed Read must be restarted
//   because a Write by an external PCI Master overlapped the read window.
  parameter PCI_HOST_RESPONSE_EXT_DELAYED_READ_RESTART       = 4'h8;
// Second, the Response which says that all Writes are finished, and the
//   Delayed Read is finally being serviced on the PCI Bus.
  parameter PCI_HOST_RESPONSE_EXT_READ_UNSUSPENDING          = 4'h9;
// Third, the Responses which indicate that an External PCI Master has requested
//   a Read or a Write, depending on the Command.
  parameter PCI_HOST_RESPONSE_EXTERNAL_ADDRESS_COMMAND_READ_WRITE = 4'hA;
  parameter PCI_HOST_RESPONSE_EXTERNAL_ADDRESS_COMMAND_READ_WRITE_SERR = 4'hB;
// Fourth, the Responses saying Write Data, Read or Write Byte Masks, and End Burst.
  parameter PCI_HOST_RESPONSE_EXT_W_DATA_RW_MASK             = 4'hC;
  parameter PCI_HOST_RESPONSE_EXT_W_DATA_RW_MASK_PERR        = 4'hD;
  parameter PCI_HOST_RESPONSE_EXT_W_DATA_RW_MASK_LAST        = 4'hE;
  parameter PCI_HOST_RESPONSE_EXT_W_DATA_RW_MASK_LAST_PERR   = 4'hF;


// Writes from an External PCI Master can be completed immediately based on
//   information available on the Host Response Bus.
// Reads from an External PCI Master need to be completed in several steps.
// First, the Address, Command, and one word containing a Read Mask are received.
// Second, upon receiving a Response indicating that Read is being started, the Host
//   controller must either issue a Write Fence onto the Host Request Bus.
// Third the Host Controller must start putting Read Data into the Delayed_Read_Data
//   FIFO.  The Host Controller can indicate End Of Burst or Target Abort there too.
// The Host Controller must continue to service Write Requests while the Delayed Read
//   is being acted on.   See the PCI Local Bus Spec Revision 2.2 section 3.3.3.3.4
// If Bus Writes are done while the Delayed Read Data is being fetched, the PCI
//   Bus Interface will watch to see if any writes overlap the Read address region.
//   If a Write overlaps the Read address region, the PCI Interface will ask that the
//   Read be re-issued.  The PCI Interface will also start flushing data out of
//   the Delayed_Read_Data FIFO until a DATA_LAST entry is found.  The Host Intrface
//   is REQUIRED to put one DATA_LAST or TARGET_ABORT entry into the Delayed_Read_Data
//   FIFO after being instructed to reissue a Delayed Read.  All data up to and
//   including that last entry will be flushed, and data following that point will
//   be waited for to satisfy the Delayed Read Request.
// Tags the Host Controller sends across the Delayed_Read_Data FIFO to indicate
//   progress made on transfers initiated by the external PCI Bus Master.
  parameter PCI_HOST_DELAYED_READ_DATA_SPARE           = 3'b000;
  parameter PCI_HOST_DELAYED_READ_DATA_TARGET_ABORT    = 3'b001;
  parameter PCI_HOST_DELAYED_READ_DATA_SPARE_2         = 3'b010;
  parameter PCI_HOST_DELAYED_READ_DATA_FAST_RETRY      = 3'b011;
  parameter PCI_HOST_DELAYED_READ_DATA_VALID           = 3'b100;
  parameter PCI_HOST_DELAYED_READ_DATA_VALID_PERR      = 3'b101;
  parameter PCI_HOST_DELAYED_READ_DATA_VALID_LAST      = 3'b110;
  parameter PCI_HOST_DELAYED_READ_DATA_VALID_LAST_PERR = 3'b111;


// Macros which are used as paramaters in the Test Device code
// The Test Device behaves in different ways depending on the Address it is responding to.
// Select master
`define Test_Master_0                          (3'h0)
`define Test_Master_1                          (3'h1)
`define Test_Master_2                          (3'h2)
`define Test_Master_3                          (3'h3)
`define Test_Master_Real                       (3'h7)

// Byte Masks
`define Test_Byte_0                            (4'b1110)
`define Test_Byte_1                            (4'b1101)
`define Test_Byte_2                            (4'b1011)
`define Test_Byte_3                            (4'b0111)
`define Test_Half_0                            (4'b1100)
`define Test_Half_1                            (4'b0011)
`define Test_All_Bytes                         (4'b0000)

// Document that a retry is due to a pending Delayed Read.  Master transfers 1 word.
`define Test_Expect_Delayed_Read_Retry         (4'h0)
// Sizeof the transfer from the Master perspective
`define Test_One_Word                          (4'h1)
`define Test_Two_Words                         (4'h2)
`define Test_Three_Words                       (4'h3)
`define Test_Four_Words                        (4'h4)
`define Test_Eight_Words                       (4'h8)

// Address Parity Error
`define Test_No_Addr_Perr                      (1'b0)
`define Test_Addr_Perr                         (1'b1)

// Data Parity Error
`define Test_No_Data_Perr                      (1'b0)
`define Test_Data_Perr                         (1'b1)

// Master Wait States {[7:4] wait before first data, [3:0] wait between subsequent{
`define Test_No_Master_WS                      (8'h00)
`define Test_One_Master_WS                     (8'h11)
	// #####################################
	// ADDED on 20.11.2001 by Tadej Markovic
`define Test_One_Zero_Master_WS					(8'h10)
	// #####################################

// Target Wait States {[7:4] wait before first data, [3:0] wait between subsequent}
`define Test_No_Target_WS                      (8'h00)
`define Test_One_Target_WS                     (8'h11)
	// #####################################
	// ADDED on 20.11.2001 by Tadej Markovic
`define Test_One_Zero_Target_WS					(8'h10)
	// #####################################

// Target Devsel Speed
`define Test_Devsel_Fast                       (2'b00)
`define Test_Devsel_Medium                     (2'b01)
`define Test_Devsel_Slow                       (2'b10)
`define Test_Devsel_Subtractive                (2'b11)

// enable/disable fast back-to-back (until done in controller)
`define Test_No_Fast_B2B                       (1'b0)
`define Test_Fast_B2B                          (1'b1)

// Target Disconnect:
//   None, Before First Data, With First Data,
//   Before Second Data, With Second Data
`define Test_Target_Normal_Completion          (3'h0)
`define Test_Target_Retry_Before_First         (3'h1)
`define Test_Target_Retry_Before               (3'h1)
`define Test_Target_Disc_With_First            (3'h2)
`define Test_Target_Disc_With                  (3'h2)
`define Test_Target_Disc_Before                (3'h2)
`define Test_Target_Retry_Before_Second        (3'h3)
`define Test_Target_Retry_On                   (3'h3)
`define Test_Target_Disc_With_Second           (3'h4)
`define Test_Target_Disc_On                    (3'h4)

// Make a Target Retry while starting a Delayed Read
`define Test_Target_Start_Delayed_Read         (3'h5)

// Target Abort: Before First Data, Before Second Data
`define Test_Target_Abort_Before_First         (3'h6)
`define Test_Target_Abort_Before_Second        (3'h7)
`define Test_Target_Abort                      (3'h7)
`define Test_Target_Abort_Before               (3'h7)
`define Test_Target_Abort_On                   (3'h6)

// Expect Master Abort
`define Test_Expect_No_Master_Abort            (1'b0)
`define Test_Expect_Master_Abort               (1'b1)

// The following defines are used to encode the previous paramaters from
//   the Master to the Target over the PCI Address Bus during testbench references
/*
// changed by miha dolenc - added input for target response to device and target models!
*/
`define TARGET_ENCODED_TERMINATE_ON            24:15
`define TARGET_ENCODED_PARAMATERS_ENABLE       25
`define TARGET_ENCODED_INIT_WAITSTATES         14:11
`define TARGET_ENCODED_SUBS_WAITSTATES         10:7
`define TARGET_ENCODED_TERMINATION             6:4
`define TARGET_ENCODED_DEVSEL_SPEED            3:2
`define TARGET_ENCODED_DATA_PAR_ERR            1
`define TARGET_ENCODED_ADDR_PAR_ERR            0


// Value on the AD bus when the bus is Parked, in a wait state, or undriven
`define BUS_PARK_VALUE                         (32'hA5A5A5A5)
`define BUS_WAIT_STATE_VALUE                   (32'h2BAD2BAD)
`define BUS_IMPOSSIBLE_VALUE                   (32'hDEADBEAF)

// variables used for debugging and development.  These have easy-to-find names
`define DEBUG_TRUE                             (1'b1)
`define DEBUG_FALSE                            (1'b0)

// macro used for documentation purposes when an "if" really should have no "else"
`define NO_ELSE                                else

// macro used for documentation purposes when an "case" really should have no "default"
`define NO_DEFAULT                             default



