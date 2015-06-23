/*********************************************************
 MODULE:		Top Level SDRAM Controller ASIC Design Block

 FILE NAME:	sdramctrl_rtl.v
 VERSION:	1.0
 DATE:		April 8nd, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the top level RTL code of SDRAM Controller ASIC verilog
 code. It will instantiate the following blocks in the ASIC:

 1)	Command Interface
 2)	Finite State Machine
 3)	Data Port

 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps
 
// TOP MODULE
module sdram_ctrl(
						// Inputs
						clk0,
						clk0_2x,
						reset,
						paddr,
						cmd,
						dm,
						datain,
						// Outputs
						cmdack,
						addr,
						cs,
						ras,
						cas,
						we,
						dqm,
						cke,
						ba,
						dataout,
						// Inouts
						dq
						);

// Parameter
`include        "parameter.v"


// Inputs
input clk0;
input clk0_2x;
input reset;
input [padd_size - 1 : 0]paddr;
input [cmd_size  - 1 : 0]cmd;
input [dqm_size  - 1 : 0]dm;
input [data_size - 1 : 0]datain;

// Outputs
output cmdack;
output [add_size - 1 : 0]addr;
output [cs_size  - 1 : 0]cs;
output ras;
output cas;
output we;
output [dqm_size - 1 : 0]dqm;
output cke;
output [ba_size - 1 : 0]ba;
output [data_size - 1 : 0]dataout;

// Inouts
inout [data_size - 1 : 0]dq;


// Signal Declarations
wire clk0;
wire clk0_2x;
wire reset;
wire [padd_size - 1 : 0]paddr;
wire [padd_size - 1 : 0]wpaddr;
wire [cmd_size - 1 : 0]cmd;
wire [dqm_size - 1 : 0]dm;
wire cmack;

wire cmdack;
wire [add_size - 1 : 0]addr;
wire [cs_size - 1 : 0]cs;
wire ras;
wire cas;
wire we;
wire cke;
wire [ba_size - 1 : 0]ba;

wire nop;
wire reada;
wire writea;
wire refresh;
wire preacharge;
wire load_mod;

wire oe;

wire [cas_size - 1 : 0]cas_lat;
wire [rc_size - 1 : 0]ras_cas;
wire [ref_dur_size - 1 : 0]ref_dur;
wire page_mod;
wire [burst_size - 1 : 0]bur_len;

wire ref_ack;
wire ref_req;
wire resetn;


wire [add_size - 1 : 0]wsadd;
wire [ba_size - 1 : 0]wba;
wire [cs_size - 1 : 0]wcs;
wire wcke;
wire wras;
wire wcas;
wire wwe;

// Assignment statments


/*----------------------------Sub Level Module Instantiation------------------------*/


command_if cmdif_0(// Input
						.reset(reset),
						.clk0(clk0),
						.paddr(paddr),
						.cmd(cmd),
						.cmack(cmack),
						.ref_ack(ref_ack),
						// Output
						.cmdack(cmdack),
						.caddr(wpaddr),
						.nop(nop),
						.reada(reada),
						.writea(writea),
						.refresh(refresh),
						.preacharge(preacharge),
						.load_mod(load_mod),
						.cas_lat(cas_lat),
						.ras_cas(ras_cas),
						.ref_dur(ref_dur),
						.page_mod(page_mod),
						.bur_len(bur_len),
						.ref_req(ref_req)
						);

fsm  fsm_0(// Input
				.reset(reset),
				.clk0(clk0),
				.nop(nop),
				.reada(reada),
				.writea(writea),
				.refresh(refresh),
				.preacharge(preacharge),
				.load_mod(load_mod),
				.caddr(wpaddr),
				.cas_lat(cas_lat),
				.ras_cas(ras_cas),
				.ref_dur(ref_dur),
				.page_mod(page_mod),
				.bur_len(bur_len),
				.ref_req(ref_req),
				// Output
				.sadd(wsadd),
				.cs(wcs),
				.ras(wras),
				.cas(wcas),
				.we(wwe),
				.cke(wcke),
				.ba(wba),
				.oe(oe),
				.ref_ack(ref_ack),
				.cmack(cmack)
				);


data_port data_0(	// Input
						.reset(reset),
						.clk0(clk0),
						.clk0_2x(clk0_2x),
						.dm(dm),
						.oe(oe),
						.datain(datain),
						.wsadd(wsadd),
						.wba(wba),
						.wcs(wcs),
						.wcke(wcke),
						.wras(wras),
						.wcas(wcas),
						.wwe(wwe),
						// Output
						.dqm(dqm),
						.dataout(dataout),
						.add(addr),
						.ba(ba),
						.cs(cs),
						.cke(cke),
						.ras(ras),
						.cas(cas),
						.we(we),
						// Inout
						.dq(dq)
						);

endmodule



