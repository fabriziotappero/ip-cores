/*******************************************************************************
 *
 * Copyright 2012-2014, Sinclair R.F., Inc.
 *
 * SSBCC.9x8 -- Small Stack Based Computer Compiler, 9-bit opcode, 8-bit data.
 *
 * The repository for this open-source project is at
 *   https://github.com/sinclairrf/SSBCC
 *
 ******************************************************************************/

//@SSBCC@ user_header

//@SSBCC@ module

// configuration file determined parameters
//@SSBCC@ localparam

/*******************************************************************************
 *
 * Declare the signals used throughout the system.
 *
 ******************************************************************************/

// listed in useful display order
reg            [C_PC_WIDTH-1:0] s_PC;           // program counter
reg                       [8:0] s_opcode;       // current opcode
reg    [C_RETURN_PTR_WIDTH-1:0] s_R_stack_ptr;  // pointer into return stack memory
reg        [C_RETURN_WIDTH-1:0] s_R;            // top of return stack
reg                       [7:0] s_T;            // top of the data stack
reg                       [7:0] s_N;            // next-to-top on the data stack
reg      [C_DATA_PTR_WIDTH-1:0] s_Np_stack_ptr; // pointer into data stack memory

//@SSBCC@ functions

//@SSBCC@ verilator_tracing

//@SSBCC@ signals

/*******************************************************************************
 *
 * Instantiate the ALU operations.  These are listed in order by opcode.
 *
 ******************************************************************************/

reg [8:0] s_T_adder;

// opcode = 000000_xxx
// shifter operations (including "nop" as no shift)
// 6-input LUT formulation -- 3-bit opcode, 3 bits of T centered at current bit
reg [7:0] s_math_rotate;
always @ (s_T,s_opcode)
  case (s_opcode[0+:3])
     3'b000 : s_math_rotate = s_T;                      // nop
     3'b001 : s_math_rotate = { s_T[0+:7], 1'b0 };      // <<0
     3'b010 : s_math_rotate = { s_T[0+:7], 1'b1 };      // <<1
     3'b011 : s_math_rotate = { s_T[0+:7], s_T[7] };    // <<msb
     3'b100 : s_math_rotate = { 1'b0,      s_T[1+:7] }; // 0>>
     3'b101 : s_math_rotate = { 1'b1,      s_T[1+:7] }; // 1>>
     3'b110 : s_math_rotate = { s_T[7],    s_T[1+:7] }; // msb>>
     3'b111 : s_math_rotate = { s_T[0],    s_T[1+:7] }; // lsb>>
    default : s_math_rotate = s_T;
  endcase

// opcode = 000001_0xx
// T pre-multiplexer for pushing repeated values onto the data stack
reg [7:0] s_T_stack;
always @ (*)
  case (s_opcode[0+:2])
      2'b00 : s_T_stack = s_T;                          // dup
      2'b01 : s_T_stack = s_R[0+:8];                    // r@
      2'b10 : s_T_stack = s_N;                          // over
      2'b11 : s_T_stack = { 7'd0, s_T_adder[8] };       // +/-c
    default : s_T_stack = s_T;
  endcase

