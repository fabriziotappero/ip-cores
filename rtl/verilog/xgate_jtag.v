////////////////////////////////////////////////////////////////////////////////
//
//  XGATE Coprocessor - XGATE JTAG Module
//
//  Author: Robert Hayes
//          rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/xgate.....
//
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2011, Robert Hayes
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

// -----------------------------------------------------------------------------
// JTAG TAP Controller
// -----------------------------------------------------------------------------
module xgate_jtag #(parameter IR_BITS = 4)    // Number of Instruction Register Bits
  (
    output  jtag_tdo,      // JTAG Serial Output Data
    output  jtag_tdo_en,   // JTAG Serial Output Data tri-state enable

    input   jtag_tdi,      // JTAG Serial Input Data
    input   jtag_clk,      // JTAG Test clock
    input   jtag_reset_n,  // JTAG Async reset signal
    input   jtag_tms,      // JTAG Test Mode Select

    output  extest,        // JTAG Command for I/O control
    output  clamp,         // JTAG Command for I/O control
    output  highz,         // JTAG Command for I/O control
    output  force_pul_lo,  // JTAG Command for I/O control
    output  force_pul_hi,  // JTAG Command for I/O control

    output  sel_bsd,       // JTAG select the boundary scan register
    output  sel_udi_1,     // JTAG select the udi_1 (testmode control) register

    output  capture_clk,   // Shift and input capture clock
    output  update_clk,    // Load holding register
    output  capture_dr,    // Enable shift/capture register input loading,
    output  update_dr,     // Enable holding register input loading
    output  shift_dr,      // Select eather shift mode or parallel capture mode
    input   bsd_so,        // Serial data input from boundary scan chain
    input   user1_so       // Serial data input from user register
  );


  wire [3:0] jtag_state;
  wire [3:0] next_jtag_state;

  wire [IR_BITS-1:0] ir_reg;



  // Define clocks here, future enhansment would be to add scan clock mux
  // update_clk is output I/O clock and control register capture clock
  // capture_clock is input I/O clock and shifting clock
  assign update_clk  = !jtag_clk;
  assign capture_clk = jtag_clk;

  // ---------------------------------------------------------------------------
  xgate_jtag_sm
    jtag_sm(
      .jtag_state(jtag_state),
      .next_jtag_state(next_jtag_state),
      .update_ir(update_ir),
      .capture_ir(capture_ir),
      .shift_ir(shift_ir),
      .update_dr(update_dr),
      .capture_dr(capture_dr),
      .shift_dr(shift_dr),
      .capture_clk(capture_clk),
      .jtag_reset_n(jtag_reset_n),
      .jtag_tms(jtag_tms)
    );

  // ---------------------------------------------------------------------------
  xgate_jtag_ir #(.IR_BITS(IR_BITS))
    jtag_ir(
      .ir_reg(ir_reg),
      .ir_so(ir_so),
      .capture_clk(capture_clk),
      .update_clk(update_clk),
      .update_ir(update_ir),
      .capture_ir(capture_ir),
      .shift_ir(shift_ir),
      .jtag_tdi(jtag_tdi),
      .jtag_reset_n(jtag_reset_n)
    );

  // ---------------------------------------------------------------------------
  xgate_instr_decode #(.IR_BITS(IR_BITS))
    decoder(
      .bypass(bypass),
      .clamp(clamp),
      .highz(highz),
      .extest(extest),
      .force_pul_lo(force_pul_lo),
      .force_pul_hi(force_pul_hi),
      .sample(sample),
      .idcode(idcode),
      .usercode(usercode),
      .udi_1(udi_1),

      .sel_bypass(sel_bypass),
      .sel_bsd(sel_bsd),
      .sel_id(sel_id),
      .sel_udi_1(sel_udi_1),

      .ir_reg(ir_reg)
    );

  // ---------------------------------------------------------------------------
  xgate_bypass_reg
    tdi_bypass(
      .bypass_so(bypass_so),

      .jtag_tdi(jtag_tdi),
      .capture_clk(capture_clk),
      .jtag_reset_n(jtag_reset_n)
    );

  // ---------------------------------------------------------------------------
  xgate_id_reg
    chip_id(
      .id_so(id_so),

      .jtag_tdi(jtag_tdi),
      .capture_clk(capture_clk),
      .capture_dr(capture_dr),
      .shift_dr(shift_dr),
      .idcode(idcode),
      .usercode(usercode),
      .jtag_reset_n(jtag_reset_n)
    );

  // ---------------------------------------------------------------------------
  xgate_tdo_mux
    tdo_out(
      .sel_bypass(sel_bypass),
      .sel_bsd(sel_bsd),
      .sel_id(sel_id),
      .sel_udi_1(sel_udi_1),

      .bypass_so(bypass_so),
      .bsd_so(bsd_so),
      .user1_so(user1_so),
      .id_so(id_so),
      .ir_so(ir_so),

      .shift_dr(shift_dr),
      .shift_ir(shift_ir),
      .update_clk(update_clk),
      .jtag_reset_n(jtag_reset_n),

      .jtag_tdo(jtag_tdo),
      .jtag_tdo_en(jtag_tdo_en)
    );

