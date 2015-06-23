//////////////////////////////////////////////////////////////////////////////
//
//  Xilinx, Inc. 2006                 www.xilinx.com
//
//  XAPP 486 - 7:1 LVDS in Spartan3E Devices
//
//////////////////////////////////////////////////////////////////////////////
//
//  File name :       serdes_4b_7to1.v
//
//  Description :     generic 4-bit 7:1 serdes for Spartan 3E, now using ODDR2 with ALIGNMENT = NONE
// 			data is transmitted LSBs first
// 			0, 4,  8, 12, 16, 20, 24
// 			1, 5,  9, 13, 17, 21, 25
// 			2, 6, 10, 14, 18, 22, 26
// 			3, 7, 11, 15, 19, 23, 27
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

module serdes_4b_7to1 (
input 		clk,				// clock
input 		clkx3p5,			// 3.5 times clock
input 		clkx3p5not,			// not 3.5 times clock
input 	[27:0]	datain,				// input data
input 		rst,				// reset
output 	[7:0]	dataout,			// output data
output 	[1:0]	clkout) ;			// output clock (1x)

wire 		clkd2 ;
wire 		clkd2d_a ;
wire 		clkd2d_b ;
wire 		xra ;
wire 		xrareg ;
wire 		notclk3p5d2 ;
wire 		clk3p5d2a ;
wire 		clk3p5d2b ;
wire 		ce0 ;
wire 		ce1 ;
wire 		ce0_d ;
wire 		ce1_d ;
reg 	[2:0] 	phase_bna ;
reg 	[2:0] 	phase_bnb ;
wire 	[2:0] 	pba ;
wire 	[2:0] 	pbb ;
wire 	[2:1] 	pbad ;
wire 	[2:2] 	pbadd ;
wire 	[6:0] 	mux_ap_d ;
wire 	[5:0] 	mux_ap ;
wire 	[6:0] 	mux_bp_d ;
wire 	[5:0] 	mux_bp ;
wire 	[6:0] 	mux_cp_d ;
wire 	[5:0] 	mux_cp ;
wire 	[6:0] 	mux_dp_d ;
wire 	[5:0] 	mux_dp ;
wire 	[6:0] 	mux_an_d ;
wire 	[5:0] 	mux_an ;
wire 	[6:0] 	mux_bn_d ;
wire 	[5:0] 	mux_bn ;
wire 	[6:0] 	mux_cn_d ;
wire 	[5:0] 	mux_cn ;
wire 	[6:0] 	mux_dn_d ;
wire 	[5:0] 	mux_dn ;
wire 	[3:0] 	mux_p ;
wire 	[27:0] 	db ;
reg 	[27:0] 	dataint ;
wire 	[27:20] datainr ;
wire 		clkcn  ;
wire 		clkcp_d  ;
wire 		clkcn_d  ;

parameter xa = "12" ;						// Use this set of 4 parameters for macro either side of block RAM
parameter xb = "13" ;
parameter xc = "14" ;
parameter xd = "15" ;

//parameter xa = "4" ;						// Use this set of 4 parameters for contiguous macro 
//parameter xb = "5" ;
//parameter xc = "6" ;
//parameter xd = "7" ;

always @ (datain)								// this is to get around an issue that appeared 
 	dataint <= #100 datain ;						// in simulation with MTI 6.0

assign mux_an_d[0]  = (db[0]  & ~pba[0]) | (db[8]  & pba[0]) ;
assign mux_an_d[1]  = (db[16] & ~pba[0]) | (db[24] & pba[0]) ;
assign mux_an_d[2]  = (db[4]  & ~pbb[0]) | (db[12] & pbb[0]) ;
assign mux_an_d[3]  =  db[20] ;
assign mux_an_d[4]  = (mux_an[0] & ~pbad[1])  | (mux_an[1] & pbad[1]) ;
assign mux_an_d[5]  = (mux_an[2] & ~pbad[1])  | (mux_an[3] & pbad[1]) ;
assign mux_an_d[6]  = (mux_an[4] & ~pbadd[2]) | (mux_an[5] & pbadd[2]) ;

