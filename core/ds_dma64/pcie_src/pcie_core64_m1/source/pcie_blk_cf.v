
//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : V5-Block Plus for PCI Express
// File       : pcie_blk_cf.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--
//-- Description: PCIe Block Configuration Interface
//--
//--             
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`ifndef Tcq
  `define Tcq 1 
`endif

module pcie_blk_cf
(
       // PCIe Block clock and reset

       input wire         clk,
       input wire         rst_n,

       // PCIe Transaction Link Up

       output             trn_lnk_up_n,

       // PCIe Block Misc Inputs

       input wire         mac_link_up,
       input wire   [3:0] mac_negotiated_link_width,
       input wire   [7:0] llk_tc_status,
 
       // PCIe Block Cfg Interface

       input wire         io_space_enable,
       input wire         mem_space_enable,
       input wire         bus_master_enable,
       input wire         parity_error_response,
       input wire         serr_enable,
       input wire         msi_enable,
       input wire  [12:0] completer_id,
       input wire   [2:0] max_read_request_size,
       input wire   [2:0] max_payload_size,
    
       output             legacy_int_request,
       output             transactions_pending,

       output       [3:0] msi_request,
       input              cfg_interrupt_assert_n, // select between assert 
					// and deassert message type in legacy
					// mode
       input       [7:0]  cfg_interrupt_di, 
       output      [2:0]  cfg_interrupt_mmenable, //number of MSI vectors avail
						  // from conviguration
       output             cfg_interrupt_msienable, // indiacates msi or legacy
						// enabled 
       output      [7:0]  cfg_interrupt_do, 	// indiacates lowest 8bits of
       input              msi_8bit_en,

       // PCIe Block Management Interface

       output wire [10:0] mgmt_addr,
       output wire        mgmt_wren,
       output wire        mgmt_rden,
       output wire [31:0] mgmt_wdata,
       output wire [3:0]  mgmt_bwren,
       input  wire [31:0] mgmt_rdata,
       input  wire [16:0] mgmt_pso,
       //// These signals go to mgmt block to implement a workaround
       input  wire [63:0] llk_rx_data_d,
       input  wire        llk_rx_src_rdy_n,
       input  wire        l0_stats_cfg_received,
       input  wire        l0_stats_cfg_transmitted,

       // PCIe Soft Macro Cfg Interface
       
       output wire [31:0] cfg_do,
       input wire  [31:0] cfg_di,
       input wire  [63:0] cfg_dsn,
       input wire   [3:0] cfg_byte_en_n,
       input wire  [11:0] cfg_dwaddr,
       output wire        cfg_rd_wr_done_n,
       input wire         cfg_wr_en_n,
       input wire         cfg_rd_en_n,
       input wire         cfg_err_cor_n,
       input wire         cfg_err_ur_n,
       input wire         cfg_err_ecrc_n,
       input wire         cfg_err_cpl_timeout_n,
       input wire         cfg_err_cpl_abort_n,
       input wire         cfg_err_cpl_unexpect_n,
       input wire         cfg_err_posted_n,
       input wire         cfg_err_locked_n,
       input wire         cfg_interrupt_n,
       output wire        cfg_interrupt_rdy_n,
       input wire         cfg_turnoff_ok_n,
       output wire        cfg_to_turnoff_n,
       input wire         cfg_pm_wake_n,
       input wire  [47:0] cfg_err_tlp_cpl_header,
       output wire        cfg_err_cpl_rdy_n,
       input wire         cfg_trn_pending_n,
       output wire [31:0] cfg_rx_bar0,
       output wire [31:0] cfg_rx_bar1,
       output wire [31:0] cfg_rx_bar2,
       output wire [31:0] cfg_rx_bar3,
       output wire [31:0] cfg_rx_bar4,
       output wire [31:0] cfg_rx_bar5,
       output wire [31:0] cfg_rx_xrom,
       output wire [15:0] cfg_status,
       output wire [15:0] cfg_command,
       output wire [15:0] cfg_dstatus,
       output wire [15:0] cfg_dcommand,
       output wire [15:0] cfg_lstatus,
       output wire [15:0] cfg_lcommand,
       output wire [31:0] cfg_pmcsr,
       output wire [31:0] cfg_dcap,
       output wire  [7:0] cfg_bus_number,
       output wire  [4:0] cfg_device_number,
       output wire  [2:0] cfg_function_number,
       output wire  [2:0] cfg_pcie_link_state_n,

       input              rx_err_cpl_ep_n, //Rx Completion
       input              tx_err_wr_ep_n,  //Tx Write
       input              rx_err_ep_n,     //Any
       input              rx_err_tlp_poisoned_n,
       input              rx_err_cpl_abort_n,
       input              rx_err_cpl_ur_n,
       input              rx_err_tlp_ur_n,
       input              rx_err_tlp_ur_lock_n,
       input              rx_err_tlp_p_cpl_n,
       input              rx_err_tlp_malformed_n,
       input       [47:0] rx_err_tlp_hdr,

       output wire [63:0] cfg_arb_td,
       output wire  [7:0] cfg_arb_trem_n,
       output wire        cfg_arb_tsof_n,
       output wire        cfg_arb_teof_n,
       output wire        cfg_arb_tsrc_rdy_n,
       input              cfg_arb_tdst_rdy_n,

       input        [6:0] l0_dll_error_vector,
       input        [1:0] l0_rx_mac_link_error,
       output wire        l0_set_unsupported_request_other_error,
       output wire        l0_set_detected_fatal_error,
       output wire        l0_set_detected_nonfatal_error,
       output wire        l0_set_detected_corr_error,
       output wire        l0_set_user_system_error,
       output wire        l0_set_user_master_data_parity,
       output wire        l0_set_user_signaled_target_abort,
       output wire        l0_set_user_received_target_abort,
       output wire        l0_set_user_received_master_abort,
       output wire        l0_set_user_detected_parity_error,

       input        [3:0] l0_ltssm_state,
       input              l0_pwr_turn_off_req,
       output wire        l0_pme_req_in,
       input              l0_pme_ack

); 


 assign transactions_pending = ~cfg_trn_pending_n;

 assign cfg_pcie_link_state_n = {~(l0_ltssm_state == 4'b0110),  //L1
                                 ~(l0_ltssm_state == 4'b0101),  //L0s
                                 ~(l0_ltssm_state == 4'b0100)}; //L0

 wire  [49:0] cmt_rd_hdr;
 wire  [49:0] cfg_rd_hdr;
 wire  [49:0] request_data;
 wire  [15:0] cfg_msgctrl;
 wire  [31:0] cfg_msgladdr;
 wire  [31:0] cfg_msguaddr;
 wire  [15:0] cfg_msgdata;
 wire         send_cor;
 wire         send_nfl;
 wire         send_ftl;
 wire         send_cplt;
 wire         send_cplu;
 wire         send_pmeack;
 wire         send_intr32;
 wire         send_intr64;
 wire         grant;
 wire         cs_is_cplu;
 wire         cs_is_cplt;
 wire         cs_is_cor;
 wire         cs_is_nfl;
 wire         cs_is_ftl;
 wire         cs_is_pm;
 wire         cs_is_intr;
 reg   [12:0] completer_id_reg = 0;
 reg          llk_tc_status_reg;          
 wire  [31:0] mis_laddr;
 wire  [31:0] mis_haddr;

   wire [7:0] intr_vector;
   wire [1:0] intr_req_type;

always @(posedge clk) begin
  completer_id_reg <= #`Tcq completer_id;
  llk_tc_status_reg <= #`Tcq llk_tc_status[0];
