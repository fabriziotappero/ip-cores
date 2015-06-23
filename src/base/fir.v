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

OUTDIR  PREFIX_NAME
OUTFILE PREFIX_NAME.v
INCLUDE def_fir.txt

 LIST firlist_NAME.txt 

ITER CX COEFF_NUM

##  Expected RobustVerilog parameters:
##  SWAP ORDER val       - order of FIR
##  SWAP COEFF_BITS val  - precision of coeeficients (bit num)
##  SWAP DIN_BITS val    - precision of input data (bit num)
##  SWAP MAC_NUM val     - number of multiplayers (determines architecture)

//  Built In Parameters:
//  
//    Filter Order              = ORDER
//    Input Precision           = DIN_BITS
//    Coefficient Precision     = COEFF_BITS
//    Number of serial FIR sons = MAC_NUM
//    Number of multiplayers    = MAC_NUM
//    Architecture              = ARCH
//    Sum of Products Latency   = LATENCY


module PREFIX_NAME (PORTS);
			
   input                            clk;
   input                            reset;
   input [EXPR(COEFF_BITS-1):0]     kCX;
   input [EXPR(DIN_BITS-1):0]       data_in;
   output [EXPR(DOUT_BITS-1):0]     data_out;
   input                            valid_in;
   output                           valid_out;
   
	
IFDEF MAC_EQ(1)
  CREATE fir_serial.v def_fir_basic.txt DEFCMD(SWAP CONST(ORDER) ORDER) DEFCMD(SWAP CONST(COEFF_BITS) COEFF_BITS) DEFCMD(SWAP CONST(DIN_BITS) DIN_BITS)
  PREFIX_serial_TOPO PREFIX(clk, reset, valid_in, CONCAT.REV(kCX ,), data_in, data_out, valid_out);
  
ELSE MAC_EQ(1)
  IFDEF MAC_EQ(COEFF_NUM)
  CREATE fir_parallel.v def_fir_basic.txt DEFCMD(SWAP CONST(ORDER) ORDER) DEFCMD(SWAP CONST(COEFF_BITS) COEFF_BITS) DEFCMD(SWAP CONST(DIN_BITS) DIN_BITS)
  PREFIX_parallel_TOPO PREFIX(clk, reset, valid_in, CONCAT.REV(kCX ,), data_in, data_out, valid_out);
  
  ELSE MAC_EQ(COEFF_NUM)
  CREATE fir_Nserial.v def_fir_Nserial.txt DEFCMD(SWAP CONST(ORDER) ORDER) DEFCMD(SWAP CONST(COEFF_BITS) COEFF_BITS) DEFCMD(SWAP CONST(DIN_BITS) DIN_BITS) DEFCMD(SWAP CONST(MAC_NUM) MAC_NUM)
  PREFIX_MAC_NUMserial_TOPO PREFIX(clk, reset, valid_in, CONCAT.REV(kCX ,), data_in, data_out, valid_out);
  
  ENDIF MAC_EQ(COEFF_NUM)
ENDIF MAC_EQ(1)
  	
	
endmodule
