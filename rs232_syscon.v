//-------------------------------------------------------------------------------------
//
// Author: John Clayton
// Date  : June 25, 2001
// Update: 6/25/01 copied this file from ps2_mouse.v (pared down).
// Update: 6/07/01 Finished initial coding efforts.
// Update: 7/19/01 First compilation.  Added master_br_o and master_bg_i;
// Update: 7/25/01 Testing.  Eliminated msg_active signal.  Changed serial.v
//                 to reflect new handshaking (i.e. "load_request" is now a
//                 periodic pulse of tx_clk_1x from rs232_tx...)
// Update: 7/30/01 Began coding m2 state machine.  Defined response codes.
// Update: 8/01/01 After some testing with m2, merged m2 into m1.  Eliminated
//                 response codes.
// Update: 8/02/01 Tested & measured the single "combined" state machine's
//                 performance, and "it was found wanting."  (The 49.152MHz
//                 clock frequency was too fast for it...)  Created clk_s
//                 at 49.152/2 MHz, and this worked.
// Update: 8/03/01 Added counter loop to "execute" and "bus_granted" states
//                 so that multiple bus cycles are generated, at sequential
//                 addresses.  However, the qty field is not cleared before
//                 being loaded with new characters, which causes problems.
// Update: 8/07/01 Finished debugging.  The read print formatting is now
//                 correct, and the unit appears to operate correctly.
//                 Many hours were spent puzzling over how to make this work.
//                 Removed port "debug".
// Update: 8/24/01 Added "master_stb_i" and "master_we_i" inputs and logic.
// Update: 12/13/01 For memory_sizer.v, I lowered the frequency of clk_s down
//                 to 49.152/4 MHz, so I changed the CLOCK_FACTOR from 8 to 4
//                 on the rs232 transciever, and this worked fine.
// Update: 9/09/02 Incorporated the "autobaud_with_tracking" module so that
//                 the serial clock is generated automatically, no matter
//                 what frequency clk_i is used.  The user simply needs to
//                 press "enter" from the terminal program to synchronize
//                 the baud rate generator.  Changing BAUD rates on the fly
//                 is also permitted, simply change to a new BAUD rate in the
//                 terminal program and hit enter.
// Update:11/26/02 Changed the string constants to binary representation
//                 (Just to eliminate warnings in XST.)
//
//
//
//
//
// Description
//-------------------------------------------------------------------------------------
// This is a state-machine driven rs232 serial port interface to a "Wishbone"
// type of bus.  It is intended to be used as a "Wishbone system controller"
// for debugging purposes.  Specifically, the unit allows the user to send
// text commands to the "rs232_syscon" unit, in order to generate read and
// write cycles on the Wishbone compatible bus.  The command structure is
// quite terse and spartan in nature, this is for the sake of the logic itself.
// Because the menu-driven command structure is supported without the use of
// dedicated memory blocks (in order to maintain cross-platform portability
// as much as possible) the menus and command responses were kept as small
// as possible.  In most cases, the responses from the unit to the user
// consist of a "newline" and one or two visible characters.  The command
// structure consists of the following commands and responses:
//
// Command Syntax              Purpose
// ---------------             ---------------------------------------
// w aaaa dddd xx              Write data "dddd" starting at address "aaaa"
//                             perform this "xx" times at sequential addresses.
//                             (The quantity field is optional, default is 1).
// r aaaa xx                   Read data starting from address "aaaa."
//                             Perform this "xx" times at sequential addresses.
//                             (The quantity field is optional, default is 1).
// i                           Send a reset pulse to the system. (initialize).
//
// Response from rs232_syscon  Meaning
// --------------------------  ---------------------------------------
// OK                          Command received and performed.  No errors.
// ?                           Command buffer full, without receiving "enter."
// C?                          Command not recognized.
// A?                          Address field syntax error.
// D?                          Data field syntax error.
// Q?                          Quantity field syntax error.
// !                           No "ack_i", or else "err_i" received from bus.
// B!                          No "bg_i" received from master.
//
// NOTES on the operation of this unit:
//
// - The unit generates a command prompt which is "-> ".
// - Capitalization is not important.
// - Each command is terminated by the "enter" key (0x0d character).
//   Commands are executed as soon as "enter" is received.
// - Trailing parameters need not be re-entered.  Their values will
//   remain the same as their previous settings.
// - Use of the backspace key is supported, so mistakes can be corrected.
// - The length of the command line is limited to a fixed number of
//   characters, as configured by parameter.
// - Fields are separated by white space, including "tab" and/or "space"
// - All numerical fields are interpreted as hexadecimal numbers.
//   Decimal is not supported.
// - Numerical field values are retained between commands.  If a "r" is issued
//   without any fields following it, the previous values will be used.  A
//   set of "quantity" reads will take place at sequential addresses.
//   If a "w" is issued without any fields following it, the previous data
//   value will be written "quantity" times at sequential addresses, starting
//   from the next location beyond where the last command ended.
// - If the user does not wish to use "ack" functionality, simply tie the
//   "ack_i" input to 1b'1, and then the ! response will never be generated.
// - The data which is read in by the "r" command is displayed using lines
//   which begin with the address, followed by the data fields.  The number
//   of data fields displayed per line (following the address) is adjustable
//   by setting a parameter.  No other display format adjustments can be made.
// - There is currently only a single watchdog timer.  It begins to count at
//   the time a user hits "enter" to execute a command.  If the bus is granted
//   and the ack is received before the expiration of the timer, then the
//   cycle will complete normally.  Therefore, the watchdog timeout value
//   needs to include time for the request and granting of the bus, in
//   addition to the time needed for the actual bus cycle to complete.
//
//
// Currently, there is only a single indicator (stb_o) generated during bus
// output cycles which are generated from this unit.
// The user can easily implement decoding logic based upon adr_o and stb_o
// which would serve as multiple "stb_o" type signals for different cores
// which would be sharing the same bus.
//
// The dat_io bus supported by this module is a tri-state type of bus.  The
// Wishbone spec. allows for this type of bus (see Wishbone spec. pg. 66).
// However, if separate dat_o and dat_i busses are desired, they can be added
// to the module without too much trouble.  Supposedly the only difference
// between the two forms of data bus is that one of them avoids using tri-state
// at the cost of doubling the number of interconnects used to carry data back
// and forth...  Some people say that tri-state should be avoided for use
// in internal busses in ASICs.  Maybe they are right.
// But in FPGAs tri-state seems to work pretty well, even for internal busses.
//
// Parameters are provided to configure the width of the different command
// fields.  To simplify the logic for binary to hexadecimal conversion, these
// parameters allow adjustment in units of 1 hex digit, not anything smaller.
// If your bus has 10 bits, for instance, simply set the address width to 3
// which produces 12 bits, and then just don't use the 2 msbs of address
// output.
//
// No support for the optional Wishbone "retry" (rty_i) input is provided at
// this time.
// No support for "tagn_o" bits is provided at this time, although a register
// might be added external to this module in order to implement to tag bits.
// No BLOCK or RMW cycles are supported currently, so cyc_o is equivalent to
// stb_o...
// The output busses are not tri-stated.  The user may add tri-state buffers
// external to the module, using "stb_o" to enable the buffer outputs.
//
//-------------------------------------------------------------------------------------


