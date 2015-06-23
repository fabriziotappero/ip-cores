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
////  Project test bench                                          ////
////  - Instantiation of the top level module mesi_isc            ////
////  - Generates the tests stimulus                              ////
////  - Simulate the CPU and caches                               ////
////  - Generates clock, reset and watchdog                       ////
////  - Generate statistic                                        ////
////  - Generate dump file                                        ////
////  - Check for behavior correctness                            ////
////  - Check for coherency correctness                           ////
////                                                              ////
////  For more details see the project spec document.             ////
////  To Do:                                                      ////
////   -                                                          ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "mesi_isc_define.v"
`include "mesi_isc_tb_define.v"

module mesi_isc_tb
    (
     // Inputs
     // Outputs
     );
   
parameter
  CBUS_CMD_WIDTH           = 3,
  ADDR_WIDTH               = 32,
  DATA_WIDTH               = 32,
  BROAD_TYPE_WIDTH         = 2,  
  BROAD_ID_WIDTH           = 5,  
  BROAD_REQ_FIFO_SIZE      = 4,
  BROAD_REQ_FIFO_SIZE_LOG2 = 2,
  MBUS_CMD_WIDTH           = 3,
  BREQ_FIFO_SIZE           = 2,
  BREQ_FIFO_SIZE_LOG2      = 1;
   
/// Regs and wires
//================================
// System
reg                   clk;          // System clock
reg                   rst;          // Active high system reset

// Main buses
wire  [MBUS_CMD_WIDTH-1:0] mbus_cmd_array [3:0]; // Main bus3 command
wire  [MBUS_CMD_WIDTH-1:0] mbus_cmd3; // Main bus2 command
wire  [MBUS_CMD_WIDTH-1:0] mbus_cmd2; // Main bus2 command
wire  [MBUS_CMD_WIDTH-1:0] mbus_cmd1; // Main bus1 command
wire  [MBUS_CMD_WIDTH-1:0] mbus_cmd0; // Main bus0 command
// Coherence buses
wire  [ADDR_WIDTH-1:0]  mbus_addr_array [3:0];  // Main bus3 address
wire  [ADDR_WIDTH-1:0]  mbus_addr3;  // Main bus3 address
wire  [ADDR_WIDTH-1:0]  mbus_addr2;  // Main bus2 address
wire  [ADDR_WIDTH-1:0]  mbus_addr1;  // Main bus1 address
wire  [ADDR_WIDTH-1:0]  mbus_addr0;  // Main bus0 address
reg   [DATA_WIDTH-1:0]  mbus_data_rd;  // Main bus data read
wire  [DATA_WIDTH-1:0]  mbus_data_wr_array [3:0];  // Main bus data read
wire  [DATA_WIDTH-1:0]  mbus_data_wr3;  // Main bus data read
wire  [DATA_WIDTH-1:0]  mbus_data_wr2;  // Main bus data read
wire  [DATA_WIDTH-1:0]  mbus_data_wr1;  // Main bus data read
wire  [DATA_WIDTH-1:0]  mbus_data_wr0;  // Main bus data read

wire  [7:0]             mbus_data_rd_word_array [3:0]; // Bus data read in words
                                        // word

wire                    cbus_ack3;  // Coherence bus3 acknowledge
wire                    cbus_ack2;  // Coherence bus2 acknowledge
wire                    cbus_ack1;  // Coherence bus1 acknowledge
wire                    cbus_ack0;  // Coherence bus0 acknowledge
   

wire   [ADDR_WIDTH-1:0] cbus_addr;  // Coherence bus address. All busses have
                                      // the same address
wire   [CBUS_CMD_WIDTH-1:0] cbus_cmd3; // Coherence bus3 command
wire   [CBUS_CMD_WIDTH-1:0] cbus_cmd2; // Coherence bus2 command
wire   [CBUS_CMD_WIDTH-1:0] cbus_cmd1; // Coherence bus1 command
wire   [CBUS_CMD_WIDTH-1:0] cbus_cmd0; // Coherence bus0 command

wire   [3:0]            mbus_ack;  // Main bus3 acknowledge
reg    [3:0]            mbus_ack_memory;
wire   [3:0]            mbus_ack_mesi_isc;
reg    [3:0]            tb_ins_array [3:0];
wire   [3:0]            tb_ins3;
wire   [3:0]            tb_ins2;
wire   [3:0]            tb_ins1;
wire   [3:0]            tb_ins0;
reg    [3:0]            tb_ins_addr_array [3:0];
wire   [3:0]            tb_ins_addr3;
wire   [3:0]            tb_ins_addr2;
wire   [3:0]            tb_ins_addr1;
wire   [3:0]            tb_ins_addr0;
reg    [7:0]            tb_ins_nop_period [3:0];
wire   [7:0]            tb_ins_nop_period3;
wire   [7:0]            tb_ins_nop_period2;
wire   [7:0]            tb_ins_nop_period1;
wire   [7:0]            tb_ins_nop_period0;
wire   [3:0]            tb_ins_ack;
reg    [31:0]           mem   [9:0];  // Main memory
wire   [31:0]           mem0;
wire   [31:0]           mem1;
wire   [31:0]           mem2;
wire   [31:0]           mem3;
wire   [31:0]           mem4;
wire   [31:0]           mem5;
wire   [31:0]           mem6;
wire   [31:0]           mem7;
wire   [31:0]           mem8;
wire   [31:0]           mem9;
reg    [1:0]            cpu_priority;
reg    [3:0]            cpu_selected;   
reg                     mem_access;
integer                 stimulus_rand_numb [9:0];
integer                 seed;
reg    [1:0]            stimulus_rand_cpu_select;
reg    [1:0]            stimulus_op;
reg    [7:0]            stimulus_addr;
reg    [7:0]            stimulus_nop_period;
integer                 cur_stimulus_cpu;
// For debug in GTKwave
wire   [ADDR_WIDTH+BROAD_TYPE_WIDTH+2+BROAD_ID_WIDTH:0] broad_fifo_entry0;
wire   [ADDR_WIDTH+BROAD_TYPE_WIDTH+2+BROAD_ID_WIDTH:0] broad_fifo_entry1;
wire   [ADDR_WIDTH+BROAD_TYPE_WIDTH+2+BROAD_ID_WIDTH:0] broad_fifo_entry2;
wire   [ADDR_WIDTH+BROAD_TYPE_WIDTH+2+BROAD_ID_WIDTH:0] broad_fifo_entry3;

wire   [5:0]            cache_state_valid_array [3:0];

integer                 i, j, k, l, m, n, p;

reg [31:0]              stat_cpu_access_nop [3:0];
reg [31:0]              stat_cpu_access_rd  [3:0];
reg [31:0]              stat_cpu_access_wr  [3:0];
   

`include "mesi_isc_tb_sanity_check.v"
   
