//////////////////////////////////////////////////////////////////
//                                                              //
//  Barrel Shifter for Amber 2 Core                             //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Provides 32-bit shifts LSL, LSR, ASR and ROR                //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////


module a23_barrel_shift (

input       [31:0]          i_in,
input                       i_carry_in,
input       [7:0]           i_shift_amount,     // uses 8 LSBs of Rs, or a 5 bit immediate constant
input                       i_shift_imm_zero,   // high when immediate shift value of zero selected
input       [1:0]           i_function,

output      [31:0]          o_out,
output                      o_carry_out

);

`include "a23_localparams.vh"

  // MSB is carry out
wire [32:0] lsl_out;
wire [32:0] lsr_out;
wire [32:0] asr_out;
wire [32:0] ror_out;


// Logical shift right zero is redundant as it is the same as logical shift left zero, so
// the assembler will convert LSR #0 (and ASR #0 and ROR #0) into LSL #0, and allow
// lsr #32 to be specified.

// lsl #0 is a special case, where the shifter carry out is the old value of the status flags
// C flag. The contents of Rm are used directly as the second operand.
assign lsl_out = i_shift_imm_zero         ? {i_carry_in, i_in              } :  // fall through case 

                 i_shift_amount == 8'd 0  ? {i_carry_in, i_in              } :  // fall through case
                 i_shift_amount == 8'd 1  ? {i_in[31],   i_in[30: 0],  1'd0} :
                 
                 i_shift_amount == 8'd 2  ? {i_in[30],   i_in[29: 0],  2'd0} :
                 i_shift_amount == 8'd 3  ? {i_in[29],   i_in[28: 0],  3'd0} :
                 i_shift_amount == 8'd 4  ? {i_in[28],   i_in[27: 0],  4'd0} :
                 i_shift_amount == 8'd 5  ? {i_in[27],   i_in[26: 0],  5'd0} :
                 i_shift_amount == 8'd 6  ? {i_in[26],   i_in[25: 0],  6'd0} :
                 i_shift_amount == 8'd 7  ? {i_in[25],   i_in[24: 0],  7'd0} :
                 i_shift_amount == 8'd 8  ? {i_in[24],   i_in[23: 0],  8'd0} :
                 i_shift_amount == 8'd 9  ? {i_in[23],   i_in[22: 0],  9'd0} :
                 i_shift_amount == 8'd10  ? {i_in[22],   i_in[21: 0], 10'd0} :
                 i_shift_amount == 8'd11  ? {i_in[21],   i_in[20: 0], 11'd0} :
                    
                 i_shift_amount == 8'd12  ? {i_in[20],   i_in[19: 0], 12'd0} :
                 i_shift_amount == 8'd13  ? {i_in[19],   i_in[18: 0], 13'd0} :
                 i_shift_amount == 8'd14  ? {i_in[18],   i_in[17: 0], 14'd0} :
                 i_shift_amount == 8'd15  ? {i_in[17],   i_in[16: 0], 15'd0} :
                 i_shift_amount == 8'd16  ? {i_in[16],   i_in[15: 0], 16'd0} :
                 i_shift_amount == 8'd17  ? {i_in[15],   i_in[14: 0], 17'd0} :
                 i_shift_amount == 8'd18  ? {i_in[14],   i_in[13: 0], 18'd0} :
                 i_shift_amount == 8'd19  ? {i_in[13],   i_in[12: 0], 19'd0} :
                 i_shift_amount == 8'd20  ? {i_in[12],   i_in[11: 0], 20'd0} :
                 i_shift_amount == 8'd21  ? {i_in[11],   i_in[10: 0], 21'd0} :

                 i_shift_amount == 8'd22  ? {i_in[10],   i_in[ 9: 0], 22'd0} :
                 i_shift_amount == 8'd23  ? {i_in[ 9],   i_in[ 8: 0], 23'd0} :
                 i_shift_amount == 8'd24  ? {i_in[ 8],   i_in[ 7: 0], 24'd0} :
                 i_shift_amount == 8'd25  ? {i_in[ 7],   i_in[ 6: 0], 25'd0} :
                 i_shift_amount == 8'd26  ? {i_in[ 6],   i_in[ 5: 0], 26'd0} :
                 i_shift_amount == 8'd27  ? {i_in[ 5],   i_in[ 4: 0], 27'd0} :
                 i_shift_amount == 8'd28  ? {i_in[ 4],   i_in[ 3: 0], 28'd0} :
                 i_shift_amount == 8'd29  ? {i_in[ 3],   i_in[ 2: 0], 29'd0} :
                 i_shift_amount == 8'd30  ? {i_in[ 2],   i_in[ 1: 0], 30'd0} :
                 i_shift_amount == 8'd31  ? {i_in[ 1],   i_in[ 0: 0], 31'd0} :
                 i_shift_amount == 8'd32  ? {i_in[ 0],   32'd0             } :  // 32
                                            {1'd0,       32'd0             } ;  // > 32
                                            

// The form of the shift field which might be expected to correspond to LSR #0 is used
// to encode LSR #32, which has a zero result with bit 31 of Rm as the carry output. 
                                           // carry out, < -------- out ---------->
assign lsr_out = i_shift_imm_zero         ? {i_in[31], 32'd0             } :

                 i_shift_amount == 8'd 0  ? {i_carry_in, i_in            } :  // fall through case
                 i_shift_amount == 8'd 1  ? {i_in[ 0],  1'd0, i_in[31: 1]} :
                 i_shift_amount == 8'd 2  ? {i_in[ 1],  2'd0, i_in[31: 2]} :
                 i_shift_amount == 8'd 3  ? {i_in[ 2],  3'd0, i_in[31: 3]} :
                 i_shift_amount == 8'd 4  ? {i_in[ 3],  4'd0, i_in[31: 4]} :
                 i_shift_amount == 8'd 5  ? {i_in[ 4],  5'd0, i_in[31: 5]} :
                 i_shift_amount == 8'd 6  ? {i_in[ 5],  6'd0, i_in[31: 6]} :
                 i_shift_amount == 8'd 7  ? {i_in[ 6],  7'd0, i_in[31: 7]} :
                 i_shift_amount == 8'd 8  ? {i_in[ 7],  8'd0, i_in[31: 8]} :
                 i_shift_amount == 8'd 9  ? {i_in[ 8],  9'd0, i_in[31: 9]} :
                    
                 i_shift_amount == 8'd10  ? {i_in[ 9], 10'd0, i_in[31:10]} :
                 i_shift_amount == 8'd11  ? {i_in[10], 11'd0, i_in[31:11]} :
                 i_shift_amount == 8'd12  ? {i_in[11], 12'd0, i_in[31:12]} :
                 i_shift_amount == 8'd13  ? {i_in[12], 13'd0, i_in[31:13]} :
                 i_shift_amount == 8'd14  ? {i_in[13], 14'd0, i_in[31:14]} :
                 i_shift_amount == 8'd15  ? {i_in[14], 15'd0, i_in[31:15]} :
                 i_shift_amount == 8'd16  ? {i_in[15], 16'd0, i_in[31:16]} :
                 i_shift_amount == 8'd17  ? {i_in[16], 17'd0, i_in[31:17]} :
                 i_shift_amount == 8'd18  ? {i_in[17], 18'd0, i_in[31:18]} :
                 i_shift_amount == 8'd19  ? {i_in[18], 19'd0, i_in[31:19]} :

                 i_shift_amount == 8'd20  ? {i_in[19], 20'd0, i_in[31:20]} :
                 i_shift_amount == 8'd21  ? {i_in[20], 21'd0, i_in[31:21]} :
                 i_shift_amount == 8'd22  ? {i_in[21], 22'd0, i_in[31:22]} :
                 i_shift_amount == 8'd23  ? {i_in[22], 23'd0, i_in[31:23]} :
                 i_shift_amount == 8'd24  ? {i_in[23], 24'd0, i_in[31:24]} :
                 i_shift_amount == 8'd25  ? {i_in[24], 25'd0, i_in[31:25]} :
                 i_shift_amount == 8'd26  ? {i_in[25], 26'd0, i_in[31:26]} :
                 i_shift_amount == 8'd27  ? {i_in[26], 27'd0, i_in[31:27]} :
                 i_shift_amount == 8'd28  ? {i_in[27], 28'd0, i_in[31:28]} :
                 i_shift_amount == 8'd29  ? {i_in[28], 29'd0, i_in[31:29]} :

                 i_shift_amount == 8'd30  ? {i_in[29], 30'd0, i_in[31:30]} :
                 i_shift_amount == 8'd31  ? {i_in[30], 31'd0, i_in[31   ]} :
                 i_shift_amount == 8'd32  ? {i_in[31], 32'd0             } :
                                            {1'd0,     32'd0             } ;  // > 32


// The form of the shift field which might be expected to give ASR #0 is used to encode
// ASR #32. Bit 31 of Rm is again used as the carry output, and each bit of operand 2 is
// also equal to bit 31 of Rm. The result is therefore all ones or all zeros, according to
// the value of bit 31 of Rm.

                                          // carry out, < -------- out ---------->
assign asr_out = i_shift_imm_zero         ? {i_in[31], {32{i_in[31]}}             } :

                 i_shift_amount == 8'd 0  ? {i_carry_in, i_in                     } :  // fall through case
                 i_shift_amount == 8'd 1  ? {i_in[ 0], { 2{i_in[31]}}, i_in[30: 1]} :
                 i_shift_amount == 8'd 2  ? {i_in[ 1], { 3{i_in[31]}}, i_in[30: 2]} :
                 i_shift_amount == 8'd 3  ? {i_in[ 2], { 4{i_in[31]}}, i_in[30: 3]} :
                 i_shift_amount == 8'd 4  ? {i_in[ 3], { 5{i_in[31]}}, i_in[30: 4]} :
                 i_shift_amount == 8'd 5  ? {i_in[ 4], { 6{i_in[31]}}, i_in[30: 5]} :
                 i_shift_amount == 8'd 6  ? {i_in[ 5], { 7{i_in[31]}}, i_in[30: 6]} :
                 i_shift_amount == 8'd 7  ? {i_in[ 6], { 8{i_in[31]}}, i_in[30: 7]} :
                 i_shift_amount == 8'd 8  ? {i_in[ 7], { 9{i_in[31]}}, i_in[30: 8]} :
                 i_shift_amount == 8'd 9  ? {i_in[ 8], {10{i_in[31]}}, i_in[30: 9]} :
                    
                 i_shift_amount == 8'd10  ? {i_in[ 9], {11{i_in[31]}}, i_in[30:10]} :
                 i_shift_amount == 8'd11  ? {i_in[10], {12{i_in[31]}}, i_in[30:11]} :
                 i_shift_amount == 8'd12  ? {i_in[11], {13{i_in[31]}}, i_in[30:12]} :
                 i_shift_amount == 8'd13  ? {i_in[12], {14{i_in[31]}}, i_in[30:13]} :
                 i_shift_amount == 8'd14  ? {i_in[13], {15{i_in[31]}}, i_in[30:14]} :
                 i_shift_amount == 8'd15  ? {i_in[14], {16{i_in[31]}}, i_in[30:15]} :
                 i_shift_amount == 8'd16  ? {i_in[15], {17{i_in[31]}}, i_in[30:16]} :
                 i_shift_amount == 8'd17  ? {i_in[16], {18{i_in[31]}}, i_in[30:17]} :
                 i_shift_amount == 8'd18  ? {i_in[17], {19{i_in[31]}}, i_in[30:18]} :
                 i_shift_amount == 8'd19  ? {i_in[18], {20{i_in[31]}}, i_in[30:19]} :

                 i_shift_amount == 8'd20  ? {i_in[19], {21{i_in[31]}}, i_in[30:20]} :
                 i_shift_amount == 8'd21  ? {i_in[20], {22{i_in[31]}}, i_in[30:21]} :
                 i_shift_amount == 8'd22  ? {i_in[21], {23{i_in[31]}}, i_in[30:22]} :
                 i_shift_amount == 8'd23  ? {i_in[22], {24{i_in[31]}}, i_in[30:23]} :
                 i_shift_amount == 8'd24  ? {i_in[23], {25{i_in[31]}}, i_in[30:24]} :
                 i_shift_amount == 8'd25  ? {i_in[24], {26{i_in[31]}}, i_in[30:25]} :
                 i_shift_amount == 8'd26  ? {i_in[25], {27{i_in[31]}}, i_in[30:26]} :
                 i_shift_amount == 8'd27  ? {i_in[26], {28{i_in[31]}}, i_in[30:27]} :
                 i_shift_amount == 8'd28  ? {i_in[27], {29{i_in[31]}}, i_in[30:28]} :
                 i_shift_amount == 8'd29  ? {i_in[28], {30{i_in[31]}}, i_in[30:29]} :

                 i_shift_amount == 8'd30  ? {i_in[29], {31{i_in[31]}}, i_in[30   ]} :
                 i_shift_amount == 8'd31  ? {i_in[30], {32{i_in[31]}}             } :
                                            {i_in[31], {32{i_in[31]}}             } ; // >= 32
                                            

                                          // carry out, < ------- out --------->
assign ror_out = i_shift_imm_zero              ? {i_in[ 0], i_carry_in,  i_in[31: 1]} :  // RXR, (ROR w/ imm 0)

                 i_shift_amount[7:0] == 8'd 0  ? {i_carry_in, i_in                  } :  // fall through case
                 
                 i_shift_amount[4:0] == 5'd 0  ? {i_in[31], i_in                    } :  // Rs > 31
                 i_shift_amount[4:0] == 5'd 1  ? {i_in[ 0], i_in[    0], i_in[31: 1]} :
                 i_shift_amount[4:0] == 5'd 2  ? {i_in[ 1], i_in[ 1: 0], i_in[31: 2]} :
                 i_shift_amount[4:0] == 5'd 3  ? {i_in[ 2], i_in[ 2: 0], i_in[31: 3]} :
                 i_shift_amount[4:0] == 5'd 4  ? {i_in[ 3], i_in[ 3: 0], i_in[31: 4]} :
                 i_shift_amount[4:0] == 5'd 5  ? {i_in[ 4], i_in[ 4: 0], i_in[31: 5]} :
                 i_shift_amount[4:0] == 5'd 6  ? {i_in[ 5], i_in[ 5: 0], i_in[31: 6]} :
                 i_shift_amount[4:0] == 5'd 7  ? {i_in[ 6], i_in[ 6: 0], i_in[31: 7]} :
                 i_shift_amount[4:0] == 5'd 8  ? {i_in[ 7], i_in[ 7: 0], i_in[31: 8]} :
                 i_shift_amount[4:0] == 5'd 9  ? {i_in[ 8], i_in[ 8: 0], i_in[31: 9]} :
                    
                 i_shift_amount[4:0] == 5'd10  ? {i_in[ 9], i_in[ 9: 0], i_in[31:10]} :
                 i_shift_amount[4:0] == 5'd11  ? {i_in[10], i_in[10: 0], i_in[31:11]} :
                 i_shift_amount[4:0] == 5'd12  ? {i_in[11], i_in[11: 0], i_in[31:12]} :
                 i_shift_amount[4:0] == 5'd13  ? {i_in[12], i_in[12: 0], i_in[31:13]} :
                 i_shift_amount[4:0] == 5'd14  ? {i_in[13], i_in[13: 0], i_in[31:14]} :
                 i_shift_amount[4:0] == 5'd15  ? {i_in[14], i_in[14: 0], i_in[31:15]} :
                 i_shift_amount[4:0] == 5'd16  ? {i_in[15], i_in[15: 0], i_in[31:16]} :
                 i_shift_amount[4:0] == 5'd17  ? {i_in[16], i_in[16: 0], i_in[31:17]} :
                 i_shift_amount[4:0] == 5'd18  ? {i_in[17], i_in[17: 0], i_in[31:18]} :
                 i_shift_amount[4:0] == 5'd19  ? {i_in[18], i_in[18: 0], i_in[31:19]} :

                 i_shift_amount[4:0] == 5'd20  ? {i_in[19], i_in[19: 0], i_in[31:20]} :
                 i_shift_amount[4:0] == 5'd21  ? {i_in[20], i_in[20: 0], i_in[31:21]} :
                 i_shift_amount[4:0] == 5'd22  ? {i_in[21], i_in[21: 0], i_in[31:22]} :
                 i_shift_amount[4:0] == 5'd23  ? {i_in[22], i_in[22: 0], i_in[31:23]} :
                 i_shift_amount[4:0] == 5'd24  ? {i_in[23], i_in[23: 0], i_in[31:24]} :
                 i_shift_amount[4:0] == 5'd25  ? {i_in[24], i_in[24: 0], i_in[31:25]} :
                 i_shift_amount[4:0] == 5'd26  ? {i_in[25], i_in[25: 0], i_in[31:26]} :
                 i_shift_amount[4:0] == 5'd27  ? {i_in[26], i_in[26: 0], i_in[31:27]} :
                 i_shift_amount[4:0] == 5'd28  ? {i_in[27], i_in[27: 0], i_in[31:28]} :
                 i_shift_amount[4:0] == 5'd29  ? {i_in[28], i_in[28: 0], i_in[31:29]} :

                 i_shift_amount[4:0] == 5'd30  ? {i_in[29], i_in[29: 0], i_in[31:30]} :
                                                 {i_in[30], i_in[30: 0], i_in[31:31]} ;
                 

 
assign {o_carry_out, o_out} = i_function == LSL ? lsl_out :
                              i_function == LSR ? lsr_out :
                              i_function == ASR ? asr_out :
                                                  ror_out ;

endmodule


