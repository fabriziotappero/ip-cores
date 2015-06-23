//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adv_dbg_tb.v                                                ////
////                                                              ////
////                                                              ////
////  Testbench for the SoC Advanced Debug Interface.             ////
////  This testbench specifically tests the JTAG serial port      ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencored.org)                ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010        Authors                            ////
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



`include "tap_defines.v"
`include "adbg_defines.v"
`include "adbg_wb_defines.v"

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

wire jsp_int;
   
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

reg [63:0] jsp_data8;
    
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

  #1 test_enabled<=#1 1'b1;
end

// This is the main test procedure
always @ (posedge test_enabled)
begin

  $display("Starting advanced debug JTAG serial port test");
  
  reset_jtag;
  #1000;
  check_idcode;
  #1000;
  
  // Select the debug module in the IR
  set_ir(`DEBUG);
  #1000;

  
  ///////////////////////////////////////////////////////////////////
  // Test the JTAG serial port.  We use the debug unit WB interface
  // to act as the CPU/WB master. 
  ////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////
  // Do an 8 byte transfer, JSP->WB
  
  $display("-------------------------------------------");
  $display("--- Test 1: 8 bytes JSP->WB");
  
    // Write 8 bytes from JTAG to WB 
    $display("Selecting JSP module at time %t", $time);
   select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
   #200
   $display("JTAG putting 8 bytes to JSP module at time %t", $time);
   do_jsp_read_write(4'h8,jsp_data8);  // 4 bits words to write, 64 bits output data
   // data returned in input_data8[]
    
   // Select the WB unit in the debug module, read the data written
   #1000; 
   $display("Selecting Wishbone module at time %t", $time);
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
  failed <= 1'b0;
   for(i = 0; i < 8; i=i+1) begin
      do_module_burst_read(3'h1, 16'd1, 32'h0);
      //$display("WB read got 0x%x", input_data8[0]);
      if(input_data8[0] != i) begin 
        failed = 1;
        $display("JSP-to-WB data mismatch at index %d, wrote 0x%x, read 0x%x", i, i, input_data8[i]);
      //$display("JTAG read got 0x%x", input_data8[i]);
      end

    end
    if(!failed) $display("WB-to-JSP data: 8 bytes OK! Test 1 passed!");

 /////////////////////////////////////////////////////  
 // Do an 8-byte transfer, WB->JSP
 
   $display("-------------------------------------------");
  $display("--- Test 2: 8 bytes WB->JSP");
  
   // Put 8 bytes from the WB into the JSP
   #1000
  $display("WB putting 8 bytes to JSP module at time %t", $time);
  for(i = 0; i < 8; i=i+1) begin
     static_data8[0] = i;
     do_module_burst_write(3'h1, 16'd1, 32'h0);
  end

   // Get 8 bytes from the JSP
   #1000
   $display("Selecting JSP module at time %t", $time);
   select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
   #1000
   $display("JTAG getting 8 bytes from JSP module at time %t", $time);
   do_jsp_read_write(4'h0,jsp_data8);  // 4 bits words to write, 64 bits output data
   // data returned in input_data8[]

   failed <= 1'b0;
   for(i = 0; i < 8; i=i+1) begin
     if(i != input_data8[i]) begin 
        failed = 1;
        $display("WB-to-JSP data mismatch at index %d, wrote 0x%x, read 0x%x", i, i, input_data8[i]);
      //$display("JTAG read got 0x%x", input_data8[i]);
    end
  end
    if(!failed) $display("WB-to-JSP data: 8 bytes OK!  Test 2 passed!");
 
 //////////////////////////////////////
 // Write 4 bytes, then 4 more, JSP->WB (read all back at once)
 
   $display("-------------------------------------------");
  $display("--- Test 3: 4+4 bytes, JSP->WB");
 
    // Write 4 bytes from JTAG
    #1000 
    $display("Selecting JSP module at time %t", $time);
   select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
   #200
   $display("JTAG putting 4 bytes to JSP module at time %t", $time);
   do_jsp_read_write(4'h4,jsp_data8);  // 4 bits words to write, 64 bits output data
  do_jsp_read_write(4'h4,jsp_data8);  // 4 bits words to write, 64 bits output data
   // data returned in input_data8[]
    
   // Select the WB unit in the debug module, read the data written
   #1000; 
   $display("Selecting Wishbone module at time %t", $time);
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
  failed <= 1'b0;
   for(i = 0; i < 4; i=i+1) begin
      do_module_burst_read(3'h1, 16'd1, 32'h0);
      if(input_data8[0] != i) begin 
        failed = 1;
        $display("JSP-to-WB 4+4 data mismatch at index %d, wrote 0x%x, read 0x%x", i, i, input_data8[i]);
      end
    end
   for(i = 0; i < 4; i=i+1) begin
      do_module_burst_read(3'h1, 16'd1, 32'h0);
      if(input_data8[0] != i) begin 
        failed = 1;
        $display("JSP-to-WB 4+4 data mismatch at index %d, wrote 0x%x, read 0x%x", i+4, i, input_data8[i]);
      end
    end    
    
    if(!failed) $display("WB-to-JSP 4+4 data: 8 bytes OK! Test 3 passed!");
 
 ////////////////////////////////////////
 // Read 8 from JTAG, put 4 to WB
 
   $display("-------------------------------------------");
  $display("--- Test 4: 8 bytes WB->JSP, 4 bytes JSP->WB");
 
    // Put 8 bytes from the WB into the JSP
   #1000
  $display("Selecting Wishbone module at time %t", $time);
  select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
  $display("WB putting 8 bytes to JSP module for R8W4 read at time %t", $time);
  for(i = 0; i < 8; i=i+1) begin
     static_data8[0] = i;
     do_module_burst_write(3'h1, 16'd1, 32'h0);
  end

   // Get 8 bytes from the JSP, put 4 to WB
   #1000
   $display("Selecting JSP module at time %t", $time);
   select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
   #1000
   $display("JTAG getting 8 and putting 4 at time %t", $time);
   do_jsp_read_write(4'h4,jsp_data8);  // 4 bits words to write, 64 bits output data
   // data returned in input_data8[]

   failed <= 1'b0;
   for(i = 0; i < 8; i=i+1) begin
     if(i != input_data8[i]) begin 
        failed = 1;
        $display("R8W4 data mismatch getting JSP data at index %d, wrote 0x%x, read 0x%x", i, i, input_data8[i]);
    end
  end
    if(!failed) $display("R8W4: 8 JSP bytes OK!");
 
 // Remove the 4 bytes via the WB
    #1000; 
   $display("Selecting Wishbone module at time %t", $time);
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
  failed <= 1'b0;
   for(i = 0; i < 4; i=i+1) begin
      do_module_burst_read(3'h1, 16'd1, 32'h0);
      if(input_data8[0] != i) begin 
        failed = 1;
        $display("R8W4 data mismatch clearing WB data at index %d, wrote 0x%x, read 0x%x", i, i, input_data8[i]);
      end
    end
    if(!failed) $display("R8W4: 4 WB bytes OK!");
      
 ///////////////////////////////////////////////////
 // Test putting more data than space available
 
   $display("-------------------------------------------");
  $display("--- Test 5: Put 6 JSP->WB, then 6 more");
 
    //  put 6 to WB
   #1000
   $display("Selecting JSP module at time %t", $time);
   select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
   #1000
   $display("JTAG putting 6 at time %t", $time);
   do_jsp_read_write(4'h6,jsp_data8);  // 4 bits words to write, 64 bits output data
 
  // put 6 more
     #1000
   $display("Selecting JSP module at time %t", $time);
   select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
   #1000
   $display("JTAG putting 6 at time %t", $time);
   do_jsp_read_write(4'h6,jsp_data8);  // 4 bits words to write, 64 bits output data
   
   
   // Get the data back from the WB 
      #1000; 
   $display("Selecting Wishbone module at time %t", $time);
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
  failed <= 1'b0;
   for(i = 0; i < 6; i=i+1) begin
      do_module_burst_read(3'h1, 16'd1, 32'h0);
      if(input_data8[0] != i) begin 
        failed = 1;
        $display("W6W6 data mismatch reading WB data at index %d, wrote 0x%x, read 0x%x", i, i, input_data8[i]);
      end
    end
   for(i = 0; i < 2; i=i+1) begin
      do_module_burst_read(3'h1, 16'd1, 32'h0);
      if(input_data8[0] != i) begin 
        failed = 1;
        $display("W6W6 data mismatch reading WB data at index %d, wrote 0x%x, read 0x%x", i+6, i, input_data8[i]);
      end
    end
    if(!failed) $display("W6W6: 8 WB bytes OK!");

 
 //////////////////////////////////////////
 // Verify behavior of WB UART 16450-style registers
 
 // Check LSR with both FIFOs empty
    $display("-------------------------------------------");
  $display("--- Test 6a: Check LSR with both FIFOs empty");
  
   $display("Selecting Wishbone module at time %t", $time);
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE); 
   do_module_burst_read(3'h1, 16'd1, 32'h5);
   if(input_data8[0] != 8'h60) begin 
        $display("LSR mismatch with both FIFOs empty, read 0x%x, expected 0x60", input_data8[0]);
   end
  else $display("LSR with both FIFOs empty OK!");

    $display("-------------------------------------------");
  $display("--- Test 6b: Check LSR with WB read data available");
 
  #1000
  $display("Selecting JSP module at time %t", $time);
  select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
    $display("JTAG putting 1 at time %t", $time);
   do_jsp_read_write(4'h1,jsp_data8);  // 4 bits words to write, 64 bits output data
   
   $display("Selecting Wishbone module at time %t", $time);
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE); 
   do_module_burst_read(3'h1, 16'd1, 32'h5);
   if(input_data8[0] != 8'h61) begin 
        $display("LSR mismatch with WB read data available, read 0x%x, expected 0x61", input_data8[0]);
   end
  else $display("LSR with WB read data available OK!");   
   
  $display("-------------------------------------------");
  $display("--- Test 6c: Check LSR with WB read data available and write FIFO not empty / full");
   
   #1000
  $display("Selecting Wishbone module at time %t", $time);
  select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
  $display("WB putting 1 bytes to JSP module for LSR test at time %t", $time);
  do_module_burst_write(3'h1, 16'd1, 32'h0); 
   
  do_module_burst_read(3'h1, 16'd1, 32'h5);
   if(input_data8[0] != 8'h61) begin 
        $display("LSR mismatch with WB read data available and write FIFO not empty, read 0x%x, expected 0x61", input_data8[0]);
   end
  else $display("LSR with WB read data available and write FIFO not empty OK!");   
   
   // Fill the write FIFO
   for(i = 0; i < 7; i = i + 1) begin
    do_module_burst_write(3'h1, 16'd1, 32'h0);      
   end
   
  do_module_burst_read(3'h1, 16'd1, 32'h5);
   if(input_data8[0] != 8'h01) begin 
        $display("LSR mismatch with WB read data available and write FIFO full, read 0x%x, expected 0x01", input_data8[0]);
   end
  else $display("LSR with WB read data available and write FIFO full OK!");   
   
  $display("-------------------------------------------");
  $display("--- Test 6d: Check LSR with write FIFO full");
  
  do_module_burst_read(3'h1, 16'd1, 32'h0);  // get/clear the read data
   
  do_module_burst_read(3'h1, 16'd1, 32'h5);
   if(input_data8[0] != 8'h00) begin 
        $display("LSR mismatch with WB write FIFO full, read 0x%x, expected 0x00", input_data8[0]);
   end
  else $display("LSR with WB write FIFO full OK!");   
   
   //////////////////////////////////////
   // Test DLAB bit
   // Now that we've tested the LSR, we can use it to verity the FIFO states

  $display("-------------------------------------------");
  $display("--- Test 7: test DLAB bit");
   
     #1000
  $display("Selecting JSP module at time %t", $time);
  select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
    $display("JTAG putting 1 (and getting 8) at time %t", $time);
   do_jsp_read_write(4'h1,jsp_data8);  // 4 bits words to write, 64 bits output data
   
   // Set the DLAB bit.  This should prevent reads/writes to the FIFOs from the WB
  #1000
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   
   #1000
   $display("Setting DLAB bit it time %t", $time);  
   static_data8[0] = 8'h80;
   do_module_burst_write(3'h1, 16'd1, 32'h00000003); 
   
   // Read from 0.  This should not get the available byte.
   do_module_burst_read(3'h1, 16'd1, 32'h0);
   
   // Try to write the FIFO full.  This should not put any bytes to the transmit FIFO
   for(i = 0; i < 8; i = i + 1) begin
      do_module_burst_write(3'h1, 16'd1, 32'h0);    
    end
    
   // Check FIFO status in the LSR
   $display("Checking LSR");
  do_module_burst_read(3'h1, 16'd1, 32'h5);
   if(input_data8[0] != 8'h61) begin 
        $display("LSR mismatch in DLAB inhibit test, read 0x%x, expected 0x61", input_data8[0]);
   end
  else $display("DLAB inhibit test OK!");   
   
   // Now clear the DLAB, and try again.
   $display("Clearing DLAB at time %t", $time);
   static_data8[0] = 8'h00;
   do_module_burst_write(3'h1, 16'd1, 32'h3);
   
   do_module_burst_read(3'h1, 16'd1, 32'h0);  // Should empty the read FIFO
   for(i = 0; i < 8; i = i + 1) begin
    do_module_burst_write(3'h1, 16'd1, 32'h0);   // Should un-empty the read FIFO
   end
 
   // Check FIFO status in the LSR
  do_module_burst_read(3'h1, 16'd1, 32'h5);
   if(input_data8[0] != 8'h00) begin 
        $display("LSR mismatch in DLAB test 2, read 0x%x, expected 0x00", input_data8[0]);
   end
  else $display("DLAB un-inhibit test OK!");   
   
   // Note WB write FIFO is full at this point
   
   ///////////////////////////////////////////////////
   // Test interrupt functionality.
   
     $display("-------------------------------------------");
  $display("--- Test 8a:  IER write");
   
   // Write IER to 0
  static_data8[0] = 8'h00;
   do_module_burst_write(3'h1, 16'd1, 32'h1);
   
   // Make sure it's 0
   do_module_burst_read(3'h1, 16'd1, 32'h1);
   if(input_data8[0] != 8'h00) begin 
        $display("Failed to set IER to 0x00, read 0x%x", input_data8[0]);
   end
  else $display("Set IER to 0: pass"); 
 
   // Make sure int_o is not set
  if(jsp_int) begin
    $display("JSP Interrupt set when no interrupts enabled: FAIL");
  end
  else $display("JSP interrupt not set, interrupts disabled: OK");
 
   // Write IER to 0x0F
  static_data8[0] = 8'h0F;
   do_module_burst_write(3'h1, 16'd1, 32'h1);
   
   // Make sure it's 0x0F
   do_module_burst_read(3'h1, 16'd1, 32'h1);
   if(input_data8[0] != 8'h0F) begin 
        $display("Failed to set IER to 0x0F, read 0x%x", input_data8[0]);
   end
  else $display("Set IER to 0x0F: pass");   
   

   // Write IER to 0x03
  static_data8[0] = 8'h03;
   do_module_burst_write(3'h1, 16'd1, 32'h1);
   
   // Make sure it's 0x03
   do_module_burst_read(3'h1, 16'd1, 32'h1);
   if(input_data8[0] != 8'h03) begin 
        $display("Failed to set IER to 0x03, read 0x%x", input_data8[0]);
   end
  else $display("Set IER to 0x03: pass");     

  ////////////////////////////////////
  //  Test the int_o output

     $display("-------------------------------------------");
  $display("--- Test 8b: int_o output");
  
   // Make sure int_o is (still) not set WB RD FIFO empty, WB WR FIFO is full
  if(jsp_int) begin
    $display("JSP Interrupt set when no int condition: FAIL");
  end
  else $display("JSP interrupt not set, no INT condition: OK");
 
 // Check IIR for 'no active interrupt'
    do_module_burst_read(3'h1, 16'd1, 32'h2);
   if(input_data8[0] != 8'h01) begin 
        $display("Wrong value for IIR with no active interrupt, read 0x%x, expected 0x01", input_data8[0]);
   end
  else $display("IIR is 0x01 with no active interrupt: pass");  
    
    
  // Read a byte from the JSP, should trigger the 'THR empty' interrupt
     #1000
  $display("Selecting JSP module at time %t", $time);
  select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
    $display("JTAG getting 8 at time %t", $time);
   do_jsp_read_write(4'h0,jsp_data8);  // 4 bits words to write, 64 bits output data


   // Make sure int_o is (still) not set WB RD FIFO empty, WB WR FIFO is full
  if(!jsp_int) begin
    $display("JSP Interrupt not set when THR empty: FAIL");
  end
  else $display("JSP interrupt set for THR empty: OK");   
 
  #1000
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   
 // Check IIR for THR empty
    do_module_burst_read(3'h1, 16'd1, 32'h2);
   if(input_data8[0] != 8'h02) begin 
        $display("Wrong value for IIR with no active interrupt, read 0x%x, expected 0x02", input_data8[0]);
   end
  else $display("IIR is 0x02 with THR empty: pass");  
 
   // IIR read should have cleared int_o and changed IIR to 'no active interrupt'
  if(jsp_int) begin
    $display("JSP Interrupt set after IIR read: FAIL");
  end
  else $display("JSP interrupt not set after clearing THR INT with IIR read: OK");
    
 // Check IIR for 'no active interrupt'
    do_module_burst_read(3'h1, 16'd1, 32'h2);
   if(input_data8[0] != 8'h01) begin 
        $display("Wrong value for IIR after clearing THR INT with IIR read, read 0x%x, expected 0x01", input_data8[0]);
   end
  else $display("IIR is 0x01 after clearing THR INT with IIR read: pass");  
    
  // Write a byte from the WB, should trigger int_o
    static_data8[0] = 8'h00;
   do_module_burst_write(3'h1, 16'd1, 32'h0);
   
  // check int_o, should be set
    if(!jsp_int) begin
    $display("JSP Interrupt not set when THR not full: FAIL");
  end
  else $display("JSP interrupt set for THR not full: OK");  
    
  // Write a byte from the JSP, should take precedence in IIR
  #1000
  $display("Selecting JSP module at time %t", $time);
  select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
    $display("JTAG putting 1 at time %t", $time);
   do_jsp_read_write(4'h1,jsp_data8);  // 4 bits words to write, 64 bits output data
  
  // check int_o, should be set
    if(!jsp_int) begin
    $display("JSP Interrupt not set when read data available: FAIL");
  end
  else $display("JSP interrupt set for read data available: OK");  
    
  // Check IIR, should show read data available
   #1000
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   do_module_burst_read(3'h1, 16'd1, 32'h2);
   if(input_data8[0] != 8'h4) begin 
        $display("Wrong value for IIR after clearing THR INT with IIR read, read 0x%x, expected 0x04", input_data8[0]);
   end
  else $display("IIR is 0x04 after putting a JSP byte: pass"); 
   
  // Read the byte from the WB.
    do_module_burst_read(3'h1, 16'd1, 32'h0);
    
  // check int_o, should be set
      if(!jsp_int) begin
    $display("JSP Interrupt not set when THR not full: FAIL");
  end
  else $display("JSP interrupt set for THR not full: OK"); 
  
  // Check IIR, should show THRE
     #1000
   do_module_burst_read(3'h1, 16'd1, 32'h2);
   if(input_data8[0] != 8'h02) begin 
        $display("Wrong value for IIR after clearing RDA INT with WB read (THRE), read 0x%x, expected 0x02", input_data8[0]);
   end
    else $display("IIR is 0x02 after reading data with THRE: pass"); 
  
  // check int_o, should be cleared
    if(jsp_int) begin
    $display("JSP Interrupt set after clearing THRE with IIR read: FAIL");
  end
  else $display("JSP interrupt not set, THRE cleared with IIR read: OK");
  
  // Check IIR, should no no interrupt
   #1000
   do_module_burst_read(3'h1, 16'd1, 32'h2);
   if(input_data8[0] != 8'h01) begin 
        $display("Wrong value for IIR after clearing THR INT with IIR read, read 0x%x, expected 0x01", input_data8[0]);
   end
    else $display("IIR is 0x01 after reading data with THRE: pass"); 
  
  // Put a byte from the JSP
   #1000
  $display("Selecting JSP module at time %t", $time);
  select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
    $display("JTAG putting 1 at time %t", $time);
   do_jsp_read_write(4'h1,jsp_data8);  // 4 bits words to write, 64 bits output data
  
  
  // check int_o, should be set
      if(!jsp_int) begin
    $display("JSP Interrupt not set when read data available: FAIL");
  end
  else $display("JSP interrupt set for read data available: OK"); 
    
  // check IIR, should show receive data available
     #1000
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   do_module_burst_read(3'h1, 16'd1, 32'h2);
   if(input_data8[0] != 8'h4) begin 
        $display("Wrong value for IIR with RDA, read 0x%x, expected 0x04", input_data8[0]);
   end
  else $display("IIR is 0x04 after putting a JSP byte: pass"); 
  
  // Read the byte over WB
   do_module_burst_read(3'h1, 16'd1, 32'h0);
   
    
  // check int_o, should be cleared
    if(jsp_int) begin
    $display("JSP Interrupt set when no int condition: FAIL");
  end
  else $display("JSP interrupt not set, no INT condition: OK");
    
  // check IIR, should show no active interrupt
      #1000
   do_module_burst_read(3'h1, 16'd1, 32'h2);
   if(input_data8[0] != 8'h1) begin 
        $display("Wrong value for IIR with no active int, read 0x%x, expected 0x01", input_data8[0]);
   end
  else $display("IIR is 0x01 with no active interrupts: pass"); 
   
  ////////////////////////////////////
  //  Test the software resets

  $display("-------------------------------------------");
  $display("--- Test 9: Software WB/UART FIFO reset");
  
  // First, test reset only JSP->WB FIFO
  // Put a byte from the JSP
   #1000
  //$display("Selecting JSP module at time %t", $time);
  select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
    //$display("JTAG putting 1 at time %t", $time);
   do_jsp_read_write(4'h1,jsp_data8);  // 4 bits words to write, 64 bits output data
   
   // Put a byte from the WB
    #1000
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   #500
  static_data8[0] = 8'h00;
   do_module_burst_write(3'h1, 16'd1, 32'h0);
   
   // Reset the JSP->WB FIFO
   #500
   static_data8[0] = 8'h02;
  do_module_burst_write(3'h1, 16'd1, 32'h2);

  // To test, need to read the output from the transact function:
  // Should be 1 byte available, 8 bytes free
     #1000
  //$display("Selecting JSP module at time %t", $time);
  select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
    $display("Next line should show 1 byte available, 8 bytes free:");
   do_jsp_read_write(4'h0,jsp_data8);  // 4 bits words to write, 64 bits output data     
 
 
 // Second, test reset only WB->JSP FIFO
   // Put a byte from the JSP
   #1000
   do_jsp_read_write(4'h1,jsp_data8);  // 4 bits words to write, 64 bits output data
   
   // Put a byte from the WB
    #1000
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   #500
  static_data8[0] = 8'h00;
   do_module_burst_write(3'h1, 16'd1, 32'h0);
   
   // Reset the WB->JSP FIFO
   #500
   static_data8[0] = 8'h04;
  do_module_burst_write(3'h1, 16'd1, 32'h2);

  // To test, need to read the output from the transact function:
  // Should be 0 byte available, 7 bytes free
     #1000
  //$display("Selecting JSP module at time %t", $time);
  select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
    $display("Next line should show 0 byte available, 7 bytes free:");
   do_jsp_read_write(4'h0,jsp_data8);  // 4 bits words to write, 64 bits output data     
     
   // Finally, test reset both directions  
     // Put a byte from the JSP
   #1000
   do_jsp_read_write(4'h1,jsp_data8);  // 4 bits words to write, 64 bits output data
   
   // Put a byte from the WB
    #1000
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   #500
  static_data8[0] = 8'h00;
   do_module_burst_write(3'h1, 16'd1, 32'h0);
   
   // Reset both FIFO
   #500
   static_data8[0] = 8'h06;
  do_module_burst_write(3'h1, 16'd1, 32'h2);

  // To test, need to read the output from the transact function:
  // Should be 0 byte available, 8 bytes free
     #1000
  //$display("Selecting JSP module at time %t", $time);
  select_debug_module(`DBG_TOP_JSP_DEBUG_MODULE);
    $display("Next line should show 0 byte available, 8 bytes free:");
   do_jsp_read_write(4'h0,jsp_data8);  // 4 bits words to write, 64 bits output data     
     
   //////////////////////////////
  // End of tests 
  
  $display("----------------------------------"); 
  $display("--- ALL TESTS COMPLETE ---"); 
  
  end

task initialize_memory;
  input [31:0] start_addr;
  input [31:0] length;
  integer i;
  reg [31:0] addr;
  begin

  jsp_data8 <= 64'h0706050403020100;

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
                .wb_rst_i(wb_rst_i),
                                                                                
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

		 `ifdef DBG_JSP_SUPPORTED
		 // WISHBONE slave, including interrupt output     
		 ,
                .wb_jsp_adr_i(wb_adr),
                .wb_jsp_dat_o(wb_dat_s),
                .wb_jsp_dat_i(wb_dat_m),
                .wb_jsp_cyc_i(wb_cyc),
                .wb_jsp_stb_i(wb_stb),
                .wb_jsp_sel_i(wb_sel),
                .wb_jsp_we_i(wb_we),
                .wb_jsp_ack_o(wb_ack),
                .wb_jsp_cab_i(),
                .wb_jsp_err_o(wb_err),
                .wb_jsp_cti_i(),
                .wb_jsp_bte_i(),
		.int_o(jsp_int)
		`endif

              );


   
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
    //$display("Doing burst read, word size %d, word count %d, start address 0x%x", word_size_bytes, word_count, start_address);
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
      
      //if(j > 1) begin
      //   $display("Took %0d tries before good status bit during burst read", j);
      //end
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
      
      //if(j > 1) begin
       //  $display("Took %0d tries before good status bit during burst read", j);
      //end
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
   //else $display("CRC OK!");
    
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
    //$display("Doing burst write, word size %d, word count %d, start address 0x%x", word_size_bytes, word_count, start_address);
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
   //else $display("CRC OK!");
    
   // Finally, shift out 5 0's, to make the next command a NOP
   // Not necessary, module will not latch new opcode during burst
   //jtag_write_stream(64'h0, 8'h5, 1);
   write_bit(`JTAG_TMS_bit);  // update_ir
   write_bit(3'h0);           // idle
end

endtask

   task do_jsp_read_write;
      input [3:0] words_to_put;
      input [63:0] outstream;
      reg [63:0] instream;
      integer i;
      integer j;
      integer snd;
      integer rcv;
      integer xfer_size;
      reg inbit;
 //     reg shiftbit;
      begin

	 // Put us in shift mode
	 write_bit(`JTAG_TMS_bit);  // select_dr_scan
	 write_bit(3'h0);           // capture_ir
	 write_bit(3'h0);           // shift_ir

`ifdef ADBG_JSP_SUPPORT_MULTI
	 read_write_bit(`JTAG_TDO_bit,inbit);           // Put the start bit
`endif

	 // Put / get lengths
	 jtag_read_write_stream({56'h0,words_to_put, 4'b0000}, 8'h8,0,instream);
	 
`ifdef ADBG_JSP_SUPPORT_MULTI
  //shiftbit = instream[7];
  instream = (instream << 1);
  instream[0] = inbit;
  inbit = instream[8];
`endif

	 $display("JSP got %d bytes available, %d bytes free", instream[7:4], instream[3:0]);

	 // Determine transfer size...
	 rcv = instream[7:4];
	 snd = words_to_put;
	 if(instream[3:0] < words_to_put) snd = instream[3:0];
	 xfer_size = snd;
	 if(rcv > snd) xfer_size = rcv;
	 
	 // *** Always do 8 bytes transfers, for testing
	 // xfer_size = 8;
	 // *** 
	 
	 $display("Doing JSP transfer of %d bytes", xfer_size);
	 
	 // Put / get bytes.
	 for(i = 0; i < xfer_size; i=i+1) begin
	   #100
	    jtag_read_write_stream(outstream>>(i*8), 8'h8,0,instream);  // Length is in bits...
`ifdef ADBG_JSP_SUPPORT_MULTI	    
      input_data8[i] = {instream[6:0], inbit};
      inbit = instream[7];
`else
	    input_data8[i] = instream[7:0];  // Move input data to where it can be gotten by main task
`endif
	 end

	 // JSP does not use the module_inhibit output, so last data bit must be a '0'
	 // Excess writes are ignored.  This will however pop a byte from the receive
	 // FIFO, so make sure all data bytes have been fetched before this is sent.
	 write_bit(`JTAG_TMS_bit);  // exit_dr
	 
	 // Put us back in idle mode
	 write_bit(`JTAG_TMS_bit);  // update_dr
	 write_bit(3'h0);           // idle
	 
	 end
      endtask // do_jsp_read_write
   
   

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