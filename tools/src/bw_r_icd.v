// Empty module for cacheless Simply RISC S1 Core

module bw_r_icd(icd_wsel_fetdata_s1, icd_wsel_topdata_s1, icd_fuse_repair_value,
	icd_fuse_repair_en, so, rclk, se, si, reset_l, sehold, fdp_icd_index_bf,
	ifq_icd_index_bf, fcl_icd_index_sel_ifq_bf, ifq_icd_wrway_bf, 
	ifq_icd_worden_bf, ifq_icd_wrdata_i2, fcl_icd_rdreq_bf, 
	fcl_icd_wrreq_bf, bist_ic_data, rst_tri_en, ifq_icd_data_sel_old_i2, 
	ifq_icd_data_sel_fill_i2, ifq_icd_data_sel_bist_i2, fuse_icd_wren, 
	fuse_icd_rid, fuse_icd_repair_value, fuse_icd_repair_en, 
	efc_spc_fuse_clk1);

	input			rclk;
	input			se;
	input			si;
	input			reset_l;
	input			sehold;
	input	[11:2]		fdp_icd_index_bf;
	input	[11:2]		ifq_icd_index_bf;
	input			fcl_icd_index_sel_ifq_bf;
	input	[1:0]		ifq_icd_wrway_bf;
	input	[3:0]		ifq_icd_worden_bf;
	input	[135:0]		ifq_icd_wrdata_i2;
	input			fcl_icd_rdreq_bf;
	input			fcl_icd_wrreq_bf;
	input	[7:0]		bist_ic_data;
	input			rst_tri_en;
	input			ifq_icd_data_sel_old_i2;
	input			ifq_icd_data_sel_fill_i2;
	input			ifq_icd_data_sel_bist_i2;
	input			fuse_icd_wren;
	input	[3:0]		fuse_icd_rid;
	input	[7:0]		fuse_icd_repair_value;
	input	[1:0]		fuse_icd_repair_en;
	input			efc_spc_fuse_clk1;
	output	[135:0]		icd_wsel_fetdata_s1;
	output	[135:0]		icd_wsel_topdata_s1;
	output	[7:0]		icd_fuse_repair_value;
	output	[1:0]		icd_fuse_repair_en;
	output			so;

endmodule
