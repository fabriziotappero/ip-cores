/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores ATA/ATAPI-5 Host Controller                      ////
////  ATA/ATAPI-5 PIO Controller (OCIDEC-2)                      ////
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
//  $Id: atahost_controller.v,v 1.2 2002-05-19 06:05:28 rherveille Exp $
//
//  $Date: 2002-05-19 06:05:28 $
//  $Revision: 1.2 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $

//
// OCIDEC2 supports:	
// -Common Compatible timing access to all connected devices
//	-Separate timing accesses to data port
// -No DMA support
//

`include "timescale.v"

module atahost_controller (
		clk, nReset, rst, irq, IDEctrl_rst, IDEctrl_IDEen, IDEctrl_FATR0, IDEctrl_FATR1,
		cmdport_T1, cmdport_T2, cmdport_T4, cmdport_Teoc, cmdport_IORDYen,
		dport0_T1, dport0_T2, dport0_T4, dport0_Teoc, dport0_IORDYen,
		dport1_T1, dport1_T2, dport1_T4, dport1_Teoc, dport1_IORDYen,
		PIOreq, PIOack, PIOa, PIOd, PIOq, PIOwe,
		RESETn, DDi, DDo, DDoe, DA, CS0n, CS1n, DIORn, DIOWn, IORDY, INTRQ
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
		
	output irq;                                // interrupt request signal
	reg irq;

	// control / registers
	input IDEctrl_rst;
	input IDEctrl_IDEen;
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

	input         PIOreq;                      // PIO transfer request
	output        PIOack;                      // PIO transfer ended
	input  [ 3:0] PIOa;                        // PIO address
	input  [15:0] PIOd;                        // PIO data in
	output [15:0] PIOq;                        // PIO data out
	input         PIOwe;                       // PIO direction bit '1'=write, '0'=read

	reg PIOack;

	// ATA signals
	output        RESETn;
	input  [15:0] DDi;
	output [15:0] DDo;
	output        DDoe;
	output [ 2:0] DA;
	output        CS0n;
	output        CS1n;
	output        DIORn;
	output        DIOWn;
	input         IORDY;
	input         INTRQ;

	reg        RESETn;
	reg [15:0] DDo;
	reg        DDoe;
	reg [ 2:0] DA;
	reg        CS0n;
	reg        CS1n;
	reg        DIORn;
	reg        DIOWn;


	//
	// signals & variables
	//
	wire PIOdone;                     // PIO timing controller done

	// PIO signals
	wire PIOdior, PIOdiow, PIOoe;

	// synchronized ATA inputs
	reg sIORDY;

	//
	// module body
	//


	// synchronize incoming signals
	reg cIORDY;                               // capture IORDY
	reg cINTRQ;                               // capture INTRQ

	always @(posedge clk)
	begin : synch_incoming

		cIORDY <= #1 IORDY;
		cINTRQ <= #1 INTRQ;

		sIORDY <= #1 cIORDY;
		irq    <= #1 cINTRQ;
	end

	// generate ATA signals
	always @(posedge clk or negedge nReset)
		if (~nReset)
			begin
				RESETn <= #1 1'b0;
				DIORn  <= #1 1'b1;
				DIOWn  <= #1 1'b1;
				DA     <= #1 0;
				CS0n   <= #1 1'b1;
				CS1n   <= #1 1'b1;
				DDo    <= #1 0;
				DDoe   <= #1 1'b0;
			end
		else if (rst)
			begin
				RESETn <= #1 1'b0;
				DIORn  <= #1 1'b1;
				DIOWn  <= #1 1'b1;
				DA     <= #1 0;
				CS0n   <= #1 1'b1;
				CS1n   <= #1 1'b1;
				DDo    <= #1 0;
				DDoe   <= #1 1'b0;
			end
		else
			begin
				RESETn <= #1 !IDEctrl_rst;
				DA     <= #1 PIOa[2:0];
				CS0n   <= #1 !( !PIOa[3] & PIOreq); // CS0 asserted when A(3) = '0'
				CS1n   <= #1 !(  PIOa[3] & PIOreq); // CS1 asserted when A(3) = '1'

				DDo    <= #1 PIOd;
				DDoe   <= #1 PIOoe;
				DIORn  <= #1 !PIOdior;
				DIOWn  <= #1 !PIOdiow;
			end

	// generate selected device
	reg SelDev;
	always @(posedge clk)
		if (PIOdone & (PIOa == 4'b0110) & PIOwe)
			SelDev <= #1 PIOd[4];

	// generate PIOgo signal
	always @(posedge clk or negedge nReset)
		if (~nReset)
			begin
				dPIOreq <= #1 1'b0;
				PIOgo   <= #1 1'b0;
			end
		else if (rst)
			begin
				dPIOreq <= #1 1'b0;
				PIOgo   <= #1 1'b0;
			end
		else
			begin
				dPIOreq <= #1 PIOreq & !PIOack;
				PIOgo   <= #1 (PIOreq & !dPIOreq) & IDEctrl_IDEen;
			end

	//
	// Hookup PIO access controller
	//
	atahost_pio_actrl #(TWIDTH, PIO_mode0_T1, PIO_mode0_T2, PIO_mode0_T4, PIO_mode0_Teoc)
		PIO_access_control (
			.clk(clk),
			.nReset(nReset),
			.rst(rst),
			.IDEctrl_FATR0(IDEctrl_FATR0),
			.IDEctrl_FATR1(IDEctrl_FATR1),
			.cmdport_T1(cmdport_T1),
			.cmdport_T2(cmdport_T2),
			.cmdport_T4(cmdport_T4),
			.cmdport_Teoc(cmdport_Teoc),
			.cmdport_IORDYen(cmdport_IORDYen),
			.dport0_T1(dport0_T1),
			.dport0_T2(dport0_T2),
			.dport0_T4(dport0_T4),
			.dport0_Teoc(dport0_Teoc),
			.dport0_IORDYen(dport0_IORDYen),
			.dport1_T1(dport1_T1),
			.dport1_T2(dport1_T2),
			.dport1_T4(dport1_T4),
			.dport1_Teoc(dport1_Teoc),
			.dport1_IORDYen(dport1_IORDYen),
			.SelDev(SelDev),
			.go(PIOgo),
			.done(PIOdone),
			.dir(PIOwe),
			.a(PIOa),
			.q(PIOq),
			.DDi(DDi),
			.oe(PIOoe),
			.DIOR(PIOdior),
			.DIOW(PIOdiow),
			.IORDY(sIORDY)
		);

	always @(posedge clk)
		PIOack <= #1 PIOdone | (PIOreq & !IDEctrl_IDEen); // acknowledge when done or when IDE not enabled (discard request)

endmodule