endmodule  // xgate_jtag


// -----------------------------------------------------------------------------
// JTAG TAP State Machine
// -----------------------------------------------------------------------------
module xgate_jtag_sm
  (
    output reg [3:0] jtag_state,        // JTAG State
    output reg [3:0] next_jtag_state,   // Pseudo Register for JTAG next state logic

    output           update_ir,
    output           capture_ir,
    output           shift_ir,

    output           update_dr,
    output           capture_dr,
    output           shift_dr,

    input            capture_clk,   // JTAG Test clock
    input            jtag_reset_n,  // JTAG Async reset signal
    input            jtag_tms       // JTAG Test Mode Select
  );

parameter RESET         = 4'hF,
          RUN_TEST_IDLE = 4'hC,
          SEL_DR_SCAN   = 4'h7,
          CAPTURE_DR    = 4'h6,
          SHIFT_DR      = 4'h2,
          EXIT1_DR      = 4'h1,
          PAUSE_DR      = 4'h3,
          EXIT2_DR      = 4'h0,
          UPDATE_DR     = 4'h5,
          SEL_IR_SCAN   = 4'h4,
          CAPTURE_IR    = 4'hE,
          SHIFT_IR      = 4'hA,
          EXIT1_IR      = 4'h9,
          PAUSE_IR      = 4'hB,
          EXIT2_IR      = 4'h8,
          UPDATE_IR     = 4'hD;

  assign update_ir  = jtag_state == UPDATE_IR;
  assign capture_ir = jtag_state == CAPTURE_IR;
  assign shift_ir   = jtag_state == SHIFT_IR;

  assign update_dr  = jtag_state == UPDATE_DR;
  assign capture_dr = jtag_state == CAPTURE_DR;
  assign shift_dr   = jtag_state == SHIFT_DR;


  // Define the JTAG State Register
  always @(posedge capture_clk or negedge jtag_reset_n)
    if (!jtag_reset_n)
      jtag_state <= RESET;
    else
      jtag_state <= next_jtag_state;

  // Define the JTAG State Transitions
  always @*
    begin
      case(jtag_state)
        RESET:
          next_jtag_state = jtag_tms ? RESET : RUN_TEST_IDLE;
        RUN_TEST_IDLE:
          next_jtag_state = jtag_tms ? SEL_DR_SCAN : RUN_TEST_IDLE;
        SEL_DR_SCAN:
          next_jtag_state = jtag_tms ? SEL_IR_SCAN : CAPTURE_DR;
        CAPTURE_DR:
          next_jtag_state = jtag_tms ? EXIT1_DR : SHIFT_DR;
        SHIFT_DR:
          next_jtag_state = jtag_tms ? EXIT1_DR : SHIFT_DR;
        EXIT1_DR:
          next_jtag_state = jtag_tms ? UPDATE_DR : PAUSE_DR;
        PAUSE_DR:
          next_jtag_state = jtag_tms ? EXIT2_DR : PAUSE_DR;
        EXIT2_DR:
          next_jtag_state = jtag_tms ? UPDATE_DR : SHIFT_DR;
        UPDATE_DR:
          next_jtag_state = jtag_tms ? SEL_DR_SCAN : RUN_TEST_IDLE;

        SEL_IR_SCAN:
          next_jtag_state = jtag_tms ? RESET : CAPTURE_IR;
        CAPTURE_IR:
          next_jtag_state = jtag_tms ? EXIT1_IR : SHIFT_IR;
        SHIFT_IR:
          next_jtag_state = jtag_tms ? EXIT1_IR : SHIFT_IR;
        EXIT1_IR:
          next_jtag_state = jtag_tms ? UPDATE_IR : PAUSE_IR;
        PAUSE_IR:
          next_jtag_state = jtag_tms ? EXIT2_IR : PAUSE_IR;
        EXIT2_IR:
          next_jtag_state = jtag_tms ? UPDATE_IR : SHIFT_IR;
        UPDATE_IR:
          next_jtag_state = jtag_tms ? SEL_DR_SCAN : RUN_TEST_IDLE;
      endcase
    end

