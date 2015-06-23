/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores ATA/ATAPI-5 Host Controller                      ////
////  PIO Timing Controller (common for all OCIDEC cores)        ////
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

//  CVS Log
//
//  $Id: atahost_pio_tctrl.v,v 1.1 2002-02-18 14:26:46 rherveille Exp $
//
//  $Date: 2002-02-18 14:26:46 $
//  $Revision: 1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               Rev. 1.0 June 27th, 2001. Initial Verilog release
//               Rev. 1.1 July  2nd, 2001. Fixed incomplete port list and some Verilog related issues.
//               Rev. 1.2 July 11th, 2001. Changed 'igo' & 'hold_go' generation.
//
//               $Log: not supported by cvs2svn $
//               Revision 1.2  2002/02/16 10:42:17  rherveille
//               Added disclaimer
//               Added CVS information
//               Changed core for new internal counter libraries (synthesis fixes).
//
//


//
// Timing	PIO mode transfers
//--------------------------------------------
// T0:	cycle time
// T1:	address valid to DIOR-/DIOW-
// T2:	DIOR-/DIOW- pulse width
// T2i:	DIOR-/DIOW- recovery time
// T3:	DIOW- data setup
// T4:	DIOW- data hold
// T5:	DIOR- data setup
// T6:	DIOR- data hold
// T9:	address hold from DIOR-/DIOW- negated
// Trd:	Read data valid to IORDY asserted
// Ta:	IORDY setup time
// Tb:	IORDY pulse width
//
// Transfer sequence
//--------------------------------
// 1)	set address (DA, CS0-, CS1-)
// 2)	wait for T1
// 3)	assert DIOR-/DIOW-
//	   when write action present Data (timing spec. T3 always honored), enable output enable-signal
// 4)	wait for T2
// 5)	check IORDY
//	   when not IORDY goto 5
// 	  when IORDY negate DIOW-/DIOR-, latch data (if read action)
//    when write, hold data for T4, disable output-enable signal
// 6)	wait end_of_cycle_time. This is T2i or T9 or (T0-T1-T2) whichever takes the longest
// 7)	start new cycle