// Stimulus
//================================
// The stimulus drives instruction to the CPU. There are three possible 
// instructions:
// 1. NOP - Do nothing for a random cycles.   
// 2. RD - Read a memory address line with a random address. If the line address
//    is valid on the cache read it from there, if not bring the line according
//    to the the MESI protocol.
// 3. WR - Write a memory address line with a random address. If the line address
//    is valid on the cache write to it according to the MESI protocol. If it is
//    not valid, bring it from the memory according to the the MESI protocol.
always @(posedge clk or posedge rst)
  if (rst)
  begin
   tb_ins_array[3]      = `MESI_ISC_TB_INS_NOP;
   tb_ins_array[2]      = `MESI_ISC_TB_INS_NOP;
   tb_ins_array[1]      = `MESI_ISC_TB_INS_NOP;
   tb_ins_array[0]      = `MESI_ISC_TB_INS_NOP;
   tb_ins_addr_array[3] = 0;
   tb_ins_addr_array[2] = 0;
   tb_ins_addr_array[1] = 0;
   tb_ins_addr_array[0] = 0;
   tb_ins_nop_period[3] = 0;
   tb_ins_nop_period[2] = 0;
   tb_ins_nop_period[1] = 0;
   tb_ins_nop_period[0] = 0;
  end
  else
  begin
    // Calculate the random numbers for this cycle. Use one $random command
    // to perform one series of random number depends on the seed.
    for (m = 0; m < 9; m = m + 1)
      stimulus_rand_numb[m] = $random(seed);

    // For the current cycle check all the CPU starting in a random CPU ID 
    stimulus_rand_cpu_select = $unsigned(stimulus_rand_numb[0]) % 4; // The
                                      // random CPU ID
    for (l = 0; l < 4; l = l + 1)
    begin
      // Start generate a request of CPU ID that equal to cur_stimulus_cpu
      cur_stimulus_cpu = (stimulus_rand_cpu_select+l) % 4;
      // This CPU is in NOP period
      // ----------------------------
      if(tb_ins_nop_period[cur_stimulus_cpu] > 0) 
      begin
        tb_ins_array[cur_stimulus_cpu] = `MESI_ISC_TB_INS_NOP;
        // Decrease the counter by 1. When the counter value is 0 the NOP period
        // is finished
        tb_ins_nop_period[cur_stimulus_cpu] =
                                    tb_ins_nop_period[cur_stimulus_cpu] - 1;
      end
      // The CPU is return acknowledge for the last action. Change the 
      // instruction back to nop.
      // ----------------------------
     else if (tb_ins_ack[cur_stimulus_cpu])
        tb_ins_array[cur_stimulus_cpu] = `MESI_ISC_TB_INS_NOP;        
      // Generate the next instruction for the CPU 
      // ----------------------------
      else if(tb_ins_array[cur_stimulus_cpu] == `MESI_ISC_TB_INS_NOP)
      begin
        // Decide the next operation - nop (0), wr (1), or rd (2)
        stimulus_op         = $unsigned(stimulus_rand_numb[1+l]) % 20 ;
        // Ratio: 1 - nop     1 - wr 5 - rd
        if (stimulus_op > 1) stimulus_op = 2;
        // Decide the next address operation 1 to 5
        stimulus_addr       = ($unsigned(stimulus_rand_numb[5+l]) % 5) + 1 ;  
        // Decide the next  operation 1 to 10
        stimulus_nop_period = ($unsigned(stimulus_rand_numb[9]) % 10) + 1 ;  
        // Next op is nop. Set the value of the counter
        if (stimulus_op == 0)
          tb_ins_nop_period[cur_stimulus_cpu] = stimulus_nop_period;
        else
        begin
          tb_ins_array[cur_stimulus_cpu] = stimulus_op; // 1 for wr, 2 for rd
          tb_ins_addr_array[cur_stimulus_cpu] = stimulus_addr;          
        end
      end // if (tb_ins_array[cur_stimulus_cpu] == `MESI_ISC_TB_INS_NOP)
    end // for (l = 0; l < 4; l = l + 1)
     
  end // else: !if(rst)

