//////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  MESI_ISC Project                                            ////
////                                                              ////
////  Author(s):                                                  ////
////      - Yair Amitay       yair.amitay@yahoo.com               ////
////                          www.linkedin.com/in/yairamitay      ////
////                                                              ////
////  Description                                                 ////
////  mesi_isc_tb                                                 ////
////  -------------------                                         ////
////  Project test bench.                                         ////
////  Check coherency rules 1,2, and 3.                           ////
////  Check fifos overflow and underflow.                         ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

 
// Sanity checks
//================================

// Sanity Check 1 - coherency rules
//================================
//   
// Rule | time  | CPU ID  | Memory | Address | Data | Condition   |
//      |       |         | Event  |         |      |             |
// -----|-------|---------|--------|---------|------|-------------|
//      |  x    |   1     |  WR    |  A1     |  D1  |
//   1  |-------|---------|--------|---------|------|
//      |  x+1  |   1     |  RD    |  A1     |  D1  |
// -----|-------|---------|--------|---------|------|
//      |  x    |   1     |  WR    |  A1     |  D1  |
//   2  |-------|---------|--------|---------|------|
//      |  x+1  |   2     |  RD    |  A1     |  D1  |
// -----|-------|---------|--------|---------|------|
//      |  x    |   1     |  WR    |  A1     |  D1  |
//      |-------|---------|--------|---------|------|
//      |  x+1  |   2     |  WD    |  A1     |  D2  |
//   3  |-------|---------|--------|---------|------|
//      |  y    |   3     |  RD    |  A1     |  D2  |
//      |-------|---------|--------|---------|------|--------------|
//      |  y+1  |   3     |  RD    |  A1     |  D1  |  Not allowed |
// -----|-------|---------|--------|---------|------|--------------|
//
// For each read from the memory, check that the read data contains the most
// update written data. The check is done separately for each CPU written data. 
// This check covers the three rules for coherency system.
// task sanity_check_rule1
task sanity_check_rule1_rule2;
input [3:0]              cpu_id;
input [ADDR_WIDTH-1:0]   mbus_addr;
input [DATA_WIDTH-1:0]   mbus_wr_data;
reg   [DATA_WIDTH-1:0]   cur_mem_data;

begin
`ifdef messages
  $display("Message: check err 7. time:%d", $time);
`endif      
  cur_mem_data = mem[mbus_addr];
  if (cur_mem_data[(3+1)*8-1 : 3*8] > mbus_wr_data[(3+1)*8-1 : 3*8] |
      cur_mem_data[(2+1)*8-1 : 2*8] > mbus_wr_data[(2+1)*8-1 : 2*8] |
      cur_mem_data[(1+1)*8-1 : 1*8] > mbus_wr_data[(1+1)*8-1 : 1*8] |
      cur_mem_data[(0+1)*8-1 : 0*8] > mbus_wr_data[(0+1)*8-1 : 0*8])
  begin
    $display("ERROR 7. The current memory data is bigger then the written data\n");
    $display("  CPU: %h, Cur data: %h, Written data: %h, Address: %h, time:%d\n",
             cpu_id,
             cur_mem_data,
             mbus_wr_data,
             mbus_addr,
             $time);
    @(negedge clk) $finish();
  end
end
endtask

// Sanity Check 2- cache states
//================================
// Checks that, at any time, there are not 2 cache lines or more, that contains
// the same memory address, with stats M or state E.
always @(posedge clk or posedge rst)
  for (k=0; k < 4; k = k + 1)
    if (mbus_ack[k]) sanity_check_cache_status(mbus_addr_array[k]);

// task sanity_check_cache_status;
task sanity_check_cache_status;
input [ADDR_WIDTH-1:0]   mbus_addr;
reg [1:0]                num_of_lines_in_m_e_state;
   
begin
`ifdef messages
     $display("Message: check err 6. time:%d", $time);
`endif 
  num_of_lines_in_m_e_state = 0; 
  //               \ /
  if(mesi_isc_tb_cpu3.cache_state[mbus_addr] == `MESI_ISC_TB_CPU_MESI_E |
  //               \ /
     mesi_isc_tb_cpu3.cache_state[mbus_addr] == `MESI_ISC_TB_CPU_MESI_M)
     num_of_lines_in_m_e_state = num_of_lines_in_m_e_state + 1; 

  if(mesi_isc_tb_cpu2.cache_state[mbus_addr] == `MESI_ISC_TB_CPU_MESI_E |
  //               \ /
     mesi_isc_tb_cpu2.cache_state[mbus_addr] == `MESI_ISC_TB_CPU_MESI_M)
     num_of_lines_in_m_e_state = num_of_lines_in_m_e_state + 1; 

  if(mesi_isc_tb_cpu1.cache_state[mbus_addr] == `MESI_ISC_TB_CPU_MESI_E |
  //               \ /
     mesi_isc_tb_cpu1.cache_state[mbus_addr] == `MESI_ISC_TB_CPU_MESI_M)
     num_of_lines_in_m_e_state = num_of_lines_in_m_e_state + 1; 

  if(mesi_isc_tb_cpu0.cache_state[mbus_addr] == `MESI_ISC_TB_CPU_MESI_E |
  //               \ /
     mesi_isc_tb_cpu0.cache_state[mbus_addr] == `MESI_ISC_TB_CPU_MESI_M)
     num_of_lines_in_m_e_state = num_of_lines_in_m_e_state + 1;

  if (num_of_lines_in_m_e_state > 1)
  begin
     $display("Error 6. %d of cache lines are in M or E state. time:%d\n",
                                                 num_of_lines_in_m_e_state,
                                                 $time);
     @(negedge clk) $finish;
  end