end

assign trn_lnk_up_n = ~llk_tc_status_reg;


pcie_blk_cf_mgmt management_interface
(
       .clk                 ( clk ),
       .rst_n               ( rst_n ),
       .completer_id        ( completer_id_reg ),
       .mgmt_addr           ( mgmt_addr ),
       .mgmt_wren           ( mgmt_wren ),
       .mgmt_rden           ( mgmt_rden ),
       .mgmt_wdata          ( mgmt_wdata ),
       .mgmt_bwren          ( mgmt_bwren ),
       .mgmt_rdata          ( mgmt_rdata ),
       .mgmt_pso            ( mgmt_pso ),
       .cfg_dsn             ( cfg_dsn ),
       .cfg_do              ( cfg_do ),
       .cfg_rd_wr_done_n    ( cfg_rd_wr_done_n ),
       .cfg_dwaddr          ( cfg_dwaddr ),
       .cfg_rd_en_n         ( cfg_rd_en_n ),
       .cfg_rx_bar0         ( cfg_rx_bar0 ),
       .cfg_rx_bar1         ( cfg_rx_bar1 ),
       .cfg_rx_bar2         ( cfg_rx_bar2 ),
       .cfg_rx_bar3         ( cfg_rx_bar3 ),
       .cfg_rx_bar4         ( cfg_rx_bar4 ),
       .cfg_rx_bar5         ( cfg_rx_bar5 ),
       .cfg_rx_xrom         ( cfg_rx_xrom ),
       .cfg_status          ( cfg_status ),
       .cfg_command         ( cfg_command ),
       .cfg_dstatus         ( cfg_dstatus ),
       .cfg_dcommand        ( cfg_dcommand ),
       .cfg_lstatus         ( cfg_lstatus ),
       .cfg_lcommand        ( cfg_lcommand ),
       .cfg_pmcsr           ( cfg_pmcsr ),
       .cfg_dcap            ( cfg_dcap ),
       .cfg_msgctrl         ( cfg_msgctrl ),
       .cfg_msgladdr        ( cfg_msgladdr ),
       .cfg_msguaddr        ( cfg_msguaddr ),
       .cfg_msgdata         ( cfg_msgdata ),
       .cfg_bus_number      ( cfg_bus_number ),
       .cfg_device_number   ( cfg_device_number ),
       .cfg_function_number ( cfg_function_number ),
       //// These signals go to mgmt block to implement a workaround
       .llk_rx_data_d            ( llk_rx_data_d ),
       .llk_rx_src_rdy_n         ( llk_rx_src_rdy_n ),
       .l0_dll_error_vector      ( l0_dll_error_vector ),
       .l0_rx_mac_link_error     ( l0_rx_mac_link_error ),
       .l0_stats_cfg_received    ( l0_stats_cfg_received ),
       .l0_stats_cfg_transmitted ( l0_stats_cfg_transmitted ),
       .l0_set_unsupported_request_other_error( l0_set_unsupported_request_other_error ),
       .l0_set_detected_corr_error            ( l0_set_detected_corr_error )

); 