// Statistic
//================================
always @(posedge clk or posedge rst)
if (rst)
  for (n = 0; n < 4; n = n + 1)
  begin
    stat_cpu_access_nop[n] = 0;
    stat_cpu_access_rd[n]  = 0;
    stat_cpu_access_wr[n]  = 0;
  end
else 
  for (p = 0; p < 4; p = p + 1)
    if (tb_ins_ack[p])
      begin
      case (tb_ins_array[p])
	`MESI_ISC_TB_INS_NOP: stat_cpu_access_nop[p] = stat_cpu_access_nop[p]+1;
	`MESI_ISC_TB_INS_WR:  stat_cpu_access_wr[p]  = stat_cpu_access_wr[p] +1;
        `MESI_ISC_TB_INS_RD:  stat_cpu_access_rd[p]  = stat_cpu_access_rd[p] +1;
      endcase // case (tb_ins_array[p])
    end
   
// clock and reset
//================================
always #50
       clk = !clk;

// Reset and watchdog
//================================
initial
begin
  // Reset the memory
  for (j = 0; j < 10; j = j + 1)
    mem[j] = 0;
  clk = 1;
  rst = 1;
  repeat (10) @(negedge clk);
  rst = 0;
  repeat (20000) @(negedge clk);   // Watchdog
  $display ("Watchdog finish\n");
  $display ("Statistic\n");
  $display ("CPU 3. WR:%d RD:%d NOP:%d  \n", stat_cpu_access_wr[3],
                                            stat_cpu_access_rd[3],
                                            stat_cpu_access_nop[3]);
  $display ("CPU 2. WR:%d RD:%d NOP:%d\n", stat_cpu_access_wr[2],
                                            stat_cpu_access_rd[2],
                                            stat_cpu_access_nop[2]);
  $display ("CPU 1. WR:%d RD:%d NOP:%d\n", stat_cpu_access_wr[1],
                                            stat_cpu_access_rd[1],
                                            stat_cpu_access_nop[1]);
  $display ("CPU 0. WR: %d RD:%d NOP:%d\n", stat_cpu_access_wr[0],
                                            stat_cpu_access_rd[0],
                                            stat_cpu_access_nop[0]);
  $display ("Total rd and wr accesses: %d\n", stat_cpu_access_wr[3] +
                                              stat_cpu_access_rd[3] +
                                              stat_cpu_access_wr[2] +
                                              stat_cpu_access_rd[2] +
                                              stat_cpu_access_wr[1] +
                                              stat_cpu_access_rd[1] +
                                              stat_cpu_access_wr[0] +
                                              stat_cpu_access_rd[0]);
  $finish;
end

   
// Dumpfile
//================================
initial
begin
  $dumpfile("./dump.vcd");
  $dumpvars(0,mesi_isc_tb);
end
   
// Memory and matrix
//================================
always @(posedge clk or posedge rst)
  if (rst)
  begin
                     cpu_priority    = 0;
                     cpu_selected    = 0;
  end
  else
  begin
                     mbus_ack_memory = 0;
                     mem_access      = 0;
    for (i = 0; i < 4; i = i + 1)
       if ((mbus_cmd_array[cpu_priority+i] == `MESI_ISC_MBUS_CMD_WR |
            mbus_cmd_array[cpu_priority+i] == `MESI_ISC_MBUS_CMD_RD  ) &
            !mem_access)
    begin
                     mem_access      = 1;
                     cpu_selected    = cpu_priority+i;
                     mbus_ack_memory[cpu_priority+i] = 1;
      if (mbus_cmd_array[cpu_priority+i] == `MESI_ISC_MBUS_CMD_WR)
      // WR
      begin
                     sanity_check_rule1_rule2(cpu_selected,
                                            mbus_addr_array[cpu_priority+i],
                                            mbus_data_wr_array[cpu_priority+i]);
                     mem[mbus_addr_array[cpu_priority+i]] =
                                           mbus_data_wr_array[cpu_priority+i];
      end
      // RD
      else
                     mbus_data_rd =        mem[mbus_addr_array[cpu_priority+i]];
    end
  end
   
