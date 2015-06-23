<##//////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Eyal Hochberg                                      ////
////          eyal@provartec.com                                 ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2010 Provartec LTD                            ////
//// www.provartec.com                                           ////
//// info@provartec.com                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
//////////////////////////////////////////////////////////////////##>


OUTFILE prgen_NAME.v

STARTDEF
IFDEF CLKEN
SWAP NAME delayDELAY_en
ELSE CLKEN
SWAP NAME delayDELAY
ENDIF CLKEN
ENDDEF
  
ITER DX DELAY
  
module prgen_NAME(PORTS);
   parameter          WIDTH = 1;
   
   input 		      clk;
   input 		      reset;
IF CLKEN  input 		      clken;
   
   input [WIDTH-1:0]  din;
IFDEF PARALLEL
   output [WIDTH*DELAY-1:0] dout;
ELSE PARALLEL
   output [WIDTH-1:0] dout;
ENDIF PARALLEL
   
   
   wire [WIDTH-1:0]   din_d0;
   reg [WIDTH-1:0] 	  din_dEXPR(DX+1);
   
   assign din_d0 = din;
   
   always @(posedge clk or posedge reset)
     if (reset)
	   begin
         din_dEXPR(DX+1) <= #FFD {WIDTH{1'b0}};
	   end
     else
IFDEF CLKEN
	 STOMP NEWLINE
	 if (clken)
ENDIF CLKEN
	   begin
         din_dEXPR(DX+1) <= #FFD din_dDX;
	   end
	   

IFDEF PARALLEL
  assign              dout = {CONCAT.REV(din_dDX ,)};
ELSE PARALLEL
   assign 		      dout = din_dDELAY;
ENDIF PARALLEL
   
   
endmodule


   



