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
wire 	     m3tx_clk;
wire [3:0] 	     m3txd;
wire 	     m3txen;
wire 	     m3txerr;
wire 	     m3rx_clk;
wire [3:0] 	     m3rxd;
wire 	     m3rxdv;
wire 	     m3rxerr;
wire 	     m3coll;
wire 	     m3crs;   
wire 	     m4tx_clk;
wire [3:0] 	     m4txd;
wire 	     m4txen;
wire 	     m4txerr;
wire 	     m4rx_clk;
wire [3:0] 	     m4rxd;
wire 	     m4rxdv;
wire 	     m4rxerr;
wire 	     m4coll;
wire 	     m4crs;   
wire 	     m5tx_clk;
wire [3:0] 	     m5txd;
wire 	     m5txen;
wire 	     m5txerr;
wire 	     m5rx_clk;
wire [3:0] 	     m5rxd;
wire 	     m5rxdv;
wire 	     m5rxerr;
wire 	     m5coll;
wire 	     m5crs;   
wire 	     m6tx_clk;
wire [3:0] 	     m6txd;
wire 	     m6txen;
wire 	     m6txerr;
wire 	     m6rx_clk;
wire [3:0] 	     m6rxd;
wire 	     m6rxdv;
wire 	     m6rxerr;
wire 	     m6coll;
wire 	     m6crs;   
wire 	     m7tx_clk;
wire [3:0] 	     m7txd;
wire 	     m7txen;
wire 	     m7txerr;
wire 	     m7rx_clk;
wire [3:0] 	     m7rxd;
wire 	     m7rxdv;
wire 	     m7rxerr;
wire 	     m7coll;
wire 	     m7crs;   
wire 	     m8tx_clk;
wire [3:0] 	     m8txd;
wire 	     m8txen;
wire 	     m8txerr;
wire 	     m8rx_clk;
wire [3:0] 	     m8rxd;
wire 	     m8rxdv;
wire 	     m8rxerr;
wire 	     m8coll;
wire 	     m8crs;   
wire [1:10] 	     state;   
wire              sync;
wire [1:8]    rx, tx;
wire [1:8]    mdc_o, md_i, md_o, md_oe;
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
eth_top eth_top3
	(
	 .wb_clk_i(wb_clk),
	 .wb_rst_i(wb_rst),
	 .wb_dat_i(wbs_eth3_cfg_dat_i),
	 .wb_dat_o(wbs_eth3_cfg_dat_o),
	 .wb_adr_i(wbs_eth3_cfg_adr_i[11:2]),
	 .wb_sel_i(wbs_eth3_cfg_sel_i),
	 .wb_we_i(wbs_eth3_cfg_we_i),
	 .wb_cyc_i(wbs_eth3_cfg_cyc_i),
	 .wb_stb_i(wbs_eth3_cfg_stb_i),
	 .wb_ack_o(wbs_eth3_cfg_ack_o),
	 .wb_err_o(wbs_eth3_cfg_err_o),
	 .m_wb_adr_o(wbm_eth3_adr_o),
	 .m_wb_sel_o(wbm_eth3_sel_o),
	 .m_wb_we_o(wbm_eth3_we_o),
	 .m_wb_dat_o(wbm_eth3_dat_o),
	 .m_wb_dat_i(wbm_eth3_dat_i),
	 .m_wb_cyc_o(wbm_eth3_cyc_o),
	 .m_wb_stb_o(wbm_eth3_stb_o),
	 .m_wb_ack_i(wbm_eth3_ack_i),
	 .m_wb_err_i(wbm_eth3_err_i),
	 .m_wb_cti_o(wbm_eth3_cti_o),
	 .m_wb_bte_o(wbm_eth3_bte_o),
	 .mtx_clk_pad_i(m3tx_clk),
	 .mtxd_pad_o(m3txd),
	 .mtxen_pad_o(m3txen),
	 .mtxerr_pad_o(m3txerr),
	 .mrx_clk_pad_i(m3rx_clk),
	 .mrxd_pad_i(m3rxd),
	 .mrxdv_pad_i(m3rxdv),
	 .mrxerr_pad_i(m3rxerr),
	 .mcoll_pad_i(m3coll),
	 .mcrs_pad_i(m3crs),
	 .mdc_pad_o(mdc_o[3]),
	 .md_pad_i(md_i[3]),
	 .md_pad_o(md_o[3]),
	 .md_padoe_o(md_oe[3]),
	 .int_o(eth_int[3])
	 );
