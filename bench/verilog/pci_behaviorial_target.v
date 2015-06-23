//===========================================================================
// $Id: pci_behaviorial_target.v,v 1.5 2003-08-03 18:04:44 mihad Exp $
//
// Copyright 2001 Blue Beaver.  All Rights Reserved.
//
// Summary:  A PCI Behaviorial Target.  This module receives commands over
//           the PCI Bus.  The PCI Master encodes commands in the middle
//           16 bits of the PCI Address.  This Target contains Config
//           registers and a 256 byte scratch SRAM.  It responds with data
//           when it is given a Read command, and checks data when it is
//           given a Write command.
//           This interface does implement a very simple Delayed Read
//           facility which is enough to let the user manually make the
//           PCI Bus look like a Delayed Read is begin done.  This will
//           probably not work when a synthesizable PCI Interface tries
//           to cause Delayed Reads.  But by then, a second synthesizable
//           PCI Core will be the more useful test target.
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
// Separate parts of the combined source code, compiled code, or chip,
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
// NOTE:  This Test Chip instantiates one PCI interface and connects it
//        to its IO pads and to logic representing a real application.
//
// NOTE TODO: Horrible.  Tasks can't depend on their Arguments being safe
//        if there are several instances ofthe tasl running at once.
// NOTE TODO: need to check parity on writes, and report if error status wrong
// NOTE TODO: need to drive PERR and SERR lines
// NOTE TODO: need to start setting error bits in Config Register
// Need to detect Address Parity Errors, and report them  3.7.3
// Need to allow bad parity address decodes if Parity Error Response not set 3.7.3
// Need to act on Delayed Read commands
// Need to do retries on other READ commands when delayed read in progress
// Need to clear delayed read in progress bit when Config Register says to
// Need to consider holding PERR if asserted without regards to TRDY and IRDY
//   See 3.7.4.1 for details.  If done as now, no need to hold.
// Need to assert SERR on address parity errors  3.7.4.2
// Need to record errors.  3.7.4.3, 3.7.4.4
// Complain if address parity error not seen when expected
// Complain if data parity error not seen when expected
//
//===========================================================================

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module pci_behaviorial_target (
  ad_now, ad_prev, target_ad_out, target_ad_oe,
  cbe_l_now, cbe_l_prev, calc_input_parity_prev, par_now, par_prev,
  frame_now, frame_prev, irdy_now, irdy_prev,
  target_devsel_out, target_d_t_s_oe, target_trdy_out, target_stop_out,
  target_perr_out, target_perr_oe, target_serr_oe,
  idsel_now, idsel_prev,
  pci_reset_comb, pci_ext_clk,
// Signals from the master to the target to set bits in the Status Register
  master_got_parity_error, master_asserted_serr, master_got_master_abort,
  master_got_target_abort, master_caused_parity_error,
  master_enable, master_fast_b2b_en, master_perr_enable, master_serr_enable,
  master_latency_value,
// Signals used by the test bench instead of using "." notation
  target_debug_force_bad_par,
  test_error_event, test_device_id,
  test_response
);

`include "pci_blue_options.vh"
`include "pci_blue_constants.vh"

  input  [PCI_BUS_DATA_RANGE:0] ad_now;
  input  [PCI_BUS_DATA_RANGE:0] ad_prev;
  output [PCI_BUS_DATA_RANGE:0] target_ad_out;
  output  target_ad_oe;
  input  [PCI_BUS_CBE_RANGE:0] cbe_l_now;
  input  [PCI_BUS_CBE_RANGE:0] cbe_l_prev;
  input   calc_input_parity_prev;
  input   par_now, par_prev;
  input   frame_now, frame_prev, irdy_now, irdy_prev;
  output  target_devsel_out, target_d_t_s_oe, target_trdy_out, target_stop_out;
  output  target_perr_out, target_perr_oe, target_serr_oe;
  input   idsel_now, idsel_prev;
  input   pci_reset_comb, pci_ext_clk;
// Signals from the master to the target to set bits in the Status Register
  input   master_got_parity_error, master_asserted_serr, master_got_master_abort;
  input   master_got_target_abort, master_caused_parity_error;
  output  master_enable, master_fast_b2b_en, master_perr_enable, master_serr_enable;
  output [7:0] master_latency_value;
// Signals used by the test bench instead of using "." notation
  output  target_debug_force_bad_par;
  output  test_error_event;
  input  [2:0]  test_device_id;
  input  [25:0] test_response ;

  reg    [PCI_BUS_DATA_RANGE:0] target_ad_out;
  reg     target_ad_oe;
  reg     target_devsel_out, target_trdy_out, target_stop_out;
  wire    target_d_t_s_oe, target_perr_oe;
  reg     target_perr_out, target_serr_oe;
  reg     target_debug_force_bad_par;
  reg     test_error_event;

// Make temporary Bip every time an error is detected
  initial test_error_event <= 1'bZ;
  reg     error_detected;
  initial error_detected <= 1'b0;
  always @(error_detected)
  begin
    test_error_event <= 1'b0;
    #2;
    test_error_event <= 1'bZ;
  end

// Target Interface:
// This will have just enough memory to make debugging exciting.
// It will have 256 Bytes of SRAM.  The memory will be available
// BOTH as Config memory and as regular memory.
// Special regions of the memory will have special characteristics.
// Locations 0, 4, 8, A, 10, and 14 will be implemented as Control
//   registers.
// Locations 18 and 1C will be used for memory debugging (somehow!)
// All other locations will act as simple memory.

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
// Devsel will be 2'h01 in this design.  New_Capabilities is 1'b0.
// All clearable bits in this register are cleared whenever the
//   register is written with the corresponding bit being 1'b1.
// See the PCI Local Bus Spec Revision 2.2 section 6.2.3.

  reg     FB2B_En, SERR_En, Par_Err_En, Master_En, Target_En;
  reg     Detected_PERR, Signaled_SERR, Received_Master_Abort, Received_Target_Abort;
  reg     Signaled_Target_Abort, Master_Caused_PERR;
  reg    [7:0] Latency_Timer;
  reg    [7:0] Cache_Line_Size;
  reg    [7:0] Interrupt_Line;
  reg    [PCI_BUS_DATA_RANGE:0] BAR0;  // Base Address Registers, used to match addresses
`ifdef PCI_BASE_ADDR1_MATCH_ENABLE
  reg    [PCI_BUS_DATA_RANGE:0] BAR1;
`endif  // PCI_BASE_ADDR1_MATCH_ENABLE

  wire   [15:0] Target_Command =
                     {4'b0000,
                      2'b00, FB2B_En, SERR_En,
                      1'b1, Par_Err_En, 2'b00,
                      1'b0, Master_En, Target_En, 1'b0};
`ifdef PCI_CLK_66
  wire   [15:0] Target_Status =
                     {Detected_PERR, Signaled_SERR, Received_Master_Abort,
                                                    Received_Target_Abort,
                      Signaled_Target_Abort, 2'b01, Master_Caused_PERR,
                      1'b1, 1'b0, 1'b1, 1'b0,
                      4'b0000};
`else  // PCI_CLK_66
  wire   [15:0] Target_Status =
                     {Detected_PERR, Signaled_SERR, Received_Master_Abort,
                                                    Received_Target_Abort,
                      Signaled_Target_Abort, 2'b01, Master_Caused_PERR,
                      1'b1, 1'b0, 1'b0, 1'b0,
                      4'b0000};
`endif  // PCI_CLK_66

  assign  master_enable = Master_En;
  assign  master_fast_b2b_en = FB2B_En;
  assign  master_perr_enable = Par_Err_En;
  assign  master_serr_enable = SERR_En;
  assign  master_latency_value[7:0] = Latency_Timer[7:0];

task Read_Test_Device_Config_Regs;
  input  [7:2] reg_number;
  output [PCI_BUS_DATA_RANGE:0] Read_Config_Reg;
  input  [PCI_BUS_CBE_RANGE:0] byte_mask_l ;

  begin  // Addresses except 0, 4, 8, A, 10, 14, 3C all return 0x00
    case (reg_number[7:2])
    6'h00: Read_Config_Reg = 32'h8000AAAA
                           | {13'h0000, test_device_id[2:0], 16'h0000};
    6'h01: Read_Config_Reg = {Target_Status[15:0], Target_Command[15:0]};
    6'h02: Read_Config_Reg = 32'hFF000000;
    6'h03: Read_Config_Reg = {16'h0000, Latency_Timer[7:0], Cache_Line_Size[7:0]};
    6'h04: Read_Config_Reg = {BAR0[`PCI_BASE_ADDR0_MATCH_RANGE],
                              `PCI_BASE_ADDR0_FILL, `PCI_BASE_ADDR0_MAP_QUAL};
