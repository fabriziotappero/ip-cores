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

OUTFILE PREFIX_MAC_NUMserial_TOPO.v

ITER CX COEFF_NUM
ITER MX MAC_NUM
ITER DX SON_DELAY

//  Built In Parameters:
//  
//    Filter Order              = ORDER
//    Input Precision           = DIN_BITS
//    Coefficient Precision     = COEFF_BITS
//    Sum of Products Latency   = LATENCY
//    Number of serial FIR sons = MAC_NUM
//    Number of multiplayers    = MAC_NUM


module PREFIX_MAC_NUMserial_TOPO (PORTS);
   
    input clk;
    input reset;
    input clken;
	input  [EXPR(COEFF_BITS-1):0] kCX;
	input  [EXPR(DIN_BITS-1):0] data_in;
	output [EXPR(DOUT_BITS-1):0] data_out;
	output valid;

    
	wire [EXPR(DIN_BITS-1):0] data_inMX;
    wire [EXPR(SON_DOUT-1):0] data_outMX;
	wire validMX;
	wire null;
	
	//delay inputs per son
    assign data_in0 = data_in;
    CREATE prgen_delayN.v DEFCMD(SWAP CONST(DELAY) SON_DELAY) DEFCMD(DEFINE CLKEN)
    prgen_delaySON_DELAY_en #(DIN_BITS) delay_dinMX (clk, reset, clken, data_inMX, data_inEXPR(MX+1));
	STOMP LINE

	
	//the FIR sons
LOOP MX MAC_NUM
	CREATE fir_serial.v def_fir_basic.txt DEFCMD(SWAP CONST(ORDER) EXPR(SON_DELAY-1)) DEFCMD(SWAP CONST(COEFF_BITS) COEFF_BITS) DEFCMD(SWAP CONST(DIN_BITS) DIN_BITS)
    PREFIX_serial_EXPR(SON_DELAY-1)_INPUT_BITS PREFIXMX
								(
								.clk(clk), 
								.reset(reset), 
								.clken(clken), 
								.kDX(kEXPR((MX*SON_DELAY)+DX)) ,
								.data_in(data_inMX), 
								.data_out(data_outMX),
								.valid(validMX)
								);
	
ENDLOOP MX

	//Pipline the output additions	
	CREATE prgen_bintree_adder.v DEFCMD(SWAP INPUT_NUM MAC_NUM)
	prgen_bintree_adder_MAC_NUM #(SON_DOUT) prgen_bintree_adder
		(
		.clk(clk),
		.reset(reset),
		.data_inMX(data_outMX),
IF TRUE(ADD_DOUT!=DOUT_BITS) .data_out({null, data_out}),
IF TRUE(ADD_DOUT==DOUT_BITS) .data_out(data_out),
		.valid_in(valid0),
		.valid_out(valid)
		);
    
endmodule







