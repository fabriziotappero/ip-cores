////////////////////////////////////////////////////////////////////////////////
//
//  WISHBONE revB.2 compliant Xgate Coprocessor - Test Bench
//
//  Author: Bob Hayes
//      rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/xgate.....
//
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009, Robert Hayes
//
// This source file is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Supplemental terms.
//     * Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
//     * Neither the name of the <organization> nor the
//   names of its contributors may be used to endorse or promote products
//   derived from this software without specific prior written permission.
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
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////////////
// 45678901234567890123456789012345678901234567890123456789012345678901234567890


`include "timescale.v"

module tst_bench_top();

  parameter MAX_CHANNEL   = 127;    // Max XGATE Interrupt Channel Number
  parameter STOP_ON_ERROR = 1'b0;
  parameter MAX_VECTOR    = 22_000;

  parameter L_BYTE = 2'b01;
  parameter H_BYTE = 2'b10;
  parameter WORD   = 2'b11;

  parameter TB_ADDR_WIDTH = 24;  // Testbench address bus width
  parameter TB_DATA_WIDTH = 16;


  // Name Address Locations
  parameter XGATE_BASE     = 24'h1000;
  parameter XGATE_XGMCTL   = XGATE_BASE + 6'h00;
  parameter XGATE_XGCHID   = XGATE_BASE + 6'h02;
  parameter XGATE_XGISPHI  = XGATE_BASE + 6'h04;
  parameter XGATE_XGISPLO  = XGATE_BASE + 6'h06;
  parameter XGATE_XGVBR    = XGATE_BASE + 6'h08;
  parameter XGATE_XGIF_7   = XGATE_BASE + 6'h0a;
  parameter XGATE_XGIF_6   = XGATE_BASE + 6'h0c;
  parameter XGATE_XGIF_5   = XGATE_BASE + 6'h0e;
  parameter XGATE_XGIF_4   = XGATE_BASE + 6'h10;
  parameter XGATE_XGIF_3   = XGATE_BASE + 6'h12;
  parameter XGATE_XGIF_2   = XGATE_BASE + 6'h14;
  parameter XGATE_XGIF_1   = XGATE_BASE + 6'h16;
  parameter XGATE_XGIF_0   = XGATE_BASE + 6'h18;
  parameter XGATE_XGSWT    = XGATE_BASE + 6'h1a;
  parameter XGATE_XGSEM    = XGATE_BASE + 6'h1c;
  parameter XGATE_RES1     = XGATE_BASE + 6'h1e;
  parameter XGATE_XGCCR    = XGATE_BASE + 6'h20;
  parameter XGATE_XGPC     = XGATE_BASE + 6'h22;
  parameter XGATE_RES2     = XGATE_BASE + 6'h24;
  parameter XGATE_XGR1     = XGATE_BASE + 6'h26;
  parameter XGATE_XGR2     = XGATE_BASE + 6'h28;
  parameter XGATE_XGR3     = XGATE_BASE + 6'h2a;
  parameter XGATE_XGR4     = XGATE_BASE + 6'h2c;
  parameter XGATE_XGR5     = XGATE_BASE + 6'h2e;
  parameter XGATE_XGR6     = XGATE_BASE + 6'h30;
  parameter XGATE_XGR7     = XGATE_BASE + 6'h32;

  // Define bits in XGATE Control Register
  parameter XGMCTL_XGEM     = 16'h8000;
  parameter XGMCTL_XGFRZM   = 16'h4000;
  parameter XGMCTL_XGDBGM   = 15'h2000;
  parameter XGMCTL_XGSSM    = 15'h1000;
  parameter XGMCTL_XGFACTM  = 15'h0800;
  parameter XGMCTL_XGBRKIEM = 15'h0400;
  parameter XGMCTL_XGSWEIFM = 15'h0200;
  parameter XGMCTL_XGIEM    = 15'h0100;
  parameter XGMCTL_XGE      = 16'h0080;
  parameter XGMCTL_XGFRZ    = 16'h0040;
  parameter XGMCTL_XGDBG    = 15'h0020;
  parameter XGMCTL_XGSS     = 15'h0010;
  parameter XGMCTL_XGFACT   = 15'h0008;
  parameter XGMCTL_XGBRKIE  = 15'h0004;
  parameter XGMCTL_XGSWEIF  = 15'h0002;
  parameter XGMCTL_XGIE     = 15'h0001;

  // Define Address locations used by the testbench
  parameter CHECK_POINT     = 16'h8000;
  parameter CHANNEL_ACK     = CHECK_POINT + 2;
  parameter CHANNEL_ERR     = CHECK_POINT + 4;
  parameter DEBUG_CNTRL     = CHECK_POINT + 6;
  parameter TB_SEMPHORE     = CHECK_POINT + 10;
  parameter CHANNEL_XGIRQ_0 = CHECK_POINT + 16;
  parameter CHANNEL_XGIRQ_1 = CHECK_POINT + 18;
  parameter CHANNEL_XGIRQ_2 = CHECK_POINT + 20;
  parameter CHANNEL_XGIRQ_3 = CHECK_POINT + 22;
  parameter CHANNEL_XGIRQ_4 = CHECK_POINT + 24;
  parameter CHANNEL_XGIRQ_5 = CHECK_POINT + 26;
  parameter CHANNEL_XGIRQ_6 = CHECK_POINT + 28;
  parameter CHANNEL_XGIRQ_7 = CHECK_POINT + 30;

  parameter BREAK_CAPT_0    = CHECK_POINT + 64;
  parameter BREAK_CAPT_1    = CHECK_POINT + 66;
  parameter BREAK_CAPT_2    = CHECK_POINT + 68;
  parameter BREAK_CAPT_3    = CHECK_POINT + 70;
  parameter BREAK_CAPT_4    = CHECK_POINT + 72;
  parameter BREAK_CAPT_5    = CHECK_POINT + 74;
  parameter BREAK_CAPT_6    = CHECK_POINT + 76;
  parameter BREAK_CAPT_7    = CHECK_POINT + 78;

  parameter SYS_RAM_BASE = 24'h00_0000;

  parameter RAM_WAIT_STATES    = 1; // Number between 0 and 15
  parameter SYS_READ_DELAY     = 10;
  parameter XGATE_ACCESS_DELAY = SYS_READ_DELAY + RAM_WAIT_STATES;
  parameter XGATE_SS_DELAY     = XGATE_ACCESS_DELAY + RAM_WAIT_STATES;

  parameter IRQ_BASE       = XGATE_BASE + 64;
  parameter IRQ_BYPS_0     = IRQ_BASE + 0;
  parameter IRQ_BYPS_1     = IRQ_BASE + 2;
  parameter IRQ_BYPS_2     = IRQ_BASE + 4;
  parameter IRQ_BYPS_3     = IRQ_BASE + 6;
  parameter IRQ_BYPS_4     = IRQ_BASE + 8;
  parameter IRQ_BYPS_5     = IRQ_BASE + 10;
  parameter IRQ_BYPS_6     = IRQ_BASE + 12;
  parameter IRQ_BYPS_7     = IRQ_BASE + 14;

  //
  // wires && regs
  //
  reg         mstr_test_clk;
  reg  [19:0] vector;
  reg  [15:0] error_count;
  reg  [ 7:0] test_num;

  reg  [15:0] q, qq;

  reg       rstn;
  reg       sync_reset;
  reg       scantestmode;

  reg  [MAX_CHANNEL:1] channel_req;  // XGATE Interrupt inputs
  wire [MAX_CHANNEL:1] xgif;         // XGATE Interrupt outputs
  wire         [  7:0] xgswt;        // XGATE Software Trigger outputs
  wire                 xg_sw_irq;    // Xgate Software Error interrupt
  wire          [15:0] brkpt_cntl;   //


  wire [15:0] wbm_dat_o;   // WISHBONE Master Mode data output from XGATE
  wire [15:0] wbm_dat_i;   // WISHBONE Master Mode data input to XGATE
  wire [15:0] wbm_adr_o;   // WISHBONE Master Mode address output from XGATE
  wire [ 1:0] wbm_sel_o;

  reg         mem_wait_state_enable;

  wire [15:0] tb_ram_out;

  wire [15:0] tb_slave_dout; // WISHBONE data bus output from testbench slave module
  wire        error_pulse;   // Error detected output pulse from the testbench slave module
  wire        tb_slave_ack;  // WISHBONE ack from testbench slave module
  wire        ack_pulse;     // Thread ack output pulse from testbench slave module

  wire        wbm_cyc_o;
  wire        wbm_stb_o;
  wire        wbm_we_o;
  wire        wbs_err_o;


  // Registers used to mirror internal registers
  reg  [15:0] data_xgmctl;
  reg  [15:0] data_xgchid;
  reg  [15:0] data_xgvbr;
  reg  [15:0] data_xgswt;
  reg  [15:0] data_xgsem;

  wire        sys_cyc;
  wire        sys_stb;
  wire        sys_we;
  wire [ 1:0] sys_sel;
  wire [23:0] sys_adr;
  wire [15:0] sys_dout;
  wire [15:0] sys_din;

  wire        host_ack;
  wire [15:0] host_dout;
  wire        host_cyc;
  wire        host_stb;
  wire        host_we;
  wire [ 1:0] host_sel;
  wire [23:0] host_adr;
  wire [15:0] host_din;

  wire        xgate_ack;
  wire [15:0] xgate_dout;
  wire        xgate_cyc;
  wire        xgate_stb;
  wire        xgate_we;
  wire [ 1:0] xgate_sel;
  wire [15:0] xgate_adr;
  wire [15:0] xgate_din;

  wire        xgate_s_stb;
  wire        xgate_s_ack;
  wire [15:0] xgate_s_dout;

  wire        slv2_stb;
  wire        ram_sel;
  wire [15:0] ram_dout;

  // initial values and testbench setup
  initial
    begin
      mstr_test_clk = 0;
      vector        = 0;
      test_num      = 0;
      scantestmode  = 0;
      error_count   = 0;
      mem_wait_state_enable = 0;
      // channel_req = 0;

      `ifdef WAVES
         $shm_open("waves");
         $shm_probe("AS", tst_bench_top, "AS");
         $display("\nINFO: Signal dump enabled ...\n\n");
      `endif

      `ifdef WAVES_V
         $dumpfile ("xgate_wave_dump.lxt");
         $dumpvars (0, tst_bench_top);
         $dumpon;
         $display("\nINFO: VCD Signal dump enabled ...\n\n");
      `endif

      //-------------------------------------------------------
      // Enable Debussy dumping of simulation
      `ifdef FSDB
         $fsdbDumpfile("verilog.fsdb");
         $fsdbDumpvars(0, tst_bench_top);
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

  // Add up errors that come from WISHBONE read compares
  always @host.cmp_error_detect
    begin
      error_count <= error_count + 1;
    end

  always @(posedge error_pulse) //channel_ack_wrt
    begin
      #1;
      error_count = error_count + 1;
      if (STOP_ON_ERROR == 1'b1)
        wrap_up;
    end

  wire [ 6:0] current_active_channel = xgate.risc.xgchid;
  always @(posedge ack_pulse) //channel_ack_wrt
    clear_channel(current_active_channel);



  // Testbench RAM for Xgate program storage and Load/Store instruction tests
  ram p_ram
  (
    // Outputs
    .ram_out( ram_dout ),
    // inputs
    .address( sys_adr[15:0] ),
    .ram_in( sys_dout ),
    .we( sys_we ),
    .ce( ram_sel ),
    .stb( mstr_test_clk ),
    .sel( sys_sel )
  );

  // hookup wishbone master model
  wb_master_model #(.dwidth(TB_DATA_WIDTH), .awidth(TB_ADDR_WIDTH))
    host(
    // Outputs
    .cyc( host_cyc ),
    .stb( host_stb ),
    .we( host_we ),
    .sel( host_sel ),
    .adr( host_adr ),
    .dout( host_dout ),
    // inputs
    .din( sys_din ),
    .clk( mstr_test_clk ),
    .ack( host_ack ),
    .rst( rstn ),
    .err( 1'b0 ),
    .rty( 1'b0 )
  );

  bus_arbitration  #(.dwidth(TB_DATA_WIDTH),
                     .awidth(TB_ADDR_WIDTH),
                     .ram_base(0),
                     .ram_size(17'h10000),
                     .slv1_base(XGATE_BASE),
                     .slv1_size(128),
                     .slv2_base(CHECK_POINT),
                     .slv2_size(32),
                     .ram_wait_states(RAM_WAIT_STATES)
)
    arb(
    // System bus I/O
    .sys_cyc( sys_cyc ),
    .sys_stb( sys_stb ),
    .sys_we( sys_we ),
    .sys_sel( sys_sel ),
    .sys_adr( sys_adr ),
    .sys_dout( sys_dout ),
    .sys_din( sys_din ),
    // Host bus I/O
    .host_ack( host_ack ),
    .host_dout( host_din ),
    .host_cyc( host_cyc ),
    .host_stb( host_stb ),
    .host_we( host_we ),
    .host_sel( host_sel ),
    .host_adr( host_adr ),
    .host_din( host_dout ),
    // Alternate Bus Master #1 Bus I/O
    .alt1_ack( xgate_ack ),
    .alt1_cyc( wbm_cyc_o ),
    .alt1_stb( wbm_stb_o ),
    .alt1_we( wbm_we_o ),
    .alt1_sel( wbm_sel_o ),
    .alt1_adr( {8'h00, wbm_adr_o} ),
    .alt1_din( wbm_dat_o ),
    // RAM
    .ram_sel( ram_sel ),
    .ram_dout( ram_dout ),
    // Slave #1 Bus I/O
    .slv1_stb( xgate_s_stb ),
    .slv1_ack( xgate_s_ack ),
    .slv1_din( xgate_s_dout ),
    // Slave #2 Bus I/O
    .slv2_stb( slv2_stb ),
    .slv2_ack( tb_slave_ack ),
    .slv2_din( tb_slave_dout ),
    // Miscellaneous
    .host_clk( mstr_test_clk ),
    .risc_clk( mstr_test_clk ),
    .rst( rstn ),  // No Connect
    .err( 1'b0 ),  // No Connect
    .rty( 1'b0 )   // No Connect
  );

  // hookup XGATE core - Parameters take all default values
  xgate_top  #(.SINGLE_CYCLE(1'b0),
               .WB_RD_DEFAULT(1'b0),
               .MAX_CHANNEL(MAX_CHANNEL))    // Max XGATE Interrupt Channel Number
    xgate(
    // Wishbone slave interface
    .wbs_clk_i( mstr_test_clk ),
    .wbs_rst_i( sync_reset ),       // sync_reset
    .arst_i( rstn ),                // async resetn
    .wbs_adr_i( sys_adr[6:1] ),
    .wbs_dat_i( sys_dout ),
    .wbs_dat_o( xgate_s_dout ),
    .wbs_we_i( sys_we ),
    .wbs_stb_i( xgate_s_stb ),
    .wbs_cyc_i( sys_cyc ),
    .wbs_sel_i( sys_sel ),
    .wbs_ack_o( xgate_s_ack ),
    .wbs_err_o( wbs_err_o ),

    // Wishbone master Signals
    .wbm_dat_o( wbm_dat_o ),
    .wbm_we_o( wbm_we_o ),
    .wbm_stb_o( wbm_stb_o ),
    .wbm_cyc_o( wbm_cyc_o ),
    .wbm_sel_o( wbm_sel_o ),
    .wbm_adr_o( wbm_adr_o ),
    .wbm_dat_i( sys_din ),
    .wbm_ack_i( xgate_ack ),

    .xgif( xgif ),             // XGATE Interrupt Flag output
    .xg_sw_irq( xg_sw_irq ),   // XGATE Software Error Interrupt Flag output
    .xgswt( xgswt ),
    .risc_clk( mstr_test_clk ),
    .chan_req_i( {channel_req[MAX_CHANNEL:40], xgswt, channel_req[31:1]} ),
    .debug_mode_i( 1'b0 ),
    .secure_mode_i( 1'b0 ),
    .scantestmode( scantestmode )
  );

  tb_slave #(.DWIDTH(16),
             .SINGLE_CYCLE(1'b1),
             .MAX_CHANNEL(MAX_CHANNEL))
    tb_slave_regs(
    // wishbone interface
    .wb_clk_i( mstr_test_clk ),
    .wb_rst_i( 1'b0 ),
    .arst_i( rstn ),
    .wb_adr_i( sys_adr[4:1] ),
    .wb_dat_i( sys_dout ),
    .wb_dat_o( tb_slave_dout),
    .wb_we_i( sys_we ),
    .wb_stb_i( slv2_stb ),
    .wb_cyc_i( sys_cyc ),
    .wb_sel_i( sys_sel ),
    .wb_ack_o( tb_slave_ack ),

    .ack_pulse( ack_pulse ),
          .brkpt_cntl( brkpt_cntl ),
    .error_pulse( error_pulse ),
    .brk_pt(  ),
    .x_address( wbm_adr_o ),
    .xgif( xgif ),
    .vector( vector )
  );

tb_debug #(.DWIDTH(16),                  // Data bus width
           .BREAK_CAPT_0(BREAK_CAPT_0),
           .BREAK_CAPT_1(BREAK_CAPT_1),
           .BREAK_CAPT_2(BREAK_CAPT_2),
           .BREAK_CAPT_3(BREAK_CAPT_3),
           .BREAK_CAPT_4(BREAK_CAPT_4),
           .BREAK_CAPT_5(BREAK_CAPT_5),
           .BREAK_CAPT_6(BREAK_CAPT_6),
           .BREAK_CAPT_7(BREAK_CAPT_7))
  debugger(
    .arst_i( rstn ),
    .risc_clk( mstr_test_clk ),
    .brkpt_cntl( brkpt_cntl )
  );


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Main Test Program
initial
  begin
    $display("\nstatus at time: %t Testbench started", $time);

    // reset system
    rstn        <= 1'b0; // negate reset
    channel_req <= 1;    //
    sync_reset  <= 1'b0; // Don't do sync reset
    #5;                  // Keep the async reset pulse with less than a clock cycle
    rstn = 1'b1;         // negate async reset
    channel_req = 0;     //
    repeat(1) @(posedge mstr_test_clk);

    $display("\nstatus at time: %t done reset", $time);

    pc_rollover;

    test_skipjack;
    wrap_up;

    test_inst_set;

    test_debug_mode;

    test_debug_bit;

    test_chid_debug;

    reg_test_16;

    reg_irq;

    sync_reset_test;
    
    // host_ram;

    // End testing
    wrap_up;
  end

////////////////////////////////////////////////////////////////////////////////
// Test CHID Debug mode operation
task test_chid_debug;
  begin
    test_num = test_num + 1;
    $display("\nTEST #%d Starts at vector=%d, test_chid_debug", test_num, vector);
    $readmemh("../../../bench/verilog/debug_test.v", p_ram.ram_8);

    // Enable interrupts to RISC
    host.wb_write(0, IRQ_BYPS_0,  16'h0000, WORD);

    data_xgmctl = XGMCTL_XGBRKIEM | XGMCTL_XGBRKIE;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Enable interrupt on BRK instruction
    $display("BRK Software Error Interrupt enabled at vector=%d", vector);

    activate_thread_sw(3);

    wait_debug_set;   // Debug Status bit is set by BRK instruction

    host.wb_cmp(0, XGATE_XGPC,     16'h20c6, WORD);  // See Program code (BRK).
    host.wb_cmp(0, XGATE_XGR3,     16'h0001, WORD);  // See Program code.R3 = 1
    host.wb_cmp(0, XGATE_XGCHID,   16'h0003, WORD);  // Check for Correct CHID
    $display("Debug entry detected at vector=%d", vector);

    channel_req[5] = 1'b1; //
    repeat(7) @(posedge mstr_test_clk);
    host.wb_cmp(0, XGATE_XGCHID,   16'h0003, WORD);    // Check for Correct CHID

    host.wb_write(0, XGATE_XGCHID, 16'h000f, H_BYTE);  // Check byte select lines
    repeat(4) @(posedge mstr_test_clk);
    host.wb_cmp(0, XGATE_XGCHID,   16'h0003, WORD);    // Verify CHID is unchanged

    host.wb_write(0, XGATE_XGCHID, 16'h000f, L_BYTE);  // Change CHID
    host.wb_cmp(0, XGATE_XGCHID,   16'h000f, WORD);    // Check for Correct CHID

    host.wb_write(0, XGATE_XGCHID, 16'h0000, WORD);    // Change CHID to 00, RISC should go to IDLE state

    repeat(1) @(posedge mstr_test_clk);

    host.wb_write(0, XGATE_XGCHID, 16'h0004, WORD);    // Change CHID

    repeat(8) @(posedge mstr_test_clk);
    $display("Channel ID changed at vector=%d", vector);


    data_xgmctl = XGMCTL_XGDBGM;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Clear Debug Mode Control Bit

    wait_debug_set;                                      // Debug Status bit is set by BRK instruction
    host.wb_cmp(0, XGATE_XGCHID,   16'h0004, WORD);      // Check for Correct CHID
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Clear Debug Mode Control Bit (Excape from Break State and run)

    wait_debug_set;   // Debug Status bit is set by BRK instruction
    host.wb_cmp(0, XGATE_XGCHID,   16'h0005, WORD);      // Check for Correct CHID
    activate_channel(6);
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Clear Debug Mode Control Bit (Excape from Break State and run)

    wait_debug_set;                                      // Debug Status bit is set by BRK instruction
    host.wb_cmp(0, XGATE_XGCHID,   16'h0006, WORD);      // Check for Correct CHID
    host.wb_cmp(0, XGATE_XGPC,     16'h211c, WORD);      // See Program code (BRK)
    data_xgmctl = XGMCTL_XGSSM | XGMCTL_XGSS;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);
    host.wb_cmp(0, XGATE_XGPC,     16'h211e, WORD);      // See Program code (BRA)
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);
    host.wb_cmp(0, XGATE_XGPC,     16'h2122, WORD);      // See Program code ()

    repeat(20) @(posedge mstr_test_clk);

    data_xgmctl = XGMCTL_XGDBGM;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Clear Debug Mode Control Bit

    repeat(50) @(posedge mstr_test_clk);

    p_ram.dump_ram(0);

    read_ram_cmp(16'h0000, 16'h7b55);
    read_ram_cmp(16'h0004, 16'h7faa);
    read_ram_cmp(16'h0006, 16'h6f55);
    read_ram_cmp(16'h0008, 16'h00c3);
    read_ram_cmp(16'h000a, 16'h5f66);
    read_ram_cmp(16'h000c, 16'h0003);
    read_ram_cmp(16'h0022, 16'hccxx);
    read_ram_cmp(16'h0026, 16'hxx99);
    read_ram_cmp(16'h0032, 16'h1fcc);
    read_ram_cmp(16'h0038, 16'h2f99);
    read_ram_cmp(16'h0042, 16'h33xx);
    read_ram_cmp(16'h0046, 16'hxx55);
    read_ram_cmp(16'h0052, 16'hxx66);
    read_ram_cmp(16'h0058, 16'h99xx);
    read_ram_cmp(16'h0062, 16'h1faa);
    read_ram_cmp(16'h0068, 16'h2fcc);

  end
endtask

////////////////////////////////////////////////////////////////////////////////
// Test Debug bit operation
task test_debug_bit;
  begin
    test_num = test_num + 1;
    $display("\nTEST #%d Starts at vector=%d, test_debug_bit", test_num, vector);
    $readmemh("../../../bench/verilog/debug_test.v", p_ram.ram_8);

    // Enable interrupts to RISC
    host.wb_write(0, IRQ_BYPS_0,  16'h0000, WORD);

    data_xgmctl = XGMCTL_XGBRKIEM | XGMCTL_XGBRKIE;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Enable interrupt on BRK instruction

    activate_thread_sw(2);

    // Approxmatly 12 instructions need to be done before activating Debug Mode
    repeat(12 + RAM_WAIT_STATES*12) @(posedge mstr_test_clk);

    data_xgmctl = XGMCTL_XGDBGM | XGMCTL_XGDBG;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Set Debug Mode Control Bit
    repeat(5) @(posedge mstr_test_clk);
    $display("DEBUG bit set at vector=%d", vector);

    host.wb_read(1, XGATE_XGR3, q, WORD);
    data_xgmctl = XGMCTL_XGSSM | XGMCTL_XGSS;
    qq = q;

    // The Xgate test program is in an infinite loop incrementing R3
    while (qq == q)  // Look for change in R3 register
      begin
        host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step
        repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);
        host.wb_read(1, XGATE_XGR3, q, WORD);
      end
    if (q != (qq+1))
      begin
        $display("Error! - Unexpected value of R3 at vector=%d", vector);
        error_count = error_count + 1;
      end


    host.wb_write(1, XGATE_XGPC, 16'h2094, WORD);    // Write to PC to force exit from infinite loop
    repeat(10) @(posedge mstr_test_clk);
    host.wb_cmp(0, XGATE_XGPC,     16'h2094, WORD);  // Verify Proram Counter was changed
    $display("Program Counter changed at vector=%d", vector);

    data_xgmctl = XGMCTL_XGSSM | XGMCTL_XGSS;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step (Load ADDL instruction)
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);
    host.wb_cmp(0, XGATE_XGR4,     16'h0002, WORD);      // See Program code.(R4 <= R4 + 1)

    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step (Load ADDL instruction)
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);
    host.wb_cmp(0, XGATE_XGR4,     16'h0003, WORD);      // See Program code.(R4 <= R4 + 1)

    data_xgmctl = XGMCTL_XGDBGM;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Clear Debug Mode Control Bit
             // Should be back in Run Mode

//    data_xgmctl = XGMCTL_XGSWEIFM | XGMCTL_XGSWEIF | XGMCTL_XGBRKIEM;
//    host.wb_write(0, XGATE_XGMCTL, data_xgmctl);   // Clear Software Interrupt and BRK Interrupt Enable Bit
    repeat(15) @(posedge mstr_test_clk);

  end
endtask

////////////////////////////////////////////////////////////////////////////////
// Test Debug mode operation
task test_debug_mode;
  begin
    test_num = test_num + 1;
    $display("\nTEST #%d Starts at vector=%d, test_debug_mode", test_num, vector);
    $readmemh("../../../bench/verilog/debug_test.v", p_ram.ram_8);

    // Enable interrupts to RISC
    host.wb_write(0, IRQ_BYPS_0,  16'h0000, WORD);

    data_xgmctl = XGMCTL_XGBRKIEM | XGMCTL_XGBRKIE;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Enable interrupt on BRK instruction

    activate_thread_sw(1);

    wait_debug_set;   // Debug Status bit is set by BRK instruction

    host.wb_cmp(0, XGATE_XGPC,     16'h203a, WORD);  // See Program code (BRK).
    host.wb_cmp(0, XGATE_XGR3,     16'h0001, WORD);  // See Program code.R3 = 1

    data_xgmctl = XGMCTL_XGSSM | XGMCTL_XGSS;

    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step (Load ADDL instruction)
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);
    host.wb_cmp(0, XGATE_XGPC,     16'h203c, WORD);      // PC + 2.

    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step (Load NOP instruction)
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);     // Execute ADDL instruction
    host.wb_cmp(0, XGATE_XGR3,     16'h0002, WORD);      // See Program code.(R3 <= R3 + 1)
    host.wb_cmp(0, XGATE_XGCCR,    16'h0000, WORD);      // See Program code.
    host.wb_cmp(0, XGATE_XGPC,     16'h203e, WORD);      // PC + 2.
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);
    host.wb_cmp(0, XGATE_XGPC,     16'h203e, WORD);      // Still no change.

    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step (Load BRA instruction)
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);     // Execute NOP instruction
    host.wb_cmp(0, XGATE_XGPC,     16'h2040, WORD);      // See Program code.


    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);     // Execute BRA instruction
    host.wb_cmp(0, XGATE_XGPC,     16'h2064, WORD);      // PC = Branch destination.
               // Load ADDL instruction

    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step (Load LDW R7 instruction)
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);     // Execute ADDL instruction
    host.wb_cmp(0, XGATE_XGPC,     16'h2066, WORD);      // PC + 2.
    host.wb_cmp(0, XGATE_XGR3,     16'h0003, WORD);      // See Program code.(R3 <= R3 + 1)

    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step (LDW R7)
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);
    host.wb_cmp(0, XGATE_XGPC,     16'h2068, WORD);      // PC + 2.
    host.wb_cmp(0, XGATE_XGR7,     16'h00c3, WORD);      // See Program code

    repeat(1) @(posedge mstr_test_clk);
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step (BRA)
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);
    host.wb_cmp(0, XGATE_XGPC,     16'h2048, WORD);      // See Program code.

    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step (STW R3)
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);
    host.wb_cmp(0, XGATE_XGPC,     16'h204a, WORD);      // PC + 2.
    host.wb_cmp(0, XGATE_XGR3,     16'h0003, WORD);      // See Program code.(R3 <= R3 + 1)

    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Do a Single Step (R3 <= R3 + 1)
    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);
    host.wb_cmp(0, XGATE_XGPC,     16'h204c, WORD);      // PC + 2.

    repeat(XGATE_SS_DELAY) @(posedge mstr_test_clk);

    data_xgmctl = XGMCTL_XGDBGM;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Clear Debug Mode Control Bit
               // Should be back in Run Mode
    wait_irq_set(1);
    host.wb_write(1, XGATE_XGIF_0, 16'h0002, WORD);

    data_xgmctl = XGMCTL_XGSWEIFM | XGMCTL_XGSWEIF | XGMCTL_XGBRKIEM;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Clear Software Interrupt and BRK Interrupt Enable Bit
    repeat(15) @(posedge mstr_test_clk);

  end
endtask

////////////////////////////////////////////////////////////////////////////////
// Test instruction set
task test_inst_set;
  begin
    $readmemh("../../../bench/verilog/inst_test.v", p_ram.ram_8);
    test_num = test_num + 1;
    $display("\nTEST #%d Starts at vector=%d, test_inst_set", test_num, vector);
    repeat(1) @(posedge mstr_test_clk);

    // Enable XGATE SW interrupt for error detection of bad instructions
    //   There should not be any!
    data_xgmctl = XGMCTL_XGIEM | XGMCTL_XGIE;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);

    // Enable interrupts to RISC
    host.wb_write(0, IRQ_BYPS_0,  16'h0000, WORD);

    // Test Shift instructions
    activate_thread_sw(1);
    wait_irq_set(1);
    host.wb_write(1, XGATE_XGIF_0, 16'h0002, WORD);

    // Test Logical Byte wide instructions
    activate_thread_sw(2);
    wait_irq_set(2);
    host.wb_write(1, XGATE_XGIF_0, 16'h0004, WORD);

    // Test Logical Word Wide instructions
    activate_thread_sw(3);
    wait_irq_set(3);
    host.wb_write(1, XGATE_XGIF_0, 16'h0008, WORD);

    // Test Bit Field instructions
    activate_thread_sw(4);
    wait_irq_set(4);
    host.wb_write(1, XGATE_XGIF_0, 16'h0010, WORD);

    // Test Branch instructions
    activate_thread_sw(5);
    wait_irq_set(5);
    host.wb_write(1, XGATE_XGIF_0, 16'h0020, WORD);

    // Test Subroutine Call and return instructions
    activate_thread_sw(6);
    wait_irq_set(6);
    host.wb_write(1, XGATE_XGIF_0, 16'h0040, WORD);

    // Test 16 bit Addition and Substract instructions
    activate_thread_sw(7);
    wait_irq_set(7);
    host.wb_write(1, XGATE_XGIF_0, 16'h0080, WORD);

    // Test 8 bit Addition and Substract instructions
    activate_thread_sw(8);
    wait_irq_set(8);
    host.wb_write(1, XGATE_XGIF_0, 16'h0100, WORD);

    // Test Load and Store instructions
    activate_thread_sw(9);
    wait_irq_set(9);
    host.wb_write(1, XGATE_XGIF_0, 16'h0200, WORD);

    // Test Semaphore instructions
    host.wb_write(1, XGATE_XGSEM, 16'h5050, WORD);
    host.wb_cmp(0, XGATE_XGSEM,    16'h0050, WORD);   //
    activate_thread_sw(10);
    wait_irq_set(10);
    host.wb_write(1, XGATE_XGIF_0, 16'h0400, WORD);

    host.wb_write(1, XGATE_XGSEM, 16'hff00, WORD);    // clear the old settings
    host.wb_cmp(0, XGATE_XGSEM,   16'h0000, WORD);    //
    host.wb_write(1, XGATE_XGSEM, 16'ha0a0, WORD);    // Verify that bits were unlocked by RISC
    host.wb_cmp(0, XGATE_XGSEM,   16'h00a0, WORD);    // Verify bits were set
    host.wb_write(1, XGATE_XGSEM, 16'hff08, WORD);    // Try to set the bit that was left locked by the RISC
    host.wb_cmp(0, XGATE_XGSEM,   16'h0000, WORD);    // Verify no bits were set

    repeat(20) @(posedge mstr_test_clk);

    p_ram.dump_ram(0);

    read_ram_cmp(16'h0000, 16'haa55);
    read_ram_cmp(16'h0004, 16'h7faa);
    read_ram_cmp(16'h0006, 16'h6f55);
    read_ram_cmp(16'h000a, 16'h5f66);
    read_ram_cmp(16'h0032, 16'h1fcc);
    read_ram_cmp(16'h0038, 16'h2f99);
    read_ram_cmp(16'h0062, 16'h1faa);
    read_ram_cmp(16'h0068, 16'h2fcc);
    read_ram_cmp(16'h0022, 16'hccxx);
    read_ram_cmp(16'h0026, 16'hxx99);
    read_ram_cmp(16'h0052, 16'hxx66);
    read_ram_cmp(16'h0058, 16'h99xx);
    read_ram_cmp(16'h0080, 16'h9966);
    read_ram_cmp(16'h0086, 16'h7533);

    // All the tested instructions should have been legal
    if (xg_sw_irq)
      begin
        error_count = error_count + 1;
        $display("SW IRQ active after instruction test, vector=%d", vector);
        clear_sw_irq;  // Don't let error state propogate into following tests
      end

    data_xgmctl = 16'hff00;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Disable XGATE

  end
endtask

////////////////////////////////////////////////////////////////////////////////
// check pc rollover error detection
task pc_rollover;
  integer i, j, k;
  begin
    $readmemh("../../../bench/verilog/pc_rollover.v", p_ram.ram_8);
    test_num = test_num + 1;
    $display("\nTEST #%d Starts at vector=%d, pc_rollover", test_num, vector);

    data_xgmctl = XGMCTL_XGIEM | XGMCTL_XGIE;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Enable XGATE SW interrupt for error detection

    host.wb_write(0, XGATE_XGVBR,  16'h8800, WORD); // set vector table address to match test code
    repeat(4) @(posedge mstr_test_clk);

    // Enable interrupts to RISC
    host.wb_write(0, IRQ_BYPS_0,  16'h0000, WORD);

    // Test #1 - single step past the end of memory space
    // Test #2 - branch past the end of memory space
    // Test #3 - branch past the begining of memory space
    for (i = 1; i <= 3; i = i + 1)
      begin
        $display("  -- Subtest %0d Starts at vector = %0d, pc over/underrun", i, vector);
        activate_thread_sw(i);
    
        wait_sw_irq_set(8'd100);
        clear_sw_irq;
        channel_req[i] = 1'b0; //
        repeat(1) @(posedge mstr_test_clk);
        host.wb_cmp(0, XGATE_XGMCTL,   16'h00A1, WORD); // verify Debug mode
        data_xgmctl = XGMCTL_XGEM | XGMCTL_XGDBGM;      // Clear Debug mode and XGATE Enable
        host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);
        repeat(14) @(posedge mstr_test_clk);
      end


  end
endtask

////////////////////////////////////////////////////////////////////////////////
// Test skipjack encription - test subset of instruction set on a real problem
task test_skipjack;
  begin
    $readmemh("../../../bench/verilog/skipjack.v", p_ram.ram_8);
    test_num = test_num + 1;
    $display("\nTEST #%d Starts at vector=%d, test_skipjack", test_num, vector);
    repeat(1) @(posedge mstr_test_clk);

    host.wb_write(0, DEBUG_CNTRL,  16'hFFFF, WORD);

    host.wb_write(0, XGATE_XGVBR,  16'hFE00, WORD); // set vector table address to match test code
    repeat(4) @(posedge mstr_test_clk);

    // Enable interrupts to RISC
    host.wb_write(0, IRQ_BYPS_0,  16'h0000, WORD);

    activate_thread_sw(2);
    wait_irq_set(2);
    host.wb_write(1, XGATE_XGIF_0, 16'h0002, WORD);


    repeat(20) @(posedge mstr_test_clk);

    p_ram.dump_ram(16'h2000);
    // repeat(2) @(posedge mstr_test_clk);
    // p_ram.dump_ram(16'h9000);

    data_xgmctl = 16'hff00;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Disable XGATE

  end
endtask

////////////////////////////////////////////////////////////////////////////////
// check register bits - reset, read/write
task reg_test_16;
  begin
    test_num = test_num + 1;
    $display("\nTEST #%d Starts at vector=%d, reg_test_16", test_num, vector);

    system_reset;

    host.wb_cmp(0, XGATE_XGMCTL,   16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGCHID,   16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGISPHI,  16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGISPLO,  16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGVBR,    16'hfe00, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGIF_7,   16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGIF_6,   16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGIF_5,   16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGIF_4,   16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGIF_3,   16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGIF_2,   16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGIF_1,   16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGIF_0,   16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGSWT,    16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGSEM,    16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGCCR,    16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGPC,     16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGR1,     16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGR2,     16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGR3,     16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGR4,     16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGR5,     16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGR6,     16'h0000, WORD); // verify reset
    host.wb_cmp(0, XGATE_XGR7,     16'h0000, WORD); // verify reset

   // Test bits in the Xgate Control Register (XGMCTL)
    data_xgmctl = XGMCTL_XGEM | XGMCTL_XGFRZM | XGMCTL_XGFACTM | XGMCTL_XGFRZ | XGMCTL_XGFACT | XGMCTL_XGE;
    host.wb_write(0, XGATE_XGMCTL,   data_xgmctl, WORD);   //
    data_xgmctl = XGMCTL_XGFRZ | XGMCTL_XGFACT | XGMCTL_XGE;
    host.wb_cmp(  0, XGATE_XGMCTL, data_xgmctl, WORD);

    data_xgmctl = XGMCTL_XGEM;
    host.wb_write(0, XGATE_XGMCTL,   data_xgmctl, WORD);   //
    data_xgmctl = XGMCTL_XGFRZ | XGMCTL_XGFACT;
    host.wb_cmp(  0, XGATE_XGMCTL, data_xgmctl, WORD);

    data_xgmctl = XGMCTL_XGFRZM | XGMCTL_XGFACTM;
    host.wb_write(0, XGATE_XGMCTL,   data_xgmctl, WORD);   //
    data_xgmctl = 16'h0000;
    host.wb_cmp(  0, XGATE_XGMCTL, data_xgmctl, WORD);

    data_xgmctl = 16'hffff;
    host.wb_write(0, XGATE_XGMCTL,   data_xgmctl, H_BYTE); //
    data_xgmctl = 16'h0000;
    host.wb_cmp(  0, XGATE_XGMCTL, data_xgmctl, WORD);

    data_xgmctl = 16'hffff;
    host.wb_write(0, XGATE_XGMCTL,   data_xgmctl, L_BYTE); //
    data_xgmctl = 16'h0000;
    host.wb_cmp(  0, XGATE_XGMCTL, data_xgmctl, WORD);

    // Test the Xgate Vector Base Address Register (XGVBR)
    host.wb_write(0, XGATE_XGVBR,  16'h5555, WORD);
    host.wb_cmp(0, XGATE_XGVBR,    16'h5554, WORD);

    host.wb_write(0, XGATE_XGVBR,  16'hAAAA, WORD);
    host.wb_cmp(0, XGATE_XGVBR,    16'hAAAA, WORD);

    host.wb_write(0, XGATE_XGVBR,  16'hFF55, L_BYTE);
    host.wb_cmp(0, XGATE_XGVBR,    16'hAA54, WORD);

    host.wb_write(0, XGATE_XGVBR,  16'h55AA, H_BYTE);
    host.wb_cmp(0, XGATE_XGVBR,    16'h5554, WORD);

    data_xgmctl = XGMCTL_XGEM | XGMCTL_XGE;
    host.wb_write(0, XGATE_XGMCTL,   data_xgmctl, WORD);   //
    data_xgmctl = XGMCTL_XGE;
    host.wb_cmp(  0, XGATE_XGMCTL, data_xgmctl, WORD);
    host.wb_write(0, XGATE_XGVBR,  16'hFFFF, WORD);
    host.wb_cmp(0, XGATE_XGVBR,    16'h5554, WORD);

    data_xgmctl = XGMCTL_XGEM;
    host.wb_write(0, XGATE_XGMCTL,   data_xgmctl, WORD);   //

    // Test the Xgate Software Trigger Register (XGSWT)
    host.wb_write(0, XGATE_XGSWT,  16'hFFFF, WORD);
    host.wb_cmp(0, XGATE_XGSWT,    16'h00FF, WORD);
    host.wb_write(0, XGATE_XGSWT,  16'hFF00, WORD);
    host.wb_cmp(0, XGATE_XGSWT,    16'h0000, WORD);

    host.wb_write(0, XGATE_XGSWT,  16'hFF55, L_BYTE);
    host.wb_cmp(0, XGATE_XGSWT,    16'h0000, WORD);
    host.wb_write(0, XGATE_XGSWT,  16'hFF55, H_BYTE);
    host.wb_cmp(0, XGATE_XGSWT,    16'h0000, WORD);

    // Test the Xgate Semaphore Register (XGSEM)
    host.wb_write(0, XGATE_XGSEM,  16'hFFFF, WORD);
    host.wb_cmp(0, XGATE_XGSEM,    16'h00FF, WORD);
    host.wb_write(0, XGATE_XGSEM,  16'hFF00, WORD);
    host.wb_cmp(0, XGATE_XGSEM,    16'h0000, WORD);

    host.wb_write(0, XGATE_XGSEM,  16'hFFFF, L_BYTE);
    host.wb_cmp(0, XGATE_XGSEM,    16'h0000, WORD);
    host.wb_write(0, XGATE_XGSEM,  16'hFFFF, H_BYTE);
    host.wb_cmp(0, XGATE_XGSEM,    16'h0000, WORD);

    // Test the Xgate Condition Code Register (XGCCR)
    host.wb_write(0, XGATE_XGCCR,  16'hFFFF, L_BYTE);
    host.wb_cmp(0, XGATE_XGCCR,    16'h000F, WORD);
    host.wb_write(0, XGATE_XGCCR,  16'hFFF0, WORD);
    host.wb_cmp(0, XGATE_XGCCR,    16'h0000, WORD);

    // Test the Xgate Program Counter Register (XGPC)
    host.wb_write(0, XGATE_XGPC,  16'hFF55, L_BYTE);
    host.wb_cmp(0, XGATE_XGPC,    16'h0055, WORD);
    host.wb_write(0, XGATE_XGPC,  16'hAAFF, H_BYTE);
    host.wb_cmp(0, XGATE_XGPC,    16'hAA55, WORD);
    host.wb_write(0, XGATE_XGPC,  16'h9966, WORD);
    host.wb_cmp(0, XGATE_XGPC,    16'h9966, WORD);

    // Test the Xgate Register #1 (XGR1)
    host.wb_write(0, XGATE_XGR1,  16'hFF33, L_BYTE);
    host.wb_cmp(0, XGATE_XGR1,    16'h0033, WORD);
    host.wb_write(0, XGATE_XGR1,  16'hccFF, H_BYTE);
    host.wb_cmp(0, XGATE_XGR1,    16'hcc33, WORD);
    host.wb_write(0, XGATE_XGR1,  16'hf11f, WORD);
    host.wb_cmp(0, XGATE_XGR1,    16'hf11f, WORD);

    // Test the Xgate Register #2 (XGR2)
    host.wb_write(0, XGATE_XGR2,  16'hFF11, L_BYTE);
    host.wb_cmp(0, XGATE_XGR2,    16'h0011, WORD);
    host.wb_write(0, XGATE_XGR2,  16'h22FF, H_BYTE);
    host.wb_cmp(0, XGATE_XGR2,    16'h2211, WORD);
    host.wb_write(0, XGATE_XGR2,  16'hddee, WORD);
    host.wb_cmp(0, XGATE_XGR2,    16'hddee, WORD);

    // Test the Xgate Register #3 (XGR3)
    host.wb_write(0, XGATE_XGR3,  16'hFF43, L_BYTE);
    host.wb_cmp(0, XGATE_XGR3,    16'h0043, WORD);
    host.wb_write(0, XGATE_XGR3,  16'h54FF, H_BYTE);
    host.wb_cmp(0, XGATE_XGR3,    16'h5443, WORD);
    host.wb_write(0, XGATE_XGR3,  16'habbc, WORD);
    host.wb_cmp(0, XGATE_XGR3,    16'habbc, WORD);

    // Test the Xgate Register #4 (XGR4)
    host.wb_write(0, XGATE_XGR4,  16'hFF54, L_BYTE);
    host.wb_cmp(0, XGATE_XGR4,    16'h0054, WORD);
    host.wb_write(0, XGATE_XGR4,  16'h65FF, H_BYTE);
    host.wb_cmp(0, XGATE_XGR4,    16'h6554, WORD);
    host.wb_write(0, XGATE_XGR4,  16'h9aab, WORD);
    host.wb_cmp(0, XGATE_XGR4,    16'h9aab, WORD);

    // Test the Xgate Register #5 (XGR5)
    host.wb_write(0, XGATE_XGR5,  16'hFF65, L_BYTE);
    host.wb_cmp(0, XGATE_XGR5,    16'h0065, WORD);
    host.wb_write(0, XGATE_XGR5,  16'h76FF, H_BYTE);
    host.wb_cmp(0, XGATE_XGR5,    16'h7665, WORD);
    host.wb_write(0, XGATE_XGR5,  16'h899a, WORD);
    host.wb_cmp(0, XGATE_XGR5,    16'h899a, WORD);

    // Test the Xgate Register #6 (XGR6)
    host.wb_write(0, XGATE_XGR6,  16'hFF76, L_BYTE);
    host.wb_cmp(0, XGATE_XGR6,    16'h0076, WORD);
    host.wb_write(0, XGATE_XGR6,  16'h87FF, H_BYTE);
    host.wb_cmp(0, XGATE_XGR6,    16'h8776, WORD);
    host.wb_write(0, XGATE_XGR6,  16'h7889, WORD);
    host.wb_cmp(0, XGATE_XGR6,    16'h7889, WORD);

    // Test the Xgate Register #7 (XGR7)
    host.wb_write(0, XGATE_XGR7,  16'hFF87, L_BYTE);
    host.wb_cmp(0, XGATE_XGR7,    16'h0087, WORD);
    host.wb_write(0, XGATE_XGR7,  16'h98FF, H_BYTE);
    host.wb_cmp(0, XGATE_XGR7,    16'h9887, WORD);
    host.wb_write(0, XGATE_XGR7,  16'h6778, WORD);
    host.wb_cmp(0, XGATE_XGR7,    16'h6778, WORD);

    host.wb_cmp(0, XGATE_XGPC,    16'h9966, WORD);
    host.wb_cmp(0, XGATE_XGR1,    16'hf11f, WORD);
    host.wb_cmp(0, XGATE_XGR2,    16'hddee, WORD);
    host.wb_cmp(0, XGATE_XGR3,    16'habbc, WORD);
    host.wb_cmp(0, XGATE_XGR4,    16'h9aab, WORD);
    host.wb_cmp(0, XGATE_XGR5,    16'h899a, WORD);
    host.wb_cmp(0, XGATE_XGR6,    16'h7889, WORD);
    host.wb_cmp(0, XGATE_XGR7,    16'h6778, WORD);

  end
endtask

////////////////////////////////////////////////////////////////////////////////
// check irq register bits - reset, read/write
task reg_irq;
  integer i, j, k;
  reg [15:0] irq_clear;
  reg [TB_ADDR_WIDTH-1:0] irq_ack_addr; // Address to clear irq request
  begin
    test_num = test_num + 1;
    $display("\nTEST #%d Starts at vector=%d, reg_irq", test_num, vector);
    $readmemh("../../../bench/verilog/irq_test.v", p_ram.ram_8);

    system_reset;

    host.wb_cmp(0, IRQ_BYPS_0,   16'hFFFE, WORD); // verify reset
    host.wb_cmp(0, IRQ_BYPS_1,   16'hFFFF, WORD); // verify reset
    host.wb_cmp(0, IRQ_BYPS_2,   16'hFFFF, WORD); // verify reset
    host.wb_cmp(0, IRQ_BYPS_3,   16'hFFFF, WORD); // verify reset
    host.wb_cmp(0, IRQ_BYPS_4,   16'hFFFF, WORD); // verify reset
    host.wb_cmp(0, IRQ_BYPS_5,   16'hFFFF, WORD); // verify reset
    host.wb_cmp(0, IRQ_BYPS_6,   16'hFFFF, WORD); // verify reset
    host.wb_cmp(0, IRQ_BYPS_7,   16'hFFFF, WORD); // verify reset


    // Test the Xgate IRQ Bypass Registers (IRQ_BYPS)
    host.wb_write(0, IRQ_BYPS_0,  16'hAAAA, WORD);
    host.wb_cmp(0, IRQ_BYPS_0,    16'hAAAA, WORD);
    host.wb_write(0, IRQ_BYPS_0,  16'h5555, WORD);
    host.wb_cmp(0, IRQ_BYPS_0,    16'h5554, WORD);

    host.wb_write(0, IRQ_BYPS_0,  16'hFF66, L_BYTE);
    host.wb_cmp(0, IRQ_BYPS_0,    16'h5566, WORD);
    host.wb_write(0, IRQ_BYPS_0,  16'h33FF, H_BYTE);
    host.wb_cmp(0, IRQ_BYPS_0,    16'h3366, WORD);
    host.wb_write(0, IRQ_BYPS_0,  16'hFFFF, H_BYTE);

    channel_req[17] = 1'b1; //
    repeat(4) @(posedge mstr_test_clk);
    host.wb_cmp(0, CHANNEL_XGIRQ_1,    16'h0002, WORD);
    channel_req[17] = 1'b0; //
    repeat(4) @(posedge mstr_test_clk);
    host.wb_cmp(0, CHANNEL_XGIRQ_1,    16'h0000, WORD);

    host.wb_write(0, TB_SEMPHORE, 16'h0000, WORD);
    host.wb_write(0, IRQ_BYPS_0,  16'h0000, WORD);
    host.wb_write(0, IRQ_BYPS_1,  16'h0000, WORD);
    host.wb_write(0, IRQ_BYPS_2,  16'h0000, WORD);
    host.wb_write(0, IRQ_BYPS_3,  16'h0000, WORD);
    host.wb_write(0, IRQ_BYPS_4,  16'h0000, WORD);
    host.wb_write(0, IRQ_BYPS_5,  16'h0000, WORD);
    host.wb_write(0, IRQ_BYPS_6,  16'h0000, WORD);
    host.wb_write(0, IRQ_BYPS_7,  16'h0000, WORD);
    data_xgmctl = XGMCTL_XGEM | XGMCTL_XGE;
    host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Enable XGATE
    repeat(XGATE_ACCESS_DELAY+2) @(posedge mstr_test_clk);

    //channel_req[8:1] = 8'b1_1111_111; //  Activate the interrupt inputs
    channel_req = {MAX_CHANNEL{1'b1}}; //  Activate the interrupt inputs

    for (i = 1; i <= MAX_CHANNEL; i = i + 1)
    begin
      j = i % 16;
      k = i / 16;
      irq_ack_addr = XGATE_XGIF_0 - (2 * k);
      $display("Testing interrupt %d.", i);
      q = 0;
      // The Xgate test program is in an infinite loop looking for the test bench semaphore register to be changed
      while (q == 0)  // Look for change in test bench semapore register
        begin
          host.wb_read(1, TB_SEMPHORE, q, WORD);
        end

      if (q != i)
        begin
          error_count = error_count + 1;
          $display("IRQ test failure, Wrong interrupt being processed! Interrupt=%d, vector=%d", q, vector);
        end

      channel_req[i] = 1'b0; //  Clear the active interrupt input
      repeat(XGATE_ACCESS_DELAY+2) @(posedge mstr_test_clk);
      host.wb_write(0, TB_SEMPHORE,  16'h0000, WORD);
      repeat(XGATE_ACCESS_DELAY+2) @(posedge mstr_test_clk);

      irq_clear = 16'h0001 << j;
      // host.wb_cmp(0, CHANNEL_XGIRQ_0, irq_clear, WORD);  // Verify Xgate output interrupt flag set
      // host.wb_cmp(0, XGATE_XGIF_0,    irq_clear, WORD);  // Verify Xgate interrupt status bit set
      host.wb_write(1, irq_ack_addr, irq_clear, WORD);  // Clear Interrupt Flag from Xgate
      // host.wb_cmp(0, XGATE_XGIF_0,    16'h0000, WORD);  // Verify flag cleared
    end

  end
endtask  // reg_irq


////////////////////////////////////////////////////////////////////////////////
task sync_reset_test;  // reset system
  begin
    test_num = test_num + 1;
    $display("\nTEST #%d Starts at vector=%d, reg_irq", test_num, vector);

    // Write some registers so a change in state can be verified after reset
    host.wb_write(1, XGATE_XGVBR, 16'h01ff, WORD);  //
    host.wb_write(0, IRQ_BYPS_0,  16'h0000, WORD);

    repeat(1) @(posedge mstr_test_clk);
    sync_reset  <= 1'b1; // 
    repeat(1) @(posedge mstr_test_clk);
    sync_reset  <= 1'b0;

    host.wb_cmp(0, XGATE_XGVBR,    16'hfe00, WORD); // verify reset
    host.wb_cmp(0, IRQ_BYPS_0,     16'hFFFE, WORD); // verify reset

  end
endtask


////////////////////////////////////////////////////////////////////////////////
// End Main test program tasks
// Begin test program helper tasks and functions
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// check RAM Read/Write from host
task host_ram;
  begin
    test_num = test_num + 1;
    $display("\nTEST #%d Starts at vector=%d, host_ram", test_num, vector);

    host.wb_write(1, SYS_RAM_BASE, 16'h5555, WORD);
    host.wb_cmp(  0, SYS_RAM_BASE, 16'h5555, WORD);

    repeat(5) @(posedge mstr_test_clk);
    p_ram.dump_ram(0);

  end
endtask

////////////////////////////////////////////////////////////////////////////////
// Poll for XGATE Interrupt set
task wait_irq_set;
  input [ 6:0] chan_val;
  begin
    while(!xgif[chan_val])
      @(posedge mstr_test_clk); // poll it until it is set
    $display("XGATE Interrupt Request #%d set detected at vector =%d", chan_val, vector);
  end
endtask

////////////////////////////////////////////////////////////////////////////////
// Poll for XGATE SW Interrupt set
task wait_sw_irq_set;
  input [ 7:0] wait_timeout;
  reg [7:0]timeout_count;
  begin
    timeout_count = 0;
    while(!xg_sw_irq & (timeout_count <= wait_timeout))
      begin
        @(posedge mstr_test_clk); // poll it until it is set
        timeout_count = timeout_count + 1;
      end

    if (timeout_count >= wait_timeout)
      begin
        error_count = error_count + 1;
        $display("SW IRQ not detected in the alloted time, vector=%d", vector);
      end
    else
      $display("XGATE SW Interrupt Request set detected at vector =%d", vector);

  end
endtask

////////////////////////////////////////////////////////////////////////////////
// Clear XGATE SW Interrupt
task clear_sw_irq;
  begin
    host.wb_write(0, XGATE_XGMCTL, 16'h0202, WORD);   // Clear SW interrupt
    repeat(4) @(posedge mstr_test_clk);
    if (xg_sw_irq)
      begin
        error_count = error_count + 1;
        $display("SW IRQ not cleared after command write, vector=%d", vector);
      end

  end
endtask

////////////////////////////////////////////////////////////////////////////////
// Poll for debug bit set
task wait_debug_set;
  begin
    host.wb_read(1, XGATE_XGMCTL, q, WORD);
    while(~|(q & XGMCTL_XGDBG))
      host.wb_read(1, XGATE_XGMCTL, q, WORD); // poll it until it is set
    $display("DEBUG Flag set detected at vector =%d", vector);
  end
endtask


////////////////////////////////////////////////////////////////////////////////
task system_reset;  // reset system
  begin
    repeat(1) @(posedge mstr_test_clk);
    #2;     // move the async reset away from the clock edge
    rstn = 1'b0;    // assert async reset
    #5;     // Keep the async reset pulse with less than a clock cycle
    rstn = 1'b1;    // negate async reset
    repeat(1) @(posedge mstr_test_clk);

    $display("\nstatus: %t System Reset Task Done", $time);
    test_num = test_num + 1;
    channel_req = 0;  // Clear all the testbench inpterrupt inputs to the xgate

    repeat(2) @(posedge mstr_test_clk);
  end
endtask


////////////////////////////////////////////////////////////////////////////////
task activate_channel;
  input [ 6:0] chan_val;
  begin
    $display("Activating Channel %d", chan_val);

    channel_req[chan_val] = 1'b1; //
    repeat(1) @(posedge mstr_test_clk);
  end
endtask


////////////////////////////////////////////////////////////////////////////////
task clear_channel;
  input [ 6:0] chan_val;
  begin
    $display("Clearing Channel interrupt input #%d", chan_val);

    channel_req[chan_val] = 1'b0; //
    repeat(1) @(posedge mstr_test_clk);
  end
endtask


////////////////////////////////////////////////////////////////////////////////
task activate_thread_sw;
  input [ 6:0] chan_val;
  begin
      $display("Activating Software Thread - Channel #%d", chan_val);

      data_xgmctl = XGMCTL_XGEM | XGMCTL_XGE;
      host.wb_write(0, XGATE_XGMCTL, data_xgmctl, WORD);   // Enable XGATE

      channel_req[chan_val] = 1'b1; //
      repeat(1) @(posedge mstr_test_clk);
   end
endtask

////////////////////////////////////////////////////////////////////////////////
task read_ram_cmp;
  input [15:0] address;
  input [15:0] value;
  reg [15:0] q;
  begin

      // BIGENDIAN
      q = {p_ram.ram_8[address], p_ram.ram_8[address+1]};
      // "X" compares don't work, "X" in value or q always match
      if (value != q)
        begin
          error_count = error_count + 1;
          $display("RAM Data compare error at address %h. Received %h, expected %h at time %t", address, q, value, $time);
        end
   end
endtask

////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
function [15:0] four_2_16;
  input [3:0] vector;
  begin
    case (vector)
      4'h0 : four_2_16 = 16'b0000_0000_0000_0001;
      4'h1 : four_2_16 = 16'b0000_0000_0000_0010;
      4'h2 : four_2_16 = 16'b0000_0000_0000_0100;
      4'h3 : four_2_16 = 16'b0000_0000_0000_1000;
      4'h4 : four_2_16 = 16'b0000_0000_0001_0000;
      4'h5 : four_2_16 = 16'b0000_0000_0010_0000;
      4'h6 : four_2_16 = 16'b0000_0000_0100_0000;
      4'h7 : four_2_16 = 16'b0000_0000_1000_0000;
      4'h8 : four_2_16 = 16'b0000_0001_0000_0000;
      4'h9 : four_2_16 = 16'b0000_0010_0000_0000;
      4'ha : four_2_16 = 16'b0000_0100_0000_0000;
      4'hb : four_2_16 = 16'b0000_1000_0000_0000;
      4'hc : four_2_16 = 16'b0001_0000_0000_0000;
      4'hd : four_2_16 = 16'b0010_0000_0000_0000;
      4'he : four_2_16 = 16'b0100_0000_0000_0000;
      4'hf : four_2_16 = 16'b1000_0000_0000_0000;
    endcase
  end
endfunction


endmodule  // tst_bench_top

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
module bus_arbitration  #(parameter dwidth = 16,
        parameter awidth    = 24,
        parameter ram_base  = 0,
        parameter ram_size  = 16'hffff,
        parameter slv1_base = 0,
        parameter slv1_size = 1,
        parameter slv2_base = 0,
        parameter slv2_size = 1,
                          parameter ram_wait_states = 0) // Number between 0 and 15
  (
  // System bus I/O
  output reg                 sys_cyc,
  output reg                 sys_stb,
  output reg                 sys_we,
  output reg [dwidth/8 -1:0] sys_sel,
  output reg [awidth   -1:0] sys_adr,
  output reg [dwidth   -1:0] sys_dout,
  output     [dwidth   -1:0] sys_din,

  // Host bus I/O
  output         host_ack,
  output     [dwidth   -1:0] host_dout,
  input          host_cyc,
  input          host_stb,
  input          host_we,
  input      [dwidth/8 -1:0] host_sel,
  input      [awidth   -1:0] host_adr,
  input      [dwidth   -1:0] host_din,

  // Alternate Bus Master #1 Bus I/O
  output         alt1_ack,
  output     [dwidth   -1:0] alt1_dout,
  input          alt1_cyc,
  input          alt1_stb,
  input          alt1_we,
  input      [dwidth/8 -1:0] alt1_sel,
  input      [awidth   -1:0] alt1_adr,
  input      [dwidth   -1:0] alt1_din,

  // System RAM memory signals
  output         ram_sel,
  input      [dwidth   -1:0] ram_dout,

  // Slave #1 Bus I/O
  output         slv1_stb,
  input          slv1_ack,
  input      [dwidth   -1:0] slv1_din,

  // Slave #2 Bus I/O
  output         slv2_stb,
  input          slv2_ack,
  input      [dwidth   -1:0] slv2_din,

  // Miscellaneous
  input          host_clk,
  input          risc_clk,
  input          rst,       // No Connect
  input          err,       // No Connect
  input          rty        // No Connect
  );

  // States for bus arbitration
  parameter [1:0] BUS_IDLE  = 2'b00,
                  HOST_OWNS = 2'b10,
                  RISC_OWNS = 2'b11;

  parameter max_bus_hold = 5;  // Max number of cycles any bus master can hold the system bus
  //////////////////////////////////////////////////////////////////////////////
  //
  // Local Wires and Registers
  //
  wire       ram_ack;        //
  wire       any_ack;        //
  reg        host_wait;      // Host bus in wait state, Hold the bus till the transaction complets
  reg  [3:0] host_cycle_cnt; // Used to count the cycle the host and break the lock if the risc needs access

  wire       risc_lock;      // RISC has the slave bus
  reg        risc_wait;      // RISC bus in wait state, Hold the bus till the transaction complets
  reg  [3:0] risc_cycle_cnt; // Used to count the cycle the risc and break the lock if the host needs access

  reg  [1:0] owner_state;
  reg  [1:0] owner_ns;

  wire       host_timeout;
  wire       risc_timeout;

  wire       ram_ack_dly;    // Delayed bus ack to simulate bus wait states
  reg  [3:0] ack_dly_cnt;    // Counter to delay bus ack to master modules


  //
  always @(posedge host_clk or negedge rst)
    if (!rst)
      owner_state <= BUS_IDLE;
    else
      owner_state <= owner_ns;

  //
  always @*
    case (owner_state)
      BUS_IDLE :
        begin
          if (host_cyc)
            owner_ns = HOST_OWNS;
          else if (alt1_cyc)
            owner_ns = RISC_OWNS;
        end
      HOST_OWNS :
        begin
          if (!host_cyc && !alt1_cyc)
            owner_ns = BUS_IDLE;
          else if (alt1_cyc && (!host_cyc || host_timeout))
            owner_ns = RISC_OWNS;
        end
      RISC_OWNS :
        begin
          if (!host_cyc && !alt1_cyc)
            owner_ns = BUS_IDLE;
          else if (host_cyc && (!alt1_cyc || risc_timeout))
            owner_ns = HOST_OWNS;
        end
      default : owner_ns = BUS_IDLE;
    endcase


  assign host_timeout = (owner_state == HOST_OWNS) && (host_cycle_cnt > max_bus_hold) && any_ack;
  assign risc_timeout = (owner_state == RISC_OWNS) && (risc_cycle_cnt > max_bus_hold) && any_ack;

  // Start counting cycles that the host has the bus, if the risc is also requesting the bus
  always @(posedge host_clk or negedge rst)
    if (!rst)
      host_cycle_cnt <= 0;
    else if ((owner_state != HOST_OWNS) || !alt1_cyc)
      host_cycle_cnt <= 0;
    else if (&host_cycle_cnt && !host_timeout)  // Don't allow rollover
      host_cycle_cnt <= host_cycle_cnt;
    else if ((owner_state == HOST_OWNS) && alt1_cyc)
      host_cycle_cnt <= host_cycle_cnt + 1'b1;

  // Start counting cycles that the risc has the bus, if the host is also requesting the bus
  always @(posedge host_clk or negedge rst)
    if (!rst)
      risc_cycle_cnt <= 0;
    else if ((owner_state != RISC_OWNS) || !host_cyc)
      risc_cycle_cnt <= 0;
    else if (&risc_cycle_cnt && !risc_timeout)  // Don't allow rollover
      risc_cycle_cnt <= risc_cycle_cnt;
    else if ((owner_state == RISC_OWNS) && host_cyc)
      risc_cycle_cnt <= risc_cycle_cnt + 1'b1;

  // Aribartration Logic for System Bus access
  assign any_ack  = slv1_ack || slv2_ack || ram_ack;
  assign host_ack = (owner_state == HOST_OWNS) && any_ack && host_cyc;
  assign alt1_ack = (owner_state == RISC_OWNS) && any_ack && alt1_cyc;


  // Address decoding for different Slave module instances
  assign slv1_stb = sys_stb && (sys_adr >= slv1_base) && (sys_adr < (slv1_base + slv1_size));
  assign slv2_stb = sys_stb && (sys_adr >= slv2_base) && (sys_adr < (slv2_base + slv2_size));

  // Address decoding for Testbench access to RAM
  assign ram_sel = sys_cyc && sys_stb && !(slv1_stb || slv2_stb) &&
                   (sys_adr >= ram_base) &&
                   (sys_adr < (ram_base + ram_size));

  // Throw in some wait states from the memory
  always @(posedge host_clk)
    if ((ack_dly_cnt == ram_wait_states) || !ram_sel)
      ack_dly_cnt <= 0;
    else if (ram_sel)
      ack_dly_cnt <= ack_dly_cnt + 1'b1;

  assign ram_ack_dly = (ack_dly_cnt == ram_wait_states);
  assign ram_ack = ram_sel && ram_ack_dly;


  // Create the System Read Data Bus from the Slave output data buses
  assign sys_din = ({dwidth{1'b1}} & slv1_din) |
       ({dwidth{slv2_stb}} & slv2_din) |
       ({dwidth{ram_sel}}  & ram_dout);

  // Mux for System Bus access
  always @*
    case (owner_state)
      BUS_IDLE :
        begin
          sys_cyc   = 0;
          sys_stb   = 0;
          sys_we    = 0;
          sys_sel   = 0;
          sys_adr   = 0;
          sys_dout  = 0;
        end
      HOST_OWNS :
        begin
          sys_cyc   = host_cyc;
          sys_stb   = host_stb;
          sys_we    = host_we;
          sys_sel   = host_sel;
          sys_adr   = host_adr;
          sys_dout  = host_din;
        end
      RISC_OWNS :
        begin
          sys_cyc   = alt1_cyc;
          sys_stb   = alt1_stb;
          sys_we    = alt1_we;
          sys_sel   = alt1_sel;
          sys_adr   = alt1_adr;
          sys_dout  = alt1_din;
        end
      default :
        begin
          sys_cyc   = 0;
          sys_stb   = 0;
          sys_we    = 0;
          sys_sel   = 0;
          sys_adr   = 0;
          sys_dout  = 0;
        end
    endcase

endmodule   // bus_arbitration

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
module tb_slave #(parameter SINGLE_CYCLE = 1'b0,  // No bus wait state added
                  parameter MAX_CHANNEL  = 127,   // Max XGATE Interrupt Channel Number
                  parameter DWIDTH       = 16)    // Data bus width
  (
  // Wishbone Signals
  output [DWIDTH-1:0] wb_dat_o,     // databus output
  output              wb_ack_o,     // bus cycle acknowledge output
  input               wb_clk_i,     // master clock input
  input               wb_rst_i,     // synchronous active high reset
  input               arst_i,       // asynchronous reset
  input        [ 3:0] wb_adr_i,     // lower address bits
  input  [DWIDTH-1:0] wb_dat_i,     // databus input
  input               wb_we_i,      // write enable input
  input               wb_stb_i,     // stobe/core select signal
  input               wb_cyc_i,     // valid bus cycle input
  input        [ 1:0] wb_sel_i,     // Select byte in word bus transaction
  // Slave unique IO Signals
  output reg              error_pulse,  // Error detected output pulse
  output reg              ack_pulse,    // Thread ack output pulse
  output reg [DWIDTH-1:0] brkpt_cntl,   // Break Point Control reg

  output                brk_pt,       // Break point
  input          [15:0] x_address,    // XGATE WISHBONE Master bus address
  input [MAX_CHANNEL:1] xgif,         // XGATE Interrupt Flag to Host
  input          [19:0] vector
  );

  wire      async_rst_b;   // Asyncronous reset
  wire      sync_reset;    // Syncronous reset

  // Wishbone Bus interface
  // registers
  reg               bus_wait_state;  // Holdoff wb_ack_o for one clock to add wait state
  reg  [DWIDTH-1:0] rd_data_mux;     // Pseudo Register, WISHBONE Read Data Mux
  reg  [DWIDTH-1:0] rd_data_reg;     // Latch for WISHBONE Read Data

  reg  [DWIDTH-1:0] check_point_reg;
  reg  [DWIDTH-1:0] channel_ack_reg;
  reg  [DWIDTH-1:0] channel_err_reg;

  reg  [DWIDTH-1:0] brkpt_addr_reg;  // Break Point Address reg

  reg  [DWIDTH-1:0] tb_semaphr_reg;  // Test bench semaphore reg

  event check_point_wrt;
  event channel_ack_wrt;
  event channel_err_wrt;

  // Wires
  wire   module_sel;    // This module is selected for bus transaction
  wire   wb_wacc;       // WISHBONE Write Strobe
  wire   wb_racc;       // WISHBONE Read Access (Clock gating signal)

  //
  // module body
  //

  // generate internal resets


  // generate wishbone signals
  assign module_sel = wb_cyc_i && wb_stb_i;
  assign wb_wacc    = module_sel && wb_we_i && (wb_ack_o || SINGLE_CYCLE);
  assign wb_racc    = module_sel && !wb_we_i;
  assign wb_ack_o   = SINGLE_CYCLE ? module_sel : bus_wait_state;
  assign wb_dat_o   = SINGLE_CYCLE ? rd_data_mux : rd_data_reg;

  // generate acknowledge output signal, By using register all accesses takes two cycles.
  //  Accesses in back to back clock cycles are not possable.
  always @(posedge wb_clk_i or negedge arst_i)
    if (!arst_i)
      bus_wait_state <=  1'b0;
    else if (wb_rst_i)
      bus_wait_state <=  1'b0;
    else
      bus_wait_state <=  module_sel && !bus_wait_state;

  // assign data read bus -- DAT_O
  always @(posedge wb_clk_i)
    if ( wb_racc )           // Clock gate for power saving
      rd_data_reg <= rd_data_mux;

  // WISHBONE Read Data Mux
  always @*
    case (wb_adr_i) // synopsys parallel_case
      4'b0000: rd_data_mux = check_point_reg;
      4'b0001: rd_data_mux = channel_ack_reg;
      4'b0010: rd_data_mux = channel_err_reg;
      4'b0011: rd_data_mux = brkpt_cntl;
      4'b0100: rd_data_mux = brkpt_addr_reg;
      4'b0101: rd_data_mux = tb_semaphr_reg;
      4'b1000: rd_data_mux = {xgif[15: 1], 1'b0};
      4'b1001: rd_data_mux = xgif[31:16];
      4'b1010: rd_data_mux = xgif[47:32];
      4'b1011: rd_data_mux = xgif[63:48];
      4'b1100: rd_data_mux = xgif[79:64];
      4'b1101: rd_data_mux = xgif[95:80];
      4'b1110: rd_data_mux = xgif[111:96];
      4'b1111: rd_data_mux = xgif[127:112];
      default: rd_data_mux = {DWIDTH{1'b0}};
    endcase

  // generate wishbone write register strobes
  always @(posedge wb_clk_i or negedge arst_i)
    begin
      if (!arst_i)
        begin
          check_point_reg <= 0;
          channel_ack_reg <= 0;
          channel_err_reg <= 0;
          ack_pulse       <= 0;
          error_pulse     <= 0;
          brkpt_cntl      <= 0;
          brkpt_addr_reg  <= 0;
          tb_semaphr_reg  <= 0;
        end
      else if (wb_wacc)
  case (wb_adr_i) // synopsys parallel_case
     3'b000 :
       begin
         check_point_reg[ 7:0] <= wb_sel_i[0] ? wb_dat_i[ 7:0] : check_point_reg[ 7:0];
         check_point_reg[15:8] <= wb_sel_i[1] ? wb_dat_i[15:8] : check_point_reg[15:8];
         -> check_point_wrt;
       end
     3'b001 :
       begin
         channel_ack_reg[ 7:0] <= wb_sel_i[0] ? wb_dat_i[ 7:0] : channel_ack_reg[ 7:0];
         channel_ack_reg[15:8] <= wb_sel_i[1] ? wb_dat_i[15:8] : channel_ack_reg[15:8];
         ack_pulse <= 1;
         -> channel_ack_wrt;
       end
     3'b010 :
       begin
         channel_err_reg[ 7:0] <= wb_sel_i[0] ? wb_dat_i[ 7:0] : channel_err_reg[ 7:0];
         channel_err_reg[15:8] <= wb_sel_i[1] ? wb_dat_i[15:8] : channel_err_reg[15:8];
         error_pulse <= 1'b1;
         -> channel_err_wrt;
       end
     3'b011 :
       begin
         brkpt_cntl[ 7:0] <= wb_sel_i[0] ? wb_dat_i[ 7:0] : brkpt_cntl[ 7:0];
         brkpt_cntl[15:8] <= wb_sel_i[1] ? wb_dat_i[15:8] : brkpt_cntl[15:8];
       end
     3'b100 :
       begin
         brkpt_addr_reg[ 7:0] <= wb_sel_i[0] ? wb_dat_i[ 7:0] : brkpt_addr_reg[ 7:0];
         brkpt_addr_reg[15:8] <= wb_sel_i[1] ? wb_dat_i[15:8] : brkpt_addr_reg[15:8];
       end
     3'b101 :
       begin
         tb_semaphr_reg[ 7:0] <= wb_sel_i[0] ? wb_dat_i[ 7:0] : tb_semaphr_reg[ 7:0];
         tb_semaphr_reg[15:8] <= wb_sel_i[1] ? wb_dat_i[15:8] : tb_semaphr_reg[15:8];
       end
     default: ;
  endcase
      else
  begin
    ack_pulse   <= 0;
    error_pulse <= 1'b0;
  end
    end

  always @check_point_wrt
    begin
      #1;
      $display("\nSoftware Checkpoint #%h -- at vector=%d\n", check_point_reg, vector);
    end

  always @channel_err_wrt
    begin
      #1;
      $display("\n ------ !!!!! Software Checkpoint Error #%d -- at vector=%d\n  -------", channel_err_reg, vector);
    end


endmodule // tb_slave

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
module tb_debug #(parameter DWIDTH = 16,    // Data bus width
                  parameter BREAK_CAPT_0 = 0,
                  parameter BREAK_CAPT_1 = 0,
                  parameter BREAK_CAPT_2 = 0,
                  parameter BREAK_CAPT_3 = 0,
                  parameter BREAK_CAPT_4 = 0,
                  parameter BREAK_CAPT_5 = 0,
                  parameter BREAK_CAPT_6 = 0,
                  parameter BREAK_CAPT_7 = 0
      )
  (
  // Wishbone Signals
  input               arst_i,     // asynchronous reset
  input               risc_clk,
  input  [DWIDTH-1:0] brkpt_cntl  // databus input
  );

  wire [15:0] next_pc = xgate.risc.program_counter;
  wire [15:0] x1 = xgate.risc.xgr1;
  wire [15:0] x2 = xgate.risc.xgr2;
  wire [15:0] x3 = xgate.risc.xgr3;
  wire [15:0] x4 = xgate.risc.xgr4;
  wire [15:0] x5 = xgate.risc.xgr5;
  wire [15:0] x6 = xgate.risc.xgr6;
  wire [15:0] x7 = xgate.risc.xgr7;

  reg [15:0] cap_x1;
  reg [15:0] cap_x2;
  reg [15:0] cap_x3;
  reg [15:0] cap_x4;
  reg [15:0] cap_x5;
  reg [15:0] cap_x6;
  reg [15:0] cap_x7;

  reg [15:0] break_addr_0;
  reg [15:0] break_addr_1;
  reg [15:0] break_addr_2;
  reg [15:0] break_addr_3;
  reg [15:0] break_addr_4;
  reg [15:0] break_addr_5;
  reg [15:0] break_addr_6;
  reg [15:0] break_addr_7;

  reg detect_addr;

  wire trigger, trigger0, trigger1, trigger3, trigger4, trigger5, trigger6, trigger7;

  initial
    begin
      break_addr_0 = 0;
      break_addr_1 = 0;
      break_addr_2 = 0;
      break_addr_3 = 0;
      break_addr_4 = 0;
      break_addr_5 = 0;
      break_addr_6 = 0;
      break_addr_7 = 0;
      repeat(4) @(posedge risc_clk);
      break_addr_0 = {p_ram.ram_8[BREAK_CAPT_0], p_ram.ram_8[BREAK_CAPT_0+1]};
      break_addr_1 = {p_ram.ram_8[BREAK_CAPT_1], p_ram.ram_8[BREAK_CAPT_1+1]};
      break_addr_2 = {p_ram.ram_8[BREAK_CAPT_2], p_ram.ram_8[BREAK_CAPT_2+1]};
      break_addr_3 = {p_ram.ram_8[BREAK_CAPT_3], p_ram.ram_8[BREAK_CAPT_3+1]};
      break_addr_4 = {p_ram.ram_8[BREAK_CAPT_4], p_ram.ram_8[BREAK_CAPT_4+1]};
      break_addr_5 = {p_ram.ram_8[BREAK_CAPT_5], p_ram.ram_8[BREAK_CAPT_5+1]};
      break_addr_6 = {p_ram.ram_8[BREAK_CAPT_6], p_ram.ram_8[BREAK_CAPT_6+1]};
      break_addr_7 = {p_ram.ram_8[BREAK_CAPT_7], p_ram.ram_8[BREAK_CAPT_7+1]};
    end

  assign trigger0 = (next_pc === break_addr_0) && brkpt_cntl[ 8];
  assign trigger1 = (next_pc === break_addr_1) && brkpt_cntl[ 9];
  assign trigger2 = (next_pc === break_addr_2) && brkpt_cntl[10];
  assign trigger3 = (next_pc === break_addr_3) && brkpt_cntl[11];
  assign trigger4 = (next_pc === break_addr_4) && brkpt_cntl[12];
  assign trigger5 = (next_pc === break_addr_5) && brkpt_cntl[13];
  assign trigger6 = (next_pc === break_addr_6) && brkpt_cntl[14];
  assign trigger7 = (next_pc === break_addr_7) && brkpt_cntl[15];

  assign trigger = brkpt_cntl[0] &
                   (trigger0 | trigger1 | trigger2 | trigger3 | trigger4 | trigger5 | trigger6 | trigger7);

  always @(posedge risc_clk or negedge arst_i)
    begin
      if (!arst_i)
        begin
          cap_x1 <= 0;
          cap_x2 <= 0;
          cap_x3 <= 0;
          cap_x4 <= 0;
          cap_x5 <= 0;
          cap_x6 <= 0;
          cap_x7 <= 0;
        end
      else if (trigger)
        begin
          cap_x1 <= x1;
          cap_x2 <= x2;
          cap_x3 <= x3;
          cap_x4 <= x4;
          cap_x5 <= x5;
          cap_x6 <= x6;
          cap_x7 <= x7;
        end
    end


endmodule // tb_debug

