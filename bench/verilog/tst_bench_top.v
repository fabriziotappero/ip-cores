////////////////////////////////////////////////////////////////////////////////
//
//  WISHBONE revB.2 compliant Computer Operating Properly - Test Bench
//
//  Author: Bob Hayes
//          rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/cop.....
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

  //
  // wires && regs
  //
  reg        mstr_test_clk;
  reg [19:0] vector;
  reg [ 7:0] test_num;
  reg [15:0] wb_temp;
  reg        rstn;
  reg        sync_reset;
  reg        por_reset_b;
  reg        startup_osc;
  reg        stop_mode;
  reg        wait_mode;
  reg        debug_mode;
  reg        scantestmode;
  reg [ 8:0] osc_div;


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
  reg        en_osc_clk;
  wire       osc_clk;


  wire scl, scl0_o, scl0_oen, scl1_o, scl1_oen;
  wire sda, sda0_o, sda0_oen, sda1_o, sda1_oen;

  // Name Address Locations
  parameter COP_CNTRL = 5'b0_0000;
  parameter COP_TOUT  = 5'b0_0001;
  parameter COP_COUNT = 5'b0_0010;

  parameter RD      = 1'b1;
  parameter WR      = 1'b0;
  parameter SADR    = 7'b0010_000;

  parameter COP_CNTRL_COP_EVENT  = 16'h0100;  // COP Enable interrupt request
  parameter COP_CNTRL_IRQ        = 16'h00c0;  // COP Enable interrupt request
  parameter COP_CNTRL_DEBUG_ENA  = 16'h0020;  // COP Enable in system debug mode
  parameter COP_CNTRL_STOP_ENA   = 16'h0010;  // COP Enable in system stop mode
  parameter COP_CNTRL_WAIT_ENA   = 16'h0008;  // COP Enable in system wait mode
  parameter COP_CNTRL_COP_ENA    = 16'h0004;  // COP Enable bit
  parameter COP_CNTRL_CWP        = 16'h0002;  // COP Write Protect
  parameter COP_CNTRL_CLCK       = 16'h0001;  // COP Lock

  parameter COP_COUNT_SVRW0      = 16'h5555;  // Default COP Service word 0
  parameter COP_COUNT_SVRW1      = 16'haaaa;  // Default COP Service word 1

  parameter SLAVE_0_CNTRL = 5'b0_1000;
  parameter SLAVE_0_MOD   = 5'b0_1001;
  parameter SLAVE_0_COUNT = 5'b0_1010;

  parameter SLAVE_1_CNTRL = 5'b1_0000;
  parameter SLAVE_1_MOD   = 5'b1_0001;
  parameter SLAVE_1_COUNT = 5'b1_0010;

  parameter COP_2_CNTRL_0   = 5'b1_1000;
  parameter COP_2_CNTRL_1   = 5'b1_1001;
  parameter COP_2_TOUT_0    = 5'b1_1010;
  parameter COP_2_TOUT_1    = 5'b1_1011;
  parameter COP_2_COUNT_0   = 5'b1_1100;
  parameter COP_2_COUNT_1   = 5'b1_1101;

  // initial values and testbench setup
  initial
    begin
      mstr_test_clk = 0;
      vector = 0;
      test_num = 0;
      por_reset_b = 0;
      startup_osc = 0;
      stop_mode = 0;
      wait_mode = 0;
      debug_mode = 0;
      scantestmode = 0;
      osc_div = 0;
      en_osc_clk = 1'b0;

      `ifdef WAVES
           $shm_open("waves");
           $shm_probe("AS",tst_bench_top,"AS");
           $display("\nINFO: Signal dump enabled ...\n\n");
      `endif

      `ifdef WAVES_V
           $dumpfile ("cop_wave_dump.lxt");
           $dumpvars (0, tst_bench_top);
           $dumpon;
           $display("\nINFO: VCD Signal dump enabled ...\n\n");
      `endif

    end

  // generate clock
  always #20 mstr_test_clk = ~mstr_test_clk;

  always @(posedge mstr_test_clk)
    vector <= vector + 1;

  always @(mstr_test_clk)
    begin
      if (osc_div <= 7)
        osc_div <= osc_div + 1;
      else
	osc_div <= 0;
      if (osc_div == 7)
	startup_osc <= !startup_osc;
    end
    
  assign osc_clk = startup_osc && en_osc_clk;

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


  // Address decoding for different COP module instances
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

  // hookup wishbone_COP_master core - Parameters take all default values
  //  Async Reset, 16 bit Bus, 16 bit Granularity
  cop_top  #(.SINGLE_CYCLE(1'b0))
          cop_1(
          // wishbone interface
          .wb_clk_i(mstr_test_clk),
          .wb_rst_i(1'b0),         // sync_reset
          .arst_i(rstn),           // rstn
          .wb_adr_i(adr[2:0]),
          .wb_dat_i(dat_o),
          .wb_dat_o(dat0_i),
          .wb_we_i(we),
          .wb_stb_i(stb0),
          .wb_cyc_i(cyc),
          .wb_sel_i( 2'b11 ),
          .wb_ack_o(ack_1),

          .cop_rst_o(cop_1_out),
          .cop_irq_o(cop_1_irq),
          .por_reset_i(por_reset_b),
          .startup_osc_i(osc_clk),
          .stop_mode_i(stop_mode),
          .wait_mode_i(wait_mode),
          .debug_mode_i(debug_mode),
          .scantestmode(scantestmode)
  );

  // hookup wishbone_COP_slave core - Parameters take all default values
  //  Sync Reset, 16 bit Bus, 16 bit Granularity
  cop_top #(.ARST_LVL(1'b1),
            .INIT_ENA(1'b1),
            .SERV_WD_0(16'haa55),
	    .SERV_WD_1(16'hc396))
          cop_2(
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

          .cop_rst_o(cop_2_out),
          .cop_irq_o(cop_2_irq),
          .por_reset_i(por_reset_b),
          .startup_osc_i(osc_clk),
          .stop_mode_i(stop_mode),
          .wait_mode_i(wait_mode),
          .debug_mode_i(debug_mode),
          .scantestmode(scantestmode)
  );

  assign dat2_i = 16'h0000;
  assign ack_3 = 1'b0;

  // hookup wishbone_COP_slave core
  //  8 bit Bus, 8 bit Granularity
  cop_top #(.DWIDTH(8))
          cop_4(
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

          .cop_rst_o(cop_4_out),
          .cop_irq_o(cop_4_irq),
          .por_reset_i(por_reset_b),
          .startup_osc_i(osc_clk),
          .stop_mode_i(stop_mode),
          .wait_mode_i(wait_mode),
          .debug_mode_i(debug_mode),
          .scantestmode(scantestmode)
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
      por_reset_b = 1'b1;
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
      
      cop_count_test;
      
      cop_count_test_8;
      
      cop_irq_test;

      repeat(10) @(posedge mstr_test_clk);

      $display("\nTestbench done at vector=%d\n", vector);
      $finish;
  end

// Poll for flag set
task wait_flag_set;
  begin
    u0.wb_read(1, COP_CNTRL, q);
    while(~|(q & COP_CNTRL_COP_EVENT))
      u0.wb_read(1, COP_CNTRL, q); // poll it until it is set
    $display("COP Flag set detected at vector =%d", vector);
  end
endtask

// check register bits - reset, read/write
task reg_test_16;
  begin
      test_num = test_num + 1;
      $display("TEST #%d Starts at vector=%d, reg_test_16", test_num, vector);
      u0.wb_cmp(0, COP_CNTRL, 16'h0004);   // verify reset
      u0.wb_cmp(0, COP_TOUT,  16'hffff);   // verify reset
      u0.wb_cmp(0, COP_COUNT, 16'hffff);   // verify reset

      u0.wb_write(1, COP_CNTRL, 16'h0000); // Clear COP_ENA
      u0.wb_cmp(  0, COP_CNTRL, 16'h0000); // verify clear
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_WAIT_ENA);  //
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_WAIT_ENA);  //
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_STOP_ENA);  //
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_STOP_ENA);  //
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_DEBUG_ENA); //
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_DEBUG_ENA); //
      u0.wb_write(1, COP_CNTRL, 16'h0000); // Clear all bits

      u0.wb_write(1, COP_TOUT, 16'hc639); // Check TOUT reg
      u0.wb_cmp(  0, COP_TOUT, 16'hc639); // verify
      u0.wb_write(1, COP_TOUT, 16'h39c6); // Check TOUT reg
      u0.wb_cmp(  0, COP_TOUT, 16'h39c6); // verify

      // Verify that control bits can not be changed when COP_ENA is set
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_COP_ENA); //
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_COP_ENA); //
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_WAIT_ENA | COP_CNTRL_STOP_ENA | COP_CNTRL_DEBUG_ENA | COP_CNTRL_COP_ENA);
      $display("Debug 1");
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_COP_ENA); // verify that all bits are still clear
      $display("Debug 2");

      u0.wb_write(1, COP_CNTRL, 16'h0000); // Clear COP_ENA
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_WAIT_ENA | COP_CNTRL_STOP_ENA | COP_CNTRL_DEBUG_ENA);
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_WAIT_ENA | COP_CNTRL_STOP_ENA | COP_CNTRL_DEBUG_ENA);
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_WAIT_ENA | COP_CNTRL_STOP_ENA | COP_CNTRL_DEBUG_ENA | COP_CNTRL_COP_ENA); //
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_WAIT_ENA | COP_CNTRL_STOP_ENA | COP_CNTRL_DEBUG_ENA | COP_CNTRL_COP_ENA);
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_COP_ENA); //
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_WAIT_ENA | COP_CNTRL_STOP_ENA | COP_CNTRL_DEBUG_ENA | COP_CNTRL_COP_ENA);
      u0.wb_write(1, COP_CNTRL, 16'h0000); //
      u0.wb_cmp(  0, COP_CNTRL, 16'h0000);

      // Verify TOUT bits are locked when COP_ENA is set
      u0.wb_write(1, COP_TOUT,  16'h5555); // Check TOUT reg
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_COP_ENA); // Lock TOUT reg
      u0.wb_write(1, COP_TOUT,  16'haaaa); // Try to overwrite with new bits
      u0.wb_cmp(  0, COP_TOUT,  16'h5555); // verify old bits are still there
      u0.wb_write(1, COP_CNTRL, 16'h0000); // Enable writes to TOUT reg
      u0.wb_write(1, COP_TOUT,  16'haaaa); // Write new bits
      u0.wb_cmp(  0, COP_TOUT,  16'haaaa); // verify new bits
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_COP_ENA); // Lock TOUT reg
      u0.wb_write(1, COP_TOUT,  16'h5555); // Try to overwrite with new bits
      u0.wb_cmp(  0, COP_TOUT,  16'haaaa); // verify old bits are still there
      u0.wb_write(1, COP_CNTRL, 16'h0000); // Enable writes to TOUT reg

      // Verify COP_EN bit is locked when CWP is set
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_COP_ENA | COP_CNTRL_CWP); // 
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_COP_ENA | COP_CNTRL_CWP);
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_CWP); // 
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_COP_ENA | COP_CNTRL_CWP);
      u0.wb_write(1, COP_CNTRL, 16'h0000);      // 
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_COP_ENA);
      u0.wb_write(1, COP_CNTRL, 16'h0000);      // 
      u0.wb_cmp(  0, COP_CNTRL, 16'h0000);
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_CWP); // 
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_COP_ENA | COP_CNTRL_CWP); // 
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_CWP);
     
      // Verify CWP bit is locked when CLCK is set
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_CLCK | COP_CNTRL_CWP); // COP Write Protect is ON
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_CLCK | COP_CNTRL_CWP);
      u0.wb_write(1, COP_CNTRL, 16'h0000);  // Try too clear both bits 
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_CLCK | COP_CNTRL_CWP);
      system_reset;  // This is the only way to clear CLCK
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_COP_ENA);
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_CLCK); // COP Write Protect is OFF
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_CLCK);
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_COP_ENA | COP_CNTRL_CWP | COP_CNTRL_WAIT_ENA | COP_CNTRL_STOP_ENA | COP_CNTRL_DEBUG_ENA);
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_CLCK | COP_CNTRL_COP_ENA | COP_CNTRL_WAIT_ENA | COP_CNTRL_STOP_ENA | COP_CNTRL_DEBUG_ENA);
      

      $display("Debug 3");
      u0.wb_read( 0, COP_COUNT, wb_temp);
      u0.wb_write(0, COP_COUNT, 16'h0000);
      u0.wb_cmp(  0, COP_COUNT, wb_temp); // verify register not writable
      u0.wb_write(0, COP_COUNT, 16'hffff);
      u0.wb_cmp(  0, COP_COUNT, wb_temp); // verify register not writable

      system_reset;  // This is the only way to clear CLCK

  end
endtask

task reg_test_8;
  begin
      test_num = test_num + 1;
      $display("TEST #%d Starts at vector=%d, reg_test_8", test_num, vector);
      u0.wb_cmp(0, COP_2_CNTRL_0, 16'h0004);   // verify reset
      u0.wb_cmp(0, COP_2_CNTRL_1, 16'h0000);   // verify reset
      u0.wb_cmp(0, COP_2_TOUT_0,  16'h00ff);   // verify reset
      u0.wb_cmp(0, COP_2_TOUT_1,  16'h00ff);   // verify reset
      u0.wb_cmp(0, COP_2_COUNT_0, 16'h00ff);   // verify reset
      u0.wb_cmp(0, COP_2_COUNT_1, 16'h00ff);   // verify reset

      u0.wb_write(0, COP_2_CNTRL_0, 16'h0000);  // Remove write prtection
      u0.wb_write(0, COP_2_TOUT_0,  16'haa55);
      u0.wb_cmp(  0, COP_2_TOUT_0,  16'h0055);   // verify write
      u0.wb_cmp(  0, COP_2_TOUT_1,  16'h00ff);   // verify hig byte unchanged
      u0.wb_write(0, COP_2_TOUT_1,  16'h66aa);
      u0.wb_cmp(  0, COP_2_TOUT_1,  16'h00aa);   // verify write
      u0.wb_cmp(  0, COP_2_TOUT_0,  16'h0055);   // verify low byte unchanged

  end
endtask

task cop_count_test;
  begin
      test_num = test_num + 1;
      $display("TEST #%d Starts at vector=%d, cop_count_test",
                test_num, vector);
      // program internal registers
      u0.wb_cmp(  0, COP_COUNT, 16'hffff); // reset value
      u0.wb_write(1, COP_CNTRL, 16'h0000); // Turn off COP_ENA
      u0.wb_write(1, COP_TOUT,  16'h5555); // Write TOUT reg
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_COP_ENA); //
      send_x_osc_clks(1);
      u0.wb_cmp(  0, COP_COUNT, 16'h5555); // verify counter initilized
      send_x_osc_clks(5);
      u0.wb_cmp(  0, COP_COUNT, 16'h5550); // verify counter has decremented
      u0.wb_write(0, COP_COUNT, COP_COUNT_SVRW0); // Send the two Service words
      u0.wb_write(0, COP_COUNT, COP_COUNT_SVRW1);
      send_x_osc_clks(2);
      u0.wb_cmp(  0, COP_COUNT, 16'h5555); // verify counter initilized
      send_x_osc_clks(5);
      u0.wb_cmp(  0, COP_COUNT, 16'h5550); // verify counter has decremented
      u0.wb_write(1, COP_CNTRL, 16'h0000); // Turn off COP_ENA
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_COP_ENA); // Verify toggle of COP_ENA resets COP
      send_x_osc_clks(2);
      u0.wb_cmp(  0, COP_COUNT, 16'h5555); // verify counter initilized

      u0.wb_write(1, COP_CNTRL, 16'h0000); // Turn off COP_ENA
      u0.wb_write(1, COP_TOUT,  16'h0005); // Write TOUT reg
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_COP_ENA); //
      send_x_osc_clks(9);  // Give enough clocks so counter rolls over
      repeat(8) @(posedge mstr_test_clk);
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_COP_EVENT | COP_CNTRL_COP_ENA); // verify Status bit set
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_COP_EVENT | COP_CNTRL_COP_ENA); //
      u0.wb_cmp(  1, COP_CNTRL, COP_CNTRL_COP_ENA); // verify Status bit cleared
      
      u0.wb_write(1, COP_CNTRL, 16'h0000); // Turn off COP_ENA
      u0.wb_write(1, COP_TOUT,  16'h0005); // Write TOUT reg
      u0.wb_write(1, COP_CNTRL, COP_CNTRL_COP_ENA); //
      send_x_osc_clks(9);  // Give enough clocks so counter rolls over
      repeat(8) @(posedge mstr_test_clk);
      u0.wb_cmp(  0, COP_CNTRL, COP_CNTRL_COP_EVENT | COP_CNTRL_COP_ENA); // verify Status bit set
      u0.wb_write(0, COP_COUNT, COP_COUNT_SVRW0);   // Send the two Service words
      u0.wb_write(0, COP_COUNT, COP_COUNT_SVRW1);
      u0.wb_cmp(  1, COP_CNTRL, COP_CNTRL_COP_ENA); // verify Status bit cleared

   end
endtask

task cop_irq_test;
  begin
      test_num = test_num + 1;
      $display("TEST #%d Starts at vector=%d, cop_irq_test",
                test_num, vector);
      // program internal registers
      u0.wb_write(1, COP_CNTRL, 16'h0000); // Turn off COP_ENA
      u0.wb_write(1, COP_TOUT,  16'h0014); // Write TOUT reg
//      u0.wb_write(1, COP_CNTRL, COP_CNTRL_IRQ | COP_CNTRL_COP_ENA); //
      u0.wb_write(1, COP_CNTRL, 16'h0040 | COP_CNTRL_COP_ENA); //
      send_x_osc_clks(10);

      u0.wb_write(1, COP_CNTRL, 16'h0000); // Turn off COP_ENA
      u0.wb_write(1, COP_TOUT,  16'h0022); // Write TOUT reg
      send_x_osc_clks(1);
//      u0.wb_write(1, COP_CNTRL, COP_CNTRL_IRQ | COP_CNTRL_COP_ENA); //
      u0.wb_write(1, COP_CNTRL, 16'h0080 | COP_CNTRL_COP_ENA); //
      send_x_osc_clks(10);
   end
endtask

task cop_count_test_8;
  begin
      test_num = test_num + 1;
      $display("TEST #%d Starts at vector=%d, cop_count_test_8",
                test_num, vector);
      // program internal registers
      u0.wb_write(0, COP_2_CNTRL_0, 16'h0000);  // Remove write prtection

      u0.wb_write(0, COP_2_TOUT_0,  16'h0005);  // Set timout value
      u0.wb_write(0, COP_2_TOUT_1,  16'h0000);
      u0.wb_write(0, COP_2_CNTRL_0, COP_CNTRL_COP_ENA);  // Enable COP Watchdog Timer

      send_x_osc_clks(9);  // Give enough clocks so counter rolls over

      u0.wb_cmp(0, COP_2_CNTRL_1, 16'h0001);   // verify COP event bit set

      u0.wb_write(0, COP_2_COUNT_0, 16'h0055);   // write 8 bit service words
      u0.wb_write(0, COP_2_COUNT_0, 16'h00aa);   //  to clear event
      send_x_osc_clks(2);  // Give enough clocks so counter rolls over
      u0.wb_cmp(0, COP_2_CNTRL_1, 16'h0000);   // verify COP event bit set
   end
endtask

task system_reset;  // reset system
  begin
      repeat(1) @(posedge mstr_test_clk);
      sync_reset = 1'b1;  // Make the sync reset 1 clock cycle long
      #2;                 // move the async reset away from the clock edge
      rstn = 1'b0;        // assert async reset
      #5;                 // Keep the async reset pulse with less than a clock cycle
      rstn = 1'b1;        // negate async reset
      repeat(1) @(posedge mstr_test_clk);
      sync_reset = 1'b0;

      $display("\nstatus: %t System Reset Task Done", $time);
      test_num = test_num + 1;

      repeat(2) @(posedge mstr_test_clk);
   end
endtask


task send_x_osc_clks;
  input [ 7:0] x_val;
  begin
      $display("Sending %d osc_clks", x_val);

      @(negedge startup_osc);
      #2;                // 
      en_osc_clk = 1'b1; // 
      repeat(x_val) @(posedge startup_osc);
      @(negedge startup_osc);
      #2;                // 
      en_osc_clk = 1'b0; // 
      repeat(1) @(posedge mstr_test_clk);
   end
endtask


endmodule  // tst_bench_top

