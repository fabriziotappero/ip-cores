//**************************************************************
// Module             : virtual_jtag_adda_fifo.v
// Platform           : Windows xp sp2
// Simulator          : Modelsim 6.5b
// Synthesizer        : QuartusII 10.1 sp1
// Place and Route    : QuartusII 10.1 sp1
// Targets device     : Cyclone III
// Author             : Bibo Yang  (ash_riple@hotmail.com)
// Organization       : www.opencores.org
// Revision           : 2.2 
// Date               : 2012/03/28
// Description        : addr/data capture output to debug host
//                      via Virtual JTAG.
//**************************************************************

`include "jtag_sim_define.h"
`timescale 1ns/1ns

module virtual_jtag_adda_fifo(clk,wr_in,data_in,rd_in);

parameter data_width  = 32,
          fifo_depth  = 256,
          addr_width  = 8,
          al_full_val = 255,
          al_empt_val = 0;

input clk;
input wr_in, rd_in;
input [data_width-1:0] data_in;

wire tdi, tck, cdr, cir, e1dr, e2dr, pdr, sdr, udr, uir;
reg  tdo;
reg  [addr_width-1:0] usedw_instr_reg;
reg  reset_instr_reg;
reg  [data_width-1:0] read_instr_reg;
reg  bypass_reg;

wire [1:0] ir_in;
wire usedw_instr  = ~ir_in[1] &  ir_in[0]; // 1
wire reset_instr  =  ir_in[1] & ~ir_in[0]; // 2
wire read_instr   =  ir_in[1] &  ir_in[0]; // 3

wire reset = reset_instr && e1dr;

wire [addr_width-1:0] usedw;
wire [data_width-1:0] data_out;
wire full;
wire al_full;

reg read_instr_d1;
reg read_instr_d2;
reg read_instr_d3;
wire rd_en = rd_in | (read_instr_d2 & !read_instr_d3);
wire wr_en = wr_in;
always @(posedge clk or posedge reset)
begin
  if (reset)
  begin
    read_instr_d1 <= 1'b0;
    read_instr_d2 <= 1'b0;
    read_instr_d3 <= 1'b0;
  end
  else
  begin
    read_instr_d1 <= read_instr;
    read_instr_d2 <= read_instr_d1;
    read_instr_d3 <= read_instr_d2;
  end
end

scfifo  jtag_fifo (
        .aclr (reset),
        .clock (clk),
        .wrreq (wr_en & !al_full),
        .data (data_in),
        .rdreq (rd_en),
        .q (data_out),
        .full (full),
        .almost_full (al_full),
        .empty (),
        .almost_empty (),
        .usedw (usedw),
        .sclr ());
    defparam
        jtag_fifo.lpm_width = data_width,
        jtag_fifo.lpm_numwords = fifo_depth,
        jtag_fifo.lpm_widthu = addr_width,
        jtag_fifo.intended_device_family = "Cyclone III",
        jtag_fifo.almost_full_value = al_full_val,
        jtag_fifo.almost_empty_value = al_empt_val,
        jtag_fifo.lpm_type = "scfifo",
        jtag_fifo.lpm_showahead = "OFF",
        jtag_fifo.overflow_checking = "ON",
        jtag_fifo.underflow_checking = "ON",
        jtag_fifo.use_eab = "ON",
        jtag_fifo.add_ram_output_register = "ON";

 
/* usedw_instr Instruction Handler */		
always @ (posedge tck)
  if ( usedw_instr && cdr )
    usedw_instr_reg <= usedw;
  else if ( usedw_instr && sdr )
    usedw_instr_reg <= {tdi, usedw_instr_reg[addr_width-1:1]};

/* reset_instr Instruction Handler */
always @ (posedge tck)
  if ( reset_instr && sdr )
    reset_instr_reg <= tdi;//{tdi, reset_instr_reg[data_width-1:1]};

/* read_instr Instruction Handler */		
always @ (posedge tck)
  if ( read_instr && cdr )
    read_instr_reg <= data_out;
  else if ( read_instr && sdr )
    read_instr_reg <= {tdi, read_instr_reg[data_width-1:1]};

/* Bypass register */
always @ (posedge tck)
  bypass_reg = tdi;

/* Node TDO Output */
always @ ( usedw_instr, reset_instr, read_instr, usedw_instr_reg[0], reset_instr_reg/*[0]*/, read_instr_reg[0], bypass_reg )
begin
  if (usedw_instr)
    tdo <= usedw_instr_reg[0];
  else if (reset_instr)
    tdo <= reset_instr_reg/*[0]*/;
  else if (read_instr)
    tdo <= read_instr_reg[0];
  else
    tdo <= bypass_reg;		// Used to maintain the continuity of the scan chain.
end

sld_virtual_jtag	sld_virtual_jtag_component (
				.ir_in (ir_in),
				.ir_out (2'b0),
				.tdo (tdo),
				.tdi (tdi),
				.tms (),
				.tck (tck),
				.virtual_state_cir (cir),
				.virtual_state_pdr (pdr),
				.virtual_state_uir (uir),
				.virtual_state_sdr (sdr),
				.virtual_state_cdr (cdr),
				.virtual_state_udr (udr),
				.virtual_state_e1dr (e1dr),
				.virtual_state_e2dr (e2dr),
				.jtag_state_rti (),
				.jtag_state_e1dr (),
				.jtag_state_e2dr (),
				.jtag_state_pir (),
				.jtag_state_tlr (),
				.jtag_state_sir (),
				.jtag_state_cir (),
				.jtag_state_uir (),
				.jtag_state_pdr (),
				.jtag_state_sdrs (),
				.jtag_state_sdr (),
				.jtag_state_cdr (),
				.jtag_state_udr (),
				.jtag_state_sirs (),
				.jtag_state_e1ir (),
				.jtag_state_e2ir ());
	defparam
		sld_virtual_jtag_component.sld_auto_instance_index = "NO",
		sld_virtual_jtag_component.sld_instance_index = 0,
		sld_virtual_jtag_component.sld_ir_width = 2,
		`ifdef USE_SIM_STIMULUS
		sld_virtual_jtag_component.sld_sim_action       = `FIFO_SLD_SIM_ACTION,
		sld_virtual_jtag_component.sld_sim_n_scan       = `FIFO_SLD_SIM_N_SCAN,
		sld_virtual_jtag_component.sld_sim_total_length = `FIFO_SLD_SIM_T_LENG;
		`else
		sld_virtual_jtag_component.sld_sim_action       = "((1,1,1,2))",
		sld_virtual_jtag_component.sld_sim_n_scan       = 1,
		sld_virtual_jtag_component.sld_sim_total_length = 2;
		`endif
		
endmodule
