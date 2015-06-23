/*
 *  PS2 Wishbone 8042 compatible keyboard controller
 *
 *  Copyright (c) 2009  Zeus Gomez Marmolejo <zeus@opencores.org>
 *  adapted from the opencores keyboard controller from John Clayton
 *
 *  This file is part of the Zet processor. This processor is free
 *  hardware; you can redistribute it and/or modify it under the terms of
 *  the GNU General Public License as published by the Free Software
 *  Foundation; either version 3, or (at your option) any later version.
 *
 *  Zet is distrubuted in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 *  License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Zet; see the file COPYING. If not, see
 *  <http://www.gnu.org/licenses/>.
 */

`include "defines.v"

`timescale 1ns/100ps

`define TOTAL_BITS   11
`define RELEASE_CODE 16'hF0
`define LEFT_SHIFT   16'h12
`define RIGHT_SHIFT  16'h59

module ps2_keyb (
`ifdef DEBUG
    output           rx_output_strobe,
    output           released,
    output           rx_shifting_done,
`endif
    // Wishbone slave interface
    input            wb_clk_i,
    input            wb_rst_i,
    output reg [7:0] wb_dat_o,   // scancode
    output reg       wb_tgc_o,   // intr

    // PS2 PAD signals
    inout            ps2_clk_,
    inout            ps2_data_
  );

  // Parameter declarations
  // The timer value can be up to (2^bits) inclusive.
  parameter TIMER_60USEC_VALUE_PP = 1920; // Number of sys_clks for 60usec.
  parameter TIMER_60USEC_BITS_PP  = 11;   // Number of bits needed for timer
  parameter TIMER_5USEC_VALUE_PP  = 186;  // Number of sys_clks for debounce
  parameter TIMER_5USEC_BITS_PP   = 8;    // Number of bits needed for timer
  parameter TRAP_SHIFT_KEYS_PP    = 0;    // Default: No shift key trap.

  // State encodings, provided as parameters
  // for flexibility to the one instantiating the module.
  // In general, the default values need not be changed.

  // State "m1_rx_clk_l" has been chosen on purpose.  Since the input
  // synchronizing flip-flops initially contain zero, it takes one clk
  // for them to update to reflect the actual (idle = high) status of
  // the I/O lines from the keyboard.  Therefore, choosing 0 for m1_rx_clk_l
  // allows the state machine to transition to m1_rx_clk_h when the true
  // values of the input signals become present at the outputs of the
  // synchronizing flip-flops.  This initial transition is harmless, and it
  // eliminates the need for a "reset" pulse before the interface can operate.
  parameter m1_rx_clk_h = 1;
  parameter m1_rx_clk_l = 0;
  parameter m1_rx_falling_edge_marker = 13;
  parameter m1_rx_rising_edge_marker = 14;
  parameter m1_tx_force_clk_l = 3;
  parameter m1_tx_first_wait_clk_h = 10;
  parameter m1_tx_first_wait_clk_l = 11;
  parameter m1_tx_reset_timer = 12;
  parameter m1_tx_wait_clk_h = 2;
  parameter m1_tx_clk_h = 4;
  parameter m1_tx_clk_l = 5;
  parameter m1_tx_wait_keyboard_ack = 6;
  parameter m1_tx_done_recovery = 7;
  parameter m1_tx_error_no_keyboard_ack = 8;
  parameter m1_tx_rising_edge_marker = 9;

  // Nets and registers
  wire rx_output_event;
  wire tx_shifting_done;
  wire timer_60usec_done;
  wire timer_5usec_done;
