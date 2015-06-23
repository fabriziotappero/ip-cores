//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Arithmetic functions                                        ////
////                                                              ////
////  Description                                                 ////
////  Arithmetic functions for ALU and DSP                        ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`ifdef MULTS
// signed multiplication
`define MODULE mults
module `BASE`MODULE (a,b,p);
`undef MODULE
parameter operand_a_width = 18;
parameter operand_b_width = 18;
parameter result_hi = 35;
parameter result_lo = 0;
input [operand_a_width-1:0] a;
input [operand_b_width-1:0] b;
output [result_hi:result_lo] p;
wire signed [operand_a_width-1:0] ai;
wire signed [operand_b_width-1:0] bi;
wire signed [operand_a_width+operand_b_width-1:0] result;

    assign ai = a;
    assign bi = b;
    assign result = ai * bi;
    assign p = result[result_hi:result_lo];
    
endmodule
`endif
`ifdef MULTS18X18
`define MODULE mults18x18
module `BASE`MODULE (a,b,p);
`undef MODULE
input [17:0] a,b;
output [35:0] p;
vl_mult
    # (.operand_a_width(18), .operand_b_width(18))
    mult0 (.a(a), .b(b), .p(p));
endmodule
`endif

`ifdef MULT
`define MODULE mult
// unsigned multiplication
module `BASE`MODULE (a,b,p);
`undef MODULE
parameter operand_a_width = 18;
parameter operand_b_width = 18;
parameter result_hi = 35;
parameter result_lo = 0;
input [operand_a_width-1:0] a;
input [operand_b_width-1:0] b;
output [result_hi:result_hi] p;

wire [operand_a_width+operand_b_width-1:0] result;

    assign result = a * b;
    assign p = result[result_hi:result_lo];
    
