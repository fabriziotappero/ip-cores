//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Subkey generator of key scheduler for HIGHT Crypto Core     ////
////                                                              ////
////  This file is part of the HIGHT Crypto Core project          ////
////  http://github.com/OpenSoCPlus/hight_crypto_core             ////
////  http://www.opencores.org/project,hight                      ////
////                                                              ////
////  Description                                                 ////
////  __description__                                             ////
////                                                              ////
////  Author(s):                                                  ////
////      - JoonSoo Ha, json.ha@gmail.com                         ////
////      - Younjoo Kim, younjookim.kr@gmail.com                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2015 Authors, OpenSoCPlus and OPENCORES.ORG    ////
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

module SKG(
	i_op       ,
	i_rnd_idx  ,
	i_mk       , 

	o_sk3x     ,  
	o_sk2x     ,  
	o_sk1x     ,  
	o_sk0x         
);


//=====================================
//
//          PARAMETERS 
//
//=====================================


//=====================================
//
//          I/O PORTS 
//
//=====================================
input        i_op       ;
input[4:0]   i_rnd_idx  ;
input[127:0] i_mk       ; 

output[7:0]  o_sk3x     ;  
output[7:0]  o_sk2x     ;  
output[7:0]  o_sk1x     ;  
output[7:0]  o_sk0x     ;    


//=====================================
//
//          REGISTERS
//
//=====================================


//=====================================
//
//          WIRES
//
//=====================================
// w_mk15 ~ w_mk0
wire[7:0]   w_mk15 = i_mk[127:120]; 
wire[7:0]   w_mk14 = i_mk[119:112];
wire[7:0]   w_mk13 = i_mk[111:104];
wire[7:0]   w_mk12 = i_mk[103: 96];
wire[7:0]   w_mk11 = i_mk[ 95: 88];
wire[7:0]   w_mk10 = i_mk[ 87: 80];
wire[7:0]   w_mk9  = i_mk[ 79: 72];
wire[7:0]   w_mk8  = i_mk[ 71: 64];
wire[7:0]   w_mk7  = i_mk[ 63: 56];
wire[7:0]   w_mk6  = i_mk[ 55: 48];
wire[7:0]   w_mk5  = i_mk[ 47: 40];
wire[7:0]   w_mk4  = i_mk[ 39: 32];
wire[7:0]   w_mk3  = i_mk[ 31: 24];
wire[7:0]   w_mk2  = i_mk[ 23: 16];
wire[7:0]   w_mk1  = i_mk[ 15:  8];
wire[7:0]   w_mk0  = i_mk[  7:  0];

// w_base
wire[4:0]   w_base;

// w_d3x ~ w_d0x
reg[6:0]    w_d3x;
reg[6:0]    w_d2x;
reg[6:0]    w_d1x;
reg[6:0]    w_d0x;

// w_mk3x ~ w_mk0x
reg[7:0]    w_mk3x;
reg[7:0]    w_mk2x;
reg[7:0]    w_mk1x;
reg[7:0]    w_mk0x;

// w_sk3x_tmp ~ w_sk0x_tmp
wire[7:0]   w_sk3x_tmp;
wire[7:0]   w_sk2x_tmp;
wire[7:0]   w_sk1x_tmp;
wire[7:0]   w_sk0x_tmp;


//=====================================
//
//          MAIN
//
//=====================================
// w_base
assign      w_base = (~i_op) ? i_rnd_idx         :
                               5'd31 - i_rnd_idx ;

