//////////////////////////////////////////////////////////////////
//                                                              //
//  Debug Functions                                             //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  A bunch of non-synthesizable testbench functions            //
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

// Testbench Functions used in more than one module


function [31:0] hex_chars_to_32bits;
input [8*8-1:0] hex_chars;
begin
hex_chars_to_32bits[31:28] = hex_chars_to_4bits (hex_chars[8*8-1:7*8]);
hex_chars_to_32bits[27:24] = hex_chars_to_4bits (hex_chars[7*8-1:6*8]);
hex_chars_to_32bits[23:20] = hex_chars_to_4bits (hex_chars[6*8-1:5*8]);
hex_chars_to_32bits[19:16] = hex_chars_to_4bits (hex_chars[5*8-1:4*8]);
hex_chars_to_32bits[15:12] = hex_chars_to_4bits (hex_chars[4*8-1:3*8]);
hex_chars_to_32bits[11: 8] = hex_chars_to_4bits (hex_chars[3*8-1:2*8]);
hex_chars_to_32bits[ 7: 4] = hex_chars_to_4bits (hex_chars[2*8-1:1*8]);
hex_chars_to_32bits[ 3: 0] = hex_chars_to_4bits (hex_chars[1*8-1:  0]);
end
endfunction


function [7:0] hex_chars_to_8bits;
input [8*2-1:0] hex_chars;
begin
hex_chars_to_8bits[ 7: 4] = hex_chars_to_4bits (hex_chars[2*8-1:1*8]);
hex_chars_to_8bits[ 3: 0] = hex_chars_to_4bits (hex_chars[1*8-1:  0]);
end
endfunction


function [3:0] hex_chars_to_4bits;
input [7:0] hex_chars;
begin
case (hex_chars)
    "0" : hex_chars_to_4bits  = 4'h0;
    "1" : hex_chars_to_4bits  = 4'h1;
    "2" : hex_chars_to_4bits  = 4'h2;
    "3" : hex_chars_to_4bits  = 4'h3;
    "4" : hex_chars_to_4bits  = 4'h4;
    "5" : hex_chars_to_4bits  = 4'h5;
    "6" : hex_chars_to_4bits  = 4'h6;
    "7" : hex_chars_to_4bits  = 4'h7;
    "8" : hex_chars_to_4bits  = 4'h8;
    "9" : hex_chars_to_4bits  = 4'h9;
    "a" : hex_chars_to_4bits  = 4'ha;
    "b" : hex_chars_to_4bits  = 4'hb;
    "c" : hex_chars_to_4bits  = 4'hc;
    "d" : hex_chars_to_4bits  = 4'hd;
    "e" : hex_chars_to_4bits  = 4'he;
    "f" : hex_chars_to_4bits  = 4'hf;
    "A" : hex_chars_to_4bits  = 4'ha;
    "B" : hex_chars_to_4bits  = 4'hb;
    "C" : hex_chars_to_4bits  = 4'hc;
    "D" : hex_chars_to_4bits  = 4'hd;
    "E" : hex_chars_to_4bits  = 4'he;
    "F" : hex_chars_to_4bits  = 4'hf;
endcase
end
endfunction


