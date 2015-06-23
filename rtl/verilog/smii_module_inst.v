//////////////////////////////////////////////////////////////////////
////                                                              ////
////  SMII                                                        ////
////                                                              ////
////  Description                                                 ////
////  SMII low pin count ethernet PHY interface                   ////
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////                          michael.unneback@orsoc.se           ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
// wire declarations
`for (i=1;i<=SMII;i++)
   // MII
wire 	     m::`i::tx_clk;
wire [3:0] 	     m::`i::txd;
wire 	     m::`i::txen;
wire 	     m::`i::txerr;
wire 	     m::`i::rx_clk;
wire [3:0] 	     m::`i::rxd;
wire 	     m::`i::rxdv;
wire 	     m::`i::rxerr;
wire 	     m::`i::coll;
wire 	     m::`i::crs;   
`endfor
wire [1:10] 	     state;   
wire              sync;
wire [1:`SMII]    rx, tx;
wire [1:`SMII]    mdc_o, md_i, md_o, md_oe;
smii_sync smii_sync1
  (
   .sync(sync),
   .state(state),
   .clk(eth_clk),
   .rst(wb_rst)
   );

`ifndef SMII_SYNC_PER_PHY
obufdff obufdff_sync
  (
   .d(sync),
   .pad(eth_sync_pad_o),
   .clk(eth_clk),
   .rst(wb_rst)
   );
`endif

`for (i=1;i<=SMII;i++)
// ethernet MAC
eth_top eth_top::`i
	(
	 // wb common
	 .wb_clk_i(wb_clk),
	 .wb_rst_i(wb_rst),
	 // wb slave
	 .wb_dat_i(wbs_eth::`i::_cfg_dat_i),
	 .wb_dat_o(wbs_eth::`i::_cfg_dat_o),
	 .wb_adr_i(wbs_eth::`i::_cfg_adr_i[11:2]),
	 .wb_sel_i(wbs_eth::`i::_cfg_sel_i),
	 .wb_we_i(wbs_eth::`i::_cfg_we_i),
	 .wb_cyc_i(wbs_eth::`i::_cfg_cyc_i),
	 .wb_stb_i(wbs_eth::`i::_cfg_stb_i),
	 .wb_ack_o(wbs_eth::`i::_cfg_ack_o),
	 .wb_err_o(wbs_eth::`i::_cfg_err_o),
	 // wb master
	 .m_wb_adr_o(wbm_eth::`i::_adr_o),
	 .m_wb_sel_o(wbm_eth::`i::_sel_o),
	 .m_wb_we_o(wbm_eth::`i::_we_o),
	 .m_wb_dat_o(wbm_eth::`i::_dat_o),
	 .m_wb_dat_i(wbm_eth::`i::_dat_i),
	 .m_wb_cyc_o(wbm_eth::`i::_cyc_o),
	 .m_wb_stb_o(wbm_eth::`i::_stb_o),
	 .m_wb_ack_i(wbm_eth::`i::_ack_i),
	 .m_wb_err_i(wbm_eth::`i::_err_i),
	 .m_wb_cti_o(wbm_eth::`i::_cti_o),
	 .m_wb_bte_o(wbm_eth::`i::_bte_o),
	 // MII TX
	 .mtx_clk_pad_i(m::`i::tx_clk),
	 .mtxd_pad_o(m::`i::txd),
	 .mtxen_pad_o(m::`i::txen),
	 .mtxerr_pad_o(m::`i::txerr),
	 .mrx_clk_pad_i(m::`i::rx_clk),
	 .mrxd_pad_i(m::`i::rxd),
	 .mrxdv_pad_i(m::`i::rxdv),
	 .mrxerr_pad_i(m::`i::rxerr),
	 .mcoll_pad_i(m::`i::coll),
	 .mcrs_pad_i(m::`i::crs),
	 // MII management
	 .mdc_pad_o(mdc_o[`i]),
	 .md_pad_i(md_i[`i]),
	 .md_pad_o(md_o[`i]),
	 .md_padoe_o(md_oe[`i]),
	 .int_o(eth_int[`i])
	 );

iobuftri iobuftri::`i
  (
   .i(md_o[`i]),
   .oe(md_oe[`i]),
   .o(md_i[`i]),
   .pad(eth_md_pad_io[`i])
   );

obuf obuf::`i
  (
   .i(mdc_o[`i]),
   .pad(eth_mdc_pad_o[`i])
   );

smii_txrx smii_txrx::`i
  (
   .tx(tx[`i]),
   .rx(rx[`i]),
   .mtx_clk(m::`i::tx_clk),
   .mtxd(m::`i::txd),
   .mtxen(m::`i::txen),
   .mtxerr(m::`i::txerr),
   .mrx_clk(m::`i::rx_clk),
   .mrxd(m::`i::rxd),
   .mrxdv(m::`i::rxdv),
   .mrxerr(m::`i::rxerr),
   .mcoll(m::`i::coll),
   .mcrs(m::`i::crs),
   .state(state),
   .clk(eth_clk),
   .rst(wb_rst)
   );

 `ifdef SMII_SYNC_PER_PHY
obufdff obufdff_sync::`i
  (
   .d(sync),
   .pad(eth_sync_pad_o[`i]),
   .clk(eth_clk),
   .rst(wb_rst)
   );
 `endif

obufdff obufdff_tx::`i
  (
   .d(tx[`i]),
   .pad(eth_tx_pad_o[`i]),
   .clk(eth_clk),
   .rst(wb_rst)
   );

ibufdff ibufdff_rx::`i
  (
   .pad(eth_rx_pad_i[`i]),
   .q(rx[`i]),
   .clk(eth_clk),
   .rst(wb_rst)
   );

`endfor