(* RLOC = {"x",xa,"y0"} *)	FD	muxan0 	(.D(mux_an_d[0]),  .C(clkx3p5), .Q(mux_an[0])) ;
(* RLOC = {"x",xa,"y0"} *)	FD	muxan1 	(.D(mux_an_d[1]),  .C(clkx3p5), .Q(mux_an[1])) ;
(* RLOC = "x3y0" *)		FD	muxan2 	(.D(mux_an_d[2]),  .C(clkx3p5), .Q(mux_an[2])) ;
(* RLOC = "x3y0" *)		FD	muxan3 	(.D(mux_an_d[3]),  .C(clkx3p5), .Q(mux_an[3])) ;
(* RLOC = {"x",xc,"y1"} *)	FD	muxan4 	(.D(mux_an_d[4]),  .C(clkx3p5), .Q(mux_an[4])) ;
(* RLOC = {"x",xc,"y1"} *)	FD	muxan5 	(.D(mux_an_d[5]),  .C(clkx3p5), .Q(mux_an[5])) ;
(* RLOC = {"x",xc,"y2"} *)	FD	muxan6 	(.D(mux_an_d[6]),  .C(clkx3p5), .Q(dataout[4])) ;

assign mux_ap_d[0]  = (db[4]  & ~pba[0]) | (db[12] & pba[0]) ;
assign mux_ap_d[1]  = (db[20] & ~pba[0]) | (db[0]  & pba[0]) ;
assign mux_ap_d[2]  = (db[8]  & ~pbb[0]) | (db[16] & pbb[0]) ;
assign mux_ap_d[3]  =  db[24] ;
assign mux_ap_d[4]  = (mux_ap[0] & ~pbad[1])  | (mux_ap[1] & pbad[1]) ;
assign mux_ap_d[5]  = (mux_ap[2] & ~pbad[1])  | (mux_ap[3] & pbad[1]) ;
assign mux_ap_d[6]  = (mux_ap[4] & ~pbadd[2]) | (mux_ap[5] & pbadd[2]) ;

(* RLOC = {"x",xa,"y1"} *)	FD	muxap0 	(.D(mux_ap_d[0]),  .C(clkx3p5), .Q(mux_ap[0])) ;
(* RLOC = {"x",xa,"y1"} *)	FD	muxap1 	(.D(mux_ap_d[1]),  .C(clkx3p5), .Q(mux_ap[1])) ;
(* RLOC = "x3y1" *)		FD	muxap2 	(.D(mux_ap_d[2]),  .C(clkx3p5), .Q(mux_ap[2])) ;
(* RLOC = "x3y1" *)		FD	muxap3 	(.D(mux_ap_d[3]),  .C(clkx3p5), .Q(mux_ap[3])) ;
(* RLOC = {"x",xc,"y0"} *)	FD	muxap4 	(.D(mux_ap_d[4]),  .C(clkx3p5), .Q(mux_ap[4])) ;
(* RLOC = {"x",xc,"y0"} *)	FD	muxap5 	(.D(mux_ap_d[5]),  .C(clkx3p5), .Q(mux_ap[5])) ;
(* RLOC = {"x",xd,"y0"}, BEL = "FFY"  *)	FD	muxap6 	(.D(mux_ap_d[6]),  .C(clkx3p5), .Q(mux_p[0])) ;

assign mux_bn_d[0]  = (db[1]  & ~pbb[0]) | (db[9]  & pbb[0]) ;
assign mux_bn_d[1]  = (db[17] & ~pbb[0]) | (db[25] & pbb[0]) ;
assign mux_bn_d[2]  = (db[5]  & ~pbb[0]) | (db[13] & pbb[0]) ;
assign mux_bn_d[3]  =  db[21] ;
assign mux_bn_d[4]  = (mux_bn[0] & ~pbad[1])  | (mux_bn[1] & pbad[1]) ;
assign mux_bn_d[5]  = (mux_bn[2] & ~pbad[1])  | (mux_bn[3] & pbad[1]) ;
assign mux_bn_d[6]  = (mux_bn[4] & ~pbadd[2]) | (mux_bn[5] & pbadd[2]) ;

