//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Random Number Generator                                     ////
////                                                              ////
////  This file is part of the SystemC RNG                        ////
////                                                              ////
////  Description:                                                ////
////                                                              ////
////  Implementation of random number generator                   ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, javier.castillo@urjc.es              ////
////                                                              ////
////  This core is provided by Universidad Rey Juan Carlos        ////
////  http://www.escet.urjc.es/~jmartine                          ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2005/07/30 20:07:26  jcastillo
// Correct bit 28. Correct assignation to bit 31
//
// Revision 1.2  2005/07/29 09:13:06  jcastillo
// Correct bit 28 of CASR
//
// Revision 1.1  2004/09/23 09:43:06  jcastillo
// Verilog first import
//

`timescale 10ns/1ns

module rng(clk,reset,loadseed_i,seed_i,number_o);
input clk;
input reset;
input loadseed_i;
input [31:0] seed_i;
output [31:0] number_o;

reg [31:0] number_o;

reg [42:0] LFSR_reg;
reg [36:0] CASR_reg;


//CASR:
reg[36:0] CASR_varCASR,CASR_outCASR;
always @(posedge clk or negedge reset)

   begin




   if (!reset )

      begin

      CASR_reg  = (1);

      end

   else 

      begin

      if (loadseed_i )

         begin

         CASR_varCASR [36:32]=0;
         CASR_varCASR [31:0]=seed_i ;
         CASR_reg  = (CASR_varCASR );


         end

      else 

         begin

         CASR_varCASR =CASR_reg ;

         CASR_outCASR [36]=CASR_varCASR [35]^CASR_varCASR [0];
         CASR_outCASR [35]=CASR_varCASR [34]^CASR_varCASR [36];
         CASR_outCASR [34]=CASR_varCASR [33]^CASR_varCASR [35];
         CASR_outCASR [33]=CASR_varCASR [32]^CASR_varCASR [34];
         CASR_outCASR [32]=CASR_varCASR [31]^CASR_varCASR [33];
         CASR_outCASR [31]=CASR_varCASR [30]^CASR_varCASR [32];
         CASR_outCASR [30]=CASR_varCASR [29]^CASR_varCASR [31];
         CASR_outCASR [29]=CASR_varCASR [28]^CASR_varCASR [30];
         CASR_outCASR [28]=CASR_varCASR [27]^CASR_varCASR [29];
         CASR_outCASR [27]=CASR_varCASR [26]^CASR_varCASR [27]^CASR_varCASR [28];
         CASR_outCASR [26]=CASR_varCASR [25]^CASR_varCASR [27];
         CASR_outCASR [25]=CASR_varCASR [24]^CASR_varCASR [26];
         CASR_outCASR [24]=CASR_varCASR [23]^CASR_varCASR [25];
         CASR_outCASR [23]=CASR_varCASR [22]^CASR_varCASR [24];
         CASR_outCASR [22]=CASR_varCASR [21]^CASR_varCASR [23];
         CASR_outCASR [21]=CASR_varCASR [20]^CASR_varCASR [22];
         CASR_outCASR [20]=CASR_varCASR [19]^CASR_varCASR [21];
         CASR_outCASR [19]=CASR_varCASR [18]^CASR_varCASR [20];
         CASR_outCASR [18]=CASR_varCASR [17]^CASR_varCASR [19];
         CASR_outCASR [17]=CASR_varCASR [16]^CASR_varCASR [18];
         CASR_outCASR [16]=CASR_varCASR [15]^CASR_varCASR [17];
         CASR_outCASR [15]=CASR_varCASR [14]^CASR_varCASR [16];
         CASR_outCASR [14]=CASR_varCASR [13]^CASR_varCASR [15];
         CASR_outCASR [13]=CASR_varCASR [12]^CASR_varCASR [14];
         CASR_outCASR [12]=CASR_varCASR [11]^CASR_varCASR [13];
         CASR_outCASR [11]=CASR_varCASR [10]^CASR_varCASR [12];
         CASR_outCASR [10]=CASR_varCASR [9]^CASR_varCASR [11];
         CASR_outCASR [9]=CASR_varCASR [8]^CASR_varCASR [10];
         CASR_outCASR [8]=CASR_varCASR [7]^CASR_varCASR [9];
         CASR_outCASR [7]=CASR_varCASR [6]^CASR_varCASR [8];
         CASR_outCASR [6]=CASR_varCASR [5]^CASR_varCASR [7];
         CASR_outCASR [5]=CASR_varCASR [4]^CASR_varCASR [6];
         CASR_outCASR [4]=CASR_varCASR [3]^CASR_varCASR [5];
         CASR_outCASR [3]=CASR_varCASR [2]^CASR_varCASR [4];
         CASR_outCASR [2]=CASR_varCASR [1]^CASR_varCASR [3];
         CASR_outCASR [1]=CASR_varCASR [0]^CASR_varCASR [2];
         CASR_outCASR [0]=CASR_varCASR [36]^CASR_varCASR [1];

         CASR_reg  = (CASR_outCASR );

         end


      end


   end
//LFSR:
reg[42:0] LFSR_varLFSR;
reg outbitLFSR;
always @(posedge clk or negedge reset)

   begin


   if (!reset )

      begin

      LFSR_reg  = (1);

      end

   else 

      begin

      if (loadseed_i )

         begin

         LFSR_varLFSR [42:32]=0;
         LFSR_varLFSR [31:0]=seed_i ;
         LFSR_reg  = (LFSR_varLFSR );


         end

      else 

         begin

         LFSR_varLFSR =LFSR_reg ;

         outbitLFSR =LFSR_varLFSR [42];
         LFSR_varLFSR [42]=LFSR_varLFSR [41];
         LFSR_varLFSR [41]=LFSR_varLFSR [40]^outbitLFSR ;
         LFSR_varLFSR [40]=LFSR_varLFSR [39];
         LFSR_varLFSR [39]=LFSR_varLFSR [38];
         LFSR_varLFSR [38]=LFSR_varLFSR [37];
         LFSR_varLFSR [37]=LFSR_varLFSR [36];
         LFSR_varLFSR [36]=LFSR_varLFSR [35];
         LFSR_varLFSR [35]=LFSR_varLFSR [34];
         LFSR_varLFSR [34]=LFSR_varLFSR [33];
         LFSR_varLFSR [33]=LFSR_varLFSR [32];
         LFSR_varLFSR [32]=LFSR_varLFSR [31];
         LFSR_varLFSR [31]=LFSR_varLFSR [30];
         LFSR_varLFSR [30]=LFSR_varLFSR [29];
         LFSR_varLFSR [29]=LFSR_varLFSR [28];
         LFSR_varLFSR [28]=LFSR_varLFSR [27];
         LFSR_varLFSR [27]=LFSR_varLFSR [26];
         LFSR_varLFSR [26]=LFSR_varLFSR [25];
         LFSR_varLFSR [25]=LFSR_varLFSR [24];
         LFSR_varLFSR [24]=LFSR_varLFSR [23];
         LFSR_varLFSR [23]=LFSR_varLFSR [22];
         LFSR_varLFSR [22]=LFSR_varLFSR [21];
         LFSR_varLFSR [21]=LFSR_varLFSR [20];
         LFSR_varLFSR [20]=LFSR_varLFSR [19]^outbitLFSR ;
         LFSR_varLFSR [19]=LFSR_varLFSR [18];
         LFSR_varLFSR [18]=LFSR_varLFSR [17];
         LFSR_varLFSR [17]=LFSR_varLFSR [16];
         LFSR_varLFSR [16]=LFSR_varLFSR [15];
         LFSR_varLFSR [15]=LFSR_varLFSR [14];
         LFSR_varLFSR [14]=LFSR_varLFSR [13];
         LFSR_varLFSR [13]=LFSR_varLFSR [12];
         LFSR_varLFSR [12]=LFSR_varLFSR [11];
         LFSR_varLFSR [11]=LFSR_varLFSR [10];
         LFSR_varLFSR [10]=LFSR_varLFSR [9];
         LFSR_varLFSR [9]=LFSR_varLFSR [8];
         LFSR_varLFSR [8]=LFSR_varLFSR [7];
         LFSR_varLFSR [7]=LFSR_varLFSR [6];
         LFSR_varLFSR [6]=LFSR_varLFSR [5];
         LFSR_varLFSR [5]=LFSR_varLFSR [4];
         LFSR_varLFSR [4]=LFSR_varLFSR [3];
         LFSR_varLFSR [3]=LFSR_varLFSR [2];
         LFSR_varLFSR [2]=LFSR_varLFSR [1];
         LFSR_varLFSR [1]=LFSR_varLFSR [0]^outbitLFSR ;
         LFSR_varLFSR [0]=LFSR_varLFSR [42];

         LFSR_reg  = (LFSR_varLFSR );

         end


      end


   end
//combinate:
always @(posedge clk or negedge reset)

   begin

   if (!reset )

      begin

      number_o  = (0);

      end

   else 

      begin

      number_o  = (LFSR_reg [31:0]^CASR_reg[31:0]);

      end


   end

endmodule
