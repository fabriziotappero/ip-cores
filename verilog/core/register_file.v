/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Mini-RISC-1                                                ////
////  Register File                                              ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  D/L from: http://www.opencores.org/cores/minirisc/         ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: register_file.v,v 1.3 2002-10-01 12:44:24 rudi Exp $
//
//  $Date: 2002-10-01 12:44:24 $
//  $Revision: 1.3 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.2  2002/09/27 15:35:40  rudi
//               Minor update to newer devices ...
//
//
//
//
//
//
//
//
//
//
//

`timescale 1ns / 10ps

module register_file(	clk, rst,
			rf_rd_bnk, rf_rd_addr, rf_rd_data,
			rf_we, rf_wr_bnk, rf_wr_addr, rf_wr_data);

input		clk,rst;
input  [1:0]	rf_rd_bnk;
input  [4:0]	rf_rd_addr;
output [7:0]	rf_rd_data;
input		rf_we;
input  [1:0]	rf_wr_bnk;
input  [4:0]	rf_wr_addr;
input  [7:0]	rf_wr_data;

wire		clk;
wire [7:0]	rf_rd_data;
wire [6:0]	rd_addr;
wire [6:0]	wr_addr;
wire [7:0]	rf_rd_data_mem;
reg  [7:0]	wr_data_tmp;
reg		rd_wr_addr_equal;

// Simple Read & Write Address Mapping to memory address
assign	rd_addr[6]   = ~rf_rd_addr[4];
assign	rd_addr[5:3] = rf_rd_addr[4] ? {rf_rd_bnk, rf_rd_addr[3]} : 3'h0;
assign	rd_addr[2:0] = rf_rd_addr[2:0];

assign	wr_addr[6]   = ~rf_wr_addr[4];
assign	wr_addr[5:3] = rf_wr_addr[4] ? {rf_wr_bnk, rf_wr_addr[3]} : 3'h0;
assign	wr_addr[2:0] = rf_wr_addr[2:0];

// This logic is to bypass the register file if we are reading and
// writing (in previous instruction) to the same register
always @(posedge clk)
	rd_wr_addr_equal <= #1 (rd_addr==wr_addr) & rf_we;

assign rf_rd_data = rd_wr_addr_equal ? wr_data_tmp : rf_rd_data_mem;

always @(posedge clk)
	wr_data_tmp <= #1 rf_wr_data;

// This is the actual Memory
generic_dpram #(7,8) rf0(
        	.rclk(		clk		),
		.rrst(		rst		),
		.rce(		1'b1		),
		.oe(		1'b1		),
		.raddr(		rd_addr		),
		.do(		rf_rd_data_mem	),
        	.wclk(		clk		),
		.wrst(		rst		),
		.wce(		1'b1		),
		.we(		rf_we		),
		.waddr(		wr_addr		),
		.di(		rf_wr_data	)
		);

endmodule
