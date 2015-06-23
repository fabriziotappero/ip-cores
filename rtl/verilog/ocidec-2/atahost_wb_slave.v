/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OCIDEC-1 ATA/ATAPI-5 Controller                            ////
////  Wishbone Slave interface (common for all OCIDEC cores)     ////
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
//  $Id: atahost_wb_slave.v,v 1.1 2002-02-18 14:26:46 rherveille Exp $
//
//  $Date: 2002-02-18 14:26:46 $
//  $Revision: 1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//

`include "timescale.v"

module atahost_wb_slave (
		clk_i, arst_i, rst_i, cyc_i, stb_i, ack_o, rty_o, err_o, adr_i,	dat_i, dat_o, sel_i, we_i, inta_o,
		PIOsel, PIOtip, PIOack, PIOq, PIOpp_full, irq,
		DMAsel, DMAtip, DMAack, DMARxEmpty, DMATxFull, DMA_dmarq, DMAq,
		IDEctrl_rst, IDEctrl_IDEen, IDEctrl_FATR1, IDEctrl_FATR0, IDEctrl_ppen,
		DMActrl_DMAen, DMActrl_dir, DMActrl_BeLeC0, DMActrl_BeLeC1,
		PIO_cmdport_T1, PIO_cmdport_T2, PIO_cmdport_T4, PIO_cmdport_Teoc, PIO_cmdport_IORDYen,
		PIO_dport0_T1, PIO_dport0_T2, PIO_dport0_T4, PIO_dport0_Teoc, PIO_dport0_IORDYen,
		PIO_dport1_T1, PIO_dport1_T2, PIO_dport1_T4, PIO_dport1_Teoc, PIO_dport1_IORDYen,
		DMA_dev0_Tm, DMA_dev0_Td, DMA_dev0_Teoc, DMA_dev1_Tm, DMA_dev1_Td, DMA_dev1_Teoc
	);

	//
	// Parameters
	//
	parameter DeviceId   = 4'h0;
	parameter RevisionNo = 4'h0;

	// PIO mode 0 settings (@100MHz clock)
	parameter PIO_mode0_T1   =  6;                // 70ns
	parameter PIO_mode0_T2   = 28;                // 290ns
	parameter PIO_mode0_T4   =  2;                // 30ns
	parameter PIO_mode0_Teoc = 23;                // 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240

	// Multiword DMA mode 0 settings (@100MHz clock)
	parameter DMA_mode0_Tm   =  6;                // 50ns
	parameter DMA_mode0_Td   = 21;                // 215ns
	parameter DMA_mode0_Teoc = 21;                // 215ns ==> T0 - Td - Tm = 480 - 50 - 215 = 215

	//
	// inputs & outputs
	//
	
	// WISHBONE SYSCON signals
	input clk_i;                                // master clock in
	input arst_i;                               // asynchronous active low reset
	input rst_i;                                // synchronous active high reset

	// WISHBONE SLAVE signals
	input       cyc_i;                          // valid bus cycle input
	input       stb_i;                          // strobe/core select input
	output      ack_o;                          // strobe acknowledge output
	output      rty_o;                          // retry output
	output      err_o;                          // error output
	input [6:2] adr_i;                          // A6 = '1' ATA devices selected
	                                            //          A5 = '1' CS1- asserted, '0' CS0- asserted
	                                            //          A4..A2 ATA address lines
	                                            // A6 = '0' ATA controller selected
	input  [31:0] dat_i;                        // Databus in
	output [31:0] dat_o;                        // Databus out
	input  [ 3:0] sel_i;                        // Byte select signals
	input         we_i;                         // Write enable input
	output        inta_o;                       // interrupt request signal IDE0

	// PIO control input
	output        PIOsel;
	input         PIOtip;                       // PIO transfer in progress
	input         PIOack;                       // PIO acknowledge signal
	input  [15:0] PIOq;                         // PIO data input
	input         PIOpp_full;                   // PIO write-ping-pong buffers full
	input         irq;                          // interrupt signal input

	// DMA control inputs
	output       DMAsel;
	input        DMAtip;                        // DMA transfer in progress
	input        DMAack;                        // DMA transfer acknowledge
	input        DMARxEmpty;                    // DMA receive buffer empty
	input        DMATxFull;                     // DMA transmit buffer full
	input        DMA_dmarq;                     // wishbone DMA request
	input [31:0] DMAq;

	// outputs
	// control register outputs
	output IDEctrl_rst;
	output IDEctrl_IDEen;
	output IDEctrl_FATR1;
	output IDEctrl_FATR0;
	output IDEctrl_ppen;
	output DMActrl_DMAen;
	output DMActrl_dir;
	output DMActrl_BeLeC0;
	output DMActrl_BeLeC1;

	// CMD port timing registers
	output [7:0] PIO_cmdport_T1,
	             PIO_cmdport_T2,
	             PIO_cmdport_T4,
	             PIO_cmdport_Teoc;
	output       PIO_cmdport_IORDYen;

	reg [7:0] PIO_cmdport_T1,
	          PIO_cmdport_T2,
	          PIO_cmdport_T4,
	          PIO_cmdport_Teoc;

	// data-port0 timing registers
	output [7:0] PIO_dport0_T1,
	             PIO_dport0_T2,
	             PIO_dport0_T4,
	             PIO_dport0_Teoc;
	output       PIO_dport0_IORDYen;

	reg [7:0] PIO_dport0_T1,
	          PIO_dport0_T2,
	          PIO_dport0_T4,
	          PIO_dport0_Teoc;

	// data-port1 timing registers
	output [7:0] PIO_dport1_T1,
	             PIO_dport1_T2,
	             PIO_dport1_T4,
	             PIO_dport1_Teoc;
	output       PIO_dport1_IORDYen;

	reg [7:0] PIO_dport1_T1,
	          PIO_dport1_T2,
	          PIO_dport1_T4,
	          PIO_dport1_Teoc;

	// DMA device0 timing registers
	output [7:0] DMA_dev0_Tm,
	             DMA_dev0_Td,
	             DMA_dev0_Teoc;

	reg [7:0] DMA_dev0_Tm,
	          DMA_dev0_Td,
	          DMA_dev0_Teoc;

	// DMA device1 timing registers
	output [7:0] DMA_dev1_Tm,
	             DMA_dev1_Td,
	             DMA_dev1_Teoc;

	reg [7:0] DMA_dev1_Tm,
	          DMA_dev1_Td,
	          DMA_dev1_Teoc;


	//
	// constants
	//

	// addresses
	`define ATA_DEV_ADR adr_i[6]
	`define ATA_ADR     adr_i[5:2]

	`define ATA_CTRL_REG 4'b0000
	`define ATA_STAT_REG 4'b0001
	`define ATA_PIO_CMD  4'b0010
	`define ATA_PIO_DP0  4'b0011
	`define ATA_PIO_DP1  4'b0100
	`define ATA_DMA_DEV0 4'b0101
	`define ATA_DMA_DEV1 4'b0110
	// reserved //
	`define ATA_DMA_PORT 4'b1111


	//
	// signals
	//

	// registers
	reg  [31:0] CtrlReg; // control register
	wire [31:0] StatReg; // status register

	// store ping-pong-full signal
	reg store_pp_full;


	//
	// generate bus cycle / address decoder
	//
	wire w_acc  = &sel_i[1:0];                        // word access
	wire dw_acc = &sel_i;                             // double word access

	// bus error
	wire berr = `ATA_DEV_ADR ? !w_acc : !dw_acc;

	// PIO accesses at least 16bit wide, no PIO access during DMAtip or pingpong-full
	wire PIOsel = cyc_i & stb_i & `ATA_DEV_ADR & w_acc & !(DMAtip | store_pp_full);

	// CON accesses only 32bit wide
	wire CONsel = cyc_i & stb_i & !(`ATA_DEV_ADR) & dw_acc;
	wire DMAsel = CONsel & (`ATA_ADR == `ATA_DMA_PORT);

	// bus retry (OCIDEC-3 and above)
	// store PIOpp_full, we don't want a PPfull based retry initiated by the current bus-cycle
	always@(posedge clk_i)
		if (!PIOsel)
			store_pp_full <= #1 PIOpp_full;

	wire brty = (`ATA_DEV_ADR & w_acc) & (DMAtip | store_pp_full);

	//
	// generate registers
	//

	// generate register select signals
	wire sel_ctrl        = CONsel & we_i & (`ATA_ADR == `ATA_CTRL_REG);
	wire sel_stat        = CONsel & we_i & (`ATA_ADR == `ATA_STAT_REG);
	wire sel_PIO_cmdport = CONsel & we_i & (`ATA_ADR == `ATA_PIO_CMD);
	wire sel_PIO_dport0  = CONsel & we_i & (`ATA_ADR == `ATA_PIO_DP0);
	wire sel_PIO_dport1  = CONsel & we_i & (`ATA_ADR == `ATA_PIO_DP1);
	wire sel_DMA_dev0    = CONsel & we_i & (`ATA_ADR == `ATA_DMA_DEV0);
	wire sel_DMA_dev1    = CONsel & we_i & (`ATA_ADR == `ATA_DMA_DEV1);
	// reserved 0x1c-0x38
	// reserved 0x3c : DMA-port


	// generate control register
	always@(posedge clk_i or negedge arst_i)
		if (~arst_i)
			begin
				CtrlReg[31:1] <= #1 0;
				CtrlReg[0]    <= #1 1'b1; // set reset bit (ATA-RESETn line)
			end
		else if (rst_i)
			begin
				CtrlReg[31:1] <= #1 0;
				CtrlReg[0]    <= #1 1'b1; // set reset bit (ATA-RESETn line)
			end
		else if (sel_ctrl)
			CtrlReg <= #1 dat_i;

	// assign bits
	assign DMActrl_DMAen        = CtrlReg[15];
	assign DMActrl_dir          = CtrlReg[13];
	assign DMActrl_BeLeC1       = CtrlReg[9];
	assign DMActrl_BeLeC0       = CtrlReg[8];
	assign IDEctrl_IDEen        = CtrlReg[7];
	assign IDEctrl_FATR1        = CtrlReg[6];
	assign IDEctrl_FATR0        = CtrlReg[5];
	assign IDEctrl_ppen         = CtrlReg[4];
	assign PIO_dport1_IORDYen   = CtrlReg[3];
	assign PIO_dport0_IORDYen   = CtrlReg[2];
	assign PIO_cmdport_IORDYen  = CtrlReg[1];
	assign IDEctrl_rst          = CtrlReg[0];


	// generate status register clearable bits
	reg dirq, int;
	
	always@(posedge clk_i or negedge arst_i)
		if (~arst_i)
			begin
				int  <= #1 1'b0;
				dirq <= #1 1'b0;
			end
		else if (rst_i)
			begin
				int  <= #1 1'b0;
				dirq <= #1 1'b0;
			end
		else
			begin
				int  <= #1 (int | (irq & !dirq)) & !(sel_stat & !dat_i[0]);
				dirq <= #1 irq;
			end

	// assign status bits
	assign StatReg[31:28] = DeviceId;   // set Device ID
	assign StatReg[27:24] = RevisionNo; // set revision number
	assign StatReg[23:16] = 0;          // reserved
	assign StatReg[15]    = DMAtip;
	assign StatReg[14:11] = 0;
	assign StatReg[10]    = DMARxEmpty;
	assign StatReg[9]     = DMATxFull;
	assign StatReg[8]     = DMA_dmarq;
	assign StatReg[7]     = PIOtip;
	assign StatReg[6]     = PIOpp_full;
	assign StatReg[5:1]   = 0;          // reserved
	assign StatReg[0]     = int;


	// generate PIO compatible / command-port timing register
	always@(posedge clk_i or negedge arst_i)
		if (~arst_i)
			begin
				PIO_cmdport_T1   <= #1 PIO_mode0_T1;
				PIO_cmdport_T2   <= #1 PIO_mode0_T2;
				PIO_cmdport_T4   <= #1 PIO_mode0_T4;
				PIO_cmdport_Teoc <= #1 PIO_mode0_Teoc;
			end
		else if (rst_i)
			begin
				PIO_cmdport_T1   <= #1 PIO_mode0_T1;
				PIO_cmdport_T2   <= #1 PIO_mode0_T2;
				PIO_cmdport_T4   <= #1 PIO_mode0_T4;
				PIO_cmdport_Teoc <= #1 PIO_mode0_Teoc;
			end
		else if(sel_PIO_cmdport)
			begin
				PIO_cmdport_T1   <= #1 dat_i[ 7: 0];
				PIO_cmdport_T2   <= #1 dat_i[15: 8];
				PIO_cmdport_T4   <= #1 dat_i[23:16];
				PIO_cmdport_Teoc <= #1 dat_i[31:24];
			end

	// generate PIO device0 timing register
	always@(posedge clk_i or negedge arst_i)
		if (~arst_i)
			begin
				PIO_dport0_T1   <= #1 PIO_mode0_T1;
				PIO_dport0_T2   <= #1 PIO_mode0_T2;
				PIO_dport0_T4   <= #1 PIO_mode0_T4;
				PIO_dport0_Teoc <= #1 PIO_mode0_Teoc;
			end
		else if (rst_i)
			begin
				PIO_dport0_T1   <= #1 PIO_mode0_T1;
				PIO_dport0_T2   <= #1 PIO_mode0_T2;
				PIO_dport0_T4   <= #1 PIO_mode0_T4;
				PIO_dport0_Teoc <= #1 PIO_mode0_Teoc;
			end
		else if(sel_PIO_dport0)
			begin
				PIO_dport0_T1   <= #1 dat_i[ 7: 0];
				PIO_dport0_T2   <= #1 dat_i[15: 8];
				PIO_dport0_T4   <= #1 dat_i[23:16];
				PIO_dport0_Teoc <= #1 dat_i[31:24];
			end

	// generate PIO device1 timing register
	always@(posedge clk_i or negedge arst_i)
		if (~arst_i)
			begin
				PIO_dport1_T1   <= #1 PIO_mode0_T1;
				PIO_dport1_T2   <= #1 PIO_mode0_T2;
				PIO_dport1_T4   <= #1 PIO_mode0_T4;
				PIO_dport1_Teoc <= #1 PIO_mode0_Teoc;
			end
		else if (rst_i)
			begin
				PIO_dport1_T1   <= #1 PIO_mode0_T1;
				PIO_dport1_T2   <= #1 PIO_mode0_T2;
				PIO_dport1_T4   <= #1 PIO_mode0_T4;
				PIO_dport1_Teoc <= #1 PIO_mode0_Teoc;
			end
		else if(sel_PIO_dport1)
			begin
				PIO_dport1_T1   <= #1 dat_i[ 7: 0];
				PIO_dport1_T2   <= #1 dat_i[15: 8];
				PIO_dport1_T4   <= #1 dat_i[23:16];
				PIO_dport1_Teoc <= #1 dat_i[31:24];
			end

	// generate DMA device0 timing register
	always@(posedge clk_i or negedge arst_i)
		if (~arst_i)
			begin
				DMA_dev0_Tm   <= #1 DMA_mode0_Tm;
				DMA_dev0_Td   <= #1 DMA_mode0_Td;
				DMA_dev0_Teoc <= #1 DMA_mode0_Teoc;
			end
		else if (rst_i)
			begin
				DMA_dev0_Tm   <= #1 DMA_mode0_Tm;
				DMA_dev0_Td   <= #1 DMA_mode0_Td;
				DMA_dev0_Teoc <= #1 DMA_mode0_Teoc;
			end
		else if(sel_DMA_dev0)
			begin
				DMA_dev0_Tm   <= #1 dat_i[ 7: 0];
				DMA_dev0_Td   <= #1 dat_i[15: 8];
				DMA_dev0_Teoc <= #1 dat_i[31:24];
			end

	// generate DMA device1 timing register
	always@(posedge clk_i or negedge arst_i)
		if (~arst_i)
			begin
				DMA_dev1_Tm   <= #1 DMA_mode0_Tm;
				DMA_dev1_Td   <= #1 DMA_mode0_Td;
				DMA_dev1_Teoc <= #1 DMA_mode0_Teoc;
			end
		else if (rst_i)
			begin
				DMA_dev1_Tm   <= #1 DMA_mode0_Tm;
				DMA_dev1_Td   <= #1 DMA_mode0_Td;
				DMA_dev1_Teoc <= #1 DMA_mode0_Teoc;
			end
		else if(sel_DMA_dev1)
			begin
				DMA_dev1_Tm   <= #1 dat_i[ 7: 0];
				DMA_dev1_Td   <= #1 dat_i[15: 8];
				DMA_dev1_Teoc <= #1 dat_i[31:24];
			end

	//
	// generate WISHBONE interconnect signals
	//
	reg [31:0] Q;

	// generate acknowledge signal
	assign ack_o = PIOack | CONsel; // | DMAack; // since DMAack is derived from CONsel this is OK

	// generate error signal
	assign err_o = cyc_i & stb_i & berr;

	// generate retry signal (for OCIDEC-3 and above only)
	assign rty_o = cyc_i & stb_i & brty;

	// generate interrupt signal
	assign inta_o = StatReg[0];
	
	// generate output multiplexor
	always@(`ATA_ADR or CtrlReg or StatReg or 
			PIO_cmdport_T1 or PIO_cmdport_T2 or PIO_cmdport_T4 or PIO_cmdport_Teoc or
			PIO_dport0_T1 or PIO_dport0_T2 or PIO_dport0_T4 or PIO_dport0_Teoc or
			PIO_dport1_T1 or PIO_dport1_T2 or PIO_dport1_T4 or PIO_dport1_Teoc or
			DMA_dev0_Tm or DMA_dev0_Td or DMA_dev0_Teoc or
			DMA_dev1_Tm or DMA_dev1_Td or DMA_dev1_Teoc or
			DMAq
		)
		case (`ATA_ADR) // synopsis full_case parallel_case
			`ATA_CTRL_REG: Q = CtrlReg;
			`ATA_STAT_REG: Q = StatReg;
			`ATA_PIO_CMD : Q = {PIO_cmdport_Teoc, PIO_cmdport_T4, PIO_cmdport_T2, PIO_cmdport_T1};
			`ATA_PIO_DP0 : Q = {PIO_dport0_Teoc, PIO_dport0_T4, PIO_dport0_T2, PIO_dport0_T1};
			`ATA_PIO_DP1 : Q = {PIO_dport1_Teoc, PIO_dport1_T4, PIO_dport1_T2, PIO_dport1_T1};
			`ATA_DMA_DEV0: Q = {DMA_dev0_Teoc, 8'h0, DMA_dev0_Td, DMA_dev0_Tm};
			`ATA_DMA_DEV1: Q = {DMA_dev1_Teoc, 8'h0, DMA_dev1_Td, DMA_dev1_Tm};
			`ATA_DMA_PORT: Q = DMAq;
			default: Q = 0;
		endcase

	// assign DAT_O output
	assign dat_o = `ATA_DEV_ADR ? {16'h0, PIOq} : Q;

endmodule


