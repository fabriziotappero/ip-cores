/**********************************************************************/
/*                                                                    */
/*                                                                    */
/*   Copyright (c) 2012 Ouabache Design Works                         */
/*                                                                    */
/*          All Rights Reserved Worldwide                             */
/*                                                                    */
/*   Licensed under the Apache License,Version2.0 (the'License');     */
/*   you may not use this file except in compliance with the License. */
/*   You may obtain a copy of the License at                          */
/*                                                                    */
/*       http://www.apache.org/licenses/LICENSE-2.0                   */
/*                                                                    */
/*   Unless required by applicable law or agreed to in                */
/*   writing, software distributed under the License is               */
/*   distributed on an 'AS IS' BASIS, WITHOUT WARRANTIES              */
/*   OR CONDITIONS OF ANY KIND, either express or implied.            */
/*   See the License for the specific language governing              */
/*   permissions and limitations under the License.                   */
/**********************************************************************/
 module 
  cde_jtag_tap 
    #( parameter 
      INST_LENGTH=4,
      INST_RETURN=4'b1101,
      INST_RESET=4'b1111,
      NUM_USER=2,
      USER=8'b1010_1001,
      EXTEST=4'b0000,
      SAMPLE=4'b0001,
      HIGHZ_MODE=4'b0010,
      CHIP_ID_ACCESS=4'b0011,
      CLAMP=4'b1000,
      RPC_DATA=4'b1010,
      RPC_ADD=4'b1001,
      BYPASS=4'b1111,
      CHIP_ID_VAL=32'h12345678)
     (
 input   wire                  tclk_pad_in,
 input   wire                  tdi_pad_in,
 input   wire                  tms_pad_in,
 input   wire                  trst_n_pad_in,
 output  wire                  tdo_pad_oe,
 output  wire                  tdo_pad_out,
 output   wire                 jtag_clk,
 output   wire                 update_dr_clk_o,
 output   wire                 shiftcapture_dr_clk_o,
 output   wire                 aux_jtag_clk,
 output   wire                 aux_update_dr_clk_o,
 output   wire                 aux_shiftcapture_dr_clk_o,
 output   reg                  test_logic_reset_o,
 output   wire                 aux_test_logic_reset_o,
 output   wire                 tdi_o,
 output   wire                 aux_tdi_o,
 input   wire                  tdo_i,
 input   wire                  aux_tdo_i,
 input   wire                  bsr_tdo_i,
 output   reg                  capture_dr_o,
 output   reg                  shift_dr_o,
 output   reg                  update_dr_o,
 output   wire                 aux_capture_dr_o,
 output   wire                 aux_shift_dr_o,
 output   wire                 aux_update_dr_o,
 output   reg                  tap_highz_mode,
 output   reg                  bsr_output_mode,
 output   wire                 select_o,
 output   wire                 aux_select_o,
 output   wire                    bsr_select_o
);
reg                        bypass_tdo;
reg                        capture_ir;
reg                        next_tdo;
reg                        shift_ir;
reg                        update_ir;
reg     [ 3 :  0]              next_tap_state;
reg     [ 3 :  0]              tap_state;
wire                        bypass_select;
wire                        chip_id_select;
wire                        chip_id_tdo;
wire                        clamp;
wire                        extest;
wire                        sample;
wire                        shift_capture_dr;
wire                        tclk;
wire                        tclk_n;
wire                        trst_pad_in;
wire                        jtag_shift_clk;
 assign      aux_jtag_clk               = jtag_clk;
 assign      aux_update_dr_clk_o        = update_dr_clk_o;
 assign      aux_shiftcapture_dr_clk_o  = shiftcapture_dr_clk_o;
 assign      aux_test_logic_reset_o     = test_logic_reset_o;
 assign      aux_tdi_o                  = tdi_o;
 assign      aux_capture_dr_o           = capture_dr_o;
 assign      aux_shift_dr_o             = shift_dr_o;
 assign      aux_update_dr_o            = update_dr_o;
