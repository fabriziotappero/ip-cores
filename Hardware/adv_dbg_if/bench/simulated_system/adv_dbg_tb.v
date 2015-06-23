//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adv_dbg_tb.v                                                ////
////                                                              ////
////                                                              ////
////  Testbench for the SoC Advanced Debug Interface.             ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencored.org)                ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008        Authors                            ////
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
// $Log: adv_dbg_tb.v,v $
// Revision 1.7  2010-01-13 00:55:45  Nathan
// Created hi-speed mode for burst reads.  This will probably be most beneficial to the OR1K module, as GDB does a burst read of all the GPRs each time a microinstruction is single-stepped.
//
// Revision 1.2  2009/05/17 20:54:55  Nathan
// Changed email address to opencores.org
//
// Revision 1.1  2008/07/08 19:11:55  Nathan
// Added second testbench to simulate a complete system, including OR1200, wb_conbus, and onchipram.  Renamed sim-only testbench directory from verilog to simulated_system.
//
// Revision 1.11  2008/07/08 18:53:47  Nathan
// Fixed wrong include name.
//
// Revision 1.10  2008/06/30 20:09:19  Nathan
// Removed code to select top-level module as active (it served no purpose).  Re-numbered modules, requiring changes to testbench and software driver.
//


`include "tap_defines.v"
`include "adbg_defines.v"
`include "adbg_wb_defines.v"
`include "wb_model_defines.v"

// Polynomial for the CRC calculation
// Yes, it's backwards.  Yes, this is on purpose.
// To decrease logic + routing, we want to shift the CRC calculation
// in the same direction we use to shift the data out, LSB first.
`define DBG_CRC_POLY 32'hedb88320

// These are indicies into an array which hold values for the JTAG outputs
`define JTAG_TMS 0
`define JTAG_TCK 1
`define JTAG_TDO 2

`define JTAG_TMS_bit 3'h1
`define JTAG_TCK_bit 3'h2
`define JTAG_TDO_bit 3'h4

`define wait_jtag_period #50


module adv_debug_tb; 

// Connections to the JTAG TAP
reg jtag_tck_o;
reg jtag_tms_o;
reg jtag_tdo_o;
wire jtag_tdi_i;

// Connections between TAP and debug module
wire capture_dr;
wire shift_dr;
wire pause_dr;
wire update_dr;
wire dbg_rst;
wire dbg_tdi;
wire dbg_tdo;
wire dbg_sel;

// Connections between the debug module and the wishbone
`ifdef DBG_WISHBONE_SUPPORTED
wire [31:0] wb_adr;
wire [31:0] wb_dat_m;
wire [31:0] wb_dat_s;
wire wb_cyc;
wire wb_stb;
wire [3:0] wb_sel;
wire wb_we;
wire wb_ack;
wire wb_err;
reg wb_clk_i;  // the wishbone clock
reg wb_rst_i;
`endif

`ifdef DBG_CPU0_SUPPORTED
wire cpu0_clk;
wire [31:0]cpu0_addr;
wire [31:0] cpu0_data_c;
wire [31:0] cpu0_data_d;
wire cpu0_bp;
wire cpu0_stall;
wire cpu0_stb;
wire cpu0_we;
wire cpu0_ack;
wire cpu0_rst;
`endif

`ifdef DBG_CPU1_SUPPORTED
reg cpu1_clk;
wire [31:0]cpu1_addr;
wire [31:0] cpu1_data_c;
wire [31:0] cpu1_data_d;
wire cpu1_bp;
wire cpu1_stall;
wire cpu1_stb;
wire cpu1_we;
wire cpu1_ack;
wire cpu1_rst;
`endif //  `ifdef DBG_CPU1_SUPPORTED
   
reg test_enabled;

// Data which will be written to the WB interface
reg [31:0] static_data32 [0:15]; 
reg [15:0] static_data16 [0:15];
reg [7:0] static_data8 [0:15];

// Arrays to hold data read back from the WB interface, for comparison
reg [31:0] input_data32 [0:15]; 
reg [15:0] input_data16 [0:15];
reg [7:0]  input_data8 [0:15];                                

reg [32:0] err_data;  // holds the contents of the error register from the various modules

reg failed;
integer i;

initial
begin
   jtag_tck_o = 1'b0;
   jtag_tms_o = 1'b0;
   jtag_tdo_o = 1'b0;
end

// Provide the wishbone clock
`ifdef DBG_WISHBONE_SUPPORTED
initial
begin
  wb_clk_i = 1'b0;
  forever #7 wb_clk_i = ~wb_clk_i;  // Odd frequency ratio to test the synchronization
end
`endif