assign mbus_ack[3:0] = mbus_ack_memory[3:0] | mbus_ack_mesi_isc[3:0];

// Assigns
//================================
// GTKwave can't see arrays. points to array so GTKwave can see these signals
assign broad_fifo_entry0 = mesi_isc.mesi_isc_broad.broad_fifo.entry[0];
assign broad_fifo_entry1 = mesi_isc.mesi_isc_broad.broad_fifo.entry[1];
assign brroad_fifo_entry2 = mesi_isc.mesi_isc_broad.broad_fifo.entry[2];
assign brroad_fifo_entry3 = mesi_isc.mesi_isc_broad.broad_fifo.entry[3];
assign mbus_cmd3          = mbus_cmd_array[3];
assign mbus_cmd2          = mbus_cmd_array[2];
assign mbus_cmd1          = mbus_cmd_array[1];
assign mbus_cmd0          = mbus_cmd_array[0];
assign mbus_addr3         = mbus_addr_array[3];
assign mbus_addr2         = mbus_addr_array[2];
assign mbus_addr1         = mbus_addr_array[1];
assign mbus_addr0         = mbus_addr_array[0];
assign mbus_data_wr3      = mbus_data_wr_array[3];
assign mbus_data_wr2      = mbus_data_wr_array[2];
assign mbus_data_wr1      = mbus_data_wr_array[1];
assign mbus_data_wr0      = mbus_data_wr_array[0];
assign tb_ins3            = tb_ins_array[3];
assign tb_ins2            = tb_ins_array[2];
assign tb_ins1            = tb_ins_array[1];
assign tb_ins0            = tb_ins_array[0];
assign tb_ins_addr3       = tb_ins_addr_array[3];
assign tb_ins_addr2       = tb_ins_addr_array[2];
assign tb_ins_addr1       = tb_ins_addr_array[1];
assign tb_ins_addr0       = tb_ins_addr_array[0];
assign tb_ins_nop_period3 = tb_ins_nop_period[3];
assign tb_ins_nop_period2 = tb_ins_nop_period[2];
assign tb_ins_nop_period1 = tb_ins_nop_period[1];
assign tb_ins_nop_period0 = tb_ins_nop_period[0];
assign mem0 = mem[0];
assign mem1 = mem[1];
assign mem2 = mem[2];
assign mem3 = mem[3];
assign mem4 = mem[4];
assign mem5 = mem[5];
assign mem6 = mem[6];
assign mem7 = mem[7];
assign mem8 = mem[8];
assign mem9 = mem[9];
assign mbus_data_rd_word_array[3] = mbus_data_rd[31:24]; 
assign mbus_data_rd_word_array[2] = mbus_data_rd[23:16]; 
assign mbus_data_rd_word_array[1] = mbus_data_rd[15:8]; 
assign mbus_data_rd_word_array[0] = mbus_data_rd[7:0]; 
   
