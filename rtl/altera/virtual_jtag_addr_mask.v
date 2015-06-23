//**************************************************************
// Module             : virtual_jtag_addr_mask.v
// Platform           : Windows xp sp2
// Simulator          : Modelsim 6.5b
// Synthesizer        : QuartusII 10.1 sp1
// Place and Route    : QuartusII 10.1 sp1
// Targets device     : Cyclone III
// Author             : Bibo Yang  (ash_riple@hotmail.com)
// Organization       : www.opencores.org
// Revision           : 2.2 
// Date               : 2012/03/28
// Description        : addr mask input from debug host via
//                      Virtual JTAG.
//**************************************************************

`include "jtag_sim_define.h"
`timescale 1ns/1ns

module virtual_jtag_addr_mask(mask_out0 ,mask_out1 ,mask_out2 ,mask_out3 ,
                              mask_out4 ,mask_out5 ,mask_out6 ,mask_out7 ,
                              mask_out8 ,mask_out9 ,mask_out10,mask_out11,
                              mask_out12,mask_out13,mask_out14,mask_out15
                             );

parameter mask_index  = 4, //2**mask_index=mask_num
          mask_enabl  = 4,
          addr_width  = 32;

output [mask_enabl+addr_width-1:0] mask_out0;
output [mask_enabl+addr_width-1:0] mask_out1;
output [mask_enabl+addr_width-1:0] mask_out2;
output [mask_enabl+addr_width-1:0] mask_out3;
output [mask_enabl+addr_width-1:0] mask_out4;
output [mask_enabl+addr_width-1:0] mask_out5;
output [mask_enabl+addr_width-1:0] mask_out6;
output [mask_enabl+addr_width-1:0] mask_out7;
output [mask_enabl+addr_width-1:0] mask_out8;
output [mask_enabl+addr_width-1:0] mask_out9;
output [mask_enabl+addr_width-1:0] mask_out10;
output [mask_enabl+addr_width-1:0] mask_out11;
output [mask_enabl+addr_width-1:0] mask_out12;
output [mask_enabl+addr_width-1:0] mask_out13;
output [mask_enabl+addr_width-1:0] mask_out14;
output [mask_enabl+addr_width-1:0] mask_out15;

reg [mask_enabl+addr_width-1:0] mask_out0;
reg [mask_enabl+addr_width-1:0] mask_out1;
reg [mask_enabl+addr_width-1:0] mask_out2;
reg [mask_enabl+addr_width-1:0] mask_out3;
reg [mask_enabl+addr_width-1:0] mask_out4;
reg [mask_enabl+addr_width-1:0] mask_out5;
reg [mask_enabl+addr_width-1:0] mask_out6;
reg [mask_enabl+addr_width-1:0] mask_out7;
reg [mask_enabl+addr_width-1:0] mask_out8;
reg [mask_enabl+addr_width-1:0] mask_out9;
reg [mask_enabl+addr_width-1:0] mask_out10;
reg [mask_enabl+addr_width-1:0] mask_out11;
reg [mask_enabl+addr_width-1:0] mask_out12;
reg [mask_enabl+addr_width-1:0] mask_out13;
reg [mask_enabl+addr_width-1:0] mask_out14;
reg [mask_enabl+addr_width-1:0] mask_out15;

wire tdi, tck, cdr, cir, e1dr, e2dr, pdr, sdr, udr, uir;
reg  tdo;
reg  [mask_index+mask_enabl+addr_width-1:0] mask_instr_reg;
reg  bypass_reg;

wire [1:0] ir_in;
wire mask_instr = ~ir_in[1] &  ir_in[0]; // 1

wire [mask_index-1           :0] mask_id = mask_instr_reg[(mask_index+mask_enabl+addr_width-1):(mask_enabl+addr_width)];
wire [mask_enabl+addr_width-1:0] mask_is = mask_instr_reg[                                     (mask_enabl+addr_width-1):0];

always @(posedge tck)
begin
  if (mask_instr && e1dr)
	case (mask_id)
		4'd0 :
			mask_out0 <= mask_is;
		4'd1 :
			mask_out1 <= mask_is;
		4'd2 :
			mask_out2 <= mask_is;
		4'd3 :
			mask_out3 <= mask_is;
		4'd4 :
			mask_out4 <= mask_is;
		4'd5 :
			mask_out5 <= mask_is;
		4'd6 :
			mask_out6 <= mask_is;
		4'd7 :
			mask_out7 <= mask_is;
		4'd8 :
			mask_out8 <= mask_is;
		4'd9 :
			mask_out9 <= mask_is;
		4'd10 :
			mask_out10 <= mask_is;
		4'd11 :
			mask_out11 <= mask_is;
		4'd12 :
			mask_out12 <= mask_is;
		4'd13 :
			mask_out13 <= mask_is;
		4'd14 :
			mask_out14 <= mask_is;
		4'd15 :
			mask_out15 <= mask_is;
	endcase
end

/* mask_instr Instruction Handler */		
always @ (posedge tck)
  if ( mask_instr && cdr )
    mask_instr_reg <= mask_instr_reg;
  else if ( mask_instr && sdr )
    mask_instr_reg <= {tdi, mask_instr_reg[mask_index+mask_enabl+addr_width-1:1]};

/* Bypass register */
always @ (posedge tck)
  bypass_reg = tdi;

/* Node TDO Output */
always @ ( mask_instr, mask_instr_reg, bypass_reg )
begin
  if (mask_instr)
    tdo <= mask_instr_reg[0];
  else
    tdo <= bypass_reg;// Used to maintain the continuity of the scan chain.
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
		sld_virtual_jtag_component.sld_instance_index = 1,
		sld_virtual_jtag_component.sld_ir_width = 2,
		`ifdef USE_SIM_STIMULUS
		sld_virtual_jtag_component.sld_sim_action       = `ADDR_SLD_SIM_ACTION,
		sld_virtual_jtag_component.sld_sim_n_scan       = `ADDR_SLD_SIM_N_SCAN,
		sld_virtual_jtag_component.sld_sim_total_length = `ADDR_SLD_SIM_T_LENG;
		`else
		sld_virtual_jtag_component.sld_sim_action       = "((1,1,1,2))",
		sld_virtual_jtag_component.sld_sim_n_scan       = 1,
		sld_virtual_jtag_component.sld_sim_total_length = 2;
		`endif
		
endmodule