(* RLOC = "x2y2" *)		FD	muxbn0 	(.D(mux_bn_d[0]),  .C(clkx3p5), .Q(mux_bn[0])) ;
(* RLOC = "x2y2" *)		FD	muxbn1 	(.D(mux_bn_d[1]),  .C(clkx3p5), .Q(mux_bn[1])) ;
(* RLOC = "x3y2" *)		FD	muxbn2 	(.D(mux_bn_d[2]),  .C(clkx3p5), .Q(mux_bn[2])) ;
(* RLOC = "x3y2" *)		FD	muxbn3 	(.D(mux_bn_d[3]),  .C(clkx3p5), .Q(mux_bn[3])) ;
(* RLOC = {"x",xd,"y3"} *)	FD	muxbn4 	(.D(mux_bn_d[4]),  .C(clkx3p5), .Q(mux_bn[4])) ;
(* RLOC = {"x",xd,"y3"} *)	FD	muxbn5 	(.D(mux_bn_d[5]),  .C(clkx3p5), .Q(mux_bn[5])) ;
(* RLOC = {"x",xc,"y2"} *)	FD	muxbn6 	(.D(mux_bn_d[6]),  .C(clkx3p5), .Q(dataout[5])) ;

assign mux_bp_d[0]  = (db[5]  & ~pba[0]) | (db[13] & pba[0]) ;
assign mux_bp_d[1]  = (db[21] & ~pba[0]) | (db[1]  & pba[0]) ;
assign mux_bp_d[2]  = (db[9]  & ~pbb[0]) | (db[17] & pbb[0]) ;
assign mux_bp_d[3]  =  db[25] ;
assign mux_bp_d[4]  = (mux_bp[0] & ~pbad[1])  | (mux_bp[1] & pbad[1]) ;
assign mux_bp_d[5]  = (mux_bp[2] & ~pbad[1])  | (mux_bp[3] & pbad[1]) ;
assign mux_bp_d[6]  = (mux_bp[4] & ~pbadd[2]) | (mux_bp[5] & pbadd[2]) ;

(* RLOC = {"x",xa,"y3"} *)	FD	muxbp0 	(.D(mux_bp_d[0]),  .C(clkx3p5), .Q(mux_bp[0])) ;
(* RLOC = {"x",xa,"y3"} *)	FD	muxbp1 	(.D(mux_bp_d[1]),  .C(clkx3p5), .Q(mux_bp[1])) ;
(* RLOC = "x3y3" *)		FD	muxbp2 	(.D(mux_bp_d[2]),  .C(clkx3p5), .Q(mux_bp[2])) ;
(* RLOC = "x3y3" *)		FD	muxbp3 	(.D(mux_bp_d[3]),  .C(clkx3p5), .Q(mux_bp[3])) ;
(* RLOC = {"x",xd,"y2"} *)	FD	muxbp4 	(.D(mux_bp_d[4]),  .C(clkx3p5), .Q(mux_bp[4])) ;
(* RLOC = {"x",xd,"y2"} *)	FD	muxbp5 	(.D(mux_bp_d[5]),  .C(clkx3p5), .Q(mux_bp[5])) ;
(* RLOC = {"x",xb,"y0"}, BEL = "FFY"  *)	FD	muxbp6 	(.D(mux_bp_d[6]),  .C(clkx3p5), .Q(mux_p[1])) ;

assign mux_cn_d[0]  = (db[2]  & ~pba[0]) | (db[10] & pba[0]) ;
assign mux_cn_d[1]  = (db[18] & ~pba[0]) | (db[26] & pba[0]) ;
assign mux_cn_d[2]  = (db[6]  & ~pbb[0]) | (db[14] & pbb[0]) ;
assign mux_cn_d[3]  =  db[22] ;
assign mux_cn_d[4]  = (mux_cn[0] & ~pbad[1])  | (mux_cn[1] & pbad[1]) ;
assign mux_cn_d[5]  = (mux_cn[2] & ~pbad[1])  | (mux_cn[3] & pbad[1]) ;
assign mux_cn_d[6]  = (mux_cn[4] & ~pbadd[2]) | (mux_cn[5] & pbadd[2]) ;

