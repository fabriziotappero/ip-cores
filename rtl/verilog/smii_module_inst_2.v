wire 	     m1tx_clk;
wire [3:0] 	     m1txd;
wire 	     m1txen;
wire 	     m1txerr;
wire 	     m1rx_clk;
wire [3:0] 	     m1rxd;
wire 	     m1rxdv;
wire 	     m1rxerr;
wire 	     m1coll;
wire 	     m1crs;   
wire 	     m2tx_clk;
wire [3:0] 	     m2txd;
wire 	     m2txen;
wire 	     m2txerr;
wire 	     m2rx_clk;
wire [3:0] 	     m2rxd;
wire 	     m2rxdv;
wire 	     m2rxerr;
wire 	     m2coll;
wire 	     m2crs;   
wire [1:10] 	     state;   
wire              sync;
wire [1:2]    rx, tx;
wire [1:2]    mdc_o, md_i, md_o, md_oe;
smii_sync smii_sync1
  (
   .sync(sync),
   .state(state),
   .clk(eth_clk),
   .rst(wb_rst)
   );
eth_top eth_top1
	(
	 .wb_clk_i(wb_clk),
	 .wb_rst_i(wb_rst),
	 .wb_dat_i(wbs_eth1_cfg_dat_i),
	 .wb_dat_o(wbs_eth1_cfg_dat_o),
	 .wb_adr_i(wbs_eth1_cfg_adr_i[11:2]),
	 .wb_sel_i(wbs_eth1_cfg_sel_i),
	 .wb_we_i(wbs_eth1_cfg_we_i),
	 .wb_cyc_i(wbs_eth1_cfg_cyc_i),
	 .wb_stb_i(wbs_eth1_cfg_stb_i),
	 .wb_ack_o(wbs_eth1_cfg_ack_o),
	 .wb_err_o(wbs_eth1_cfg_err_o),
	 .m_wb_adr_o(wbm_eth1_adr_o),
	 .m_wb_sel_o(wbm_eth1_sel_o),
	 .m_wb_we_o(wbm_eth1_we_o),
	 .m_wb_dat_o(wbm_eth1_dat_o),
	 .m_wb_dat_i(wbm_eth1_dat_i),
	 .m_wb_cyc_o(wbm_eth1_cyc_o),
	 .m_wb_stb_o(wbm_eth1_stb_o),
	 .m_wb_ack_i(wbm_eth1_ack_i),
	 .m_wb_err_i(wbm_eth1_err_i),
	 .m_wb_cti_o(wbm_eth1_cti_o),
	 .m_wb_bte_o(wbm_eth1_bte_o),
	 .mtx_clk_pad_i(m1tx_clk),
	 .mtxd_pad_o(m1txd),
	 .mtxen_pad_o(m1txen),
	 .mtxerr_pad_o(m1txerr),
	 .mrx_clk_pad_i(m1rx_clk),
	 .mrxd_pad_i(m1rxd),
	 .mrxdv_pad_i(m1rxdv),
	 .mrxerr_pad_i(m1rxerr),
	 .mcoll_pad_i(m1coll),
	 .mcrs_pad_i(m1crs),
	 .mdc_pad_o(mdc_o[1]),
	 .md_pad_i(md_i[1]),
	 .md_pad_o(md_o[1]),
	 .md_padoe_o(md_oe[1]),
	 .int_o(eth_int[1])
	 );
iobuftri iobuftri1
  (
   .i(md_o[1]),
   .oe(md_oe[1]),
   .o(md_i[1]),
   .pad(eth_md_pad_io[1])
   );
obuf obuf1
  (
   .i(mdc_o[1]),
   .pad(eth_mdc_pad_o[1])
   );