//  opcode = 000011_x00 (adder) and 001xxx_x.. (incrementers)
always @ (*)
  if (s_opcode[6] == 1'b0)
    case (s_opcode[2])
       1'b0: s_T_adder = { 1'b0, s_N } + { 1'b0, s_T };
       1'b1: s_T_adder = { 1'b0, s_N } - { 1'b0, s_T };
    endcase
  else begin
    case (s_opcode[2])
       1'b0: s_T_adder = { 1'b0, s_T } + 9'h01;
       1'b1: s_T_adder = { 1'b0, s_T } - 9'h01;
    default: s_T_adder = { 1'b0, s_T } + 9'h01;
    endcase
  end

// opcode = 000100_0xx
//                   ^ 0 ==> "=", 1 ==> "<>"
//                  ^  0 ==> all zero, 1 ==> all ones
wire s_T_compare = s_opcode[0] ^ &(s_T == {(8){s_opcode[1]}});

// opcode = 001010_xxx
// add,sub,and,or,xor,TBD,drop,nip
reg [7:0] s_T_logic;
always @ (*)
  case (s_opcode[0+:3])
     3'b000 : s_T_logic = s_N & s_T;    // and
     3'b001 : s_T_logic = s_N | s_T;    // or
     3'b010 : s_T_logic = s_N ^ s_T;    // xor
     3'b011 : s_T_logic = s_T;          // nip
     3'b100 : s_T_logic = s_N;          // drop
     3'b101 : s_T_logic = s_N;          // drop
     3'b110 : s_T_logic = s_N;          // drop
     3'b111 : s_T_logic = s_N;          // drop
    default : s_T_logic = s_N;          // drop
  endcase

// increment PC
reg [C_PC_WIDTH-1:0] s_PC_plus1 = {(C_PC_WIDTH){1'b0}};
always @ (*)
  s_PC_plus1 = s_PC + { {(C_PC_WIDTH-1){1'b0}}, 1'b1 };

// Reduced-warning-message method to extract the jump address from the top of
// the stack and the current opcode.
wire [C_PC_WIDTH-1:0] s_PC_jump;
generate
  if (C_PC_WIDTH <= 8) begin : gen_pc_jump_narrow
    assign s_PC_jump = s_T[0+:C_PC_WIDTH];
  end else begin : gen_pc_jump_wide
    assign s_PC_jump = { s_opcode[0+:C_PC_WIDTH-8], s_T };
  end
endgenerate

/*******************************************************************************
 *
 * Instantiate the input port data selection.
 *
 * Note:  This creates and computes an 8-bit wire called "s_T_inport".
 *
 ******************************************************************************/

reg [7:0] s_T_inport = 8'h00;
reg       s_inport   = 1'b0;
//@SSBCC@ inports

/*******************************************************************************
 *
 * Instantiate the memory banks.
 *
 ******************************************************************************/

reg s_mem_wr = 1'b0;
//@SSBCC@ s_memory

/*******************************************************************************
 *
 * Define the states for the bus muxes and then compute these states from the
 * 6 msb of the opcode.
 *
 ******************************************************************************/

localparam C_BUS_PC_NORMAL      = 2'b00;
localparam C_BUS_PC_JUMP        = 2'b01;
localparam C_BUS_PC_RETURN      = 2'b11;
reg [1:0] s_bus_pc;

localparam C_BUS_R_T            = 1'b0;         // no-op and push T onto return stack
localparam C_BUS_R_PC           = 1'b1;         // push PC onto return stack
reg s_bus_r;

localparam C_RETURN_NOP         = 2'b00;        // don't change return stack pointer
localparam C_RETURN_INC         = 2'b01;        // add element to return stack
localparam C_RETURN_DEC         = 2'b10;        // remove element from return stack
reg [1:0] s_return;

localparam C_BUS_T_MATH_ROTATE  = 4'b0000;      // nop and rotate operations
localparam C_BUS_T_OPCODE       = 4'b0001;
localparam C_BUS_T_N            = 4'b0010;
localparam C_BUS_T_PRE          = 4'b0011;
localparam C_BUS_T_ADDER        = 4'b0100;
localparam C_BUS_T_COMPARE      = 4'b0101;
localparam C_BUS_T_INPORT       = 4'b0110;
localparam C_BUS_T_LOGIC        = 4'b0111;
localparam C_BUS_T_MEM          = 4'b1010;
reg [3:0] s_bus_t;

localparam C_BUS_N_N            = 2'b00;       // don't change N
localparam C_BUS_N_STACK        = 2'b01;       // replace N with third-on-stack
localparam C_BUS_N_T            = 2'b10;       // replace N with T
localparam C_BUS_N_MEM          = 2'b11;       // from memory
reg [1:0] s_bus_n;

localparam C_STACK_NOP          = 2'b00;        // don't change internal data stack pointer
localparam C_STACK_INC          = 2'b01;        // add element to internal data stack
localparam C_STACK_DEC          = 2'b10;        // remove element from internal data stack
reg [1:0] s_stack;

reg s_outport                   = 1'b0;

always @ (*) begin
  // default operation is nop/math_rotate
  s_bus_pc      = C_BUS_PC_NORMAL;
  s_bus_r       = C_BUS_R_T;
  s_return      = C_RETURN_NOP;
  s_bus_t       = C_BUS_T_MATH_ROTATE;
  s_bus_n       = C_BUS_N_N;
  s_stack       = C_STACK_NOP;
  s_inport      = 1'b0;
  s_outport     = 1'b0;
  s_mem_wr      = 1'b0;
  if (s_opcode[8] == 1'b1) begin // push
    s_bus_t     = C_BUS_T_OPCODE;
    s_bus_n     = C_BUS_N_T;
    s_stack     = C_STACK_INC;
  end else if (s_opcode[7] == 1'b1) begin // jump, jumpc, call, callc
    if (!s_opcode[5] || (|s_N)) begin // always or conditional
      s_bus_pc  = C_BUS_PC_JUMP;
      if (s_opcode[6])                  // call or callc
        s_return = C_RETURN_INC;
    end
    s_bus_r     = C_BUS_R_PC;
    s_bus_t     = C_BUS_T_N;
    s_bus_n     = C_BUS_N_STACK;
    s_stack     = C_STACK_DEC;
  end else case (s_opcode[3+:4])
      4'b0000:  // nop, math_rotate
                ;
      4'b0001:  begin // dup, r@, over, +/-c
                s_bus_t         = C_BUS_T_PRE;
                s_bus_n         = C_BUS_N_T;
                s_stack         = C_STACK_INC;
                end
      4'b0010:  begin // swap
                s_bus_t         = C_BUS_T_N;
                s_bus_n         = C_BUS_N_T;
                end
      4'b0011:  begin // dual-operand adder:  add,sub
                s_bus_t         = C_BUS_T_ADDER;
                s_bus_n         = C_BUS_N_STACK;
                s_stack         = C_STACK_DEC;
                end
      4'b0100:  begin // 0=, -1=, 0<>, -1<>
                s_bus_t         = C_BUS_T_COMPARE;
                end
      4'b0101:  begin // return
                s_bus_pc        = C_BUS_PC_RETURN;
                s_return        = C_RETURN_DEC;
                end
      4'b0110:  begin // inport
                s_bus_t         = C_BUS_T_INPORT;
                s_inport        = 1'b1;
                end
      4'b0111:  begin // outport
                s_bus_t         = C_BUS_T_N;
                s_bus_n         = C_BUS_N_STACK;
                s_stack         = C_STACK_DEC;
                s_outport       = 1'b1;
                end
      4'b1000:  begin // >r
                s_return        = C_RETURN_INC;
                s_bus_t         = C_BUS_T_N;
                s_bus_n         = C_BUS_N_STACK;
                s_stack         = C_STACK_DEC;
                end
      4'b1001:  begin // r> (pop the return stack and push it onto the data stack)
                s_return        = C_RETURN_DEC;
                s_bus_t         = C_BUS_T_PRE;
                s_bus_n         = C_BUS_N_T;
                s_stack         = C_STACK_INC;
                end
      4'b1010:  begin // &, or, ^, nip, and drop
                s_bus_t         = C_BUS_T_LOGIC;
                s_bus_n         = C_BUS_N_STACK;
                s_stack         = C_STACK_DEC;
                end
      4'b1011:  begin // 8-bit increment/decrement
                s_bus_t         = C_BUS_T_ADDER;
                end
      4'b1100:  begin // store
                s_bus_t         = C_BUS_T_N;
                s_bus_n         = C_BUS_N_STACK;
                s_stack         = C_STACK_DEC;
                s_mem_wr        = 1'b1;
                end
      4'b1101:  begin // fetch
                s_bus_t       = C_BUS_T_MEM;
                end
      4'b1110:  begin // store+/store-
                s_bus_t         = C_BUS_T_ADDER;
                s_bus_n         = C_BUS_N_STACK;
                s_stack         = C_STACK_DEC;
                s_mem_wr        = 1'b1;
                end
      4'b1111:  begin // fetch+/fetch-
                s_bus_t         = C_BUS_T_ADDER;
                s_bus_n         = C_BUS_N_MEM;
                s_stack         = C_STACK_INC;
                end
      default:  // nop
                ;
    endcase
end

/*******************************************************************************
 *
 * Operate the MUXes
 *
 ******************************************************************************/

// non-clocked PC required for shadow register in SRAM blocks
reg [C_PC_WIDTH-1:0] s_PC_next;
always @ (*)
  case (s_bus_pc)
    C_BUS_PC_NORMAL:
      s_PC_next = s_PC_plus1;
    C_BUS_PC_JUMP:
      s_PC_next = s_PC_jump;
    C_BUS_PC_RETURN:
      s_PC_next = s_R[0+:C_PC_WIDTH];
    default:
      s_PC_next = s_PC_plus1;
  endcase

// Return stack candidate
reg [C_RETURN_WIDTH-1:0] s_R_pre;
generate
  if (C_PC_WIDTH < 8) begin : gen_r_narrow
    always @ (*)
      case (s_bus_r)
        C_BUS_R_T:
          s_R_pre = s_T;
        C_BUS_R_PC:
          s_R_pre = { {(8-C_PC_WIDTH){1'b0}}, s_PC_plus1 };
        default:
          s_R_pre = s_T;
      endcase
  end else if (C_PC_WIDTH == 8) begin : gen_r_same
    always @ (*)
      case (s_bus_r)
        C_BUS_R_T:
          s_R_pre = s_T;
        C_BUS_R_PC:
          s_R_pre = s_PC_plus1;
        default:
          s_R_pre = s_T;
      endcase
  end else begin : gen_r_wide
    always @ (*)
      case (s_bus_r)
        C_BUS_R_T:
          s_R_pre = { {(C_PC_WIDTH-8){1'b0}}, s_T };
        C_BUS_R_PC:
          s_R_pre = s_PC_plus1;
        default:
          s_R_pre = { {(C_PC_WIDTH-8){1'b0}}, s_T };
      endcase
  end
endgenerate

/*******************************************************************************
 *
 * run the state machines for the processor components.
 *
 ******************************************************************************/

/*
 * Operate the program counter.
 */

initial s_PC = {(C_PC_WIDTH){1'b0}};
always @ (posedge i_clk)
  if (i_rst)
    s_PC <= {(C_PC_WIDTH){1'b0}};
  else
    s_PC <= s_PC_next;

/*
 * Operate the return stack.
 */

reg [C_RETURN_PTR_WIDTH-1:0] s_R_stack_ptr_next;

// reference data stack pointer
initial s_R_stack_ptr = {(C_RETURN_PTR_WIDTH){1'b1}};
always @ (posedge i_clk)
  if (i_rst)
    s_R_stack_ptr <= {(C_RETURN_PTR_WIDTH){1'b1}};
  else
    s_R_stack_ptr <= s_R_stack_ptr_next;

// reference data stack pointer
initial s_R_stack_ptr_next = {(C_RETURN_PTR_WIDTH){1'b1}};
always @ (*)
  case (s_return)
    C_RETURN_INC: s_R_stack_ptr_next = s_R_stack_ptr + { {(C_RETURN_PTR_WIDTH-1){1'b0}}, 1'b1 };
    C_RETURN_DEC: s_R_stack_ptr_next = s_R_stack_ptr - { {(C_RETURN_PTR_WIDTH-1){1'b0}}, 1'b1 };
         default: s_R_stack_ptr_next = s_R_stack_ptr;
  endcase

/*
 * Operate the top of the data stack.
 */

reg [7:0] s_T_pre = 8'd0;
always @ (*)
  case (s_bus_t)
    C_BUS_T_MATH_ROTATE:        s_T_pre = s_math_rotate;
    C_BUS_T_OPCODE:             s_T_pre = s_opcode[0+:8];  // push 8-bit value
    C_BUS_T_N:                  s_T_pre = s_N;
    C_BUS_T_PRE:                s_T_pre = s_T_stack;
    C_BUS_T_ADDER:              s_T_pre = s_T_adder[0+:8];
    C_BUS_T_COMPARE:            s_T_pre = {(8){s_T_compare}};
    C_BUS_T_INPORT:             s_T_pre = s_T_inport;
    C_BUS_T_LOGIC:              s_T_pre = s_T_logic;
    C_BUS_T_MEM:                s_T_pre = s_memory;
    default:                    s_T_pre = s_T;
  endcase

initial s_T = 8'h00;
always @ (posedge i_clk)
  if (i_rst)
    s_T <= 8'h00;
  else
    s_T <= s_T_pre;

/*
 * Operate the next-to-top of the data stack.
 */

// reference data stack pointer
reg [C_DATA_PTR_WIDTH-1:0] s_Np_stack_ptr_next;
always @ (*)
  case (s_stack)
    C_STACK_INC: s_Np_stack_ptr_next = s_Np_stack_ptr + { {(C_DATA_PTR_WIDTH-1){1'b0}}, 1'b1 };
    C_STACK_DEC: s_Np_stack_ptr_next = s_Np_stack_ptr - { {(C_DATA_PTR_WIDTH-1){1'b0}}, 1'b1 };
        default: s_Np_stack_ptr_next = s_Np_stack_ptr;
  endcase

initial s_Np_stack_ptr = { {(C_DATA_PTR_WIDTH-2){1'b1}}, 2'b01 };
always @ (posedge i_clk)
  if (i_rst)
    s_Np_stack_ptr <= { {(C_DATA_PTR_WIDTH-2){1'b1}}, 2'b01 };
  else
    s_Np_stack_ptr <= s_Np_stack_ptr_next;

reg [7:0] s_Np;

initial s_N = 8'h00;
always @ (posedge i_clk)
  if (i_rst)
    s_N <= 8'h00;
  else case (s_bus_n)
    C_BUS_N_N:          s_N <= s_N;
    C_BUS_N_STACK:      s_N <= s_Np;
    C_BUS_N_T:          s_N <= s_T;
    C_BUS_N_MEM:        s_N <= s_memory;
    default:            s_N <= s_N;
  endcase

/*******************************************************************************
 *
 * Instantiate the output signals.
 *
 ******************************************************************************/

//@SSBCC@ outports

/*******************************************************************************
 *
 * Instantiate the instruction memory and the PC access of that memory.
 *
 ******************************************************************************/

//@SSBCC@ memories

/*******************************************************************************
 *
 * Instantiate the peripherals (if any).
 *
 ******************************************************************************/

//@SSBCC@ peripherals

endmodule
