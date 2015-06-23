////////////////////////////////////////////////////////////////////////////////
//
//  WISHBONE revB.2 compliant Programable Interval Timer - Test Bench
//
//  Author: Bob Hayes
//          rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/pit.....
//
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009, Robert Hayes
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY Robert Hayes ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL Robert Hayes BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
////////////////////////////////////////////////////////////////////////////////
// 45678901234567890123456789012345678901234567890123456789012345678901234567890


`include "timescale.v"

module tst_bench_top();

  parameter STOP_ON_ERROR = 1'b0;
  parameter MAX_VECTOR = 1_000;
  //
  // wires && regs
  //
  reg        mstr_test_clk;
  reg [19:0] vector;
  reg [ 7:0] test_num;
  reg        rstn;
  reg        sync_reset;

  wire [31:0] adr;
  wire [15:0] dat_i, dat_o, dat0_i, dat1_i, dat2_i, dat3_i;
  wire we;
  wire stb;
  wire cyc;
  wire ack, ack_1, ack_2, ack_3, ack_4;
  wire inta_1, inta_2, inta_3, inta_4;
  wire count_en_1;
  wire count_flag_1;

  reg [15:0] q, qq;
  reg [15:0] error_count;

  wire scl, scl0_o, scl0_oen, scl1_o, scl1_oen;
  wire sda, sda0_o, sda0_oen, sda1_o, sda1_oen;

  // Name Address Locations
  parameter PIT_CNTRL = 5'b0_0000;
  parameter PIT_MOD   = 5'b0_0001;
  parameter PIT_COUNT = 5'b0_0010;

  parameter RD      = 1'b1;
  parameter WR      = 1'b0;
  parameter SADR    = 7'b0010_000;

  parameter CTR_EN  = 8'b1000_0000;  // core enable bit
  parameter CTR_IEN = 8'b0100_0000;  // core interrupt enable bit

  parameter PIT_CNTRL_SLAVE  = 16'h8000;  // PIT Slave mode
  parameter PIT_CNTRL_FLAG   = 16'h0004;  // PIT Rollover Flag
  parameter PIT_CNTRL_IRQEN  = 16'h0002;  // PIT Interupt Enable
  parameter PIT_CNTRL_ENA    = 16'h0001;  // PIT Enable

  parameter SLAVE_0_CNTRL = 5'b0_1000;
  parameter SLAVE_0_MOD   = 5'b0_1001;
  parameter SLAVE_0_COUNT = 5'b0_1010;

  parameter SLAVE_1_CNTRL = 5'b1_0000;
  parameter SLAVE_1_MOD   = 5'b1_0001;
  parameter SLAVE_1_COUNT = 5'b1_0010;

  parameter SLAVE_2_CNTRL_0 = 5'b1_1000;
  parameter SLAVE_2_CNTRL_1 = 5'b1_1001;
  parameter SLAVE_2_MOD_0   = 5'b1_1010;
  parameter SLAVE_2_MOD_1   = 5'b1_1011;
  parameter SLAVE_2_COUNT_0 = 5'b1_1100;
  parameter SLAVE_2_COUNT_1 = 5'b1_1101;

  // initial values and testbench setup
  initial
    begin
      mstr_test_clk = 0;
      vector = 0;
      test_num = 0;
      error_count = 0;

      `ifdef WAVES
	   $shm_open("waves");
	   $shm_probe("AS",tst_bench_top,"AS");
	   $display("\nINFO: Signal dump enabled ...\n\n");
	`endif

	`ifdef WAVES_V
	   $dumpfile ("pit_wave_dump.lxt");
	   $dumpvars (0, tst_bench_top);
	   $dumpon;
	   $display("\nINFO: VCD Signal dump enabled ...\n\n");
	`endif

    end

  // generate clock
  always #20 mstr_test_clk = ~mstr_test_clk;

  // Keep a count of how many clocks we've simulated
  always @(posedge mstr_test_clk)
    begin
      vector <= vector + 1;
      if (vector > MAX_VECTOR)
        begin
          error_count <= error_count + 1;
          $display("\n ------ !!!!! Simulation Timeout at vector=%d\n -------", vector);
          wrap_up;
        end
    end

  // Add up errors tha come from WISHBONE read compares
  always @u0.cmp_error_detect
    begin
      error_count <= error_count + 1;
    end

  // hookup wishbone master model
  wb_master_model #(.dwidth(16), .awidth(32))
	  u0 (
	  .clk(mstr_test_clk),
	  .rst(rstn),
	  .adr(adr),
	  .din(dat_i),
	  .dout(dat_o),
	  .cyc(cyc),
	  .stb(stb),
	  .we(we),
	  .sel(),
	  .ack(ack),
	  .err(1'b0),
	  .rty(1'b0)
  );


  // Address decoding for different PIT module instances
  wire stb0 = stb && ~adr[4] && ~adr[3];
  wire stb1 = stb && ~adr[4] &&  adr[3];
  wire stb2 = stb &&  adr[4] && ~adr[3];
  wire stb3 = stb &&  adr[4] &&  adr[3];

  // Create the Read Data Bus
  assign dat_i = ({16{stb0}} & dat0_i) |
		 ({16{stb1}} & dat1_i) |
		 ({16{stb2}} & dat2_i) |
		 ({16{stb3}} & {8'b0, dat3_i[7:0]});

  assign ack = ack_1 || ack_2 || ack_3 || ack_4;

  // hookup wishbone_PIT_master core - Parameters take all default values
  //  Async Reset, 16 bit Bus, 16 bit Granularity,Wait States
  pit_top #(.SINGLE_CYCLE(1'b0))
          pit_1(
	  // wishbone interface
	  .wb_clk_i(mstr_test_clk),
	  .wb_rst_i(1'b0),
	  .arst_i(rstn),
	  .wb_adr_i(adr[2:0]),
	  .wb_dat_i(dat_o),
	  .wb_dat_o(dat0_i),
	  .wb_we_i(we),
	  .wb_stb_i(stb0),
	  .wb_cyc_i(cyc),
	  .wb_sel_i( 2'b11 ),
	  .wb_ack_o(ack_1),
	  .pit_irq_o(inta_1),

	  .pit_o(pit_1_out),
	  .ext_sync_i(1'b0),
	  .cnt_sync_o(count_en_1),
	  .cnt_flag_o(count_flag_1)
  );

  // hookup wishbone_PIT_slave core - Parameters take all default values
  //  Sync Reset, 16 bit Bus, 16 bit Granularity
  pit_top #(.ARST_LVL(1'b1))
	  pit_2(
	  // wishbone interface
	  .wb_clk_i(mstr_test_clk),
	  .wb_rst_i(sync_reset),
	  .arst_i(1'b0),
	  .wb_adr_i(adr[2:0]),
	  .wb_dat_i(dat_o),
	  .wb_dat_o(dat1_i),
	  .wb_we_i(we),
	  .wb_stb_i(stb1),
	  .wb_cyc_i(cyc),
	  .wb_sel_i( 2'b11 ),
	  .wb_ack_o(ack_2),
	  .pit_irq_o(inta_2),

	  .pit_o(pit_2_out),
	  .ext_sync_i(count_en_1),
	  .cnt_sync_o(count_en_2),
	  .cnt_flag_o(count_flag_2)
  );

  // hookup wishbone_PIT_slave core
  //  16 bit Bus, 16 bit Granularity
  pit_top #(.NO_PRESCALE(1'b1))
	  pit_3(
	  // wishbone interface
	  .wb_clk_i(mstr_test_clk),
	  .wb_rst_i(sync_reset),
	  .arst_i(1'b1),
	  .wb_adr_i(adr[2:0]),
	  .wb_dat_i(dat_o),
	  .wb_dat_o(dat2_i),
	  .wb_we_i(we),
	  .wb_stb_i(stb2),
	  .wb_cyc_i(cyc),
	  .wb_sel_i( 2'b11 ),
	  .wb_ack_o(ack_3),
	  .pit_irq_o(inta_3),

	  .pit_o(pit_3_out),
	  .ext_sync_i(count_en_1),
	  .cnt_sync_o(count_en_3),
	  .cnt_flag_o(count_flag_3)
  );

  // hookup wishbone_PIT_slave core
  //  8 bit Bus, 8 bit Granularity
  pit_top #(.DWIDTH(8))
	  pit_4(
	  // wishbone interface
	  .wb_clk_i(mstr_test_clk),
	  .wb_rst_i(sync_reset),
	  .arst_i(1'b1),
	  .wb_adr_i(adr[2:0]),
	  .wb_dat_i(dat_o[7:0]),
	  .wb_dat_o(dat3_i[7:0]),
	  .wb_we_i(we),
	  .wb_stb_i(stb3),
	  .wb_cyc_i(cyc),
	  .wb_sel_i( 2'b11 ),
	  .wb_ack_o(ack_4),
	  .pit_irq_o(inta_4),

	  .pit_o(pit_4_out),
	  .ext_sync_i(count_en_1),
	  .cnt_sync_o(count_en_4),
	  .cnt_flag_o(count_flag_4)
  );

// Test Program
initial
  begin
      $display("\nstatus: %t Testbench started", $time);

      // reset system
      rstn = 1'b1; // negate reset
      repeat(1) @(posedge mstr_test_clk);
      sync_reset = 1'b1;  // Make the sync reset 1 clock cycle long
      #2;          // move the async reset away from the clock edge
      rstn = 1'b0; // assert async reset
      #5;          // Keep the async reset pulse with less than a clock cycle
      rstn = 1'b1; // negate async reset
      repeat(1) @(posedge mstr_test_clk);
      sync_reset = 1'b0;

      $display("\nstatus: %t done reset", $time);
      test_num = test_num + 1;

      repeat(2) @(posedge mstr_test_clk);

      //
      // program core
      //

      reg_test_16;

      reg_test_8;

      u0.wb_write(1, SLAVE_0_CNTRL,   PIT_CNTRL_SLAVE); // Enable Slave Mode
      u0.wb_write(1, SLAVE_1_CNTRL,   PIT_CNTRL_SLAVE); // Enable Slave Mode
      u0.wb_write(1, SLAVE_2_CNTRL_1, 16'h0080); // Enable Slave Mode
      u0.wb_write(1, SLAVE_0_MOD,     16'h000a); // load Modulo
      u0.wb_write(1, SLAVE_1_MOD,     16'h0010); // load Modulo
      u0.wb_write(1, SLAVE_2_MOD_0,   16'h0010); // load Modulo
      
      // Set Master Mode PS=0, Modulo=16
      test_num = test_num + 1;
      $display("TEST #%d Starts at vector=%d, ms_test", test_num, vector);

      u0.wb_write(1, PIT_MOD,   16'h0010); // load prescaler hi-byte
      u0.wb_write(1, PIT_CNTRL, PIT_CNTRL_ENA); // Enable to start counting
      $display("status: %t programmed registers", $time);

      wait_flag_set;  // Wait for Counter to tomeout
      u0.wb_write(1, PIT_CNTRL, PIT_CNTRL_FLAG | PIT_CNTRL_ENA); //

      wait_flag_set;  // Wait for Counter to tomeout
      u0.wb_write(1, PIT_CNTRL, PIT_CNTRL_FLAG | PIT_CNTRL_ENA); //

      repeat(10) @(posedge mstr_test_clk);
      u0.wb_write(1, PIT_CNTRL, 16'b0); //
      
      repeat(10) @(posedge mstr_test_clk);

      mstr_psx_modx(2,4);

      mstr_psx_modx(4,0);

      repeat(100) @(posedge mstr_test_clk);
      
      wrap_up;
      
  end  // Main Test Flow

// Poll for flag set
task wait_flag_set;
  begin
    u0.wb_read(1, PIT_CNTRL, q);
    while(~|(q & PIT_CNTRL_FLAG))
      u0.wb_read(1, PIT_CNTRL, q); // poll it until it is set
    $display("PIT Flag set detected at vector =%d", vector);
  end
endtask

// check register bits - reset, read/write
task reg_test_16;
  begin
      test_num = test_num + 1;
      $display("TEST #%d Starts at vector=%d, reg_test_16", test_num, vector);
      u0.wb_cmp(0, PIT_CNTRL, 16'h4000);   // verify reset
      u0.wb_cmp(0, PIT_MOD,   16'h0000);   // verify reset
      u0.wb_cmp(0, PIT_COUNT, 16'h0001);   // verify reset

      u0.wb_write(1, PIT_CNTRL, 16'hfffe); // load prescaler lo-byte
      u0.wb_cmp(  0, PIT_CNTRL, 16'hCf02); // verify write data
      u0.wb_write(1, PIT_CNTRL, 16'h0000); // load prescaler lo-byte
      u0.wb_cmp(  0, PIT_CNTRL, 16'h4000); // verify write data

      u0.wb_write(1, PIT_MOD, 16'h5555); // load prescaler lo-byte
      u0.wb_cmp(  0, PIT_MOD, 16'h5555); // verify write data
      u0.wb_write(1, PIT_MOD, 16'haaaa); // load prescaler lo-byte
      u0.wb_cmp(  0, PIT_MOD, 16'haaaa); // verify write data
      
      u0.wb_write(0, PIT_COUNT, 16'hfffe);
      u0.wb_cmp(  0, PIT_COUNT, 16'h0001); // verify register not writable
  end
endtask

task reg_test_8;
  begin
      test_num = test_num + 1;
      $display("TEST #%d Starts at vector=%d, reg_test_8", test_num, vector);
      u0.wb_cmp(0, SLAVE_2_CNTRL_0, 16'h0000);   // verify reset
      u0.wb_cmp(0, SLAVE_2_CNTRL_1, 16'h0040);   // verify reset
      u0.wb_cmp(0, SLAVE_2_MOD_0,   16'h0000);   // verify reset
      u0.wb_cmp(0, SLAVE_2_MOD_1,   16'h0000);   // verify reset
      u0.wb_cmp(0, SLAVE_2_COUNT_0, 16'h0001);   // verify reset
      u0.wb_cmp(0, SLAVE_2_COUNT_1, 16'h0000);   // verify reset

      u0.wb_write(1, SLAVE_2_CNTRL_0, 16'hfffe); // load prescaler lo-byte
      u0.wb_cmp(  0, SLAVE_2_CNTRL_0, 16'h0002); // verify write data
      u0.wb_write(1, SLAVE_2_CNTRL_0, 16'h0000); // load prescaler lo-byte
      u0.wb_cmp(  0, SLAVE_2_CNTRL_0, 16'h0000); // verify write data
      u0.wb_cmp(  0, SLAVE_2_CNTRL_1, 16'h0040); // verify write data

      u0.wb_write(1, SLAVE_2_MOD_0, 16'hff55); // load prescaler lo-byte
      u0.wb_cmp(  0, SLAVE_2_MOD_0, 16'h0055); // verify write data
      u0.wb_write(1, SLAVE_2_MOD_0, 16'hffaa); // load prescaler lo-byte
      u0.wb_cmp(  0, SLAVE_2_MOD_0, 16'h00aa); // verify write data
      u0.wb_write(1, SLAVE_2_MOD_1, 16'hff66); // load prescaler lo-byte
      u0.wb_cmp(  0, SLAVE_2_MOD_1, 16'h0066); // verify write data
      u0.wb_write(1, SLAVE_2_MOD_1, 16'hff99); // load prescaler lo-byte
      u0.wb_cmp(  0, SLAVE_2_MOD_1, 16'h0099); // verify write data
      u0.wb_write(1, SLAVE_2_MOD_1, 16'hff00); // load prescaler lo-byte

      u0.wb_write(0, SLAVE_2_COUNT_0, 16'hfffe);
      u0.wb_cmp(  0, SLAVE_2_COUNT_0, 16'h0001); // verify register not writable
      u0.wb_write(0, SLAVE_2_COUNT_1, 16'hfffe);
      u0.wb_cmp(  0, SLAVE_2_COUNT_1, 16'h0000); // verify register not writable
  end
endtask

task mstr_psx_modx;
  input	[ 3:0] ps_val;
  input	[15:0] mod_val;
  reg   [15:0] cntrl_val;
  begin
      test_num = test_num + 1;
      $display("TEST #%d Starts at vector=%d, mstr_psx_modx Pre=%h, Mod=%h",
                test_num, vector, ps_val, mod_val);
      // program internal registers

      cntrl_val = {1'b0, 3'b0, ps_val, 8'b0} | PIT_CNTRL_IRQEN;
      u0.wb_write(1, PIT_MOD,   mod_val); // load modulo
      u0.wb_write(1, PIT_CNTRL, ( cntrl_val | PIT_CNTRL_ENA)); // Enable to start counting

      wait_flag_set;  // Wait for Counter to timeout
      u0.wb_write(1, PIT_CNTRL, cntrl_val | PIT_CNTRL_FLAG | PIT_CNTRL_ENA); //

      wait_flag_set;  // Wait for Counter to timeout
      u0.wb_write(1, PIT_CNTRL, cntrl_val | PIT_CNTRL_FLAG | PIT_CNTRL_ENA); //

      repeat(10) @(posedge mstr_test_clk);
      
      u0.wb_write(1, PIT_CNTRL, 16'b0); //

   end
endtask

task wrap_up;
  begin
    test_num = test_num + 1;
    repeat(10) @(posedge mstr_test_clk);
    $display("\nSimulation Finished!! - vector =%d", vector);
    if (error_count == 0)
      $display("Simulation Passed");
    else
      $display("Simulation Failed  --- Errors =%d", error_count);

    $finish;
  end
endtask


endmodule  // tst_bench_top

