/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores ATA/ATAPI-5 Host Controller                      ////
////  PIO Access Controller (common for OCIDEC 2 and above)      ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001, 2002 Richard Herveille                  ////
////                          richard@asics.ws                   ////
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

//
//  CVS Log
//
//  $Id: atahost_pio_actrl.v,v 1.1 2002-02-18 14:26:46 rherveille Exp $
//
//  $Date: 2002-02-18 14:26:46 $
//  $Revision: 1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $

`include "timescale.v"

module atahost_pio_actrl (
		clk, nReset, rst, IDEctrl_FATR0, IDEctrl_FATR1,
		cmdport_T1, cmdport_T2, cmdport_T4, cmdport_Teoc, cmdport_IORDYen,
		dport0_T1, dport0_T2, dport0_T4, dport0_Teoc, dport0_IORDYen,
		dport1_T1, dport1_T2, dport1_T4, dport1_Teoc, dport1_IORDYen,
		SelDev, go, done, dir, a, q, DDi, oe, DIOR, DIOW, IORDY
	);

	//
	// parameters
	//
	parameter TWIDTH = 8;
	parameter PIO_mode0_T1   =  6;             // 70ns
	parameter PIO_mode0_T2   = 28;             // 290ns
	parameter PIO_mode0_T4   =  2;             // 30ns
	parameter PIO_mode0_Teoc = 23;             // 240ns

	//
	// inputs & outputs
	//
	input clk;                                 // master clock
	input nReset;                              // asynchronous active low reset
	input rst;                                 // synchronous active high reset

	input IDEctrl_FATR0;
	input IDEctrl_FATR1;

	input [7:0] cmdport_T1,
	            cmdport_T2,
	            cmdport_T4,
	            cmdport_Teoc;
	input       cmdport_IORDYen;               // PIO command port / non-fast timing

	input [7:0] dport0_T1,
	            dport0_T2,
	            dport0_T4,
	            dport0_Teoc;
	input       dport0_IORDYen;                // PIO mode data-port / fast timing device 0

	input [7:0] dport1_T1,
	            dport1_T2,
	            dport1_T4,
	            dport1_Teoc;
	input       dport1_IORDYen;                // PIO mode data-port / fast timing device 1

	input SelDev;                              // Selected device	

	input         go;                          // Start transfer sequence
	output        done;                        // Transfer sequence done
	input         dir;                         // Transfer direction '1'=write, '0'=read
	input  [ 3:0] a;                           // PIO transfer address
	output [15:0] q;                           // Data read from ATA devices
	reg [15:0] q;

	input [15:0] DDi;                          // Data from ATA DD bus
	output       oe;                           // DDbus output-enable signal

	output DIOR;
	output DIOW;
	input  IORDY;

	//
	// signals & variables
	//
	wire      dstrb;
	reg [7:0] T1, T2, T4, Teoc;
	reg       IORDYen;


	//
	// Module body
	//

	// PIO transfer control
  //
	// capture ATA data for PIO access
	always@(posedge clk)
		if (dstrb)
			q <= DDi;


	// PIO timing controllers
	//
  // select timing settings for the addressed port
	always@(posedge clk)
		if (|a) // command ports accessed ?
			begin
				T1      <= #1 cmdport_T1;
				T2      <= #1 cmdport_T2;
				T4      <= #1 cmdport_T4;
				Teoc    <= #1 cmdport_Teoc;
				IORDYen <= #1 cmdport_IORDYen;
			end
		else    // data ports accessed
			begin
				if (SelDev & IDEctrl_FATR1)
					begin
						T1      <= #1 dport1_T1;
						T2      <= #1 dport1_T2;
						T4      <= #1 dport1_T4;
						Teoc    <= #1 dport1_Teoc;
						IORDYen <= #1 dport1_IORDYen;
					end
				else if (!SelDev & IDEctrl_FATR0)
					begin
						T1      <= #1 dport0_T1;
						T2      <= #1 dport0_T2;
						T4      <= #1 dport0_T4;
						Teoc    <= #1 dport0_Teoc;
						IORDYen <= #1 dport0_IORDYen;
					end
				else
					begin
						T1      <= #1 cmdport_T1;
						T2      <= #1 cmdport_T2;
						T4      <= #1 cmdport_T4;
						Teoc    <= #1 cmdport_Teoc;
						IORDYen <= #1 cmdport_IORDYen;
					end
			end

	//
	// hookup timing controller
	//
	atahost_pio_tctrl #(TWIDTH, PIO_mode0_T1, PIO_mode0_T2, PIO_mode0_T4, PIO_mode0_Teoc)
		PIO_timing_controller (
			.clk(clk),
			.nReset(nReset),
			.rst(rst),
			.IORDY_en(IORDYen),
			.T1(T1),
			.T2(T2),
			.T4(T4),
			.Teoc(Teoc),
			.go(go),
			.we(dir),
			.oe(oe),
			.done(done),
			.dstrb(dstrb),
			.DIOR(DIOR),
			.DIOW(DIOW),
			.IORDY(IORDY)
		);

endmodule