`define NIBBLE_SIZE 4        // Number of bits in one nibble

// The command register has these values
`define CMD_0 0              // Unused command
`define CMD_I 1              // Initialize (or reset)
`define CMD_R 2              // Read
`define CMD_W 3              // Write

module rs232_syscon (
  clk_i,
  reset_i,
  ack_i,
  err_i,
  master_bg_i,
  master_adr_i,
  master_stb_i,
  master_we_i,
  rs232_rxd_i,
  dat_io,
  rst_o,
  master_br_o,
  stb_o,
  cyc_o,
  adr_o,
  we_o,
  rs232_txd_o
  );


// Parameters

// The timer value can be from [0 to (2^WATCHDOG_TIMER_BITS_PP)-1] inclusive.
// RD_FIELDS_PP can be from [0 to (2^RD_FIELD_CTR_BITS_PP)-1] inclusive.
// Ensure that (2^CHAR_COUNT_BITS_PP) >= CMD_BUFFER_SIZE_PP.
// The setting of CMD_BUFFER_SIZE_PP should be large enough to hold the
// largest command, obviously.
// Ensure that (2^RD_DIGIT_COUNT_BITS_PP) is greater than or equal to the
//     larger of {ADR_DIGITS_PP,DAT_DIGITS_PP}.
parameter ADR_DIGITS_PP = 4;             // # of hex digits for address.
parameter DAT_DIGITS_PP = 4;             // # of hex digits for data.
parameter QTY_DIGITS_PP = 2;             // # of hex digits for quantity.
parameter CMD_BUFFER_SIZE_PP = 32;       // # of chars in the command buffer.
parameter CMD_PTR_BITS_PP = 4;           // # of Bits in command buffer ptr.
parameter WATCHDOG_TIMER_VALUE_PP = 200; // # of sys_clks before ack expected.
parameter WATCHDOG_TIMER_BITS_PP  = 8;   // # of bits needed for timer.
parameter RD_FIELDS_PP = 8;              // # of fields/line (when qty > 1).
parameter RD_FIELD_COUNT_BITS_PP = 3;    // # of bits in the fields counter.
parameter RD_DIGIT_COUNT_BITS_PP = 2;    // # of bits in the digits counter.


// State encodings, provided as parameters
// for flexibility to the one instantiating the module.
// In general, the default values need not be changed.

// There is one state machines: m1.
// "default" state upon power-up and configuration is:
//    "m1_initial_state"

parameter m1_initial_state = 5'h00;
parameter m1_send_ok = 5'h01;                    // Sends OK
parameter m1_send_prompt = 5'h02;                // Sends "-> "
parameter m1_check_received_char = 5'h03;
parameter m1_send_crlf = 5'h04;                  // Sends cr,lf
parameter m1_parse_error_indicator_crlf = 5'h05; // Sends cr,lf
parameter m1_parse_error_indicator = 5'h06;      // Sends ?
parameter m1_ack_error_indicator = 5'h07;        // Sends !
parameter m1_bg_error_indicator = 5'h08;         // Sends B!
parameter m1_cmd_error_indicator = 5'h09;        // Sends C?
parameter m1_adr_error_indicator = 5'h0a;        // Sends A?
parameter m1_dat_error_indicator = 5'h0b;        // Sends D?
parameter m1_qty_error_indicator = 5'h0c;        // Sends Q?
parameter m1_scan_command = 5'h10;
parameter m1_scan_adr_whitespace = 5'h11;
parameter m1_get_adr_field = 5'h12;
parameter m1_scan_dat_whitespace = 5'h13;
parameter m1_get_dat_field = 5'h14;
parameter m1_scan_qty_whitespace = 5'h15;
parameter m1_get_qty_field = 5'h16;
parameter m1_start_execution = 5'h17;
parameter m1_request_bus = 5'h18;
parameter m1_bus_granted = 5'h19;
parameter m1_execute = 5'h1a;
parameter m1_rd_send_adr_sr = 5'h1b;
parameter m1_rd_send_separator = 5'h1c;
parameter m1_rd_send_dat_sr = 5'h1d;
parameter m1_rd_send_space = 5'h1e;
parameter m1_rd_send_crlf = 5'h1f;

// I/O declarations
input clk_i;                 // System clock input
input reset_i;               // Reset signal for this module
input ack_i;                 // Ack input from Wishbone "slaves"
input err_i;                 // Err input from Wishbone "slaves"
input master_bg_i;           // Bus Grant (grants this module the bus)
                             // Address bus input from "normal" Wishbone
                             // master (i.e. from processor)
input [`NIBBLE_SIZE*ADR_DIGITS_PP-1:0] master_adr_i;
input master_stb_i;          // bus cycle signal from "normal" bus master
input master_we_i;           // write enable from "normal" bus master
input rs232_rxd_i;           // Serial data from debug host terminal.
                             // Data bus (tri-state, to save interconnect)