// w_d3x
always @(w_base)
	case(w_base)
	5'd00 : w_d3x <= 7'h1b; // idx : 3
	5'd01 : w_d3x <= 7'h41; // idx : 7
	5'd02 : w_d3x <= 7'h4c; // idx : 11
	5'd03 : w_d3x <= 7'h2c; // idx : 15
	5'd04 : w_d3x <= 7'h4a; // idx : 19
	5'd05 : w_d3x <= 7'h1c; // idx : 23
	5'd06 : w_d3x <= 7'h79; // idx : 27
	5'd07 : w_d3x <= 7'h37; // idx : 31
	5'd08 : w_d3x <= 7'h0b; // idx : 35
	5'd09 : w_d3x <= 7'h50; // idx : 39
	5'd10 : w_d3x <= 7'h55; // idx : 43
	5'd11 : w_d3x <= 7'h7d; // idx : 47
	5'd12 : w_d3x <= 7'h17; // idx : 51
	5'd13 : w_d3x <= 7'h29; // idx : 55
	5'd14 : w_d3x <= 7'h62; // idx : 59
	5'd15 : w_d3x <= 7'h76; // idx : 63
	5'd16 : w_d3x <= 7'h47; // idx : 67
	5'd17 : w_d3x <= 7'h7c; // idx : 71
	5'd18 : w_d3x <= 7'h1f; // idx : 75
	5'd19 : w_d3x <= 7'h61; // idx : 79
	5'd20 : w_d3x <= 7'h6e; // idx : 83
	5'd21 : w_d3x <= 7'h1e; // idx : 87
	5'd22 : w_d3x <= 7'h69; // idx : 91
	5'd23 : w_d3x <= 7'h26; // idx : 95
	5'd24 : w_d3x <= 7'h12; // idx : 99
	5'd25 : w_d3x <= 7'h01; // idx : 103
	5'd26 : w_d3x <= 7'h08; // idx : 107
	5'd27 : w_d3x <= 7'h48; // idx : 111
	5'd28 : w_d3x <= 7'h0c; // idx : 115
	5'd29 : w_d3x <= 7'h68; // idx : 119
	5'd30 : w_d3x <= 7'h2e; // idx : 123
	5'd31 : w_d3x <= 7'h5a; // idx : 127
	endcase	

// w_d2x
always @(w_base)
	case(w_base)
	5'd00 : w_d2x <= 7'h36; // idx : 2 
	5'd01 : w_d2x <= 7'h03; // idx : 6
	5'd02 : w_d2x <= 7'h18; // idx : 10
	5'd03 : w_d2x <= 7'h59; // idx : 14
	5'd04 : w_d2x <= 7'h15; // idx : 18
	5'd05 : w_d2x <= 7'h39; // idx : 22
	5'd06 : w_d2x <= 7'h73; // idx : 26
	5'd07 : w_d2x <= 7'h6f; // idx : 30
	5'd08 : w_d2x <= 7'h16; // idx : 34
	5'd09 : w_d2x <= 7'h21; // idx : 38
	5'd10 : w_d2x <= 7'h2a; // idx : 42
	5'd11 : w_d2x <= 7'h7a; // idx : 46
	5'd12 : w_d2x <= 7'h2f; // idx : 50
	5'd13 : w_d2x <= 7'h52; // idx : 54
	5'd14 : w_d2x <= 7'h45; // idx : 58
	5'd15 : w_d2x <= 7'h6c; // idx : 62
	5'd16 : w_d2x <= 7'h0e; // idx : 66
	5'd17 : w_d2x <= 7'h78; // idx : 70
	5'd18 : w_d2x <= 7'h3f; // idx : 74
	5'd19 : w_d2x <= 7'h43; // idx : 78
	5'd20 : w_d2x <= 7'h5c; // idx : 82
	5'd21 : w_d2x <= 7'h3d; // idx : 86
	5'd22 : w_d2x <= 7'h53; // idx : 90
	5'd23 : w_d2x <= 7'h4d; // idx : 94
	5'd24 : w_d2x <= 7'h24; // idx : 98
	5'd25 : w_d2x <= 7'h02; // idx : 102
	5'd26 : w_d2x <= 7'h10; // idx : 106
	5'd27 : w_d2x <= 7'h11; // idx : 110
	5'd28 : w_d2x <= 7'h19; // idx : 114
	5'd29 : w_d2x <= 7'h51; // idx : 118
	5'd30 : w_d2x <= 7'h5d; // idx : 122
	5'd31 : w_d2x <= 7'h35; // idx : 126
	endcase	

