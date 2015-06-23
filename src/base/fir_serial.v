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

OUTFILE PREFIX_serial_TOPO.v

ITER OX ORDER
ITER CX COEFF_NUM
ITER SX ADD_STAGES

//  Built In Parameters:
//  
//    Filter Order             = ORDER
//    Input Precision          = DIN_BITS
//    Coefficient Precision    = COEFF_BITS
//    Sum of Products Latency  = LATENCY

module PREFIX_serial_TOPO (PORTS);
			
	input  clk;
	input  reset;
    input  clken;
	input  [EXPR(COEFF_BITS-1):0] kCX;
	input  [EXPR(DIN_BITS-1):0] data_in;
	output [EXPR(DOUT_BITS-1):0] data_out;
	output valid;

    wire [EXPR(COEFF_BITS-1):0] k;
    wire [EXPR(MULT_BITS-1):0] mult;
    reg [EXPR(DOUT_BITS-1):0] multCX;
    wire [EXPR(DOUT_BITS-1):0] add;
	wire addCX;
	reg [EXPR(DOUT_BITS-1):0] mult_sum;
	reg [EXPR(DOUT_BITS-1):0] data_out;
	reg valid;
	
	reg active;
    reg [EXPR(ADD_STAGES-1):0] phase;
    reg [EXPR(ADD_STAGES-1):0] cycle;
    
	wire phaseCX;
	wire cycleCX;
  
	assign phaseCX = phase == 'dCX;
	assign cycleCX = cycle == 'dCX;
  
    assign k = 
	  phaseOX ? kOX :
	  kORDER;
  
    //a single multiplayer and a single adder
    assign mult = k * data_in;
	assign add  = mult + (
		   		  addOX ? multOX :
				          multORDER);
  
  
    always @(posedge clk or posedge reset)
      if (reset)
        active <= #FFD 1'b0;
	  else if (clken)
        active <= #FFD 1'b1;
	  else if (phase == 'dORDER)
        active <= #FFD 1'b0;
  
    always @(posedge clk or posedge reset)
      if (reset)
        phase <= #FFD {ADD_STAGES{1'b0}};
      else if (phase == 'dORDER)
        phase <= #FFD {ADD_STAGES{1'b0}};
      else if (active)
        phase <= #FFD phase + 1'b1;
	 
    always @(posedge clk or posedge reset)
      if (reset)
        cycle <= #FFD {ADD_STAGES{1'b0}};
	  else if (phase == 'dORDER)
	    begin
		  if (cycle == 'dORDER)
            cycle <= #FFD {ADD_STAGES{1'b0}};
		  else
            cycle <= cycle + 1'b1;
		end
	 
LOOP PX COEFF_NUM
	assign addPX = active & (
	    (phaseEXPR((COEFF_NUM+PX-CX)%COEFF_NUM) && cycleCX) ||
		STOMP || );
	
	always @(posedge clk or posedge reset)
	  if (reset)
	    multPX <= #FFD {MULT_BITS{1'b0}};
	  else if (phase1 && cyclePX)
	    multPX <= #FFD {MULT_BITS{1'b0}};
	  else if (addPX)
	    multPX <= #FFD add;
	    
ENDLOOP PX

  
 //sample when valid
 always @(posedge clk or posedge reset)
  if (reset)
    mult_sum <= #FFD {DOUT_BITS{1'b0}};
  else if (phase1)
    begin
LOOP CX COEFF_NUM
	if (cycleCX)
    mult_sum <= #FFD multCX; 
	else
STOMP NEWLINE
ENDLOOP CX
STOMP else
    end

 //sync to clock enable
 always @(posedge clk or posedge reset)
  if (reset)
    begin
      data_out <= #FFD {DOUT_BITS{1'b0}};
	  valid <= #FFD 1'b0;
	end
  else if (clken)
    begin
      data_out <= #FFD mult_sum;
	  valid <= #FFD 1'b1;
	end
  else
    begin
	  valid <= #FFD 1'b0;
	end
    
	
endmodule