inout [`NIBBLE_SIZE*DAT_DIGITS_PP-1:0] dat_io;

output rst_o;                // Rst output to Wishbone "slaves"
output master_br_o;          // Bus request to normal master device.
output stb_o;                // Bus cycle indicator to Wishbone "slaves"
output cyc_o;                // Bus cycle indicator to Wishbone "slaves"
                             // Address bus output to Wishbone "slaves"
output [`NIBBLE_SIZE*ADR_DIGITS_PP-1:0] adr_o;
output we_o;                 // Write enable to Wishbone "slaves"
output rs232_txd_o;          // Serial transmit data to debug host terminal

reg rst_o;
reg master_br_o;

// Internal signal declarations
wire watchdog_timer_done;   // High when watchdog timer is expired
wire rd_addr_field_done;    // High when displayed addr field is complete
wire rd_data_field_done;    // High when displayed data field is complete
wire rd_line_done;          // High when displayed line is complete
wire char_is_enter;         // High when cmd_buffer[char_count] is enter.
wire char_is_whitespace;    // High when cmd_buffer[char_count] is whitespace.
wire char_is_num;           // High when cmd_buffer[char_count] is 0..9
wire char_is_a_f;           // High when cmd_buffer[char_count] is a..f
wire char_is_hex;           // High when cmd_buffer[char_count] is a hex char.
wire char_is_r;             // High when cmd_buffer[char_count] is r.
wire char_is_w;             // High when cmd_buffer[char_count] is w.
wire char_is_i;             // High when cmd_buffer[char_count] is i.
wire rx_char_is_enter;      // High when rs232_rx_char is enter.
wire rx_char_is_backspace;  // High when rs232_rx_char is backspace.
wire [4:0] msg_pointer;     // Determines message position or address.
wire [3:0] hex_digit;       // This is the digit to be stored.

reg rs232_echo;           // High == echo char's received.
reg [7:0] msg_char;       // Selected response message character.
reg [4:0] msg_base;       // Added to msg_offset to form msg_pointer.
reg [4:0] msg_offset;     // Offset from start of message.
reg reset_msg_offset;     // High == set message offset to zero
reg incr_msg_offset;      // Used for output messages.
reg cmd_i;                // Sets command.
reg cmd_r;                // Sets command.
reg cmd_w;                // Sets command.
reg shift_rd_adr;         // Shifts the rd_adr_sr by one character.
reg store_adr;            // Allows adr_sr to store hex_digit.
reg store_dat;            // Allows dat_sr to store hex_digit.
reg store_qty;            // Allows qty_sr to store hex_digit.
reg reset_adr;            // Clears adr_sr
reg reset_dat;            // Clears dat_sr
reg reset_qty;            // Clears qty_sr
reg init_qty;             // Sets qty_sr to 1
reg capture_dat;          // Puts dat_io into dat_sr for later display.

    // For the buses
wire [`NIBBLE_SIZE*ADR_DIGITS_PP-1:0] adr_ptr;  // = adr_sr + adr_offset

reg stb_l;      // "local" stb signal (to distinguish from stb_o)
reg we_l;       // "local" we  signal (to distinguish from we_o)

reg [`NIBBLE_SIZE*ADR_DIGITS_PP-1:0] rd_adr_sr; // sr for printing addresses
reg [`NIBBLE_SIZE*ADR_DIGITS_PP-1:0] adr_sr;    // "nibble" shift register
reg [`NIBBLE_SIZE*DAT_DIGITS_PP-1:0] dat_sr;    // "nibble" shift register
reg [`NIBBLE_SIZE*QTY_DIGITS_PP-1:0] qty_sr;    // "nibble" shift register
reg [1:0] command;
reg [`NIBBLE_SIZE*QTY_DIGITS_PP-1:0] adr_offset;   // counts from 0 to qty_sr
reg reset_adr_offset;
reg incr_adr_offset;

    // For the command buffer
reg [CMD_PTR_BITS_PP-1:0] cmd_ptr; // Offset from start of command.
reg reset_cmd_ptr;        // High == set command pointer to zero.
reg incr_cmd_ptr;         // Used for "write port" side of the command buffer
reg decr_cmd_ptr;         // Used for "write port" side of the command buffer
reg cmd_buffer_write;
reg [7:0] cmd_buffer [0:CMD_BUFFER_SIZE_PP-1];
wire [7:0] cmd_char;
wire [7:0] lc_cmd_char;   // Lowercase version of cmd_char

    // For the state machine
reg [4:0] m1_state;
reg [4:0] m1_next_state;

    // For various counters
reg reset_rd_field_count;
reg reset_rd_digit_count;
reg incr_rd_field_count;
reg incr_rd_digit_count;
reg [RD_FIELD_COUNT_BITS_PP-1:0] rd_field_count;  // "fields displayed"
reg [RD_DIGIT_COUNT_BITS_PP-1:0] rd_digit_count;  // "digits displayed"
reg [WATCHDOG_TIMER_BITS_PP-1:0] watchdog_timer_count;
reg reset_watchdog;

     // For the rs232 interface
wire serial_clk;
wire [2:0] rs232_rx_error;
wire rs232_tx_load;
wire rs232_tx_load_request;
wire rs232_rx_data_ready;
wire [7:0] rs232_rx_char;
wire [7:0] rs232_tx_char;   // Either rs232_rx_char or msg_char

//--------------------------------------------------------------------------
// Instantiations
//--------------------------------------------------------------------------


