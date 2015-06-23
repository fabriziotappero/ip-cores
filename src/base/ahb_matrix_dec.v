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

OUTFILE PREFIX_dec.v
INCLUDE def_ahb_matrix.txt

ITER MX   
ITER SX   

module PREFIX_dec (PORTS);

   input [ADDR_BITS-1:0] 		      MMX_HADDR;
   output [SLV_BITS-1:0] 		      MMX_slv;
   
   
   parameter                                  DEC_MSB =  ADDR_BITS - 1;
   parameter                                  DEC_LSB =  ADDR_BITS - SLV_BITS;
   
   reg [SLV_BITS-1:0] 			      MMX_slv;
   
   LOOP MX
     always @(*)
       begin                                                  
	  case (MMX_HADDR[DEC_MSB:DEC_LSB])    
	    BIN(SX SLV_BITS) : MMX_slv = 'dSX;  

            default : MMX_slv = 'dSERR;                     
	  endcase                                             
       end                                                    

   ENDLOOP MX
      
     endmodule