`ifdef PCI_BASE_ADDR1_MATCH_ENABLE
    6'h05: Read_Config_Reg = {BAR1[`PCI_BASE_ADDR1_MATCH_RANGE],
                              `PCI_BASE_ADDR1_FILL, `PCI_BASE_ADDR1_MAP_QUAL};
`endif  // PCI_BASE_ADDR1_MATCH_ENABLE
    6'h0F: Read_Config_Reg = {16'h0000, 8'h01, Interrupt_Line[7:0]};
    default: Read_Config_Reg = 32'h00000000;
    endcase

    case(reg_number[7:2])
        6'h00, 6'h01, 6'h02, 6'h03, 6'h04, 6'h0F `ifdef PCI_BASE_ADDR1_MATCH_ENABLE , 6'h05 `endif :
        begin
            if (byte_mask_l[3] !== 1'b0)
                Read_Config_Reg[31:24] = $random ;
            
            if (byte_mask_l[2] !== 1'b0)
                Read_Config_Reg[23:16] = $random ;
            
            if (byte_mask_l[1] !== 1'b0)
                Read_Config_Reg[15:8] = $random ;
            
            if (byte_mask_l[0] !== 1'b0)
                Read_Config_Reg[7:0] = $random ;
        end
    endcase
  end
endtask

// store info away so Config Register code can update register correctly
  reg    [7:2] pending_config_reg_write_address;
  reg    [PCI_BUS_CBE_RANGE:0] pending_config_reg_write_byte_enables;
  reg    [PCI_BUS_DATA_RANGE:0] pending_config_reg_write_data;
  reg     pending_config_write_request;
task Write_Test_Device_Config_Regs;
  input  [7:2] reg_number;
  input  [PCI_BUS_DATA_RANGE:0] data;
  input  [PCI_BUS_CBE_RANGE:0] master_mask_l;
  begin
    if (~pci_reset_comb)
    begin
      pending_config_reg_write_address[7:2] <= reg_number[7:2];
      pending_config_reg_write_byte_enables[PCI_BUS_CBE_RANGE:0] <= master_mask_l[PCI_BUS_CBE_RANGE:0];
      pending_config_reg_write_data[PCI_BUS_DATA_RANGE:0] <= data[PCI_BUS_DATA_RANGE:0];
      pending_config_write_request <= 1'b1;
    end
    `NO_ELSE;
  end
endtask

  wire    target_got_parity_error;
  wire    target_asserted_serr;
  reg     target_signaling_target_abort;

// Make a register transfer style Configuration Register, so it is easier to handle
//   simultaneous updates from the master and the target.
  always @(posedge pci_ext_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
    begin
      FB2B_En <= 1'b0;
      SERR_En <= 1'b0;                Par_Err_En <= 1'b0;
      Master_En <= 1'b0;              Target_En <= 1'b0;
      Detected_PERR <= 1'b0;          Signaled_SERR <= 1'b0;
      Received_Master_Abort <= 1'b0;  Received_Target_Abort <= 1'b0;
      Signaled_Target_Abort <= 1'b0;
      Master_Caused_PERR <= 1'b0;
      Latency_Timer <= 8'h00;         Cache_Line_Size <= 8'h00;
      Interrupt_Line <= 8'h00;
      BAR0 <= {PCI_BUS_DATA_RANGE + 1{1'b0}} ;
`ifdef PCI_BASE_ADDR1_MATCH_ENABLE
      BAR1 <= {PCI_BUS_DATA_RANGE + 1{1'b0}} ;
`endif  // PCI_BASE_ADDR1_MATCH_ENABLE
      pending_config_write_request <= 1'b0;
    end
    else
    begin
      if (pending_config_write_request)
      begin
// Words 0 and 2 are not writable.  Only certain bits in word 1 are writable.
        FB2B_En    <= ((pending_config_reg_write_address[7:2] == 6'h01)
                        & ~pending_config_reg_write_byte_enables[1])
             ? ((pending_config_reg_write_data[PCI_BUS_DATA_RANGE:0] & CONFIG_CMD_FB2B_EN)
                        != `PCI_BUS_DATA_ZERO) : FB2B_En;
        SERR_En    <= ((pending_config_reg_write_address[7:2] == 6'h01)
                        & ~pending_config_reg_write_byte_enables[1])
             ? ((pending_config_reg_write_data[PCI_BUS_DATA_RANGE:0] & CONFIG_CMD_SERR_EN)
                        != `PCI_BUS_DATA_ZERO) : SERR_En;
        Par_Err_En <= ((pending_config_reg_write_address[7:2] == 6'h01)
                        & ~pending_config_reg_write_byte_enables[0])
             ? ((pending_config_reg_write_data[PCI_BUS_DATA_RANGE:0] & CONFIG_CMD_PAR_ERR_EN)
                        != `PCI_BUS_DATA_ZERO) : Par_Err_En;
        Master_En  <= ((pending_config_reg_write_address[7:2] == 6'h01)
                        & ~pending_config_reg_write_byte_enables[0])
             ? ((pending_config_reg_write_data[PCI_BUS_DATA_RANGE:0] & CONFIG_CMD_MASTER_EN)
                        != `PCI_BUS_DATA_ZERO) : Master_En;
        Target_En  <= ((pending_config_reg_write_address[7:2] == 6'h01)
                        & ~pending_config_reg_write_byte_enables[0])
             ? ((pending_config_reg_write_data[PCI_BUS_DATA_RANGE:0] & CONFIG_CMD_TARGET_EN)
                        != `PCI_BUS_DATA_ZERO) : Target_En;
// Certain bits in word 1 are only clearable, not writable.
        Detected_PERR    <= ((pending_config_reg_write_address[7:2] == 6'h01)
                        & ~pending_config_reg_write_byte_enables[3]
                    & ((pending_config_reg_write_data[PCI_BUS_DATA_RANGE:0] & CONFIG_STAT_DETECTED_PERR) != `PCI_BUS_DATA_ZERO))
             ? 1'b0 : Detected_PERR | master_got_parity_error | target_got_parity_error;
        Signaled_SERR    <= ((pending_config_reg_write_address[7:2] == 6'h01)
                        & ~pending_config_reg_write_byte_enables[3]
                    & ((pending_config_reg_write_data[PCI_BUS_DATA_RANGE:0] & CONFIG_STAT_DETECTED_SERR) != `PCI_BUS_DATA_ZERO))
             ? 1'b0 : Signaled_SERR | master_asserted_serr | target_asserted_serr;
        Received_Master_Abort <= ((pending_config_reg_write_address[7:2] == 6'h01)
                        & ~pending_config_reg_write_byte_enables[3]
                    & ((pending_config_reg_write_data[PCI_BUS_DATA_RANGE:0] & CONFIG_STAT_GOT_MABORT) != `PCI_BUS_DATA_ZERO))
             ? 1'b0 : Received_Master_Abort | master_got_master_abort;
        Received_Target_Abort <= ((pending_config_reg_write_address[7:2] == 6'h01)
                        & ~pending_config_reg_write_byte_enables[3]
                    & ((pending_config_reg_write_data[PCI_BUS_DATA_RANGE:0] & CONFIG_STAT_GOT_TABORT) != `PCI_BUS_DATA_ZERO))
             ? 1'b0 : Received_Target_Abort | master_got_target_abort;
        Signaled_Target_Abort <= ((pending_config_reg_write_address[7:2] == 6'h01)
                        & ~pending_config_reg_write_byte_enables[3]
                    & ((pending_config_reg_write_data[PCI_BUS_DATA_RANGE:0] & CONFIG_STAT_CAUSED_TABORT) != `PCI_BUS_DATA_ZERO))
             ? 1'b0 : Signaled_Target_Abort | target_signaling_target_abort;
        Master_Caused_PERR <= (  (pending_config_reg_write_address[7:2] == 6'h01)
                        & ~pending_config_reg_write_byte_enables[3]
                    & ((pending_config_reg_write_data[PCI_BUS_DATA_RANGE:0] & CONFIG_STAT_CAUSED_PERR) != `PCI_BUS_DATA_ZERO))
             ? 1'b0 : Master_Caused_PERR | master_caused_parity_error;
// Certain bytes in higher words are writable
        Latency_Timer    <= (  (pending_config_reg_write_address[7:2] == 6'h03)
                              & ~pending_config_reg_write_byte_enables[1])
                          ? pending_config_reg_write_data[15:8] : Latency_Timer;
        Cache_Line_Size  <= (  (pending_config_reg_write_address[7:2] == 6'h03)
                              & ~pending_config_reg_write_byte_enables[0])
                          ? pending_config_reg_write_data[7:0] : Cache_Line_Size;

        if (pending_config_reg_write_address[7:2] == 6'h04)
        begin
            if (~pending_config_reg_write_byte_enables[3])
                BAR0[31:24]      <= pending_config_reg_write_data[31:24] ;

            if (~pending_config_reg_write_byte_enables[2])
                BAR0[23:16]      <= pending_config_reg_write_data[23:16] ;

            if (~pending_config_reg_write_byte_enables[1])
                BAR0[15:8]      <= pending_config_reg_write_data[15:8] ;

            if (~pending_config_reg_write_byte_enables[0])
                BAR0[7:0]      <= pending_config_reg_write_data[7:0] ;
        end

`ifdef PCI_BASE_ADDR1_MATCH_ENABLE
        if (pending_config_reg_write_address[7:2] == 6'h05)
        begin
            if (~pending_config_reg_write_byte_enables[3])
                BAR1[31:24]      <= pending_config_reg_write_data[31:24] ;

            if (~pending_config_reg_write_byte_enables[2])
                BAR1[23:16]      <= pending_config_reg_write_data[23:16] ;

            if (~pending_config_reg_write_byte_enables[1])
                BAR1[15:8]      <= pending_config_reg_write_data[15:8] ;

            if (~pending_config_reg_write_byte_enables[0])
                BAR1[7:0]      <= pending_config_reg_write_data[7:0] ;
        end
`endif  // PCI_BASE_ADDR1_MATCH_ENABLE
        Interrupt_Line   <= (  (pending_config_reg_write_address[7:2] == 6'h0F)
                              & ~pending_config_reg_write_byte_enables[0])
                          ? pending_config_reg_write_data[7:0] : Interrupt_Line;
        pending_config_write_request <= 1'b0;  // NOTE this seems to prevent back-to-back writes.
      end
      else
      begin  // not writing from PCI side
// Words 0 and 2 are not writable.  Only certain bits in word 1 are writable.
        FB2B_En    <= FB2B_En;
        SERR_En    <= SERR_En;
        Par_Err_En <= Par_Err_En;
        Master_En  <= Master_En;
        Target_En  <= Target_En;
// Certain bits in word 1 are only clearable, not writable.
        Detected_PERR    <= Detected_PERR | master_got_parity_error | target_got_parity_error;
        Signaled_SERR    <= Signaled_SERR | master_asserted_serr | target_asserted_serr;
        Received_Master_Abort <= Received_Master_Abort | master_got_master_abort;
        Received_Target_Abort <= Received_Target_Abort | master_got_target_abort;
        Signaled_Target_Abort <= Signaled_Target_Abort | target_signaling_target_abort;
        Master_Caused_PERR <= Master_Caused_PERR | master_caused_parity_error;
// Certain bytes in higher words are writable
        Latency_Timer    <= Latency_Timer;
        Cache_Line_Size  <= Cache_Line_Size;
        BAR0             <= BAR0;
`ifdef PCI_BASE_ADDR1_MATCH_ENABLE
        BAR1             <= BAR1;
`endif  // PCI_BASE_ADDR1_MATCH_ENABLE
        Interrupt_Line   <= Interrupt_Line;
      end
    end
  end

// Tasks to manage the small SRAM visible in Memory Space
  reg    [PCI_BUS_DATA_RANGE:0] Test_Device_Mem [0:1023];  // address limits, not bits in address
// Tasks can't have local storage!  have to be module global
  reg    [9:0] sram_addr;
task Init_Test_Device_SRAM;
  begin
    for (sram_addr = 10'h000; sram_addr < 10'h3FF; sram_addr = sram_addr + 10'h001)
    begin
      Test_Device_Mem[sram_addr] = `BUS_IMPOSSIBLE_VALUE;
    end
    sram_addr = 10'h3FF; // maximum value must also be written!
    Test_Device_Mem[sram_addr] = `BUS_IMPOSSIBLE_VALUE; 
  end
endtask

task Read_Test_Device_SRAM;
  input  [11:2] sram_address;
  input  [PCI_BUS_CBE_RANGE:0] byte_sel ;
  output [PCI_BUS_DATA_RANGE:0] target_read_data;
  reg    [PCI_BUS_DATA_RANGE:0] temp_val ;
  begin
    temp_val                = Test_Device_Mem[sram_address] ;
    target_read_data[7:0]   = byte_sel[0] ? temp_val[7:0]   : 0 ;
    target_read_data[15:8]  = byte_sel[1] ? temp_val[15:8]  : 0 ;
    target_read_data[23:16] = byte_sel[2] ? temp_val[23:16] : 0 ;
    target_read_data[31:24] = byte_sel[3] ? temp_val[31:24] : 0 ;
  end
endtask

// Tasks can't have local storage!  have to be module global
  reg    [PCI_BUS_DATA_RANGE:0] sram_temp;
task Write_Test_Device_SRAM;
  input  [11:2] sram_address;
  input  [PCI_BUS_DATA_RANGE:0] master_write_data;
  input  [PCI_BUS_CBE_RANGE:0] master_mask_l;
  begin
    sram_temp = Test_Device_Mem[sram_address];
    sram_temp[7:0]   = (~master_mask_l[0]) ? master_write_data[7:0]   : sram_temp[7:0];
    sram_temp[15:8]  = (~master_mask_l[1]) ? master_write_data[15:8]  : sram_temp[15:8];
    sram_temp[23:16] = (~master_mask_l[2]) ? master_write_data[23:16] : sram_temp[23:16];
    sram_temp[31:24] = (~master_mask_l[3]) ? master_write_data[31:24] : sram_temp[31:24];
    Test_Device_Mem[sram_address] = sram_temp[PCI_BUS_DATA_RANGE:0];
  end
endtask

// Make the DEVSEL_TRDY_STOP_OE output enable signal.  It must become
//   asserted as soon as one of those signals become asserted, and
//   must stay asserted one clock after the last one becomes deasserted.
  reg     prev_d_t_s_asserted;
  always @(posedge pci_ext_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
    begin
      prev_d_t_s_asserted <= 1'b0;
    end
    else
    begin
      prev_d_t_s_asserted <= target_devsel_out | target_trdy_out | target_stop_out;
    end
  end
  assign  target_d_t_s_oe = target_devsel_out | target_trdy_out | target_stop_out
                          | prev_d_t_s_asserted;

// Make the PERR_OE signal.
// See the PCI Local Bus Spec Revision 2.2 section 3.7.4.1
// At time N, target_perr_check_next is set
// At time N+1, external data is latched, and irdy is also latched
// At time N+1, target_perr_check is latched
// At time N+2, calc_input_parity_prev is valid
// Also at N+2, external parity is valid
  reg     target_perr_prev, target_perr_check_next, target_perr_check;
  reg     target_perr_detected;
  reg     target_debug_force_bad_perr ;

  always @(posedge pci_ext_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
        target_debug_force_bad_perr <= 1'b0 ;
    else
        target_debug_force_bad_perr <= target_debug_force_bad_par ;
  end

  always @(posedge pci_ext_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
    begin
      target_perr_check <= 1'b0;
      target_perr_detected <= 1'b0;
      target_perr_out <= 1'b0;
      target_perr_prev <= 1'b0;
    end
    else
    begin
      target_perr_check <= target_perr_check_next;
      target_perr_detected <= target_perr_check & irdy_prev
                         & (calc_input_parity_prev != par_now);
      target_perr_out <= target_perr_check & irdy_prev & Par_Err_En
                                                                 // mihad - bad perr generation
                         & (calc_input_parity_prev != (par_now ^ target_debug_force_bad_perr));
      target_perr_prev <= target_perr_out;
    end
  end
  assign  target_perr_oe = target_perr_out | target_perr_prev;

// Make the SERR_OE signal
// See the PCI Local Bus Spec Revision 2.2 section 6.2.3.
  reg prev_prev_frame;
  always @(posedge pci_ext_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
    begin
      prev_prev_frame <= 1'b0;
      target_serr_oe <= 1'b0;
    end
    else
    begin
      prev_prev_frame <= frame_prev;
      target_serr_oe <= ~prev_prev_frame & frame_prev
                      & SERR_En & Par_Err_En
                      & (calc_input_parity_prev != par_now);
    end
  end
  assign  target_asserted_serr = target_serr_oe;
  assign  target_got_parity_error = target_perr_detected | target_serr_oe;

// Remember whether this device drove DEVSEL last clock, which allows
// Zero-Wait-State Back-to-Back references
  wire    This_Target_Drove_DEVSEL_Last_Clock = target_d_t_s_oe;

// Remember whether the bus has correct parity.
// Used by Medium, slower Address Decode to prevent DEVSEL on bad Address Parity
  reg     prev_bus_par_ok, prev_prev_bus_par_ok;
  always @(posedge pci_ext_clk)
  begin
    prev_bus_par_ok <= (calc_input_parity_prev == par_now);
    prev_prev_bus_par_ok <= prev_bus_par_ok;
  end

// We want the Target to do certain behavior to let us test the interface.
// See the note in the Master section about the use of Address Bits to
//   encode Target Wait State, Target Completion, and Target Error info.

// signals used by Target test code to apply correct info to the PCI bus
  reg    [PCI_BUS_DATA_RANGE:0] hold_target_address;
  reg    [PCI_BUS_CBE_RANGE:0] hold_target_command;
  reg    [3:0] hold_target_initial_waitstates;
  reg    [3:0] hold_target_subsequent_waitstates;
  reg    [2:0] hold_target_termination;
  reg    [1:0] hold_target_devsel_speed;
  reg    [9:0] hold_target_terminate_on ;
  reg     hold_target_data_par_err;
  reg     hold_target_addr_par_err;

// Tasks which use the held PCI address to access internal info.  These tasks
//   update the address counter, emulating the target address counter during bursts.
// Store data from PCI bus into Config Register, and increment Write Pointer
task Capture_Config_Reg_Data_From_AD_Bus;
  input  [PCI_BUS_DATA_RANGE:0] master_write_data;
  input  [PCI_BUS_CBE_RANGE:0] master_mask_l;
  begin
    Write_Test_Device_Config_Regs (hold_target_address[7:2],
                           master_write_data[PCI_BUS_DATA_RANGE:0], master_mask_l[PCI_BUS_CBE_RANGE:0]);
    hold_target_address[7:2] = hold_target_address[7:2] + 6'h01;  // addr++
  end
endtask

// Drive Config Register Data onto AD bus, and increment Read Pointer
task Fetch_Config_Reg_Data_For_Read_Onto_AD_Bus;
  output [PCI_BUS_DATA_RANGE:0] target_read_data;
  begin
    Read_Test_Device_Config_Regs (hold_target_address[7:2], target_read_data[PCI_BUS_DATA_RANGE:0], cbe_l_now);
    hold_target_address[7:2] = hold_target_address[7:2] + 6'h01;  // addr++
  end
endtask

// Store data from PCI bus into SRAM, and increment Write Pointer
task Capture_SRAM_Data_From_AD_Bus;
  input  [PCI_BUS_DATA_RANGE:0] master_write_data;
  input  [PCI_BUS_CBE_RANGE:0] master_mask_l;
  begin
    Write_Test_Device_SRAM (hold_target_address[11:2],
                            master_write_data[PCI_BUS_DATA_RANGE:0], master_mask_l[PCI_BUS_CBE_RANGE:0]);
    hold_target_address[11:2] = hold_target_address[11:2] + 10'h001;  // addr++
  end
endtask

// Drive SRAM Data onto AD bus, and increment Read Pointer
task Fetch_SRAM_Data_For_Read_Onto_AD_Bus;
  output [PCI_BUS_DATA_RANGE:0] target_read_data;
  reg fetch_from0 ;
  begin
    fetch_from0 = (hold_target_command == PCI_COMMAND_INTERRUPT_ACKNOWLEDGE) ;
    Read_Test_Device_SRAM (fetch_from0 ? 0 : hold_target_address[11:2], ~cbe_l_now, target_read_data[PCI_BUS_DATA_RANGE:0]);
    hold_target_address[11:2] = hold_target_address[11:2] + 10'h001;  // addr++
  end
endtask

// The target is able to execute Delayed Reads,
// See the PCI Local Bus Spec Revision 2.2 section 3.3.3.3
// To allow a delayed read to complete, read data must be available.
// Also a PCI command matching in Address, Command, Byte Enables,
//   and parity on address.
// If the region of memory is prefetchable and always returns all
//   bytes, it is OK to disregard the Byte Enables.
  reg     Delayed_Read_Started, Delayed_Read_Pending, Delayed_Read_Finished;
  reg    [PCI_BUS_DATA_RANGE:0] Delayed_Read_Address;
  reg    [PCI_BUS_CBE_RANGE:0] Delayed_Read_Command;
  reg    [PCI_BUS_CBE_RANGE:0] Delayed_Read_Mask_L;
  reg    [14:0] Delayed_Read_Discard_Counter;
  wire   [14:0] Delayed_Read_Discard_Limit = 15'h7FFF;  // change for debugging
  always @(posedge pci_ext_clk or posedge pci_reset_comb)
  begin
    if (pci_reset_comb)
    begin
      Delayed_Read_Pending <= 1'b0;
    end
    else
    begin
      Delayed_Read_Pending <= Delayed_Read_Started
          | (Delayed_Read_Pending & ~Delayed_Read_Finished
              & (Delayed_Read_Discard_Counter[14:0] < Delayed_Read_Discard_Limit[14:0]));
    end
  end

  always @(posedge pci_ext_clk)
  begin
    Delayed_Read_Discard_Counter[14:0] <= Delayed_Read_Started
                    ? 15'h0000 : Delayed_Read_Discard_Counter[14:0] + 15'h0001;
`ifdef VERBOSE_TEST_DEVICE
    if (Delayed_Read_Pending & (Delayed_Read_Discard_Counter[14:0]
                                     >= Delayed_Read_Discard_Limit[14:0]))
    begin
      $display (" test target %h - Delayed Read Discarded, at %t",
                    test_device_id[2:0], $time);
    end
    `NO_ELSE;
`endif // VERBOSE_TEST_DEVICE
  end

// Target tasks.  These know how to respond to the external masters.
// NOTE all tasks end with an @(posedge pci_ext_clk) statement
//      to let any signals asserted during that task settle out.
// If a task DOESN'T end with @(posedge pci_ext_clk), then it must
//      be called just before some other task which does.

parameter TEST_TARGET_SPINLOOP_MAX = 20;

task Clock_Wait_Unless_Reset;
  begin
    if (~pci_reset_comb)
    begin
      @ (posedge pci_ext_clk or posedge pci_reset_comb) ;
    end
    `NO_ELSE;
  end
endtask

task Assert_DEVSEL;
  begin
    target_devsel_out <= 1'b1;
  end
endtask

task Assert_TRDY;
  begin
    target_trdy_out <= 1'b1;
  end
endtask

task Assert_STOP;
  begin
    target_stop_out <= 1'b1;
  end
endtask

task Deassert_DEVSEL;
  begin
    target_devsel_out <= 1'b0;
  end
endtask

task Deassert_TRDY;
  begin
    target_trdy_out <= 1'b0;
  end
endtask

task Deassert_STOP;
  begin
    target_stop_out <= 1'b0;
  end
endtask

task Assert_Target_Continue_Or_Disconnect;
  input   do_target_disconnect;
  begin
    if (do_target_disconnect)
    begin
      Assert_DEVSEL;    Assert_TRDY;    Assert_STOP;
    end
    else
    begin
      Assert_DEVSEL;    Assert_TRDY;    Deassert_STOP;
    end
  end
endtask

// Execute_Target_Retry is called with nothing or DEVSEL asserted
//   tasks can't have local storage!  have to be module global
  integer iiii;
task Execute_Target_Retry_Undrive_DEVSEL;
  input   drive_ad_bus;
  input   signal_starting_delayed_read;
  input   signal_satisfied_delayed_read;
  begin
    for (iiii = 0; iiii < TEST_TARGET_SPINLOOP_MAX; iiii = iiii + 1)
    begin
      if ((iiii == 0) | frame_now | ~irdy_now)  // At least one stop, then Not Finished
      begin
        target_ad_out <= `BUS_IMPOSSIBLE_VALUE;
        target_ad_oe <= drive_ad_bus;
        target_debug_force_bad_par <= 1'b0;
        target_perr_check_next <= ~drive_ad_bus;
        target_signaling_target_abort <= 1'b0;
        Delayed_Read_Started <= signal_starting_delayed_read;
        Delayed_Read_Finished <= signal_satisfied_delayed_read;
        Assert_DEVSEL;  // signal DEVSEL and Stop, indicating Retry
        Deassert_TRDY;
        Assert_STOP;
        if (signal_starting_delayed_read)
        begin
          Delayed_Read_Address[PCI_BUS_DATA_RANGE:0] = hold_target_address[PCI_BUS_DATA_RANGE:0];
          Delayed_Read_Command[PCI_BUS_CBE_RANGE:0] =  hold_target_command[PCI_BUS_CBE_RANGE:0];
          Delayed_Read_Mask_L[PCI_BUS_CBE_RANGE:0] = cbe_l_now[PCI_BUS_CBE_RANGE:0];
        end
        `NO_ELSE;
      end
      else
      begin
        target_ad_out[PCI_BUS_DATA_RANGE:0] <= `BUS_IMPOSSIBLE_VALUE;
        target_ad_oe <= 1'b0;  // unconditionally undrive ad bus
        target_debug_force_bad_par <= 1'b0;
        target_perr_check_next <= 1'b0;
        target_signaling_target_abort <= 1'b0;
        Delayed_Read_Started <= 1'b0;
        Delayed_Read_Finished <= 1'b0;
        Deassert_DEVSEL;  // Master saw us, so leave
        Deassert_TRDY;
        Deassert_STOP;
        iiii = TEST_TARGET_SPINLOOP_MAX + 1;  // break
      end
      Clock_Wait_Unless_Reset;  // wait for outputs to settle
      signal_satisfied_delayed_read = 1'b0;
    end
`ifdef NORMAL_PCI_CHECKS
    if (~pci_reset_comb & (iiii == TEST_TARGET_SPINLOOP_MAX))
    begin
      $display ("*** test target %h - Bus didn't go Idle during Target Retry, at %t",
                test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
    if (~pci_reset_comb & irdy_now)
    begin
      $display ("*** test target %h - IRDY didn't deassert at end of Target Retry, at %t",
                   test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
`endif // NORMAL_PCI_CHECKS
  end
endtask

// This Test Device is capable of doing Fast Decode.  To do this,
//   it must make sure not to cause conflicts on DEVSEL, IRDY,
//   STOP, or PERR.  To achieve this, the task must hold off on
//   making DEVSEL unless either
//   1) the bus was just Idle
//   2) this device also drove DEVSEL the previous clock (I presume this
//      means that DEVSEL was driven LOW!!  Would HIGH be an idle cycle?)
// See the PCI Local Bus Spec Revision 2.2 section 3.4.2
//
// See the PCI Local Bus Spec Revision 2.2 section 3.7.3 for what
//   to do if an Address Parity Error is detected.
// Since this behaviorial test knows that an address parity error is
//   comming, it holds off fast decode parity errors, and always
//   allows a master abort to happen.  This would not be possible in
//   a gate-level PCI interface.  For FAST decode, that interface would
//   have to continue on as if there was no error.  It would be nice
//   if it prevented any writes of data, or reads with side-effects.
task Wait_Till_DEVSEL_Possible;
  output  devsel_asserted;
  output  fast_devsel_asserted;
  output  signal_satisfied_delayed_read;
  begin
    if ((hold_target_devsel_speed[1:0] == `Test_Devsel_Fast) & ~Delayed_Read_Pending
          & (   (~frame_prev & ~irdy_prev)
              | (~frame_prev &  irdy_prev & This_Target_Drove_DEVSEL_Last_Clock) )
          & ~(hold_target_addr_par_err & Par_Err_En))
    begin
`ifdef VERBOSE_TEST_DEVICE
      $display (" test target %h - doing fast DEVSEL, at %t",
                    test_device_id[2:0], $time);
`endif // VERBOSE_TEST_DEVICE
      devsel_asserted = 1'b1;  // fast decode
      fast_devsel_asserted = 1'b1;  // fast decode
      signal_satisfied_delayed_read = 1'b0;
    end
    else
    begin
      target_ad_out <= `BUS_IMPOSSIBLE_VALUE;
      target_ad_oe <= 1'b0;  // Should this drive AD when not DEVSEL?
      target_debug_force_bad_par <= 1'b0;
      target_perr_check_next <= 1'b0;
      target_signaling_target_abort <= 1'b0;
      Delayed_Read_Started <= 1'b0;
      Delayed_Read_Finished <= 1'b0;
      Deassert_DEVSEL;
      Deassert_TRDY;
      Deassert_STOP;
      Clock_Wait_Unless_Reset;  // wait for outputs to settle
      if (Delayed_Read_Pending
            & (   (hold_target_command[3:0] == PCI_COMMAND_MEMORY_READ)
                | (hold_target_command[3:0] == PCI_COMMAND_MEMORY_READ_MULTIPLE)
                | (hold_target_command[3:0] == PCI_COMMAND_MEMORY_READ_LINE)
                | (hold_target_command[3:0] == PCI_COMMAND_CONFIG_READ) )
            & (   (    (hold_target_address[PCI_BUS_DATA_RANGE:0] & 32'hFF0000FF)  // partial test address match
                    != (Delayed_Read_Address[PCI_BUS_DATA_RANGE:0] & 32'hFF0000FF))
                | (hold_target_command[PCI_BUS_CBE_RANGE:0] != Delayed_Read_Command[PCI_BUS_CBE_RANGE:0])
                | (cbe_l_now[PCI_BUS_CBE_RANGE:0] != Delayed_Read_Mask_L[PCI_BUS_CBE_RANGE:0]) ) )
      begin
        Execute_Target_Retry_Undrive_DEVSEL (1'b1, 1'b0, 1'b0);
        devsel_asserted = 1'b0;  // tell calling routine to not claim DEVSEL.
        fast_devsel_asserted = 1'b0;
        signal_satisfied_delayed_read = 1'b0;
      end
      else
      begin
        if /*(*/(  (hold_target_devsel_speed[1:0] == `Test_Devsel_Fast)
             | (hold_target_devsel_speed[1:0] == `Test_Devsel_Medium) )
             /*  & ((calc_input_parity_prev == par_now) | ~Par_Err_En))*/
        begin
          devsel_asserted = 1'b1;  // medium decode
          fast_devsel_asserted = 1'b0;  // medium decode
          signal_satisfied_delayed_read = Delayed_Read_Pending
                & (   (hold_target_command[3:0] == PCI_COMMAND_MEMORY_READ)
                    | (hold_target_command[3:0] == PCI_COMMAND_MEMORY_READ_MULTIPLE)
                    | (hold_target_command[3:0] == PCI_COMMAND_MEMORY_READ_LINE)
                    | (hold_target_command[3:0] == PCI_COMMAND_CONFIG_READ) );
        end
        else
        begin
          target_ad_out <= `BUS_IMPOSSIBLE_VALUE;
          target_ad_oe <= 1'b0;  // Should this drive AD when not DEVSEL?
          target_debug_force_bad_par <= 1'b0;
          target_perr_check_next <= 1'b0;
          target_signaling_target_abort <= 1'b0;
          Delayed_Read_Started <= 1'b0;
          Delayed_Read_Finished <= 1'b0;
          Deassert_DEVSEL;
          Deassert_TRDY;
          Deassert_STOP;
          Clock_Wait_Unless_Reset;
          if /*(*/(hold_target_devsel_speed[1:0] == `Test_Devsel_Slow)
                /*& (prev_bus_par_ok | ~Par_Err_En))*/
          begin
            devsel_asserted = 1'b1;  // slow decode
            fast_devsel_asserted = 1'b0;  // slow decode
            signal_satisfied_delayed_read = Delayed_Read_Pending
                & (   (hold_target_command[3:0] == PCI_COMMAND_MEMORY_READ)
                    | (hold_target_command[3:0] == PCI_COMMAND_MEMORY_READ_MULTIPLE)
                    | (hold_target_command[3:0] == PCI_COMMAND_MEMORY_READ_LINE)
                    | (hold_target_command[3:0] == PCI_COMMAND_CONFIG_READ) );
          end
          else
          begin
            target_ad_out <= `BUS_IMPOSSIBLE_VALUE;
            target_ad_oe <= 1'b0;  // Should this drive AD when not DEVSEL?
            target_debug_force_bad_par <= 1'b0;
            target_perr_check_next <= 1'b0;
            target_signaling_target_abort <= 1'b0;
            Delayed_Read_Started <= 1'b0;
            Delayed_Read_Finished <= 1'b0;
            Deassert_DEVSEL;
            Deassert_TRDY;
            Deassert_STOP;
            Clock_Wait_Unless_Reset;  // wait for outputs to settle
            if (/*(*/hold_target_devsel_speed[1:0] == `Test_Devsel_Subtractive)
                  /*& (prev_prev_bus_par_ok | ~Par_Err_En))*/
            begin
              devsel_asserted = 1'b1;  // subtractive decode
              fast_devsel_asserted = 1'b0;  // subtractive decode
              signal_satisfied_delayed_read = Delayed_Read_Pending
                & (   (hold_target_command[3:0] == PCI_COMMAND_MEMORY_READ)
                    | (hold_target_command[3:0] == PCI_COMMAND_MEMORY_READ_MULTIPLE)
                    | (hold_target_command[3:0] == PCI_COMMAND_MEMORY_READ_LINE)
                    | (hold_target_command[3:0] == PCI_COMMAND_CONFIG_READ) );

            end
            else
            begin
              devsel_asserted = 1'b0;  // must have had bad parity
              fast_devsel_asserted = 1'b0;
              signal_satisfied_delayed_read = 1'b0;
            end
          end
        end
      end
    end
`ifdef NORMAL_PCI_CHECKS
    if (~pci_reset_comb & (devsel_asserted == 1'b1)
                        & (hold_target_addr_par_err == 1'b1))
    begin
      $display ("*** test target %h - DEVSEL Asserted when Address Parity Error expected, at %t",
                   test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
`endif // NORMAL_PCI_CHECKS
  end
endtask

// While asserting DEVSEL, wait zero or more clocks as commanded by master
// This might be called with 1 waitstate before the read data can be OE'd
//    or before the Master Parity can be checked.
// Tasks can't have local storage!  have to be module global
  reg    [3:0] cnt1;
task Execute_Target_Waitstates;
  input   drive_ad_bus;
  input   enable_parity_check;
  input  [3:0] num_waitstates;
  begin
    for (cnt1 = 4'h0; cnt1 < num_waitstates[3:0]; cnt1 = cnt1 + 4'h1)
    begin
`ifdef NORMAL_PCI_CHECKS
    if (!pci_reset_comb & ~frame_now & ~irdy_now)
    begin
      $display ("*** test target %h - Execute Target Waitstates Wait States called when no Master, at %t",
                   test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
`endif // NORMAL_PCI_CHECKS
      target_ad_out <= `BUS_WAIT_STATE_VALUE;
      target_ad_oe <= drive_ad_bus;
      target_debug_force_bad_par <= 1'b0;
      target_perr_check_next <= enable_parity_check;
      target_signaling_target_abort <= 1'b0;
      Delayed_Read_Started <= 1'b0;
      Delayed_Read_Finished <= 1'b0;
      Assert_DEVSEL;
      Deassert_TRDY;
      Deassert_STOP;
      Clock_Wait_Unless_Reset;  // wait for outputs to settle
    end
  end
endtask

// DEVSEL already asserted upon entry to this task.  OK to watch Parity
// Tasks can't have local storage!  have to be module global
  integer ii;
task Linger_Until_Master_Waitstates_Done;
  input   drive_ad_bus;
  input  [PCI_BUS_DATA_RANGE:0] target_read_data;
  input   do_target_disconnect;
  begin
    for (ii = 0; ii < TEST_TARGET_SPINLOOP_MAX; ii = ii + 1)
    begin
      if (frame_now & ~irdy_now)  // master executing wait states
      begin
        target_ad_out[PCI_BUS_DATA_RANGE:0] <= target_read_data[PCI_BUS_DATA_RANGE:0];
        target_ad_oe <= drive_ad_bus;
        target_debug_force_bad_par <= hold_target_data_par_err;
        target_perr_check_next <= ~drive_ad_bus;
        target_signaling_target_abort <= 1'b0;
        Delayed_Read_Started <= 1'b0;
        Delayed_Read_Finished <= 1'b0;
        Assert_Target_Continue_Or_Disconnect (do_target_disconnect);
        Clock_Wait_Unless_Reset;  // wait for outputs to settle
      end
      else
      begin
      ii = TEST_TARGET_SPINLOOP_MAX + 1;  // break
      end
    end
`ifdef NORMAL_PCI_CHECKS
    if (~pci_reset_comb & ~frame_now & ~irdy_now)
    begin
      $display ("*** test target %h - Linger during Master Wait States called when no Master, at %t",
                   test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
    if (~pci_reset_comb & (ii == TEST_TARGET_SPINLOOP_MAX))
    begin
      $display ("*** test target %h - Bus stuck in Master Wait States during Target ref, at %t",
                   test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
`endif // NORMAL_PCI_CHECKS
  end
endtask

// Execute_Target_Abort.  This must be called with DEVSEL asserted
// Tasks can't have local storage!  have to be module global
  integer iii;
task Execute_Target_Abort_Undrive_DEVSEL;
  input   drive_ad_bus;
  input   signal_satisfied_delayed_read;
  begin
`ifdef NORMAL_PCI_CHECKS
    if (~pci_reset_comb & (target_devsel_out == 1'b0))
    begin
      $display ("*** test target %h - DEVSEL not asserted when starting Target Abort, at %t",
                   test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
`endif // NORMAL_PCI_CHECKS
    for (iii = 0; iii < TEST_TARGET_SPINLOOP_MAX; iii = iii + 1)
    begin
      if ((iii == 0) | frame_now | ~irdy_now)  // At least one stop, Master Not Finished
      begin
        target_ad_out[PCI_BUS_DATA_RANGE:0] <= `BUS_IMPOSSIBLE_VALUE;
        target_ad_oe <= 1'b0;  // Should this drive AD when not DEVSEL?
        target_debug_force_bad_par <= 1'b0;
        target_perr_check_next <= 1'b0;
        target_signaling_target_abort <= 1'b1;
        Delayed_Read_Started <= 1'b0;
        Delayed_Read_Finished <= signal_satisfied_delayed_read;
        Deassert_DEVSEL;  // Signal Target Abort
        Deassert_TRDY;
        Assert_STOP;
      end
      else
      begin
        target_ad_out[PCI_BUS_DATA_RANGE:0] <= `BUS_IMPOSSIBLE_VALUE;
        target_ad_oe <= 1'b0;  // unconditionally undrive ad bus
        target_debug_force_bad_par <= 1'b0;
        target_perr_check_next <= 1'b0;
        target_signaling_target_abort <= 1'b0;
        Delayed_Read_Started <= 1'b0;
        Delayed_Read_Finished <= 1'b0;
        Deassert_DEVSEL;  // Signal Target Abort
        Deassert_TRDY;
        Deassert_STOP;  // Master saw us, so leave
        iii = TEST_TARGET_SPINLOOP_MAX + 1;  // break
      end
      Clock_Wait_Unless_Reset;  // wait for outputs to settle
      signal_satisfied_delayed_read = 1'b0;
    end
`ifdef NORMAL_PCI_CHECKS
    if (~pci_reset_comb & irdy_now)
    begin
      $display ("*** test target %h - Master didn't deassert IRDY at end of Target Abort, at %t",
                   test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
    if (~pci_reset_comb & (iii == TEST_TARGET_SPINLOOP_MAX))
    begin
      $display ("*** test target %h - Bus didn't go Idle during Target Abort, at %t",
                   test_device_id[2:0], $time);
      error_detected <= ~error_detected;
    end
    `NO_ELSE;
`endif // NORMAL_PCI_CHECKS
  end
endtask

// Transfer a word with or without target termination, and act on Master Termination
task Execute_Target_Ref_Undrive_DEVSEL_On_Any_Termination;
  input   drive_ad_bus;
  input   do_target_disconnect;
  input   signal_satisfied_delayed_read;
  input  [PCI_BUS_DATA_RANGE:0] target_read_data;
  output [PCI_BUS_DATA_RANGE:0] master_write_data;
  output [PCI_BUS_CBE_RANGE:0] master_mask_l;
  output  target_was_terminated;
  begin
    target_ad_out[PCI_BUS_DATA_RANGE:0] <= target_read_data[PCI_BUS_DATA_RANGE:0];
    target_ad_oe <= drive_ad_bus;
    target_debug_force_bad_par <= hold_target_data_par_err;
    target_perr_check_next <= ~drive_ad_bus;
    target_signaling_target_abort <= 1'b0;
    Delayed_Read_Started <= 1'b0;
    Delayed_Read_Finished <= signal_satisfied_delayed_read;
    Assert_Target_Continue_Or_Disconnect (do_target_disconnect);
    Clock_Wait_Unless_Reset;  // wait for outputs to settle
    Linger_Until_Master_Waitstates_Done (drive_ad_bus,
                       target_read_data[PCI_BUS_DATA_RANGE:0], do_target_disconnect);
    master_write_data[PCI_BUS_DATA_RANGE:0] = ad_now[PCI_BUS_DATA_RANGE:0];  // unconditionally grab.
    master_mask_l[PCI_BUS_CBE_RANGE:0] = cbe_l_now[PCI_BUS_CBE_RANGE:0];
    if (frame_now & irdy_now & ~do_target_disconnect)
    begin
        target_was_terminated = 1'b0;
    end
    else
    begin
      if (frame_now & irdy_now & do_target_disconnect)  // doing Target Termination
      begin
        target_ad_out <= `BUS_IMPOSSIBLE_VALUE;
        target_ad_oe <= drive_ad_bus;
        target_debug_force_bad_par <= 1'b0;
        target_perr_check_next <= ~drive_ad_bus;
        target_signaling_target_abort <= 1'b0;
        Delayed_Read_Started <= 1'b0;
        Delayed_Read_Finished <= 1'b0;
        Assert_DEVSEL;
        Deassert_TRDY;
        Assert_STOP;
        Clock_Wait_Unless_Reset;  // give master a chance to turn FRAME around
      end
      `NO_ELSE;
`ifdef NORMAL_PCI_CHECKS
      if (~pci_reset_comb & ~(~frame_now & irdy_now))  // error if not last master data phase
      begin
        $display ("*** test target %h - Master entered fatally odd state in Target Ref, at %t",
                     test_device_id[2:0], $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
`endif // NORMAL_PCI_CHECKS
      target_ad_out <= `BUS_IMPOSSIBLE_VALUE;
      target_ad_oe <= 1'b0;  // unconditionally undrive ad bus
      target_debug_force_bad_par <= 1'b0;
      target_perr_check_next <= 1'b0;
      target_signaling_target_abort <= 1'b0;
      Delayed_Read_Started <= 1'b0;
      Delayed_Read_Finished <= 1'b0;
      Deassert_DEVSEL;
      Deassert_TRDY;
      Deassert_STOP;
      Clock_Wait_Unless_Reset;
`ifdef NORMAL_PCI_CHECKS
      if (~pci_reset_comb & irdy_now)
      begin
        $display ("*** test target %h - IRDY didn't deassert at end of Master Termination, at %t",
                     test_device_id[2:0], $time);
        error_detected <= ~error_detected;
      end
      `NO_ELSE;
`endif // NORMAL_PCI_CHECKS
      target_was_terminated = 1'b1;
    end
  end
endtask

`define TEST_TARGET_DOING_CONFIG_READ   2'b00
`define TEST_TARGET_DOING_CONFIG_WRITE  2'b01
`define TEST_TARGET_DOING_SRAM_READ     2'b10
`define TEST_TARGET_DOING_SRAM_WRITE    2'b11

task Report_On_Target_PCI_Ref_Start;
  input  [1:0] reference_type;
  begin
    case (reference_type[1:0])
    `TEST_TARGET_DOING_CONFIG_READ:
      $display (" test target %h - Starting Config Read, at %t",
                    test_device_id[2:0], $time);
    `TEST_TARGET_DOING_CONFIG_WRITE:
      $display (" test target %h - Starting Config Write, at %t",
                    test_device_id[2:0], $time);
    `TEST_TARGET_DOING_SRAM_READ:
      $display (" test target %h - Starting Memory Read, at %t",
                    test_device_id[2:0], $time);
    `TEST_TARGET_DOING_SRAM_WRITE:
      $display (" test target %h - Starting Memory Write, at %t",
                    test_device_id[2:0], $time);
    default:
      $display ("*** test target %h - Doing Unknown Reference, at %t",
                    test_device_id[2:0], $time);
    endcase
`ifdef VERBOSE_TEST_DEVICE
    Report_Target_Reference_Paramaters;
`endif // VERBOSE_TEST_DEVICE
  end
endtask

// Transfer either a burst of Config Registers or SRAM Contents across the PCI Bus
// Tasks can't have local storage!  have to be module global
  reg     devsel_asserted, fast_devsel_asserted, target_was_terminated;
  reg    [3:0] wait_states_this_time;
  reg     do_abort_this_time, do_retry_this_time, do_disconnect_this_time;
  reg     abort_needs_waitstate;
  reg    [PCI_BUS_DATA_RANGE:0] master_write_data;
  reg    [PCI_BUS_DATA_RANGE:0] target_read_data;
  reg    [PCI_BUS_CBE_RANGE:0] master_mask_l;
  reg     drive_ad_bus;
  reg     signal_satisfied_delayed_read;
task Execute_Target_PCI_Ref;
  input  [1:0] reference_type;
  output  saw_fast_back_to_back;
  reg     [9:0] number_of_transfers ;
  begin

    number_of_transfers = 0 ;
`ifdef REPORT_TEST_DEVICE
    Report_On_Target_PCI_Ref_Start (reference_type[1:0]);
`endif // REPORT_TEST_DEVICE
    Wait_Till_DEVSEL_Possible (devsel_asserted, fast_devsel_asserted,
                                          signal_satisfied_delayed_read);
    if (devsel_asserted == 1'b1)
    begin
// Target must drive AD bus even if it is going to do an abort or retry.
// See the PCI Local Bus Spec Revision 2.2 section 3.3.1
      drive_ad_bus = (reference_type[1:0] == `TEST_TARGET_DOING_CONFIG_READ)
                   | (reference_type[1:0] == `TEST_TARGET_DOING_SRAM_READ);
      wait_states_this_time[3:0] = hold_target_initial_waitstates[3:0];
      abort_needs_waitstate = (hold_target_initial_waitstates[3:0] == 4'h0);

      do_abort_this_time = ( (hold_target_termination[2:0] == `Test_Target_Abort) && (hold_target_terminate_on == 1) );

      do_retry_this_time = ( (hold_target_termination[2:0] == `Test_Target_Retry_Before) && (hold_target_terminate_on == 1) ) |
                           (hold_target_termination[2:0] == `Test_Target_Start_Delayed_Read) ;

      do_disconnect_this_time = ( (hold_target_termination[2:0] == `Test_Target_Disc_With) && (hold_target_terminate_on == 1) ) ;

// If the bottom 2 bits of the Address aren't 2'b00, only transfer 1 word.
// See the PCI Local Bus Spec Revision 2.2 section 3.2.2.2
      do_disconnect_this_time = do_disconnect_this_time
                              | (hold_target_address[1:0] != 2'b00);
// If Fast Decode and it's a read, don't drive data for 1 clock to avoid AD bus fight
// See the PCI Local Bus Spec Revision 2.2 section 3.3.1
      if (fast_devsel_asserted & drive_ad_bus)
      begin
        Execute_Target_Waitstates (1'b0, 1'b0, 4'h1);  // avoid collisions on AD bus
        if (wait_states_this_time[3:0] != 4'h0)
        begin
          wait_states_this_time[3:0] = wait_states_this_time[3:0] - 4'h1;
        end
        `NO_ELSE;
      end
      `NO_ELSE;
      target_was_terminated = 1'b0;
      while (target_was_terminated == 1'b0)
      begin
        Execute_Target_Waitstates (drive_ad_bus, ~drive_ad_bus,
                                            wait_states_this_time[3:0]);
        if (do_abort_this_time)
        begin
          if (abort_needs_waitstate)
          begin
            Execute_Target_Waitstates (drive_ad_bus, ~drive_ad_bus, 4'h1);
          end
          `NO_ELSE;
          Execute_Target_Abort_Undrive_DEVSEL (drive_ad_bus,
                                               signal_satisfied_delayed_read);
          target_was_terminated = 1'b1;
        end
        else if (do_retry_this_time)
        begin
          Execute_Target_Retry_Undrive_DEVSEL (drive_ad_bus,
                (hold_target_termination[2:0] == `Test_Target_Start_Delayed_Read)
              & (   (hold_target_command[PCI_BUS_CBE_RANGE:0] ==
                                              PCI_COMMAND_MEMORY_READ)
                  | (hold_target_command[PCI_BUS_CBE_RANGE:0] ==
                                              PCI_COMMAND_MEMORY_READ_MULTIPLE)
                  | (hold_target_command[PCI_BUS_CBE_RANGE:0] ==
                                              PCI_COMMAND_MEMORY_READ_LINE)
                  | (hold_target_command[PCI_BUS_CBE_RANGE:0] ==
                                              PCI_COMMAND_CONFIG_READ) ),
                                               signal_satisfied_delayed_read);
          target_was_terminated = 1'b1;
        end
        else  // at least one data item should be read out of this device
        begin
//          do_disconnect_this_time = do_disconnect_this_time  // prevent address roll-over
//                            | (hold_target_address[7:2] == 6'h3F);
          if (reference_type[1:0] == `TEST_TARGET_DOING_CONFIG_READ)
          begin
            Fetch_Config_Reg_Data_For_Read_Onto_AD_Bus (target_read_data[PCI_BUS_DATA_RANGE:0]);
          end
          `NO_ELSE;
          if (reference_type[1:0] == `TEST_TARGET_DOING_SRAM_READ)
          begin
            Fetch_SRAM_Data_For_Read_Onto_AD_Bus (target_read_data[PCI_BUS_DATA_RANGE:0]);
          end
          `NO_ELSE;
          Execute_Target_Ref_Undrive_DEVSEL_On_Any_Termination
                           (drive_ad_bus, do_disconnect_this_time,
                            signal_satisfied_delayed_read,
                            target_read_data[PCI_BUS_DATA_RANGE:0],
                            master_write_data[PCI_BUS_DATA_RANGE:0],
                            master_mask_l[PCI_BUS_CBE_RANGE:0],
                            target_was_terminated);
          number_of_transfers = number_of_transfers + 1 ;

          if (reference_type[1:0] == `TEST_TARGET_DOING_CONFIG_WRITE)
          begin
            Capture_Config_Reg_Data_From_AD_Bus (master_write_data[PCI_BUS_DATA_RANGE:0],
                                                 master_mask_l[PCI_BUS_CBE_RANGE:0]);
          end
          `NO_ELSE;
          if (reference_type[1:0] == `TEST_TARGET_DOING_SRAM_WRITE)
          begin
            Capture_SRAM_Data_From_AD_Bus (master_write_data[PCI_BUS_DATA_RANGE:0],
                                           master_mask_l[PCI_BUS_CBE_RANGE:0]);
          end

          `NO_ELSE;
// set up for the next transfer
          wait_states_this_time[3:0] = hold_target_subsequent_waitstates[3:0];
          abort_needs_waitstate = 1'b0;
          /*do_abort_this_time = (hold_target_termination[2:0]
                                            == `Test_Target_Abort_Before_Second);
          do_retry_this_time = (hold_target_termination[2:0]
                                            == `Test_Target_Retry_Before_Second);
          do_disconnect_this_time = (hold_target_termination[2:0]
                                      == `Test_Target_Disc_With_Second);*/

          do_abort_this_time = ( (hold_target_termination[2:0] == `Test_Target_Abort) && (hold_target_terminate_on == (number_of_transfers + 1)) );

          do_retry_this_time = ( (hold_target_termination[2:0] == `Test_Target_Retry_Before) && (hold_target_terminate_on == (number_of_transfers + 1)) ) ;

          do_disconnect_this_time = ( (hold_target_termination[2:0] == `Test_Target_Disc_With) && (hold_target_terminate_on == (number_of_transfers + 1)) ) ;

          signal_satisfied_delayed_read = 1'b0;
        end
      end
// Watch for Fast Back-to-Back reference.  If seen, do not go to the top
//   of the Target Idle Loop, which automatically waits for one clock.
// Instead go directly to see if this device is addressed.
// This transition is manditory even if the device can't do
//   fast-back-to-back transfers!
// See the PCI Local Bus Spec Revision 2.2 section 3.4.2.
      saw_fast_back_to_back = frame_now & ~irdy_now;
// No clock here to let this dovetail with the next reference?
    end
    else
    begin  // no devsel, so it must have been an address parity error
      saw_fast_back_to_back = 1'b0;
    end
  end
endtask

// Task to print debug info
// NOTE This must change if bit allocation changes
task Report_Target_Reference_Paramaters;
  begin
    if (hold_target_address[23:9] != 15'h0000)
    begin
      $display ("  Target Devsel Speed %h, Target Termination %h,",
            hold_target_devsel_speed[1:0], hold_target_termination[2:0]);
      $display ("  First Target Data Wait States %h, Subsequent Target Data Wait States %h",
            hold_target_initial_waitstates[3:0],
            hold_target_subsequent_waitstates[3:0]);
      $display ("  Addr Par Error %h, Data Par Error %h",
            hold_target_addr_par_err, hold_target_data_par_err);
    end
    `NO_ELSE;
  end
endtask

task Reset_Target_To_Idle;
  begin
    Init_Test_Device_SRAM;
    target_ad_oe <= 1'b0;
    target_devsel_out <= 1'b0;
    target_trdy_out <= 1'b0;
    target_stop_out <= 1'b0;
    target_perr_check_next <= 1'b0;
    target_signaling_target_abort <= 1'b0;
    Delayed_Read_Started <= 1'b0;
    Delayed_Read_Finished <= 1'b0;
  end
endtask

// Config References are described in PCI Local Bus Spec
// Revision 2.2 section 3.2.2.3.4
// The idea is that a Config command must be seen, IDSEL must be LOW,
// AD[1:0] must be 2'b00, and either AD[10:8] should be ignored
//   for a single function device, or only implemented devices should
//   respond.  Function 0 is required to be detected.

// Make a fake version just to make the charts pop:

// Fire off Target tasks in response to PCI Bus Activity
  reg     saw_fast_back_to_back;
  always @(posedge pci_ext_clk or posedge pci_reset_comb)
  begin
    if (~pci_reset_comb)
    begin
      saw_fast_back_to_back = 1'b1;
      while (saw_fast_back_to_back == 1'b1)  // whats the value of this loop?  Does it reset correctly?
      begin
        hold_target_address[PCI_BUS_DATA_RANGE:0] = ad_now[PCI_BUS_DATA_RANGE:0];  // intentionally use "="
        hold_target_command[PCI_BUS_CBE_RANGE:0]  = cbe_l_now[PCI_BUS_CBE_RANGE:0];
        if (test_response[`TARGET_ENCODED_PARAMATERS_ENABLE] != 1'b0)
        begin
          hold_target_initial_waitstates    = test_response[`TARGET_ENCODED_INIT_WAITSTATES];
          hold_target_subsequent_waitstates = test_response[`TARGET_ENCODED_SUBS_WAITSTATES];
          hold_target_termination           = test_response[`TARGET_ENCODED_TERMINATION];
          hold_target_devsel_speed          = test_response[`TARGET_ENCODED_DEVSEL_SPEED];
          hold_target_data_par_err          = test_response[`TARGET_ENCODED_DATA_PAR_ERR];
          hold_target_addr_par_err          = test_response[`TARGET_ENCODED_ADDR_PAR_ERR];
          hold_target_terminate_on          = test_response[`TARGET_ENCODED_TERMINATE_ON];
        end
        else
        begin
          hold_target_initial_waitstates    = 4'h0;
          hold_target_subsequent_waitstates = 4'h0;
          hold_target_termination           = `Test_Target_Normal_Completion;
          hold_target_devsel_speed          = `Test_Devsel_Medium;
          hold_target_data_par_err          = `Test_No_Data_Perr;
          hold_target_addr_par_err          = `Test_No_Addr_Perr;
          hold_target_terminate_on          = 0 ;
        end

        if (~frame_prev & frame_now & Target_En
`ifdef SIMULTANEOUS_MASTER_TARGET
// don't check for reads to self
`else // SIMULTANEOUS_MASTER_TARGET
// check for, and don't respond to, reads to self
`endif //SIMULTANEOUS_MASTER_TARGET
            & (   (cbe_l_now[PCI_BUS_CBE_RANGE:0] == PCI_COMMAND_MEMORY_WRITE)
                | (cbe_l_now[PCI_BUS_CBE_RANGE:0] == PCI_COMMAND_MEMORY_WRITE_INVALIDATE) )
            & (   (ad_now[`PCI_BASE_ADDR0_MATCH_RANGE] == BAR0[`PCI_BASE_ADDR0_MATCH_RANGE])
`ifdef PCI_BASE_ADDR1_MATCH_ENABLE
                | (ad_now[`PCI_BASE_ADDR1_MATCH_RANGE] == BAR1[`PCI_BASE_ADDR1_MATCH_RANGE])
`endif  // PCI_BASE_ADDR1_MATCH_ENABLE
              ) )
        begin
          Execute_Target_PCI_Ref (`TEST_TARGET_DOING_SRAM_WRITE,
                                                 saw_fast_back_to_back);
        end
        else if (~frame_prev & frame_now & (idsel_now == 1'b1)
               & (cbe_l_now[PCI_BUS_CBE_RANGE:0] == PCI_COMMAND_CONFIG_WRITE)
               & (ad_now[1:0]  == 2'b00) )
        begin
          Execute_Target_PCI_Ref (`TEST_TARGET_DOING_CONFIG_WRITE,
                                                 saw_fast_back_to_back);
        end
        else if (~frame_prev & frame_now & Target_En &
                    (   
                        (cbe_l_now[PCI_BUS_CBE_RANGE:0] == PCI_COMMAND_INTERRUPT_ACKNOWLEDGE) |
                        (
                            (   
                                  (cbe_l_now[PCI_BUS_CBE_RANGE:0] == PCI_COMMAND_MEMORY_READ)
                                | (cbe_l_now[PCI_BUS_CBE_RANGE:0] == PCI_COMMAND_MEMORY_READ_MULTIPLE)
                                | (cbe_l_now[PCI_BUS_CBE_RANGE:0] == PCI_COMMAND_MEMORY_READ_LINE) 
                            ) 
                            &
                            (   
                                  (ad_now[`PCI_BASE_ADDR0_MATCH_RANGE] == BAR0[`PCI_BASE_ADDR0_MATCH_RANGE])
`ifdef PCI_BASE_ADDR1_MATCH_ENABLE
                                | (ad_now[`PCI_BASE_ADDR1_MATCH_RANGE] == BAR1[`PCI_BASE_ADDR1_MATCH_RANGE])
`endif  // PCI_BASE_ADDR1_MATCH_ENABLE
                            )
                        )
                    )
                )
        begin
          Execute_Target_PCI_Ref (`TEST_TARGET_DOING_SRAM_READ,
                                                 saw_fast_back_to_back);
        end
        else if (~frame_prev & frame_now & (idsel_now == 1'b1)
               & (cbe_l_now[PCI_BUS_CBE_RANGE:0] == PCI_COMMAND_CONFIG_READ)
               & (ad_now[1:0]  == 2'b00) )
        begin
          Execute_Target_PCI_Ref (`TEST_TARGET_DOING_CONFIG_READ,
                                                 saw_fast_back_to_back);
        end
        else
        begin
          saw_fast_back_to_back = 1'b0;
        end
        if (pci_reset_comb)
        begin
          saw_fast_back_to_back = 1'b0;
        end
      end  // saw_fast_back_to_back
    end
    `NO_ELSE;
// Because this is sequential code, have to reset all regs if the above falls
// through due to a reset.  This would not be needed in synthesizable code.
    if (pci_reset_comb)
    begin
      Reset_Target_To_Idle;
    end
    `NO_ELSE;
  end
endmodule

