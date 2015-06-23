`include "sd_defines.v"

wire sd_cmd_oe;
wire sd_cmd_out;
wire sd_dat_oe;
wire [3:0] sd_dat_out;

assign sd_cmd_pad_io = sd_cmd_oe ? sd_cmd_out : 1'bZ ;
assign sd_dat_pad_io = sd_dat_oe ? sd_dat_out : 4'bzzzz ;

sd_controller_fifo_wba SD_CONTROLLER_TOP
	(
	 .wb_clk_i(wb_clk),
	 .wb_rst_i(wb_rst),
	 .wb_dat_i(wbs_sds_dat_i),
	 .wb_dat_o(wbs_sds_dat_o),
	 .wb_adr_i(wbs_sds_adr_i[7:2]),
	 .wb_sel_i(wbs_sds_sel_i),
	 .wb_we_i(wbs_sds_we_i),
	 
	 .wb_stb_i(wbs_sds_stb_i),
	 .wb_cyc_i(wbs_sds_cyc_i),
	 .wb_ack_o(wbs_sds_ack_o),

	 .sd_cmd_dat_i(sd_cmd_pad_io),
       .sd_cmd_out_o (sd_cmd_out  ),
	 .sd_cmd_oe_o (sd_cmd_oe),
	 .sd_dat_dat_i ( sd_dat_pad_io),
	 .sd_dat_out_o ( sd_dat_out ) ,
       .sd_dat_oe_o ( sd_dat_oe  ),
	 .sd_clk_o_pad  (sd_clk_pad_o)

   `ifdef SD_CLK_EXT
    , .sd_clk_i_pad (sd_clk_i_pad)
   `endif
	 );
  

   
   
   



