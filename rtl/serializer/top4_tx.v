//////////////////////////////////////////////////////////////////////////////
//
//  Xilinx, Inc. 2006                 www.xilinx.com
//
//  XAPP 486 - 7:1 LVDS in Spartan3E Devices
//
//////////////////////////////////////////////////////////////////////////////
//
//  File name :       top4_tx.v
//
//  Description :     Example top level module for using a 4-bit transmitter in Spartan 3E
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
//  Copyright © 2006 Xilinx, Inc.
//  All rights reserved
//
//////////////////////////////////////////////////////////////////////////////	
// 
`timescale 1 ps / 1ps

module top4_tx(
input		clkint, 				// clock in
input 	[27:0]	datain,				// 28 bit data in
input		rstin,				// reset (active low)
output	[3:0]	dataouta_p, dataouta_n,		// lvds data outputs
output		clkouta1_p,  clkouta1_n) ;	// lvds clock output

wire 		low ;				// logic 1'b0 
wire 		high ;				// logic 1'b1
wire 		rst ;				// reset wire
wire 		inclk ;				// 
wire 		inclknot ;			// 
wire 		clk ;				// main clock from DCM
wire 		clknot ;			// inverted main clock from DCM
wire 		clkdcm ;			// clock from dcm
wire 		clkx3p5 ;			// 3.5x clock for transmitter
wire 		clkx3p5dcm ;			// 3.5x clock from dcm
wire 		clkx3p5notdcm ;			// not 3.5x clock from dcm
wire 	[7:0]	outdata ;			// output data lines
wire 		clkoutint ;	          	// forwarded output clock
wire 	[1:0]	oclkinta ;	          	// 
wire 		clkoutaint ;	          	// forwarded output clock from macro 3:4 or 4:3 duty cycle
wire 		clkoutbint ;	          	// forwarded output clock using DCM clk0 - 50% output duty cycle 
wire 		clkoutcint ;	          	// forwarded output clock just using BUFG - output duty cycle = input duty cycle
wire 		clkoutdint ;	          	// output clock being used to monitor CLKFX and CLKFX180
wire 		clk_lckd ;			// clock locked
wire 		not_clk_lckd ;			// not clock locked
reg 	[27:0]	txdata = 0 ;			// data for transmission
wire 		clkx3p5not ;			// inverted 3.5x clock
wire 		rst_clk ;			// reset syncced to main clock
wire 	[7:0]	tx_output_fix ;
wire 	[3:0]	tx_output_reg ;

parameter [3:0] TX_SWAP_MASK = 4'b0000 ;	// pinswap mask for 4 output bits (0 = no swap (default), 1 = swap)

assign low 	= 1'b0 ;
assign high 	= 1'b1 ;
assign rst 	= ~rstin ; 			// reset is active low
assign clknot   = ~clk ;
assign inclknot = ~inclk ;

DCM_SP #(.CLKIN_PERIOD	("15.625"),
	.DESKEW_ADJUST	("0"),	
	.CLKFX_MULTIPLY	(7),
	.CLKFX_DIVIDE	(2))	
dcm_clk (
	.CLKIN   	(clkint),
	.CLKFB   	(clk),
	.DSSEN 		(low),
	.PSINCDEC	(low),
	.PSEN 		(low),
	.PSCLK 		(low),
	.RST     	(rst),
	.CLK0    	(clkdcm),
	.CLK90   	(clkdx),
	.CLKFX   	(clkx3p5dcm),
	.CLKFX180	(clkx3p5notdcm),
	.LOCKED  	(clk_lckd),
	.PSDONE  	(),
	.STATUS  	()) ;
wire	clkdxnot;
assign clkdxnot = ~clkdx ;

BUFG 	inclk_bufg	(.I(clkint), 		.O(inclk) ) ;
BUFG 	clk_bufg	(.I(clkdcm), 		.O(clk) ) ;
BUFG 	clkx3p5_bufg 	(.I(clkx3p5dcm), 	.O(clkx3p5) ) ;
BUFG 	clkx3p5not_bufg	(.I(clkx3p5notdcm), 	.O(clkx3p5not) ) ;

genvar i ;
generate
for (i = 0 ; i <= 3 ; i = i + 1)
begin : loop0
OBUFDS	#(.IOSTANDARD("LVDS_33")) 	
obuf_d   (.I(tx_output_reg[i]), .O(dataouta_p[i]), .OB(dataouta_n[i]));
ODDR2 	#(.DDR_ALIGNMENT("NONE")) fd_ioc	(.C0(clkx3p5), .C1(clkx3p5not), .D0(tx_output_fix[i+4]), .D1(tx_output_fix[i]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(tx_output_reg[i])) ;
assign tx_output_fix[i]   = outdata[i]   ^ TX_SWAP_MASK[i] ;
assign tx_output_fix[i+4] = outdata[i+4] ^ TX_SWAP_MASK[i] ;
end
endgenerate

ODDR2 	#(.DDR_ALIGNMENT("NONE")) ca_ddr_reg   (.C0(clkx3p5), .C1(clkx3p5not), .D0(oclkinta[1]), .D1(oclkinta[0]), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(clkoutaint)) ;

assign clkoutint = clkoutaint	;	// use this line for 3:4 or 4:3 macro generated forwarded clock

OBUFDS	#(.IOSTANDARD("LVDS_33")) lvds_clka_obuf	(.I(clkoutint),   .O(clkouta1_p),    .OB(clkouta1_n) );

serdes_4b_7to1_wrapper tx0(
	.clk		(clk),
	.datain 	(txdata),
	.rst   		(rst_clk),
	.clkx3p5   	(clkx3p5),
	.clkx3p5not	(clkx3p5not),
	.dataout	(outdata),
	.clkout		(oclkinta));	// clock output

always @ (posedge clk or posedge rst_clk)
begin
if (rst_clk == 1'b1) begin
	txdata <= 28'b0000000000000000000000000000 ;
end
else begin
	txdata <= datain ;
end
end

assign not_clk_lckd = ~clk_lckd ;

// generate a registered reset wire for the tx clock
FDP fd_rst_clk (.D(not_clk_lckd), .C(clk), .PRE(rst), .Q(rst_clk)) ;

endmodule


