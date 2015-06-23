//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores MAC Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
//`timescale 1ns/100ps
  module  g_mac_core (
                    scan_mode, 
                    s_reset_n, 
                    tx_reset_n,
                    rx_reset_n,
                    reset_mdio_clk_n,
                    app_reset_n,

                    app_clk,

                 // Reg Bus Interface Signal
                    reg_cs,
                    reg_wr,
                    reg_addr,
                    reg_wdata,
                    reg_be,

                     // Outputs
                    reg_rdata,
                    reg_ack,


                  // RX FIFO Interface Signal
                    rx_fifo_full_i,
                    rx_fifo_wr_o,
                    rx_fifo_data_o,
                    rx_commit_wr_o,
                    rx_rewind_wr_o,
                    rx_commit_write_done_o,
                    clr_rx_error_from_rx_fsm_o,
                    rx_fifo_error_i,

                  // TX FIFO Interface Signal
                    tx_fifo_data_i,
                    tx_fifo_empty_i,
                    tx_fifo_rdy_i,
                    tx_fifo_rd_o,
                    tx_commit_read_o,

                    // Phy Signals 

                    // Line Side Interface TX Path
                    phy_tx_en,
                    phy_tx_er,
                    phy_txd,
                    phy_tx_clk,

                    // Line Side Interface RX Path
                    phy_rx_clk,
                    phy_rx_er,
                    phy_rx_dv,
                    phy_rxd,
                    phy_crs,

                    //MDIO interface
                    mdio_clk,
                    mdio_in,
                    mdio_out_en,
                    mdio_out,

                    // configuration output
                    cf_mac_sa,
                    cfg_ip_sa,
                    cfg_mac_filter,
                    rx_buf_base_addr,
                    tx_buf_base_addr,

                    rx_buf_qbase_addr,
                    tx_buf_qbase_addr,

                    tx_qcnt_inc,
                    tx_qcnt_dec,
                    tx_qcnt,

                    rx_qcnt_inc,
                    rx_qcnt_dec,
                    rx_qcnt

       );
                    
parameter mac_mdio_en = 1'b1;
		    
//-----------------------------------------------------------------------
// INPUT/OUTPUT DECLARATIONS
//-----------------------------------------------------------------------
input                    scan_mode; 
input                    s_reset_n; 
input                    tx_reset_n;
input                    rx_reset_n;
input                    reset_mdio_clk_n;
input                    app_reset_n;

//-----------------------------------------------------------------------
// Application Clock Related Declaration
//-----------------------------------------------------------------------
input        app_clk;

// Conntrol Bus Sync with Application Clock
//---------------------------------
// Reg Bus Interface Signal
//---------------------------------
   input             reg_cs         ;
   input             reg_wr         ;
   input [3:0]       reg_addr       ;
   input [31:0]      reg_wdata      ;
   input [3:0]       reg_be         ;
   
   // Outputs
   output [31:0]     reg_rdata      ;
   output            reg_ack        ;



// RX FIFO Interface Signal
output       clr_rx_error_from_rx_fsm_o;
input        rx_fifo_full_i;
output       rx_fifo_wr_o;
output [8:0] rx_fifo_data_o;
output       rx_commit_wr_o;
output       rx_commit_write_done_o;   
output       rx_rewind_wr_o;
input	     rx_fifo_error_i;

//-----------------------------------------------------------------------
// TX-Clock Domain Status Signal
//-----------------------------------------------------------------------
output       tx_commit_read_o;
output       tx_fifo_rd_o;

input [8:0]  tx_fifo_data_i;
input	     tx_fifo_empty_i;
input	     tx_fifo_rdy_i;


//-----------------------------------------------------------------------
// Line-Tx Signal
//-----------------------------------------------------------------------
output       phy_tx_en;
output       phy_tx_er;
output [7:0] phy_txd;
input	     phy_tx_clk;

