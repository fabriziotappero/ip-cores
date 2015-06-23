//////////////////////////////////////////////////////////////////////////////
//
//  Xilinx, Inc. 2005                 www.xilinx.com
//
//  XAPP 486 - 7:1 LVDS in Spartan3E Devices
//
//////////////////////////////////////////////////////////////////////////////
//
//  File name :       serdes_4b_7to1_wrapper.v
//
//  Description :     Wrapper for generic 4-bit serdes_4b_7to1 for Spartan 3E
//
//  Date - revision : October 16th 2006 - v 1.4
//			
//			Version 1.4 : 	Brings the DDR registers to the top level and no
//					longer uses 'C0' alignment
//
//  Author :          NJS
//
//  Disclaimer: LIMITED WARRANTY AND DISCLAMER. These designs are
//              provided to you "as is". Xilinx and its licensors make and you
//              receive no warranties or conditions, express, implied,
//              statutory or otherwise, and Xilinx specifically disclaims any
//              implied warranties of merchantability, non-infringement,or
//              fitness for a particular purpose. Xilinx does not warrant that
//              the functions contained in these designs will meet your
//              requirements, or that the operation of these designs will be
//              uninterrupted or error free, or that defects in the Designs
//              will be corrected. Furthermore, Xilinx does not warrantor
//              make any representations regarding use or the results of the
//              use of the designs in terms of correctness, accuracy,
//              reliability, or otherwise.
//
//              LIMITATION OF LIABILITY. In no event will Xilinx or its
//              licensors be liable for any loss of data, lost profits,cost
//              or procurement of substitute goods or services, or for any
//              special, incidental, consequential, or indirect damages
//              arising from the use or operation of the designs or
//              accompanying documentation, however caused and on any theory
//              of liability. This limitation will apply even if Xilinx
//              has been advised of the possibility of such damage. This
//              limitation shall apply not-withstanding the failure of the
//              essential purpose of any limited remedies herein.
//
//  Copyright © 2005 Xilinx, Inc.
//  All rights reserved
//
//////////////////////////////////////////////////////////////////////////////	
`timescale 1 ps / 1ps

module serdes_4b_7to1_wrapper (
input 		clk,				// clock
input 		clkx3p5,			// 3.5 times clock
input 		clkx3p5not,			// not 3.5 times clock
input 	[27:0]	datain,				// input data
input 		rst,				// reset
output 	[7:0]	dataout,			// output data
output 	[1:0]	clkout) ;			// output clock (1x)

(* RLOC = "x0y0" *) 	serdes_4b_7to1 tx0(
	.clk		(clk),
	.clkx3p5	(clkx3p5),
	.clkx3p5not	(clkx3p5not),
	.datain		(datain),
	.rst		(rst),
	.dataout	(dataout),
	.clkout		(clkout)) ;

endmodule


