/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Mini-RISC-1                                                ////
////  Prescaler and Wachdog Counter                              ////
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
//  $Id: presclr_wdt.v,v 1.2 2002-09-27 15:35:40 rudi Exp $
//
//  $Date: 2002-09-27 15:35:40 $
//  $Revision: 1.2 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
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

// Prescaler and Wachdog Counter
module presclr_wdt(clk, rst, tcki, option, tmr0_we, tmr0_cnt_en, wdt_en, wdt_clr, wdt_to);
input		clk;
input		rst;
input		tcki;
input	[5:0]	option;
input		tmr0_we;
output		tmr0_cnt_en;
input		wdt_en, wdt_clr;
output		wdt_to;


reg	[7:0]	prescaler;
reg	[7:0]	wdt;
reg		tmr0_cnt_en;
reg		tcki_r;
reg		wdt_to;
wire		tose;
wire		tosc;
wire		psa;
wire	[2:0]	ps;
wire		tcki_a, tcki_b;
wire		presclr_ce;
wire		prsclr_clr;
wire		wdt_to_direct;
reg		presclr_out, presclr_out_r1;
reg		presclr_out_next;
wire	[7:0]	presclr_plus_1, wdt_plus_1;
wire	[7:0]	prescaler_next, prescaler_next1;
wire	[7:0]	wdt_next, wdt_next1;

// Inputs select
assign	ps = option[2:0];
assign	psa = option[3];
assign	tose = option[4];
assign	tosc = option[5];

always @(posedge clk)
	tcki_r <= #1 tcki;

assign  tcki_a = tose ^ tcki_r;
assign	tcki_b = tosc ? tcki_a : 1'b1;
assign	presclr_ce = psa ? wdt_to_direct : tcki_b;

always @(posedge clk)
	tmr0_cnt_en <= #1 psa ? tcki_b : presclr_out;

// Prescaler
assign	prsclr_clr = psa ? wdt_clr : tmr0_we;

always @(posedge clk)
	if(rst | prsclr_clr)	prescaler <= #1 8'h00;
	else
	if(presclr_ce)		prescaler <= #1 prescaler + 8'h01;

always @(ps or prescaler)
	case(ps)
	   3'd0:	presclr_out_next = prescaler[0];
	   3'd1:	presclr_out_next = prescaler[1];
	   3'd2:	presclr_out_next = prescaler[2];
	   3'd3:	presclr_out_next = prescaler[3];
	   3'd4:	presclr_out_next = prescaler[4];
	   3'd5:	presclr_out_next = prescaler[5];
	   3'd6:	presclr_out_next = prescaler[6];
	   3'd7:	presclr_out_next = prescaler[7];
	endcase

always @(posedge clk)
	presclr_out_r1 <= #1 presclr_out_next;

always @(posedge clk)	// Edge detector for prescaler output
	presclr_out <= #1 presclr_out_next & ~presclr_out_r1 & ~prsclr_clr;

// Wachdog timer
always @(posedge clk)
	wdt_to <= #1 psa ? presclr_out : wdt_to_direct;

always @(posedge clk)
	if(rst | wdt_clr)	wdt <= #1 8'h00;
	else
	if(wdt_en)		wdt <= #1 wdt + 8'h01;	// wdt_plus_1;

assign	wdt_to_direct = (wdt == 8'hff);

endmodule