// These defines are for the rs232 interface
`define START_BITS 1
`define DATA_BITS 8
`define STOP_BITS 1
`define CLOCK_FACTOR 8

// This module generates a serial BAUD clock automatically.
// The unit synchronizes on the carriage return character, so the user
// only needs to press the "enter" key for serial communications to start
// working, no matter what BAUD rate and clk_i frequency are used!
auto_baud_with_tracking #(
                          `CLOCK_FACTOR,    // CLOCK_FACTOR_PP
                          16                // LOG2_MAX_COUNT_PP
                          )
  clock_unit_2
  (
  .clk_i(clk_i),
  .reset_i(reset_i),
  .serial_dat_i(rs232_rxd_i),
  .auto_baud_locked_o(),
  .baud_clk_o(serial_clk)
  );

// A transmitter, which asserts load_request at the end of the currently
// transmitted word.  The tx_clk must be a "clock enable" (narrow positive
// pulse) which occurs at 16x the desired transmit rate.  If load_request
// is connected directly to load, the unit will transmit continuously.
rs232tx #(
          `START_BITS,   // start_bits
          `DATA_BITS,    // data_bits
          `STOP_BITS,    // stop_bits (add intercharacter delay...)
          `CLOCK_FACTOR  // clock_factor
         )
         rs232_tx_block // instance name
         ( 
          .clk(clk_i),
          .tx_clk(serial_clk),
          .reset(reset_i),
          .load(rs232_tx_load),
          .data(rs232_tx_char),
          .load_request(rs232_tx_load_request),
          .txd(rs232_txd_o)
         );

// A receiver, which asserts "word_ready" to indicate a received word.
// Asserting "read_word" will cause "word_ready" to go low again if it was high.
// The character is held in the output register, during the time the next
//   character is coming in.
rs232rx #(
          `START_BITS,  // start_bits
          `DATA_BITS,   // data_bits
          `STOP_BITS,   // stop_bits
          `CLOCK_FACTOR // clock_factor
         )
         rs232_rx_block // instance name
         ( 
          .clk(clk_i),
          .rx_clk(serial_clk),
          .reset(reset_i || (| rs232_rx_error)),
          .rxd(rs232_rxd_i),
          .read(rs232_tx_load),
          .data(rs232_rx_char),
          .data_ready(rs232_rx_data_ready),
          .error_over_run(rs232_rx_error[0]),
          .error_under_run(rs232_rx_error[1]),
          .error_all_low(rs232_rx_error[2])
         );

//`undef START_BITS 
//`undef DATA_BITS 
//`undef STOP_BITS 
//`undef CLOCK_FACTOR


//--------------------------------------------------------------------------
// Module code
//--------------------------------------------------------------------------

assign adr_o = master_bg_i?adr_ptr:master_adr_i;
assign we_o = master_bg_i?we_l:master_we_i;
assign stb_o = master_bg_i?stb_l:master_stb_i;