// Instantiations
//================================


// mesi_isc
mesi_isc #(CBUS_CMD_WIDTH,
           ADDR_WIDTH,
           BROAD_TYPE_WIDTH,
           BROAD_ID_WIDTH,
           BROAD_REQ_FIFO_SIZE,
           BROAD_REQ_FIFO_SIZE_LOG2,
           MBUS_CMD_WIDTH,
           BREQ_FIFO_SIZE,
           BREQ_FIFO_SIZE_LOG2
          )
  mesi_isc
    (
     // Inputs
     .clk              (clk),
     .rst              (rst),
     .mbus_cmd3_i      (mbus_cmd_array[3]),
     .mbus_cmd2_i      (mbus_cmd_array[2]),
     .mbus_cmd1_i      (mbus_cmd_array[1]),
     .mbus_cmd0_i      (mbus_cmd_array[0]),
     .mbus_addr3_i     (mbus_addr_array[3]),
     .mbus_addr2_i     (mbus_addr_array[2]),
     .mbus_addr1_i     (mbus_addr_array[1]),
     .mbus_addr0_i     (mbus_addr_array[0]),
     .cbus_ack3_i      (cbus_ack3),
     .cbus_ack2_i      (cbus_ack2),
     .cbus_ack1_i      (cbus_ack1),
     .cbus_ack0_i      (cbus_ack0),
     // Outputs
     .cbus_addr_o      (cbus_addr),
     .cbus_cmd3_o      (cbus_cmd3),
     .cbus_cmd2_o      (cbus_cmd2),
     .cbus_cmd1_o      (cbus_cmd1),
     .cbus_cmd0_o      (cbus_cmd0),
     .mbus_ack3_o      (mbus_ack_mesi_isc[3]),
     .mbus_ack2_o      (mbus_ack_mesi_isc[2]),
     .mbus_ack1_o      (mbus_ack_mesi_isc[1]),
     .mbus_ack0_o      (mbus_ack_mesi_isc[0])
    );

