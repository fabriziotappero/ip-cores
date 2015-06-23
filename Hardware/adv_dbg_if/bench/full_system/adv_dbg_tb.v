//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adv_dbg_tb.v                                                ////
////                                                              ////
////                                                              ////
////  Testbench for the SoC Advanced Debug Interface.             ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nyawn@opencores.org)                      ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008'2010        Authors                       ////
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
// Revision 1.7  2011-02-14 04:16:25  natey
// Major functionality enhancement - now duplicates the full OR1K self-test performed by adv_jtag_bridge.
//
// Revision 1.6  2010-01-16 02:15:22  Nathan
// Updated to match changes in hardware.  Added support for hi-speed mode.
//
// Revision 1.5  2010-01-08 01:41:07  Nathan
// Removed unused, non-existant include from CPU behavioral model.  Minor text edits.
//
// Revision 1.4  2009/05/17 20:54:55  Nathan
// Changed email address to opencores.org
//
// Revision 1.3  2008/07/11 08:18:47  Nathan
// Added a bit to the CPU test.  Added the hack that allows the driver to work with a Xilinx BSCAN device.
//


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


module adv_debug_tb (

jtag_tck_o,
jtag_tms_o,
jtag_tdo_o,
jtag_tdi_i,

wb_clk_o,
sys_rstn_o


); 

output jtag_tck_o;
output jtag_tms_o;
output jtag_tdo_o;
input jtag_tdi_i;
output wb_clk_o;
output sys_rstn_o;

// Connections to the JTAG TAP
reg jtag_tck_o;
reg jtag_tms_o;
reg jtag_tdo_o;
wire jtag_tdi_i;

reg wb_clk_o;
reg sys_rst_o;
reg sys_rstn_o;
   
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

reg [31:0] original_instruction; // holds instruction being replaced by TRAP in CPU functional test

reg failed;
integer i;

initial
begin
   jtag_tck_o = 1'b0;
   jtag_tms_o = 1'b0;
   jtag_tdo_o = 1'b0;
end

// Provide the wishbone / CPU / system clock
initial
begin
  wb_clk_o = 1'b0;
  forever #5 wb_clk_o = ~wb_clk_o; 
end

initial
begin
   sys_rstn_o = 1'b1;
   #200 sys_rstn_o = 1'b0;
   #5000 sys_rstn_o = 1'b1;
end


// Start the test (and reset the wishbone)
initial
begin
  test_enabled = 1'b0;

   // Init the memory
  initialize_memory(32'h0,32'h16);

  #5 test_enabled<= 1'b1;
end