`ifndef DEBUG
  wire rx_output_strobe;
  wire rx_shifting_done;
  wire released;
`endif
  wire [6:0] xt_code;

  reg [3:0] bit_count;
  reg [3:0] m1_state;
  reg [3:0] m1_next_state;

  reg ps2_clk_hi_z;     // Without keyboard, high Z equals 1 due to pullups.
  reg ps2_data_hi_z;    // Without keyboard, high Z equals 1 due to pullups.
  reg ps2_clk_s;        // Synchronous version of this input
  reg ps2_data_s;       // Synchronous version of this input

  reg enable_timer_60usec;
  reg enable_timer_5usec;
  reg [TIMER_60USEC_BITS_PP-1:0] timer_60usec_count;
  reg [TIMER_5USEC_BITS_PP-1:0] timer_5usec_count;

  reg [`TOTAL_BITS-1:0] q;

  reg hold_released;    // Holds prior value, cleared at rx_output_strobe

  // Module instantiation
  translate_8042 tr0 (
    .at_code (q[7:1]),
    .xt_code (xt_code)
  );

  // Continuous assignments
  // This signal is high for one clock at the end of the timer count.
  assign rx_shifting_done = (bit_count == `TOTAL_BITS);
  assign tx_shifting_done = (bit_count == `TOTAL_BITS-1);

  assign rx_output_event  = (rx_shifting_done
                          && ~released
                          );
  assign rx_output_strobe = (rx_shifting_done
                          && ~released
                          && ( (TRAP_SHIFT_KEYS_PP == 0)
                               || ( (q[8:1] != `RIGHT_SHIFT)
                                    &&(q[8:1] != `LEFT_SHIFT)
                                  )
                             )
                          );

  assign ps2_clk_  = ps2_clk_hi_z  ? 1'bZ : 1'b0;
  assign ps2_data_ = ps2_data_hi_z ? 1'bZ : 1'b0;

  assign timer_60usec_done =
    (timer_60usec_count == (TIMER_60USEC_VALUE_PP - 1));
  assign timer_5usec_done = (timer_5usec_count == TIMER_5USEC_VALUE_PP - 1);

  // Create the signals which indicate special scan codes received.
  // These are the "unlatched versions."
  //assign extended = (q[8:1] == `EXTEND_CODE) && rx_shifting_done;
  assign released = (q[8:1] == `RELEASE_CODE) && rx_shifting_done;

  // Behaviour
  // wb_tgc_o
  always @(posedge wb_clk_i)
    wb_tgc_o <= wb_rst_i ? 1'b0 : rx_output_strobe;

  // This is the shift register
  always @(posedge wb_clk_i)
    if (wb_rst_i) q <= 0;
    //  else if (((m1_state == m1_rx_clk_h) && ~ps2_clk_s)
    else if ( (m1_state == m1_rx_falling_edge_marker)
             ||(m1_state == m1_tx_rising_edge_marker) )
        q <= {ps2_data_s,q[`TOTAL_BITS-1:1]};

  // This is the 60usec timer counter
  always @(posedge wb_clk_i)
    if (~enable_timer_60usec) timer_60usec_count <= 0;
    else if (~timer_60usec_done) timer_60usec_count <= timer_60usec_count + 1;

  // This is the 5usec timer counter
  always @(posedge wb_clk_i)
    if (~enable_timer_5usec) timer_5usec_count <= 0;
    else if (~timer_5usec_done) timer_5usec_count <= timer_5usec_count + 1;

  // Input "synchronizing" logic -- synchronizes the inputs to the state
  // machine clock, thus avoiding errors related to
  // spurious state machine transitions.
  //
  // Since the initial state of registers is zero, and the idle state
  // of the ps2_clk and ps2_data lines is "1" (due to pullups), the
  // "sense" of the ps2_clk_s signal is inverted from the true signal.
  // This allows the state machine to "come up" in the correct
  always @(posedge wb_clk_i)
  begin
    ps2_clk_s <= ps2_clk_;
    ps2_data_s <= ps2_data_;
  end

  // State transition logic
  always @(m1_state
           or q
           or tx_shifting_done
           or ps2_clk_s
           or ps2_data_s
           or timer_60usec_done
           or timer_5usec_done
          )
    begin : m1_state_logic

    // Output signals default to this value,
    //  unless changed in a state condition.
    ps2_clk_hi_z  <= 1;
    ps2_data_hi_z <= 1;
    enable_timer_60usec <= 0;
    enable_timer_5usec  <= 0;

    case (m1_state)

      m1_rx_clk_h :
      begin
        enable_timer_60usec <= 1;
        if (~ps2_clk_s)
          m1_next_state <= m1_rx_falling_edge_marker;
        else m1_next_state <= m1_rx_clk_h;
      end

      m1_rx_falling_edge_marker :
      begin
        enable_timer_60usec <= 0;
        m1_next_state <= m1_rx_clk_l;
      end

      m1_rx_rising_edge_marker :
      begin
        enable_timer_60usec <= 0;
        m1_next_state <= m1_rx_clk_h;
      end

      m1_rx_clk_l :
      begin
        enable_timer_60usec <= 1;
        if (ps2_clk_s)
          m1_next_state <= m1_rx_rising_edge_marker;
        else m1_next_state <= m1_rx_clk_l;
      end

      m1_tx_reset_timer :
      begin
        enable_timer_60usec <= 0;
        m1_next_state <= m1_tx_force_clk_l;
      end

      m1_tx_force_clk_l :
      begin
        enable_timer_60usec <= 1;
        ps2_clk_hi_z <= 0;  // Force the ps2_clk line low.
        if (timer_60usec_done)
          m1_next_state <= m1_tx_first_wait_clk_h;
        else m1_next_state <= m1_tx_force_clk_l;
      end

      m1_tx_first_wait_clk_h :
      begin
        enable_timer_5usec <= 1;
        ps2_data_hi_z <= 0;        // Start bit.
        if (~ps2_clk_s && timer_5usec_done)
          m1_next_state <= m1_tx_clk_l;
        else
          m1_next_state <= m1_tx_first_wait_clk_h;
      end

      // This state must be included because the device might possibly
      // delay for up to 10 milliseconds before beginning its clock pulses.
      // During that waiting time, we cannot drive the data (q[0]) because it
      // is possibly 1, which would cause the keyboard to abort its receive
      // and the expected clocks would then never be generated.
      m1_tx_first_wait_clk_l :
      begin
        ps2_data_hi_z <= 0;
        if (~ps2_clk_s) m1_next_state <= m1_tx_clk_l;
        else m1_next_state <= m1_tx_first_wait_clk_l;
      end

      m1_tx_wait_clk_h :
      begin
        enable_timer_5usec <= 1;
        ps2_data_hi_z <= q[0];
        if (ps2_clk_s && timer_5usec_done)
          m1_next_state <= m1_tx_rising_edge_marker;
        else
          m1_next_state <= m1_tx_wait_clk_h;
      end

      m1_tx_rising_edge_marker :
      begin
        ps2_data_hi_z <= q[0];
        m1_next_state <= m1_tx_clk_h;
      end

      m1_tx_clk_h :
      begin
        ps2_data_hi_z <= q[0];
        if (tx_shifting_done) m1_next_state <= m1_tx_wait_keyboard_ack;
        else if (~ps2_clk_s) m1_next_state <= m1_tx_clk_l;
        else m1_next_state <= m1_tx_clk_h;
      end

      m1_tx_clk_l :
      begin
        ps2_data_hi_z <= q[0];
        if (ps2_clk_s) m1_next_state <= m1_tx_wait_clk_h;
        else m1_next_state <= m1_tx_clk_l;
      end

      m1_tx_wait_keyboard_ack :
      begin
        if (~ps2_clk_s && ps2_data_s)
          m1_next_state <= m1_tx_error_no_keyboard_ack;
        else if (~ps2_clk_s && ~ps2_data_s)
          m1_next_state <= m1_tx_done_recovery;
        else m1_next_state <= m1_tx_wait_keyboard_ack;
      end

      m1_tx_done_recovery :
      begin
        if (ps2_clk_s && ps2_data_s) m1_next_state <= m1_rx_clk_h;
        else m1_next_state <= m1_tx_done_recovery;
      end

      m1_tx_error_no_keyboard_ack :
      begin
        if (ps2_clk_s && ps2_data_s) m1_next_state <= m1_rx_clk_h;
        else m1_next_state <= m1_tx_error_no_keyboard_ack;
      end

      default : m1_next_state <= m1_rx_clk_h;
    endcase
  end

  // State register
  always @(posedge wb_clk_i)
  begin : m1_state_register
    if (wb_rst_i) m1_state <= m1_rx_clk_h;
    else m1_state <= m1_next_state;
  end

  // wb_dat_o - scancode
  always @(posedge wb_clk_i)
    if (wb_rst_i) wb_dat_o <= 8'b0;
    else wb_dat_o <=
      (rx_output_strobe && q[8:1]) ? (q[8] ? q[8:1]
        : {hold_released,xt_code})
     : wb_dat_o;

  // This is the bit counter
  always @(posedge wb_clk_i)
    begin
      if (wb_rst_i
         || rx_shifting_done
         || (m1_state == m1_tx_wait_keyboard_ack) // After tx is done.
         ) bit_count <= 0;  // normal reset
      else if (timer_60usec_done
               && (m1_state == m1_rx_clk_h)
               && (ps2_clk_s)
              ) bit_count <= 0;  // rx watchdog timer reset
      else if ( (m1_state == m1_rx_falling_edge_marker) // increment for rx
              ||(m1_state == m1_tx_rising_edge_marker)  // increment for tx
              )
        bit_count <= bit_count + 1;
  end

  // Store the special scan code status bits
  // Not the final output, but an intermediate storage place,
  // until the entire set of output data can be assembled.
  always @(posedge wb_clk_i)
    if (wb_rst_i || rx_output_event) hold_released <= 0;
    else if (rx_shifting_done && released) hold_released <= 1;