//-----------------------------------------------------------------------
// Line-Rx Signal
//-----------------------------------------------------------------------
input	     phy_rx_clk;
input	     phy_rx_er;
input	     phy_rx_dv;
input [7:0]  phy_rxd;
input	     phy_crs;


//-----------------------------------------------------------------------
// MDIO Signal
//-----------------------------------------------------------------------
input	     mdio_clk;
input	     mdio_in;
output       mdio_out_en;
output       mdio_out;
		    
output [47:0]   cf_mac_sa;
output [31:0]   cfg_ip_sa;
output [31:0]   cfg_mac_filter;
output [3:0]    rx_buf_base_addr;
output [3:0]    tx_buf_base_addr;

output [9:0]   rx_buf_qbase_addr;  // Rx Q Base Address
output [9:0]   tx_buf_qbase_addr;  // Tx Q Base Address

input           tx_qcnt_inc;
input           tx_qcnt_dec;
output [3:0]    tx_qcnt;

input           rx_qcnt_inc;
input           rx_qcnt_dec;
output [3:0]    rx_qcnt;

//-----------------------------------------------------------------------
// RX-Clock Domain Status Signal
//-----------------------------------------------------------------------
wire        rx_sts_vld_o;
wire [15:0] rx_sts_bytes_rcvd_o;
wire        rx_sts_large_pkt_o;
wire        rx_sts_lengthfield_err_o;
wire        rx_sts_len_mismatch_o;
wire        rx_sts_crc_err_o;
wire        rx_sts_runt_pkt_rcvd_o;
wire        rx_sts_rx_overrun_o;
wire        rx_sts_frm_length_err_o;
wire        rx_sts_rx_er_o;  


//-----------------------------------------------------------------------
// TX-Clock Domain Status Signal
//-----------------------------------------------------------------------
wire         tx_sts_vld_o          ;
wire   [15:0]tx_sts_byte_cntr_o    ;
wire         tx_sts_fifo_underrun_o;
// TX Interface Status Signal
wire         tx_set_fifo_undrn_o   ;// Description: At GMII Interface ,
                                    // abug after a transmit fifo underun was found.
                                    // The packet after a packet that 
                                    // underran has 1 too few bytes .

