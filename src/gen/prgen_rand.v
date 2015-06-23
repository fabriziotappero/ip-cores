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

OUTFILE prgen_rand.v
  
function integer rand_chance;
      input [31:0] chance_true;

      begin
	 if (chance_true > 100)
	   begin
	      $display("RAND_CHANCE-E-: fatal error, rand_chance called with percent chance larger than 100.\tTime: %0d ns", $time);
	      $finish;
	   end
	 rand_chance = (rand(1,100) <= chance_true);
      end
endfunction // rand_chance


function integer rand;
      input [31:0] min;
      input [31:0] max;

      integer      range;
      begin
	 if (min > max)
	   begin
	      $display("RAND-E-: fatal error, rand was called with min larger than max.\tTime: %0d ns", $time);
	      $finish;
	   end

	 range = (max - min) + 1;
	 if (range == 0) range = -1;
	 rand  = min + ($random % range); 
      end
endfunction // rand


function integer align;
      input [31:0]  num;
      input [31:0]  align_size;
      
      begin
         align = num - (num % align_size);
      end
endfunction


function integer rand_align;
      input [31:0] min;
      input [31:0] max;
      input [31:0] align_val;

      begin
         rand_align = rand(min, max);
         
         if (rand_align > align_val)
           rand_align = align(rand_align, align_val);
      end
endfunction