smii_txrx smii_txrx1
  (
   .tx(tx[1]),
   .rx(rx[1]),
   .mtx_clk(m1tx_clk),
   .mtxd(m1txd),
   .mtxen(m1txen),
   .mtxerr(m1txerr),
   .mrx_clk(m1rx_clk),
   .mrxd(m1rxd),
   .mrxdv(m1rxdv),
   .mrxerr(m1rxerr),
   .mcoll(m1coll),
   .mcrs(m1crs),
   .state(state),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_sync1
  (
   .d(sync),
   .pad(eth_sync_pad_o[1]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_tx1
  (
   .d(tx[1]),
   .pad(eth_tx_pad_o[1]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
ibufdff ibufdff_rx1
  (
   .pad(eth_rx_pad_i[1]),
   .q(rx[1]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
eth_top eth_top2
	(
	 .wb_clk_i(wb_clk),
	 .wb_rst_i(wb_rst),
	 .wb_dat_i(wbs_eth2_cfg_dat_i),
	 .wb_dat_o(wbs_eth2_cfg_dat_o),
	 .wb_adr_i(wbs_eth2_cfg_adr_i[11:2]),
	 .wb_sel_i(wbs_eth2_cfg_sel_i),
	 .wb_we_i(wbs_eth2_cfg_we_i),
	 .wb_cyc_i(wbs_eth2_cfg_cyc_i),
	 .wb_stb_i(wbs_eth2_cfg_stb_i),
	 .wb_ack_o(wbs_eth2_cfg_ack_o),
	 .wb_err_o(wbs_eth2_cfg_err_o),
	 .m_wb_adr_o(wbm_eth2_adr_o),
	 .m_wb_sel_o(wbm_eth2_sel_o),
	 .m_wb_we_o(wbm_eth2_we_o),
	 .m_wb_dat_o(wbm_eth2_dat_o),
	 .m_wb_dat_i(wbm_eth2_dat_i),
	 .m_wb_cyc_o(wbm_eth2_cyc_o),
	 .m_wb_stb_o(wbm_eth2_stb_o),
	 .m_wb_ack_i(wbm_eth2_ack_i),
	 .m_wb_err_i(wbm_eth2_err_i),
	 .m_wb_cti_o(wbm_eth2_cti_o),
	 .m_wb_bte_o(wbm_eth2_bte_o),
	 .mtx_clk_pad_i(m2tx_clk),
	 .mtxd_pad_o(m2txd),
	 .mtxen_pad_o(m2txen),
	 .mtxerr_pad_o(m2txerr),
	 .mrx_clk_pad_i(m2rx_clk),
	 .mrxd_pad_i(m2rxd),
	 .mrxdv_pad_i(m2rxdv),
	 .mrxerr_pad_i(m2rxerr),
	 .mcoll_pad_i(m2coll),
	 .mcrs_pad_i(m2crs),
	 .mdc_pad_o(mdc_o[2]),
	 .md_pad_i(md_i[2]),
	 .md_pad_o(md_o[2]),
	 .md_padoe_o(md_oe[2]),
	 .int_o(eth_int[2])
	 );
iobuftri iobuftri2
  (
   .i(md_o[2]),
   .oe(md_oe[2]),
   .o(md_i[2]),
   .pad(eth_md_pad_io[2])
   );
obuf obuf2
  (
   .i(mdc_o[2]),
   .pad(eth_mdc_pad_o[2])
   );
smii_txrx smii_txrx2
  (
   .tx(tx[2]),
   .rx(rx[2]),
   .mtx_clk(m2tx_clk),
   .mtxd(m2txd),
   .mtxen(m2txen),
   .mtxerr(m2txerr),
   .mrx_clk(m2rx_clk),
   .mrxd(m2rxd),
   .mrxdv(m2rxdv),
   .mrxerr(m2rxerr),
   .mcoll(m2coll),
   .mcrs(m2crs),
   .state(state),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_sync2
  (
   .d(sync),
   .pad(eth_sync_pad_o[2]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_tx2
  (
   .d(tx[2]),
   .pad(eth_tx_pad_o[2]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
ibufdff ibufdff_rx2
  (
   .pad(eth_rx_pad_i[2]),
   .q(rx[2]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
