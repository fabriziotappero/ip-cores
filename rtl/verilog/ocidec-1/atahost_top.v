/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OCIDEC-1 ATA/ATAPI-5 Controller                            ////
////  Top Level                                                 ////
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
//  $Id: atahost_top.v,v 1.7 2002-02-18 14:25:43 rherveille Exp $
//
//  $Date: 2002-02-18 14:25:43 $
//  $Revision: 1.7 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               rev.: 1.0    June 29th, 2001. Initial Verilog release
//               rev.: 1.1    July  3rd, 2001. Changed 'ADR_I[5:2]' into 'ADR_I' on output multiplexor sensitivity list.
//               rev.: 1.2    July  9th, 2001. Fixed register control; registers latched data on all edge cycles instead when selected.
//               rev.: 1.3    July 11th, 2001. Fixed case sensitivity error (nRESET instead of nReset) in "controller" module declaration.
//               rev.: 1.4    July 26th, 2001. Fixed non-blocking assignments.
//               rev.: 1.5  August 15th, 2001. Changed port-names to conform to new OpenCores naming-convention.
//               rev.: 1.6 October 15th, 2001. Removed ata_defines file. Changed define statement to parameter
//
//               $Log: not supported by cvs2svn $
//               Revision 1.6  2002/02/16 10:42:17  rherveille
//               Added disclaimer
//               Added CVS information
//               Changed core for new internal counter libraries (synthesis fixes).
//
//
//
//

/////////////////////////////////////////////////////////////
//
// DeviceType: OCIDEC-1: OpenCores IDE Controller type1
// Features: PIO Compatible Timing
// DeviceID: 0x01
// RevNo : 0x00
//

//
// Host signals:
// Reset
// DIOR-		read strobe. The falling edge enables data from device onto DD. The rising edge latches data at the host.
// DIOW-		write strobe. The rising edge latches data from DD into the device.
// DA(2:0)		3bit binary coded adress
// CS0-		select command block registers
// CS1-		select control block registers