end
endtask


// Error state
//================================
`ifdef mesi_isc_debug

always @(mesi_isc.mesi_isc_breq_fifos.fifo_3.dbg_fifo_overflow or
         mesi_isc.mesi_isc_breq_fifos.fifo_3.dbg_fifo_underflow or
         mesi_isc.mesi_isc_breq_fifos.fifo_2.dbg_fifo_overflow or
         mesi_isc.mesi_isc_breq_fifos.fifo_2.dbg_fifo_underflow or
         mesi_isc.mesi_isc_breq_fifos.fifo_1.dbg_fifo_overflow or
         mesi_isc.mesi_isc_breq_fifos.fifo_1.dbg_fifo_underflow or
         mesi_isc.mesi_isc_breq_fifos.fifo_0.dbg_fifo_overflow or
         mesi_isc.mesi_isc_breq_fifos.fifo_0.dbg_fifo_underflow or
         mesi_isc.mesi_isc_broad.broad_fifo.dbg_fifo_overflow or
         mesi_isc.mesi_isc_broad.broad_fifo.dbg_fifo_underflow)
if (mesi_isc.mesi_isc_breq_fifos.fifo_3.dbg_fifo_overflow  |
    mesi_isc.mesi_isc_breq_fifos.fifo_3.dbg_fifo_underflow |
    mesi_isc.mesi_isc_breq_fifos.fifo_2.dbg_fifo_overflow  |
    mesi_isc.mesi_isc_breq_fifos.fifo_2.dbg_fifo_underflow |
    mesi_isc.mesi_isc_breq_fifos.fifo_1.dbg_fifo_overflow  |
    mesi_isc.mesi_isc_breq_fifos.fifo_1.dbg_fifo_underflow |
    mesi_isc.mesi_isc_breq_fifos.fifo_0.dbg_fifo_overflow  |
    mesi_isc.mesi_isc_breq_fifos.fifo_0.dbg_fifo_underflow |
    mesi_isc.mesi_isc_broad.broad_fifo.dbg_fifo_overflow   |
    mesi_isc.mesi_isc_broad.broad_fifo.dbg_fifo_underflow)
  begin
    $display("ERROR 8. Fifo overflow or underflow\n");
    $display("mesi_isc.mesi_isc_breq_fifos.fifo_3.dbg_fifo_overflow = %h,              mesi_isc.mesi_isc_breq_fifos.fifo_3.dbg_fifo_underflow = %h,    mesi_isc.mesi_isc_breq_fifos.fifo_2.dbg_fifo_overflow = %h,    mesi_isc.mesi_isc_breq_fifos.fifo_2.dbg_fifo_underflow = %h,    mesi_isc.mesi_isc_breq_fifos.fifo_1.dbg_fifo_overflow = %h,    mesi_isc.mesi_isc_breq_fifos.fifo_1.dbg_fifo_underflow = %h,    mesi_isc.mesi_isc_breq_fifos.fifo_0.dbg_fifo_overflow = %h,    mesi_isc.mesi_isc_breq_fifos.fifo_0.dbg_fifo_underflow = %h,    mesi_isc.mesi_isc_broad.broad_fifo.dbg_fifo_overflow = %h,    mesi_isc.mesi_isc_broad.broad_fifo.dbg_fifo_underflow = %h",    mesi_isc.mesi_isc_breq_fifos.fifo_3.dbg_fifo_overflow,
    mesi_isc.mesi_isc_breq_fifos.fifo_3.dbg_fifo_underflow,
    mesi_isc.mesi_isc_breq_fifos.fifo_2.dbg_fifo_overflow,
    mesi_isc.mesi_isc_breq_fifos.fifo_2.dbg_fifo_underflow,
    mesi_isc.mesi_isc_breq_fifos.fifo_1.dbg_fifo_overflow,
    mesi_isc.mesi_isc_breq_fifos.fifo_1.dbg_fifo_underflow,
    mesi_isc.mesi_isc_breq_fifos.fifo_0.dbg_fifo_overflow,
    mesi_isc.mesi_isc_breq_fifos.fifo_0.dbg_fifo_underflow,
    mesi_isc.mesi_isc_broad.broad_fifo.dbg_fifo_overflow,
    mesi_isc.mesi_isc_broad.broad_fifo.dbg_fifo_underflow);
    $finish();
  end
`endif
   