// This is the main test procedure
always @ (posedge test_enabled)
begin

  $display("Starting advanced debug test");
  
  reset_jtag;
  #6000;
  check_idcode;
  #1000;
  
  // Select the debug module in the IR
  set_ir(`DEBUG);
  #1000;
  
  
  `ifdef DBG_CPU0_SUPPORTED
  // STALL the CPU, so it won't interfere with WB tests
  // Select the CPU0 unit in the debug module
  #1000; 
  $display("Selecting CPU0 module at time %t", $time);
  select_debug_module(`DBG_TOP_CPU0_DEBUG_MODULE);

    
   //  Set the stall bit...holding the CPU in reset prevents WB access (?)
   $display("Setting reset and stall bits at time %t", $time);    
    write_module_internal_register(32'h0, 8'h1, 32'h1, 8'h2);  // idx, idxlen, data, datalen
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
    
   // Reset the error bit    
    write_module_internal_register(32'h0, 8'h1, 32'h1, 8'h1);  // idx, idxlen, data, datalen
   #1000;
   
  /////////////////////////////////
  // Test 8-bit WB access
  failed = 0;
  $display("Testing WB 8-bit burst write at time %t: resetting ", $time);
  do_module_burst_write(3'h1, 16'd16, 32'h87);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
  #1000;
  $display("Testing WB 8-bit burst read at time %t", $time);
  do_module_burst_read(3'h1, 16'd16, 32'h87);
  #1000;
   for(i = 0; i < 16; i = i+1) begin
     if(static_data8[i] != input_data8[i]) begin 
        failed = 1;
        $display("32-bit data mismatch at index %d, wrote 0x%x, read 0x%x", i, static_data8[i], input_data8[i]);
    end
  end
  if(!failed) $display("8-bit read/write OK!");
  
  
  /////////////////////////////////
  // Test 16-bit WB access
  failed = 0;
  $display("Testing WB 16-bit burst write at time %t", $time);
  do_module_burst_write(3'h2, 16'd16, 32'h22);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
  #1000;
  $display("Testing WB 16-bit burst read at time %t", $time);
  do_module_burst_read(3'h2, 16'd16, 32'h22);
  #1000;
   for(i = 0; i < 16; i = i+1) begin
     if(static_data16[i] != input_data16[i]) begin 
        failed = 1;
        $display("16-bit data mismatch at index %d, wrote 0x%x, read 0x%x", i, static_data16[i], input_data16[i]);
    end
  end
  if(!failed) $display("16-bit read/write OK!");
 
  
  ////////////////////////////////////
  // Test 32-bit WB access
  failed = 0;
  $display("Testing WB 32-bit burst write at time %t", $time);
  do_module_burst_write(3'h4, 16'd16, 32'h100);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
  #1000;
  $display("Testing WB 32-bit burst read at time %t", $time);
  do_module_burst_read(3'h4, 16'd16, 32'h100);
  #1000;
   for(i = 0; i < 16; i = i+1) begin
     if(static_data32[i] != input_data32[i]) begin 
        failed = 1;
        $display("32-bit data mismatch at index %d, wrote 0x%x, read 0x%x", i, static_data32[i], input_data32[i]);
    end
  end
  if(!failed) $display("32-bit read/write OK!");
    
  
  ////////////////////////////////
  // Test error register
  err_data = 33'h0;
  // Select and reset the error register
  write_module_internal_register(`DBG_WB_INTREG_ERROR, `DBG_WB_REGSELECT_SIZE, 64'h1, 8'h1); // regidx,idxlen,writedata, datalen;
  //i_wb.cycle_response(`ERR_RESPONSE, 2, 0);  // response type, wait cycles, retry_cycles
  do_module_burst_write(3'h4, 16'd4, 32'hdeaddead);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
  read_module_internal_register(8'd33, err_data);  // get the error register
  $display("Error bit is %d, error address is %x", err_data[0], err_data>>1);

`endif  // WB module supported
  
  
   ///////////////////////////////////////////////////////////////////
   // Test CPU0 unit. This duplicates the CPU self-test originally
   // found in the jp2 JTAG proxy (which was carried over into
   // adv_jtag_bridge)  
   ////////////////////////////////////////////////////////////////////
`ifdef DBG_CPU0_SUPPORTED
  // Select the CPU0 unit in the debug module
  #1000; 
  $display("Selecting CPU0 module at time %t", $time);
  select_debug_module(`DBG_TOP_CPU0_DEBUG_MODULE);

    
   //  Set the stall bit (clear the reset bit)
   $display("Setting reset and stall bits at time %t", $time);    
    write_module_internal_register(32'h0, 8'h1, 32'h1, 8'h2);  // idx, idxlen, data, datalen
   #1000;
   
   // Make sure CPU stalled
   $display("Testing reset and stall bits at time %t", $time);
   read_module_internal_register(8'd2, err_data);  // We assume the register is already selected
   $display("Reset and stall bits are %x", err_data);
   #1000;
   

   // Write some opcodes into the memory
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   $display("Commencing CPU functional test - writing instructions at time %t", $time);
   static_data32[0] = 32'hE0000005;/* l.xor   r0,r0,r0   */
   static_data32[1] = 32'h9C200000; /* l.addi  r1,r0,0x0  */
   static_data32[2] = 32'h18400000;/* l.movhi r2,0x4000  */
   static_data32[3] = 32'hA8420030;/* l.ori   r2,r2,0x30 */
   static_data32[4] = 32'h9C210001;/* l.addi  r1,r1,1    */
   static_data32[5] = 32'h9C210001; /* l.addi  r1,r1,1    */
   static_data32[6] = 32'hD4020800;/* l.sw    0(r2),r1   */
   static_data32[7] = 32'h9C210001;/* l.addi  r1,r1,1    */
   static_data32[8] = 32'h84620000;/* l.lwz   r3,0(r2)   */
   static_data32[9] = 32'h03FFFFFB;/* l.j     loop2      */
   static_data32[10] = 32'hE0211800;/* l.add   r1,r1,r3   */
   do_module_burst_write(3'h4, 16'd11, 32'h0);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address

   #1000;
   select_debug_module(`DBG_TOP_CPU0_DEBUG_MODULE);

   // *** Test the step bit ***
   #1000;
   $display("Testing step bit at time %t", $time);
   static_data32[0] = 32'h1;  // enable exceptions
   do_module_burst_write(3'h4, 16'd1, 32'd17);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
   static_data32[0] = 32'h00002000;  // Trap causes stall
   do_module_burst_write(3'h4, 16'd1, (6 << 11)+20);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
   static_data32[0] = 32'h0;  // Set PC to 0x00
   do_module_burst_write(3'h4, 16'd1, 32'd16);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address
   static_data32[0] = (1 << 22);  // set step bit
   do_module_burst_write(3'h4, 16'd1, (6<<11) + 16);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address

   // Unstall x11
   for(i = 0; i < 11; i = i + 1)
     begin
	#1000;
	$display("Unstall (%d/11) at time %t", i+1, $time);
	unstall();
	wait_for_stall();
     end

   #1000;
   check_results(32'h10, 32'h28, 32'h5);
  
   static_data32[0] = 32'h0;
   do_module_burst_write(3'h4, 16'd1, (6 << 11)+16);  // Un-set step bit
  
   // *** Put a TRAP instruction in the delay slot ***
   #1000;  
   $display("Put TRAP instruction in the delay slot at time %t", $time);  
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   do_module_burst_read(3'h4, 16'd1, 32'h28);  // Save old instr in input_data32[0]
  original_instruction = input_data32[0];
   static_data32[0] = 32'h21000001;  /* l.trap   */
   do_module_burst_write(3'h4, 16'd1, 32'h28); // put new instr
   select_debug_module(`DBG_TOP_CPU0_DEBUG_MODULE);
   // We don't set the PC here

   unstall();
   wait_for_stall();
   check_results(32'h10, 32'h28, 32'd8);  // Expected NPC, PPC, R1
   
   // Put back original instruction
   static_data32[0] = original_instruction;
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   do_module_burst_write(3'h4, 16'd1, 32'h28); // put back old instr

   // *** Put TRAP instruction in place of BRANCH instruction ***
   #1000;
   $display("Put TRAP instruction in place of BRANCH instruction at time %t", $time);  
   do_module_burst_read(3'h4, 16'd1, 32'h24);  // Save old instr in input_data32[0]
   original_instruction = input_data32[0];
   static_data32[0] = 32'h21000001;  /* l.trap   */
   do_module_burst_write(3'h4, 16'd1, 32'h24); // put new instr
   select_debug_module(`DBG_TOP_CPU0_DEBUG_MODULE);
   static_data32[0] = 32'h10;  
   do_module_burst_write(3'h4, 16'd1, 32'd16); // Set PC to 0x10
   
   unstall();
   wait_for_stall();
   check_results(32'h28, 32'h24, 32'd11);  // Expected NPC, PPC, R1
   
   static_data32[0] = original_instruction;
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   do_module_burst_write(3'h4, 16'd1, 32'h24); // put back old instr

   // *** Set TRAP instruction before BRANCH instruction ***
   #1000;
   $display("Put TRAP instruction before BRANCH instruction at time %t", $time);  
   do_module_burst_read(3'h4, 16'd1, 32'h20);  // Save old instr in input_data32[0]
   original_instruction = input_data32[0];
   static_data32[0] = 32'h21000001;  /* l.trap   */
   do_module_burst_write(3'h4, 16'd1, 32'h20); // put new instr
   select_debug_module(`DBG_TOP_CPU0_DEBUG_MODULE);
   static_data32[0] = 32'h24;  
   do_module_burst_write(3'h4, 16'd1, 32'd16); // Set PC to 0x24
   
   unstall();
   wait_for_stall();
   check_results(32'h24, 32'h20, 32'd24);  // Expected NPC, PPC, R1
   
   static_data32[0] = original_instruction;
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   do_module_burst_write(3'h4, 16'd1, 32'h20); // put back old instr

   // *** Set TRAP instruction behind LSU instruction ***
   #1000;
   $display("Put TRAP instruction behind LSU instruction at time %t", $time);  
   do_module_burst_read(3'h4, 16'd1, 32'h1c);  // Save old instr in input_data32[0]
   original_instruction = input_data32[0];
   static_data32[0] = 32'h21000001;  /* l.trap   */
   do_module_burst_write(3'h4, 16'd1, 32'h1c); // put new instr
   select_debug_module(`DBG_TOP_CPU0_DEBUG_MODULE);
   static_data32[0] = 32'h20;  
   do_module_burst_write(3'h4, 16'd1, 32'd16); // Set PC to 0x20
   
   unstall();
   wait_for_stall();
   check_results(32'h20, 32'h1c, 32'd49);  // Expected NPC, PPC, R1
   
   static_data32[0] = original_instruction;
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   do_module_burst_write(3'h4, 16'd1, 32'h1c); // put back old instr

   // *** Set TRAP instruction very near previous one ***
   #1000;
   $display("Put TRAP instruction very near previous one at time %t", $time);  
   do_module_burst_read(3'h4, 16'd1, 32'h20);  // Save old instr in input_data32[0]
   original_instruction = input_data32[0];
   static_data32[0] = 32'h21000001;  /* l.trap   */
   do_module_burst_write(3'h4, 16'd1, 32'h20); // put new instr
   select_debug_module(`DBG_TOP_CPU0_DEBUG_MODULE);
   static_data32[0] = 32'h1c;  
   do_module_burst_write(3'h4, 16'd1, 32'd16); // Set PC to 0x1c
   
   unstall();
   wait_for_stall();
   check_results(32'h24, 32'h20, 32'd50);  // Expected NPC, PPC, R1
   
   static_data32[0] = original_instruction;
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   do_module_burst_write(3'h4, 16'd1, 32'h20); // put back old instr

   // *** Set TRAP instruction at the start ***
   #1000;
   $display("Put TRAP at the start at time %t", $time);  
   do_module_burst_read(3'h4, 16'd1, 32'h10);  // Save old instr in input_data32[0]
   original_instruction = input_data32[0];
   static_data32[0] = 32'h21000001;  /* l.trap   */
   do_module_burst_write(3'h4, 16'd1, 32'h10); // put new instr
   select_debug_module(`DBG_TOP_CPU0_DEBUG_MODULE);
   static_data32[0] = 32'h20;  
   do_module_burst_write(3'h4, 16'd1, 32'd16); // Set PC to 0x20
   
   unstall();
   wait_for_stall();
   check_results(32'h14, 32'h10, 32'd99);  // Expected NPC, PPC, R1
   
   static_data32[0] = original_instruction;
   select_debug_module(`DBG_TOP_WISHBONE_DEBUG_MODULE);
   do_module_burst_write(3'h4, 16'd1, 32'h10); // put back old instr

   // *** Test the STEP bit some more ***
   #1000;   
   select_debug_module(`DBG_TOP_CPU0_DEBUG_MODULE);
   $display("Set step bit at time %t", $time);
   static_data32[0] = (1 << 22);  // set step bit
   do_module_burst_write(3'h4, 16'd1, (6<<11) + 16);  // 3-bit word size (bytes), 16-bit word count, 32-bit start address

   // Unstall x5
   for(i = 0; i < 5; i = i + 1)
     begin
	#1000;
	$display("Unstall (%d/5) at time %t", i, $time);
	unstall();
	wait_for_stall();
     end

   check_results(32'h28, 32'h24, 32'd101);  // Expected NPC, PPC, R1

   static_data32[0] = 32'h24;  
   do_module_burst_write(3'h4, 16'd1, 32'd16); // Set PC to 0x24
   
      // Unstall x2
   for(i = 0; i < 2; i = i + 1)
     begin
	#1000;
	$display("Unstall (%d/2) at time %t", i, $time);
	unstall();
	wait_for_stall();
     end
   
  check_results(32'h10, 32'h28, 32'd201);  // Expected NPC, PPC, R1
   
`endif

end

task check_results;      
      input [31:0] expected_npc;
      input [31:0] expected_ppc;
      input [31:0] expected_r1;
      begin
	 //$display("Getting NPC at time %t", $time);
	 do_module_burst_read(3'h4, 16'd3, 32'd16);// The software self-test does 2 separate reads here
  
	 $display("NPC = %x, expected %x", input_data32[0], expected_npc);
	 $display("PPC = %x, expected %x", input_data32[2], expected_ppc);

	 //$display("Getting R1 at time %t", $time);
	 do_module_burst_read(3'h4, 16'd1, 32'h401);  // Word size, count, addr
	 $display("R1 = %x, expected %x", input_data32[0], expected_r1);
      end
endtask

task unstall;      
  begin
     //$display("Unstall  at time %t", $time);
     write_module_internal_register(32'h0, 8'h1, 32'h0, 8'h2);  // idx, idxlen, data, datalen
  end
endtask
   
task wait_for_stall;
  reg[31:0] regstate;
  begin
     regstate = 0;
     while(regstate == 0)
       begin
	       //$display("Testing for stall at %t", $time);
	       read_module_internal_register(8'd2, regstate);  // We assume the register is already selected
	       #1000;    
       end
  end
endtask
   
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
    
    //$display("Selecting module (%0x)", moduleid);
    
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
   
   // This charming kludge provides ONE TCK, in case a xilinx BSCAN TAP is used,
   // because the FSM needs it between the read burst command and the actual
   // read burst.  Blech.
   #500;
   set_ir(`IDCODE);
   #500;
   set_ir(`DEBUG);
  #500;
  
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
      //   $display("Took %0d tries before good status bit during burst read", j);
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

endmodule // adv_debug_tb