// w_d1x
always @(w_base)
	case(w_base)
	5'd00 : w_d1x <= 7'h6d; // idx : 1
	5'd01 : w_d1x <= 7'h06; // idx : 5
	5'd02 : w_d1x <= 7'h30; // idx : 9
	5'd03 : w_d1x <= 7'h33; // idx : 13
	5'd04 : w_d1x <= 7'h2b; // idx : 17
	5'd05 : w_d1x <= 7'h72; // idx : 21
	5'd06 : w_d1x <= 7'h67; // idx : 25
	5'd07 : w_d1x <= 7'h5e; // idx : 29
	5'd08 : w_d1x <= 7'h2d; // idx : 33
	5'd09 : w_d1x <= 7'h42; // idx : 37
	5'd10 : w_d1x <= 7'h54; // idx : 41
	5'd11 : w_d1x <= 7'h75; // idx : 45
	5'd12 : w_d1x <= 7'h5f; // idx : 49
	5'd13 : w_d1x <= 7'h25; // idx : 53
	5'd14 : w_d1x <= 7'h0a; // idx : 57
	5'd15 : w_d1x <= 7'h58; // idx : 61
	5'd16 : w_d1x <= 7'h1d; // idx : 65
	5'd17 : w_d1x <= 7'h71; // idx : 69
	5'd18 : w_d1x <= 7'h7f; // idx : 73
	5'd19 : w_d1x <= 7'h07; // idx : 77
	5'd20 : w_d1x <= 7'h38; // idx : 81
	5'd21 : w_d1x <= 7'h7b; // idx : 85
	5'd22 : w_d1x <= 7'h27; // idx : 89
	5'd23 : w_d1x <= 7'h1a; // idx : 93
	5'd24 : w_d1x <= 7'h49; // idx : 97
	5'd25 : w_d1x <= 7'h04; // idx : 101
	5'd26 : w_d1x <= 7'h20; // idx : 105
	5'd27 : w_d1x <= 7'h22; // idx : 109
	5'd28 : w_d1x <= 7'h32; // idx : 113
	5'd29 : w_d1x <= 7'h23; // idx : 117
	5'd30 : w_d1x <= 7'h3a; // idx : 121
	5'd31 : w_d1x <= 7'h6b; // idx : 125
	endcase	

// w_d0x
always @(w_base)
	case(w_base)
	5'd00 : w_d0x <= 7'h5a; // idx : 0
	5'd01 : w_d0x <= 7'h0d; // idx : 4 
	5'd02 : w_d0x <= 7'h60; // idx : 8
	5'd03 : w_d0x <= 7'h66; // idx : 12 
	5'd04 : w_d0x <= 7'h56; // idx : 16
	5'd05 : w_d0x <= 7'h65; // idx : 20
	5'd06 : w_d0x <= 7'h4e; // idx : 24
	5'd07 : w_d0x <= 7'h3c; // idx : 28
	5'd08 : w_d0x <= 7'h5b; // idx : 32
	5'd09 : w_d0x <= 7'h05; // idx : 36
	5'd10 : w_d0x <= 7'h28; // idx : 40
	5'd11 : w_d0x <= 7'h6a; // idx : 44
	5'd12 : w_d0x <= 7'h3e; // idx : 48
	5'd13 : w_d0x <= 7'h4b; // idx : 52
	5'd14 : w_d0x <= 7'h14; // idx : 56
	5'd15 : w_d0x <= 7'h31; // idx : 60
	5'd16 : w_d0x <= 7'h3b; // idx : 64
	5'd17 : w_d0x <= 7'h63; // idx : 68
	5'd18 : w_d0x <= 7'h7e; // idx : 72
	5'd19 : w_d0x <= 7'h0f; // idx : 76
	5'd20 : w_d0x <= 7'h70; // idx : 80
	5'd21 : w_d0x <= 7'h77; // idx : 84
	5'd22 : w_d0x <= 7'h4f; // idx : 88
	5'd23 : w_d0x <= 7'h34; // idx : 92
	5'd24 : w_d0x <= 7'h13; // idx : 96
	5'd25 : w_d0x <= 7'h09; // idx : 100
	5'd26 : w_d0x <= 7'h40; // idx : 104
	5'd27 : w_d0x <= 7'h44; // idx : 108
	5'd28 : w_d0x <= 7'h64; // idx : 112
	5'd29 : w_d0x <= 7'h46; // idx : 116
	5'd30 : w_d0x <= 7'h74; // idx : 120
	5'd31 : w_d0x <= 7'h57; // idx : 124
	endcase	