pcie_blk_cf_err error_manager
(
       .clk                    ( clk ),
       .rst_n                  ( rst_n ),
       .cfg_err_cor_n          ( cfg_err_cor_n ),
       .cfg_err_ur_n           ( cfg_err_ur_n ),
       .cfg_err_ecrc_n         ( cfg_err_ecrc_n ),
       .cfg_err_cpl_timeout_n  ( cfg_err_cpl_timeout_n ),
       .cfg_err_cpl_abort_n    ( cfg_err_cpl_abort_n ),
       .cfg_err_cpl_unexpect_n ( cfg_err_cpl_unexpect_n ),
       .cfg_err_posted_n       ( cfg_err_posted_n ),
       .cfg_err_locked_n       ( cfg_err_locked_n ),
       .cfg_err_tlp_cpl_header ( cfg_err_tlp_cpl_header ),
       .cfg_err_cpl_rdy_n      ( cfg_err_cpl_rdy_n ),
       .rx_err_cpl_ep_n        ( rx_err_cpl_ep_n ), 
       .tx_err_wr_ep_n         ( tx_err_wr_ep_n ),
       .rx_err_ep_n            ( rx_err_ep_n ),
       .rx_err_tlp_poisoned_n  ( rx_err_tlp_poisoned_n ),
       .rx_err_cpl_abort_n     ( rx_err_cpl_abort_n ),
       .rx_err_cpl_ur_n        ( rx_err_cpl_ur_n ),
       .rx_err_tlp_ur_n        ( rx_err_tlp_ur_n ),
       .rx_err_tlp_ur_lock_n   ( rx_err_tlp_ur_lock_n ),
       .rx_err_tlp_p_cpl_n     ( rx_err_tlp_p_cpl_n ),
       .rx_err_tlp_malformed_n ( rx_err_tlp_malformed_n ),
       .rx_err_tlp_hdr         ( rx_err_tlp_hdr ),
       .send_cor               ( send_cor ),
       .send_nfl               ( send_nfl ),
       .send_ftl               ( send_ftl ),
       .send_cplt              ( send_cplt ),
       .send_cplu              ( send_cplu ),
       .cmt_rd_hdr             ( cmt_rd_hdr ),
       .cfg_rd_hdr             ( cfg_rd_hdr ),
       .request_data           ( request_data ),
       .grant                  ( grant ),
       .cs_is_cplu             ( cs_is_cplu ),
       .cs_is_cplt             ( cs_is_cplt ),
       .cs_is_cor              ( cs_is_cor ),
       .cs_is_nfl              ( cs_is_nfl ),
       .cs_is_ftl              ( cs_is_ftl ),
       .l0_dll_error_vector               ( l0_dll_error_vector ),
       .l0_rx_mac_link_error              ( l0_rx_mac_link_error ),
       .l0_mac_link_up                    ( mac_link_up ),
       .l0_set_unsupported_request_other_error( l0_set_unsupported_request_other_error ),
       .l0_set_detected_fatal_error       ( l0_set_detected_fatal_error ),
       .l0_set_detected_nonfatal_error    ( l0_set_detected_nonfatal_error ),
       .l0_set_detected_corr_error        ( l0_set_detected_corr_error ),
       .l0_set_user_system_error          ( l0_set_user_system_error ),
       .l0_set_user_master_data_parity    ( l0_set_user_master_data_parity ),
       .l0_set_user_signaled_target_abort ( l0_set_user_signaled_target_abort ),
       .l0_set_user_received_target_abort ( l0_set_user_received_target_abort ),
       .l0_set_user_received_master_abort ( l0_set_user_received_master_abort ),
       .l0_set_user_detected_parity_error ( l0_set_user_detected_parity_error ),
       .cfg_dcommand           ( cfg_dcommand ),
       .cfg_command            ( cfg_command ),
       .serr_en                ( serr_enable )
); 

