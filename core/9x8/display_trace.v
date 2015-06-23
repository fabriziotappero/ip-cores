// Display micro controller PC, opcode, and stacks.
localparam L__TRACE_SIZE        = C_PC_WIDTH            // pc width
                                + 9                     // opcode width
                                + C_DATA_PTR_WIDTH      // data stack pointer width
                                + 1                     // s_N_valid
                                + 8                     // s_N
                                + 1                     // s_T_valid
                                + 8                     // s_T
                                + 1                     // s_R_valid
                                + C_RETURN_WIDTH        // s_R
                                + C_RETURN_PTR_WIDTH    // return stack pointer width
                                ;
task display_trace;
  input                     [L__TRACE_SIZE-1:0] s_raw;
  reg                  [C_PC_WIDTH-1:0] s_PC;
  reg                             [8:0] s_opcode;
  reg            [C_DATA_PTR_WIDTH-1:0] s_Np_stack_ptr;
  reg                                   s_N_valid;
  reg                             [7:0] s_N;
  reg                                   s_T_valid;
  reg                             [7:0] s_T;
  reg                                   s_R_valid;
  reg              [C_RETURN_WIDTH-1:0] s_R;
  reg          [C_RETURN_PTR_WIDTH-1:0] s_Rw_ptr;
  reg                         [7*8-1:0] s_opcode_name;
  begin
    { s_PC, s_opcode, s_Np_stack_ptr, s_N_valid, s_N, s_T_valid, s_T, s_R_valid, s_R, s_Rw_ptr } = s_raw;
    casez (s_opcode)
      9'b00_0000_000 : s_opcode_name = "nop    ";
      9'b00_0000_001 : s_opcode_name = "<<0    ";
      9'b00_0000_010 : s_opcode_name = "<<1    ";
      9'b00_0000_011 : s_opcode_name = "<<msb  ";
      9'b00_0000_100 : s_opcode_name = "0>>    ";
      9'b00_0000_101 : s_opcode_name = "1>>    ";
      9'b00_0000_110 : s_opcode_name = "msb>>  ";
      9'b00_0000_111 : s_opcode_name = "lsb>>  ";
      9'b00_0001_000 : s_opcode_name = "dup    ";
      9'b00_0001_001 : s_opcode_name = "r@     ";
      9'b00_0001_010 : s_opcode_name = "over   ";
      9'b00_0001_011 : s_opcode_name = "+c     ";
      9'b00_0001_111 : s_opcode_name = "-c     ";
      9'b00_0010_010 : s_opcode_name = "swap   ";
      9'b00_0011_000 : s_opcode_name = "+      ";
      9'b00_0011_100 : s_opcode_name = "-      ";
      9'b00_0100_000 : s_opcode_name = "0=     ";
      9'b00_0100_001 : s_opcode_name = "0<>    ";
      9'b00_0100_010 : s_opcode_name = "-1=    ";
      9'b00_0100_011 : s_opcode_name = "-1<>   ";
      9'b00_0101_000 : s_opcode_name = "return ";
      9'b00_0110_000 : s_opcode_name = "inport ";
      9'b00_0111_000 : s_opcode_name = "outport";
      9'b00_1000_000 : s_opcode_name = ">r     ";
      9'b00_1001_001 : s_opcode_name = "r>     ";
      9'b00_1010_000 : s_opcode_name = "&      ";
      9'b00_1010_001 : s_opcode_name = "or     ";
      9'b00_1010_010 : s_opcode_name = "^      ";
      9'b00_1010_011 : s_opcode_name = "nip    ";
      9'b00_1010_100 : s_opcode_name = "drop   ";
      9'b00_1011_000 : s_opcode_name = "1+     ";
      9'b00_1011_100 : s_opcode_name = "1-     ";
      9'b00_1100_000 : s_opcode_name = "store0 ";
      9'b00_1100_001 : s_opcode_name = "store1 ";
      9'b00_1100_010 : s_opcode_name = "store2 ";
      9'b00_1100_011 : s_opcode_name = "store3 ";
      9'b00_1101_000 : s_opcode_name = "fetch0 ";
      9'b00_1101_001 : s_opcode_name = "fetch1 ";
      9'b00_1101_010 : s_opcode_name = "fetch2 ";
      9'b00_1101_011 : s_opcode_name = "fetch3 ";
      9'b00_1110_000 : s_opcode_name = "store0+";
      9'b00_1110_001 : s_opcode_name = "store1+";
      9'b00_1110_010 : s_opcode_name = "store2+";
      9'b00_1110_011 : s_opcode_name = "store3+";
      9'b00_1110_100 : s_opcode_name = "store0-";
      9'b00_1110_101 : s_opcode_name = "store1-";
      9'b00_1110_110 : s_opcode_name = "store2-";
      9'b00_1110_111 : s_opcode_name = "store3-";
      9'b00_1111_000 : s_opcode_name = "fetch0+";
      9'b00_1111_001 : s_opcode_name = "fetch1+";
      9'b00_1111_010 : s_opcode_name = "fetch2+";
      9'b00_1111_011 : s_opcode_name = "fetch3+";
      9'b00_1111_100 : s_opcode_name = "fetch0-";
      9'b00_1111_101 : s_opcode_name = "fetch1-";
      9'b00_1111_110 : s_opcode_name = "fetch2-";
      9'b00_1111_111 : s_opcode_name = "fetch3-";
      9'b0_100_????? : s_opcode_name = "jump   ";
      9'b0_110_????? : s_opcode_name = "call   ";
      9'b0_101_????? : s_opcode_name = "jumpc  ";
      9'b0_111_????? : s_opcode_name = "callc  ";
      9'b1_????_???? : s_opcode_name = "push   ";
             default : s_opcode_name = "INVALID";
    endcase
    $write("%X %X %s : %X", s_PC, s_opcode, s_opcode_name, s_Np_stack_ptr);
    if (s_N_valid) $write(" %x",s_N); else $write(" XX");
    if (s_T_valid) $write(" %x",s_T); else $write(" XX");
    if (s_R_valid) $write(" : %x",s_R); else $write(" : %s",{((C_RETURN_WIDTH+3)/4){8'h58}});
    $write(" %X\n",s_Rw_ptr);
  end
endtask
