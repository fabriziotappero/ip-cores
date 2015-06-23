/*********************************************************
 MODULE:		Sub Level SDRAM Controller Command Interface

 FILE NAME:	command_if.v
 VERSION:	1.0
 DATE:		April 8nd, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It will decode the uProcessor command, its a command interface block.

 It will instantiate the following blocks in the ASIC:

 1)	Command Decoder
 2)	Internal Register
 3)   Command Acknowledge
 4)	Refresh Timer

 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps

module command_if (// Input
						reset,
						clk0,
						paddr,
						cmd,
						cmack,
						ref_ack,
						// Output
						cmdack,
						caddr,
						nop,
						reada,
						writea,
						refresh,
						preacharge,
						load_mod,
						cas_lat,
						ras_cas,
						ref_dur,
						page_mod,
						bur_len,
						ref_req
						);

// Parameter
`include        "parameter.v"

// Input
input reset;
input clk0;
input [padd_size - 1 : 0]paddr;
input [cmd_size  - 1 : 0]cmd;
input cmack;
input ref_ack;

// Output
output cmdack;
output [padd_size - 1 : 0]caddr;
output nop;
output reada;
output writea;
output refresh;
output preacharge;
output load_mod;
output [cas_size - 1 : 0]cas_lat;
output [rc_size - 1 : 0]ras_cas;
output [ref_dur_size - 1 : 0]ref_dur;
output page_mod;
output [burst_size - 1 : 0]bur_len;
output ref_req;

// Internal wire and reg signals


wire reset;
wire clk0;
wire [padd_size - 1 : 0]paddr;
wire [cmd_size  - 1 : 0]cmd;

wire nop;
wire reada;
wire writea;
wire refresh;
wire preacharge;
wire load_mod;
wire load_time;
wire load_rfcnt;
wire [padd_size - 1 : 0]caddr;

wire [cas_size - 1 : 0]cas_lat;
wire [rc_size - 1 : 0]ras_cas;
wire [ref_dur_size - 1 : 0]ref_dur;
wire page_mod;
wire [burst_size - 1 : 0]bur_len;
wire [15:0]refresh_count;

wire cmack;
wire cmdack;
wire ref_ack;
wire ref_req;

// Assignment


/************************************ Sub-Level Instantiation *****************************/

cmd_decoder cmd_decoder0(	// Input
									.reset(reset),
									.clk0(clk0),
									.paddr(paddr),
									.cmd(cmd),
									.cmdack(cmdack),
									// Output
									.nop(nop),
									.reada(reada),
									.writea(writea),
									.refresh(refresh),
									.preacharge(preacharge),
									.load_mod(load_mod),
									.load_time(load_time),
									.load_rfcnt(load_rfcnt),
									.caddr(caddr)
									);


internal_reg internal_reg0(	// Input
										.reset(reset),
										.clk0(clk0),
										.load_time(load_time),
										.load_rfcnt(load_rfcnt),
										.caddr(caddr),
										// Output
										.cas_lat(cas_lat),
										.ras_cas(ras_cas),
										.ref_dur(ref_dur),
										.page_mod(page_mod),
										.bur_len(bur_len),
										.refresh_count(refresh_count)
										);

cmd_ack	cmd_ack0(// Input
						.reset(reset),
						.clk0(clk0),
						.cmack(cmack),
						.load_time(load_time),
						.load_rfcnt(load_rfcnt),
						// Output
						.cmdack(cmdack)
						);


ref_timer	ref_timer0(// Input
								.reset(reset),
								.clk0(clk0),
								.refresh_count(refresh_count),
								.bur_len(bur_len),
								.ref_ack(ref_ack),
								// Output
								.ref_req(ref_req)
								);


endmodule