`include "timescale.v"

module atahost_pio_tctrl(clk, nReset, rst, IORDY_en, T1, T2, T4, Teoc, go, we, oe, done, dstrb, DIOR, DIOW, IORDY);
	// parameter declarations
	parameter TWIDTH = 8;
	parameter PIO_MODE0_T1   =  6;             // 70ns
	parameter PIO_MODE0_T2   = 28;             // 290ns
	parameter PIO_MODE0_T4   =  2;             // 30ns
	parameter PIO_MODE0_Teoc = 23;             // 240ns
	
	// inputs & outputs
	input clk; // master clock
	input nReset; // asynchronous active low reset
	input rst; // synchronous active high reset
	
	// timing & control register settings
	input IORDY_en;          // use IORDY (or not)
	input [TWIDTH-1:0] T1;   // T1 time (in clk-ticks)
	input [TWIDTH-1:0] T2;   // T1 time (in clk-ticks)
	input [TWIDTH-1:0] T4;   // T1 time (in clk-ticks)
	input [TWIDTH-1:0] Teoc; // T1 time (in clk-ticks)

	// control signals
	input go; // PIO controller selected (strobe signal)
	input we; // write enable signal. 1'b0 == read, 1'b1 == write

	// return signals
	output oe; // output enable signal
	reg oe;
	output done; // finished cycle
	output dstrb; // data strobe, latch data (during read)
	reg dstrb;

	// ata signals
	output DIOR; // IOread signal, active high
	reg DIOR;
	output DIOW; // IOwrite signal, active high
	reg DIOW;
	input  IORDY; // IOrDY signal


	//
	// constant declarations
	//
	// PIO mode 0 settings (@100MHz clock)
	wire [TWIDTH-1:0] T1_m0   = PIO_MODE0_T1;
	wire [TWIDTH-1:0] T2_m0   = PIO_MODE0_T2;
	wire [TWIDTH-1:0] T4_m0   = PIO_MODE0_T4;
	wire [TWIDTH-1:0] Teoc_m0 = PIO_MODE0_Teoc;

	//
	// variable declaration
	//
	reg busy, hold_go;
	wire igo;
	wire T1done, T2done, T4done, Teoc_done, IORDY_done;
	reg hT2done;

	//
	// module body
	//

	// generate internal go strobe
	// strecht go until ready for new cycle
	always@(posedge clk or negedge nReset)
		if (~nReset)
			begin
				busy    <= #1 1'b0;
				hold_go <= #1 1'b0;
			end
		else if (rst)
			begin
				busy    <= #1 1'b0;
				hold_go <= #1 1'b0;
			end
		else
			begin
				busy    <= #1 (igo | busy) & !Teoc_done;
				hold_go <= #1 (go | (hold_go & busy)) & !igo;
			end

	assign igo = (go | hold_go) & !busy;

	// 1)	hookup T1 counter
	ro_cnt #(TWIDTH, 1'b0, PIO_MODE0_T1)
		t1_cnt(
			.clk(clk),
			.rst(rst),
			.nReset(nReset),
			.cnt_en(1'b1),
			.go(igo),
			.d(T1),
			.q(),
			.done(T1done)
		);

	// 2)	set (and reset) DIOR-/DIOW-, set output-enable when writing to device
	always@(posedge clk or negedge nReset)
		if (~nReset)
			begin
				DIOR <= #1 1'b0;
				DIOW <= #1 1'b0;
				oe   <= #1 1'b0;
			end
		else if (rst)
			begin
				DIOR <= #1 1'b0;
				DIOW <= #1 1'b0;
				oe   <= #1 1'b0;
			end
		else
			begin
				DIOR <= #1 (!we & T1done) | (DIOR & !IORDY_done);
				DIOW <= #1 ( we & T1done) | (DIOW & !IORDY_done);
				oe   <= #1 ( (we & igo) | oe) & !T4done;           // negate oe when t4-done
			end

	// 3)	hookup T2 counter
	ro_cnt #(TWIDTH, 1'b0, PIO_MODE0_T2)
		t2_cnt(
			.clk(clk),
			.rst(rst),
			.nReset(nReset),
			.cnt_en(1'b1),
			.go(T1done),
			.d(T2),
			.q(),
			.done(T2done)
		);

	// 4)	check IORDY (if used), generate release_DIOR-/DIOW- signal (ie negate DIOR-/DIOW-)
	// hold T2done
	always@(posedge clk or negedge nReset)
		if (~nReset)
			hT2done <= #1 1'b0;
		else if (rst)
			hT2done <= #1 1'b0;
		else
			hT2done <= #1 (T2done | hT2done) & !IORDY_done;

	assign IORDY_done = (T2done | hT2done) & (IORDY | !IORDY_en);

	// generate datastrobe, capture data at rising DIOR- edge
	always@(posedge clk)
		dstrb <= #1 IORDY_done;

	// hookup data hold counter
	ro_cnt #(TWIDTH, 1'b0, PIO_MODE0_T4)
		dhold_cnt(
			.clk(clk),
			.rst(rst),
			.nReset(nReset),
			.cnt_en(1'b1),
			.go(IORDY_done),
			.d(T4),
			.q(),
			.done(T4done)
		);

	assign done = T4done; // placing done here provides the fastest return possible, 
                        // while still guaranteeing data and address hold-times

	// 5)	hookup end_of_cycle counter
	ro_cnt #(TWIDTH, 1'b0, PIO_MODE0_Teoc)
		eoc_cnt(
			.clk(clk),
			.rst(rst),
			.nReset(nReset),
			.cnt_en(1'b1),
			.go(IORDY_done),
			.d(Teoc),
			.q(),
			.done(Teoc_done)
		);

endmodule
