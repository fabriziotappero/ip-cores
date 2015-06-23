//Legal Notice: (C)2006 Altera Corporation. All rights reserved. Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.



`define TOTAL_BITS   11
`define EXTEND_CODE  16'hE0
`define RELEASE_CODE 16'hF0
`define LEFT_SHIFT   16'h12
`define RIGHT_SHIFT  16'h59


module ps2_keyboard (
  clk,
  reset,
  ps2_clk_en_o_,
  ps2_data_en_o_,
  ps2_clk_i,
  ps2_data_i,
  rx_extended,
  rx_released,
  rx_shift_key_on,
  rx_scan_code,
  rx_ascii,
  rx_data_ready,       // rx_read_o
  rx_read,             // rx_read_ack_i
  tx_data,
  tx_write,
  tx_write_ack_o,
  tx_error_no_keyboard_ack,
  translate
  );

// Parameters

// The timer value can be up to (2^bits) inclusive.
parameter TIMER_60USEC_VALUE_PP = 2950; // Number of sys_clks for 60usec.
parameter TIMER_60USEC_BITS_PP  = 12;   // Number of bits needed for timer
parameter TIMER_5USEC_VALUE_PP = 186;   // Number of sys_clks for debounce
parameter TIMER_5USEC_BITS_PP  = 8;     // Number of bits needed for timer
parameter TRAP_SHIFT_KEYS_PP = 0;       // Default: No shift key trap.

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
parameter m2_rx_data_ready = 1;
parameter m2_rx_data_ready_ack = 0;

  
// I/O declarations
input clk;
input reset;
output ps2_clk_en_o_ ;
output ps2_data_en_o_ ;
input  ps2_clk_i ;
input  ps2_data_i ;
output rx_extended;
output rx_released;
output rx_shift_key_on;
output [7:0] rx_scan_code;
output [7:0] rx_ascii;
output rx_data_ready;
input rx_read;
input [7:0] tx_data;
input tx_write;
output tx_write_ack_o;
output tx_error_no_keyboard_ack;
input  translate ;

reg rx_extended;
reg rx_released;
reg [7:0] rx_scan_code;
reg [7:0] rx_ascii;
reg rx_data_ready;
reg tx_error_no_keyboard_ack;

// Internal signal declarations
wire timer_60usec_done;
wire timer_5usec_done;
wire extended;
wire released;
wire shift_key_on;

                         // NOTE: These two signals used to be one.  They
                         //       were split into two signals because of
                         //       shift key trapping.  With shift key
                         //       trapping, no event is generated externally,
                         //       but the "hold" data must still be cleared
                         //       anyway regardless, in preparation for the
                         //       next scan codes.
wire rx_output_event;    // Used only to clear: hold_released, hold_extended
wire rx_output_strobe;   // Used to produce the actual output.

wire tx_parity_bit;
wire rx_shifting_done;
wire tx_shifting_done;
wire [11:0] shift_key_plus_code;

reg [`TOTAL_BITS-1:0] q;
reg [3:0] m1_state;
reg [3:0] m1_next_state;
reg m2_state;
reg m2_next_state;
reg [3:0] bit_count;
reg enable_timer_60usec;
reg enable_timer_5usec;
reg [TIMER_60USEC_BITS_PP-1:0] timer_60usec_count;
reg [TIMER_5USEC_BITS_PP-1:0] timer_5usec_count;
reg [7:0] ascii;      // "REG" type only because a case statement is used.
reg left_shift_key;
reg right_shift_key;
reg hold_extended;    // Holds prior value, cleared at rx_output_strobe
reg hold_released;    // Holds prior value, cleared at rx_output_strobe
reg ps2_clk_s;        // Synchronous version of this input
reg ps2_data_s;       // Synchronous version of this input
reg ps2_clk_hi_z;     // Without keyboard, high Z equals 1 due to pullups.
reg ps2_data_hi_z;    // Without keyboard, high Z equals 1 due to pullups.

//--------------------------------------------------------------------------
// Module code

assign ps2_clk_en_o_  = ps2_clk_hi_z  ;
assign ps2_data_en_o_ = ps2_data_hi_z ;

// Input "synchronizing" logic -- synchronizes the inputs to the state
// machine clock, thus avoiding errors related to
// spurious state machine transitions.
always @(posedge clk)
begin
  ps2_clk_s <= ps2_clk_i;
  ps2_data_s <= ps2_data_i;
end

// State register
always @(posedge clk)
begin : m1_state_register
  if (reset) m1_state <= m1_rx_clk_h;
  else m1_state <= m1_next_state;
end

// State transition logic
always @(m1_state
         or q
         or tx_shifting_done
         or tx_write
         or ps2_clk_s
         or ps2_data_s
         or timer_60usec_done
         or timer_5usec_done
         )
