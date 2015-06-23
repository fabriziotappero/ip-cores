
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
// File       : pcie_blk_cf_err.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--
//-- Description: Error Manager. This module will generate error messages to be
//--  sent by the Tx block, and it will set appropriate error bits in register
//--  space.
//--
//--------------------------------------------------------------------------------

`ifndef Tcq
  `define Tcq 1
`endif

`timescale 1ns/1ns

module pcie_blk_cf_err
(
       // PCIe Block clock and reset

       input wire         clk,
       input wire         rst_n,

       // PCIe Soft Macro Cfg Interface
       
       input              cfg_err_cor_n,
       input              cfg_err_ur_n,
       input              cfg_err_ecrc_n,
       input              cfg_err_cpl_timeout_n,
       input              cfg_err_cpl_abort_n,
       input              cfg_err_cpl_unexpect_n,
       input              cfg_err_posted_n,
       input              cfg_err_locked_n,
       input       [47:0] cfg_err_tlp_cpl_header,
       output             cfg_err_cpl_rdy_n,

       // Rx/Tx indicates Poisoned TLP
       input              rx_err_cpl_ep_n, //Rx Completion
       input              tx_err_wr_ep_n,  //Tx Write
       input              rx_err_ep_n,     //Any
       input              rx_err_tlp_poisoned_n,

       // Rx indicates Competion Abort
       input              rx_err_cpl_abort_n,

       // Rx indicates Unsupported Request
       input              rx_err_cpl_ur_n,
       input              rx_err_tlp_ur_n,      //Bar miss, format problem
       input              rx_err_tlp_ur_lock_n, //UR due to Lock
       input              rx_err_tlp_p_cpl_n,

       // Rx indicates Malformed packet
       input              rx_err_tlp_malformed_n,

       // Header info from Rx
       input       [47:0] rx_err_tlp_hdr,

       // Output to Tx Block (via arbiter) to generate message/UR Completions
       output reg         send_cor  = 0,
       output reg         send_nfl  = 0,
       output reg         send_ftl  = 0,
       output reg         send_cplt = 0,
       output reg         send_cplu = 0,
       output wire [49:0] cmt_rd_hdr,
       output wire [49:0] cfg_rd_hdr,
       input  wire [49:0] request_data,
       input              grant,
       input              cs_is_cplu,
       input              cs_is_cplt,
       input              cs_is_cor,
       input              cs_is_nfl,
       input              cs_is_ftl,

       // Input from the PCIe Block
       input        [6:0] l0_dll_error_vector,
       input        [1:0] l0_rx_mac_link_error,
       input              l0_mac_link_up,
                                                                   
       // Output to PCIe Block, to set 
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

       // Inputs fromthe Shadow Registers
       input       [15:0] cfg_dcommand,
       input       [15:0] cfg_command,

       // Inputs from the PCIe Block
       input              serr_en
); 

  parameter UR = 1'b0,
            CA = 1'b1;

  wire decr_cplu;
  wire decr_cplt;
  wire decr_cor;
  wire decr_nfl;
  wire decr_ftl;

  wire tlp_posted;
  wire cfg_posted;

  wire tlp_is_np_and_ur;
  wire cfg_is_np_and_ur;
  wire cfg_is_np_and_cpl_abort, cfg_is_p_and_cpl_abort, cfg_is_p_and_cpl_abort_and_send_nfl;

  wire masterdataparityerror;
  wire signaledtargetabort;
  wire receivedtargetabort;
  wire receivedmasterabort;
  wire detectedparityerror;
  wire signaledsystemerror;
  wire unsupportedreq;
  wire detectedfatal;
  wire detectednonfatal;
  wire detectedcorrectable;

  wire    [3:0] cnt_cplt;
  wire    [3:0] cnt_cplu;
  wire    [3:0] cnt_ftl;
  wire    [3:0] cnt_nfl;
  wire    [3:0] cnt_cor;

  wire   [49:0] cmt_wr_hdr;
  wire   [49:0] cfg_wr_hdr;

  wire          incr_cplu, incr_cplt;


  reg    [49:0] reg_cmt_wr_hdr;
  reg    [49:0] reg_cfg_wr_hdr;

  reg     [3:0] cs_fsm;  // current state

  reg     [1:0] reg_cmt_wp, reg_cmt_rp;
  reg     [2:0] reg_cfg_wp, reg_cfg_rp;

  reg           reg_masterdataparityerror;
  reg           reg_signaledtargetabort;
  reg           reg_receivedtargetabort;
  reg           reg_receivedmasterabort;
  reg           reg_detectedparityerror;
  reg           reg_signaledsystemerror;
  reg           reg_detectedcorrectable;
  reg           reg_detectedfatal;
  reg           reg_detectednonfatal;
  reg           reg_unsupportedreq;

    
  reg           reg_incr_cplu, reg_incr_cplt;

  wire    [2:0] cor_num_int;
  wire    [2:0] cor_num;
  wire    [2:0] ftl_num;
  wire    [2:0] nfl_num_int;
  wire    [2:0] nfl_num;
  wire    [2:0] cplt_num;
  wire    [2:0] cplu_num;
  wire    [1:0] cmt_wp;
  wire    [1:0] cmt_rp;
  wire    [2:0] cfg_wp;
  wire    [2:0] cfg_rp;

  wire          reg_decr_nfl;
  wire          reg_decr_cor;

  //******************************************************************//
  // Decode the error report masking capabilities and error severity. //
  //******************************************************************//
  wire serr_en_cmd = cfg_command[8]; 

  wire [3:0] x_dcmd = cfg_dcommand[3:0];
  wire err_cor_en = x_dcmd[0];
  wire err_nfl_en = x_dcmd[1] | serr_en_cmd;
  wire err_ftl_en = x_dcmd[2] | serr_en_cmd;
  wire err_ur_en  = x_dcmd[3];
  wire err_ur_nfl_en  = x_dcmd[3] & x_dcmd[1];

  //******************************************************************//
  // ??? Need to drive these signals when errors are detected. ???    //
  // There is no clear instruction in the PCI Express Base Spec,      //
  // Rev. 1.0 how the PCI Express errors are mapped to PCI errors,    //
  // all the following PCI error reporting signals are tied to logic  //
  // zero until further clarify by the PCI SIG. (7/2/02)              //
  //******************************************************************//

  always @(posedge clk) begin
    if (~rst_n)
      reg_signaledsystemerror <= #`Tcq 1'b0;
    else if (serr_en_cmd & grant)
        // If NFL message is sent 'cos of a NP UR.
      if ((request_data[48] == UR) && (cs_is_cplu || cs_is_cplt) && grant && err_ur_en) 
        reg_signaledsystemerror <= #`Tcq 1'b1;
        // If NFL message is sent 'cos of a P UR 
      else if (cs_is_cplu)
        reg_signaledsystemerror <= #`Tcq 1'b1;
        // If NFL | FTL message is sent 'cos of ERROR Non-Fatal | Fatal
      else if (cs_is_nfl|cs_is_ftl)
        reg_signaledsystemerror <= #`Tcq 1'b1;
      else
        reg_signaledsystemerror <= #`Tcq 1'b0;
    else
      reg_signaledsystemerror <= #`Tcq 1'b0;
  end  

  wire parity_err_resp = cfg_command[6]; 

  always @(posedge clk) begin
    if (~rst_n) begin
      reg_masterdataparityerror <= #`Tcq 1'b0;
      reg_signaledtargetabort   <= #`Tcq 1'b0;
      reg_receivedtargetabort   <= #`Tcq 1'b0;
      reg_receivedmasterabort   <= #`Tcq 1'b0;
      reg_detectedparityerror   <= #`Tcq 1'b0;
      reg_detectedcorrectable   <= #`Tcq 1'b0;
      reg_detectedfatal         <= #`Tcq 1'b0;
      reg_detectednonfatal      <= #`Tcq 1'b0;
      reg_unsupportedreq        <= #`Tcq 1'b0;
    end
    else begin  
        // This bit is set by Requestor if the Parity Error Enable
        // bit is set and either of the following two conditions occurs:
        //   --> Requestor receives completion marked poisoned
        //   --> Requestor poisons a write Request
        // If the Parity Error Enable bit is cleared, this bit is never set.
        // Default value of this field is 0.
      reg_masterdataparityerror <= #`Tcq parity_err_resp ? (~rx_err_cpl_ep_n | ~tx_err_wr_ep_n) : 1'b0;

      // This bit is set when the device completes a Request using completer Abort completion Status 
      // Default value of this field is 0.
      reg_signaledtargetabort <= #`Tcq  cfg_is_np_and_cpl_abort;

      // This bit is set when a Requestor receives a Completion with completer Abort completion Status 
      // Default value of this field is 0.
      reg_receivedtargetabort <= #`Tcq ~rx_err_cpl_abort_n;

      // This bit is set when a Requestor receives a completion with Unsupported Request completion status 
      // Default value of this field is 0.
      reg_receivedmasterabort <= #`Tcq ~rx_err_cpl_ur_n;

      // This bit is set by a device whenever it receives  a Poisoned TLP, regardless of the state of 
      // the Parity Error Enable bit.
      // Default value of this field is 0.
      reg_detectedparityerror <= #`Tcq ~rx_err_ep_n;


      // Refer Sec 6.2.6 Error Listing Rules for this classification
      reg_detectedcorrectable <= #`Tcq   ~cfg_err_cor_n;

      reg_detectedfatal       <= #`Tcq    ~rx_err_tlp_malformed_n;

      //Modified to NFL, other than UR or Posted Completer Abort
      reg_detectednonfatal    <= #`Tcq  ~cfg_err_ecrc_n |                              // Not a AFE, User detects a ECRC error for a TLP
                                        ~cfg_err_cpl_timeout_n;                        // Not a ANFE, User detects that Cpln has not arrived

      reg_unsupportedreq      <= #`Tcq  (~rx_err_tlp_ur_n & ~rx_err_tlp_p_cpl_n) |
                                        (~cfg_err_ur_n & ~cfg_err_posted_n) ;          // Not a ANFE, User detects a UR for a posted TLP
                                                                                       // so send a NFL message and record the UR in the
                                                                                       // status here.
    end
  end


  // Instantiate the error count-up/count-down modules
  // Correctible error handling: parse, count, send_request through a priorotised arbiter
  cmm_errman_cor  wtd_cor (
                 .cor_num                (cor_num_int)
                ,.inc_dec_b              (cor_add_sub_b)
                ,.reg_decr_cor           (reg_decr_cor)
                ,.add_input_one          (1'b0) //l0_rx_mac_link_error[1] & l0_mac_link_up)
                ,.add_input_two_n        (1'b1) //~l0_dll_error_vector[2])
                ,.add_input_three_n      (1'b1) //~l0_dll_error_vector[3])
                ,.add_input_four_n       (1'b1) //~l0_dll_error_vector[1])
                ,.add_input_five_n       (1'b1) //~l0_dll_error_vector[0])
                ,.add_input_six_n        (1'b1) ////cfg_err_cor_n)
                ,.decr_cor               (decr_cor)
                ,.rst                    (~rst_n)
                ,.clk                    (clk)
                );

  assign cor_num = cor_num_int - reg_decr_cor;

  cmm_errman_cnt_en  cor_cntr (
                 .count      (cnt_cor)
                ,.index      (cor_num)
                ,.inc_dec_b  (cor_add_sub_b)
                ,.enable     (err_cor_en)
                ,.rst        (~rst_n)
                ,.clk        (clk)
                );



  // Non-Fatal error handling: parse, count, send_request through a priorotised arbiter
  cmm_errman_cor  wtd_nfl (
                 .cor_num                (nfl_num_int)
                ,.inc_dec_b              (nfl_add_sub_b)
                ,.reg_decr_cor           (reg_decr_nfl)
                                            // Posted TLP that causes a UR, the NFL message is sent if
                                            // the UR&NFL are enabled together, or if the SERR is enabled.
                                            // Ref: Fig6-2, PCIe Base Spec v1.1
                ,.add_input_one          (1'b0)////~rx_err_tlp_ur_n & ~rx_err_tlp_p_cpl_n & (err_ur_nfl_en | serr_en) )
                ,.add_input_two_n        (1'b1)////err_nfl_en ? cfg_err_cpl_timeout_n : 1'b1)
                ,.add_input_three_n      (err_nfl_en ? rx_err_tlp_poisoned_n : 1'b1)
                ,.add_input_four_n       (1'b1)////err_nfl_en ? cfg_err_ecrc_n : 1'b1)
                ,.add_input_five_n       (1'b1)////~(~cfg_err_ur_n & ~cfg_err_posted_n & (err_ur_nfl_en|serr_en)))
                ,.add_input_six_n        (1'b1)
                ,.decr_cor               (decr_nfl)
                ,.rst                    (~rst_n)
                ,.clk                    (clk)
                );

  assign nfl_num = nfl_num_int - reg_decr_nfl;

  cmm_errman_cnt_en  nfl_cntr (
                 .count      (cnt_nfl)
                ,.index      (nfl_num)
                ,.inc_dec_b  (nfl_add_sub_b)
                ,.enable     (1'b1)
                ,.rst        (~rst_n)
                ,.clk        (clk)
                );

  // Fatal error handling: parse, count, send_request through a priorotised arbiter
  cmm_errman_ftl  wtd_ftl (
                 .ftl_num                   (ftl_num)
                ,.inc_dec_b                 (ftl_add_sub_b)
                ,.cmmp_training_err         (1'b0)
                ,.cmml_protocol_err_n       (1'b1) //~l0_dll_error_vector[6])
                ,.cmmt_err_rbuf_overflow    (1'b0)
                ,.cmmt_err_fc               (1'b0)
                ,.cmmt_err_tlp_malformed    (1'b0)
                ,.decr_ftl                  (decr_ftl)
                ,.rst                       (~rst_n)
                ,.clk                       (clk)
                );

  cmm_errman_cnt_en  ftl_cntr (
                 .count      (cnt_ftl)
                ,.index      (ftl_num)
                ,.inc_dec_b  (ftl_add_sub_b)
                ,.enable     (err_ftl_en)
                ,.rst        (~rst_n)
                ,.clk        (clk)
                );



  // Completion-Abort/Unsupported-Request TLM error handling: parse, count, send_request through a priorotised arbiter
  cmm_errman_cpl  wtd_cplt (
                 .cpl_num               (cplt_num)
                ,.inc_dec_b             (cplt_add_sub_b)
                ,.cmm_err_tlp_posted    (tlp_posted)
                ,.decr_cpl              (decr_cplt)
                ,.rst                   (~rst_n)
                ,.clk                   (clk)
                );

  cmm_errman_cnt_en  cplt_cntr (                // one counter for TLM
                 .count      (cnt_cplt)
                ,.index      (cplt_num)
                ,.inc_dec_b  (cplt_add_sub_b)
                ,.enable     (1'b1)             // always enable Cpl response
                ,.rst        (~rst_n)
                ,.clk        (clk)
                );


  // Completion-Abort/Unsupported-Request USER error handling: parse, count, send_request through a priorotised arbiter
  cmm_errman_cpl  wtd_cplu (
                 .cpl_num               (cplu_num)
                ,.inc_dec_b             (cplu_add_sub_b)
                ,.cmm_err_tlp_posted    (cfg_posted)
                ,.decr_cpl              (decr_cplu)
                ,.rst                   (~rst_n)
                ,.clk                   (clk)
                );

  cmm_errman_cnt_en  cplu_cntr (                // one counter for User
                 .count      (cnt_cplu)
                ,.index      (cplu_num)
                ,.inc_dec_b  (cplu_add_sub_b)
                ,.enable     (1'b1)             // always enable Cpl response
                ,.rst        (~rst_n)
                ,.clk        (clk)
                );



  always @(posedge clk) begin
    if (~rst_n) begin
      send_cor  <= #`Tcq 1'b0;
      send_nfl  <= #`Tcq 1'b0;
      send_ftl  <= #`Tcq 1'b0;
      send_cplt <= #`Tcq 1'b0;
      send_cplu <= #`Tcq 1'b0;
    end
    else  begin
      send_cor  <= #`Tcq |cnt_cor;
      send_nfl  <= #`Tcq |cnt_nfl;
      send_ftl  <= #`Tcq |cnt_ftl;
      send_cplt <= #`Tcq |cnt_cplt;
      send_cplu <= #`Tcq |cnt_cplu;
    end
  end



  // Store the header information into FIFO
  always @(posedge clk) begin
    if (~rst_n) 
      reg_cmt_wr_hdr <= #`Tcq 50'h0000_0000_0000;
    else  begin
        // If UR 
      if (tlp_is_np_and_ur)
        reg_cmt_wr_hdr <= #`Tcq {rx_err_tlp_ur_lock_n,UR,  // Locked status, UR
                                 rx_err_tlp_hdr[47:0]};    // Lower-Addr + Byte-Count + TC + Attr + Req-ID + Tag
      else 
        reg_cmt_wr_hdr <= #`Tcq 0;
    end
  end


  // Store the header information into FIFO
  always @(posedge clk) begin
    if (~rst_n) 
      reg_cfg_wr_hdr <= #`Tcq 50'h0000_0000_0000;
    else  begin
      if (cfg_is_np_and_ur)
        reg_cfg_wr_hdr <= #`Tcq {cfg_err_locked_n,     UR,       // Locked status, UR
                                 cfg_err_tlp_cpl_header[47:0]};  // Lower-Addr + Byte-Count + TC + Attr + Req-ID + Tag
      else if (cfg_is_np_and_cpl_abort)
        reg_cfg_wr_hdr <= #`Tcq {cfg_err_locked_n,     CA,       // Locked status, CA
                                 cfg_err_tlp_cpl_header[47:0]};  // Lower-Addr + Byte-Count + TC + Attr + Req-ID + Tag
      else
        reg_cfg_wr_hdr <= #`Tcq 0;
    end
  end

  assign  cmt_wr_hdr = reg_cmt_wr_hdr;
  assign  cfg_wr_hdr = reg_cfg_wr_hdr;





  // Pipeline the completion request signals
  always @(posedge clk)
    if (~rst_n) begin
      reg_incr_cplu <= #`Tcq 1'b0;
      reg_incr_cplt <= #`Tcq 1'b0;
    end
    else begin
      reg_incr_cplu <= #`Tcq cfg_posted;
      reg_incr_cplt <= #`Tcq tlp_posted;
    end


  assign incr_cplu = reg_incr_cplu;
  assign incr_cplt = reg_incr_cplt;

  always @(posedge clk) begin
    if (~rst_n)                 reg_cmt_wp <= #`Tcq 2'b00;
    else if (incr_cplt)         reg_cmt_wp <= #`Tcq cmt_wp + 2'b01;
  end

  always @(posedge clk) begin
    if (~rst_n)                 reg_cfg_wp <= #`Tcq 3'b000;
    else if (incr_cplu)         reg_cfg_wp <= #`Tcq cfg_wp + 3'b001;
  end


  always @(posedge clk) begin   
    if (~rst_n)                   reg_cmt_rp <= #`Tcq 2'b00;
    else if (cs_is_cplt & grant)  reg_cmt_rp <= #`Tcq cmt_rp + 2'b01;
  end     
  
  always @(posedge clk) begin   
    if (~rst_n)                   reg_cfg_rp <= #`Tcq 3'b000;
    else if (cs_is_cplu & grant)  reg_cfg_rp <= #`Tcq cfg_rp + 3'b001;
  end     

  assign cmt_wp  = reg_cmt_wp;
  assign cfg_wp  = reg_cfg_wp;
  assign cmt_rp  = reg_cmt_rp;
  assign cfg_rp  = reg_cfg_rp;

  //******************************************************************//
  // Instantiate two 4-deep, 50-bit wide buffers to store the header //
  // information of the outstanding completion packets. One buffer    //
  // for the requests from the TLM (cmmt_* ports) and one for the     //
  // requests from the user (cfg_* ports).                            //
  // The buffer is implemented with RAM16X1D primitives and the       //
  // read data output is registered.                                  //
  // The write and read pointers to the header buffer are separately  //
  // advanced by the FSM. Pointer wraps around if overflow. Both the  //
  // write and read pointers are not managed (e.g. if there are 16    //
  // writes before a read occur, header information is lost).         //
  //******************************************************************//

  // Header buffer for completion from TLM (TRN I/F) & USR (CFG I/F)
  cmm_errman_ram4x26  cmt_hdr_buf (
                 .rddata (cmt_rd_hdr)
                ,.wrdata (cmt_wr_hdr)
                ,.wr_ptr (cmt_wp)
                ,.rd_ptr (cmt_rp)
                ,.we     (incr_cplt)
                ,.rst    (~rst_n)
                ,.clk    (clk)
                );

  cmm_errman_ram8x26  cfg_hdr_buf (
                 .rddata (cfg_rd_hdr)
                ,.wrdata (cfg_wr_hdr)
                ,.wr_ptr (cfg_wp)  
                ,.rd_ptr (cfg_rp)
                ,.we     (incr_cplu)
                ,.rst    (~rst_n)
                ,.clk    (clk)
                );

  assign decr_cplu = cs_is_cplu && grant;
  assign decr_cplt = cs_is_cplt && grant;
  assign decr_cor  = cs_is_cor  && grant;
  assign decr_nfl  = cs_is_nfl  && grant;
  assign decr_ftl  = cs_is_ftl  && grant;

  //assign tlp_is_np_and_ur  = cmmt_err_tlp_ur & cmmt_err_tlp_p_cpl_n;
  assign tlp_is_np_and_ur  = ~rx_err_tlp_ur_n & rx_err_tlp_p_cpl_n;
                                // For a Non-Posted TLP that causes a UR, we should report a UR
  assign tlp_posted        = tlp_is_np_and_ur ? 1'b1 : 1'b0;
                            
  assign cfg_is_np_and_ur                  = ~cfg_err_ur_n & cfg_err_posted_n;
  assign cfg_is_np_and_cpl_abort           = ~cfg_err_cpl_abort_n & cfg_err_posted_n;

  // cfg_posted has a 3 cycle delay from when cfg_err_ur_n or 
  // cfg_err_cpl_abort_n is asserted.  Set throttle at 4, so fifo needs space
  // for 3+3. Only 1 cpl can be added to fifo at a time.

  assign cfg_posted        = ((cfg_is_np_and_ur|cfg_is_np_and_cpl_abort) & ~cnt_cplu[2]) ? 1'b1 : 1'b0;

  assign cfg_err_cpl_rdy_n = (cnt_cplu[2] | ~rst_n);  
                             

  assign l0_set_user_master_data_parity    = reg_masterdataparityerror;
  assign l0_set_user_signaled_target_abort = reg_signaledtargetabort;
  assign l0_set_user_received_target_abort = reg_receivedtargetabort;
  assign l0_set_user_received_master_abort = reg_receivedmasterabort;
  assign l0_set_user_detected_parity_error = reg_detectedparityerror;

  assign l0_set_user_system_error = reg_signaledsystemerror;

  assign l0_set_unsupported_request_other_error = reg_unsupportedreq;
  assign l0_set_detected_fatal_error        = reg_detectedfatal;
  assign l0_set_detected_nonfatal_error     = reg_detectednonfatal;
  assign l0_set_detected_corr_error = reg_detectedcorrectable;

endmodule // pcie_blk_cf_err