// w_mk3x
always @(*)
	case(w_base)
	5'd00 : w_mk3x <= w_mk3 ; // idx : 3
	5'd01 : w_mk3x <= w_mk7 ; // idx : 7    
	5'd02 : w_mk3x <= w_mk11; // idx : 11
	5'd03 : w_mk3x <= w_mk15; // idx : 15
	5'd04 : w_mk3x <= w_mk2 ; // idx : 19
	5'd05 : w_mk3x <= w_mk6 ; // idx : 23
	5'd06 : w_mk3x <= w_mk10; // idx : 27
	5'd07 : w_mk3x <= w_mk14; // idx : 31
	5'd08 : w_mk3x <= w_mk1 ; // idx : 35
	5'd09 : w_mk3x <= w_mk5 ; // idx : 39
	5'd10 : w_mk3x <= w_mk9 ; // idx : 43
	5'd11 : w_mk3x <= w_mk13; // idx : 47
	5'd12 : w_mk3x <= w_mk0 ; // idx : 51
	5'd13 : w_mk3x <= w_mk4 ; // idx : 55
	5'd14 : w_mk3x <= w_mk8 ; // idx : 59
	5'd15 : w_mk3x <= w_mk12; // idx : 63
	5'd16 : w_mk3x <= w_mk7 ; // idx : 67
	5'd17 : w_mk3x <= w_mk3 ; // idx : 71
	5'd18 : w_mk3x <= w_mk15; // idx : 75
	5'd19 : w_mk3x <= w_mk11; // idx : 79
	5'd20 : w_mk3x <= w_mk6 ; // idx : 83
	5'd21 : w_mk3x <= w_mk2 ; // idx : 87
	5'd22 : w_mk3x <= w_mk14; // idx : 91
	5'd23 : w_mk3x <= w_mk10; // idx : 95
	5'd24 : w_mk3x <= w_mk5 ; // idx : 99
	5'd25 : w_mk3x <= w_mk1 ; // idx : 103
	5'd26 : w_mk3x <= w_mk13; // idx : 107
	5'd27 : w_mk3x <= w_mk9 ; // idx : 111
	5'd28 : w_mk3x <= w_mk4 ; // idx : 115
	5'd29 : w_mk3x <= w_mk0 ; // idx : 119
	5'd30 : w_mk3x <= w_mk12; // idx : 123
	5'd31 : w_mk3x <= w_mk8 ; // idx : 127
	endcase	