// mesi_isc_tb_cpu3
mesi_isc_tb_cpu  #(
       CBUS_CMD_WIDTH,
       ADDR_WIDTH,
       DATA_WIDTH,
       BROAD_TYPE_WIDTH,
       BROAD_ID_WIDTH,
       BROAD_REQ_FIFO_SIZE,
       BROAD_REQ_FIFO_SIZE_LOG2,
       MBUS_CMD_WIDTH,
       BREQ_FIFO_SIZE,
       BREQ_FIFO_SIZE_LOG2
      )
   //         \ /
   mesi_isc_tb_cpu3
    (
     // Inputs
     .clk              (clk),
     .rst              (rst),
     .cbus_addr_i      (cbus_addr),
     //                        \ /
     .cbus_cmd_i       (cbus_cmd3),
     //                             \ /
     .mbus_data_i      (mbus_data_rd),
     //                        \ /
     .mbus_ack_i       (mbus_ack[3]),
     //                   \ /
     .cpu_id_i         (2'd3),
     //                      \ /
     .tb_ins_i         (tb_ins_array[3]),
     //                           \ /
     .tb_ins_addr_i    (tb_ins_addr3),
     // Outputs                \ /
     .mbus_cmd_o       (mbus_cmd_array[3]),
      //                        \ /
     .mbus_addr_o      (mbus_addr_array[3]),
      //                        \ /
     .mbus_data_o      (mbus_data_wr_array[3]),
     //                        \ /
     .cbus_ack_o       (cbus_ack3),
     //                          \ /
     .tb_ins_ack_o     (tb_ins_ack[3])
 );

// mesi_isc_tb_cpu2
mesi_isc_tb_cpu  #(
       CBUS_CMD_WIDTH,
       ADDR_WIDTH,
       DATA_WIDTH,
       BROAD_TYPE_WIDTH,
       BROAD_ID_WIDTH,
       BROAD_REQ_FIFO_SIZE,
       BROAD_REQ_FIFO_SIZE_LOG2,
       MBUS_CMD_WIDTH,
       BREQ_FIFO_SIZE,
       BREQ_FIFO_SIZE_LOG2
      )
   //         \ /
   mesi_isc_tb_cpu2
    (
     // Inputs
     .clk              (clk),
     .rst              (rst),
     .cbus_addr_i      (cbus_addr),
     //                        \ /
     .cbus_cmd_i       (cbus_cmd2),
     //                             \ /
     .mbus_data_i      (mbus_data_rd),
     //                        \ /
     .mbus_ack_i       (mbus_ack[2]),
     //                   \ /
     .cpu_id_i         (2'd2),
     //                      \ /
     .tb_ins_i         (tb_ins_array[2]),
     //                           \ /
     .tb_ins_addr_i    (tb_ins_addr2),
     // Outputs                \ /
     .mbus_cmd_o       (mbus_cmd_array[2]),
      //                        \ /
     .mbus_addr_o      (mbus_addr_array[2]),
      //                        \ /
     .mbus_data_o      (mbus_data_wr_array[2]),
     //                        \ /
     .cbus_ack_o       (cbus_ack2),
     //                          \ /
     .tb_ins_ack_o     (tb_ins_ack[2])
 );

// mesi_isc_tb_cpu1
mesi_isc_tb_cpu  #(
       CBUS_CMD_WIDTH,
       ADDR_WIDTH,
       DATA_WIDTH,
       BROAD_TYPE_WIDTH,
       BROAD_ID_WIDTH,
       BROAD_REQ_FIFO_SIZE,
       BROAD_REQ_FIFO_SIZE_LOG2,
       MBUS_CMD_WIDTH,
       BREQ_FIFO_SIZE,
       BREQ_FIFO_SIZE_LOG2
      )
   //         \ /
   mesi_isc_tb_cpu1
    (
     // Inputs
     .clk              (clk),
     .rst              (rst),
     .cbus_addr_i      (cbus_addr),
     //                        \ /
     .cbus_cmd_i       (cbus_cmd1),
     //                             \ /
     .mbus_data_i      (mbus_data_rd),
     //                        \ /
     .mbus_ack_i       (mbus_ack[1]),
     //                   \ /
     .cpu_id_i         (2'd1),
     //                      \ /
     .tb_ins_i         (tb_ins_array[1]),
     //                           \ /
     .tb_ins_addr_i    (tb_ins_addr1),
     // Outputs                \ /
     .mbus_cmd_o       (mbus_cmd_array[1]),
      //                        \ /
     .mbus_addr_o      (mbus_addr_array[1]),
      //                        \ /
     .mbus_data_o      (mbus_data_wr_array[1]),
     //                        \ /
     .cbus_ack_o       (cbus_ack1),
     //                          \ /
     .tb_ins_ack_o     (tb_ins_ack[1])
 );

// mesi_isc_tb_cpu0
mesi_isc_tb_cpu  #(
       CBUS_CMD_WIDTH,
       ADDR_WIDTH,
       DATA_WIDTH,
       BROAD_TYPE_WIDTH,
       BROAD_ID_WIDTH,
       BROAD_REQ_FIFO_SIZE,
       BROAD_REQ_FIFO_SIZE_LOG2,
       MBUS_CMD_WIDTH,
       BREQ_FIFO_SIZE,
       BREQ_FIFO_SIZE_LOG2
      )
   //         \ /
   mesi_isc_tb_cpu0
    (
     // Inputs
     .clk              (clk),
     .rst              (rst),
     .cbus_addr_i      (cbus_addr),
     //                        \ /
     .cbus_cmd_i       (cbus_cmd0),
     //                             \ /
     .mbus_data_i      (mbus_data_rd),
     //                        \ /
     .mbus_ack_i       (mbus_ack[0]),
     //                   \ /
     .cpu_id_i         (2'd0),
     //                      \ /
     .tb_ins_i         (tb_ins_array[0]),
     //                           \ /
     .tb_ins_addr_i    (tb_ins_addr0),
     // Outputs                \ /
     .mbus_cmd_o       (mbus_cmd_array[0]),
      //                        \ /
     .mbus_addr_o      (mbus_addr_array[0]),
      //                        \ /
     .mbus_data_o      (mbus_data_wr_array[0]),
     //                        \ /
     .cbus_ack_o       (cbus_ack0),
     //                           \ /
     .tb_ins_ack_o     (tb_ins_ack[0])
 );

endmodule