pcie_blk_cf_arb cfg_arb
(
       .clk                    ( clk ),
       .rst_n                  ( rst_n ),
       .cfg_bus_number         ( cfg_bus_number ),
       .cfg_device_number      ( cfg_device_number ),
       .cfg_function_number    ( cfg_function_number ),
       .msi_data               ( cfg_msgdata ),
       .msi_laddr              ( cfg_msgladdr ),
       .msi_haddr              ( cfg_msguaddr ),
       .send_cor               ( send_cor ),
       .send_nfl               ( send_nfl ),
       .send_ftl               ( send_ftl ),
       .send_cplt              ( send_cplt ),
       .send_cplu              ( send_cplu ),
       .send_pmeack            ( send_pmeack ),
       .cmt_rd_hdr             ( cmt_rd_hdr ),
       .cfg_rd_hdr             ( cfg_rd_hdr ),
       .request_data           ( request_data ),
       .grant                  ( grant ),
       .cs_is_cplu             ( cs_is_cplu ),
       .cs_is_cplt             ( cs_is_cplt ),
       .cs_is_cor              ( cs_is_cor ),
       .cs_is_nfl              ( cs_is_nfl ),
       .cs_is_ftl              ( cs_is_ftl ),
       .cs_is_pm               ( cs_is_pm ),
       .cs_is_intr             ( cs_is_intr ),
       .intr_vector( intr_vector ),
       .intr_req_type( intr_req_type ),
       .intr_req_valid         ( intr_req_valid ),
       .cfg_arb_td             ( cfg_arb_td ),
       .cfg_arb_trem_n         ( cfg_arb_trem_n ),
       .cfg_arb_tsof_n         ( cfg_arb_tsof_n ),
       .cfg_arb_teof_n         ( cfg_arb_teof_n ),
       .cfg_arb_tsrc_rdy_n     ( cfg_arb_tsrc_rdy_n ),
       .cfg_arb_tdst_rdy_n     ( cfg_arb_tdst_rdy_n )
); 

pcie_blk_cf_pwr pwr_interface
(
       .clk                ( clk ),
       .rst_n              ( rst_n ),
       .cfg_turnoff_ok_n   ( cfg_turnoff_ok_n ),
       .cfg_to_turnoff_n   ( cfg_to_turnoff_n ),
       .cfg_pm_wake_n      ( cfg_pm_wake_n ),
       .send_pmeack        ( send_pmeack ),
       .cs_is_pm           ( cs_is_pm ),
       .grant              ( grant ),
       .l0_pwr_turn_off_req ( l0_pwr_turn_off_req ),
       .l0_pme_req_in      ( l0_pme_req_in ),
       .l0_pme_ack         ( l0_pme_ack )
); 

pcie_soft_cf_int interrupt_interface
(
       // Clock & Reset
       .clk                 ( clk ),                               // I
       .rst_n               ( rst_n ),                             // I
       // Interface to Arbitor
       .cs_is_intr          ( cs_is_intr ),
       .grant               ( grant ),
       .cfg_msguaddr        ( cfg_msguaddr ),
       // PCIe Block Interrupt Ports
       .msi_enable          ( msi_enable ),                        // I
       .msi_request         ( msi_request ),                       // O[3:0]
       .legacy_int_request  ( legacy_int_request ),                // O
       // LocalLink Interrupt Ports
       .cfg_interrupt_n     ( cfg_interrupt_n ),                   // I
       .cfg_interrupt_rdy_n ( cfg_interrupt_rdy_n ),                // O

       .cfg_interrupt_assert_n(cfg_interrupt_assert_n),            // I
       .cfg_interrupt_di(cfg_interrupt_di),                        // I[7:0]

       .cfg_interrupt_mmenable(cfg_interrupt_mmenable),            // O[2:0]
       .cfg_interrupt_do(cfg_interrupt_do),                        // O[7:0]
       .cfg_interrupt_msienable(cfg_interrupt_msienable),          // O
       .intr_vector(intr_vector),                                  // O[7:0]
       .msi_8bit_en(msi_8bit_en),                                     // I
       .msi_laddr(cfg_msgladdr),                                   // I[31:0]
       .msi_haddr(cfg_msguaddr),                                   // I[31:0]
 
       .cfg_command(cfg_command),
       .cfg_msgctrl(cfg_msgctrl),
       .cfg_msgdata(cfg_msgdata),

       .signaledint(signaledint),
       .intr_req_valid(intr_req_valid),
       .intr_req_type(intr_req_type)


);

endmodule // pcie_blk_cf