iobuftri iobuftri3
  (
   .i(md_o[3]),
   .oe(md_oe[3]),
   .o(md_i[3]),
   .pad(eth_md_pad_io[3])
   );
obuf obuf3
  (
   .i(mdc_o[3]),
   .pad(eth_mdc_pad_o[3])
   );
smii_txrx smii_txrx3
  (
   .tx(tx[3]),
   .rx(rx[3]),
   .mtx_clk(m3tx_clk),
   .mtxd(m3txd),
   .mtxen(m3txen),
   .mtxerr(m3txerr),
   .mrx_clk(m3rx_clk),
   .mrxd(m3rxd),
   .mrxdv(m3rxdv),
   .mrxerr(m3rxerr),
   .mcoll(m3coll),
   .mcrs(m3crs),
   .state(state),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_sync3
  (
   .d(sync),
   .pad(eth_sync_pad_o[3]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_tx3
  (
   .d(tx[3]),
   .pad(eth_tx_pad_o[3]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
ibufdff ibufdff_rx3
  (
   .pad(eth_rx_pad_i[3]),
   .q(rx[3]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
eth_top eth_top4
	(
	 .wb_clk_i(wb_clk),
	 .wb_rst_i(wb_rst),
	 .wb_dat_i(wbs_eth4_cfg_dat_i),
	 .wb_dat_o(wbs_eth4_cfg_dat_o),
	 .wb_adr_i(wbs_eth4_cfg_adr_i[11:2]),
	 .wb_sel_i(wbs_eth4_cfg_sel_i),
	 .wb_we_i(wbs_eth4_cfg_we_i),
	 .wb_cyc_i(wbs_eth4_cfg_cyc_i),
	 .wb_stb_i(wbs_eth4_cfg_stb_i),
	 .wb_ack_o(wbs_eth4_cfg_ack_o),
	 .wb_err_o(wbs_eth4_cfg_err_o),
	 .m_wb_adr_o(wbm_eth4_adr_o),
	 .m_wb_sel_o(wbm_eth4_sel_o),
	 .m_wb_we_o(wbm_eth4_we_o),
	 .m_wb_dat_o(wbm_eth4_dat_o),
	 .m_wb_dat_i(wbm_eth4_dat_i),
	 .m_wb_cyc_o(wbm_eth4_cyc_o),
	 .m_wb_stb_o(wbm_eth4_stb_o),
	 .m_wb_ack_i(wbm_eth4_ack_i),
	 .m_wb_err_i(wbm_eth4_err_i),
	 .m_wb_cti_o(wbm_eth4_cti_o),
	 .m_wb_bte_o(wbm_eth4_bte_o),
	 .mtx_clk_pad_i(m4tx_clk),
	 .mtxd_pad_o(m4txd),
	 .mtxen_pad_o(m4txen),
	 .mtxerr_pad_o(m4txerr),
	 .mrx_clk_pad_i(m4rx_clk),
	 .mrxd_pad_i(m4rxd),
	 .mrxdv_pad_i(m4rxdv),
	 .mrxerr_pad_i(m4rxerr),
	 .mcoll_pad_i(m4coll),
	 .mcrs_pad_i(m4crs),
	 .mdc_pad_o(mdc_o[4]),
	 .md_pad_i(md_i[4]),
	 .md_pad_o(md_o[4]),
	 .md_padoe_o(md_oe[4]),
	 .int_o(eth_int[4])
	 );
iobuftri iobuftri4
  (
   .i(md_o[4]),
   .oe(md_oe[4]),
   .o(md_i[4]),
   .pad(eth_md_pad_io[4])
   );
obuf obuf4
  (
   .i(mdc_o[4]),
   .pad(eth_mdc_pad_o[4])
   );
smii_txrx smii_txrx4
  (
   .tx(tx[4]),
   .rx(rx[4]),
   .mtx_clk(m4tx_clk),
   .mtxd(m4txd),
   .mtxen(m4txen),
   .mtxerr(m4txerr),
   .mrx_clk(m4rx_clk),
   .mrxd(m4rxd),
   .mrxdv(m4rxdv),
   .mrxerr(m4rxerr),
   .mcoll(m4coll),
   .mcrs(m4crs),
   .state(state),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_sync4
  (
   .d(sync),
   .pad(eth_sync_pad_o[4]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_tx4
  (
   .d(tx[4]),
   .pad(eth_tx_pad_o[4]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
ibufdff ibufdff_rx4
  (
   .pad(eth_rx_pad_i[4]),
   .q(rx[4]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
eth_top eth_top5
	(
	 .wb_clk_i(wb_clk),
	 .wb_rst_i(wb_rst),
	 .wb_dat_i(wbs_eth5_cfg_dat_i),
	 .wb_dat_o(wbs_eth5_cfg_dat_o),
	 .wb_adr_i(wbs_eth5_cfg_adr_i[11:2]),
	 .wb_sel_i(wbs_eth5_cfg_sel_i),
	 .wb_we_i(wbs_eth5_cfg_we_i),
	 .wb_cyc_i(wbs_eth5_cfg_cyc_i),
	 .wb_stb_i(wbs_eth5_cfg_stb_i),
	 .wb_ack_o(wbs_eth5_cfg_ack_o),
	 .wb_err_o(wbs_eth5_cfg_err_o),
	 .m_wb_adr_o(wbm_eth5_adr_o),
	 .m_wb_sel_o(wbm_eth5_sel_o),
	 .m_wb_we_o(wbm_eth5_we_o),
	 .m_wb_dat_o(wbm_eth5_dat_o),
	 .m_wb_dat_i(wbm_eth5_dat_i),
	 .m_wb_cyc_o(wbm_eth5_cyc_o),
	 .m_wb_stb_o(wbm_eth5_stb_o),
	 .m_wb_ack_i(wbm_eth5_ack_i),
	 .m_wb_err_i(wbm_eth5_err_i),
	 .m_wb_cti_o(wbm_eth5_cti_o),
	 .m_wb_bte_o(wbm_eth5_bte_o),
	 .mtx_clk_pad_i(m5tx_clk),
	 .mtxd_pad_o(m5txd),
	 .mtxen_pad_o(m5txen),
	 .mtxerr_pad_o(m5txerr),
	 .mrx_clk_pad_i(m5rx_clk),
	 .mrxd_pad_i(m5rxd),
	 .mrxdv_pad_i(m5rxdv),
	 .mrxerr_pad_i(m5rxerr),
	 .mcoll_pad_i(m5coll),
	 .mcrs_pad_i(m5crs),
	 .mdc_pad_o(mdc_o[5]),
	 .md_pad_i(md_i[5]),
	 .md_pad_o(md_o[5]),
	 .md_padoe_o(md_oe[5]),
	 .int_o(eth_int[5])
	 );
iobuftri iobuftri5
  (
   .i(md_o[5]),
   .oe(md_oe[5]),
   .o(md_i[5]),
   .pad(eth_md_pad_io[5])
   );
obuf obuf5
  (
   .i(mdc_o[5]),
   .pad(eth_mdc_pad_o[5])
   );
smii_txrx smii_txrx5
  (
   .tx(tx[5]),
   .rx(rx[5]),
   .mtx_clk(m5tx_clk),
   .mtxd(m5txd),
   .mtxen(m5txen),
   .mtxerr(m5txerr),
   .mrx_clk(m5rx_clk),
   .mrxd(m5rxd),
   .mrxdv(m5rxdv),
   .mrxerr(m5rxerr),
   .mcoll(m5coll),
   .mcrs(m5crs),
   .state(state),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_sync5
  (
   .d(sync),
   .pad(eth_sync_pad_o[5]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_tx5
  (
   .d(tx[5]),
   .pad(eth_tx_pad_o[5]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
ibufdff ibufdff_rx5
  (
   .pad(eth_rx_pad_i[5]),
   .q(rx[5]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
eth_top eth_top6
	(
	 .wb_clk_i(wb_clk),
	 .wb_rst_i(wb_rst),
	 .wb_dat_i(wbs_eth6_cfg_dat_i),
	 .wb_dat_o(wbs_eth6_cfg_dat_o),
	 .wb_adr_i(wbs_eth6_cfg_adr_i[11:2]),
	 .wb_sel_i(wbs_eth6_cfg_sel_i),
	 .wb_we_i(wbs_eth6_cfg_we_i),
	 .wb_cyc_i(wbs_eth6_cfg_cyc_i),
	 .wb_stb_i(wbs_eth6_cfg_stb_i),
	 .wb_ack_o(wbs_eth6_cfg_ack_o),
	 .wb_err_o(wbs_eth6_cfg_err_o),
	 .m_wb_adr_o(wbm_eth6_adr_o),
	 .m_wb_sel_o(wbm_eth6_sel_o),
	 .m_wb_we_o(wbm_eth6_we_o),
	 .m_wb_dat_o(wbm_eth6_dat_o),
	 .m_wb_dat_i(wbm_eth6_dat_i),
	 .m_wb_cyc_o(wbm_eth6_cyc_o),
	 .m_wb_stb_o(wbm_eth6_stb_o),
	 .m_wb_ack_i(wbm_eth6_ack_i),
	 .m_wb_err_i(wbm_eth6_err_i),
	 .m_wb_cti_o(wbm_eth6_cti_o),
	 .m_wb_bte_o(wbm_eth6_bte_o),
	 .mtx_clk_pad_i(m6tx_clk),
	 .mtxd_pad_o(m6txd),
	 .mtxen_pad_o(m6txen),
	 .mtxerr_pad_o(m6txerr),
	 .mrx_clk_pad_i(m6rx_clk),
	 .mrxd_pad_i(m6rxd),
	 .mrxdv_pad_i(m6rxdv),
	 .mrxerr_pad_i(m6rxerr),
	 .mcoll_pad_i(m6coll),
	 .mcrs_pad_i(m6crs),
	 .mdc_pad_o(mdc_o[6]),
	 .md_pad_i(md_i[6]),
	 .md_pad_o(md_o[6]),
	 .md_padoe_o(md_oe[6]),
	 .int_o(eth_int[6])
	 );
iobuftri iobuftri6
  (
   .i(md_o[6]),
   .oe(md_oe[6]),
   .o(md_i[6]),
   .pad(eth_md_pad_io[6])
   );
obuf obuf6
  (
   .i(mdc_o[6]),
   .pad(eth_mdc_pad_o[6])
   );
smii_txrx smii_txrx6
  (
   .tx(tx[6]),
   .rx(rx[6]),
   .mtx_clk(m6tx_clk),
   .mtxd(m6txd),
   .mtxen(m6txen),
   .mtxerr(m6txerr),
   .mrx_clk(m6rx_clk),
   .mrxd(m6rxd),
   .mrxdv(m6rxdv),
   .mrxerr(m6rxerr),
   .mcoll(m6coll),
   .mcrs(m6crs),
   .state(state),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_sync6
  (
   .d(sync),
   .pad(eth_sync_pad_o[6]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_tx6
  (
   .d(tx[6]),
   .pad(eth_tx_pad_o[6]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
ibufdff ibufdff_rx6
  (
   .pad(eth_rx_pad_i[6]),
   .q(rx[6]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
eth_top eth_top7
	(
	 .wb_clk_i(wb_clk),
	 .wb_rst_i(wb_rst),
	 .wb_dat_i(wbs_eth7_cfg_dat_i),
	 .wb_dat_o(wbs_eth7_cfg_dat_o),
	 .wb_adr_i(wbs_eth7_cfg_adr_i[11:2]),
	 .wb_sel_i(wbs_eth7_cfg_sel_i),
	 .wb_we_i(wbs_eth7_cfg_we_i),
	 .wb_cyc_i(wbs_eth7_cfg_cyc_i),
	 .wb_stb_i(wbs_eth7_cfg_stb_i),
	 .wb_ack_o(wbs_eth7_cfg_ack_o),
	 .wb_err_o(wbs_eth7_cfg_err_o),
	 .m_wb_adr_o(wbm_eth7_adr_o),
	 .m_wb_sel_o(wbm_eth7_sel_o),
	 .m_wb_we_o(wbm_eth7_we_o),
	 .m_wb_dat_o(wbm_eth7_dat_o),
	 .m_wb_dat_i(wbm_eth7_dat_i),
	 .m_wb_cyc_o(wbm_eth7_cyc_o),
	 .m_wb_stb_o(wbm_eth7_stb_o),
	 .m_wb_ack_i(wbm_eth7_ack_i),
	 .m_wb_err_i(wbm_eth7_err_i),
	 .m_wb_cti_o(wbm_eth7_cti_o),
	 .m_wb_bte_o(wbm_eth7_bte_o),
	 .mtx_clk_pad_i(m7tx_clk),
	 .mtxd_pad_o(m7txd),
	 .mtxen_pad_o(m7txen),
	 .mtxerr_pad_o(m7txerr),
	 .mrx_clk_pad_i(m7rx_clk),
	 .mrxd_pad_i(m7rxd),
	 .mrxdv_pad_i(m7rxdv),
	 .mrxerr_pad_i(m7rxerr),
	 .mcoll_pad_i(m7coll),
	 .mcrs_pad_i(m7crs),
	 .mdc_pad_o(mdc_o[7]),
	 .md_pad_i(md_i[7]),
	 .md_pad_o(md_o[7]),
	 .md_padoe_o(md_oe[7]),
	 .int_o(eth_int[7])
	 );
iobuftri iobuftri7
  (
   .i(md_o[7]),
   .oe(md_oe[7]),
   .o(md_i[7]),
   .pad(eth_md_pad_io[7])
   );
obuf obuf7
  (
   .i(mdc_o[7]),
   .pad(eth_mdc_pad_o[7])
   );
smii_txrx smii_txrx7
  (
   .tx(tx[7]),
   .rx(rx[7]),
   .mtx_clk(m7tx_clk),
   .mtxd(m7txd),
   .mtxen(m7txen),
   .mtxerr(m7txerr),
   .mrx_clk(m7rx_clk),
   .mrxd(m7rxd),
   .mrxdv(m7rxdv),
   .mrxerr(m7rxerr),
   .mcoll(m7coll),
   .mcrs(m7crs),
   .state(state),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_sync7
  (
   .d(sync),
   .pad(eth_sync_pad_o[7]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_tx7
  (
   .d(tx[7]),
   .pad(eth_tx_pad_o[7]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
ibufdff ibufdff_rx7
  (
   .pad(eth_rx_pad_i[7]),
   .q(rx[7]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
eth_top eth_top8
	(
	 .wb_clk_i(wb_clk),
	 .wb_rst_i(wb_rst),
	 .wb_dat_i(wbs_eth8_cfg_dat_i),
	 .wb_dat_o(wbs_eth8_cfg_dat_o),
	 .wb_adr_i(wbs_eth8_cfg_adr_i[11:2]),
	 .wb_sel_i(wbs_eth8_cfg_sel_i),
	 .wb_we_i(wbs_eth8_cfg_we_i),
	 .wb_cyc_i(wbs_eth8_cfg_cyc_i),
	 .wb_stb_i(wbs_eth8_cfg_stb_i),
	 .wb_ack_o(wbs_eth8_cfg_ack_o),
	 .wb_err_o(wbs_eth8_cfg_err_o),
	 .m_wb_adr_o(wbm_eth8_adr_o),
	 .m_wb_sel_o(wbm_eth8_sel_o),
	 .m_wb_we_o(wbm_eth8_we_o),
	 .m_wb_dat_o(wbm_eth8_dat_o),
	 .m_wb_dat_i(wbm_eth8_dat_i),
	 .m_wb_cyc_o(wbm_eth8_cyc_o),
	 .m_wb_stb_o(wbm_eth8_stb_o),
	 .m_wb_ack_i(wbm_eth8_ack_i),
	 .m_wb_err_i(wbm_eth8_err_i),
	 .m_wb_cti_o(wbm_eth8_cti_o),
	 .m_wb_bte_o(wbm_eth8_bte_o),
	 .mtx_clk_pad_i(m8tx_clk),
	 .mtxd_pad_o(m8txd),
	 .mtxen_pad_o(m8txen),
	 .mtxerr_pad_o(m8txerr),
	 .mrx_clk_pad_i(m8rx_clk),
	 .mrxd_pad_i(m8rxd),
	 .mrxdv_pad_i(m8rxdv),
	 .mrxerr_pad_i(m8rxerr),
	 .mcoll_pad_i(m8coll),
	 .mcrs_pad_i(m8crs),
	 .mdc_pad_o(mdc_o[8]),
	 .md_pad_i(md_i[8]),
	 .md_pad_o(md_o[8]),
	 .md_padoe_o(md_oe[8]),
	 .int_o(eth_int[8])
	 );
iobuftri iobuftri8
  (
   .i(md_o[8]),
   .oe(md_oe[8]),
   .o(md_i[8]),
   .pad(eth_md_pad_io[8])
   );
obuf obuf8
  (
   .i(mdc_o[8]),
   .pad(eth_mdc_pad_o[8])
   );
smii_txrx smii_txrx8
  (
   .tx(tx[8]),
   .rx(rx[8]),
   .mtx_clk(m8tx_clk),
   .mtxd(m8txd),
   .mtxen(m8txen),
   .mtxerr(m8txerr),
   .mrx_clk(m8rx_clk),
   .mrxd(m8rxd),
   .mrxdv(m8rxdv),
   .mrxerr(m8rxerr),
   .mcoll(m8coll),
   .mcrs(m8crs),
   .state(state),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_sync8
  (
   .d(sync),
   .pad(eth_sync_pad_o[8]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
obufdff obufdff_tx8
  (
   .d(tx[8]),
   .pad(eth_tx_pad_o[8]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
ibufdff ibufdff_rx8
  (
   .pad(eth_rx_pad_i[8]),
   .q(rx[8]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
