//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
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


`timescale 1ns/10ps


module 
  glitch_generator
  #(
    parameter ENABLE = 0,
    parameter MAX_FREQ = 10000,
    parameter MAX_WIDTH = 120
  ) 
  (
    output out
  );
    
  
  // --------------------------------------------------------------------
  //  wires & regs
  reg glitch_generator_en;
  reg glitch;
  reg glitch_en;
  
    
  // --------------------------------------------------------------------
  //  init 
  initial
    begin
      glitch_generator_en <= ENABLE;
      glitch              <= 1'b0;
      glitch_en           <= 1'b0;
    
      forever
        begin: glitch_loop
        
          #({$random} % MAX_FREQ);
          
          if( ~glitch_generator_en )
            disable glitch_loop;
          
          glitch_en = 1'b1;
          #({$random} % MAX_WIDTH);
          
          glitch = ~glitch;
          #({$random} % MAX_WIDTH);
          
          glitch_en = 1'b0;
        
        end
    end      
    
      
  // --------------------------------------------------------------------
  //  enable_glitch_generator
  task enable_glitch_generator; 
    begin
    
    glitch_generator_en <= 1'b1;
         
    end    
  endtask
  
      
  // --------------------------------------------------------------------
  //  disable_glitch_generator
  task disable_glitch_generator; 
    begin
    
    glitch_generator_en <= 1'b0;
         
    end    
  endtask
  
      
  // --------------------------------------------------------------------
  //  outputs   

  assign (supply1, supply0) out = glitch_en ? glitch : 1'bz;
  
endmodule