begin : m1_state_logic

  // Output signals default to this value, unless changed in a state condition.
  ps2_clk_hi_z <= 1;
  ps2_data_hi_z <= 1;
  tx_error_no_keyboard_ack <= 0;
  enable_timer_60usec <= 0;
  enable_timer_5usec <= 0;

  case (m1_state)

    m1_rx_clk_h :
      begin
        enable_timer_60usec <= 1;
        if (tx_write) m1_next_state <= m1_tx_reset_timer;
        else if (~ps2_clk_s) m1_next_state <= m1_rx_falling_edge_marker;
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
        if (tx_write) m1_next_state <= m1_tx_reset_timer;
        else if (ps2_clk_s) m1_next_state <= m1_rx_rising_edge_marker;
        else m1_next_state <= m1_rx_clk_l;
      end

    m1_tx_reset_timer:
      begin
        enable_timer_60usec <= 0;
        m1_next_state <= m1_tx_force_clk_l;
      end

    m1_tx_force_clk_l :
      begin
        enable_timer_60usec <= 1;
        ps2_clk_hi_z <= 0;  // Force the ps2_clk line low.
        if (timer_60usec_done) m1_next_state <= m1_tx_first_wait_clk_h;
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
        tx_error_no_keyboard_ack <= 1;
        if (ps2_clk_s && ps2_data_s) m1_next_state <= m1_rx_clk_h;
        else m1_next_state <= m1_tx_error_no_keyboard_ack;
      end

    default : m1_next_state <= m1_rx_clk_h;
  endcase
end

// State register
always @(posedge clk)
begin : m2_state_register
  if (reset) m2_state <= m2_rx_data_ready_ack;
  else m2_state <= m2_next_state;
end

// State transition logic
always @(m2_state or rx_output_strobe or rx_read)
begin : m2_state_logic
  case (m2_state)
    m2_rx_data_ready_ack:
          begin
            rx_data_ready <= 1'b0;
            if (rx_output_strobe) m2_next_state <= m2_rx_data_ready;
            else m2_next_state <= m2_rx_data_ready_ack;
          end
    m2_rx_data_ready:
          begin
            rx_data_ready <= 1'b1;
            if (rx_read) m2_next_state <= m2_rx_data_ready_ack;
            else m2_next_state <= m2_rx_data_ready;
          end
    default : m2_next_state <= m2_rx_data_ready_ack;
  endcase
end

// This is the bit counter
always @(posedge clk)
begin
  if (   reset
      || rx_shifting_done
      || (m1_state == m1_tx_wait_keyboard_ack)        // After tx is done.
      ) bit_count <= 0;  // normal reset
  else if (timer_60usec_done
           && (m1_state == m1_rx_clk_h)
           && (ps2_clk_s)
      ) bit_count <= 0;  // rx watchdog timer reset
  else if ( (m1_state == m1_rx_falling_edge_marker)   // increment for rx
           ||(m1_state == m1_tx_rising_edge_marker)   // increment for tx
           )
    bit_count <= bit_count + 1;
end
// This signal is high for one clock at the end of the timer count.
assign rx_shifting_done = (bit_count == `TOTAL_BITS);
assign tx_shifting_done = (bit_count == `TOTAL_BITS-1);

// This is the signal which enables loading of the shift register.
// It also indicates "ack" to the device writing to the transmitter.
assign tx_write_ack_o = (  (tx_write && (m1_state == m1_rx_clk_h))
                         ||(tx_write && (m1_state == m1_rx_clk_l))
                         );

// This is the ODD parity bit for the transmitted word.
assign tx_parity_bit = ~^tx_data;