function [120*8-1:0] align_line;   
input [120*8-1:0] line;
begin
case (1'd1)
    line[1  *8-1:    0] == 8'd0 : align_line = 960'd0;
    line[2  *8-1:1  *8] == 8'd0 : align_line = {line[1  *8-1:  0], 952'd0};
    line[3  *8-1:2  *8] == 8'd0 : align_line = {line[2  *8-1:  0], 944'd0};
    line[4  *8-1:3  *8] == 8'd0 : align_line = {line[3  *8-1:  0], 936'd0};
    line[5  *8-1:4  *8] == 8'd0 : align_line = {line[4  *8-1:  0], 928'd0};
    line[6  *8-1:5  *8] == 8'd0 : align_line = {line[5  *8-1:  0], 920'd0};
    line[7  *8-1:6  *8] == 8'd0 : align_line = {line[6  *8-1:  0], 912'd0};
    line[8  *8-1:7  *8] == 8'd0 : align_line = {line[7  *8-1:  0], 904'd0};
    line[9  *8-1:8  *8] == 8'd0 : align_line = {line[8  *8-1:  0], 896'd0};
    line[10 *8-1:9  *8] == 8'd0 : align_line = {line[9  *8-1:  0], 888'd0};
    line[11 *8-1:10 *8] == 8'd0 : align_line = {line[10 *8-1:  0], 880'd0};
    line[12 *8-1:11 *8] == 8'd0 : align_line = {line[11 *8-1:  0], 872'd0};
    line[13 *8-1:12 *8] == 8'd0 : align_line = {line[12 *8-1:  0], 864'd0};
    line[14 *8-1:13 *8] == 8'd0 : align_line = {line[13 *8-1:  0], 856'd0};
    line[15 *8-1:14 *8] == 8'd0 : align_line = {line[14 *8-1:  0], 848'd0};
    line[16 *8-1:15 *8] == 8'd0 : align_line = {line[15 *8-1:  0], 840'd0};
    line[17 *8-1:16 *8] == 8'd0 : align_line = {line[16 *8-1:  0], 832'd0};
    line[18 *8-1:17 *8] == 8'd0 : align_line = {line[17 *8-1:  0], 824'd0};
    line[19 *8-1:18 *8] == 8'd0 : align_line = {line[18 *8-1:  0], 816'd0};
    line[20 *8-1:19 *8] == 8'd0 : align_line = {line[19 *8-1:  0], 808'd0};
    line[21 *8-1:20 *8] == 8'd0 : align_line = {line[20 *8-1:  0], 800'd0};
    line[22 *8-1:21 *8] == 8'd0 : align_line = {line[21 *8-1:  0], 792'd0};
    line[23 *8-1:22 *8] == 8'd0 : align_line = {line[22 *8-1:  0], 784'd0};
    line[24 *8-1:23 *8] == 8'd0 : align_line = {line[23 *8-1:  0], 776'd0};
    line[25 *8-1:24 *8] == 8'd0 : align_line = {line[24 *8-1:  0], 768'd0};
    line[26 *8-1:25 *8] == 8'd0 : align_line = {line[25 *8-1:  0], 760'd0};
    line[27 *8-1:26 *8] == 8'd0 : align_line = {line[26 *8-1:  0], 752'd0};
    line[28 *8-1:27 *8] == 8'd0 : align_line = {line[27 *8-1:  0], 744'd0};
    line[29 *8-1:28 *8] == 8'd0 : align_line = {line[28 *8-1:  0], 736'd0};
    line[30 *8-1:29 *8] == 8'd0 : align_line = {line[29 *8-1:  0], 728'd0};
    line[31 *8-1:30 *8] == 8'd0 : align_line = {line[30 *8-1:  0], 720'd0};
    line[32 *8-1:31 *8] == 8'd0 : align_line = {line[31 *8-1:  0], 712'd0};
    line[33 *8-1:32 *8] == 8'd0 : align_line = {line[32 *8-1:  0], 704'd0};
    line[34 *8-1:33 *8] == 8'd0 : align_line = {line[33 *8-1:  0], 696'd0};
    line[35 *8-1:34 *8] == 8'd0 : align_line = {line[34 *8-1:  0], 688'd0};
    line[36 *8-1:35 *8] == 8'd0 : align_line = {line[35 *8-1:  0], 680'd0};
    line[37 *8-1:36 *8] == 8'd0 : align_line = {line[36 *8-1:  0], 672'd0};
    line[38 *8-1:37 *8] == 8'd0 : align_line = {line[37 *8-1:  0], 664'd0};
    line[39 *8-1:38 *8] == 8'd0 : align_line = {line[38 *8-1:  0], 656'd0};
    line[40 *8-1:39 *8] == 8'd0 : align_line = {line[39 *8-1:  0], 648'd0};
    line[41 *8-1:40 *8] == 8'd0 : align_line = {line[40 *8-1:  0], 640'd0};
    line[42 *8-1:41 *8] == 8'd0 : align_line = {line[41 *8-1:  0], 632'd0};
    line[43 *8-1:42 *8] == 8'd0 : align_line = {line[42 *8-1:  0], 624'd0};
    line[44 *8-1:43 *8] == 8'd0 : align_line = {line[43 *8-1:  0], 616'd0};
    line[45 *8-1:44 *8] == 8'd0 : align_line = {line[44 *8-1:  0], 608'd0};
    line[46 *8-1:45 *8] == 8'd0 : align_line = {line[45 *8-1:  0], 600'd0};
    line[47 *8-1:46 *8] == 8'd0 : align_line = {line[46 *8-1:  0], 592'd0};
    line[48 *8-1:47 *8] == 8'd0 : align_line = {line[47 *8-1:  0], 584'd0};
    line[49 *8-1:48 *8] == 8'd0 : align_line = {line[48 *8-1:  0], 576'd0};
    line[50 *8-1:49 *8] == 8'd0 : align_line = {line[49 *8-1:  0], 568'd0};
    line[51 *8-1:50 *8] == 8'd0 : align_line = {line[50 *8-1:  0], 560'd0};
    line[52 *8-1:51 *8] == 8'd0 : align_line = {line[51 *8-1:  0], 552'd0};
    line[53 *8-1:52 *8] == 8'd0 : align_line = {line[52 *8-1:  0], 544'd0};
    line[54 *8-1:53 *8] == 8'd0 : align_line = {line[53 *8-1:  0], 536'd0};
    line[55 *8-1:54 *8] == 8'd0 : align_line = {line[54 *8-1:  0], 528'd0};
    line[56 *8-1:55 *8] == 8'd0 : align_line = {line[55 *8-1:  0], 520'd0};
    line[57 *8-1:56 *8] == 8'd0 : align_line = {line[56 *8-1:  0], 512'd0};
    line[58 *8-1:57 *8] == 8'd0 : align_line = {line[57 *8-1:  0], 504'd0};
    line[59 *8-1:58 *8] == 8'd0 : align_line = {line[58 *8-1:  0], 496'd0};
    line[60 *8-1:59 *8] == 8'd0 : align_line = {line[59 *8-1:  0], 488'd0};
    line[61 *8-1:60 *8] == 8'd0 : align_line = {line[60 *8-1:  0], 480'd0};
    line[62 *8-1:61 *8] == 8'd0 : align_line = {line[61 *8-1:  0], 472'd0};
    line[63 *8-1:62 *8] == 8'd0 : align_line = {line[62 *8-1:  0], 464'd0};
    line[64 *8-1:63 *8] == 8'd0 : align_line = {line[63 *8-1:  0], 456'd0};
    line[65 *8-1:64 *8] == 8'd0 : align_line = {line[64 *8-1:  0], 448'd0};
    line[66 *8-1:65 *8] == 8'd0 : align_line = {line[65 *8-1:  0], 440'd0};
    line[67 *8-1:66 *8] == 8'd0 : align_line = {line[66 *8-1:  0], 432'd0};
    line[68 *8-1:67 *8] == 8'd0 : align_line = {line[67 *8-1:  0], 424'd0};
    line[69 *8-1:68 *8] == 8'd0 : align_line = {line[68 *8-1:  0], 416'd0};
    line[70 *8-1:69 *8] == 8'd0 : align_line = {line[69 *8-1:  0], 408'd0};
    line[71 *8-1:70 *8] == 8'd0 : align_line = {line[70 *8-1:  0], 400'd0};
    line[72 *8-1:71 *8] == 8'd0 : align_line = {line[71 *8-1:  0], 392'd0};
    line[73 *8-1:72 *8] == 8'd0 : align_line = {line[72 *8-1:  0], 384'd0};
    line[74 *8-1:73 *8] == 8'd0 : align_line = {line[73 *8-1:  0], 376'd0};
    line[75 *8-1:74 *8] == 8'd0 : align_line = {line[74 *8-1:  0], 368'd0};
    line[76 *8-1:75 *8] == 8'd0 : align_line = {line[75 *8-1:  0], 360'd0};
    line[77 *8-1:76 *8] == 8'd0 : align_line = {line[76 *8-1:  0], 352'd0};
    line[78 *8-1:77 *8] == 8'd0 : align_line = {line[77 *8-1:  0], 344'd0};
    line[79 *8-1:78 *8] == 8'd0 : align_line = {line[78 *8-1:  0], 336'd0};
    line[80 *8-1:79 *8] == 8'd0 : align_line = {line[79 *8-1:  0], 328'd0};
    line[81 *8-1:80 *8] == 8'd0 : align_line = {line[80 *8-1:  0], 320'd0};
    line[82 *8-1:81 *8] == 8'd0 : align_line = {line[81 *8-1:  0], 312'd0};
    line[83 *8-1:82 *8] == 8'd0 : align_line = {line[82 *8-1:  0], 304'd0};
    line[84 *8-1:83 *8] == 8'd0 : align_line = {line[83 *8-1:  0], 296'd0};
    line[85 *8-1:84 *8] == 8'd0 : align_line = {line[84 *8-1:  0], 288'd0};
    line[86 *8-1:85 *8] == 8'd0 : align_line = {line[85 *8-1:  0], 280'd0};
    line[87 *8-1:86 *8] == 8'd0 : align_line = {line[86 *8-1:  0], 272'd0};
    line[88 *8-1:87 *8] == 8'd0 : align_line = {line[87 *8-1:  0], 264'd0};
    line[89 *8-1:88 *8] == 8'd0 : align_line = {line[88 *8-1:  0], 256'd0};
    line[90 *8-1:89 *8] == 8'd0 : align_line = {line[89 *8-1:  0], 248'd0};
    line[91 *8-1:90 *8] == 8'd0 : align_line = {line[90 *8-1:  0], 240'd0};
    line[92 *8-1:91 *8] == 8'd0 : align_line = {line[91 *8-1:  0], 232'd0};
    line[93 *8-1:92 *8] == 8'd0 : align_line = {line[92 *8-1:  0], 224'd0};
    line[94 *8-1:93 *8] == 8'd0 : align_line = {line[93 *8-1:  0], 216'd0};
    line[95 *8-1:94 *8] == 8'd0 : align_line = {line[94 *8-1:  0], 208'd0};
    line[96 *8-1:95 *8] == 8'd0 : align_line = {line[95 *8-1:  0], 200'd0};
    line[97 *8-1:96 *8] == 8'd0 : align_line = {line[96 *8-1:  0], 192'd0};
    line[98 *8-1:97 *8] == 8'd0 : align_line = {line[97 *8-1:  0], 184'd0};
    line[99 *8-1:98 *8] == 8'd0 : align_line = {line[98 *8-1:  0], 176'd0};
    line[100*8-1:99 *8] == 8'd0 : align_line = {line[99 *8-1:  0], 168'd0};
    line[101*8-1:100*8] == 8'd0 : align_line = {line[100*8-1:  0], 160'd0};
    line[102*8-1:101*8] == 8'd0 : align_line = {line[101*8-1:  0], 152'd0};
    line[103*8-1:102*8] == 8'd0 : align_line = {line[102*8-1:  0], 144'd0};
    line[104*8-1:103*8] == 8'd0 : align_line = {line[103*8-1:  0], 136'd0};
    line[105*8-1:104*8] == 8'd0 : align_line = {line[104*8-1:  0], 128'd0};
    line[106*8-1:105*8] == 8'd0 : align_line = {line[105*8-1:  0], 120'd0};
    line[107*8-1:106*8] == 8'd0 : align_line = {line[106*8-1:  0], 112'd0};
    line[108*8-1:107*8] == 8'd0 : align_line = {line[107*8-1:  0], 104'd0};
    line[109*8-1:108*8] == 8'd0 : align_line = {line[108*8-1:  0], 96'd0};
    line[110*8-1:109*8] == 8'd0 : align_line = {line[109*8-1:  0], 88'd0};
    line[111*8-1:110*8] == 8'd0 : align_line = {line[110*8-1:  0], 80'd0};
    line[112*8-1:111*8] == 8'd0 : align_line = {line[111*8-1:  0], 72'd0};
    line[113*8-1:112*8] == 8'd0 : align_line = {line[112*8-1:  0], 64'd0};
    line[114*8-1:113*8] == 8'd0 : align_line = {line[113*8-1:  0], 56'd0};
    line[115*8-1:114*8] == 8'd0 : align_line = {line[114*8-1:  0], 48'd0};
    line[116*8-1:115*8] == 8'd0 : align_line = {line[115*8-1:  0], 40'd0};
    line[117*8-1:116*8] == 8'd0 : align_line = {line[116*8-1:  0], 32'd0};
    line[118*8-1:117*8] == 8'd0 : align_line = {line[117*8-1:  0], 24'd0};
    line[119*8-1:118*8] == 8'd0 : align_line = {line[118*8-1:  0], 16'd0};
    line[120*8-1:119*8] == 8'd0 : align_line = {line[119*8-1:  0], 8'd0};

    default:                      align_line = 960'd0;
endcase
end
endfunction