assign dat_io = (master_bg_i && we_l && stb_l)?
                   dat_sr:{`NIBBLE_SIZE*DAT_DIGITS_PP{1'bZ}};
                   
// Temporary
assign cyc_o = stb_o;  // Separate cyc_o is not yet supported!


// This is the adress offset counter
always @(posedge clk_i)
begin
  if (reset_i || reset_adr_offset) adr_offset <= 0;
  else if (incr_adr_offset) adr_offset <= adr_offset + 1;
end
// This forms the adress pointer which is used on the bus.
assign adr_ptr = adr_sr + adr_offset;


// This is the ROM for the ASCII characters to be transmitted.
always @(msg_pointer)
begin
  case (msg_pointer) // synthesis parallel_case
    5'b00000 : msg_char <= 8'h30;  //  "0"; // Hexadecimal characters
    5'b00001 : msg_char <= 8'h31;  //  "1";
    5'b00010 : msg_char <= 8'h32;  //  "2";
    5'b00011 : msg_char <= 8'h33;  //  "3";
    5'b00100 : msg_char <= 8'h34;  //  "4";
    5'b00101 : msg_char <= 8'h35;  //  "5";
    5'b00110 : msg_char <= 8'h36;  //  "6";
    5'b00111 : msg_char <= 8'h37;  //  "7";
    5'b01000 : msg_char <= 8'h38;  //  "8";
    5'b01001 : msg_char <= 8'h39;  //  "9";
    5'b01010 : msg_char <= 8'h41;  //  "A"; // Address error indication
    5'b01011 : msg_char <= 8'h42;  //  "B";
    5'b01100 : msg_char <= 8'h43;  //  "C"; // Command error indication
    5'b01101 : msg_char <= 8'h44;  //  "D"; // Data error indication
    5'b01110 : msg_char <= 8'h45;  //  "E";
    5'b01111 : msg_char <= 8'h46;  //  "F";
    5'b10000 : msg_char <= 8'h20;  //  " "; // Space
    5'b10001 : msg_char <= 8'h3A;  //  ":"; // Colon
    5'b10010 : msg_char <= 8'h20;  //  " "; // Space
    5'b10011 : msg_char <= 8'h3F;  //  "?"; // Parse error indication
    5'b10100 : msg_char <= 8'h21;  //  "!"; // ack_i/err_i error indication
    5'b10101 : msg_char <= 8'h4F;  //  "O"; // "All is well" message
    5'b10110 : msg_char <= 8'h4B;  //  "K";
    5'b10111 : msg_char <= 8'h0D;  // Carriage return & line feed
    5'b11000 : msg_char <= 8'h0A;
    5'b11001 : msg_char <= 8'h2D;  //  "-"; // Command Prompt
    5'b11010 : msg_char <= 8'h3E;  //  ">";
    5'b11011 : msg_char <= 8'h20;  //  " ";
    5'b11100 : msg_char <= 8'h51;  //  "Q"; // Quantity error indication
    default  : msg_char <= 8'h3D;  //  "=";
  endcase
end

// This logic determines when to load a transmit character.
assign rs232_tx_load = rs232_echo?
  (rs232_rx_data_ready && rs232_tx_load_request):rs232_tx_load_request;

// This is the counter for incrementing, decrementing or resetting the 
// message pointer.
always @(posedge clk_i)
begin
  if (reset_i || reset_msg_offset) msg_offset <= 0;
  else if (incr_msg_offset) msg_offset <= msg_offset + 1;
end
assign msg_pointer = msg_offset + msg_base;



// This is the mux which selects whether to echo back the characters
// received (as during the entering of a command) or to send back response
// characters.
assign rs232_tx_char = (rs232_echo)?rs232_rx_char:msg_char;


// These assigments are for detecting whether the received rs232 character is
// anything of special interest.
assign rx_char_is_enter = (rs232_rx_char == 8'h0d);
assign rx_char_is_backspace = (rs232_rx_char == 8'h08);



// This is state machine m1.  It handles receiving the command line, including
// backspaces, and prints error/response messages.  It also parses and
// executes the commands.

// State register
always @(posedge clk_i)
begin : m1_state_register
  if (reset_i) m1_state <= m1_initial_state; // perform reset for rest of system
  else m1_state <= m1_next_state;
end

// State transition logic
always @(m1_state
         or rx_char_is_enter
         or rx_char_is_backspace
         or msg_offset
         or cmd_ptr
         or rs232_tx_load
         or char_is_whitespace
         or char_is_hex
         or char_is_enter
         or char_is_i
         or char_is_r
         or char_is_w
         or command
         or master_bg_i
         or watchdog_timer_done
         or err_i
         or ack_i
         or adr_offset
         or qty_sr
         or dat_sr
         or rd_adr_sr
         or rd_field_count
         or rd_digit_count
         )
begin : m1_state_logic

  // Default values for outputs.  The individual states can override these.
  msg_base <= 5'b0;
  reset_msg_offset <= 0;
  incr_msg_offset <= 0;
  rs232_echo <= 0;
  rst_o <= 0;
  we_l <= 0;
  stb_l <= 0;
  cmd_buffer_write <= 0;
  reset_cmd_ptr <= 0;
  incr_cmd_ptr <= 0;
  decr_cmd_ptr <= 0;
  master_br_o <= 0;
  cmd_r <= 0;
  cmd_w <= 0;
  cmd_i <= 0;
  shift_rd_adr <= 0;
  store_adr <= 0;          // enables storing hex chars in adr_sr (shift)
  store_dat <= 0;          // enables storing hex chars in dat_sr (shift)
  store_qty <= 0;          // enables storing hex chars in qty_sr (shift)
  reset_adr <= 0;
  reset_dat <= 0;
  reset_qty <= 0;
  init_qty <= 0;
  capture_dat <= 0;        // enables capturing bus data in dat_sr (load)
  incr_adr_offset <= 0;
  reset_adr_offset <= 0;
  reset_watchdog <= 0;
  incr_rd_field_count <= 0;
  incr_rd_digit_count <= 0;
  reset_rd_field_count <= 0;
  reset_rd_digit_count <= 0;

  case (m1_state) // synthesis parallel_case

    m1_initial_state :
      begin
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 15) && rs232_tx_load) begin
          m1_next_state <= m1_send_prompt;
          reset_msg_offset <= 1;
        end
        else m1_next_state <= m1_initial_state;
      end

    m1_send_ok :
      begin
        msg_base <= 5'b10101;     // Address of the OK message
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 1) && rs232_tx_load) begin
          m1_next_state <= m1_send_prompt;
          reset_msg_offset <= 1;
        end
        else m1_next_state <= m1_send_ok;
      end

    m1_send_prompt :
      begin
        msg_base <= 5'b10111;     // Address of the cr,lf,prompt message
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 4) && rs232_tx_load) begin
          m1_next_state <= m1_check_received_char;
          reset_cmd_ptr <= 1;
        end
        else m1_next_state <= m1_send_prompt;
      end

    // This state always leads to activating the parser...
    m1_send_crlf :
      begin
        msg_base <= 5'b10111;     // Address of the cr/lf message
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 1) && rs232_tx_load) begin
          m1_next_state <= m1_scan_command;
          reset_cmd_ptr <= 1;
        end
        else m1_next_state <= m1_send_crlf;
      end

    m1_check_received_char :
      begin
        rs232_echo <= 1;          // Allow echoing of characters
        if (rx_char_is_backspace && rs232_tx_load)
        begin
          m1_next_state <= m1_check_received_char;
          decr_cmd_ptr <= 1;     // This effectively eliminates the last char
        end
        else if (rx_char_is_enter && rs232_tx_load)
        begin
          m1_next_state <= m1_send_crlf;
          cmd_buffer_write <= 1;  // Store the enter as "marker" for parsing
          reset_msg_offset <= 1;
        end
        else if (rs232_tx_load && (cmd_ptr == CMD_BUFFER_SIZE_PP-1))
        begin
          m1_next_state <= m1_parse_error_indicator_crlf;
          reset_msg_offset <= 1;
          reset_cmd_ptr <= 1;
        end
        else if (rs232_tx_load)
        begin
          incr_cmd_ptr <= 1;
          cmd_buffer_write <= 1;
          m1_next_state <= m1_check_received_char;
        end
        else m1_next_state <= m1_check_received_char;
      end

    m1_bg_error_indicator :
      begin
        msg_base <= 5'b01011;    // Address of the B character
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 0) && rs232_tx_load) begin
          m1_next_state <= m1_ack_error_indicator;
          reset_msg_offset <= 1;
        end
        else m1_next_state <= m1_bg_error_indicator;
      end

    m1_ack_error_indicator :
      begin
        msg_base <= 5'b10100;    // Address of the ! error message
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 0) && rs232_tx_load) begin
          m1_next_state <= m1_send_prompt;
          reset_msg_offset <= 1;
        end
        else m1_next_state <= m1_ack_error_indicator;
      end

    // This state is used when the line is too long...
    m1_parse_error_indicator_crlf :
      begin
        msg_base <= 5'b10111;    // Address of the cr,lf message.
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 1) && rs232_tx_load) begin
          m1_next_state <= m1_parse_error_indicator;
          reset_msg_offset <= 1;
        end
        else m1_next_state <= m1_parse_error_indicator_crlf;
      end

    m1_parse_error_indicator :
      begin
        msg_base <= 5'b10011;    // Address of the ? message.
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 0) && rs232_tx_load) begin
          m1_next_state <= m1_send_prompt;
          reset_msg_offset <= 1;
        end
        else m1_next_state <= m1_parse_error_indicator;
      end

    m1_cmd_error_indicator :
      begin
        msg_base <= 5'b01100;    // Address of 'C'
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 0) && rs232_tx_load) begin
          m1_next_state <= m1_parse_error_indicator;
          reset_msg_offset <= 1;
        end
        else m1_next_state <= m1_cmd_error_indicator;
      end

    m1_adr_error_indicator :
      begin
        msg_base <= 5'b01010;    // Address of 'A'
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 0) && rs232_tx_load)
        begin
          m1_next_state <= m1_parse_error_indicator;
          reset_msg_offset <= 1;
        end
        else m1_next_state <= m1_adr_error_indicator;
      end

    m1_dat_error_indicator :
      begin
        msg_base <= 5'b01101;    // Address of 'D'
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 0) && rs232_tx_load)
        begin
          m1_next_state <= m1_parse_error_indicator;
          reset_msg_offset <= 1;
        end
        else m1_next_state <= m1_dat_error_indicator;
      end

    m1_qty_error_indicator :
      begin
        msg_base <= 5'b11100;    // Address of 'Q'
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 0) && rs232_tx_load)
        begin
          m1_next_state <= m1_parse_error_indicator;
          reset_msg_offset <= 1;
        end
        else m1_next_state <= m1_qty_error_indicator;
      end

    // The following states are for parsing and executing the command.

    // This state takes care of leading whitespace before the command
    m1_scan_command :
      begin
        rs232_echo <= 1;          // Don't send message characters
        reset_msg_offset <= 1;    // This one reset should cover all of the
                                  // parse/exec. states.  With rs232_echo
                                  // on, and no receive characters arrive,
                                  // then the msg_offset will remain reset.
                                  // This means the watchdog timer can take
                                  // a long time, if need be, during exec.
                                  // (NOTE: It might be better to disable
                                  //  the echoing of rx chars during these
                                  //  states.)
        init_qty <= 1;         // Set qty = 1 by default.  That can be
                               // overridden later, if the command has
                               // a different qty field.
        if (char_is_whitespace) begin
          m1_next_state <= m1_scan_command;
          incr_cmd_ptr <= 1;
        end
        else if (char_is_r) begin
          m1_next_state <= m1_scan_adr_whitespace;
          incr_cmd_ptr <= 1;
          cmd_r <= 1;
        end
        else if (char_is_w) begin
          m1_next_state <= m1_scan_adr_whitespace;
          incr_cmd_ptr <= 1;
          cmd_w <= 1;
        end
        else if (char_is_i) begin
          m1_next_state <= m1_start_execution;
          cmd_i <= 1;
        end
        else m1_next_state <= m1_cmd_error_indicator;
      end

    // The only way to determine the end of a valid field is to find
    // whitespace.  Therefore, char_is_whitespace must be used as an exit
    // condition from the "get_xxx_field" states.  So, this state is used to
    // scan through any leading whitespace prior to it.
    m1_scan_adr_whitespace :
      begin
        rs232_echo <= 1;          // Don't send message characters
        if (char_is_whitespace) begin
          m1_next_state <= m1_scan_adr_whitespace;
          incr_cmd_ptr <= 1;
        end
        else if (char_is_enter) m1_next_state <= m1_start_execution;
        else begin
          m1_next_state <= m1_get_adr_field;
          reset_adr <= 1;
        end
      end

    m1_get_adr_field :
      begin
        rs232_echo <= 1;          // Don't send message characters
        if (char_is_hex) begin
          m1_next_state <= m1_get_adr_field;
          store_adr <= 1;
          incr_cmd_ptr <= 1;
        end
        else if (char_is_whitespace) begin            // Normal exit
          m1_next_state <= m1_scan_dat_whitespace;
        end
        else if (char_is_enter) m1_next_state <= m1_start_execution;
        else m1_next_state <= m1_adr_error_indicator;
      end

    m1_scan_dat_whitespace :
      begin
        rs232_echo <= 1;          // Don't send message characters
        // There is no DAT field for reads, so skip it.
        if (command == `CMD_R) m1_next_state <= m1_scan_qty_whitespace;
        else if (char_is_whitespace) begin
          m1_next_state <= m1_scan_dat_whitespace;
          incr_cmd_ptr <= 1;
        end
        else if (char_is_enter) m1_next_state <= m1_start_execution;
        else begin
          m1_next_state <= m1_get_dat_field;
          reset_dat <= 1;
        end
      end

    m1_get_dat_field :
      begin
        rs232_echo <= 1;          // Don't send message characters
        if (char_is_hex) begin
          m1_next_state <= m1_get_dat_field;
          store_dat <= 1;
          incr_cmd_ptr <= 1;
        end
        else if (char_is_whitespace) begin            // Normal exit
          m1_next_state <= m1_scan_qty_whitespace;
        end
        else if (char_is_enter) m1_next_state <= m1_start_execution;
        else m1_next_state <= m1_dat_error_indicator;
      end

    m1_scan_qty_whitespace :
      begin
        rs232_echo <= 1;          // Don't send message characters
        if (char_is_whitespace) begin
          m1_next_state <= m1_scan_qty_whitespace;
          incr_cmd_ptr <= 1;
        end
        else if (char_is_enter) m1_next_state <= m1_start_execution;
        else begin
          m1_next_state <= m1_get_qty_field;
          reset_qty <= 1;
        end
      end

    m1_get_qty_field :
      begin
        rs232_echo <= 1;          // Don't send message characters
        if (char_is_hex) begin
          m1_next_state <= m1_get_qty_field;
          store_qty <= 1;
          incr_cmd_ptr <= 1;
        end
        else if (char_is_whitespace || char_is_enter) begin  // Normal exit
          m1_next_state <= m1_start_execution;
        end
        else m1_next_state <= m1_qty_error_indicator;
      end

    // This state seeks to obtain master_bg_i, which grants the bus to
    // rs232_syscon.
    m1_start_execution :
      begin
        rs232_echo <= 1;           // Don't send message characters
        reset_watchdog <= 1;       // Reset the timer.
        reset_adr_offset <= 1;     // Reset the address offset.
        reset_rd_field_count <= 1; // Reset the rd_field_count.
        m1_next_state <= m1_request_bus;
      end

    m1_request_bus :
      begin
        rs232_echo <= 1;          // Don't send message characters
        master_br_o <= 1;         // Request the bus.
        if (master_bg_i) m1_next_state <= m1_bus_granted;
        else if (watchdog_timer_done) begin
          m1_next_state <= m1_bg_error_indicator;
        end
        else m1_next_state <= m1_request_bus;
      end

    m1_bus_granted :
      begin
        rs232_echo <= 1;          // Don't send message characters
        master_br_o <= 1;         // Keep holding the bus
        reset_watchdog <= 1;      // Reset the timer.
        if (adr_offset != qty_sr) m1_next_state <= m1_execute;
        else m1_next_state <= m1_send_ok;
      end

    // This single state does reset/write/read depending upon the value
    // contained in "command"!
    m1_execute :
      begin
        rs232_echo <= 1;          // Don't send message characters
        master_br_o <= 1;         // Keep holding the bus
        stb_l <= 1'b1;            // Show that a bus cycle is happening
        case (command)            // Assert the appropriate signals
          `CMD_I : rst_o <= 1;
          `CMD_R : capture_dat <= ack_i;
          `CMD_W : we_l <= 1;
          default: ;
        endcase
        if (watchdog_timer_done || err_i) begin
          m1_next_state <= m1_ack_error_indicator;
        end
        else if (ack_i
                 && (command == `CMD_R)
                 && (rd_field_count == 0)
                 )
        begin
          m1_next_state <= m1_rd_send_adr_sr; // Leads to a new address line.
          reset_rd_digit_count <= 1;
          incr_adr_offset <= 1;               // move to the next address
        end
        else if (ack_i && (command == `CMD_R)) begin
          m1_next_state <= m1_rd_send_dat_sr; // Leads to a new data field.
          reset_rd_digit_count <= 1;
          reset_msg_offset <= 1;
          incr_adr_offset <= 1;             // move to the next address
        end
        else if (ack_i) begin
          m1_next_state <= m1_bus_granted;  // continue to the next cycle
          incr_adr_offset <= 1;             // move to the next address
        end
        else m1_next_state <= m1_execute;
      end

    m1_rd_send_adr_sr :
      begin
        msg_base <= {1'b0,rd_adr_sr[`NIBBLE_SIZE*ADR_DIGITS_PP-1:
                                    `NIBBLE_SIZE*(ADR_DIGITS_PP-1)]};
        if ((rd_digit_count == ADR_DIGITS_PP-1) && rs232_tx_load) begin
          m1_next_state <= m1_rd_send_separator;
          reset_msg_offset <= 1;
        end
        else if (rs232_tx_load) begin
          shift_rd_adr <= 1;
          incr_rd_digit_count <= 1;
          m1_next_state <= m1_rd_send_adr_sr;
        end
        else m1_next_state <= m1_rd_send_adr_sr;
      end

    m1_rd_send_separator :
      begin
        msg_base <= 5'b10000;    // Address of the separator message
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 2) && rs232_tx_load)
        begin
          m1_next_state <= m1_rd_send_dat_sr;
          reset_rd_digit_count <= 1;
          reset_msg_offset <= 1;
        end
        else m1_next_state <= m1_rd_send_separator;
      end

    m1_rd_send_dat_sr :
      begin
        msg_base <= {1'b0,dat_sr[`NIBBLE_SIZE*DAT_DIGITS_PP-1:
                                 `NIBBLE_SIZE*(DAT_DIGITS_PP-1)]};
        if (
            (rd_digit_count == DAT_DIGITS_PP-1)
            && (rd_field_count == RD_FIELDS_PP-1)
            && rs232_tx_load
            )
        begin
          m1_next_state <= m1_rd_send_crlf;
          reset_rd_field_count <= 1;
        end
        else if ((rd_digit_count == DAT_DIGITS_PP-1) && rs232_tx_load) begin
          m1_next_state <= m1_rd_send_space;
          incr_rd_field_count <= 1;
        end
        else if (rs232_tx_load) begin
            store_dat <= 1;
            incr_rd_digit_count <= 1;
            m1_next_state <= m1_rd_send_dat_sr;
        end
        else m1_next_state <= m1_rd_send_dat_sr;
      end

    m1_rd_send_space :
      begin
        msg_base <= 5'b10000;    // Address of the space
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 0) && rs232_tx_load) begin
          m1_next_state <= m1_bus_granted;
          reset_msg_offset <= 1;
        end
        else m1_next_state <= m1_rd_send_space;
      end

    m1_rd_send_crlf :
      begin
        msg_base <= 5'b10111;     // Address of the cr/lf message
        incr_msg_offset <= rs232_tx_load;
        if ((msg_offset == 1) && rs232_tx_load) begin
          m1_next_state <= m1_bus_granted;
          reset_msg_offset <= 1;
        end
        else m1_next_state <= m1_rd_send_crlf;
      end

    default : m1_next_state <= m1_initial_state;
  endcase
end


// This is the counter for incrementing or loading the cmd_ptr
always @(posedge clk_i)
begin
  if (reset_i || reset_cmd_ptr) cmd_ptr <= 0;
  else if (decr_cmd_ptr) cmd_ptr <= cmd_ptr - 1;
  else if (incr_cmd_ptr) cmd_ptr <= cmd_ptr + 1;
end


// This is the command buffer writing section
always @(posedge clk_i)
begin
  if (rs232_echo && cmd_buffer_write) cmd_buffer[cmd_ptr] <= rs232_rx_char;
end
// This is the command buffer reading section
assign cmd_char = cmd_buffer[cmd_ptr];
assign lc_cmd_char = (cmd_buffer[cmd_ptr] | 8'h20); // lowercase



// These assigments are for detecting whether the cmd_char is
// anything of special interest.
assign char_is_enter = (cmd_char == 8'h0d);          // enter
assign char_is_whitespace = (
                                (cmd_char == 8'h20)  // space
                             || (cmd_char == 8'h09)  // tab
                             );
assign char_is_num = ((cmd_char>=8'h30)&&(cmd_char<=8'h39));
assign char_is_a_f = ((lc_cmd_char>=8'h61)&&(lc_cmd_char<=8'h66));
assign char_is_hex = ( char_is_num || char_is_a_f );
assign char_is_r = (lc_cmd_char == 8'h72); // "r"
assign char_is_w = (lc_cmd_char == 8'h77); // "w"
assign char_is_i = (lc_cmd_char == 8'h69); // "i"

assign hex_digit = char_is_num?cmd_char[3:0]:(cmd_char[3:0]+9);

// This is the command register.  It stores the type of command to execute.
// This is so that the state machine can parse address, data and qty
// into "generic" storage locations, and then when it executes the command,
// it refers back to this register in order to determine what type of
// operation to perform.

always @(posedge clk_i)
begin
  if (reset_i) command <= `CMD_0;
  else if (cmd_i) command <= `CMD_I;
  else if (cmd_r) command <= `CMD_R;
  else if (cmd_w) command <= `CMD_W;
end

// This is the "nibble" shift register for the address which is sent character
// by character to the user.  It is loaded each time the adr_offset is
// incremented, in order to save the previous address for use in printing
// to the user.
always @(posedge clk_i)
begin
  if (reset_i || reset_adr) rd_adr_sr <= 0;
  else if (incr_adr_offset) rd_adr_sr <= adr_ptr;
  else if (shift_rd_adr) begin
    rd_adr_sr[`NIBBLE_SIZE*ADR_DIGITS_PP-1:`NIBBLE_SIZE] <=
      rd_adr_sr[`NIBBLE_SIZE*(ADR_DIGITS_PP-1)-1:0];
    rd_adr_sr[`NIBBLE_SIZE-1:0] <= {`NIBBLE_SIZE{1'b0}};
  end
end

// These are the "nibble" shift registers.  They handle loading the
// hexadecimal digits from the command line.
always @(posedge clk_i)
begin
  if (reset_i || reset_adr) adr_sr <= 0;
  else if (store_adr) begin
    adr_sr[`NIBBLE_SIZE*ADR_DIGITS_PP-1:`NIBBLE_SIZE] <=
      adr_sr[`NIBBLE_SIZE*(ADR_DIGITS_PP-1)-1:0];
    adr_sr[`NIBBLE_SIZE-1:0] <= hex_digit;
  end
end

always @(posedge clk_i)
begin
  if (reset_i || reset_dat) dat_sr <= 0;
  else if (capture_dat) dat_sr <= dat_io;
  else if (store_dat) begin
    dat_sr[`NIBBLE_SIZE*DAT_DIGITS_PP-1:`NIBBLE_SIZE] <=
      dat_sr[`NIBBLE_SIZE*(DAT_DIGITS_PP-1)-1:0];
    dat_sr[`NIBBLE_SIZE-1:0] <= hex_digit;
  end
end

always @(posedge clk_i)
begin
  if (reset_i || reset_qty) qty_sr <= 0;
  else if (init_qty) qty_sr <= 1;
  else if (store_qty) begin
    qty_sr[`NIBBLE_SIZE*QTY_DIGITS_PP-1:`NIBBLE_SIZE] <=
      qty_sr[`NIBBLE_SIZE*(QTY_DIGITS_PP-1)-1:0];
    qty_sr[`NIBBLE_SIZE-1:0] <= hex_digit;
  end
end

// This is the rd_digit_count counter.  It is used for counting digits
// displayed of both the adr_sr and dat_sr, so it must be able to count up
// to the extent of the larger of the two...
always @(posedge clk_i)
begin
  if (reset_i || reset_rd_digit_count) rd_digit_count <= 0;
  else if (incr_rd_digit_count) rd_digit_count <= rd_digit_count + 1;
end

// This is the rd_field_count counter.  It is used for counting dat_sr fields
// displayed per line.
always @(posedge clk_i)
begin
  if (reset_i || reset_rd_field_count) rd_field_count <= 0;
  else if (incr_rd_field_count) rd_field_count <= rd_field_count + 1;
end


// This is the watchdog timer counter
// The watchdog timer is always "enabled" to operate.
always @(posedge clk_i)
begin
  if (reset_i || reset_watchdog) watchdog_timer_count <= 0;
  else if (~watchdog_timer_done)
    watchdog_timer_count <= watchdog_timer_count + 1;
end
assign watchdog_timer_done = (watchdog_timer_count==WATCHDOG_TIMER_VALUE_PP);


endmodule