endmodule
`endif

`ifdef SHIFT_UNIT_32
`define MODULE shift_unit_32
// shift unit
// supporting the following shift functions
//   SLL
//   SRL
//   SRA
`define SHIFT_UNIT_MULT # ( .operand_a_width(25), .operand_b_width(16), .result_hi(14), .result_lo(7))
module `BASE`MODULE( din, s, dout, opcode);
`undef MODULE
input [31:0] din; // data in operand
input [4:0] s; // shift operand
input [1:0] opcode;
output [31:0] dout;

parameter opcode_sll = 2'b00;
parameter opcode_srl = 2'b01;
parameter opcode_sra = 2'b10;
parameter opcode_ror = 2'b11;

parameter mult=0; // if set to 1 implemented based on multipliers which saves LUT

generate
if (mult==1) begin : impl_mult
wire sll, sra;
assign sll = opcode == opcode_sll;
assign sra = opcode == opcode_sra;

wire [15:1] s1;
wire [3:0] sign;
wire [7:0] tmp [0:3];

// first stage is multiplier based
// shift operand as fractional 8.7
assign s1[15] = sll & s[2:0]==3'd7;
assign s1[14] = sll & s[2:0]==3'd6;
assign s1[13] = sll & s[2:0]==3'd5;
assign s1[12] = sll & s[2:0]==3'd4;
assign s1[11] = sll & s[2:0]==3'd3;
assign s1[10] = sll & s[2:0]==3'd2;
assign s1[ 9] = sll & s[2:0]==3'd1;
assign s1[ 8] = s[2:0]==3'd0;
assign s1[ 7] = !sll & s[2:0]==3'd1;
assign s1[ 6] = !sll & s[2:0]==3'd2;
assign s1[ 5] = !sll & s[2:0]==3'd3;
assign s1[ 4] = !sll & s[2:0]==3'd4;
assign s1[ 3] = !sll & s[2:0]==3'd5;
assign s1[ 2] = !sll & s[2:0]==3'd6;
assign s1[ 1] = !sll & s[2:0]==3'd7;

assign sign[3] = din[31] & sra;
assign sign[2] = sign[3] & (&din[31:24]);
assign sign[1] = sign[2] & (&din[23:16]);
assign sign[0] = sign[1] & (&din[15:8]);
`define MODULE mults
`BASE`MODULE `SHIFT_UNIT_MULT mult_byte3 ( .a({sign[3], {8{sign[3]}},din[31:24], din[23:16]}), .b({1'b0,s1}), .p(tmp[3]));
`BASE`MODULE `SHIFT_UNIT_MULT mult_byte2 ( .a({sign[2], din[31:24]  ,din[23:16],  din[15:8]}), .b({1'b0,s1}), .p(tmp[2]));
`BASE`MODULE `SHIFT_UNIT_MULT mult_byte1 ( .a({sign[1], din[23:16]  ,din[15:8],   din[7:0]}), .b({1'b0,s1}), .p(tmp[1]));
`BASE`MODULE `SHIFT_UNIT_MULT mult_byte0 ( .a({sign[0], din[15:8]   ,din[7:0],    8'h00}),      .b({1'b0,s1}), .p(tmp[0]));
`undef MODULE
// second stage is multiplexer based
// shift on byte level

// mux byte 3
assign dout[31:24] = (s[4:3]==2'b00) ? tmp[3] :
                     (sll & s[4:3]==2'b01) ? tmp[2] :
                     (sll & s[4:3]==2'b10) ? tmp[1] :
                     (sll & s[4:3]==2'b11) ? tmp[0] :
                     {8{sign[3]}};

// mux byte 2
assign dout[23:16] = (s[4:3]==2'b00) ? tmp[2] :
                     (sll & s[4:3]==2'b01) ? tmp[1] :
                     (sll & s[4:3]==2'b10) ? tmp[0] :
                     (sll & s[4:3]==2'b11) ? {8{1'b0}} :
                     (s[4:3]==2'b01) ? tmp[3] :
                     {8{sign[3]}};

// mux byte 1
assign dout[15:8]  = (s[4:3]==2'b00) ? tmp[1] :
                     (sll & s[4:3]==2'b01) ? tmp[0] :
                     (sll & s[4:3]==2'b10) ? {8{1'b0}} :
                     (sll & s[4:3]==2'b11) ? {8{1'b0}} :
                     (s[4:3]==2'b01) ? tmp[2] :
                     (s[4:3]==2'b10) ? tmp[3] :
                     {8{sign[3]}};

// mux byte 0
assign dout[7:0]   = (s[4:3]==2'b00) ? tmp[0] :
                     (sll) ?  {8{1'b0}}:
                     (s[4:3]==2'b01) ? tmp[1] :
                     (s[4:3]==2'b10) ? tmp[2] :
                     tmp[3];
end else begin : impl_classic

assign dout =
    (opcode==opcode_sll) ? din << s :
    (opcode==opcode_srl) ? din >> s :
    (opcode==opcode_sra) ? (din >> s) | ({32{din[31]}} << (6'd32-{1'b0,s})) :
    din << s;
    
end
endgenerate

endmodule
`endif

`ifdef LOGIC_UNIT
// logic unit
// supporting the following logic functions
//    a and b
//    a or  b
//    a xor b
//    not b
`define MODULE logic_unit
module `BASE`MODULE( a, b, result, opcode);
`undef MODULE
parameter width = 32;
parameter opcode_and = 2'b00;
parameter opcode_or  = 2'b01;
parameter opcode_xor = 2'b10;
input [width-1:0] a,b;
output [width-1:0] result;
input [1:0] opcode;

assign result = (opcode==opcode_and) ? a & b :
                (opcode==opcode_or)  ? a | b :
                (opcode==opcode_xor) ? a ^ b :
                b;

endmodule
`endif

`ifdef ARITH_UNIT
`define MODULE arith_unit
module `BASE`MODULE ( a, b, c_in, add_sub, sign, result, c_out, z, ovfl);
`undef MODULE
parameter width = 32;
parameter opcode_add = 1'b0;
parameter opcode_sub = 1'b1;
input [width-1:0] a,b;
input c_in, add_sub, sign;
output [width-1:0] result;
output c_out, z, ovfl;

assign {c_out,result} = {(a[width-1] & sign),a} + ({a[width-1] & sign,b} ^ {(width+1){(add_sub==opcode_sub)}}) + {{(width-1){1'b0}},(c_in | (add_sub==opcode_sub))};
assign z = (result=={width{1'b0}});
assign ovfl = ( a[width-1] &  b[width-1] & ~result[width-1]) |
               (~a[width-1] & ~b[width-1] &  result[width-1]);
endmodule
`endif

`ifdef COUNT_UNIT
`define MODULE count_unit
module `BASE`MODULE (din, dout, opcode);
`undef MODULE
parameter width = 32;
input [width-1:0] din;
output [width-1:0] dout;
input opcode;

integer i;
wire [width/32+4:0] ff1, fl1;

/*
always @(din) begin
    ff1 = 0; i = 0;
    while (din[i] == 0 && i < width) begin // complex condition
        ff1 = ff1 + 1;
        i = i + 1;
    end
end

always @(din) begin
    fl1 = width; i = width-1;
    while (din[i] == 0 && i >= width) begin // complex condition
        fl1 = fl1 - 1;
        i = i - 1;
    end
end
*/

generate
if (width==32) begin

    assign ff1 = din[0] ? 6'd1 :
                 din[1] ? 6'd2 :
                 din[2] ? 6'd3 :
                 din[3] ? 6'd4 :
                 din[4] ? 6'd5 :
                 din[5] ? 6'd6 :
                 din[6] ? 6'd7 :
                 din[7] ? 6'd8 :
                 din[8] ? 6'd9 :
                 din[9] ? 6'd10 :
                 din[10] ? 6'd11 :
                 din[11] ? 6'd12 :
                 din[12] ? 6'd13 :
                 din[13] ? 6'd14 :
                 din[14] ? 6'd15 :
                 din[15] ? 6'd16 :
                 din[16] ? 6'd17 :
                 din[17] ? 6'd18 :
                 din[18] ? 6'd19 :
                 din[19] ? 6'd20 :
                 din[20] ? 6'd21 :
                 din[21] ? 6'd22 :
                 din[22] ? 6'd23 :
                 din[23] ? 6'd24 :
                 din[24] ? 6'd25 :
                 din[25] ? 6'd26 :
                 din[26] ? 6'd27 :
                 din[27] ? 6'd28 :
                 din[28] ? 6'd29 :
                 din[29] ? 6'd30 :
                 din[30] ? 6'd31 :
                 din[31] ? 6'd32 :
                 6'd0;

    assign fl1 = din[31] ? 6'd32 :
                 din[30] ? 6'd31 :
                 din[29] ? 6'd30 :
                 din[28] ? 6'd29 :
                 din[27] ? 6'd28 :
                 din[26] ? 6'd27 :
                 din[25] ? 6'd26 :
                 din[24] ? 6'd25 :
                 din[23] ? 6'd24 :
                 din[22] ? 6'd23 :
                 din[21] ? 6'd22 :
                 din[20] ? 6'd21 :
                 din[19] ? 6'd20 :
                 din[18] ? 6'd19 :
                 din[17] ? 6'd18 :
                 din[16] ? 6'd17 :
                 din[15] ? 6'd16 :
                 din[14] ? 6'd15 :
                 din[13] ? 6'd14 :
                 din[12] ? 6'd13 :
                 din[11] ? 6'd12 :
                 din[10] ? 6'd11 :
                 din[9] ? 6'd10 :
                 din[8] ? 6'd9 :
                 din[7] ? 6'd8 :
                 din[6] ? 6'd7 :
                 din[5] ? 6'd6 :
                 din[4] ? 6'd5 :
                 din[3] ? 6'd4 :
                 din[2] ? 6'd3 :
                 din[1] ? 6'd2 :
                 din[0] ? 6'd1 :
                 6'd0;
                 
    assign dout = (!opcode) ? {{26{1'b0}}, ff1} : {{26{1'b0}}, fl1};
end
endgenerate

generate
if (width==64) begin
    assign ff1 = 7'd0;
    assign fl1 = 7'd0;
    assign dout = (!opcode) ? {{57{1'b0}}, ff1} : {{57{1'b0}}, fl1};
end
endgenerate

endmodule
`endif

`ifdef EXT_UNIT
`define MODULE ext_unit
module `BASE`MODULE ( a, b, F, result, opcode);
`undef MODULE
parameter width = 32;
input [width-1:0] a, b;
input F;
output reg [width-1:0] result;
input [2:0] opcode;

generate
if (width==32) begin
always @ (a or b or F or opcode)
begin
    case (opcode)
    3'b000: result = {{24{1'b0}},a[7:0]};
    3'b001: result = {{24{a[7]}},a[7:0]};
    3'b010: result = {{16{1'b0}},a[7:0]};
    3'b011: result = {{16{a[15]}},a[15:0]};
    3'b110: result = (F) ? a : b;
    default: result = {b[15:0],16'h0000};
    endcase
end
end
endgenerate

generate
if (width==64) begin
always @ (a or b or F or opcode)
begin
    case (opcode)
    3'b000: result = {{56{1'b0}},a[7:0]};
    3'b001: result = {{56{a[7]}},a[7:0]};
    3'b010: result = {{48{1'b0}},a[7:0]};
    3'b011: result = {{48{a[15]}},a[15:0]};
    3'b110: result = (F) ? a : b;
    default: result = {32'h00000000,b[15:0],16'h0000};
    endcase
end
end
endgenerate
endmodule
`endif
