//**************************************************************
// Module             : up_monitor.v
// Platform           : Windows xp sp2, Ubuntu 10.04
// Simulator          : Modelsim 6.5b
// Synthesizer        : QuartusII 10.1 sp1, PlanAhead 14.2
// Place and Route    : QuartusII 10.1 sp1, PlanAhead 14.2
// Targets device     : Cyclone III, Zynq-7000
// Author             : Bibo Yang  (ash_riple@hotmail.com)
// Organization       : www.opencores.org
// Revision           : 2.3 
// Date               : 2012/11/19
// Description        : Top level: transaction record generation
//                      and glue logic to group together 
//                      the JTAG input and output modules.
//**************************************************************

`timescale 1ns/1ns
`include "vendor.h"

module up_monitor (
        `ifdef XILINX `ifdef AXI_IP
        icontrol0, icontrol1, icontrol2,
        `endif `endif
	clk,
	wr_en,rd_en,
	addr_in,
	data_in
);

input        clk;
input        wr_en,rd_en;
input [31:0] addr_in;
input [31:0] data_in;
/////////////////////////////////////////////////
// Registers and wires announcment
/////////////////////////////////////////////////

// for CPU bus signal buffer
reg         wr_en_d1,rd_en_d1;
reg  [31:0] addr_in_d1;
reg  [31:0] data_in_d1;
// for capture address mask
wire [35:0] addr_mask0,addr_mask1,addr_mask2 ,addr_mask3 ,addr_mask4 ,addr_mask5 ,addr_mask6 ,addr_mask7 ,  // inclusive
            addr_mask8,addr_mask9,addr_mask10,addr_mask11,addr_mask12,addr_mask13,addr_mask14,addr_mask15;  // exclusive
wire [15:0] addr_mask_en = {addr_mask15[32],addr_mask14[32],addr_mask13[32],addr_mask12[32],
                            addr_mask11[32],addr_mask10[32],addr_mask9 [32],addr_mask8 [32],
                            addr_mask7 [32],addr_mask6 [32],addr_mask5 [32],addr_mask4 [32],
                            addr_mask3 [32],addr_mask2 [32],addr_mask1 [32],addr_mask0 [32]};
wire        addr_wren = addr_mask15[35];
wire        addr_rden = addr_mask15[34];
reg         addr_mask_ok;
// for capture address+data trigger
wire [71:0] trig_cond;
wire        trig_aden = trig_cond[71];
wire        trig_daen = trig_cond[70];
wire        trig_wren = trig_cond[67];
wire        trig_rden = trig_cond[66];
wire        trig_en   = trig_cond[65];
wire        trig_set  = trig_cond[64];
wire [31:0] trig_addr = trig_cond[63:32];
wire [31:0] trig_data = trig_cond[31:0];
reg         trig_cond_ok,trig_cond_ok_d1;
// for capture storage
wire [97:0] capture_in;
wire        capture_wr;
// for pretrigger capture
wire [9:0] pretrig_num;
reg  [9:0] pretrig_cnt;
wire pretrig_full;
wire pretrig_wr;
reg  pretrig_wr_d1,pretrig_rd;
// for inter capture timer
reg [31:0] inter_cap_cnt;

/////////////////////////////////////////////////
// Capture logic main
/////////////////////////////////////////////////

// bus input pipeline, allowing back-to-back/continuous bus access
always @(posedge clk)
begin
	wr_en_d1   <= wr_en;
	rd_en_d1   <= rd_en;
	addr_in_d1 <= addr_in;
	data_in_d1 <= data_in;
end

