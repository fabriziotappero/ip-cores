/**********************************************************************/
/*                                                                    */
/*             -------                                                */
/*            /   SOC  \                                              */
/*           /    GEN   \                                             */
/*          /     SIM    \                                            */
/*          ==============                                            */
/*          |            |                                            */
/*          |____________|                                            */
/*                                                                    */
/*  Clock and Reset generator for simulations                          */
/*                                                                    */
/*                                                                    */
/*  Author(s):                                                        */
/*      - John Eaton, jt_eaton@opencores.org                          */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/*    Copyright (C) <2010>  <Ouabache Design Works>                   */
/*                                                                    */
/*  This source file may be used and distributed without              */
/*  restriction provided that this copyright statement is not         */
/*  removed from the file and that any derivative work contains       */
/*  the original copyright notice and the associated disclaimer.      */
/*                                                                    */
/*  This source file is free software; you can redistribute it        */
/*  and/or modify it under the terms of the GNU Lesser General        */
/*  Public License as published by the Free Software Foundation;      */
/*  either version 2.1 of the License, or (at your option) any        */
/*  later version.                                                    */
/*                                                                    */
/*  This source is distributed in the hope that it will be            */
/*  useful, but WITHOUT ANY WARRANTY; without even the implied        */
/*  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           */
/*  PURPOSE.  See the GNU Lesser General Public License for more      */
/*  details.                                                          */
/*                                                                    */
/*  You should have received a copy of the GNU Lesser General         */
/*  Public License along with this source; if not, download it        */
/*  from http://www.opencores.org/lgpl.shtml                          */
/*                                                                    */
/**********************************************************************/
 module 
  display_model_def 
     (
 input   wire                 clk,
 input   wire                 dp,
 input   wire                 reset,
 input   wire    [ 3 :  0]        an,
 input   wire    [ 6 :  0]        seg);
reg [3:0] decode;
always@(*)
if      (seg == 7'b1000000) decode = 4'b0000;
else if (seg == 7'b1111001) decode = 4'b0001;
else if (seg == 7'b0100100) decode = 4'b0010;
else if (seg == 7'b0110000) decode = 4'b0011;
else if (seg == 7'b0011001) decode = 4'b0100;
else if (seg == 7'b0010010) decode = 4'b0101;
else if (seg == 7'b0000010) decode = 4'b0110;
else if (seg == 7'b1111000) decode = 4'b0111;
else if (seg == 7'b0000000) decode = 4'b1000;
else if (seg == 7'b0011000) decode = 4'b1001;
else if (seg == 7'b0001000) decode = 4'b1010;
else if (seg == 7'b0000011) decode = 4'b1011;
else if (seg == 7'b1000110) decode = 4'b1100;
else if (seg == 7'b0100001) decode = 4'b1101;
else if (seg == 7'b0000110) decode = 4'b1110;
else                        decode = 4'b1111;
reg [3:0] segment0;
reg [3:0] segment1;
reg [3:0] segment2;
reg [3:0] segment3;
always@(posedge clk)
if(reset)             segment0 <= 4'h0;
else
if(!an[0])            segment0 <= decode;
else                  segment0 <= segment0;
always@(posedge clk)
if(reset)             segment1 <= 4'h0;
else
if(!an[1])            segment1 <= decode;
else                  segment1 <= segment1;
always@(posedge clk)
if(reset)             segment2 <= 4'h0;
else
if(!an[2])            segment2 <= decode;
else                  segment2 <= segment2;
always@(posedge clk)
if(reset)             segment3 <= 4'h0;
else
if(!an[3])            segment3 <= decode;
else                  segment3 <= segment3;
  endmodule