// This is the shift register
always @(posedge clk)
begin
  if (reset) q <= 0;
  else if (tx_write_ack_o) q <= {1'b1,tx_parity_bit,tx_data,1'b0};
  else if ( (m1_state == m1_rx_falling_edge_marker)
           ||(m1_state == m1_tx_rising_edge_marker) )
    q <= {ps2_data_s,q[`TOTAL_BITS-1:1]};
end

// This is the 60usec timer counter
always @(posedge clk)
begin
  if (~enable_timer_60usec) timer_60usec_count <= 0;
  else if (~timer_60usec_done) timer_60usec_count <= timer_60usec_count + 1;
end
assign timer_60usec_done = (timer_60usec_count == (TIMER_60USEC_VALUE_PP - 1));

// This is the 5usec timer counter
always @(posedge clk)
begin
  if (~enable_timer_5usec) timer_5usec_count <= 0;
  else if (~timer_5usec_done) timer_5usec_count <= timer_5usec_count + 1;
end
assign timer_5usec_done = (timer_5usec_count == TIMER_5USEC_VALUE_PP - 1);


// Create the signals which indicate special scan codes received.
// These are the "unlatched versions."
`ifdef PS2_TRAP_EXTENDED
assign extended = (q[8:1] == `EXTEND_CODE) && rx_shifting_done && translate ;
`else
assign extended = 1'b0 ;
`endif
assign released = (q[8:1] == `RELEASE_CODE) && rx_shifting_done && translate ;

// Store the special scan code status bits
// Not the final output, but an intermediate storage place,
// until the entire set of output data can be assembled.
always @(posedge clk)
begin
  if (reset || rx_output_event)
  begin
    hold_extended <= 0;
    hold_released <= 0;
  end
  else
  begin
    if (rx_shifting_done && extended) hold_extended <= 1;
    if (rx_shifting_done && released) hold_released <= 1;
  end
end


// These bits contain the status of the two shift keys
always @(posedge clk)
begin
  if (reset) left_shift_key <= 0;
  else if ((q[8:1] == `LEFT_SHIFT) && rx_shifting_done && ~hold_released)
    left_shift_key <= 1;
  else if ((q[8:1] == `LEFT_SHIFT) && rx_shifting_done && hold_released)
    left_shift_key <= 0;
end

always @(posedge clk)
begin
  if (reset) right_shift_key <= 0;
  else if ((q[8:1] == `RIGHT_SHIFT) && rx_shifting_done && ~hold_released)
    right_shift_key <= 1;
  else if ((q[8:1] == `RIGHT_SHIFT) && rx_shifting_done && hold_released)
    right_shift_key <= 0;
end

assign rx_shift_key_on = left_shift_key || right_shift_key;

// Output the special scan code flags, the scan code and the ascii
always @(posedge clk)
begin
  if (reset)
  begin
    rx_extended <= 0;
    rx_released <= 0;
    rx_scan_code <= 0;
    rx_ascii <= 0;
  end
  else if (rx_output_strobe)
  begin
    rx_extended <= hold_extended;
    rx_released <= hold_released;
    rx_scan_code <= q[8:1];
    rx_ascii <= ascii;
  end
end

// Store the final rx output data only when all extend and release codes
// are received and the next (actual key) scan code is also ready.
// (the presence of rx_extended or rx_released refers to the
// the current latest scan code received, not the previously latched flags.)
assign rx_output_event  = (rx_shifting_done
                          && ~extended 
                          && ~released
                          );

assign rx_output_strobe = (rx_shifting_done
                          && ~extended 
                          && ~released
                          && ( (TRAP_SHIFT_KEYS_PP == 0) 
                               || ( (q[8:1] != `RIGHT_SHIFT)
                                    &&(q[8:1] != `LEFT_SHIFT)
                                  )
                             )
                          );

// This part translates the scan code into an ASCII value...
// Only the ASCII codes which I considered important have been included.
// if you want more, just add the appropriate case statement lines...
// (You will need to know the keyboard scan codes you wish to assign.)
// The entries are listed in ascending order of ASCII value.
assign shift_key_plus_code = {3'b0,rx_shift_key_on,q[8:1]};
always @(shift_key_plus_code)
begin
  casez (shift_key_plus_code)
    12'h?66 : ascii <= 8'h08;  // Backspace ("backspace" key)
    12'h?0d : ascii <= 8'h09;  // Horizontal Tab
    12'h?5a : ascii <= 8'h0d;  // Carriage return ("enter" key)
    12'h?76 : ascii <= 8'h1b;  // Escape ("esc" key)
    12'h?29 : ascii <= 8'h20;  // Space
    12'h116 : ascii <= 8'h21;  // !
    12'h152 : ascii <= 8'h22;  // "
    12'h126 : ascii <= 8'h23;  // #
    12'h125 : ascii <= 8'h24;  // $
    12'h12e : ascii <= 8'h25;  // %
    12'h13d : ascii <= 8'h26;  // &
    12'h052 : ascii <= 8'h27;  // '
    12'h146 : ascii <= 8'h28;  // (
    12'h145 : ascii <= 8'h29;  // )
    12'h13e : ascii <= 8'h2a;  // *
    12'h155 : ascii <= 8'h2b;  // +
    12'h041 : ascii <= 8'h2c;  // ,
    12'h04e : ascii <= 8'h2d;  // -
    12'h049 : ascii <= 8'h2e;  // .
    12'h04a : ascii <= 8'h2f;  // /
    12'h045 : ascii <= 8'h30;  // 0
    12'h016 : ascii <= 8'h31;  // 1
    12'h01e : ascii <= 8'h32;  // 2
    12'h026 : ascii <= 8'h33;  // 3
    12'h025 : ascii <= 8'h34;  // 4
    12'h02e : ascii <= 8'h35;  // 5
    12'h036 : ascii <= 8'h36;  // 6
    12'h03d : ascii <= 8'h37;  // 7
    12'h03e : ascii <= 8'h38;  // 8
    12'h046 : ascii <= 8'h39;  // 9
    12'h14c : ascii <= 8'h3a;  // :
    12'h04c : ascii <= 8'h3b;  // ;
    12'h141 : ascii <= 8'h3c;  // <
    12'h055 : ascii <= 8'h3d;  // =
    12'h149 : ascii <= 8'h3e;  // >
    12'h14a : ascii <= 8'h3f;  // ?
    12'h11e : ascii <= 8'h40;  // @
    12'h11c : ascii <= 8'h41;  // A
    12'h132 : ascii <= 8'h42;  // B
    12'h121 : ascii <= 8'h43;  // C
    12'h123 : ascii <= 8'h44;  // D
    12'h124 : ascii <= 8'h45;  // E
    12'h12b : ascii <= 8'h46;  // F
    12'h134 : ascii <= 8'h47;  // G
    12'h133 : ascii <= 8'h48;  // H
    12'h143 : ascii <= 8'h49;  // I
    12'h13b : ascii <= 8'h4a;  // J
    12'h142 : ascii <= 8'h4b;  // K
    12'h14b : ascii <= 8'h4c;  // L
    12'h13a : ascii <= 8'h4d;  // M
    12'h131 : ascii <= 8'h4e;  // N
    12'h144 : ascii <= 8'h4f;  // O
    12'h14d : ascii <= 8'h50;  // P
    12'h115 : ascii <= 8'h51;  // Q
    12'h12d : ascii <= 8'h52;  // R
    12'h11b : ascii <= 8'h53;  // S
    12'h12c : ascii <= 8'h54;  // T
    12'h13c : ascii <= 8'h55;  // U
    12'h12a : ascii <= 8'h56;  // V
    12'h11d : ascii <= 8'h57;  // W
    12'h122 : ascii <= 8'h58;  // X
    12'h135 : ascii <= 8'h59;  // Y
    12'h11a : ascii <= 8'h5a;  // Z
    12'h054 : ascii <= 8'h5b;  // [
    12'h05d : ascii <= 8'h5c;  // \
    12'h05b : ascii <= 8'h5d;  // ]
    12'h136 : ascii <= 8'h5e;  // ^
    12'h14e : ascii <= 8'h5f;  // _    
    12'h00e : ascii <= 8'h60;  // `
    12'h01c : ascii <= 8'h61;  // a
    12'h032 : ascii <= 8'h62;  // b
    12'h021 : ascii <= 8'h63;  // c
    12'h023 : ascii <= 8'h64;  // d
    12'h024 : ascii <= 8'h65;  // e
    12'h02b : ascii <= 8'h66;  // f
    12'h034 : ascii <= 8'h67;  // g
    12'h033 : ascii <= 8'h68;  // h
    12'h043 : ascii <= 8'h69;  // i
    12'h03b : ascii <= 8'h6a;  // j
    12'h042 : ascii <= 8'h6b;  // k
    12'h04b : ascii <= 8'h6c;  // l
    12'h03a : ascii <= 8'h6d;  // m
    12'h031 : ascii <= 8'h6e;  // n
    12'h044 : ascii <= 8'h6f;  // o
    12'h04d : ascii <= 8'h70;  // p
    12'h015 : ascii <= 8'h71;  // q
    12'h02d : ascii <= 8'h72;  // r
    12'h01b : ascii <= 8'h73;  // s
    12'h02c : ascii <= 8'h74;  // t
    12'h03c : ascii <= 8'h75;  // u
    12'h02a : ascii <= 8'h76;  // v
    12'h01d : ascii <= 8'h77;  // w
    12'h022 : ascii <= 8'h78;  // x
    12'h035 : ascii <= 8'h79;  // y
    12'h01a : ascii <= 8'h7a;  // z
    12'h154 : ascii <= 8'h7b;  // {
    12'h15d : ascii <= 8'h7c;  // |
    12'h15b : ascii <= 8'h7d;  // }
    12'h10e : ascii <= 8'h7e;  // ~
    12'h?71 : ascii <= 8'h7f;  // (Delete OR DEL on numeric keypad)
    default : ascii <= 8'h2e;  // '.' used for unlisted characters.
  endcase
end


endmodule

//`undefine TOTAL_BITS
//`undefine EXTEND_CODE
//`undefine RELEASE_CODE
//`undefine LEFT_SHIFT
//`undefine RIGHT_SHIFT