// address range based capture enable
always @(posedge clk)
begin
	if (((addr_in[31:0]<=addr_mask0[31:0] && addr_in[31:0]>=addr_mask1[31:0] && addr_mask_en[ 0]) ||
	     (addr_in[31:0]<=addr_mask2[31:0] && addr_in[31:0]>=addr_mask3[31:0] && addr_mask_en[ 2]) ||
	     (addr_in[31:0]<=addr_mask4[31:0] && addr_in[31:0]>=addr_mask5[31:0] && addr_mask_en[ 4]) ||
	     (addr_in[31:0]<=addr_mask6[31:0] && addr_in[31:0]>=addr_mask7[31:0] && addr_mask_en[ 6])
	    ) //inclusive address range set with individual enable: addr_mask 0 - 7
	    &&
	    ((addr_in[31:0]>addr_mask8 [31:0] || addr_in[31:0]<addr_mask9 [31:0] || !addr_mask_en[ 8]) &&
	     (addr_in[31:0]>addr_mask10[31:0] || addr_in[31:0]<addr_mask11[31:0] || !addr_mask_en[10]) &&
	     (addr_in[31:0]>addr_mask12[31:0] || addr_in[31:0]<addr_mask13[31:0] || !addr_mask_en[12]) &&
	     (addr_in[31:0]>addr_mask14[31:0] || addr_in[31:0]<addr_mask15[31:0] || !addr_mask_en[14])
	    ) //exclusive address range set with individual enable: addr_mask 8 - 15
	)
		addr_mask_ok <= (addr_rden && rd_en) || (addr_wren && wr_en);
	else
		addr_mask_ok <= 0;
end

// address+data based capture trigger
always @(posedge clk)
begin
	if (trig_en==0) begin                      // trigger not enabled, trigger gate forced open
		trig_cond_ok    <= 1;
		trig_cond_ok_d1 <= 1;
	end
	else if (trig_set==0) begin                // trigger enabled and trigger stopped, trigger gate forced close
		trig_cond_ok    <= 0;
		trig_cond_ok_d1 <= 0;
	end
	else begin                                 // trigger enabled and trigger started, trigger gate conditional open
		if ((trig_aden? trig_addr[31:0]==addr_in[31:0]: 1) && (trig_daen? trig_data==data_in: 1) &&
		    (trig_wren? wr_en                         : 1) && (trig_rden? rd_en             : 1) &&
	    	    (rd_en || wr_en))
			trig_cond_ok <= 1;
		trig_cond_ok_d1 <= trig_cond_ok;
	end
	                                      // trigger gate kept open until trigger stoped
end
wire trig_cond_ok_pulse = trig_cond_ok & !trig_cond_ok_d1;

// generate capture wr_in
assign capture_in = {trig_cond_ok_pulse,wr_en_d1,inter_cap_cnt,addr_in_d1[31:0],data_in_d1[31:0]};
assign capture_wr =  trig_cond_ok_pulse || (addr_mask_ok && trig_cond_ok);

// generate pre-trigger wr_in
assign pretrig_full = (pretrig_cnt >= pretrig_num) || trig_cond_ok;
assign pretrig_wr = (!trig_en || (trig_en && !trig_set))? 1'b0 : (trig_cond_ok? 1'b0 : addr_mask_ok);
always @(posedge clk)
begin
	if      (!trig_en || (trig_en && !trig_set)) begin
		pretrig_cnt  <= 10'd0;
		pretrig_wr_d1<= 1'b0;
		pretrig_rd   <= 1'b0;
	end
	else if (!pretrig_full) begin
		pretrig_cnt  <=  pretrig_cnt + addr_mask_ok;
		pretrig_wr_d1<= 1'b0;
		pretrig_rd   <= 1'b0;
	end
	else if (pretrig_full) begin
		pretrig_cnt  <= pretrig_cnt;
		pretrig_wr_d1<= pretrig_wr;
		pretrig_rd   <= pretrig_wr_d1;
	end
end

// generate interval counter
always @(posedge clk)
begin
	if      (capture_wr || pretrig_wr)
		inter_cap_cnt <= 32'd0;
	else if (inter_cap_cnt[31])
		inter_cap_cnt <= 32'd3000000000;
	else
		inter_cap_cnt <= inter_cap_cnt + 32'd1;
end

