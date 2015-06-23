
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
// File       : pcie_blk_cf_arb.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--
//-- Description: CFG Arbiter. This module will send messages as triggered
//--  by the err manager, power interface, or bar hit/miss logic. It sends
//--  the messages to the Tx arbiter.
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`ifndef Tcq
  `define Tcq 1 
`endif

module pcie_blk_cf_arb
(
       // PCIe Block clock and reset

       input wire         clk,
       input wire         rst_n,

       // Device,Bus,Func#
       input        [7:0] cfg_bus_number,
       input        [4:0] cfg_device_number,
       input        [2:0] cfg_function_number,
       input       [15:0] msi_data,
       input       [31:0] msi_laddr,
       input       [31:0] msi_haddr,


       // Interface to Error Manager
       input              send_cor,
       input              send_nfl,
       input              send_ftl,
       input              send_cplt,
       input              send_cplu,
       input       [49:0] cmt_rd_hdr,
       input       [49:0] cfg_rd_hdr,
       output reg  [49:0] request_data = 0,
       output reg         grant        = 0,
       output reg         cs_is_cplu   = 0,
       output reg         cs_is_cplt   = 0,
       output reg         cs_is_cor    = 0,
       output reg         cs_is_nfl    = 0,
       output reg         cs_is_ftl    = 0,
       output reg         cs_is_pm     = 0,
       
       // Interface from Power Manager
       input              send_pmeack,
       output reg         cs_is_intr   = 0,

       input        [7:0] intr_vector,
       input        [1:0] intr_req_type,
       input              intr_req_valid,

       // Output to Tx Block (via arbiter) to generate message/UR Completions
       output reg  [63:0] cfg_arb_td   = 0,
       output reg   [7:0] cfg_arb_trem_n = 1,
       output reg         cfg_arb_tsof_n = 1,
       output reg         cfg_arb_teof_n = 1,
       output reg         cfg_arb_tsrc_rdy_n = 1,
       input              cfg_arb_tdst_rdy_n
); 

  reg     [3:0] cs_fsm;  // current state
  reg     [1:0] state;
parameter [3:0] st_reset       = 0,
                st_clear_count = 9,  // Added these three
                st_clear_send  = 10, // states 'cos counter takes 2 cycles to clear!
                st_cleared_all = 11, // and "send_***" signals are flopped; so 1 more-cycle is needed
                st_cplu_req    = 1,
                st_cplt_req    = 2,
                st_ftl_req     = 3,
                st_nfl_req     = 4,
                st_cor_req     = 5,
                st_send_pm     = 6,
                st_send_msi_32 = 7,
                st_send_msi_64 = 8,
                st_code_send_asrt = 12,
                st_code_send_d_asrt = 13;


parameter type_msg_intr = 5'b10100;

parameter           UR                                      = 1'b0;
parameter           CA                                      = 1'b1;
parameter           LOCK                                    = 1'b0;
parameter           rsvd_BYTE0                              = 1'b0;
parameter           fmt_mwr_3dwhdr_data                     = 2'b10;
parameter           fmt_mwr_4dwhdr_data                     = 2'b11; 
parameter           fmt_msg                                 = 2'b01;        // Table 2-3
parameter           fmt_cpl                                 = 2'b00;        // Table 2-3
parameter           type_mwr                                = 5'b0_0000;  
parameter           type_msg                                = 5'b1_0000;    // all msgs routed to root-complex (Table 2-11)
parameter           type_cpl                                = 5'b0_1010;    // all msgs routed to root-complex (Table 2-11)
parameter           type_cpllock                            = 5'b0_1011;
parameter           rsvd_msb_BYTE1                          = 1'b0;
parameter           tc_param                                = 3'b000;
parameter           rsvd_BYTE1                              = 4'b0000;
parameter           td                                      = 1'b0;
parameter           ep                                      = 1'b0;
parameter           attr_param                              = 2'b00;
parameter           rsvd_BYTE2                              = 2'b00;
parameter           len_98                                  = 2'b00;
parameter           len_70_BYTE3                            = 8'b0000_0000;
parameter           len_70_mwrd_BYTE3                       = 8'b0000_0001;

wire      [7:0]     completer_id_BYTE4                      = cfg_bus_number[7:0];
wire      [7:0]     completer_id_BYTE5                      = {cfg_device_number[4:0],cfg_function_number[2:0]};
parameter           compl_status_sc                         = 3'b000;
parameter           compl_status_ur                         = 3'b001;
parameter           compl_status_ca                         = 3'b100;
parameter           bcm                                     = 1'b0;
parameter           msg_code_err_cor_BYTE7                  = 8'b0011_0000; 
parameter           msg_code_err_nfl_BYTE7                  = 8'b0011_0001; 
parameter           msg_code_err_ftl_BYTE7                  = 8'b0011_0011; 
parameter           rsvd_BYTE11                             = 1'b0;
parameter           msg_code_pm_pme_BYTE7                   = 8'b0001_1000; 
parameter           msg_code_pme_to_ack_BYTE7               = 8'b0001_1011; 
parameter           type_msg_pme_to_ack                     = 5'b1_0101; 
parameter           last_dw_byte_enable_BYTE7               = 4'b0000;
parameter           first_dw_byte_enable_BYTE7              = 4'b1111;

parameter           msg_code_asrt_inta_BYTE7                = 8'b0010_0000;
parameter           msg_code_asrt_intb_BYTE7                = 8'b0010_0001;
parameter           msg_code_asrt_intc_BYTE7                = 8'b0010_0010;
parameter           msg_code_asrt_intd_BYTE7                = 8'b0010_0011;
parameter           msg_code_d_asrt_inta_BYTE7              = 8'b0010_0100;
parameter           msg_code_d_asrt_intb_BYTE7              = 8'b0010_0101;
parameter           msg_code_d_asrt_intc_BYTE7              = 8'b0010_0110;
parameter           msg_code_d_asrt_intd_BYTE7              = 8'b0010_0111;

wire     [31:0]     swizzle_msi_data                        = { intr_vector[7:0]    // Byte0
                                                               ,msi_data[15:8]   // Byte1
                                                               ,8'h0             // Byte2
                                                               ,8'h0             // Byte3
                                                               };


reg   [7:0] byte_00, byte_01, byte_02, byte_03, 
            byte_04, byte_05, byte_06, byte_07,
            byte_08, byte_09, byte_10, byte_11;

reg  [31:0] bytes_12_to_15 = 0;
reg         reg_req_pkt_tx = 0;
reg   [1:0] wait_cntr      = 0;


  always @(posedge clk) begin
    if (~rst_n) begin
      cs_fsm            <= #`Tcq 4'b0000;
      request_data      <= #`Tcq 0;
      cs_is_cplu        <= #`Tcq 1'b0;
      cs_is_cplt        <= #`Tcq 1'b0;
      cs_is_cor         <= #`Tcq 1'b0;
      cs_is_nfl         <= #`Tcq 1'b0;
      cs_is_ftl         <= #`Tcq 1'b0;
      cs_is_pm          <= #`Tcq 1'b0;
      cs_is_intr        <= #`Tcq 1'b0;
      byte_00           <= #`Tcq 0;
      byte_01           <= #`Tcq 0;
      byte_02           <= #`Tcq 0;
      byte_03           <= #`Tcq 0;
      byte_04           <= #`Tcq 0;
      byte_05           <= #`Tcq 0;
      byte_06           <= #`Tcq 0;
      byte_07           <= #`Tcq 0;
      byte_08           <= #`Tcq 0;
      byte_09           <= #`Tcq 0;
      byte_10           <= #`Tcq 0;
      byte_11           <= #`Tcq 0;
      bytes_12_to_15    <= #`Tcq 0;
      reg_req_pkt_tx    <= #`Tcq 1'b0;
    end
    else begin
      case (cs_fsm) // synthesis full_case parallel_case
        st_reset: begin
            if (send_cplu)
              cs_fsm            <= #`Tcq st_cplu_req;
            else if (send_cplt)
              cs_fsm            <= #`Tcq st_cplt_req;
            else if (send_ftl)
              cs_fsm            <= #`Tcq st_ftl_req;
            else if (send_nfl)
              cs_fsm            <= #`Tcq st_nfl_req;
            else if (send_cor)
              cs_fsm            <= #`Tcq st_cor_req;
            else if (send_pmeack)
              cs_fsm            <= #`Tcq st_send_pm;
            else if (intr_req_valid)
            begin
               if (intr_req_type == 2'b00) 
                  cs_fsm            <= #`Tcq st_code_send_asrt;
               else if (intr_req_type == 2'b01)
                  cs_fsm            <= #`Tcq st_code_send_d_asrt;
               else if (intr_req_type == 2'b10)
                  cs_fsm            <= #`Tcq st_send_msi_32;
               else if (intr_req_type == 2'b11)
                  cs_fsm            <= #`Tcq st_send_msi_64;
            end
            else
              cs_fsm            <= #`Tcq st_reset;
            request_data      <= #`Tcq 0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            reg_req_pkt_tx    <= #`Tcq 1'b0;
        end

        st_cplu_req: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_cplu_req;
            request_data      <= #`Tcq cfg_rd_hdr;
            cs_is_cplu        <= #`Tcq 1'b1;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            ////
            if (cfg_rd_hdr[49] == LOCK) begin
              byte_00           <= #`Tcq {rsvd_BYTE0,fmt_cpl,type_cpllock};
            end else begin
              byte_00           <= #`Tcq {rsvd_BYTE0,fmt_cpl,type_cpl};
            end
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            //byte_07           <= #`Tcq {byte_count_cpln_BYTE7};
            byte_07           <= #`Tcq {cfg_rd_hdr[36:29]};
            //byte_08           <= #`Tcq {msg_requester_id_BYTE4};
            byte_08           <= #`Tcq {cfg_rd_hdr[23:16]};
            //byte_09           <= #`Tcq {msg_requester_id_BYTE5};
            byte_09           <= #`Tcq {cfg_rd_hdr[15:8]};
            byte_10           <= #`Tcq cfg_rd_hdr[7:0];
            //byte_11           <= #`Tcq {rsvd_BYTE11,lower_address_cpln};
            byte_11           <= #`Tcq {rsvd_BYTE11,cfg_rd_hdr[47:41]};
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
            if (cfg_rd_hdr[48] == UR) begin
              //byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_ur,rsvd_BYTE1};
              byte_01           <= #`Tcq {rsvd_msb_BYTE1,cfg_rd_hdr[28:26],rsvd_BYTE1};
              //byte_02           <= #`Tcq {td,ep,attr_ur,rsvd_BYTE2,len_98};
              byte_02           <= #`Tcq {td,ep,cfg_rd_hdr[25:24],rsvd_BYTE2,len_98};
              //byte_06           <= #`Tcq {compl_status_ur,bcm,byte_count_cpln_BYTE6}; 
              byte_06           <= #`Tcq {compl_status_ur,bcm,cfg_rd_hdr[40:37]}; 
            end else begin     // CA
              //byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_ur,rsvd_BYTE1};
              byte_01           <= #`Tcq {rsvd_msb_BYTE1,cfg_rd_hdr[28:26],rsvd_BYTE1};
              //byte_02           <= #`Tcq {td,ep,attr_ur,rsvd_BYTE2,len_98};
              byte_02           <= #`Tcq {td,ep,cfg_rd_hdr[25:24],rsvd_BYTE2,len_98};
              //byte_06           <= #`Tcq {compl_status_ca,bcm,byte_count_cpln_BYTE6}; 
              byte_06           <= #`Tcq {compl_status_ca,bcm,cfg_rd_hdr[40:37]}; 
            end
        end
        st_cplt_req: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_cplt_req;
            request_data      <= #`Tcq cmt_rd_hdr;
            cs_is_cplt        <= #`Tcq 1'b1;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            ////
            if (cmt_rd_hdr[49] == LOCK) begin
              byte_00           <= #`Tcq {rsvd_BYTE0,fmt_cpl,type_cpllock};
            end else begin
              byte_00           <= #`Tcq {rsvd_BYTE0,fmt_cpl,type_cpl};
            end
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_07           <= #`Tcq {cmt_rd_hdr[36:29]};
            byte_08           <= #`Tcq {cmt_rd_hdr[23:16]};
            byte_09           <= #`Tcq {cmt_rd_hdr[15:8]};
            byte_10           <= #`Tcq cmt_rd_hdr[7:0];
            byte_11           <= #`Tcq {rsvd_BYTE11,cmt_rd_hdr[47:41]};
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
            if (cmt_rd_hdr[48] == UR) begin
              byte_01           <= #`Tcq {rsvd_msb_BYTE1,cmt_rd_hdr[28:26],rsvd_BYTE1};
              byte_02           <= #`Tcq {td,ep,cmt_rd_hdr[25:24],rsvd_BYTE2,len_98};
              byte_06           <= #`Tcq {compl_status_ur,bcm,cmt_rd_hdr[40:37]}; 
            end else begin     // CA
              byte_01           <= #`Tcq {rsvd_msb_BYTE1,cmt_rd_hdr[28:26],rsvd_BYTE1};
              byte_02           <= #`Tcq {td,ep,cmt_rd_hdr[25:24],rsvd_BYTE2,len_98};
              byte_06           <= #`Tcq {compl_status_ca,bcm,cmt_rd_hdr[40:37]}; 
            end
        end
        st_ftl_req:  begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_ftl_req;
            request_data      <= #`Tcq 0;
            cs_is_ftl         <= #`Tcq 1'b1;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            ////
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_msg,type_msg};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_07           <= #`Tcq {msg_code_err_ftl_BYTE7};
            byte_08           <= #`Tcq 0;
            byte_09           <= #`Tcq 0;
            byte_10           <= #`Tcq 0;
            byte_11           <= #`Tcq 0;
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
        end
        st_nfl_req:  begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_nfl_req;
            request_data      <= #`Tcq 0;
            cs_is_nfl         <= #`Tcq 1'b1;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            ////
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_msg,type_msg};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_07           <= #`Tcq {msg_code_err_nfl_BYTE7};
            byte_08           <= #`Tcq 0;
            byte_09           <= #`Tcq 0;
            byte_10           <= #`Tcq 0;
            byte_11           <= #`Tcq 0;
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
        end
        st_cor_req:  begin   
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_cor_req;
            request_data      <= #`Tcq 0;
            cs_is_cor         <= #`Tcq 1'b1;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            ////
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_msg,type_msg};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_07           <= #`Tcq {msg_code_err_cor_BYTE7};
            byte_08           <= #`Tcq 0;
            byte_09           <= #`Tcq 0;
            byte_10           <= #`Tcq 0;
            byte_11           <= #`Tcq 0;
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
        end
        st_send_pm: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_send_pm;
            request_data      <= #`Tcq 0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b1;
            cs_is_intr        <= #`Tcq 1'b0;
            ////
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_08           <= #`Tcq 0;
            byte_09           <= #`Tcq 0;
            byte_10           <= #`Tcq 0;
            byte_11           <= #`Tcq 0;
            bytes_12_to_15    <= #`Tcq 0;
          //if (pme_ack_bar) begin
          //  byte_07           <= #`Tcq {msg_code_pm_pme_BYTE7};
          //  byte_00           <= #`Tcq {rsvd_BYTE0,fmt_msg,type_msg};
          //end
          //else begin
            byte_07           <= #`Tcq {msg_code_pme_to_ack_BYTE7};
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_msg,type_msg_pme_to_ack};
          //end
            reg_req_pkt_tx    <= #`Tcq 1'b1;
        end


        st_code_send_asrt: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_code_send_asrt;
            request_data      <= #`Tcq 0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b1;
            ////
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_msg,type_msg_intr};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_08           <= #`Tcq 0;
            byte_09           <= #`Tcq 0;
            byte_10           <= #`Tcq 0;
            byte_11           <= #`Tcq 0;
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
          case (intr_vector[1:0])  // synthesis full_case parallel_case
            2'b00: byte_07          <= #`Tcq {msg_code_asrt_inta_BYTE7};
            2'b01: byte_07          <= #`Tcq {msg_code_asrt_intb_BYTE7};
            2'b10: byte_07          <= #`Tcq {msg_code_asrt_intc_BYTE7};
            2'b11: byte_07          <= #`Tcq {msg_code_asrt_intd_BYTE7};
          endcase
        end

        st_code_send_d_asrt: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_code_send_d_asrt;
            request_data      <= #`Tcq 0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b1;
            ////
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_msg,type_msg_intr};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_08           <= #`Tcq 0;
            byte_09           <= #`Tcq 0;
            byte_10           <= #`Tcq 0;
            byte_11           <= #`Tcq 0;
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
          case (intr_vector[1:0])  // synthesis full_case parallel_case
            2'b00: byte_07          <= #`Tcq {msg_code_d_asrt_inta_BYTE7};
            2'b01: byte_07          <= #`Tcq {msg_code_d_asrt_intb_BYTE7};
            2'b10: byte_07          <= #`Tcq {msg_code_d_asrt_intc_BYTE7};
            2'b11: byte_07          <= #`Tcq {msg_code_d_asrt_intd_BYTE7};
          endcase
        end

        st_send_msi_32: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_send_msi_32;
            request_data      <= #`Tcq 0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b1;
            ////
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_mwr_3dwhdr_data,type_mwr};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_mwrd_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_07           <= #`Tcq {last_dw_byte_enable_BYTE7,first_dw_byte_enable_BYTE7};
            byte_08           <= #`Tcq msi_laddr[31:24];
            byte_09           <= #`Tcq msi_laddr[23:16];
            byte_10           <= #`Tcq msi_laddr[15:08];
            byte_11           <= #`Tcq {msi_laddr[07:02],2'b00};
            bytes_12_to_15    <= #`Tcq swizzle_msi_data;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
        end      
        st_send_msi_64: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_send_msi_64;
            request_data      <= #`Tcq 0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b1;
            ////
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_mwr_4dwhdr_data,type_mwr};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_mwrd_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_07           <= #`Tcq {last_dw_byte_enable_BYTE7,first_dw_byte_enable_BYTE7};
            byte_08           <= #`Tcq msi_haddr[31:24];
            byte_09           <= #`Tcq msi_haddr[23:16];
            byte_10           <= #`Tcq msi_haddr[15:08];
            byte_11           <= #`Tcq msi_haddr[07:00];
            bytes_12_to_15    <= #`Tcq {msi_laddr[31:2],2'b00};
            reg_req_pkt_tx    <= #`Tcq 1'b1;
        end      
        st_clear_count: begin
            cs_fsm            <= #`Tcq st_clear_send;
            request_data      <= #`Tcq 0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            reg_req_pkt_tx    <= #`Tcq 1'b0;
        end
        st_clear_send: begin
            cs_fsm            <= #`Tcq st_cleared_all;
            request_data      <= #`Tcq 0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            reg_req_pkt_tx    <= #`Tcq 1'b0;
        end
        st_cleared_all: begin
            cs_fsm            <= #`Tcq st_reset;
            request_data      <= #`Tcq 0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            reg_req_pkt_tx    <= #`Tcq 1'b0;
        end
        default: begin
            cs_fsm            <= #`Tcq st_reset;
            request_data      <= #`Tcq 0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            reg_req_pkt_tx    <= #`Tcq 1'b0;
        end
      endcase
    end
  end


  wire [159:0] tlp_data= {swizzle_msi_data,
                          bytes_12_to_15,
                          byte_08,byte_09,byte_10,byte_11,
                          byte_04,byte_05,byte_06,byte_07,
                          byte_00,byte_01,byte_02,byte_03};
  
  wire pkt_3dw = (tlp_data[30:29]==2'b00);  // fmt type is pkt_3dw tlp 
  wire pkt_5dw = (tlp_data[30:29]==2'b11);  // fmt type is pkt_5dw tlp 
  
  parameter TX_IDLE     = 2'b00;
  parameter TX_DW1      = 2'b01;
  parameter TX_DW3      = 2'b10;
  parameter SEND_GRANT  = 2'b11;

  
  always @(posedge clk)
  begin
     if (~rst_n) begin
        cfg_arb_tsof_n  <= #`Tcq 1;
        cfg_arb_teof_n  <= #`Tcq 1;
        cfg_arb_td      <= #`Tcq 64'h0000_0000;
        cfg_arb_trem_n  <= #`Tcq 8'hff;
        cfg_arb_tsrc_rdy_n <= #`Tcq 1;
        grant           <= #`Tcq 0; 
        state           <= #`Tcq TX_IDLE;
     end
     else
     case (state) //synthesis full_case parallel_case  
        TX_IDLE : begin
                     grant             <= #`Tcq 0; 
                     cfg_arb_td[31:0]  <= #`Tcq tlp_data[63:32]; 
                     cfg_arb_td[63:32] <= #`Tcq tlp_data[31:0]; 
                     cfg_arb_teof_n    <= #`Tcq 1;
                     cfg_arb_trem_n    <= #`Tcq 8'h00;
                     if (reg_req_pkt_tx && (~|wait_cntr)) begin
                        cfg_arb_tsrc_rdy_n   <= #`Tcq 0;  
                        cfg_arb_tsof_n    <= #`Tcq 0;
                     end
                     else begin
                        cfg_arb_tsrc_rdy_n   <= #`Tcq 1;  
                        cfg_arb_tsof_n    <= #`Tcq 1;
                     end
                     if (reg_req_pkt_tx && (~|wait_cntr)) begin
                        state        <= #`Tcq TX_DW1;
                     end 
                  end
        TX_DW1  : begin
                     cfg_arb_tsrc_rdy_n <= #`Tcq 0;  
                     cfg_arb_trem_n     <= #`Tcq pkt_3dw ? 8'h0f : 8'h00 ;
                     if (!cfg_arb_tdst_rdy_n) begin
                        cfg_arb_td[31:0]  <= #`Tcq tlp_data[127:96]; 
                        cfg_arb_td[63:32] <= #`Tcq tlp_data[95:64]; 
                        cfg_arb_tsof_n    <= #`Tcq 1;
                        cfg_arb_teof_n    <= #`Tcq pkt_5dw;
                        state             <= #`Tcq pkt_5dw ? TX_DW3 : SEND_GRANT;
                        grant             <= #`Tcq 0;
                     end
                     else begin
                        cfg_arb_td[31:0]  <= #`Tcq tlp_data[63:32]; 
                        cfg_arb_td[63:32] <= #`Tcq tlp_data[31:0]; 
                        cfg_arb_tsof_n    <= #`Tcq 0;
                        cfg_arb_teof_n    <= #`Tcq 1;
                        state             <= #`Tcq TX_DW1;
                        grant             <= #`Tcq 0;
                     end
                  end
        TX_DW3  : begin
                     cfg_arb_tsrc_rdy_n <= #`Tcq 0;  
                     cfg_arb_trem_n     <= #`Tcq 8'h0f;
                     if (!cfg_arb_tdst_rdy_n) begin
                        cfg_arb_td[31:0]  <= #`Tcq 32'h0; 
                        cfg_arb_td[63:32] <= #`Tcq tlp_data[159:128]; 
                        cfg_arb_tsof_n    <= #`Tcq 1;
                        cfg_arb_teof_n    <= #`Tcq 0;
                        state             <= #`Tcq SEND_GRANT;
                        grant             <= #`Tcq 0;
                     end
                     else begin
                        cfg_arb_td[31:0]  <= #`Tcq tlp_data[127:96]; 
                        cfg_arb_td[63:32] <= #`Tcq tlp_data[95:64]; 
                        cfg_arb_tsof_n    <= #`Tcq 1;
                        cfg_arb_teof_n    <= #`Tcq 1;
                        state             <= #`Tcq TX_DW3;
                        grant             <= #`Tcq 0;
                     end
                  end
    SEND_GRANT  : begin
                     if (!cfg_arb_tdst_rdy_n) begin
                        cfg_arb_tsrc_rdy_n<= #`Tcq 1;  
                        cfg_arb_tsof_n    <= #`Tcq 1;
                        cfg_arb_teof_n    <= #`Tcq 1;
                        state             <= #`Tcq TX_IDLE;
                        grant             <= #`Tcq 1;
                     end
                     else begin
                        cfg_arb_tsrc_rdy_n<= #`Tcq 0;  
                        cfg_arb_tsof_n    <= #`Tcq 1;
                        cfg_arb_teof_n    <= #`Tcq 0;
                        state             <= #`Tcq SEND_GRANT;
                        grant             <= #`Tcq 0;
                     end
                  end
     endcase
  end 

  always @(posedge clk)
  begin
     if (~rst_n) begin
       wait_cntr <= #`Tcq 0;
     end else if (state == SEND_GRANT) begin
       wait_cntr <= #`Tcq 2'b10;
     end else if (|wait_cntr) begin
       wait_cntr <= #`Tcq wait_cntr - 1;
     end
  end

endmodule // pcie_blk_cf_arb