wire[7:0]  	mi2rx_rx_byte,tx2mi_tx_byte;
wire [7:0]  cf2df_dfl_single_rx;
wire [15:0] cf2rx_max_pkt_sz;

     g_rx_top	u_rx_top(
		//application
                    .app_clk                      (app_clk),
                    .app_reset_n                    (s_reset_n),      // Condor Change
                    .rx_reset_n                     (rx_reset_n),
                    .scan_mode                    (scan_mode),
                    
                    .rx_sts_vld                   (rx_sts_vld_o),
                    .rx_sts_bytes_rcvd            (rx_sts_bytes_rcvd_o),
                    .rx_sts_large_pkt             (rx_sts_large_pkt_o),
                    .rx_sts_lengthfield_err       (rx_sts_lengthfield_err_o),
                    .rx_sts_len_mismatch          (rx_sts_len_mismatch_o),
                    .rx_sts_crc_err               (rx_sts_crc_err_o),
                    .rx_sts_runt_pkt_rcvd         (rx_sts_runt_pkt_rcvd_o),
                    .rx_sts_rx_overrun            (rx_sts_rx_overrun_o),
                    .rx_sts_frm_length_err        (rx_sts_frm_length_err_o),
                    .clr_rx_error_from_rx_fsm     (clr_rx_error_from_rx_fsm_o),
                    .rx_fifo_full                 (rx_fifo_full_i),
                    .rx_dt_wrt                    (rx_fifo_wr_o),
                    .rx_dt_out                    (rx_fifo_data_o),
                    .rx_commit_wr                 (rx_commit_wr_o),
                    .commit_write_done            (rx_commit_write_done_o),
                    .rx_rewind_wr                 (rx_rewind_wr_o),
                    //mii interface
                    .phy_rx_clk                   (phy_rx_clk),
                    .mi2rx_strt_rcv               (mi2rx_strt_rcv),
                    .mi2rx_rcv_vld                (mi2rx_rcv_vld),
                    .mi2rx_rx_byte                (mi2rx_rx_byte),
                    .mi2rx_end_rcv                (mi2rx_end_rcv),
                    .mi2rx_extend                 (mi2rx_extend),
                    .mi2rx_frame_err              (mi2rx_frame_err),
                    .mi2rx_end_frame              (mi2rx_end_frame),
                    .mi2rx_crs                    (mi2rx_crs),
                    .df2rx_dfl_dn                 (df2rx_dfl_dn),
                    //PHY Signals
                    .phy_rx_dv                    (phy_rx_dv),
                    //Config interface
                    .cf2rx_max_pkt_sz             (cf2rx_max_pkt_sz),
                    .cf2rx_rx_ch_en               (cf2rx_ch_en),
                    .cf2rx_strp_pad_en            (cf2rx_strp_pad_en),
                    .cf2rx_snd_crc                (cf2rx_snd_crc),
                    .cf2rx_rcv_runt_pkt_en        (cf2rx_runt_pkt_en),
                    .cf_macmode                   (cf_mac_mode_o),
                    .cf2df_dfl_single_rx          (cf2df_dfl_single_rx),
                    .ap2rx_rx_fifo_err            (rx_fifo_error_i),
                    //A200 change Port added for crs based flow control
                    .phy_crs                      (phy_crs)
	       );
   
    wire [4:0]  	cf2md_regad,cf2md_phyad;
    wire [15:0] 	cf2md_datain,md2cf_data;



    wire        md2cf_status;
    wire        md2cf_cmd_done;
    wire        cf2md_op;
    wire        cf2md_go;
    wire        mdc;

    wire        int_s_reset_n;
    wire [4:0]  int_cf2md_regad;
    wire [4:0]  int_cf2md_phyad;
    wire        int_cf2md_op;
    wire        int_cf2md_go;
    wire [15:0] int_cf2md_datain;
    
    wire        int_md2cf_status;
    wire [15:0] int_md2cf_data;
    wire        int_md2cf_cmd_done;

    wire        int_mdio_clk;
    wire        int_mdio_out_en;
    wire        int_mdio_out;
    wire        int_mdc;
    wire        int_mdio_in;

// ------------------------------------------------------------------------
// CONDOR CHANGE
// MDIO Enable/disable Mux
// MDIO is used only in the WAN MAC block. The MDIO block has to be disabled
// in all other places. When MDIO is enabled the MDIO block signals will be
// connected to core module appriprotately. If MDIO is disabled, all inputs
// to the MDIO module is made zero and all outputs from this module to other
// modules is made zero. The enable/disable is controlled by the parameter
// mac_mdio_en.
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// Inputs to the MDIO module
// ------------------------------------------------------------------------