// w_mk2x
always @(*)
	case(w_base)
	5'd00 : w_mk2x <= w_mk2 ; // idx : 2 
	5'd01 : w_mk2x <= w_mk6 ; // idx : 6    
	5'd02 : w_mk2x <= w_mk10; // idx : 10
	5'd03 : w_mk2x <= w_mk14; // idx : 14
	5'd04 : w_mk2x <= w_mk1 ; // idx : 18
	5'd05 : w_mk2x <= w_mk5 ; // idx : 22
	5'd06 : w_mk2x <= w_mk9 ; // idx : 26
	5'd07 : w_mk2x <= w_mk13; // idx : 30
	5'd08 : w_mk2x <= w_mk0 ; // idx : 34
	5'd09 : w_mk2x <= w_mk4 ; // idx : 38
	5'd10 : w_mk2x <= w_mk8 ; // idx : 42
	5'd11 : w_mk2x <= w_mk12; // idx : 46
	5'd12 : w_mk2x <= w_mk7 ; // idx : 50
	5'd13 : w_mk2x <= w_mk3 ; // idx : 54
	5'd14 : w_mk2x <= w_mk15; // idx : 58
	5'd15 : w_mk2x <= w_mk11; // idx : 62
	5'd16 : w_mk2x <= w_mk6 ; // idx : 66
	5'd17 : w_mk2x <= w_mk2 ; // idx : 70
	5'd18 : w_mk2x <= w_mk14; // idx : 74
	5'd19 : w_mk2x <= w_mk10; // idx : 78
	5'd20 : w_mk2x <= w_mk5 ; // idx : 82
	5'd21 : w_mk2x <= w_mk1 ; // idx : 86
	5'd22 : w_mk2x <= w_mk13; // idx : 90
	5'd23 : w_mk2x <= w_mk9 ; // idx : 94
	5'd24 : w_mk2x <= w_mk4 ; // idx : 98
	5'd25 : w_mk2x <= w_mk0 ; // idx : 102
	5'd26 : w_mk2x <= w_mk12; // idx : 106
	5'd27 : w_mk2x <= w_mk8 ; // idx : 110
	5'd28 : w_mk2x <= w_mk3 ; // idx : 114
	5'd29 : w_mk2x <= w_mk7 ; // idx : 118
	5'd30 : w_mk2x <= w_mk11; // idx : 122
	5'd31 : w_mk2x <= w_mk15; // idx : 126
	endcase	

// w_mk1x
always @(*)
	case(w_base)
	5'd00 : w_mk1x <= w_mk1 ; // idx : 1
	5'd01 : w_mk1x <= w_mk5 ; // idx : 5    
	5'd02 : w_mk1x <= w_mk9 ; // idx : 9
	5'd03 : w_mk1x <= w_mk13; // idx : 13
	5'd04 : w_mk1x <= w_mk0 ; // idx : 17
	5'd05 : w_mk1x <= w_mk4 ; // idx : 21
	5'd06 : w_mk1x <= w_mk8 ; // idx : 25
	5'd07 : w_mk1x <= w_mk12; // idx : 29
	5'd08 : w_mk1x <= w_mk7 ; // idx : 33
	5'd09 : w_mk1x <= w_mk3 ; // idx : 37
	5'd10 : w_mk1x <= w_mk15; // idx : 41
	5'd11 : w_mk1x <= w_mk11; // idx : 45
	5'd12 : w_mk1x <= w_mk6 ; // idx : 49
	5'd13 : w_mk1x <= w_mk2 ; // idx : 53
	5'd14 : w_mk1x <= w_mk14; // idx : 57
	5'd15 : w_mk1x <= w_mk10; // idx : 61
	5'd16 : w_mk1x <= w_mk5 ; // idx : 65
	5'd17 : w_mk1x <= w_mk1 ; // idx : 69
	5'd18 : w_mk1x <= w_mk13; // idx : 73
	5'd19 : w_mk1x <= w_mk9 ; // idx : 77
	5'd20 : w_mk1x <= w_mk4 ; // idx : 81
	5'd21 : w_mk1x <= w_mk0 ; // idx : 85
	5'd22 : w_mk1x <= w_mk12; // idx : 89
	5'd23 : w_mk1x <= w_mk8 ; // idx : 93
	5'd24 : w_mk1x <= w_mk3 ; // idx : 97
	5'd25 : w_mk1x <= w_mk7 ; // idx : 101
	5'd26 : w_mk1x <= w_mk11; // idx : 105
	5'd27 : w_mk1x <= w_mk15; // idx : 109
	5'd28 : w_mk1x <= w_mk2 ; // idx : 113
	5'd29 : w_mk1x <= w_mk6 ; // idx : 117
	5'd30 : w_mk1x <= w_mk10; // idx : 121
	5'd31 : w_mk1x <= w_mk14; // idx : 125
	endcase	