/////////////////////////////////////////////////
// Instantiate vendor specific JTAG functions
/////////////////////////////////////////////////
`ifdef ALTERA
// index 0, instantiate capture fifo, as output
virtual_jtag_adda_fifo u_virtual_jtag_adda_fifo (
	.clk(clk),
	.wr_in(capture_wr || pretrig_wr),
	.data_in(capture_in),
	.rd_in(pretrig_rd)
	);
defparam
	u_virtual_jtag_adda_fifo.data_width	= 98,
	u_virtual_jtag_adda_fifo.fifo_depth	= 512,
	u_virtual_jtag_adda_fifo.addr_width	= 9,
	u_virtual_jtag_adda_fifo.al_full_val	= 511,
	u_virtual_jtag_adda_fifo.al_empt_val	= 0;

// index 1, instantiate capture mask, as input
virtual_jtag_addr_mask u_virtual_jtag_addr_mask (
	// inclusive
	.mask_out0(addr_mask0),
	.mask_out1(addr_mask1),
	.mask_out2(addr_mask2),
	.mask_out3(addr_mask3),
	.mask_out4(addr_mask4),
	.mask_out5(addr_mask5),
	.mask_out6(addr_mask6),
	.mask_out7(addr_mask7),
	// exclusive
	.mask_out8(addr_mask8),
	.mask_out9(addr_mask9),
	.mask_out10(addr_mask10),
	.mask_out11(addr_mask11),
	.mask_out12(addr_mask12),
	.mask_out13(addr_mask13),
	.mask_out14(addr_mask14),
	.mask_out15(addr_mask15)
	);
defparam
	u_virtual_jtag_addr_mask.mask_index	= 4,
	u_virtual_jtag_addr_mask.mask_enabl	= 4,
	u_virtual_jtag_addr_mask.addr_width	= 32;

// index 2, instantiate capture trigger, as input
virtual_jtag_adda_trig u_virtual_jtag_adda_trig (
	.trig_out(trig_cond),
	.pnum_out(pretrig_num)
	);
defparam
	u_virtual_jtag_adda_trig.trig_width	= 72,
	u_virtual_jtag_adda_trig.pnum_width	= 10;
`endif

`ifdef XILINX

`ifdef AXI_IP
// external ICON
inout [35:0] icontrol0, icontrol1, icontrol2;
`else
// internal ICON
wire [35:0] icontrol0, icontrol1, icontrol2;
`endif

// index 0, instantiate capture fifo, as output
chipscope_vio_adda_fifo u_chipscope_vio_adda_fifo (
	.wr_in(capture_wr || pretrig_wr),
	.data_in(capture_in),
	.rd_in(pretrig_rd),
	.clk(clk),
	.icon_ctrl(icontrol0)
	);
defparam
	u_chipscope_vio_adda_fifo.data_width	= 98,
	u_chipscope_vio_adda_fifo.addr_width	= 10,
	u_chipscope_vio_adda_fifo.al_full_val	= 511;

// index 1, instantiate capture mask, as input
chipscope_vio_addr_mask u_chipscope_vio_addr_mask (
	// inclusive
	.mask_out0(addr_mask0),
	.mask_out1(addr_mask1),
	.mask_out2(addr_mask2),
	.mask_out3(addr_mask3),
	.mask_out4(addr_mask4),
	.mask_out5(addr_mask5),
	.mask_out6(addr_mask6),
	.mask_out7(addr_mask7),
	// exclusive
	.mask_out8(addr_mask8),
	.mask_out9(addr_mask9),
	.mask_out10(addr_mask10),
	.mask_out11(addr_mask11),
	.mask_out12(addr_mask12),
	.mask_out13(addr_mask13),
	.mask_out14(addr_mask14),
	.mask_out15(addr_mask15),
        .clk(clk),
	.icon_ctrl(icontrol1)
	);
defparam
	u_chipscope_vio_addr_mask.mask_index	= 4,
	u_chipscope_vio_addr_mask.mask_enabl	= 4,
	u_chipscope_vio_addr_mask.addr_width	= 32;

// index 2, instantiate capture trigger, as input
chipscope_vio_adda_trig u_chipscope_vio_adda_trig (
	.trig_out(trig_cond),
	.pnum_out(pretrig_num),
        .clk(clk),
	.icon_ctrl(icontrol2)
	);
defparam
	u_chipscope_vio_adda_trig.trig_width	= 72,
	u_chipscope_vio_adda_trig.pnum_width	= 10;

`ifdef AXI_IP
// external ICON
`else
// internal ICON
chipscope_icon u_chipscope_icon (
	.CONTROL0(icontrol0),
	.CONTROL1(icontrol1),
	.CONTROL2(icontrol2)
	);
`endif

`endif

endmodule
