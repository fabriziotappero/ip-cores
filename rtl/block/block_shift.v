/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

`include "defines.v"

module block_shift(
    input   [6:0]   rf_cmd,
    input   [31:0]  rf_instr,
    input   [31:0]  rf_a,
    input   [31:0]  rf_b,
    
    output  [31:0]  shift_left,
    output  [31:0]  shift_right
);

//------------------------------------------------------------------------------

wire [4:0] shift_left_index = (rf_cmd == `CMD_3arg_sllv)? rf_a[4:0] : rf_instr[10:6];

assign shift_left =
    (shift_left_index == 5'd0)?   rf_b :
    (shift_left_index == 5'd1)?   { rf_b[30:0], 1'b0 } :
    (shift_left_index == 5'd2)?   { rf_b[29:0], 2'b0 } :
    (shift_left_index == 5'd3)?   { rf_b[28:0], 3'b0 } :
    (shift_left_index == 5'd4)?   { rf_b[27:0], 4'b0 } :
    (shift_left_index == 5'd5)?   { rf_b[26:0], 5'b0 } :
    (shift_left_index == 5'd6)?   { rf_b[25:0], 6'b0 } :
    (shift_left_index == 5'd7)?   { rf_b[24:0], 7'b0 } :
    (shift_left_index == 5'd8)?   { rf_b[23:0], 8'b0 } :
    (shift_left_index == 5'd9)?   { rf_b[22:0], 9'b0 } :
    (shift_left_index == 5'd10)?  { rf_b[21:0], 10'b0 } :
    (shift_left_index == 5'd11)?  { rf_b[20:0], 11'b0 } :
    (shift_left_index == 5'd12)?  { rf_b[19:0], 12'b0 } :
    (shift_left_index == 5'd13)?  { rf_b[18:0], 13'b0 } :
    (shift_left_index == 5'd14)?  { rf_b[17:0], 14'b0 } :
    (shift_left_index == 5'd15)?  { rf_b[16:0], 15'b0 } :
    (shift_left_index == 5'd16)?  { rf_b[15:0], 16'b0 } :
    (shift_left_index == 5'd17)?  { rf_b[14:0], 17'b0 } :
    (shift_left_index == 5'd18)?  { rf_b[13:0], 18'b0 } :
    (shift_left_index == 5'd19)?  { rf_b[12:0], 19'b0 } :
    (shift_left_index == 5'd20)?  { rf_b[11:0], 20'b0 } :
    (shift_left_index == 5'd21)?  { rf_b[10:0], 21'b0 } :
    (shift_left_index == 5'd22)?  { rf_b[9:0],  22'b0 } :
    (shift_left_index == 5'd23)?  { rf_b[8:0],  23'b0 } :
    (shift_left_index == 5'd24)?  { rf_b[7:0],  24'b0 } :
    (shift_left_index == 5'd25)?  { rf_b[6:0],  25'b0 } :
    (shift_left_index == 5'd26)?  { rf_b[5:0],  26'b0 } :
    (shift_left_index == 5'd27)?  { rf_b[4:0],  27'b0 } :
    (shift_left_index == 5'd28)?  { rf_b[3:0],  28'b0 } :
    (shift_left_index == 5'd29)?  { rf_b[2:0],  29'b0 } :
    (shift_left_index == 5'd30)?  { rf_b[1:0],  30'b0 } :
                                  { rf_b[0],    31'b0 };

wire       shift_right_arith = rf_cmd == `CMD_3arg_srav || rf_cmd == `CMD_sra;
wire [4:0] shift_right_index = (rf_cmd == `CMD_3arg_srav || rf_cmd == `CMD_3arg_srlv)? rf_a[4:0] : rf_instr[10:6];

assign shift_right =
    (shift_right_index == 5'd0)?  rf_b :
    (shift_right_index == 5'd1)?  { {1 {shift_right_arith & rf_b[31]}}, rf_b[31:1] } :
    (shift_right_index == 5'd2)?  { {2 {shift_right_arith & rf_b[31]}}, rf_b[31:2] } :
    (shift_right_index == 5'd3)?  { {3 {shift_right_arith & rf_b[31]}}, rf_b[31:3] } :
    (shift_right_index == 5'd4)?  { {4 {shift_right_arith & rf_b[31]}}, rf_b[31:4] } :
    (shift_right_index == 5'd5)?  { {5 {shift_right_arith & rf_b[31]}}, rf_b[31:5] } :
    (shift_right_index == 5'd6)?  { {6 {shift_right_arith & rf_b[31]}}, rf_b[31:6] } :
    (shift_right_index == 5'd7)?  { {7 {shift_right_arith & rf_b[31]}}, rf_b[31:7] } :
    (shift_right_index == 5'd8)?  { {8 {shift_right_arith & rf_b[31]}}, rf_b[31:8] } :
    (shift_right_index == 5'd9)?  { {9 {shift_right_arith & rf_b[31]}}, rf_b[31:9] } :
    (shift_right_index == 5'd10)? { {10{shift_right_arith & rf_b[31]}}, rf_b[31:10] } :
    (shift_right_index == 5'd11)? { {11{shift_right_arith & rf_b[31]}}, rf_b[31:11] } :
    (shift_right_index == 5'd12)? { {12{shift_right_arith & rf_b[31]}}, rf_b[31:12] } :
    (shift_right_index == 5'd13)? { {13{shift_right_arith & rf_b[31]}}, rf_b[31:13] } :
    (shift_right_index == 5'd14)? { {14{shift_right_arith & rf_b[31]}}, rf_b[31:14] } :
    (shift_right_index == 5'd15)? { {15{shift_right_arith & rf_b[31]}}, rf_b[31:15] } :
    (shift_right_index == 5'd16)? { {16{shift_right_arith & rf_b[31]}}, rf_b[31:16] } :
    (shift_right_index == 5'd17)? { {17{shift_right_arith & rf_b[31]}}, rf_b[31:17] } :
    (shift_right_index == 5'd18)? { {18{shift_right_arith & rf_b[31]}}, rf_b[31:18] } :
    (shift_right_index == 5'd19)? { {19{shift_right_arith & rf_b[31]}}, rf_b[31:19] } :
    (shift_right_index == 5'd20)? { {20{shift_right_arith & rf_b[31]}}, rf_b[31:20] } :
    (shift_right_index == 5'd21)? { {21{shift_right_arith & rf_b[31]}}, rf_b[31:21] } :
    (shift_right_index == 5'd22)? { {22{shift_right_arith & rf_b[31]}}, rf_b[31:22] } :
    (shift_right_index == 5'd23)? { {23{shift_right_arith & rf_b[31]}}, rf_b[31:23] } :
    (shift_right_index == 5'd24)? { {24{shift_right_arith & rf_b[31]}}, rf_b[31:24] } :
    (shift_right_index == 5'd25)? { {25{shift_right_arith & rf_b[31]}}, rf_b[31:25] } :
    (shift_right_index == 5'd26)? { {26{shift_right_arith & rf_b[31]}}, rf_b[31:26] } :
    (shift_right_index == 5'd27)? { {27{shift_right_arith & rf_b[31]}}, rf_b[31:27] } :
    (shift_right_index == 5'd28)? { {28{shift_right_arith & rf_b[31]}}, rf_b[31:28] } :
    (shift_right_index == 5'd29)? { {29{shift_right_arith & rf_b[31]}}, rf_b[31:29] } :
    (shift_right_index == 5'd30)? { {30{shift_right_arith & rf_b[31]}}, rf_b[31:30] } :
                                  { {31{shift_right_arith & rf_b[31]}}, rf_b[31] };

//------------------------------------------------------------------------------
// synthesis translate_off
wire _unused_ok = &{ 1'b0, rf_instr[31:11], rf_instr[5:0], rf_a[31:5], 1'b0 };
// synthesis translate_on
//------------------------------------------------------------------------------

endmodule
