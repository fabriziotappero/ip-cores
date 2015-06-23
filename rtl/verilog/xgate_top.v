////////////////////////////////////////////////////////////////////////////////
//
//  XGATE Coprocessor - XGATE Top Level Module
//
//  Author: Robert Hayes
//          rehayes@opencores.org
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
//       notice, this list of conditions and the following disclaimer.
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
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////////////
// 45678901234567890123456789012345678901234567890123456789012345678901234567890

module xgate_top #(parameter ARST_LVL = 1'b0,      // asynchronous reset level
                   parameter DWIDTH   = 16,        // define the wishbone bus data size
                   parameter SINGLE_CYCLE = 1'b0,  //
                   parameter MAX_CHANNEL  = 127,   // Max XGATE Interrupt Channel Number
                   parameter WB_RD_DEFAULT = 0)    // WISHBONE Read Bus default state
  (
  // Wishbone Slave Signals
  output    [DWIDTH-1:0] wbs_dat_o,     // databus output
  output                 wbs_ack_o,     // bus cycle acknowledge output
  output                 wbs_err_o,     // bus error, lost module select durning wait state
  input                  wbs_clk_i,     // master clock input
  input                  wbs_rst_i,     // synchronous active high reset
  input                  arst_i,        // asynchronous reset
  input            [6:1] wbs_adr_i,     // lower address bits
  input     [DWIDTH-1:0] wbs_dat_i,     // databus input
  input                  wbs_we_i,      // write enable input
  input                  wbs_stb_i,     // stobe/core select signal
  input                  wbs_cyc_i,     // valid bus cycle input
  input            [1:0] wbs_sel_i,     // Select byte in word bus transaction
  // Wishbone Master Signals
  output    [DWIDTH-1:0] wbm_dat_o,     // databus output
  output                 wbm_we_o,      // write enable output
  output                 wbm_stb_o,     // stobe/core select signal
  output                 wbm_cyc_o,     // valid bus cycle output
  output          [ 1:0] wbm_sel_o,     // Select byte in word bus transaction
  output          [15:0] wbm_adr_o,     // Address bits
  input     [DWIDTH-1:0] wbm_dat_i,     // databus input
  input                  wbm_ack_i,     // bus cycle acknowledge input
  // XGATE IO Signals
  output          [ 7:0] xgswt,            // XGATE Software Trigger Register
  output                 xg_sw_irq,        // Xgate Software interrupt
  output [MAX_CHANNEL:1] xgif,             // XGATE Interrupt Flag to Host
  input  [MAX_CHANNEL:1] chan_req_i,       // XGATE Interrupt request
  input                  risc_clk,         // Clock for RISC core
  input                  debug_mode_i,     // Force RISC core into debug mode
  input                  secure_mode_i,    // Limit host asscess to Xgate RISC registers
  input                  scantestmode      // Chip in in scan test mode
  );


  wire        zero_flag;
  wire        negative_flag;
  wire        carry_flag;
  wire        overflow_flag;
  wire [15:0] xgr1;          // XGATE Register #1
  wire [15:0] xgr2;          // XGATE Register #2
  wire [15:0] xgr3;          // XGATE Register #3
  wire [15:0] xgr4;          // XGATE Register #4
  wire [15:0] xgr5;          // XGATE Register #5
  wire [15:0] xgr6;          // XGATE Register #6
  wire [15:0] xgr7;          // XGATE Register #7

  wire        write_xgmctl;  // Write Strobe for XGMCTL register
  wire        write_xgchid;  // Write Strobe for XGCHID register
  wire  [1:0] write_xgvbr;   // Write Strobe for XGVBR register
  wire  [1:0] write_xgif_7;  // Write Strobe for Interrupt Flag Register 7
  wire  [1:0] write_xgif_6;  // Write Strobe for Interrupt Flag Register 6
  wire  [1:0] write_xgif_5;  // Write Strobe for Interrupt Flag Register 5
  wire  [1:0] write_xgif_4;  // Write Strobe for Interrupt Flag Register 4
  wire  [1:0] write_xgif_3;  // Write Strobe for Interrupt Flag Register 3
  wire  [1:0] write_xgif_2;  // Write Strobe for Interrupt Flag Register 2
  wire  [1:0] write_xgif_1;  // Write Strobe for Interrupt Flag Register 1
  wire  [1:0] write_xgif_0;  // Write Strobe for Interrupt Flag Register 0
  wire  [1:0] write_irw_en_7; // Write Strobe for Interrupt Bypass Control Register 7
  wire  [1:0] write_irw_en_6; // Write Strobe for Interrupt Bypass Control Register 6
  wire  [1:0] write_irw_en_5; // Write Strobe for Interrupt Bypass Control Register 5
  wire  [1:0] write_irw_en_4; // Write Strobe for Interrupt Bypass Control Register 4
  wire  [1:0] write_irw_en_3; // Write Strobe for Interrupt Bypass Control Register 3
  wire  [1:0] write_irw_en_2; // Write Strobe for Interrupt Bypass Control Register 2
  wire  [1:0] write_irw_en_1; // Write Strobe for Interrupt Bypass Control Register 1
  wire  [1:0] write_irw_en_0; // Write Strobe for Interrupt Bypass Control Register 0
  wire        write_xgswt;   // Write Strobe for XGSWT register
  wire        write_xgsem;   // Write Strobe for XGSEM register
  wire        write_xgccr;   // Write Strobe for XGATE Condition Code Register
  wire  [1:0] write_xgpc;    // Write Strobe for XGATE Program Counter
  wire  [1:0] write_xgr7;    // Write Strobe for XGATE Data Register R7
  wire  [1:0] write_xgr6;    // Write Strobe for XGATE Data Register R6
  wire  [1:0] write_xgr5;    // Write Strobe for XGATE Data Register R5
  wire  [1:0] write_xgr4;    // Write Strobe for XGATE Data Register R4
  wire  [1:0] write_xgr3;    // Write Strobe for XGATE Data Register R3
  wire  [1:0] write_xgr2;    // Write Strobe for XGATE Data Register R2
  wire  [1:0] write_xgr1;    // Write Strobe for XGATE Data Register R1

  wire        clear_xgif_7;    // Strobe for decode to clear interrupt flag bank 7
  wire        clear_xgif_6;    // Strobe for decode to clear interrupt flag bank 6
  wire        clear_xgif_5;    // Strobe for decode to clear interrupt flag bank 5
  wire        clear_xgif_4;    // Strobe for decode to clear interrupt flag bank 4
  wire        clear_xgif_3;    // Strobe for decode to clear interrupt flag bank 3
  wire        clear_xgif_2;    // Strobe for decode to clear interrupt flag bank 2
  wire        clear_xgif_1;    // Strobe for decode to clear interrupt flag bank 1
  wire        clear_xgif_0;    // Strobe for decode to clear interrupt flag bank 0
  wire [15:0] clear_xgif_data; // Data for decode to clear interrupt flag
  wire [MAX_CHANNEL:1] chan_bypass; // XGATE Interrupt enable or bypass

  wire        xge;           // XGATE Module Enable
  wire        xgfrz;         // Stop XGATE in Freeze Mode
  wire        xgdbg_set;     // Enter XGATE Debug Mode
  wire        xgdbg_clear;   // Leave XGATE Debug Mode
  wire        xgfact;        // Fake Activity
  wire        xgss;          // XGATE Single Step
  wire        xgsweif_c;     // Clear XGATE Software Error Interrupt FLag
  wire        xgie;          // XGATE Interrupt Enable
  wire [ 6:0] int_req;       // Encoded interrupt request
  wire [ 6:0] xgchid;        // Channel actively being processed
  wire [127:1] xgif_status;  // Status bits of interrupt output flags that have been set
  wire [127:1] irq_bypass;   // IRQ status bits WISHBONE Read bus

  wire [15:1] xgvbr;         // XGATE vector Base Address Register
  wire        brk_irq_ena;   // Enable BRK instruction to generate interrupt

  wire [15:0] xgate_address;   //
  wire [15:0] write_mem_data;  //
  wire [15:0] read_mem_data;   //
  wire        mem_access;      //
  wire        mem_req_ack;     //

  wire        debug_active;    // RISC state machine in Debug mode
  wire        debug_ack;       // Clear debug register
  wire        single_step;     // Pulse to trigger a single instruction execution in debug mode
  wire        ss_mem_ack;      // WISHBONE Bus has granted single step memory access

  wire [ 7:0] host_semap;       // Semaphore status for host
  wire        write_mem_strb_l; // Strobe for writing low data byte
  wire        write_mem_strb_h; // Strobe for writing high data bye
  wire        sync_reset;
  wire        async_rst_b;

  // ---------------------------------------------------------------------------
  // Wishbone Slave Bus interface
  xgate_wbs_bus #(.ARST_LVL(ARST_LVL),
                  .SINGLE_CYCLE(SINGLE_CYCLE),
                  .WB_RD_DEFAULT(WB_RD_DEFAULT))
    wishbone_s(
    .wbs_dat_o( wbs_dat_o ),
    .wbs_ack_o( wbs_ack_o ),
    .wbs_err_o( wbs_err_o ),
    .wbs_clk_i( wbs_clk_i ),
    .wbs_rst_i( wbs_rst_i ),
    .arst_i( arst_i ),
    .wbs_adr_i( wbs_adr_i ),
    .wbs_we_i( wbs_we_i ),
    .wbs_stb_i( wbs_stb_i ),
    .wbs_cyc_i( wbs_cyc_i ),
    .wbs_sel_i( wbs_sel_i ),

    // outputs
    .sync_reset( sync_reset ),
    .write_xgmctl( write_xgmctl ),
    .write_xgchid( write_xgchid ),
    .write_xgvbr( write_xgvbr ),
    .write_xgif_7( write_xgif_7 ),
    .write_xgif_6( write_xgif_6 ),
    .write_xgif_5( write_xgif_5 ),
    .write_xgif_4( write_xgif_4 ),
    .write_xgif_3( write_xgif_3 ),
    .write_xgif_2( write_xgif_2 ),
    .write_xgif_1( write_xgif_1 ),
    .write_xgif_0( write_xgif_0 ),
    .write_xgswt( write_xgswt ),
    .write_xgsem( write_xgsem ),
    .write_xgccr( write_xgccr ),
    .write_xgpc( write_xgpc ),
    .write_xgr7( write_xgr7 ),
    .write_xgr6( write_xgr6 ),
    .write_xgr5( write_xgr5 ),
    .write_xgr4( write_xgr4 ),
    .write_xgr3( write_xgr3 ),
    .write_xgr2( write_xgr2 ),
    .write_xgr1( write_xgr1 ),
    .write_irw_en_7( write_irw_en_7 ),
    .write_irw_en_6( write_irw_en_6 ),
    .write_irw_en_5( write_irw_en_5 ),
    .write_irw_en_4( write_irw_en_4 ),
    .write_irw_en_3( write_irw_en_3 ),
    .write_irw_en_2( write_irw_en_2 ),
    .write_irw_en_1( write_irw_en_1 ),
    .write_irw_en_0( write_irw_en_0 ),
    // inputs
    .async_rst_b( async_rst_b ),
    .read_risc_regs(               // in  -- read register bits
       { xgr7,             // XGR7
         xgr6,             // XGR6
         xgr5,             // XGR5
         xgr4,             // XGR4
         xgr3,             // XGR3
         xgr2,             // XGR2
         xgr1,             // XGR1
         16'b0,            // Reserved (XGR0)
         xgate_address,    // XGPC
         {12'h000,  negative_flag, zero_flag, overflow_flag, carry_flag},  // XGCCR
         16'b0,                // Reserved
         {8'h00, host_semap},  // XGSEM
         {8'h00, xgswt},       // XGSWT
         {xgif_status[ 15:  1], 1'b0}, // XGIF_0
         xgif_status[ 31: 16], // XGIF_1
         xgif_status[ 47: 32], // XGIF_2
         xgif_status[ 63: 48], // XGIF_3
         xgif_status[ 79: 64], // XGIF_4
         xgif_status[ 95: 80], // XGIF_5
         xgif_status[111: 96], // XGIF_6
         xgif_status[127:112], // XGIF_7
         {xgvbr[15:1], 1'b0},  // XGVBR
         16'b0,                // Reserved
         16'b0,                // Reserved
         {8'b0, 1'b0, xgchid}, // XGCHID
         {8'b0, xge, xgfrz, debug_active, 1'b0, xgfact, brk_irq_ena, xg_sw_irq, xgie}  // XGMCTL
       }
      ),
    .irq_bypass( irq_bypass )

  );

  // ---------------------------------------------------------------------------
  xgate_regs #(.ARST_LVL(ARST_LVL),
               .MAX_CHANNEL(MAX_CHANNEL))
    regs(
    // outputs
    .xge( xge ),
    .xgfrz( xgfrz ),
    .xgdbg_set( xgdbg_set ),
    .xgdbg_clear( xgdbg_clear ),
    .xgfact( xgfact ),
    .xgss( xgss ),
    .xgsweif_c( xgsweif_c ),
    .xgie( xgie ),
    .brk_irq_ena( brk_irq_ena ),
    .xgvbr( xgvbr ),
    .xgswt( xgswt ),
    .clear_xgif_7( clear_xgif_7 ),
    .clear_xgif_6( clear_xgif_6 ),
    .clear_xgif_5( clear_xgif_5 ),
    .clear_xgif_4( clear_xgif_4 ),
    .clear_xgif_3( clear_xgif_3 ),
    .clear_xgif_2( clear_xgif_2 ),
    .clear_xgif_1( clear_xgif_1 ),
    .clear_xgif_0( clear_xgif_0 ),
    .clear_xgif_data( clear_xgif_data ),
    .irq_bypass( irq_bypass ),
    .chan_bypass( chan_bypass ),

    // inputs
    .async_rst_b( async_rst_b ),
    .sync_reset( sync_reset ),
    .bus_clk( wbs_clk_i ),
    .write_bus( wbs_dat_i ),
    .write_xgmctl( write_xgmctl ),
    .write_xgvbr( write_xgvbr ),
    .write_xgif_7( write_xgif_7 ),
    .write_xgif_6( write_xgif_6 ),
    .write_xgif_5( write_xgif_5 ),
    .write_xgif_4( write_xgif_4 ),
    .write_xgif_3( write_xgif_3 ),
    .write_xgif_2( write_xgif_2 ),
    .write_xgif_1( write_xgif_1 ),
    .write_xgif_0( write_xgif_0 ),
    .write_irw_en_7( write_irw_en_7 ),
    .write_irw_en_6( write_irw_en_6 ),
    .write_irw_en_5( write_irw_en_5 ),
    .write_irw_en_4( write_irw_en_4 ),
    .write_irw_en_3( write_irw_en_3 ),
    .write_irw_en_2( write_irw_en_2 ),
    .write_irw_en_1( write_irw_en_1 ),
    .write_irw_en_0( write_irw_en_0 ),
    .write_xgswt( write_xgswt ),
    .debug_ack( debug_ack )
  );

  // ---------------------------------------------------------------------------
  xgate_risc #(.MAX_CHANNEL(MAX_CHANNEL))
    risc(
    // outputs
    .xgate_address( xgate_address ),
    .write_mem_strb_l( write_mem_strb_l ),
    .write_mem_strb_h( write_mem_strb_h ),
    .write_mem_data( write_mem_data ),
    .zero_flag( zero_flag ),
    .negative_flag( negative_flag ),
    .carry_flag( carry_flag ),
    .overflow_flag( overflow_flag ),
    .xgchid( xgchid ),
    .host_semap( host_semap ),
    .xgr1( xgr1 ),
    .xgr2( xgr2 ),
    .xgr3( xgr3 ),
    .xgr4( xgr4 ),
    .xgr5( xgr5 ),
    .xgr6( xgr6 ),
    .xgr7( xgr7 ),
    .xgif_status( xgif_status ),
    .debug_active( debug_active ),
    .debug_ack( debug_ack ),
    .xg_sw_irq( xg_sw_irq ),
    .mem_access( mem_access ),
    .single_step( single_step ),

    // inputs
    .risc_clk( risc_clk ),
    .perif_data( wbs_dat_i ),
    .async_rst_b( async_rst_b ),
    .read_mem_data( read_mem_data ),
    .mem_req_ack( mem_req_ack ),
    .ss_mem_ack( ss_mem_ack ),
    .xge( xge ),
    .xgdbg_set( xgdbg_set ),
    .xgdbg_clear( xgdbg_clear ),
    .debug_mode_i(debug_mode_i),
    .xgss( xgss ),
    .xgvbr( xgvbr ),
    .int_req( int_req ),
    .xgie( xgie ),
    .brk_irq_ena( brk_irq_ena ),
    .write_xgsem( write_xgsem ),
    .write_xgchid( write_xgchid ),
    .write_xgccr( write_xgccr ),
    .write_xgpc( write_xgpc ),
    .write_xgr7( write_xgr7 ),
    .write_xgr6( write_xgr6 ),
    .write_xgr5( write_xgr5 ),
    .write_xgr4( write_xgr4 ),
    .write_xgr3( write_xgr3 ),
    .write_xgr2( write_xgr2 ),
    .write_xgr1( write_xgr1 ),
    .clear_xgif_7( clear_xgif_7 ),
    .clear_xgif_6( clear_xgif_6 ),
    .clear_xgif_5( clear_xgif_5 ),
    .clear_xgif_4( clear_xgif_4 ),
    .clear_xgif_3( clear_xgif_3 ),
    .clear_xgif_2( clear_xgif_2 ),
    .clear_xgif_1( clear_xgif_1 ),
    .clear_xgif_0( clear_xgif_0 ),
    .xgsweif_c( xgsweif_c ),
    .clear_xgif_data( clear_xgif_data )
  );

  xgate_irq_encode #(.MAX_CHANNEL(MAX_CHANNEL))
    irq_encode(
    // outputs
    .xgif( xgif ),
    .int_req( int_req ),
    // inputs
    .chan_req_i( chan_req_i ),
    .chan_bypass( chan_bypass ),
    .xgif_status( xgif_status )
  );

  // ---------------------------------------------------------------------------
  // Wishbone Master Bus interface
  xgate_wbm_bus #(.ARST_LVL(ARST_LVL))
    wishbone_m(
  // Wishbone Master Signals
    .wbm_dat_o( wbm_dat_o ),
    .wbm_we_o( wbm_we_o ),
    .wbm_stb_o( wbm_stb_o ),
    .wbm_cyc_o( wbm_cyc_o ),
    .wbm_sel_o( wbm_sel_o ),
    .wbm_adr_o( wbm_adr_o ),
    .wbm_dat_i( wbm_dat_i ),
    .wbm_ack_i( wbm_ack_i ),
 // XGATE Control Signals
    .risc_clk( risc_clk ),
    .async_rst_b( async_rst_b ),
    .xge( xge ),
    .mem_access( mem_access ),
    .single_step( single_step ),
    .ss_mem_ack( ss_mem_ack ),
    .read_mem_data( read_mem_data ),
    .xgate_address( xgate_address ),
    .mem_req_ack( mem_req_ack ),
    .write_mem_strb_l( write_mem_strb_l ),
    .write_mem_strb_h( write_mem_strb_h ),
    .write_mem_data( write_mem_data )
  );


endmodule  // xgate_top