(* RLOC = {"x",xa,"y2"} *)	FD	muxcn0 	(.D(mux_cn_d[0]),  .C(clkx3p5), .Q(mux_cn[0])) ;
(* RLOC = {"x",xa,"y2"} *)	FD	muxcn1 	(.D(mux_cn_d[1]),  .C(clkx3p5), .Q(mux_cn[1])) ;
(* RLOC = "x3y4" *)		FD	muxcn2 	(.D(mux_cn_d[2]),  .C(clkx3p5), .Q(mux_cn[2])) ;
(* RLOC = "x3y4" *)		FD	muxcn3 	(.D(mux_cn_d[3]),  .C(clkx3p5), .Q(mux_cn[3])) ;
(* RLOC = {"x",xd,"y5"} *)	FD	muxcn4 	(.D(mux_cn_d[4]),  .C(clkx3p5), .Q(mux_cn[4])) ;
(* RLOC = {"x",xd,"y5"} *)	FD	muxcn5 	(.D(mux_cn_d[5]),  .C(clkx3p5), .Q(mux_cn[5])) ;
(* RLOC = {"x",xc,"y5"} *)	FD	muxcn6 	(.D(mux_cn_d[6]),  .C(clkx3p5), .Q(dataout[6])) ;

assign mux_cp_d[0]  = (db[6]  & ~pba[0]) | (db[14] & pba[0]) ;
assign mux_cp_d[1]  = (db[22] & ~pba[0]) | (db[2]  & pba[0]) ;
assign mux_cp_d[2]  = (db[10] & ~pbb[0]) | (db[18] & pbb[0]) ;
assign mux_cp_d[3]  =  db[26] ;
assign mux_cp_d[4]  = (mux_cp[0] & ~pbad[1])  | (mux_cp[1]  & pbad[1]) ;
assign mux_cp_d[5]  = (mux_cp[2] & ~pbad[1])  | (mux_cp[3]  & pbad[1]) ;
assign mux_cp_d[6]  = (mux_cp[4] & ~pbadd[2]) | (mux_cp[5] & pbadd[2]) ;

(* RLOC = {"x",xa,"y5"} *)	FD	muxcp0 	(.D(mux_cp_d[0]),  .C(clkx3p5), .Q(mux_cp[0])) ;
(* RLOC = {"x",xa,"y5"} *)	FD	muxcp1 	(.D(mux_cp_d[1]),  .C(clkx3p5), .Q(mux_cp[1])) ;
(* RLOC = "x3y5" *)		FD	muxcp2 	(.D(mux_cp_d[2]),  .C(clkx3p5), .Q(mux_cp[2])) ;
(* RLOC = "x3y5" *)		FD	muxcp3 	(.D(mux_cp_d[3]),  .C(clkx3p5), .Q(mux_cp[3])) ;
(* RLOC = {"x",xd,"y4"} *)	FD	muxcp4 	(.D(mux_cp_d[4]),  .C(clkx3p5), .Q(mux_cp[4])) ;
(* RLOC = {"x",xd,"y4"} *)	FD	muxcp5 	(.D(mux_cp_d[5]),  .C(clkx3p5), .Q(mux_cp[5])) ;
(* RLOC = {"x",xb,"y5"}, BEL = "FFY"  *)	FD	muxcp6 	(.D(mux_cp_d[6]),  .C(clkx3p5), .Q(mux_p[2])) ;

assign mux_dn_d[0]  = (db[3]  & ~pba[0]) | (db[11] & pba[0]) ;
assign mux_dn_d[1]  = (db[19] & ~pba[0]) | (db[27] & pba[0]) ;
assign mux_dn_d[2]  = (db[7]  & ~pbb[0]) | (db[15] & pbb[0]) ;
assign mux_dn_d[3]  = db[23] ;
assign mux_dn_d[4]  = (mux_dn[0] & ~pbad[1])  | (mux_dn[1]  & pbad[1]) ;
assign mux_dn_d[5]  = (mux_dn[2] & ~pbad[1])  | (mux_dn[3]  & pbad[1]) ;
assign mux_dn_d[6]  = (mux_dn[4] & ~pbadd[2]) | (mux_dn[5] & pbadd[2]) ;

