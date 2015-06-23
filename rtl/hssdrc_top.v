//
// Project      : High-Speed SDRAM Controller with adaptive bank management and command pipeline
// 
// Project Nick : HSSDRC
// 
// Version      : 1.0-beta 
//  
// Revision     : $Revision: 1.1 $ 
// 
// Date         : $Date: 2008-03-06 13:52:43 $ 
// 
// Workfile     : hssdrc_top.v
// 
// Description  : top level of memory controller
// 
// HSSDRC is licensed under MIT License
// 
// Copyright (c) 2007-2008, Denis V.Shekhalev (des00@opencores.org) 
// 
// Permission  is hereby granted, free of charge, to any person obtaining a copy of
// this  software  and  associated documentation files (the "Software"), to deal in
// the  Software  without  restriction,  including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the  Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
// 
// The  above  copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE  SOFTWARE  IS  PROVIDED  "AS  IS",  WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR  A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT  HOLDERS  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN  AN  ACTION  OF  CONTRACT,  TORT  OR  OTHERWISE,  ARISING  FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


`include "hssdrc_timescale.vh"

`include "hssdrc_define.vh"

module hssdrc_top (
  clk           , 
  reset         , 
  sclr          , 
  sys_write     ,
  sys_read      ,
  sys_refr      ,
  sys_rowa      ,
  sys_cola      ,
  sys_ba        ,
  sys_burst     ,
  sys_chid_i    ,
  sys_wdata     ,
  sys_wdatam    ,  
  sys_ready     ,
  sys_use_wdata , 
  sys_vld_rdata ,
  sys_chid_o    ,
  sys_rdata     ,
  dq            , 
  dqm           , 
  addr          , 
  ba            , 
  cke           , 
  cs_n          , 
  ras_n         , 
  cas_n         , 
  we_n          
  );

  input wire clk  ;
  input wire reset;
  input wire sclr ;

  //--------------------------------------------------------------------------------------------------
  // system interface 
  //-------------------------------------------------------------------------------------------------- 

  input  wire    sys_write     ;      
  input  wire    sys_read      ;     
  input  wire    sys_refr      ;     
  input  rowa_t  sys_rowa      ;     
  input  cola_t  sys_cola      ;     
  input  ba_t    sys_ba        ;     
  input  burst_t sys_burst     ;     
  input  chid_t  sys_chid_i    ;     
  input  data_t  sys_wdata     ;     
  input  datam_t sys_wdatam    ;    
   
  output logic   sys_ready     ; 
  output logic   sys_use_wdata ; 
  output logic   sys_vld_rdata ; 
  output chid_t  sys_chid_o    ; 
  output data_t  sys_rdata     ;

  //--------------------------------------------------------------------------------------------------
  // sdram interface 
  //--------------------------------------------------------------------------------------------------  

  inout   wire [pDataBits-1:0] dq;
  output  datam_t       dqm;  
  output  sdram_addr_t  addr;
  output  ba_t          ba; 
  output  logic         cke;
  output  logic         cs_n;
  output  logic         ras_n;
  output  logic         cas_n;
  output  logic         we_n;

  //--------------------------------------------------------------------------------------------------  
  // internal signals 
  //--------------------------------------------------------------------------------------------------

  wire init_done; 
  wire hssdrc_sclr; 

  //--------------------------------------------------------------------------------------------------
  // refr_cnt <-> arbiter_in  
  //--------------------------------------------------------------------------------------------------

  wire refr_cnt___ack     ;
  wire refr_cnt___hi_req  ;
  wire refr_cnt___low_req ;

  //--------------------------------------------------------------------------------------------------
  // arbiter_in <-> decoder's
  //--------------------------------------------------------------------------------------------------

  wire    arbiter_in0___write  ;  
  wire    arbiter_in0___read   ;
  wire    arbiter_in0___refr   ;
  rowa_t  arbiter_in0___rowa   ;
  cola_t  arbiter_in0___cola   ;
  ba_t    arbiter_in0___ba     ;
  burst_t arbiter_in0___burst  ;
  chid_t  arbiter_in0___chid   ;
  wire    arbiter_in0___ready  ;
  //                            
  wire    arbiter_in1___write  ;
  wire    arbiter_in1___read   ;
  wire    arbiter_in1___refr   ;
  rowa_t  arbiter_in1___rowa   ;
  cola_t  arbiter_in1___cola   ;
  ba_t    arbiter_in1___ba     ;
  burst_t arbiter_in1___burst  ;
  chid_t  arbiter_in1___chid   ;
  wire    arbiter_in1___ready  ;
  //                            
  wire    arbiter_in2___write  ;
  wire    arbiter_in2___read   ;
  wire    arbiter_in2___refr   ;
  rowa_t  arbiter_in2___rowa   ;
  cola_t  arbiter_in2___cola   ;
  ba_t    arbiter_in2___ba     ;
  burst_t arbiter_in2___burst  ;
  chid_t  arbiter_in2___chid   ;
  wire    arbiter_in2___ready  ;

  //--------------------------------------------------------------------------------------------------
  // ba_map <-> decoder's 
  //--------------------------------------------------------------------------------------------------

  wire    ba_map___update      ;  
  wire    ba_map___clear       ;
  ba_t    ba_map___ba          ;
  rowa_t  ba_map___rowa        ;                
  wire    ba_map___pre_act_rw  ;
  wire    ba_map___act_rw      ;
  wire    ba_map___rw          ;
  wire    ba_map___all_close   ;

  //--------------------------------------------------------------------------------------------------
  // decoder's <-> arbiter_out 
  //--------------------------------------------------------------------------------------------------

  wire          dec0___pre_all         ;
  wire          dec0___refr            ;
  wire          dec0___pre             ;
  wire          dec0___act             ;
  wire          dec0___read            ;
  wire          dec0___write           ;
  wire          dec0___pre_all_enable  ;
  wire          dec0___refr_enable     ;
  wire          dec0___pre_enable      ;
  wire          dec0___act_enable      ;
  wire          dec0___read_enable     ;
  wire          dec0___write_enable    ;
  wire          dec0___locked          ;
  wire          dec0___last            ;
  rowa_t        dec0___rowa            ;
  cola_t        dec0___cola            ;
  ba_t          dec0___ba              ;
  chid_t        dec0___chid            ;
  sdram_burst_t dec0___burst           ;
  //
  wire          dec1___pre_all         ;
  wire          dec1___refr            ;
  wire          dec1___pre             ;
  wire          dec1___act             ;
  wire          dec1___read            ;
  wire          dec1___write           ;
  wire          dec1___pre_all_enable  ;
  wire          dec1___refr_enable     ;
  wire          dec1___pre_enable      ;
  wire          dec1___act_enable      ;
  wire          dec1___read_enable     ;
  wire          dec1___write_enable    ;
  wire          dec1___locked          ;
  wire          dec1___last            ;
  rowa_t        dec1___rowa            ;
  cola_t        dec1___cola            ;
  ba_t          dec1___ba              ;
  chid_t        dec1___chid            ;
  sdram_burst_t dec1___burst           ;
  //
  wire          dec2___pre_all         ;
  wire          dec2___refr            ;
  wire          dec2___pre             ;
  wire          dec2___act             ;
  wire          dec2___read            ;
  wire          dec2___write           ;
  wire          dec2___pre_all_enable  ;
  wire          dec2___refr_enable     ;
  wire          dec2___pre_enable      ;
  wire          dec2___act_enable      ;
  wire          dec2___read_enable     ;
  wire          dec2___write_enable    ;
  wire          dec2___locked          ;
  wire          dec2___last            ;
  rowa_t        dec2___rowa            ;
  cola_t        dec2___cola            ;
  ba_t          dec2___ba              ;
  chid_t        dec2___chid            ;
  sdram_burst_t dec2___burst           ;

  //--------------------------------------------------------------------------------------------------
  // access_manager -> arbiter_out 
  //--------------------------------------------------------------------------------------------------

  wire       access_manager___pre_all_enable  ;
  wire       access_manager___refr_enable     ;
  wire [0:3] access_manager___pre_enable      ;
  wire [0:3] access_manager___act_enable      ;
  wire [0:3] access_manager___read_enable     ;
  wire [0:3] access_manager___write_enable    ;

  //--------------------------------------------------------------------------------------------------
  // arbiter_out -> multiplexer/access_manager 
  //--------------------------------------------------------------------------------------------------

  wire          arbiter_out___pre_all ;
  wire          arbiter_out___refr    ;
  wire          arbiter_out___pre     ;
  wire          arbiter_out___act     ;
  wire          arbiter_out___read    ;
  wire          arbiter_out___write   ;
  rowa_t        arbiter_out___rowa    ;
  cola_t        arbiter_out___cola    ;
  ba_t          arbiter_out___ba      ;
  chid_t        arbiter_out___chid    ;
  sdram_burst_t arbiter_out___burst   ;

  //--------------------------------------------------------------------------------------------------
  // init_state -> multiplexer
  //--------------------------------------------------------------------------------------------------

  wire    init_state___pre_all ;    
  wire    init_state___refr    ;   
  wire    init_state___lmr     ;   
  rowa_t  init_state___rowa    ;
  
  //--------------------------------------------------------------------------------------------------
  // multiplexer -> sdram_addr_path/sdram_data_path
  //--------------------------------------------------------------------------------------------------

  wire          mux___pre_all  ;           
  wire          mux___refr     ;         
  wire          mux___pre      ;         
  wire          mux___act      ;         
  wire          mux___read     ;         
  wire          mux___write    ;         
  wire          mux___lmr      ;         
  rowa_t        mux___rowa     ;         
  cola_t        mux___cola     ;         
  ba_t          mux___ba       ;         
  chid_t        mux___chid     ;         
  sdram_burst_t mux___burst    ;
  
  //
  // this clear use to disable fsm that must be off when sdram chip is not configured 
  //

  assign hssdrc_sclr = sclr | ~init_done;

  //--------------------------------------------------------------------------------------------------
  //
  //-------------------------------------------------------------------------------------------------- 

  hssdrc_refr_counter refr_cnt(
    .clk      (clk  ),  
    .reset    (reset),
    .sclr     (hssdrc_sclr ), // use internal sclr becouse there is refresh "fsm"
    .ack      (refr_cnt___ack    ),
    .hi_req   (refr_cnt___hi_req ),
    .low_req  (refr_cnt___low_req)
    ); 
  //--------------------------------------------------------------------------------------------------
  //
  //-------------------------------------------------------------------------------------------------- 
  hssdrc_arbiter_in arbiter_in ( 
    .clk              (clk  ),  
    .reset            (reset),
    .sclr             (hssdrc_sclr ), // use internal sclr becouse there is arbiter fsm                  
    //
    .sys_write        (sys_write ) , 
    .sys_read         (sys_read  ) , 
    .sys_refr         (sys_refr  ) , 
    .sys_rowa         (sys_rowa  ) , 
    .sys_cola         (sys_cola  ) , 
    .sys_ba           (sys_ba    ) , 
    .sys_burst        (sys_burst ) , 
    .sys_chid_i       (sys_chid_i) , 
    .sys_ready        (sys_ready ) , 
    //
    .refr_cnt_ack     (refr_cnt___ack    ), 
    .refr_cnt_hi_req  (refr_cnt___hi_req ), 
    .refr_cnt_low_req (refr_cnt___low_req), 
    //
    .dec0_write       (arbiter_in0___write),
    .dec0_read        (arbiter_in0___read ),
    .dec0_refr        (arbiter_in0___refr ),
    .dec0_rowa        (arbiter_in0___rowa ),
    .dec0_cola        (arbiter_in0___cola ),
    .dec0_ba          (arbiter_in0___ba   ),
    .dec0_burst       (arbiter_in0___burst),
    .dec0_chid        (arbiter_in0___chid ),
    .dec0_ready       (arbiter_in0___ready),
    //
    .dec1_write       (arbiter_in1___write),
    .dec1_read        (arbiter_in1___read ),
    .dec1_refr        (arbiter_in1___refr ),
    .dec1_rowa        (arbiter_in1___rowa ),
    .dec1_cola        (arbiter_in1___cola ),
    .dec1_ba          (arbiter_in1___ba   ),
    .dec1_burst       (arbiter_in1___burst),
    .dec1_chid        (arbiter_in1___chid ),
    .dec1_ready       (arbiter_in1___ready),
    //
    .dec2_write       (arbiter_in2___write),
    .dec2_read        (arbiter_in2___read ),
    .dec2_refr        (arbiter_in2___refr ),
    .dec2_rowa        (arbiter_in2___rowa ),
    .dec2_cola        (arbiter_in2___cola ),
    .dec2_ba          (arbiter_in2___ba   ),
    .dec2_burst       (arbiter_in2___burst),
    .dec2_chid        (arbiter_in2___chid ),
    .dec2_ready       (arbiter_in2___ready) 
  );  
  //--------------------------------------------------------------------------------------------------
  //
  //-------------------------------------------------------------------------------------------------- 
  hssdrc_ba_map ba_map (
    .clk        (clk  ),  
    .reset      (reset),
    .sclr       (hssdrc_sclr), // use internal sclr becouse there is bank access map
    //
    .update     (ba_map___update),
    .clear      (ba_map___clear ),
    .ba         (ba_map___ba    ),
    .rowa       (ba_map___rowa  ),
    //
    .pre_act_rw (ba_map___pre_act_rw),
    .act_rw     (ba_map___act_rw    ),
    .rw         (ba_map___rw        ),
    .all_close  (ba_map___all_close ) 
    );
  //--------------------------------------------------------------------------------------------------
  //
  //-------------------------------------------------------------------------------------------------- 
  hssdrc_decoder decoder (
    .clk                (clk  ),  
    .reset              (reset),
    .sclr               (hssdrc_sclr), // use internal sclr becouse there is decoders fsm
    //  
    .ba_map_update      (ba_map___update    ),
    .ba_map_clear       (ba_map___clear     ),
    .ba_map_ba          (ba_map___ba        ),
    .ba_map_rowa        (ba_map___rowa      ),
    //
    .ba_map_pre_act_rw  (ba_map___pre_act_rw),
    .ba_map_act_rw      (ba_map___act_rw    ),
    .ba_map_rw          (ba_map___rw        ),
    .ba_map_all_close   (ba_map___all_close ),
    //  
    .arb0_write         (arbiter_in0___write),
    .arb0_read          (arbiter_in0___read ),
    .arb0_refr          (arbiter_in0___refr ),
    .arb0_rowa          (arbiter_in0___rowa ),
    .arb0_cola          (arbiter_in0___cola ),
    .arb0_ba            (arbiter_in0___ba   ),
    .arb0_burst         (arbiter_in0___burst),
    .arb0_chid          (arbiter_in0___chid ),
    .arb0_ready         (arbiter_in0___ready),
    //                  
    .arb1_write         (arbiter_in1___write),
    .arb1_read          (arbiter_in1___read ),
    .arb1_refr          (arbiter_in1___refr ),
    .arb1_rowa          (arbiter_in1___rowa ),
    .arb1_cola          (arbiter_in1___cola ),
    .arb1_ba            (arbiter_in1___ba   ),
    .arb1_burst         (arbiter_in1___burst),
    .arb1_chid          (arbiter_in1___chid ),
    .arb1_ready         (arbiter_in1___ready),
    //                  
    .arb2_write         (arbiter_in2___write),
    .arb2_read          (arbiter_in2___read ),
    .arb2_refr          (arbiter_in2___refr ),
    .arb2_rowa          (arbiter_in2___rowa ),
    .arb2_cola          (arbiter_in2___cola ),
    .arb2_ba            (arbiter_in2___ba   ),
    .arb2_burst         (arbiter_in2___burst),
    .arb2_chid          (arbiter_in2___chid ),
    .arb2_ready         (arbiter_in2___ready),
    //
    .dec0_pre_all       (dec0___pre_all       ),
    .dec0_refr          (dec0___refr          ),
    .dec0_pre           (dec0___pre           ),
    .dec0_act           (dec0___act           ),
    .dec0_read          (dec0___read          ),
    .dec0_write         (dec0___write         ),
    .dec0_pre_all_enable(dec0___pre_all_enable),
    .dec0_refr_enable   (dec0___refr_enable   ),
    .dec0_pre_enable    (dec0___pre_enable    ),
    .dec0_act_enable    (dec0___act_enable    ),
    .dec0_read_enable   (dec0___read_enable   ),
    .dec0_write_enable  (dec0___write_enable  ),
    .dec0_locked        (dec0___locked        ),
    .dec0_last          (dec0___last          ),
    .dec0_rowa          (dec0___rowa          ),
    .dec0_cola          (dec0___cola          ),
    .dec0_ba            (dec0___ba            ),
    .dec0_chid          (dec0___chid          ),
    .dec0_burst         (dec0___burst         ),
    //
    .dec1_pre_all       (dec1___pre_all       ),
    .dec1_refr          (dec1___refr          ),
    .dec1_pre           (dec1___pre           ),
    .dec1_act           (dec1___act           ),
    .dec1_read          (dec1___read          ),
    .dec1_write         (dec1___write         ),
    .dec1_pre_all_enable(dec1___pre_all_enable),
    .dec1_refr_enable   (dec1___refr_enable   ),
    .dec1_pre_enable    (dec1___pre_enable    ),
    .dec1_act_enable    (dec1___act_enable    ),
    .dec1_read_enable   (dec1___read_enable   ),
    .dec1_write_enable  (dec1___write_enable  ),
    .dec1_locked        (dec1___locked        ),
    .dec1_last          (dec1___last          ),
    .dec1_rowa          (dec1___rowa          ),
    .dec1_cola          (dec1___cola          ),
    .dec1_ba            (dec1___ba            ),
    .dec1_chid          (dec1___chid          ),
    .dec1_burst         (dec1___burst         ),
    //
    .dec2_pre_all       (dec2___pre_all       ),
    .dec2_refr          (dec2___refr          ),
    .dec2_pre           (dec2___pre           ),
    .dec2_act           (dec2___act           ),
    .dec2_read          (dec2___read          ),
    .dec2_write         (dec2___write         ),
    .dec2_pre_all_enable(dec2___pre_all_enable),
    .dec2_refr_enable   (dec2___refr_enable   ),
    .dec2_pre_enable    (dec2___pre_enable    ),
    .dec2_act_enable    (dec2___act_enable    ),
    .dec2_read_enable   (dec2___read_enable   ),
    .dec2_write_enable  (dec2___write_enable  ),
    .dec2_locked        (dec2___locked        ),
    .dec2_last          (dec2___last          ),
    .dec2_rowa          (dec2___rowa          ),
    .dec2_cola          (dec2___cola          ),
    .dec2_ba            (dec2___ba            ),
    .dec2_chid          (dec2___chid          ),
    .dec2_burst         (dec2___burst         )                       
    ); 
  //--------------------------------------------------------------------------------------------------
  //
  //-------------------------------------------------------------------------------------------------- 
  hssdrc_arbiter_out arbiter_out(
    .clk                (clk), 
    .reset              (reset), 
    .sclr               (hssdrc_sclr), // use internal sclr becouse there is arbiter fsm
    //
    .dec0_pre_all       (dec0___pre_all       ),
    .dec0_refr          (dec0___refr          ),
    .dec0_pre           (dec0___pre           ),
    .dec0_act           (dec0___act           ),
    .dec0_read          (dec0___read          ),
    .dec0_write         (dec0___write         ),
    .dec0_pre_all_enable(dec0___pre_all_enable),
    .dec0_refr_enable   (dec0___refr_enable   ),
    .dec0_pre_enable    (dec0___pre_enable    ),
    .dec0_act_enable    (dec0___act_enable    ),
    .dec0_read_enable   (dec0___read_enable   ),
    .dec0_write_enable  (dec0___write_enable  ),
    .dec0_locked        (dec0___locked        ),
    .dec0_last          (dec0___last          ),
    .dec0_rowa          (dec0___rowa          ),
    .dec0_cola          (dec0___cola          ),
    .dec0_ba            (dec0___ba            ),
    .dec0_chid          (dec0___chid          ),
    .dec0_burst         (dec0___burst         ),
    //
    .dec1_pre_all       (dec1___pre_all       ),
    .dec1_refr          (dec1___refr          ),
    .dec1_pre           (dec1___pre           ),
    .dec1_act           (dec1___act           ),
    .dec1_read          (dec1___read          ),
    .dec1_write         (dec1___write         ),
    .dec1_pre_all_enable(dec1___pre_all_enable),
    .dec1_refr_enable   (dec1___refr_enable   ),
    .dec1_pre_enable    (dec1___pre_enable    ),
    .dec1_act_enable    (dec1___act_enable    ),
    .dec1_read_enable   (dec1___read_enable   ),
    .dec1_write_enable  (dec1___write_enable  ),
    .dec1_locked        (dec1___locked        ),
    .dec1_last          (dec1___last          ),
    .dec1_rowa          (dec1___rowa          ),
    .dec1_cola          (dec1___cola          ),
    .dec1_ba            (dec1___ba            ),
    .dec1_chid          (dec1___chid          ),
    .dec1_burst         (dec1___burst         ),
    //
    .dec2_pre_all       (dec2___pre_all       ),
    .dec2_refr          (dec2___refr          ),
    .dec2_pre           (dec2___pre           ),
    .dec2_act           (dec2___act           ),
    .dec2_read          (dec2___read          ),
    .dec2_write         (dec2___write         ),
    .dec2_pre_all_enable(dec2___pre_all_enable),
    .dec2_refr_enable   (dec2___refr_enable   ),
    .dec2_pre_enable    (dec2___pre_enable    ),
    .dec2_act_enable    (dec2___act_enable    ),
    .dec2_read_enable   (dec2___read_enable   ),
    .dec2_write_enable  (dec2___write_enable  ),
    .dec2_locked        (dec2___locked        ),
    .dec2_last          (dec2___last          ),
    .dec2_rowa          (dec2___rowa          ),
    .dec2_cola          (dec2___cola          ),
    .dec2_ba            (dec2___ba            ),
    .dec2_chid          (dec2___chid          ),
    .dec2_burst         (dec2___burst         ),
    //
    .am_pre_all_enable  (access_manager___pre_all_enable),
    .am_refr_enable     (access_manager___refr_enable   ),
    .am_pre_enable      (access_manager___pre_enable    ),
    .am_act_enable      (access_manager___act_enable    ),
    .am_read_enable     (access_manager___read_enable   ),
    .am_write_enable    (access_manager___write_enable  ),
    //
    .arb_pre_all        (arbiter_out___pre_all),        
    .arb_refr           (arbiter_out___refr   ),
    .arb_pre            (arbiter_out___pre    ),
    .arb_act            (arbiter_out___act    ),
    .arb_read           (arbiter_out___read   ),
    .arb_write          (arbiter_out___write  ),
    .arb_rowa           (arbiter_out___rowa   ),
    .arb_cola           (arbiter_out___cola   ),
    .arb_ba             (arbiter_out___ba     ),
    .arb_chid           (arbiter_out___chid   ),
    .arb_burst          (arbiter_out___burst  )
  );
  //--------------------------------------------------------------------------------------------------
  //
  //-------------------------------------------------------------------------------------------------- 
  hssdrc_access_manager access_manager (
    .clk               (clk  ),  
    .reset             (reset),
    .sclr              (hssdrc_sclr),    // use internal sclr becouse there is access "fsm's"
    //
    .arb_pre_all       (arbiter_out___pre_all), 
    .arb_refr          (arbiter_out___refr   ),
    .arb_pre           (arbiter_out___pre    ),
    .arb_act           (arbiter_out___act    ),
    .arb_read          (arbiter_out___read   ),
    .arb_write         (arbiter_out___write  ),
    .arb_ba            (arbiter_out___ba     ),
    .arb_burst         (arbiter_out___burst  ),
    //
    .am_pre_all_enable (access_manager___pre_all_enable),
    .am_refr_enable    (access_manager___refr_enable   ),
    .am_pre_enable     (access_manager___pre_enable    ),
    .am_act_enable     (access_manager___act_enable    ),
    .am_read_enable    (access_manager___read_enable   ),
    .am_write_enable   (access_manager___write_enable  )   
  ); 
  //--------------------------------------------------------------------------------------------------
  //
  //-------------------------------------------------------------------------------------------------- 
  hssdrc_init_state init_state(
    .clk        (clk  ),  
    .reset      (reset),
    .sclr       (sclr ), // use external sclr becouse this is initial start fsm 
    .init_done  (init_done),  
    .pre_all    (init_state___pre_all),
    .refr       (init_state___refr   ),
    .lmr        (init_state___lmr    ),
    .rowa       (init_state___rowa   ) 
  );
  //--------------------------------------------------------------------------------------------------
  //
  //-------------------------------------------------------------------------------------------------- 
  hssdrc_mux mux (
    .init_done          (init_done), 
    //
    .init_state_pre_all (init_state___pre_all),
    .init_state_refr    (init_state___refr   ),
    .init_state_lmr     (init_state___lmr    ),
    .init_state_rowa    (init_state___rowa   ),
    //                  
    .arb_pre_all        (arbiter_out___pre_all),
    .arb_refr           (arbiter_out___refr   ),
    .arb_pre            (arbiter_out___pre    ),
    .arb_act            (arbiter_out___act    ),
    .arb_read           (arbiter_out___read   ),
    .arb_write          (arbiter_out___write  ),
    .arb_rowa           (arbiter_out___rowa   ),
    .arb_cola           (arbiter_out___cola   ),
    .arb_ba             (arbiter_out___ba     ),
    .arb_chid           (arbiter_out___chid   ),
    .arb_burst          (arbiter_out___burst  ),
    //                  
    .mux_pre_all        (mux___pre_all),
    .mux_refr           (mux___refr   ),
    .mux_pre            (mux___pre    ),
    .mux_act            (mux___act    ),
    .mux_read           (mux___read   ),
    .mux_write          (mux___write  ),
    .mux_lmr            (mux___lmr    ),
    .mux_rowa           (mux___rowa   ),
    .mux_cola           (mux___cola   ),
    .mux_ba             (mux___ba     ),
    .mux_chid           (mux___chid   ),
    .mux_burst          (mux___burst  ) 
  );
  //--------------------------------------------------------------------------------------------------
  //
  //-------------------------------------------------------------------------------------------------- 
  `ifndef HSSDRC_DQ_PIPELINE

    hssdrc_data_path data_path (
      .clk           (clk  ),
      .reset         (reset),
      .sclr          (sclr ),  // use external sclr becouse there is no any fsm
      //
      .sys_wdata     (sys_wdata    ),
      .sys_wdatam    (sys_wdatam   ),
      .sys_use_wdata (sys_use_wdata),
      .sys_vld_rdata (sys_vld_rdata), 
      .sys_chid_o    (sys_chid_o   ),
      .sys_rdata     (sys_rdata    ),
      //             
      .arb_read      (mux___read   ),
      .arb_write     (mux___write  ),
      .arb_chid      (mux___chid   ),
      .arb_burst     (mux___burst  ),
      //
      .dq            (dq   ),
      .dqm           (dqm  )
    );

  `else 

    hssdrc_data_path_p1 data_path_p1 (
      .clk           (clk  ),
      .reset         (reset),
      .sclr          (sclr ),  // use external sclr becouse there is no any fsm
      //
      .sys_wdata     (sys_wdata    ),
      .sys_wdatam    (sys_wdatam   ),
      .sys_use_wdata (sys_use_wdata),
      .sys_vld_rdata (sys_vld_rdata), 
      .sys_chid_o    (sys_chid_o   ),
      .sys_rdata     (sys_rdata    ),
      //             
      .arb_read      (mux___read   ),
      .arb_write     (mux___write  ),
      .arb_chid      (mux___chid   ),
      .arb_burst     (mux___burst  ),
      //
      .dq            (dq   ),
      .dqm           (dqm  )
    );

  `endif 
  //--------------------------------------------------------------------------------------------------
  //
  //-------------------------------------------------------------------------------------------------- 
  `ifndef HSSDRC_DQ_PIPELINE

    hssdrc_addr_path addr_path(
      .clk         (clk  ),
      .reset       (reset),
      .sclr        (sclr ),  // use external sclr becouse there is no any fsm 
      //
      .arb_pre_all (mux___pre_all), 
      .arb_refr    (mux___refr   ), 
      .arb_pre     (mux___pre    ), 
      .arb_act     (mux___act    ), 
      .arb_read    (mux___read   ), 
      .arb_write   (mux___write  ), 
      .arb_lmr     (mux___lmr    ), 
      .arb_rowa    (mux___rowa   ), 
      .arb_cola    (mux___cola   ), 
      .arb_ba      (mux___ba     ), 
      //
      .addr        (addr ),
      .ba          (ba   ),
      .cke         (cke  ),
      .cs_n        (cs_n ),
      .ras_n       (ras_n),
      .cas_n       (cas_n),
      .we_n        (we_n )
    );

  `else 

    hssdrc_addr_path_p1 addr_path_p1(
      .clk         (clk  ),
      .reset       (reset),
      .sclr        (sclr ),  // use external sclr becouse there is no any fsm 
      //
      .arb_pre_all (mux___pre_all), 
      .arb_refr    (mux___refr   ), 
      .arb_pre     (mux___pre    ), 
      .arb_act     (mux___act    ), 
      .arb_read    (mux___read   ), 
      .arb_write   (mux___write  ), 
      .arb_lmr     (mux___lmr    ), 
      .arb_rowa    (mux___rowa   ), 
      .arb_cola    (mux___cola   ), 
      .arb_ba      (mux___ba     ), 
      //
      .addr        (addr ),
      .ba          (ba   ),
      .cke         (cke  ),
      .cs_n        (cs_n ),
      .ras_n       (ras_n),
      .cas_n       (cas_n),
      .we_n        (we_n )
    );

  `endif 

endmodule


