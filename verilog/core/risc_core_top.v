/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Mini-RISC-1                                                ////
////  Mini-Risc Core Top Levcel                                  ////
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
//  $Id: risc_core_top.v,v 1.3 2002-10-01 12:44:24 rudi Exp $
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

module mrisc_top(
   clk, rst_in,
   porta, portb, portc,
   tcki,
   wdt_en );	// synthesis syn_useioff=1 syn_hier="flatten,remove"

// Basic Core I/O.
input		clk;
input		rst_in;

// I/O Ports
inout  [7:0]	porta;
inout  [7:0]	portb;
inout  [7:0]	portc;

input		tcki;
input		wdt_en;

////////////////////////////////////////////////////////////////////////
//
// Local Wires
//

wire [10:0]	inst_addr;
wire [11:0]	inst_data;

wire [7:0]	portain;
wire [7:0]	portbin;
wire [7:0]	portcin;

wire [7:0]	portaout;
wire [7:0]	portbout;
wire [7:0]	portcout;

wire [7:0]	trisa;
wire [7:0]	trisb;
wire [7:0]	trisc;

////////////////////////////////////////////////////////////////////////
//
// IO Buffers
//

assign porta[0] = trisa[0] ? 1'bz : portaout[0];
assign porta[1] = trisa[1] ? 1'bz : portaout[1];
assign porta[2] = trisa[2] ? 1'bz : portaout[2];
assign porta[3] = trisa[3] ? 1'bz : portaout[3];
assign porta[4] = trisa[4] ? 1'bz : portaout[4];
assign porta[5] = trisa[5] ? 1'bz : portaout[5];
assign porta[6] = trisa[6] ? 1'bz : portaout[6];
assign porta[7] = trisa[7] ? 1'bz : portaout[7];

assign portb[0] = trisb[0] ? 1'bz : portbout[0];
assign portb[1] = trisb[1] ? 1'bz : portbout[1];
assign portb[2] = trisb[2] ? 1'bz : portbout[2];
assign portb[3] = trisb[3] ? 1'bz : portbout[3];
assign portb[4] = trisb[4] ? 1'bz : portbout[4];
assign portb[5] = trisb[5] ? 1'bz : portbout[5];
assign portb[6] = trisb[6] ? 1'bz : portbout[6];
assign portb[7] = trisb[7] ? 1'bz : portbout[7];

assign portc[0] = trisc[0] ? 1'bz : portcout[0];
assign portc[1] = trisc[1] ? 1'bz : portcout[1];
assign portc[2] = trisc[2] ? 1'bz : portcout[2];
assign portc[3] = trisc[3] ? 1'bz : portcout[3];
assign portc[4] = trisc[4] ? 1'bz : portcout[4];
assign portc[5] = trisc[5] ? 1'bz : portcout[5];
assign portc[6] = trisc[6] ? 1'bz : portcout[6];
assign portc[7] = trisc[7] ? 1'bz : portcout[7];

assign portain = porta;
assign portbin = portb;
assign portcin = portc;

////////////////////////////////////////////////////////////////////////
//
// Mini Risc Core
//

mrisc u0(
   clk,
   rst_in,
   
   inst_addr,
   inst_data,

   portain,
   portbin,
   portcin,

   portaout,
   portbout,
   portcout,

   trisa,
   trisb,
   trisc,
   
   tcki,
   wdt_en );


////////////////////////////////////////////////////////////////////////
//
// Program memory
//

generic_spram #(11,12) imem(
	.clk(	clk		),
	.rst(	rst_in		),
	.ce(	1'b1		),
	.we(	1'b0		),
	.oe(	1'b1		),
	.addr(	inst_addr	),
	.di(	12'h0		),
	.do(	inst_data	)
	);

endmodule