(* RLOC = {"x",xa,"y6"} *)	FD	muxdn0 	(.D(mux_dn_d[0]),  .C(clkx3p5), .Q(mux_dn[0])) ;
(* RLOC = {"x",xa,"y6"} *)	FD	muxdn1 	(.D(mux_dn_d[1]),  .C(clkx3p5), .Q(mux_dn[1])) ;
(* RLOC = "x3y6" *)		FD	muxdn2 	(.D(mux_dn_d[2]),  .C(clkx3p5), .Q(mux_dn[2])) ;
(* RLOC = "x3y6" *)		FD	muxdn3 	(.D(mux_dn_d[3]),  .C(clkx3p5), .Q(mux_dn[3])) ;
(* RLOC = {"x",xc,"y7"} *)	FD	muxdn4 	(.D(mux_dn_d[4]),  .C(clkx3p5), .Q(mux_dn[4])) ;
(* RLOC = {"x",xc,"y7"} *)	FD	muxdn5 	(.D(mux_dn_d[5]),  .C(clkx3p5), .Q(mux_dn[5])) ;
(* RLOC = {"x",xc,"y5"} *)	FD	muxdn6 	(.D(mux_dn_d[6]),  .C(clkx3p5), .Q(dataout[7])) ;

assign mux_dp_d[0]  = (db[7]  & ~pba[0]) | (db[15] & pba[0]) ;
assign mux_dp_d[1]  = (db[23] & ~pba[0]) | (db[3]  & pba[0]) ;
assign mux_dp_d[2]  = (db[11] & ~pbb[0]) | (db[19] & pbb[0]) ;
assign mux_dp_d[3]  =  db[27] ;
assign mux_dp_d[4]  = (mux_dp[0] & ~pbad[1])  | (mux_dp[1] & pbad[1]) ;
assign mux_dp_d[5]  = (mux_dp[2] & ~pbad[1])  | (mux_dp[3] & pbad[1]) ;
assign mux_dp_d[6]  = (mux_dp[4] & ~pbadd[2]) | (mux_dp[5] & pbadd[2]) ;

(* RLOC = {"x",xa,"y7"} *)	FD	muxdp0 	(.D(mux_dp_d[0]),  .C(clkx3p5), .Q(mux_dp[0])) ;
(* RLOC = {"x",xa,"y7"} *)	FD	muxdp1 	(.D(mux_dp_d[1]),  .C(clkx3p5), .Q(mux_dp[1])) ;
(* RLOC = "x3y7" *)		FD	muxdp2 	(.D(mux_dp_d[2]),  .C(clkx3p5), .Q(mux_dp[2])) ;
(* RLOC = "x3y7" *)		FD	muxdp3 	(.D(mux_dp_d[3]),  .C(clkx3p5), .Q(mux_dp[3])) ;
(* RLOC = {"x",xc,"y6"} *)	FD	muxdp4 	(.D(mux_dp_d[4]),  .C(clkx3p5), .Q(mux_dp[4])) ;
(* RLOC = {"x",xc,"y6"} *)	FD	muxdp5 	(.D(mux_dp_d[5]),  .C(clkx3p5), .Q(mux_dp[5])) ;
(* RLOC = {"x",xd,"y6"}, BEL = "FFY"  *)	FD	muxdp6 	(.D(mux_dp_d[6]),  .C(clkx3p5), .Q(mux_p[3])) ;