endmodule  // xgate_jtag_sm


// -----------------------------------------------------------------------------
// JTAG TAP Instruction Register
// -----------------------------------------------------------------------------
module xgate_jtag_ir #(parameter IR_BITS = 4)    // Number of Instruction Register Bits
  (
    output reg [IR_BITS-1:0] ir_reg,
    output                   ir_so,    // IR shift out

    input            update_ir,
    input            capture_ir,
    input            shift_ir,

    input            jtag_tdi,      // JTAG Serial Input Data
    input            capture_clk,   // JTAG Test clock
    input            update_clk,
    input            jtag_reset_n   // JTAG Async reset signal
  );

  reg [IR_BITS-1:0] ir_shift_reg;

  assign ir_so = ir_shift_reg[0];

  // JTAG Instruction Shift Register
  always @(posedge capture_clk or negedge jtag_reset_n)
    if (!jtag_reset_n)
      ir_shift_reg <= 0;
    else if (capture_ir)
      ir_shift_reg <= ir_reg;
    else if (shift_ir)
      ir_shift_reg <= {jtag_tdi, ir_shift_reg[(IR_BITS-1):1]};

  // JTAG Instruction Register
  always @(posedge update_clk or negedge jtag_reset_n)
    if (!jtag_reset_n)
      ir_reg <= {IR_BITS{1'b1}};  // Make the default instruction BYPASS
    else if (update_ir)
      ir_reg <= ir_shift_reg;

endmodule  // xgate_jtag_ir


// -----------------------------------------------------------------------------
// JTAG Bypass Register
// -----------------------------------------------------------------------------
module xgate_bypass_reg
  (
    output reg       bypass_so,

    input            jtag_tdi,      // JTAG Serial Input Data
    input            capture_clk,   // JTAG Test clock
    input            jtag_reset_n   // JTAG Async reset signal
  );

  // JTAG Bypass Register
  always @(posedge capture_clk or negedge jtag_reset_n)
    if (!jtag_reset_n)
      bypass_so <= 0;
    else
      bypass_so <= jtag_tdi;

endmodule  // xgate_bypass_reg


// -----------------------------------------------------------------------------
// JTAG ID Register
// -----------------------------------------------------------------------------
module xgate_id_reg #(parameter NUM_BITS = 32)
  (
    output id_so,

    input  jtag_tdi,      // JTAG Serial Input Data
    input  capture_clk,
    input  capture_dr,
    input  shift_dr,
    input  idcode,
    input  usercode,
    input  jtag_reset_n   // JTAG Async reset signal
  );

  parameter user_code_val  = 32'ha596_c3f0;
  parameter version        = 4'h1;
  parameter part_num       = 16'h1105;
  parameter manufacture_id = 11'h00f;

  reg  [NUM_BITS-1:0] id_shifter;

  wire [NUM_BITS-1:0] jtag_id = {version, part_num, manufacture_id, 1'b1};
  wire [NUM_BITS-1:0] sel_mux = ({NUM_BITS{idcode}} & jtag_id) | ({NUM_BITS{usercode}} & user_code_val);
  wire [NUM_BITS-1:0] din_mux = shift_dr ? {jtag_tdi, id_shifter[(NUM_BITS-1):1]} : jtag_id;

  wire capture_en = (idcode || usercode) && (capture_dr || shift_dr);

  // JTAG Id Register
  always @(posedge capture_clk or negedge jtag_reset_n)
    if (!jtag_reset_n)
      id_shifter <= 0;
    else if (capture_en)
      id_shifter <= din_mux;

  assign id_so = id_shifter[0];

endmodule  // xgate_id_reg


// -----------------------------------------------------------------------------
// JTAG Instruction decoder of the IR Register
// -----------------------------------------------------------------------------
module xgate_instr_decode #(parameter IR_BITS = 4)    // Number of Instruction Register Bits
  (
    output reg bypass,
    output reg clamp,
    output reg highz,
    output reg extest,
    output reg force_pul_lo,
    output reg force_pul_hi,
    output reg sample,
    output reg idcode,
    output reg usercode,
    output reg udi_1,

    output     sel_bypass,
    output     sel_bsd,
    output     sel_id,
    output     sel_udi_1,

    input  [IR_BITS-1:0] ir_reg
  );

  assign sel_bypass = bypass || clamp || highz || force_pul_lo || force_pul_hi;
  assign sel_bsd = extest || sample;
  assign sel_id = idcode || usercode;
  assign sel_udi_1 = udi_1;

  always @*
    begin
      bypass     = 0;
      clamp      = 0;
      highz      = 0;
      extest     = 0;
      force_pul_lo = 0;
      force_pul_hi = 0;
      sample     = 0;
      idcode     = 0;
      usercode   = 0;
      udi_1      = 0;
      casez (ir_reg)
        4'b0110: clamp = 1;
        4'b0101: highz = 1;
        4'b0000: extest = 1;
        4'b1001: force_pul_lo = 1;
        4'b1010: force_pul_hi = 1;
        4'b0111: sample = 1;
        4'b0001: idcode = 1;
        4'b0011: usercode = 1;
        4'b1100: udi_1 = 1;
        default: bypass = 1;
      endcase
    end

endmodule  // xgate_instr_decode


// -----------------------------------------------------------------------------
// JTAG Test Data Output mux
// -----------------------------------------------------------------------------
module xgate_tdo_mux
  (
    input  sel_bypass,
    input  sel_bsd,
    input  sel_id,
    input  sel_udi_1,

    input  bypass_so,
    input  bsd_so,
    input  id_so,
    input  user1_so,
    input  ir_so,

    input  shift_dr,
    input  shift_ir,
    input  update_clk,
    input  jtag_reset_n,

    output reg jtag_tdo,
    output reg jtag_tdo_en
  );

  wire bypass_gate = shift_dr && sel_bypass && bypass_so;
  wire bsd_gate    = shift_dr && sel_bsd    && bsd_so;
  wire id_gate     = shift_dr && sel_id     && id_so;
  wire udi_1_gate  = shift_dr && sel_udi_1  && user1_so;
  wire ir_gate     = shift_ir && ir_so;

  wire jtag_tdo_mux = bypass_gate || bsd_gate || id_gate || udi_1_gate || ir_gate;

  // JTAG TDO Retiming Register
  always @(posedge update_clk or negedge jtag_reset_n)
    if (!jtag_reset_n)
      jtag_tdo <= 0;
    else
      jtag_tdo <= jtag_tdo_mux;

  // JTAG Output Enable Register
  always @(posedge update_clk or negedge jtag_reset_n)
    if (!jtag_reset_n)
      jtag_tdo_en <= 0;
    else
      jtag_tdo_en <= shift_dr || shift_ir;

endmodule  // xgate_tdo_mux


// -----------------------------------------------------------------------------
// Boundary Scan Cell #7
// -----------------------------------------------------------------------------
module bc_7
  (
    input      capture_clk,  // Shift and input capture clock
    input      update_clk,   // Load holding register
    input      capture_en,   // Enable shift/capture register parallel input loading,
    input      update_en,    // Enable holding register input loading
    input      shift_dr,     // Select eather shift mode or parallel capture mode
    input      mode,         // Select test mode or mission mode control of pad
    input      si,           // Serial data input
    input      pin_input,    // Mission mode input from pin
    input      control_out,  // Signal from bc_2 module controlling output enable pin
    input      output_data,  // mission mode data in from core
    input      reset_n,      // reset

    output     data_out,     // Final data to pad
    output reg so            // Serial data out
  );

  reg data_reg;

  // Shift register
  always @(posedge capture_clk or negedge reset_n)
    if (!reset_n)
      so <= 0;
    else if (capture_en)
      so <= shift_dr ? si : ((!control_out || mode) ? pin_input : output_data);

  // Holding register
  always @(posedge update_clk or negedge reset_n)
    if (!reset_n)
      data_reg <= 0;
    else if (update_en)
      data_reg <= so;

  assign data_out = mode ? data_reg : output_data;

endmodule  // bc_7


// -----------------------------------------------------------------------------
// Boundary Scan Cell #2
// -----------------------------------------------------------------------------
module bc_2
  (
    input      capture_clk,  // Shift and input capture clock
    input      update_clk,   // Load holding register
    input      capture_en,   // Enable shift/capture register parallel input loading
    input      update_en,    // Enable holding register input loading
    input      shift_dr,     // Select eather shift mode or parallel capture mode
    input      mode,         // Select test mode or mission mode control of pad
    input      si,           // Serial data input
    input      data_in,      // Mission mode input
    input      reset_n,      // reset

    output     data_out,     // Final data to pad
    output reg so            // Serial data out
  );

  reg data_reg;

  // Shift register
  always @(posedge capture_clk or negedge reset_n)
    if (!reset_n)
      so <= 0;
    else if (capture_en)
      so <= shift_dr ? si : data_out;

  // Holding register
  always @(posedge update_clk or negedge reset_n)
    if (!reset_n)
      data_reg <= 0;
    else if (update_en)
      data_reg <= so;

  assign data_out = mode ? data_reg : data_in;

endmodule  // bc_2


