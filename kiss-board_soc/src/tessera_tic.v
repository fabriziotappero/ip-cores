
`timescale 1ps/1ps

module tessera_tic (
	wb_rst,
	wb_clk,
	wb_cyc_o,
	wb_adr_o,
	wb_dat_i,
	wb_dat_o,
	wb_sel_o,
	wb_ack_i,
	wb_err_i,
	wb_rty_i,
	wb_we_o,
	wb_stb_o,
	wb_cab_o
);
	input		wb_rst;
	input		wb_clk;
	output		wb_cyc_o;
	output	[31:0]	wb_adr_o;
	input	[31:0]	wb_dat_i;
	output	[31:0]	wb_dat_o;
	output	[3:0]	wb_sel_o;
	input		wb_ack_i;
	input		wb_err_i;
	input		wb_rty_i;
	output		wb_we_o;
	output		wb_stb_o;
	output		wb_cab_o;
`ifdef SIM
	reg		r_wb_cyc_o;
	reg	[31:0]	r_wb_adr_o;
	reg	[31:0]	r_wb_dat_o;
	reg	[31:0]	r_wb_sel_o;
	reg		r_wb_we_o;
	reg		r_wb_stb_o;
	reg		r_wb_cab_o;
	initial begin
		r_wb_cyc_o = 1'b0;
		r_wb_adr_o = 32'h0000_0000;
		r_wb_dat_o = 32'h0000_0000;
		r_wb_sel_o = 4'b0000;
		r_wb_we_o  = 1'b0;
		r_wb_stb_o = 1'b0;
		r_wb_cab_o = 1'b0;
	end
`define MISC_OFFSET 1
	assign #(`MISC_OFFSET) wb_cyc_o = r_wb_cyc_o;
	assign #(`MISC_OFFSET) wb_adr_o = r_wb_adr_o;
	assign #(`MISC_OFFSET) wb_dat_o = r_wb_dat_o;
	assign #(`MISC_OFFSET) wb_sel_o = r_wb_sel_o;
	assign #(`MISC_OFFSET) wb_we_o  = r_wb_we_o;
	assign #(`MISC_OFFSET) wb_stb_o = r_wb_stb_o;
	assign #(`MISC_OFFSET) wb_cab_o = r_wb_cab_o;
	task task_wr_ext;
		input		cab;
		input	[31:0]	adr;
		input	[3:0]	sel;
		input	[31:0]	data;
	begin
		begin
			r_wb_cyc_o <= 1'b1;
			r_wb_adr_o <= adr;
			r_wb_dat_o <= data;
			r_wb_sel_o <= sel;
			r_wb_we_o  <= 1'b1;
			r_wb_stb_o <= 1'b1;
			r_wb_cab_o <= cab;
		end
		begin : label_detect_wr_ext_ack
			forever @(posedge wb_clk) if (wb_ack_i==1'b1) disable label_detect_wr_ext_ack;
		end
		begin
			r_wb_cyc_o <= 1'b0;
			r_wb_adr_o <= adr;
			r_wb_dat_o <= data;
			r_wb_sel_o <= sel;
			r_wb_we_o  <= 1'b0;
			r_wb_stb_o <= 1'b0;
			r_wb_cab_o <= 1'b0;
		end
		@(posedge wb_clk);
	end
	endtask

	task task_rd_ext;
		input		cab;
		input	[31:0]	adr;
		input	[3:0]	sel;
		input	[31:0]	data;
	begin
		begin
			r_wb_cyc_o <= 1'b1;
			r_wb_adr_o <= adr;
			r_wb_dat_o <= data;
			r_wb_sel_o <= sel;
			r_wb_we_o  <= 1'b0;
			r_wb_stb_o <= 1'b1;
			r_wb_cab_o <= cab;
		end
		begin : label_detect_rd_ext_ack
			forever @(posedge wb_clk) if (wb_ack_i==1'b1) disable label_detect_rd_ext_ack;
		end
		begin
			r_wb_cyc_o <= 1'b0;
			r_wb_adr_o <= adr;
			r_wb_dat_o <= data;
			r_wb_sel_o <= sel;
			r_wb_we_o  <= 1'b0;
			r_wb_stb_o <= 1'b0;
			r_wb_cab_o <= 1'b0;
		end
		@(posedge wb_clk);
	end
	endtask
`else
	assign wb_cyc_o = 1'b0;
	assign wb_adr_o = 32'h0000_0000;
	assign wb_dat_o = 32'h0000_0000;
	assign wb_sel_o = 4'b0000;
	assign wb_we_o  = 1'b0;
	assign wb_stb_o = 1'b0;
	assign wb_cab_o = 1'b0;
`endif

endmodule
		