(* RLOC = {"x",xd,"y1"}, BEL = "FFX"  *)	FD 	fd_mnn0	(.C(clkx3p5not), .D(mux_p[0]), .Q(dataout[0])) ;
(* RLOC = {"x",xb,"y1"}, BEL = "FFX"  *)	FD 	fd_mnn1	(.C(clkx3p5not), .D(mux_p[1]), .Q(dataout[1])) ;
(* RLOC = {"x",xb,"y6"}, BEL = "FFX"  *)	FD 	fd_mnn2	(.C(clkx3p5not), .D(mux_p[2]), .Q(dataout[2])) ;
(* RLOC = {"x",xd,"y7"}, BEL = "FFX"  *)	FD 	fd_mnn3	(.C(clkx3p5not), .D(mux_p[3]), .Q(dataout[3])) ;
(* RLOC = {"x",xb,"y8"}, BEL = "FFX"  *)	FD 	fd_mnn4	(.C(clkx3p5not), .D(clkcn),    .Q(clkout[0])) ;

(* RLOC = {"x",xb,"y7"} *)	FD	fd_clkcp  	(.C(clkx3p5),  .D(clkcp_d),  .Q(clkout[1])) ;
(* RLOC = {"x",xb,"y7"} *)	FD	fd_clkcn 	(.C(clkx3p5),  .D(clkcn_d),  .Q(clkcn)) ;

//assign 	clkcp_d = (~pba[2] & ~pba[1] & pba[0]) | (~pba[2] & pba[1] & ~pba[0]) | (pba[2] & ~pba[1] & pba[0]) ;		// Use these two lines for 3:4 output clock
//assign 	clkcn_d = (~pba[2] & ~pba[1] & pba[0]) | (pba[2] & ~pba[1] & ~pba[0]) | (pba[2] & ~pba[1] & pba[0]) ;

assign 	clkcp_d = (~pba[2] & ~pba[1] & pba[0]) | (~pba[2] & pba[1] & ~pba[0]) | (pba[2] & ~pba[1] & pba[0]) | (pba[2] &  pba[1] & ~pba[0]) ;		// Use these two lines for 4:3 output clock
assign 	clkcn_d = (~pba[2] & ~pba[1] & pba[0]) | (~pba[2] & pba[1] & ~pba[0]) | (pba[2] & ~pba[1] & pba[0]) | (pba[2] & ~pba[1] & ~pba[0]) ;

assign xra = clkd2d_a ^ clkd2d_b ;

(* RLOC = {"x",xb,"y4"} *)	FDC 	fd_xra	(.C(clkx3p5), .D(xra),     .CLR(rst), .Q(xrareg)) ;