endmodule


module translate_8042 (
    input      [6:0] at_code,
    output reg [6:0] xt_code
  );

  // Behaviour
  always @(at_code)
    case (at_code)
      7'h00: xt_code <= 7'h7f;
      7'h01: xt_code <= 7'h43;
      7'h02: xt_code <= 7'h41;
      7'h03: xt_code <= 7'h3f;
      7'h04: xt_code <= 7'h3d;
      7'h05: xt_code <= 7'h3b;
      7'h06: xt_code <= 7'h3c;
      7'h07: xt_code <= 7'h58;
      7'h08: xt_code <= 7'h64;
      7'h09: xt_code <= 7'h44;
      7'h0a: xt_code <= 7'h42;
      7'h0b: xt_code <= 7'h40;
      7'h0c: xt_code <= 7'h3e;
      7'h0d: xt_code <= 7'h0f;
      7'h0e: xt_code <= 7'h29;
      7'h0f: xt_code <= 7'h59;
      7'h10: xt_code <= 7'h65;
      7'h11: xt_code <= 7'h38;
      7'h12: xt_code <= 7'h2a;
      7'h13: xt_code <= 7'h70;
      7'h14: xt_code <= 7'h1d;
      7'h15: xt_code <= 7'h10;
      7'h16: xt_code <= 7'h02;
      7'h17: xt_code <= 7'h5a;
      7'h18: xt_code <= 7'h66;
      7'h19: xt_code <= 7'h71;
      7'h1a: xt_code <= 7'h2c;
      7'h1b: xt_code <= 7'h1f;
      7'h1c: xt_code <= 7'h1e;
      7'h1d: xt_code <= 7'h11;
      7'h1e: xt_code <= 7'h03;
      7'h1f: xt_code <= 7'h5b;
      7'h20: xt_code <= 7'h67;
      7'h21: xt_code <= 7'h2e;
      7'h22: xt_code <= 7'h2d;
      7'h23: xt_code <= 7'h20;
      7'h24: xt_code <= 7'h12;
      7'h25: xt_code <= 7'h05;
      7'h26: xt_code <= 7'h04;
      7'h27: xt_code <= 7'h5c;
      7'h28: xt_code <= 7'h68;
      7'h29: xt_code <= 7'h39;
      7'h2a: xt_code <= 7'h2f;
      7'h2b: xt_code <= 7'h21;
      7'h2c: xt_code <= 7'h14;
      7'h2d: xt_code <= 7'h13;
      7'h2e: xt_code <= 7'h06;
      7'h2f: xt_code <= 7'h5d;
      7'h30: xt_code <= 7'h69;
      7'h31: xt_code <= 7'h31;
      7'h32: xt_code <= 7'h30;
      7'h33: xt_code <= 7'h23;
      7'h34: xt_code <= 7'h22;
      7'h35: xt_code <= 7'h15;
      7'h36: xt_code <= 7'h07;
      7'h37: xt_code <= 7'h5e;
      7'h38: xt_code <= 7'h6a;
      7'h39: xt_code <= 7'h72;
      7'h3a: xt_code <= 7'h32;
      7'h3b: xt_code <= 7'h24;
      7'h3c: xt_code <= 7'h16;
      7'h3d: xt_code <= 7'h08;
      7'h3e: xt_code <= 7'h09;
      7'h3f: xt_code <= 7'h5f;
      7'h40: xt_code <= 7'h6b;
      7'h41: xt_code <= 7'h33;
      7'h42: xt_code <= 7'h25;
      7'h43: xt_code <= 7'h17;
      7'h44: xt_code <= 7'h18;
      7'h45: xt_code <= 7'h0b;
      7'h46: xt_code <= 7'h0a;
      7'h47: xt_code <= 7'h60;
      7'h48: xt_code <= 7'h6c;
      7'h49: xt_code <= 7'h34;
      7'h4a: xt_code <= 7'h35;
      7'h4b: xt_code <= 7'h26;
      7'h4c: xt_code <= 7'h27;
      7'h4d: xt_code <= 7'h19;
      7'h4e: xt_code <= 7'h0c;
      7'h4f: xt_code <= 7'h61;
      7'h50: xt_code <= 7'h6d;
      7'h51: xt_code <= 7'h73;
      7'h52: xt_code <= 7'h28;
      7'h53: xt_code <= 7'h74;
      7'h54: xt_code <= 7'h1a;
      7'h55: xt_code <= 7'h0d;
      7'h56: xt_code <= 7'h62;
      7'h57: xt_code <= 7'h6e;
      7'h58: xt_code <= 7'h3a;
      7'h59: xt_code <= 7'h36;
      7'h5a: xt_code <= 7'h1c;
      7'h5b: xt_code <= 7'h1b;
      7'h5c: xt_code <= 7'h75;
      7'h5d: xt_code <= 7'h2b;
      7'h5e: xt_code <= 7'h63;
      7'h5f: xt_code <= 7'h76;
      7'h60: xt_code <= 7'h55;
      7'h61: xt_code <= 7'h56;
      7'h62: xt_code <= 7'h77;
      7'h63: xt_code <= 7'h78;
      7'h64: xt_code <= 7'h79;
      7'h65: xt_code <= 7'h7a;
      7'h66: xt_code <= 7'h0e;
      7'h67: xt_code <= 7'h7b;
      7'h68: xt_code <= 7'h7c;
      7'h69: xt_code <= 7'h4f;
      7'h6a: xt_code <= 7'h7d;
      7'h6b: xt_code <= 7'h4b;
      7'h6c: xt_code <= 7'h47;
      7'h6d: xt_code <= 7'h7e;
      7'h6e: xt_code <= 7'h7f;
      7'h6f: xt_code <= 7'h6f;
      7'h70: xt_code <= 7'h52;
      7'h71: xt_code <= 7'h53;
      7'h72: xt_code <= 7'h50;
      7'h73: xt_code <= 7'h4c;
      7'h74: xt_code <= 7'h4d;
      7'h75: xt_code <= 7'h48;
      7'h76: xt_code <= 7'h01;
      7'h77: xt_code <= 7'h45;
      7'h78: xt_code <= 7'h57;
      7'h79: xt_code <= 7'h4e;
      7'h7a: xt_code <= 7'h51;
      7'h7b: xt_code <= 7'h4a;
      7'h7c: xt_code <= 7'h37;
      7'h7d: xt_code <= 7'h49;
      7'h7e: xt_code <= 7'h46;
      7'h7f: xt_code <= 7'h54;
    endcase
endmodule
