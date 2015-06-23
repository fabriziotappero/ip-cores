/*********************************************************
 MODULE:		Sub Level SDRAM Controller FSM Block

 FILE NAME:	fsm.v
 VERSION:	1.0
 DATE:		April 8nd, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of SDRAM Controller ASIC verilog
 code. It is the signal generator Finite State Machine for SDRAM Controller

 It will instantiate the following blocks in the ASIC:

 1)	Ras-to-CAS Delay counter
 2)	Refresh Acknowledge
 3)	Output Enbable generator
 4)	Command generator
 5)   Command detector


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps


module fsm(//Input
				reset,
				clk0,
				nop,
				reada,
				writea,
				refresh,
				preacharge,
				load_mod,
				caddr,
				cas_lat,
				ras_cas,
				ref_dur,
				page_mod,
				bur_len,
				ref_req,
				// Output
				sadd,
				cs,
				ras,
				cas,
				we,
				cke,
				ba,
				oe,
				ref_ack,
				cmack
				);


// Parameter
`include        "parameter.v"

// Input
input reset;
input clk0;
input nop;
input reada;
input writea;
input refresh;
input preacharge;
input load_mod;
input [padd_size - 1 : 0]caddr;
input [cas_size - 1 : 0]cas_lat;
input [rc_size - 1 : 0]ras_cas;
input [ref_dur_size - 1 : 0]ref_dur;
input page_mod;
input [burst_size - 1 : 0]bur_len;
input ref_req;

// Output
output [add_size - 1 : 0]sadd;
output [cs_size - 1 : 0]cs;
output ras;
output cas;
output we;
output cke;
output [ba_size - 1 : 0]ba;
output oe;
output ref_ack;
output cmack;

// Wires and Reg signals
wire                             oe;
wire                            	do_nop;
wire                             do_reada;
wire                             do_writea;
wire                             do_writea1;
wire                             do_refresh;
wire                             do_preacharge;
wire                             do_load_mod;

wire                             command_done;
wire     [7:0]                   command_delay;
wire                             do_act;
wire                             rw_flag;
wire     [3:0]                   rp_shift;
wire                             rp_done;

wire    [row_size - 1:0]        rowaddr;
wire    [col_size - 1:0]        coladdr;
wire    [bank_size - 1:0]       bankaddr;


wire reset;
wire clk0;
wire [rc_size - 1 : 0]ras_cas;
wire do_rw;

wire ref_req;
wire cmack;
wire ref_ack;


wire page_mod;

wire [burst_size - 1 : 0]bur_len;
wire [cas_size - 1 : 0]cas_lat;

wire oe4;


// Assignments
assign   rowaddr   = caddr[rowstart + row_size - 1 : rowstart];         // assignment of the row address bits from sadd
assign   coladdr   = caddr[colstart + col_size - 1 : colstart];        // assignment of the column address bits
assign   bankaddr  = caddr[bankstart + bank_size - 1 : bankstart];    // assignment of the bank address bits



/*********************************** Sub Level Instantiation *****************************/

ras_cas_delay ras_cas_delay0(	// Input
										.reset(reset),
										.clk0(clk0),
										.do_reada(do_reada),
										.do_writea(do_writea),
										.ras_cas(ras_cas),
										// Output
										.do_rw(do_rw)
										);


ref_ack	ref_ack0(// Input
						.reset(reset),
						.clk0(clk0),
						.do_refresh(do_refresh),
						.do_reada(do_reada),
						.do_writea(do_writea),
						.do_preacharge(do_preacharge),
						.do_load_mod(do_load_mod),
						.ref_req(ref_req),
						// Output
						.cmack(cmack),
						.ref_ack(ref_ack)
						);

oe_generator oe_gen0(// Input
							.reset(reset),
							.clk0(clk0),
							.page_mod(page_mod),
							.do_writea1(do_writea1),
							.bur_len(bur_len),
							.cas_lat(cas_lat),
							.do_preacharge(do_preacharge),
							.do_reada(do_reada),
							.do_refresh(do_refresh),
							// Output
							.oe(oe),
							.oe4(oe4)
							);

cmd_generator cmd_generator0(	// Input
										.reset(reset),
										.clk0(clk0),
										.do_reada(do_reada),
										.do_writea(do_writea),
										.do_preacharge(do_preacharge),
										.do_rw(do_rw),
										.rowaddr(rowaddr),
										.coladdr(coladdr),
										.bankaddr(bankaddr),
										.page_mod(page_mod),
										.do_load_mod(do_load_mod),
										.do_refresh(do_refresh),
										.caddr(caddr),
										.do_nop(do_nop),
										.rw_flag(rw_flag),
										.oe4(oe4),
										// Output
										.sadd(sadd),
										.ba(ba),
										.cs(cs),
										.ras(ras),
										.cas(cas),
										.we(we),
										.cke(cke)
										);


cmd_detector cmd_detector0(// Input
									.reset(reset),
									.clk0(clk0),
									.nop(nop),
									.ref_req(ref_req),
									.refresh(refresh),
									.reada(reada),
									.writea(writea),
									.preacharge(preacharge),
									.load_mod(load_mod),
									.ref_dur(ref_dur),
									// Output
									.do_nop(do_nop),
									.do_reada(do_reada),
									.do_writea(do_writea),
									.do_writea1(do_writea1),
									.do_refresh(do_refresh),
									.do_preacharge(do_preacharge),
									.do_load_mod(do_load_mod),
									.rw_flag(rw_flag)
									);


endmodule