`include "timescale.v"

module atahost_top (wb_clk_i, arst_i, wb_rst_i, wb_cyc_i, wb_stb_i, wb_ack_o, wb_err_o,
		wb_adr_i, wb_dat_i, wb_dat_o, wb_sel_i, wb_we_i, wb_inta_o,
		resetn_pad_o, dd_pad_i, dd_pad_o, dd_padoe_o, da_pad_o, cs0n_pad_o,
		cs1n_pad_o, diorn_pad_o, diown_pad_o, iordy_pad_i, intrq_pad_i);
	//
	// Parameter declarations
	//
	parameter ARST_LVL = 1'b0;                    // asynchronous reset level

	parameter TWIDTH = 8;                         // counter width
	// PIO mode 0 settings (@100MHz clock)
	parameter PIO_mode0_T1   =  6;                // 70ns
	parameter PIO_mode0_T2   = 28;                // 290ns
	parameter PIO_mode0_T4   =  2;                // 30ns
	parameter PIO_mode0_Teoc = 23;                // 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240

	//
	// inputs & outputs
	//

	// WISHBONE SYSCON signals
	input wb_clk_i;                               // master clock in
	input arst_i;                                 // asynchronous reset
	input wb_rst_i;                               // synchronous reset

	// WISHBONE SLAVE signals
	input        wb_cyc_i;                        // valid bus cycle input
	input        wb_stb_i;                        // strobe/core select input
	output       wb_ack_o;                        // strobe acknowledge output
	output       wb_err_o;                        // error output
	input  [6:2] wb_adr_i;                        // A6 = '1' ATA devices selected
	                                              //          A5 = '1' CS1- asserted, '0' CS0- asserted
	                                              //          A4..A2 ATA address lines
	                                              // A6 = '0' ATA controller selected
	input  [31:0] wb_dat_i;                       // Databus in
	output [31:0] wb_dat_o;                       // Databus out
	input  [ 3:0] wb_sel_i;                       // Byte select signals
	input         wb_we_i;                        // Write enable input
	output        wb_inta_o;                      // interrupt request signal

	// ATA signals
	output        resetn_pad_o;
	input  [15:0] dd_pad_i;
	output [15:0] dd_pad_o;
	output        dd_padoe_o;
	output [ 2:0] da_pad_o;
	output        cs0n_pad_o;
	output        cs1n_pad_o;

	output        diorn_pad_o;
	output        diown_pad_o;
	input         iordy_pad_i;
	input         intrq_pad_i;

	//
	// constant declarations
	//
	parameter [3:0] DeviceId = 4'h1;
	parameter [3:0] RevisionNo = 4'h0;

	//
	// Variable declarations
	//

	// registers
	wire        IDEctrl_IDEen, IDEctrl_rst;
	wire [ 7:0] PIO_cmdport_T1, PIO_cmdport_T2, PIO_cmdport_T4, PIO_cmdport_Teoc;
	wire        PIO_cmdport_IORDYen;

	wire        PIOack;
	wire [15:0] PIOq;

	wire irq; // ATA bus IRQ signal


	/////////////////
	// Module body //
	/////////////////

	// generate asynchronous reset level
	// arst_signal is either a wire or a NOT-gate
	wire arst_signal = arst_i ^ ARST_LVL;

	//
	// hookup wishbone slave
	//
	atahost_wb_slave #(DeviceId, RevisionNo, PIO_mode0_T1, 
			PIO_mode0_T2, PIO_mode0_T4, PIO_mode0_Teoc, 0, 0, 0)
	u0 (
		// WISHBONE SYSCON signals
		.clk_i(wb_clk_i),
		.arst_i(arst_signal),
		.rst_i(wb_rst_i),

		// WISHBONE SLAVE signals
		.cyc_i(wb_cyc_i),
		.stb_i(wb_stb_i),
		.ack_o(wb_ack_o),
		.rty_o(),
		.err_o(wb_err_o),
		.adr_i(wb_adr_i),
		.dat_i(wb_dat_i),
		.dat_o(wb_dat_o),
		.sel_i(wb_sel_i),
		.we_i(wb_we_i),
		.inta_o(wb_inta_o),

		// PIO control inputs
		.PIOsel(PIOsel),
			//	PIOtip is only asserted during a PIO transfer (No shit! ;)
			//	Since it is impossible to read the status register and access the PIO registers at the same time
			//	this bit is useless (besides using-up resources)
		.PIOtip(1'b0),
		.PIOack(PIOack),
		.PIOq(PIOq),
		.PIOpp_full(1'b0), // OCIDEC-1 does not support PIO-write pingpong, negate signal
		.irq(irq),

		// DMA control inputs (negate all of them, OCIDEC-1 does not support DMA)
		.DMAsel(),
		.DMAtip(1'b0),
		.DMAack(1'b0),
		.DMARxEmpty(1'b0),
		.DMATxFull(1'b0),
		.DMA_dmarq(1'b0),
		.DMAq(32'h0),

		// outputs
		// control register outputs
		.IDEctrl_rst(IDEctrl_rst),
		.IDEctrl_IDEen(IDEctrl_IDEen),
		.IDEctrl_FATR0(),
		.IDEctrl_FATR1(),
		.IDEctrl_ppen(),

		.DMActrl_DMAen(),
		.DMActrl_dir(),
		.DMActrl_BeLeC0(),
		.DMActrl_BeLeC1(),

		// CMD port timing registers
		.PIO_cmdport_T1(PIO_cmdport_T1),
		.PIO_cmdport_T2(PIO_cmdport_T2),
		.PIO_cmdport_T4(PIO_cmdport_T4),
		.PIO_cmdport_Teoc(PIO_cmdport_Teoc),
		.PIO_cmdport_IORDYen(PIO_cmdport_IORDYen),

		// data-port0 timing registers
		.PIO_dport0_T1(),
		.PIO_dport0_T2(),
		.PIO_dport0_T4(),
		.PIO_dport0_Teoc(),
		.PIO_dport0_IORDYen(),

		// data-port1 timing registers
		.PIO_dport1_T1(),
		.PIO_dport1_T2(),
		.PIO_dport1_T4(),
		.PIO_dport1_Teoc(),
		.PIO_dport1_IORDYen(),

		// DMA device0 timing registers
		.DMA_dev0_Tm(),
		.DMA_dev0_Td(),
		.DMA_dev0_Teoc(),

		// DMA device1 timing registers
		.DMA_dev1_Tm(),
		.DMA_dev1_Td(),
		.DMA_dev1_Teoc()
	);


	//
	// hookup controller section
	//
	atahost_controller #(TWIDTH, PIO_mode0_T1, PIO_mode0_T2, PIO_mode0_T4, PIO_mode0_Teoc)
		u1 (
			.clk(wb_clk_i),
			.nReset(arst_signal),
			.rst(wb_rst_i),
			.irq(irq),
			.IDEctrl_rst(IDEctrl_rst),
			.IDEctrl_IDEen(IDEctrl_IDEen),
			.PIO_cmdport_T1(PIO_cmdport_T1),
			.PIO_cmdport_T2(PIO_cmdport_T2),
			.PIO_cmdport_T4(PIO_cmdport_T4),
			.PIO_cmdport_Teoc(PIO_cmdport_Teoc),
			.PIO_cmdport_IORDYen(PIO_cmdport_IORDYen),
			.PIOreq(PIOsel),
			.PIOack(PIOack),
			.PIOa(wb_adr_i[5:2]),
			.PIOd(wb_dat_i[15:0]),
			.PIOq(PIOq),
			.PIOwe(wb_we_i),
			.RESETn(resetn_pad_o),
			.DDi(dd_pad_i),
			.DDo(dd_pad_o),
			.DDoe(dd_padoe_o),
			.DA(da_pad_o),
			.CS0n(cs0n_pad_o),
			.CS1n(cs1n_pad_o),
			.DIORn(diorn_pad_o),
			.DIOWn(diown_pad_o),
			.IORDY(iordy_pad_i),
			.INTRQ(intrq_pad_i)
		);

endmodule