// Provide the CPU0 clock
//`ifdef DBG_CPU0_SUPPORTED
//initial
//begin
  //cpu0_clk = 1'b0;
  //forever #6 cpu0_clk = ~cpu0_clk;  // Odd frequency ratio to test the synchronization
//end
//`endif

// Start the test (and reset the wishbone)
initial
begin
  test_enabled = 1'b0;
  wb_rst_i = 1'b0;
  #100;
  wb_rst_i = 1'b1;
  #100;
  wb_rst_i = 1'b0;

   // Init the memory
  initialize_memory(32'h0,32'h16);
  
  // Init the WB model
  i_wb.cycle_response(`ACK_RESPONSE, 2, 0);  // response type, wait cycles, retry_cycles

  #1 test_enabled<=#1 1'b1;
end

// This is the main test procedure
always @ (posedge test_enabled)
begin

  $display("Starting advanced debug test");
  
  reset_jtag;
  #1000;
  check_idcode;
  #1000;
  
  // Select the debug module in the IR
  set_ir(`DEBUG);
  #1000;
  
  
  ///////////////////////////////////////////////////////////////////
  // Test CPU0 unit
  ////////////////////////////////////////////////////////////////////
`ifdef DBG_CPU0_SUPPORTED
  // Select the CPU0 unit in the debug module
  #1000; 
  $display("Selecting CPU0 module at time %t", $time);
  select_debug_module(`DBG_TOP_CPU0_DEBUG_MODULE);

   // Test reset, stall bits
   #1000;
   $display("Testing CPU0 intreg select at time %t", $time);
   select_module_internal_register(32'h1, 1);  // Really just a read, with discarded data
   #1000;
   select_module_internal_register(32'h0, 1);  // Really just a read, with discarded data
   #1000;
    
   // Read the stall and reset bits
   $display("Testing reset and stall bits at time %t", $time);
   read_module_internal_register(8'd2, err_data);  // We assume the register is already selected
   $display("Reset and stall bits are %x", err_data);
   #1000;
    
   //  Set rst/stall bits
   $display("Setting reset and stall bits at time %t", $time);    
    write_module_internal_register(32'h0, 8'h1, 32'h3, 8'h2);  // idx, idxlen, data, datalen
   #1000;
   
   // Read the bits again
   $display("Testing reset and stall bits again at time %t", $time);
   read_module_internal_register(8'd2, err_data);  // We assume the register is already selected
   $display("Reset and stall bits are %x", err_data);
   #1000;
   
   // Clear the bits
      $display("Clearing reset and stall bits at time %t", $time);    
    write_module_internal_register(32'h0, 8'h1, 32'h0, 8'h2);  // idx, idxlen, data, datalen
   #1000;
   
      // Read the bits again
   $display("Testing reset and stall bits again at time %t", $time);
   read_module_internal_register(8'd2, err_data);  // We assume the register is already selected
   $display("Reset and stall bits are %x", err_data);
   #1000;
   
   // Behavioral CPU model must be stalled in order to do SPR access
   //$display("Setting reset and stall bits at time %t", $time);    
   write_module_internal_register(32'h0, 8'h1, 32'h1, 8'h2);  // idx, idxlen, data, datalen
   #1000;
   
   // Test SPR bus access
  $display("Testing CPU0 32-bit burst write at time %t", $time);
  do_module_burst_write(3'h4, 16'd16, 32'h10);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
  #1000;
  $display("Testing CPU0 32-bit burst read at time %t", $time);
  do_module_burst_read(3'h4, 16'd16, 32'h0);
  #1000;

`endif

  
  ///////////////////////////////////////////////////////////////////
  // Test the Wishbone unit
  ////////////////////////////////////////////////////////////////////
  
`ifdef DBG_WISHBONE_SUPPORTED
  // Select the WB unit in the debug module
  #1000; 
  $display("Selecting Wishbone module at time %t", $time);
  select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
  
  /*
  // Test error conditions
  #1000; 
  $display("Testing error (size 0 WB burst write) at time %t", $time);
  do_module_burst_write(3'h1, 16'h0, 32'h0);  // 0-word write = error, ignored
  #1000; 
  $display("Testing error (size 0 WB burst read) at time %t", $time);
  do_module_burst_read(3'h1, 16'h0, 32'h0);  // 0-word read = error, ignored
  
  // Test NOP (a zero in the MSB, then a NOP opcode)
  #1000;
  $display("Testing NOP at time %t", $time);
    write_bit(`JTAG_TMS_bit);  // select_dr_scan
    write_bit(3'h0);           // capture_ir
    write_bit(3'h0);           // shift_ir
    jtag_write_stream(5'h0, 8'h5, 1);  // write data, exit_1
    write_bit(`JTAG_TMS_bit);  // update_dr
    write_bit(3'h0);           // idle
    #1000;
    */   
    
    /*
    #1000;
     $display("Testing WB intreg select at time %t", $time);
    select_module_internal_register(32'h1, 1);  // Really just a read, with discarded data
    #1000;
     select_module_internal_register(32'h0, 1);  // Really just a read, with discarded data
   #1000;
    
   // Reset the error bit    
    write_module_internal_register(32'h0, 8'h1, 32'h1, 8'h1);  // idx, idxlen, data, datalen
   #1000;
   
   // Read the error bit
   read_module_internal_register(8'd33, err_data);  // We assume the register is already selected
   #1000;
*/
    
  /////////////////////////////////
  // Test 8-bit WB access
  failed = 0;
  $display("Testing WB 8-bit burst write at time %t: resetting ", $time);
  do_module_burst_write(3'h1, 16'd16, 32'h0);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
  #1000;
  $display("Testing WB 8-bit burst read at time %t", $time);
  do_module_burst_read(3'h1, 16'd16, 32'h0);
  #1000;
   for(i = 0; i < 16; i = i+1) begin
     if(static_data8[i] != input_data8[i]) begin 
        failed = 1;
        $display("32-bit data mismatch at index %d, wrote 0x%x, read 0x%x", i, static_data8[i], input_data8[i]);
    end
  end
  if(!failed) $display("8-bit read/write OK!");
  
   /* try it unaligned
  do_module_burst_write(3'h1, 16'd5, 32'h3);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
    #1000;
  do_module_burst_read(3'h1, 16'd4, 32'h4);
    #1000;
  */
  
  /////////////////////////////////
  // Test 16-bit WB access
  failed = 0;
  $display("Testing WB 16-bit burst write at time %t", $time);
  do_module_burst_write(3'h2, 16'd16, 32'h0);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
  #1000;
  $display("Testing WB 16-bit burst read at time %t", $time);
  do_module_burst_read(3'h2, 16'd16, 32'h0);
  #1000;
   for(i = 0; i < 16; i = i+1) begin
     if(static_data16[i] != input_data16[i]) begin 
        failed = 1;
        $display("16-bit data mismatch at index %d, wrote 0x%x, read 0x%x", i, static_data16[i], input_data16[i]);
    end
  end
  if(!failed) $display("16-bit read/write OK!");
  
   /* try it unaligned
  do_module_burst_write(3'h2, 16'd5, 32'h2);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
    #1000;
  do_module_burst_read(3'h2, 16'd4, 32'h4);
    #1000;
  */
  
  ////////////////////////////////////
  // Test 32-bit WB access
  failed = 0;
  $display("Testing WB 32-bit burst write at time %t", $time);
  do_module_burst_write(3'h4, 16'd16, 32'h0);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
  #1000;
  $display("Testing WB 32-bit burst read at time %t", $time);
  do_module_burst_read(3'h4, 16'd16, 32'h0);
  #1000;
   for(i = 0; i < 16; i = i+1) begin
     if(static_data32[i] != input_data32[i]) begin 
        failed = 1;
        $display("32-bit data mismatch at index %d, wrote 0x%x, read 0x%x", i, static_data32[i], input_data32[i]);
    end
  end
  if(!failed) $display("32-bit read/write OK!");
    
  /* Try another address
  do_module_burst_write(3'h4, 16'd16, 32'h200);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
    #1000;
  do_module_burst_read(3'h4, 16'd15, 32'h204);
    #1000;
  */
  
  ////////////////////////////////
  // Test error register
  err_data = 33'h0;
  // Select and reset the error register
  write_module_internal_register(`DBG_WB_INTREG_ERROR, `DBG_WB_REGSELECT_SIZE, 64'h1, 8'h1); // regidx,idxlen,writedata, datalen;
  i_wb.cycle_response(`ERR_RESPONSE, 2, 0);  // response type, wait cycles, retry_cycles
  do_module_burst_write(3'h4, 16'd4, 32'hdeaddead);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
  read_module_internal_register(8'd33, err_data);  // get the error register
  $display("Error bit is %d, error address is %x", err_data[0], err_data>>1);

`endif  // WB module supported
  
end

task initialize_memory;
  input [31:0] start_addr;
  input [31:0] length;
  integer i;
  reg [31:0] addr;
  begin

    for (i=0; i<length; i=i+1)
      begin
        static_data32[i] <= {i[7:0], i[7:0]+2'd1, i[7:0]+2'd2, i[7:0]+2'd3};
        static_data16[i] <= {i[7:0], i[7:0]+ 2'd1};
        static_data8[i] <= i[7:0];
      end
  end
endtask

///////////////////////////////////////////////////////////////////////////////
// Declaration and interconnection of components

// Top module
tap_top  i_tap (
                // JTAG pads
                .tms_pad_i(jtag_tms_o), 
                .tck_pad_i(jtag_tck_o), 
                .trstn_pad_i(1'b1), 
                .tdi_pad_i(jtag_tdo_o), 
                .tdo_pad_o(jtag_tdi_i), 
                .tdo_padoe_o(),

                // TAP states
				    .test_logic_reset_o(dbg_rst),
				    .run_test_idle_o(),
                .shift_dr_o(shift_dr),
                .pause_dr_o(pause_dr), 
                .update_dr_o(update_dr),
                .capture_dr_o(capture_dr),
                
                // Select signals for boundary scan or mbist
                .extest_select_o(), 
                .sample_preload_select_o(),
                .mbist_select_o(),
                .debug_select_o(dbg_sel),
                
                // TDO signal that is connected to TDI of sub-modules.
                .tdi_o(dbg_tdo), 
                
                // TDI signals from sub-modules
                .debug_tdo_i(dbg_tdi),    // from debug module
                .bs_chain_tdo_i(1'b0), // from Boundary Scan Chain
                .mbist_tdo_i(1'b0)     // from Mbist Chain
              );


// Top module
adbg_top i_dbg_module(
                // JTAG signals
                .tck_i(jtag_tck_o),
                .tdi_i(dbg_tdo),
                .tdo_o(dbg_tdi),
                .rst_i(dbg_rst),

                // TAP states
                .shift_dr_i(shift_dr),
                .pause_dr_i(pause_dr),
                .update_dr_i(update_dr),
                .capture_dr_i(capture_dr),

                // Instructions
                .debug_select_i(dbg_sel)


                `ifdef DBG_WISHBONE_SUPPORTED
                // WISHBONE common signals
                ,
                .wb_clk_i(wb_clk_i),
                                                                                
                // WISHBONE master interface
                .wb_adr_o(wb_adr),
                .wb_dat_o(wb_dat_m),
                .wb_dat_i(wb_dat_s),
                .wb_cyc_o(wb_cyc),
                .wb_stb_o(wb_stb),
                .wb_sel_o(wb_sel),
                .wb_we_o(wb_we),
                .wb_ack_i(wb_ack),
                .wb_cab_o(),
                .wb_err_i(wb_err),
                .wb_cti_o(),
                .wb_bte_o()
                `endif

                `ifdef DBG_CPU0_SUPPORTED
                // CPU signals
                ,
                .cpu0_clk_i(cpu0_clk),
                .cpu0_addr_o(cpu0_addr), 
                .cpu0_data_i(cpu0_data_c),
                .cpu0_data_o(cpu0_data_d),
                .cpu0_bp_i(cpu0_bp),
                .cpu0_stall_o(cpu0_stall),
                .cpu0_stb_o(cpu0_stb),
                .cpu0_we_o(cpu0_we),
                .cpu0_ack_i(cpu0_ack),
                .cpu0_rst_o(cpu0_rst)
                `endif

                `ifdef DBG_CPU1_SUPPORTED
                // CPU signals
                ,
                .cpu1_clk_i(cpu1_clk), 
                .cpu1_addr_o(cpu1_addr), 
                .cpu1_data_i(cpu1_data_c),
                .cpu1_data_o(cpu1_data_d),
                .cpu1_bp_i(cpu1_bp),
                .cpu1_stall_o(cpu1_stall),
                .cpu1_stb_o(cpu1_stb),
                .cpu1_we_o(cpu1_we),
                .cpu1_ack_i(cpu1_ack),
                .cpu1_rst_o(cpu1_rst)
                `endif

              );


`ifdef DBG_WISHBONE_SUPPORTED
// The 'wishbone' may be just a p2p connection to a simple RAM
/*
onchip_ram_top i_ocram (
   .wb_clk_i(wb_clk_i), 
   .wb_rst_i(wb_rst_i),
   .wb_dat_i(wb_dat_m),
   .wb_dat_o(wb_dat_s),
   .wb_adr_i(wb_adr[11:0]), 
   .wb_sel_i(wb_sel),
   .wb_we_i(wb_we),
   .wb_cyc_i(wb_cyc),
   .wb_stb_i(wb_stb),
   .wb_ack_o(wb_ack),
   .wb_err_o(wb_err)
);
*/

wb_slave_behavioral i_wb
(
	.CLK_I(wb_clk_i),
	.RST_I(wb_rst_i),
	.ACK_O(wb_ack),
	.ADR_I(wb_adr),
	.CYC_I(wb_cyc),
	.DAT_O(wb_dat_s),
	.DAT_I(wb_dat_m),
	.ERR_O(wb_err),
	.RTY_O(),
	.SEL_I(wb_sel),
	.STB_I(wb_stb),
	.WE_I(wb_we),
	.CAB_I(1'b0)
);
`endif


`ifdef DBG_CPU0_SUPPORTED
// Instantiate a behavioral model of the CPU SPR bus
cpu_behavioral cpu0_i  (
   .cpu_rst_i(cpu0_rst),
   .cpu_clk_o(cpu0_clk),
   .cpu_addr_i(cpu0_addr),
   .cpu_data_o(cpu0_data_c),
   .cpu_data_i(cpu0_data_d),
   .cpu_bp_o(cpu0_bp),
   .cpu_stall_i(cpu0_stall),
   .cpu_stb_i(cpu0_stb),
   .cpu_we_i(cpu0_we),
   .cpu_ack_o(cpu0_ack),
   .cpu_rst_o(cpu0_rst)
);

`endif


`ifdef DBG_CPU1_SUPPORTED
// Instantiate a behavioral model of the CPU SPR bus
cpu_behavioral cpu1_i  (
		    .cpu_rst_i(cpu1_rst),
                    .cpu_clk_o(cpu1_clk),
                    .cpu_addr_i(cpu1_addr),
                    .cpu_data_o(cpu1_data_c),
                    .cpu_data_i(cpu1_data_d),
                    .cpu_bp_o(cpu1_bp),
                    .cpu_stall_i(cpu1_stall),
                    .cpu_stb_i(cpu1_stb),
                    .cpu_we_i(cpu1_we),
                    .cpu_ack_o(cpu1_ack),
                    .cpu_rst_o(cpu1_rst)
);
`endif
   
///////////////////////////////////////////////////////////////////////////
// Higher-level chain manipulation functions

// calculate the CRC, up to 32 bits at a time
task compute_crc;
    input [31:0] crc_in;
    input [31:0] data_in;
    input [5:0] length_bits;
    output [31:0] crc_out;
    integer i;
    reg [31:0] d;
    reg [31:0] c;
    begin
        crc_out = crc_in;
        for(i = 0; i < length_bits; i = i+1) begin
           d = (data_in[i]) ? 32'hffffffff : 32'h0;
           c = (crc_out[0]) ? 32'hffffffff : 32'h0;
           //crc_out = {crc_out[30:0], 1'b0};  // original
           crc_out = crc_out >> 1;
           crc_out = crc_out ^ ((d ^ c) & `DBG_CRC_POLY);
           //$display("CRC Itr %d, inbit = %d, crc = 0x%x", i, data_in[i], crc_out);
        end
    end
endtask

task check_idcode;
reg [63:0] readdata;
reg[31:0] idcode;
begin
    set_ir(`IDCODE);
    
    // Read the IDCODE in the DR
    write_bit(`JTAG_TMS_bit);  // select_dr_scan
    write_bit(3'h0);           // capture_ir
    write_bit(3'h0);           // shift_ir
    jtag_read_write_stream(64'h0, 8'd32, 1, readdata);  // write data, exit_1
    write_bit(`JTAG_TMS_bit);  // update_ir
    write_bit(3'h0);           // idle
    idcode = readdata[31:0];
    $display("Got TAP IDCODE 0x%x, expected 0x%x", idcode, `IDCODE_VALUE);
end
endtask;

task select_debug_module;
input [1:0] moduleid;
reg validid;
begin
    write_bit(`JTAG_TMS_bit);  // select_dr_scan
    write_bit(3'h0);           // capture_ir
    write_bit(3'h0);           // shift_ir
    jtag_write_stream({1'b1,moduleid}, 8'h3, 1);  // write data, exit_1
    write_bit(`JTAG_TMS_bit);  // update_dr
    write_bit(3'h0);           // idle
    
    $display("Selecting module (%0x)", moduleid);
    
    // Read back the status to make sure a valid chain is selected
    /* Pointless, the newly selected module would respond instead...
    write_bit(`JTAG_TMS_bit);  // select_dr_scan
    write_bit(3'h0);           // capture_ir
    write_bit(3'h0);           // shift_ir
    read_write_bit(`JTAG_TMS_bit, validid);  // get data, exit_1
    write_bit(`JTAG_TMS_bit);  // update_dr
    write_bit(3'h0);           // idle
    
    if(validid)   $display("Selected valid module (%0x)", moduleid);
    else          $display("Failed to select module (%0x)", moduleid);
    */
end
endtask


task send_module_burst_command;
input [3:0] opcode;
input [31:0] address;
input [15:0] burstlength;
reg [63:0] streamdata;
begin
    streamdata = {11'h0,1'b0,opcode,address,burstlength};
    write_bit(`JTAG_TMS_bit);  // select_dr_scan
    write_bit(3'h0);           // capture_ir
    write_bit(3'h0);           // shift_ir
    jtag_write_stream(streamdata, 8'd53, 1);  // write data, exit_1
    write_bit(`JTAG_TMS_bit);  // update_dr
    write_bit(3'h0);           // idle
end
endtask

task select_module_internal_register;  // Really just a read, with discarded data
    input [31:0] regidx;
    input [7:0] len;  // the length of the register index data, we assume not more than 32
    reg[63:0] streamdata;
begin
    streamdata = 64'h0;
    streamdata = streamdata | regidx;
    streamdata = streamdata | (`DBG_WB_CMD_IREG_SEL << len);
    write_bit(`JTAG_TMS_bit);  // select_dr_scan
    write_bit(3'h0);           // capture_ir
    write_bit(3'h0);           // shift_ir
    jtag_write_stream(streamdata, (len+5), 1);  // write data, exit_1
    write_bit(`JTAG_TMS_bit);  // update_dr
    write_bit(3'h0);           // idle
end
endtask
        

task read_module_internal_register;  // We assume the register is already selected
    //input [31:0] regidx;
    input [7:0] len;  // the length of the data desired, we assume a max of 64 bits
    output [63:0] instream;
    reg [63:0] bitmask;
begin
    instream = 64'h0;
    // We shift out all 0's, which is a NOP to the debug unit
    write_bit(`JTAG_TMS_bit);  // select_dr_scan
    write_bit(3'h0);           // capture_ir
    write_bit(3'h0);           // shift_ir
    // Shift at least 5 bits, as this is the min, for a valid NOP
    jtag_read_write_stream(64'h0, len+4,1,instream);  // exit_1
    write_bit(`JTAG_TMS_bit);  // update_dr
    write_bit(3'h0);           // idle
    bitmask = 64'hffffffffffffffff;
    bitmask = bitmask << len;
    bitmask = ~bitmask;
    instream = instream & bitmask;  // Cut off any unwanted excess bits
end
endtask

task write_module_internal_register;
    input [31:0] regidx; // the length of the register index data
    input [7:0] idxlen;
    input [63:0] writedata;
    input [7:0] datalen;  // the length of the data to write.  We assume the two length combined are 59 or less.
    reg[63:0] streamdata;
begin
    streamdata = 64'h0;  // This will 0 the toplevel/module select bit
    streamdata = streamdata | writedata;
    streamdata = streamdata | (regidx << datalen);
    streamdata = streamdata | (`DBG_WB_CMD_IREG_WR << (idxlen+datalen));
    
    write_bit(`JTAG_TMS_bit);  // select_dr_scan
    write_bit(3'h0);           // capture_ir
    write_bit(3'h0);           // shift_ir
    jtag_write_stream(streamdata, (idxlen+datalen+5), 1);  // write data, exit_1
    write_bit(`JTAG_TMS_bit);  // update_dr
    write_bit(3'h0);           // idle
end
endtask

// This includes the sending of the burst command
task do_module_burst_read;
input [5:0] word_size_bytes;
input [15:0] word_count;
input [31:0] start_address;
reg [3:0] opcode;
reg status;
reg [63:0] instream;
integer i;
integer j;
reg [31:0] crc_calc_i;
reg [31:0] crc_calc_o;  // temp signal...
reg [31:0] crc_read;
reg [5:0] word_size_bits;
begin
    $display("Doing burst read, word size %d, word count %d, start address 0x%x", word_size_bytes, word_count, start_address);
    instream = 64'h0;
    word_size_bits = word_size_bytes << 3;
    crc_calc_i = 32'hffffffff;
    
    // Send the command
    case (word_size_bytes)
       3'h1: opcode = `DBG_WB_CMD_BREAD8;
       3'h2: opcode = `DBG_WB_CMD_BREAD16;
       3'h4: opcode = `DBG_WB_CMD_BREAD32;
       default:
          begin
           $display("Tried burst read with invalid word size (%0x), defaulting to 4-byte words", word_size_bytes);
           opcode = `DBG_WB_CMD_BREAD32;
          end
   endcase
   
   send_module_burst_command(opcode,start_address, word_count);  // returns to state idle
   
   // Get us back to shift_dr mode to read a burst
   write_bit(`JTAG_TMS_bit);  // select_dr_scan
   write_bit(3'h0);           // capture_ir
   write_bit(3'h0);           // shift_ir

`ifdef ADBG_USE_HISPEED
      // Get 1 status bit, then word_size_bytes*8 bits
      status = 1'b0;
      j = 0;
      while(!status) begin
         read_write_bit(3'h0, status);
         j = j + 1;
      end
      
      if(j > 1) begin
         $display("Took %0d tries before good status bit during burst read", j);
      end
`endif
   
   // Now, repeat...
   for(i = 0; i < word_count; i=i+1) begin
     
`ifndef ADBG_USE_HISPEED     
      // Get 1 status bit, then word_size_bytes*8 bits
      status = 1'b0;
      j = 0;
      while(!status) begin
         read_write_bit(3'h0, status);
         j = j + 1;
      end
      
      if(j > 1) begin
         $display("Took %0d tries before good status bit during burst read", j);
      end
`endif
  
     jtag_read_write_stream(64'h0, {2'h0,(word_size_bytes<<3)},0,instream);
     //$display("Read 0x%0x", instream[31:0]);
     compute_crc(crc_calc_i, instream[31:0], word_size_bits, crc_calc_o);
     crc_calc_i = crc_calc_o;
     if(word_size_bytes == 1) input_data8[i] = instream[7:0];
     else if(word_size_bytes == 2) input_data16[i] = instream[15:0];
     else input_data32[i] = instream[31:0];
   end
    
   // Read the data CRC from the debug module.
   jtag_read_write_stream(64'h0, 6'd32, 1, crc_read);
   if(crc_calc_o != crc_read) $display("CRC ERROR! Computed 0x%x, read CRC 0x%x", crc_calc_o, crc_read);
   else $display("CRC OK!");
    
   // Finally, shift out 5 0's, to make the next command a NOP
   // Not necessary, debug unit won't latch a new opcode at the end of a burst
   //jtag_write_stream(64'h0, 8'h5, 1);
   write_bit(`JTAG_TMS_bit);  // update_ir
   write_bit(3'h0);           // idle
end
endtask


task do_module_burst_write;
input [5:0] word_size_bytes;
input [15:0] word_count;
input [31:0] start_address;
reg [3:0] opcode;
reg status;
reg [63:0] dataword;
integer i;
integer j;
reg [31:0] crc_calc_i;
reg [31:0] crc_calc_o;
reg crc_match;
reg [5:0] word_size_bits;
begin
    $display("Doing burst write, word size %d, word count %d, start address 0x%x", word_size_bytes, word_count, start_address);
    word_size_bits = word_size_bytes << 3;
    crc_calc_i = 32'hffffffff;
    
    // Send the command
    case (word_size_bytes)
       3'h1: opcode = `DBG_WB_CMD_BWRITE8;
       3'h2: opcode = `DBG_WB_CMD_BWRITE16;
       3'h4: opcode = `DBG_WB_CMD_BWRITE32;
       default:
          begin
           $display("Tried burst write with invalid word size (%0x), defaulting to 4-byte words", word_size_bytes);
           opcode = `DBG_WB_CMD_BWRITE32;
          end
   endcase
   
   send_module_burst_command(opcode, start_address, word_count);  // returns to state idle
   
   // Get us back to shift_dr mode to write a burst
   write_bit(`JTAG_TMS_bit);  // select_dr_scan
   write_bit(3'h0);           // capture_ir
   write_bit(3'h0);           // shift_ir
   

   // Write a start bit (a 1) so it knows when to start counting
   write_bit(`JTAG_TDO_bit);

   // Now, repeat...
   for(i = 0; i < word_count; i=i+1) begin
      // Write word_size_bytes*8 bits, then get 1 status bit
      if(word_size_bytes == 4)      dataword = {32'h0, static_data32[i]};
      else if(word_size_bytes == 2) dataword = {48'h0, static_data16[i]};
      else                          dataword = {56'h0, static_data8[i]};
      
      
      jtag_write_stream(dataword, {2'h0,(word_size_bytes<<3)},0);
      compute_crc(crc_calc_i, dataword[31:0], word_size_bits, crc_calc_o);
      crc_calc_i = crc_calc_o;
      
      
`ifndef ADBG_USE_HISPEED
      // Check if WB bus is ready
      // *** THIS WILL NOT WORK IF THERE IS MORE THAN 1 DEVICE IN THE JTAG CHAIN!!!
      status = 1'b0;
      read_write_bit(3'h0, status);
      
      if(!status) begin
         $display("Bad status bit during burst write, index %d", i);
      end
`endif      
  
     //$display("Wrote 0x%0x", dataword);
   end
    
   // Send the CRC we computed
   jtag_write_stream(crc_calc_o, 6'd32,0);
   
   // Read the 'CRC match' bit, and go to exit1_dr
   read_write_bit(`JTAG_TMS_bit, crc_match);
   if(!crc_match) $display("CRC ERROR! match bit after write is %d (computed CRC 0x%x)", crc_match, crc_calc_o);
   else $display("CRC OK!");
    
   // Finally, shift out 5 0's, to make the next command a NOP
   // Not necessary, module will not latch new opcode during burst
   //jtag_write_stream(64'h0, 8'h5, 1);
   write_bit(`JTAG_TMS_bit);  // update_ir
   write_bit(3'h0);           // idle
end

endtask


// Puts a value in the TAP IR, assuming we start in IDLE state.
// Returns to IDLE state when finished
task set_ir;
input [3:0] irval;
begin
    write_bit(`JTAG_TMS_bit);  // select_dr_scan
    write_bit(`JTAG_TMS_bit);  // select_ir_scan
    write_bit(3'h0);           // capture_ir
    write_bit(3'h0);           // shift_ir
    jtag_write_stream({60'h0,irval}, 8'h4, 1);  // write data, exit_1
    write_bit(`JTAG_TMS_bit);  // update_ir
    write_bit(3'h0);           // idle
end
endtask

// Resets the TAP and puts it into idle mode
task reset_jtag;
integer i;
begin
   for(i = 0; i < 8; i=i+1) begin
      write_bit(`JTAG_TMS_bit);  // 5 TMS should put us in test_logic_reset mode
   end
   write_bit(3'h0);              // idle
end
endtask


////////////////////////////////////////////////////////////////////////////
// Tasks to write or read-write a string of data

task jtag_write_stream;
input [63:0] stream;
input [7:0] len;
input set_last_bit;
integer i;
integer databit;
reg [2:0] bits;
begin
    for(i = 0; i < (len-1); i=i+1) begin
       databit = (stream >> i) & 1'h1;
       bits = databit << `JTAG_TDO;
       write_bit(bits);
   end
   
   databit = (stream >> i) & 1'h1;
   bits = databit << `JTAG_TDO;
   if(set_last_bit) bits = (bits | `JTAG_TMS_bit);
   write_bit(bits);
    
end
endtask


task jtag_read_write_stream;
input [63:0] stream;
input [7:0] len;
input set_last_bit;
output [63:0] instream;
integer i;
integer databit;
reg [2:0] bits;
reg inbit;
begin
    instream = 64'h0;
    for(i = 0; i < (len-1); i=i+1) begin
       databit = (stream >> i) & 1'h1;
       bits = databit << `JTAG_TDO;
       read_write_bit(bits, inbit);
       instream = (instream | (inbit << i));
   end
   
   databit = (stream >> i) & 1'h1;
   bits = databit << `JTAG_TDO;
   if(set_last_bit) bits = (bits | `JTAG_TMS_bit);
   read_write_bit(bits, inbit);
   instream = (instream | (inbit << (len-1)));
end
endtask

/////////////////////////////////////////////////////////////////////////
// Tasks which write or readwrite a single bit (including clocking)

task write_bit;
   input [2:0] bitvals;
   begin
       
   // Set data
   jtag_out(bitvals & ~(`JTAG_TCK_bit));
   `wait_jtag_period;
   
   // Raise clock
   jtag_out(bitvals | `JTAG_TCK_bit);
   `wait_jtag_period;
   
   // drop clock (making output available in the SHIFT_xR states)
   jtag_out(bitvals & ~(`JTAG_TCK_bit));
   `wait_jtag_period;
   end
endtask

task read_write_bit;
   input [2:0] bitvals;
   output l_tdi_val;
   begin
       
   // read bit state
   l_tdi_val <= jtag_tdi_i;
   
   // Set data
   jtag_out(bitvals & ~(`JTAG_TCK_bit));
   `wait_jtag_period;
   
   // Raise clock
   jtag_out(bitvals | `JTAG_TCK_bit);
   `wait_jtag_period;
   
   // drop clock (making output available in the SHIFT_xR states)
   jtag_out(bitvals & ~(`JTAG_TCK_bit));
   `wait_jtag_period;
   end
endtask

/////////////////////////////////////////////////////////////////
// Basic functions to set the state of the JTAG TAP I/F bits

task jtag_out;
  input   [2:0]   bitvals;
  begin

   jtag_tck_o <= bitvals[`JTAG_TCK]; 
   jtag_tms_o <= bitvals[`JTAG_TMS]; 
   jtag_tdo_o <= bitvals[`JTAG_TDO]; 
   end
endtask


task jtag_inout;
  input   [2:0]   bitvals;
  output l_tdi_val;
  begin

   jtag_tck_o <= bitvals[`JTAG_TCK]; 
   jtag_tms_o <= bitvals[`JTAG_TMS]; 
   jtag_tdo_o <= bitvals[`JTAG_TDO]; 

   l_tdi_val <= jtag_tdi_i;
   end
endtask

endmodule