assign int_s_reset_n     = (mac_mdio_en == 1'b1) ? reset_mdio_clk_n  : 1'b1;
assign int_cf2md_regad   = (mac_mdio_en == 1'b1) ? cf2md_regad     : 5'b0;
assign int_cf2md_phyad   = (mac_mdio_en == 1'b1) ? cf2md_phyad     : 5'b0;
assign int_cf2md_op      = (mac_mdio_en == 1'b1) ? cf2md_op        : 1'b0;
assign int_cf2md_go      = (mac_mdio_en == 1'b1) ? cf2md_go        : 1'b0;
assign int_cf2md_datain  = (mac_mdio_en == 1'b1) ? cf2md_datain    : 16'b0;

// ------------------------------------------------------------------------
// Outputs from the MDIO module used locally
// ------------------------------------------------------------------------

assign md2cf_status      = (mac_mdio_en == 1'b1) ? int_md2cf_status   : 1'b0;
assign md2cf_data        = (mac_mdio_en == 1'b1) ? int_md2cf_data     : 16'b0;
//assign md2cf_cmd_done    = (mac_mdio_en == 1'b1) ? int_md2cf_cmd_done : 1'b0;

// ------------------------------------------------------------------------
// Outputs from the MDIO module driven out of this module
// ------------------------------------------------------------------------

assign mdio_out_en       = (mac_mdio_en == 1'b1) ? int_mdio_out_en : 1'b0;
assign mdio_out          = (mac_mdio_en == 1'b1) ? int_mdio_out    : 1'b0;
assign mdc               = (mac_mdio_en == 1'b1) ? int_mdc         : 1'b0;

assign int_mdio_clk      = (mac_mdio_en == 1'b1) ? mdio_clk        : 1'b0;
assign int_mdio_in       = (mac_mdio_en == 1'b1) ? mdio_in         : 1'b0;

// ------------------------------------------------------------------------
// MDIO module connected with 'int_' signals
// ------------------------------------------------------------------------


    g_md_intf u_md_intf(
		  //apllication interface
                    .scan_mode                    (scan_mode), // A200 change
                    .reset_n                      (int_s_reset_n),      // Condor Change
                    
                    .mdio_clk                     (int_mdio_clk),
                    .mdio_in                      (int_mdio_in),
                    .mdio_outen_reg               (int_mdio_out_en),
                    .mdio_out_reg                 (int_mdio_out),
                    //Config interface
                    .mdio_regad                   (int_cf2md_regad),
                    .mdio_phyad                   (int_cf2md_phyad),
                    .mdio_op                      (int_cf2md_op),
                    .go_mdio                      (int_cf2md_go),
                    .mdio_datain                  (int_cf2md_datain),
                    .mdio_dataout                 (int_md2cf_data),
                    .mdio_cmd_done                (md2cf_cmd_done),
                    .mdio_stat                    (int_md2cf_status),
                    .mdc                          (int_mdc)
                    );
		

  wire [7:0]  cf2df_dfl_single;
  wire [47:0] cf_mac_sa;
  wire        cf2tx_force_bad_fcs;
  wire        set_fifo_undrn;
    
    g_tx_top U_tx_top                    (
                    .app_clk                      (app_clk) ,   
                    .set_fifo_undrn               (tx_set_fifo_undrn_o),
                    
                    //Outputs
                    //TX FIFO management
                    .tx_commit_read               (tx_commit_read_o),
                    .tx_dt_rd                     (tx_fifo_rd_o),
                    
                    //MII interface
                    .tx2mi_strt_preamble          (tx2mi_strt_preamble),
                    .tx2mi_byte_valid             (tx2mi_byte_valid),
                    .tx2mi_byte                   (tx2mi_tx_byte),
                    .tx2mi_end_transmit           (tx2mi_end_transmit),
                    .tx_ch_en                     (tx_ch_en),        
                    
                    //Status to application
                    .tx_sts_vld                   (tx_sts_vld_o),
                    .tx_sts_byte_cntr             (tx_sts_byte_cntr_o),
                    .tx_sts_fifo_underrun         (tx_sts_fifo_underrun_o),
                    
                    //Inputs
                    //MII interface
                    .phy_tx_en                    (phy_tx_en),
                    .phy_tx_er                    (phy_tx_er),
                    
                    
                    //configuration
                    .cf2tx_ch_en                  (cf2tx_ch_en),
                    .cf2df_dfl_single             (cf2df_dfl_single),
                    .cf2tx_pad_enable             (cf2tx_pad_enable),
                    .cf2tx_append_fcs             (cf2tx_append_fcs),
                    .cf_mac_mode                  (cf_mac_mode_o),
                    .cf_mac_sa                    (cf_mac_sa),
                    .cf2tx_force_bad_fcs          (cf2tx_force_bad_fcs),
                    
                    //FIFO data
                    .app_tx_dt_in                 (tx_fifo_data_i),
                    .app_tx_fifo_empty            (tx_fifo_empty_i),
                    .app_tx_rdy                   (tx_fifo_rdy_i),
                    
                    //MII
                    .mi2tx_byte_ack               (mi2tx_byte_ack),
                    
                    .app_reset_n                    (s_reset_n), // Condor Change
                    .tx_reset_n                     (tx_reset_n),
                    .tx_clk                       (phy_tx_clk)
	      );

    toggle_sync u_rx_sts_sync (
                    . in_clk    (phy_rx_clk    ),
		    . in_rst_n  (rx_reset_n    ),
		    . in        (rx_sts_vld_o  ),
		    . out_clk   (app_clk       ),
		    . out_rst_n (app_reset_n   ),
		    . out_req   (rx_sts_vld_ss ),
		    . out_ack   (rx_sts_vld_ss )
                    );


    toggle_sync u_tx_sts_sync (
                    . in_clk    (phy_tx_clk    ),
		    . in_rst_n  (tx_reset_n    ),
		    . in        (tx_sts_vld_o  ),
		    . out_clk   (app_clk       ),
		    . out_rst_n (app_reset_n   ),
		    . out_req   (tx_sts_vld_ss ),
		    . out_ack   (tx_sts_vld_ss )
                    );



    g_cfg_mgmt #(mac_mdio_en) u_cfg_mgmt (

                 // Reg Bus Interface Signal
                      . reg_cs   (reg_cs),
                      . reg_wr   (reg_wr),
                      . reg_addr (reg_addr),
                      . reg_wdata (reg_wdata),
                      . reg_be    (reg_be),

                     // Outputs
                     . reg_rdata (reg_rdata),
                     . reg_ack   (reg_ack),

                     // Rx Status
                     . rx_sts_vld(rx_sts_vld_ss),
                     . rx_sts    ({rx_sts_large_pkt_o,
                                   rx_sts_lengthfield_err_o,
                                   rx_sts_len_mismatch_o,
                                   rx_sts_crc_err_o,
                                   rx_sts_runt_pkt_rcvd_o,
                                   rx_sts_rx_overrun_o,
                                   rx_sts_frm_length_err_o,
                                   rx_sts_rx_er_o
                                  }),

                     // Tx Status
                     . tx_sts_vld(tx_sts_vld_ss),
                     . tx_sts    (tx_sts_fifo_underrun_o),

                    // MDIO READ DATA FROM PHY
                    // CONDOR CHANGE
                    // Since MDIO is not required for the half duplex
                    // MACs the done is always tied to 1'b1
                    .md2cf_cmd_done               (md2cf_cmd_done),
                    .md2cf_status                 (md2cf_status),
                    .md2cf_data                   (md2cf_data),
                    
                    .app_clk                      (app_clk),
                    .app_reset_n                    (app_reset_n),
                    
                    //List of Outputs
                    // MII Control
                    .cf2mi_loopback_en            (cf2mi_loopback_en),
                    .cf_mac_mode                  (cf_mac_mode_o),
                    .cf_chk_rx_dfl                (cf_chk_rx_dfl),
                    .cf_silent_mode               (cf_silent_mode),
                    .cf2mi_rmii_en                (cf2mi_rmii_en_o),

                  // Config In
                    .cfg_uni_mac_mode_change_i    (cfg_uni_mac_mode_change_i),

                    //CHANNEL enable
                    .cf2tx_ch_en                  (cf2tx_ch_en),
                    //CHANNEL CONTROL TX
                    .cf2df_dfl_single             (cf2df_dfl_single),
                    .cf2df_dfl_single_rx          (cf2df_dfl_single_rx),
                    .cf2tx_pad_enable             (cf2tx_pad_enable),
                    .cf2tx_append_fcs             (cf2tx_append_fcs),
                    //CHANNEL CONTROL RX
                    .cf2rx_max_pkt_sz             (cf2rx_max_pkt_sz),
                    .cf2rx_ch_en                  (cf2rx_ch_en),
                    .cf2rx_strp_pad_en            (cf2rx_strp_pad_en),
                    .cf2rx_snd_crc                (cf2rx_snd_crc),
                    .cf2rx_runt_pkt_en            (cf2rx_runt_pkt_en),
                    .cf_mac_sa                    (cf_mac_sa),
                    .cfg_ip_sa                    (cfg_ip_sa),
                    .cfg_mac_filter               (cfg_mac_filter),
                    .cf2tx_force_bad_fcs          (cf2tx_force_bad_fcs),
                    //MDIO CONTROL & DATA
                    .cf2md_datain                 (cf2md_datain),
                    .cf2md_regad                  (cf2md_regad),
                    .cf2md_phyad                  (cf2md_phyad),
                    .cf2md_op                     (cf2md_op),
                    .cf2md_go                     (cf2md_go),

                    .rx_buf_base_addr             (rx_buf_base_addr),
                    .tx_buf_base_addr             (tx_buf_base_addr),

                    .rx_buf_qbase_addr            (rx_buf_qbase_addr),
                    .tx_buf_qbase_addr            (tx_buf_qbase_addr),

                    .tx_qcnt_inc                  (tx_qcnt_inc),
                    .tx_qcnt_dec                  (tx_qcnt_dec),
                    .tx_qcnt                      (tx_qcnt),

                    .rx_qcnt_inc                  (rx_qcnt_inc),
                    .rx_qcnt_dec                  (rx_qcnt_dec),
                    .rx_qcnt                      (rx_qcnt)


		 );

    g_mii_intf u_mii_intf(
                  // Data and Control Signals to tx_fsm and rx_fsm
                    .mi2rx_strt_rcv               (mi2rx_strt_rcv),
                    .mi2rx_rcv_vld                (mi2rx_rcv_vld),
                    .mi2rx_rx_byte                (mi2rx_rx_byte),
                    .mi2rx_end_rcv                (mi2rx_end_rcv),
                    .mi2rx_extend                 (mi2rx_extend),
                    .mi2rx_frame_err              (mi2rx_frame_err),
                    .mi2rx_end_frame              (mi2rx_end_frame),
                    .mi2rx_crs                    (mi2rx_crs),
                    .mi2tx_byte_ack               (mi2tx_byte_ack),
                    .cfg_uni_mac_mode_change      (cfg_uni_mac_mode_change_i),
                    
                    // Phy Signals 
                    .phy_tx_en                    (phy_tx_en),
                    .phy_tx_er                    (phy_tx_er),
                    .phy_txd                      (phy_txd),
                    .phy_tx_clk                   (phy_tx_clk),
                    .phy_rx_clk                   (phy_rx_clk),
                    .tx_reset_n                   (tx_reset_n),
                    .rx_reset_n                     (rx_reset_n),
                    .phy_rx_er                    (phy_rx_er),
                    .phy_rx_dv                    (phy_rx_dv),
                    .phy_rxd                      (phy_rxd),
                    .phy_crs                      (phy_crs),
                    
                    // Reset signal
                    // .app_reset                 (app_reset), 
                    .rx_sts_rx_er_reg             (rx_sts_rx_er),  
                    .app_reset_n                    (s_reset_n), 
                    
                    // Signals from Config Management
                    .cf2mi_loopback_en            (cf2mi_loopback_en),
                    .cf2mi_rmii_en                (cf2mi_rmii_en_o),
                    .cf_mac_mode                  (cf_mac_mode_o),
                    .cf_chk_rx_dfl                (cf_chk_rx_dfl),
                    .cf_silent_mode               (cf_silent_mode),
                    
                    // Signal from Application to transmit JAM
                    .df2rx_dfl_dn                 (df2rx_dfl_dn),
                    
                    // Inputs from Transmit FSM
                    .tx2mi_strt_preamble          (tx2mi_strt_preamble),
                    .tx2mi_end_transmit           (tx2mi_end_transmit),
                    .tx2mi_tx_byte                (tx2mi_tx_byte),
                    .tx_ch_en                     (tx_ch_en),
                    .mi2tx_slot_vld               ()
                    );
endmodule