always@(xrareg or pba)
begin
 	if(xrareg) begin
  		phase_bna <= 3'b110;
 	end 
 	else if (pba == 3'b110) begin
  		phase_bna <= 3'b000;
   	end
   	else begin
  		phase_bna <= pba + 3'b001;   	
  	end
end
             
always@(xrareg or pbb)
begin
 	if(xrareg) begin
  		phase_bnb <= 3'b110;
 	end 
 	else if (pbb == 3'b110) begin
  		phase_bnb <= 3'b000;
   	end
   	else begin
  		phase_bnb <= pbb + 3'b001;   	
  	end
end

assign notclk3p5d2 = ~clk3p5d2a ;			// divide clk35 by 2
(* RLOC = {"x",xc,"y3"} *)	FDC fd_c35d2a(.C(clkx3p5), .D(notclk3p5d2), .CLR(rst), .Q(clk3p5d2a)) ;
(* RLOC = {"x",xc,"y3"} *)	FDC fd_c35d2b(.C(clkx3p5), .D(notclk3p5d2), .CLR(rst), .Q(clk3p5d2b)) ;

(* RLOC = {"x",xb,"y2"}, BEL = "FFX" *)	FDC fd_cb  (.C(clk),     .D(clk3p5d2b), .CLR(rst), .Q(clkd2)) ; 
(* RLOC = {"x",xb,"y3"}, BEL = "FFX" *)	FDC fd_cbda(.C(clkx3p5), .D(clkd2),     .CLR(rst), .Q(clkd2d_a)) ; 
(* RLOC = {"x",xb,"y3"} *)		FDC fd_cbdb(.C(clkx3p5), .D(clkd2d_a),  .CLR(rst), .Q(clkd2d_b)) ; 

(* RLOC = {"x",xb,"y4"} *)	FDC fdcpba0(.C(clkx3p5), .D(phase_bna[0]), .CLR(rst), .Q(pba[0]))	/* synthesis syn_replicate = 0 */; 
(* RLOC = {"x",xa,"y4"} *)	FDC fdcpba1(.C(clkx3p5), .D(phase_bna[1]), .CLR(rst), .Q(pba[1]))	/* synthesis syn_replicate = 0 */;
(* RLOC = {"x",xa,"y4"} *)	FDC fdcpba2(.C(clkx3p5), .D(phase_bna[2]), .CLR(rst), .Q(pba[2]))	/* synthesis syn_replicate = 0 */; 
(* RLOC = {"x",xc,"y4"} *)	FD  fdcpba3(.C(clkx3p5), .D(pba[1]),       .Q(pbad[1]))			/* synthesis syn_replicate = 0 */;
(* RLOC = {"x",xb,"y5"} *)	FD  fdcpba4(.C(clkx3p5), .D(pba[2]),       .Q(pbad[2]))			/* synthesis syn_replicate = 0 */; 
(* RLOC = {"x",xc,"y4"} *)	FD  fdcpba5(.C(clkx3p5), .D(pbad[2]),      .Q(pbadd[2]))		/* synthesis syn_replicate = 0 */; 

(* RLOC = "x2y4" *)	FDC fdcpbb0(.C(clkx3p5), .D(phase_bnb[0]), .CLR(rst), .Q(pbb[0]))		/* synthesis syn_replicate = 0 */; 
(* RLOC = "x2y4" *)	FDC fdcpbb1(.C(clkx3p5), .D(phase_bnb[1]), .CLR(rst), .Q(pbb[1]))		/* synthesis syn_replicate = 0 */;
(* RLOC = "x2y3" *)	FDC fdcpbb2(.C(clkx3p5), .D(phase_bnb[2]), .CLR(rst), .Q(pbb[2]))		/* synthesis syn_replicate = 0 */; 

assign ce0_d = ((pbb == 3'b001) || (pbb == 3'b100)) ? 1'b1 : 1'b0 ;
assign ce1_d = ((pbb == 3'b100) || (pbb == 3'b000)) ? 1'b1 : 1'b0 ;

(* RLOC = "x2y5" *)	FD fd_ce0(.C(clkx3p5), .D(ce0_d), .Q(ce0)) ;
(* RLOC = "x2y5" *)	FD fd_ce1(.C(clkx3p5), .D(ce1_d), .Q(ce1)) ;

(* RLOC = "x1y1" *)	FDE fd_db0 (.C(clkx3p5), .D(dataint[0]),  .CE(ce0), .Q(db[0])) ; 
(* RLOC = "x1y3" *)	FDE fd_db1 (.C(clkx3p5), .D(dataint[1]),  .CE(ce0), .Q(db[1])) ; 
(* RLOC = "x1y6" *)	FDE fd_db2 (.C(clkx3p5), .D(dataint[2]),  .CE(ce0), .Q(db[2])) ; 
(* RLOC = "x1y6" *)	FDE fd_db3 (.C(clkx3p5), .D(dataint[3]),  .CE(ce0), .Q(db[3])) ; 
(* RLOC = "x0y1" *)	FDE fd_db4 (.C(clkx3p5), .D(dataint[4]),  .CE(ce0), .Q(db[4])) ; 
(* RLOC = "x0y3" *)	FDE fd_db5 (.C(clkx3p5), .D(dataint[5]),  .CE(ce0), .Q(db[5])) ; 
(* RLOC = "x0y5" *)	FDE fd_db6 (.C(clkx3p5), .D(dataint[6]),  .CE(ce0), .Q(db[6])) ; 
(* RLOC = "x1y7" *)	FDE fd_db7 (.C(clkx3p5), .D(dataint[7]),  .CE(ce0), .Q(db[7])) ; 
(* RLOC = "x0y0" *)	FDE fd_db8 (.C(clkx3p5), .D(dataint[8]),  .CE(ce0), .Q(db[8])) ; 
(* RLOC = "x0y4" *)	FDE fd_db9 (.C(clkx3p5), .D(dataint[9]),  .CE(ce0), .Q(db[9])) ;
(* RLOC = "x1y3" *)	FDE fd_db10(.C(clkx3p5), .D(dataint[10]), .CE(ce0), .Q(db[10])) ;
(* RLOC = "x0y6" *)	FDE fd_db11(.C(clkx3p5), .D(dataint[11]), .CE(ce0), .Q(db[11])) ; 
(* RLOC = "x1y1" *)	FDE fd_db12(.C(clkx3p5), .D(dataint[12]), .CE(ce0), .Q(db[12])) ; 
(* RLOC = "x0y6" *)	FDE fd_db13(.C(clkx3p5), .D(dataint[13]), .CE(ce0), .Q(db[13])) ; 
(* RLOC = "x0y5" *)	FDE fd_db14(.C(clkx3p5), .D(dataint[14]), .CE(ce0), .Q(db[14])) ; 
(* RLOC = "x0y7" *)	FDE fd_db15(.C(clkx3p5), .D(dataint[15]), .CE(ce0), .Q(db[15])) ; 
(* RLOC = "x0y0" *)	FDE fd_db16(.C(clkx3p5), .D(dataint[16]), .CE(ce0), .Q(db[16])) ;
(* RLOC = "x0y4" *)	FDE fd_db17(.C(clkx3p5), .D(dataint[17]), .CE(ce0), .Q(db[17])) ; 
(* RLOC = "x0y3" *)	FDE fd_db18(.C(clkx3p5), .D(dataint[18]), .CE(ce0), .Q(db[18])) ; 
(* RLOC = "x0y7" *)	FDE fd_db19(.C(clkx3p5), .D(dataint[19]), .CE(ce0), .Q(db[19])) ; 
(* RLOC = "x1y0" *)	FDE fd_db20(.C(clkx3p5), .D(datainr[20]), .CE(ce1), .Q(db[20])) ; 
(* RLOC = "x1y0" *)	FDE fd_db21(.C(clkx3p5), .D(datainr[21]), .CE(ce1), .Q(db[21])) ; 
(* RLOC = "x1y5" *)	FDE fd_db22(.C(clkx3p5), .D(datainr[22]), .CE(ce1), .Q(db[22])) ; 
(* RLOC = "x1y5" *)	FDE fd_db23(.C(clkx3p5), .D(datainr[23]), .CE(ce1), .Q(db[23])) ; 
(* RLOC = "x2y0" *)	FDE fd_db24(.C(clkx3p5), .D(datainr[24]), .CE(ce1), .Q(db[24])) ;
(* RLOC = "x1y4" *)	FDE fd_db25(.C(clkx3p5), .D(datainr[25]), .CE(ce1), .Q(db[25])) ;
(* RLOC = "x1y4" *)	FDE fd_db26(.C(clkx3p5), .D(datainr[26]), .CE(ce1), .Q(db[26])) ;
(* RLOC = "x2y7" *)	FDE fd_db27(.C(clkx3p5), .D(datainr[27]), .CE(ce1), .Q(db[27])) ;

(* RLOC = "x0y2" *)	FD fd_d20(.C(clk), .D(dataint[20]), .Q(datainr[20])) ; 
(* RLOC = "x0y2" *)	FD fd_d21(.C(clk), .D(dataint[21]), .Q(datainr[21])) ; 
(* RLOC = "x1y2" *)	FD fd_d22(.C(clk), .D(dataint[22]), .Q(datainr[22])) ; 
(* RLOC = "x1y2" *)	FD fd_d23(.C(clk), .D(dataint[23]), .Q(datainr[23])) ; 
(* RLOC = "x2y1" *)	FD fd_d24(.C(clk), .D(dataint[24]), .Q(datainr[24])) ; 
(* RLOC = "x2y1" *)	FD fd_d25(.C(clk), .D(dataint[25]), .Q(datainr[25])) ; 
(* RLOC = "x2y6" *)	FD fd_d26(.C(clk), .D(dataint[26]), .Q(datainr[26])) ; 
(* RLOC = "x2y6" *)	FD fd_d27(.C(clk), .D(dataint[27]), .Q(datainr[27])) ; 

endmodule