////////////////////////////////////////////////////////////////
cde_clock_gater
clk_gater_jtag_shift_clk 
   (
   .atg_clk_mode    (1'b0),
   .clk_in          (tclk),
   .clk_out         (jtag_shift_clk),
   .enable          (shift_capture_dr));
cde_clock_gater
clk_gater_jtag_update_clk 
   (
   .atg_clk_mode    (1'b0),
   .clk_in          (tclk),
   .clk_out         (update_dr_clk_o),
   .enable          (update_dr_o));
cde_clock_gater
clk_gater_jtag_clk 
   (
   .atg_clk_mode    (1'b0),
   .clk_in          (tclk),
   .clk_out         (jtag_clk),
   .enable          (1'b1));
cde_jtag_rpc_in_reg
#( .BITS (32),
   .RESET_VALUE (CHIP_ID_VAL))
chip_id_reg 
   (
   .capture_dr       (capture_dr_o),
   .capture_value    (CHIP_ID_VAL),
   .clk              (jtag_clk),
   .reset            (trst_pad_in),
   .select           (chip_id_select),
   .shift_dr         (shift_dr_o),
   .tdi              (tdi_pad_in),
   .tdo              (chip_id_tdo));
//********************************************************************
//*** TAP Controller State Machine
//********************************************************************
// TAP state parameters
localparam TEST_LOGIC_RESET = 4'b1111, 
           RUN_TEST_IDLE    = 4'b1100,
           SELECT_DR_SCAN   = 4'b0111, 
           CAPTURE_DR       = 4'b0110,
           SHIFT_DR         = 4'b0010, 
           EXIT1_DR         = 4'b0001,
           PAUSE_DR         = 4'b0011,
           EXIT2_DR         = 4'b0000,
           UPDATE_DR        = 4'b0101,
           SELECT_IR_SCAN   = 4'b0100, 
           CAPTURE_IR       = 4'b1110,
           SHIFT_IR         = 4'b1010,
           EXIT1_IR         = 4'b1001,
           PAUSE_IR         = 4'b1011,
           EXIT2_IR         = 4'b1000,
           UPDATE_IR        = 4'b1101;
// next state decode for tap controller
always @(*)
    case (tap_state)	// synopsys parallel_case
      TEST_LOGIC_RESET: next_tap_state = tms_pad_in ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
      RUN_TEST_IDLE:    next_tap_state = tms_pad_in ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
      SELECT_DR_SCAN:   next_tap_state = tms_pad_in ? SELECT_IR_SCAN   : CAPTURE_DR;
      CAPTURE_DR:       next_tap_state = tms_pad_in ? EXIT1_DR         : SHIFT_DR;
      SHIFT_DR:         next_tap_state = tms_pad_in ? EXIT1_DR         : SHIFT_DR;
      EXIT1_DR:         next_tap_state = tms_pad_in ? UPDATE_DR        : PAUSE_DR;
      PAUSE_DR:         next_tap_state = tms_pad_in ? EXIT2_DR         : PAUSE_DR;
      EXIT2_DR:         next_tap_state = tms_pad_in ? UPDATE_DR        : SHIFT_DR;
      UPDATE_DR:        next_tap_state = tms_pad_in ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
      SELECT_IR_SCAN:   next_tap_state = tms_pad_in ? TEST_LOGIC_RESET : CAPTURE_IR;
      CAPTURE_IR:       next_tap_state = tms_pad_in ? EXIT1_IR         : SHIFT_IR;
      SHIFT_IR:         next_tap_state = tms_pad_in ? EXIT1_IR         : SHIFT_IR;
      EXIT1_IR:         next_tap_state = tms_pad_in ? UPDATE_IR        : PAUSE_IR;
      PAUSE_IR:         next_tap_state = tms_pad_in ? EXIT2_IR         : PAUSE_IR;
      EXIT2_IR:         next_tap_state = tms_pad_in ? UPDATE_IR        : SHIFT_IR;
      UPDATE_IR:        next_tap_state = tms_pad_in ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
    endcase
//********************************************************************
//*** TAP Controller State Machine Register
//********************************************************************
always @(posedge jtag_clk or negedge trst_n_pad_in)
  if (!trst_n_pad_in)     tap_state <= TEST_LOGIC_RESET;
  else             tap_state <= next_tap_state;
// Decode tap_state to get Shift, Update, and Capture signals
 always @(*)
   begin
   shift_ir     = (tap_state == SHIFT_IR);
   shift_dr_o   = (tap_state == SHIFT_DR);
   update_ir    = (tap_state == UPDATE_IR);
   update_dr_o  = (tap_state == UPDATE_DR);
   capture_dr_o = (tap_state == CAPTURE_DR);
   capture_ir   = (tap_state == CAPTURE_IR);
  end
// Decode tap_state to get test_logic_reset  signal
always @(posedge jtag_clk  or negedge trst_n_pad_in)
if (!trst_n_pad_in)                               test_logic_reset_o <= 1'b1;
else 
if (next_tap_state == TEST_LOGIC_RESET)    test_logic_reset_o <= 1'b1;
else                                       test_logic_reset_o <= 1'b0;
//******************************************************
//*** Instruction Register
//******************************************************
reg	[INST_LENGTH-1:0]      instruction_buffer;
reg	[INST_LENGTH-1:0]      instruction;
// buffer the instruction register while shifting
always @(posedge jtag_clk or negedge trst_n_pad_in)
  if (!trst_n_pad_in)          instruction_buffer <= INST_RESET;
  else 
  if (capture_ir)              instruction_buffer <= INST_RETURN;  
  else 
  if (shift_ir)                instruction_buffer <= {tdi_pad_in,instruction_buffer[INST_LENGTH-1:1]};
always @(posedge jtag_clk  or negedge trst_n_pad_in)
  if (!trst_n_pad_in)                   instruction <= INST_RESET;
  else 
  if (tap_state == TEST_LOGIC_RESET)    instruction <= INST_RESET;
  else 
  if (update_ir)                        instruction <= instruction_buffer;
assign tclk              =  tclk_pad_in;
assign tclk_n            = !tclk_pad_in;
assign shift_capture_dr  =  shift_dr_o || capture_dr_o;   
assign tdi_o             =  tdi_pad_in;   
assign trst_pad_in       = !trst_n_pad_in;
// Instruction Decoder
assign  extest          = ( instruction == EXTEST );
assign  sample          = ( instruction == SAMPLE );
assign  clamp           = ( instruction == CLAMP );
assign  chip_id_select  = ( instruction == CHIP_ID_ACCESS );
// bypass anytime we are not doing a defined instructions, or if in clamp or bypass mode
assign   bypass_select  = ( instruction == CLAMP ) || ( instruction == BYPASS );
assign  shiftcapture_dr_clk_o     =  jtag_shift_clk;
assign  select_o                  = ( instruction == RPC_ADD );
assign  aux_select_o              = ( instruction == RPC_DATA );
assign  bsr_select_o              = ( instruction == EXTEST ) || ( instruction == SAMPLE )       ;
//**********************************************************
//** Boundary scan control signals
//**********************************************************
always @(posedge jtag_clk  or negedge trst_n_pad_in)
  if (!trst_n_pad_in)                             bsr_output_mode <= 1'b0;
  else 
  if (tap_state == TEST_LOGIC_RESET)       bsr_output_mode <= 1'b0;
  else 
  if (update_ir)                           bsr_output_mode <=    (instruction_buffer  == EXTEST) 
                                                              || (instruction_buffer  == CLAMP);
// Control chip pads when we are in highz_mode
always @(posedge jtag_clk  or negedge trst_n_pad_in)
  if (!trst_n_pad_in)                                 tap_highz_mode <= 1'b0;
  else if (tap_state == TEST_LOGIC_RESET)      tap_highz_mode <= 1'b0;
  else if (update_ir)                          tap_highz_mode <= (instruction_buffer  == HIGHZ_MODE);
//**********************************************************
//*** Bypass register
//**********************************************************
always @(posedge jtag_clk or negedge trst_n_pad_in)
  if (!trst_n_pad_in)         bypass_tdo <= 1'b0;
  else 
  if (capture_dr_o)           bypass_tdo <= 1'b0;
  else 
  if (shift_dr_o)             bypass_tdo <= tdi_pad_in;
  else                        bypass_tdo <= bypass_tdo;
//****************************************************************
//*** Choose what goes out on the TDO pin
//****************************************************************
// output the instruction register when tap_state[3] is 1, else
//   put out the appropriate data register.  
always@(*)
  begin
     if( tap_state[3] )    next_tdo =  instruction_buffer[0];
     else
     if(bypass_select)     next_tdo =  bypass_tdo;
     else
     if(chip_id_select)    next_tdo =  chip_id_tdo;
     else
     if(select_o)         next_tdo =  tdo_i;
     else
     if(aux_select_o)         next_tdo =  aux_tdo_i;
     else                  next_tdo =  1'b0;
  end
reg tdo_pad_out_reg;
reg tdo_pad_oe_reg;
always @(posedge tclk_n or negedge trst_n_pad_in)
        if (!trst_n_pad_in)         tdo_pad_out_reg <= 1'b0;
        else                        tdo_pad_out_reg <= next_tdo;
// output enable for TDO pad
always @(posedge tclk_n or negedge trst_n_pad_in)
	if ( !trst_n_pad_in )    tdo_pad_oe_reg   <= 1'b0;
	else                     tdo_pad_oe_reg   <= ( (tap_state == SHIFT_DR) || (tap_state == SHIFT_IR) );
assign tdo_pad_out = tdo_pad_out_reg;
assign tdo_pad_oe  = tdo_pad_oe_reg;
reg [8*16-1:0] tap_string;
always @(tap_state) begin
   case (tap_state)
      TEST_LOGIC_RESET: tap_string = "TEST_LOGIC_RESET";
      RUN_TEST_IDLE:    tap_string = "RUN_TEST_IDLE";
      SELECT_DR_SCAN:   tap_string = "SELECT_DR_SCAN";
      CAPTURE_DR:       tap_string = "CAPTURE_DR";
      SHIFT_DR:         tap_string = "SHIFT_DR";
      EXIT1_DR:         tap_string = "EXIT1_DR";
      PAUSE_DR:         tap_string = "PAUSE_DR";
      EXIT2_DR:         tap_string = "EXIT2_DR";
      UPDATE_DR:        tap_string = "UPDATE_DR";
      SELECT_IR_SCAN:   tap_string = "SELECT_IR_SCAN";
      CAPTURE_IR:       tap_string = "CAPTURE_IR";
      SHIFT_IR:         tap_string = "SHIFT_IR";
      EXIT1_IR:         tap_string = "EXIT1_IR";
      PAUSE_IR:         tap_string = "PAUSE_IR";
      EXIT2_IR:         tap_string = "EXIT2_IR";
      UPDATE_IR:        tap_string = "UPDATE_IR";
      default:          tap_string = "-XXXXXX-";
   endcase
   $display("%t  %m   Tap State   = %s",$realtime, tap_string);
end
reg [8*16-1:0] inst_string;
always @(instruction) begin
   case (instruction)
      EXTEST: inst_string = "EXTEST";
      SAMPLE: inst_string = "SAMPLE";
      HIGHZ_MODE: inst_string = "HIGHZ_MODE";
      CHIP_ID_ACCESS: inst_string = "CHIP_ID_ACCESS";
      CLAMP: inst_string = "CLAMP";
      RPC_DATA: inst_string = "RPC_DATA";
      RPC_ADD: inst_string = "RPC_ADD";
      BYPASS: inst_string = "BYPASS";
      default:          inst_string = "-XXXXXX-";
   endcase
   $display("%t  %m   Instruction = %s",$realtime, inst_string);
end
  endmodule
