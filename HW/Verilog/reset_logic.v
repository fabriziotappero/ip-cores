//////////////////////////////////////////////////////////////////
//                                                              //
//  Reset logic for Edge core                                   //
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  Handling reset logic for Edge core jump to PC = 0           //               
//                                                              //
//  Author(s):                                                  //
//      - Hesham AL-Matary, heshamelmatary@gmail.com            //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2014 Authors and OPENCORES.ORG                 //
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

module reset_logic
#
(
  parameter RESET_AFTER = 1 // Produce 0 signal after #RESET_AFTER clock cycles
) 
(
  input reset_interrupt,
  input clk,
  output reset
);

reg[1:0] counter = 0;
reg res_buffer = 1;

always @(posedge clk)
begin
  /* Reset after specified clock cycles */
  /*counter = counter + 1; 
  if(counter == RESET_AFTER + 1)
    res_buffer = 0;
  */
    //res_buffer = 0;
   
  /* Only reset when reset button/signal pushed */
  if(reset_interrupt == 0)
    res_buffer = 0;
  else if(reset_interrupt == 1)
    res_buffer = 1;
  
end 

assign reset = res_buffer;

endmodule
