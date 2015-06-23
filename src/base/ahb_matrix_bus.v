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

OUTFILE PREFIX_bus.v
INCLUDE def_ahb_matrix.txt

ITER MX
ITER SX
  
module PREFIX_bus(PORTS);

   input 		       clk;
   input                       reset;
   
   port                        MMX_GROUP_AHB;
   revport                     SSX_GROUP_AHB;

   input                       SSX_MMX;
   input                       SSX_MMX_resp;
   

   parameter                   BUS_WIDTH = GONCAT(GROUP_AHB.IN.WIDTH +);

   wire [BUS_WIDTH-1:0]        SSX_BUS;
   
   wire [BUS_WIDTH-1:0]        MMX_BUS;
   

   
   assign                      MMX_BUS = {GONCAT(MMX_GROUP_AHB_CMD.IN ,)};
   
   assign                      SSX_BUS = CONCAT((MMX_BUS & {BUS_WIDTH{SSX_MMX}}) |);
   
   assign                      {GONCAT(SSX_GROUP_AHB_CMD.IN ,)} = SSX_BUS;

   assign                      SSX_HWDATA =  CONCAT((MMX_HWDATA & {DATA_BITS{SSX_MMX_resp}}) |);                    
   
LOOP MX
   assign                      MMX_GROUP_AHB_RESP.OUT = CONCAT(({GROUP_AHB_RESP.OUT.WIDTH{SSX_MMX_resp}} & SSX_GROUP_AHB_RESP.OUT) |);
   
   assign                      MMX_HREADY = CONCAT(((SSX_MMX|SSX_MMX_resp)&SSX_HREADY) |);
   
ENDLOOP MX
  
  
endmodule