// w_mk0x
always @(*)
	case(w_base)
	5'd00 : w_mk0x <= w_mk0 ; // idx : 0
	5'd01 : w_mk0x <= w_mk4 ; // idx : 4    
	5'd02 : w_mk0x <= w_mk8 ; // idx : 8
	5'd03 : w_mk0x <= w_mk12; // idx : 12 
	5'd04 : w_mk0x <= w_mk7 ; // idx : 16
	5'd05 : w_mk0x <= w_mk3 ; // idx : 20
	5'd06 : w_mk0x <= w_mk15; // idx : 24
	5'd07 : w_mk0x <= w_mk11; // idx : 28
	5'd08 : w_mk0x <= w_mk6 ; // idx : 32
	5'd09 : w_mk0x <= w_mk2 ; // idx : 36
	5'd10 : w_mk0x <= w_mk14; // idx : 40
	5'd11 : w_mk0x <= w_mk10; // idx : 44
	5'd12 : w_mk0x <= w_mk5 ; // idx : 48
	5'd13 : w_mk0x <= w_mk1 ; // idx : 52
	5'd14 : w_mk0x <= w_mk13; // idx : 56
	5'd15 : w_mk0x <= w_mk9 ; // idx : 60
	5'd16 : w_mk0x <= w_mk4 ; // idx : 64
	5'd17 : w_mk0x <= w_mk0 ; // idx : 68
	5'd18 : w_mk0x <= w_mk12; // idx : 72
	5'd19 : w_mk0x <= w_mk8 ; // idx : 76
	5'd20 : w_mk0x <= w_mk3 ; // idx : 80
	5'd21 : w_mk0x <= w_mk7 ; // idx : 84
	5'd22 : w_mk0x <= w_mk11; // idx : 88
	5'd23 : w_mk0x <= w_mk15; // idx : 92
	5'd24 : w_mk0x <= w_mk2 ; // idx : 96
	5'd25 : w_mk0x <= w_mk6 ; // idx : 100
	5'd26 : w_mk0x <= w_mk10; // idx : 104
	5'd27 : w_mk0x <= w_mk14; // idx : 108
	5'd28 : w_mk0x <= w_mk1 ; // idx : 112
	5'd29 : w_mk0x <= w_mk5 ; // idx : 116
	5'd30 : w_mk0x <= w_mk9 ; // idx : 120
	5'd31 : w_mk0x <= w_mk13; // idx : 124
	endcase	

// w_sk3x_tmp
assign      w_sk3x_tmp = {1'b0,w_d3x} + w_mk3x;   

// w_sk2x_tmp
assign      w_sk2x_tmp = {1'b0,w_d2x} + w_mk2x;   

// w_sk1x_tmp
assign      w_sk1x_tmp = {1'b0,w_d1x} + w_mk1x;   

// w_sk0x_tmp
assign      w_sk0x_tmp = {1'b0,w_d0x} + w_mk0x;   

// o_sk3x
assign      o_sk3x     = (~i_op) ? w_sk3x_tmp : // i_op == 0
                                   w_sk0x_tmp ; // i_op == 1

// o_sk2x
assign      o_sk2x     = (~i_op) ? w_sk2x_tmp : // i_op == 0  
                                   w_sk1x_tmp ; // i_op == 1

// o_sk1x
assign      o_sk1x     = (~i_op) ? w_sk1x_tmp : // i_op == 0  
                                   w_sk2x_tmp ; // i_op == 1

// o_sk0x
assign      o_sk0x     = (~i_op) ? w_sk0x_tmp : // i_op == 0  
                                   w_sk3x_tmp ; // i_op == 1

endmodule








