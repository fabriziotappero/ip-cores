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
// Workfile     : hssdrc_data_path.v
// 
// Description  : sdram data (data & mask) path unit
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

`include "hssdrc_timing.vh"
`include "hssdrc_define.vh"

module hssdrc_data_path (
  clk           , 
  reset         , 
  sclr          , 
  //
  sys_wdata     ,
  sys_wdatam    ,
  sys_use_wdata ,
  sys_vld_rdata , 
  sys_chid_o    ,
  sys_rdata     ,
  //            
  arb_read      ,
  arb_write     ,
  arb_chid      ,
  arb_burst     ,
  //            
  dq            ,
  dqm     
  );

  input wire clk; 
  input wire reset; 
  input wire sclr; 

  //-------------------------------------------------------------------------------------------------- 
  // system data interface 
  //-------------------------------------------------------------------------------------------------- 

  input   data_t  sys_wdata     ; 
  input   datam_t sys_wdatam    ;   
  output  logic   sys_use_wdata ; 
  output  logic   sys_vld_rdata ;
  output  chid_t  sys_chid_o    ;
  output  data_t  sys_rdata     ;

  //-------------------------------------------------------------------------------------------------- 
  // interface from arbiter throw multiplexer 
  //-------------------------------------------------------------------------------------------------- 

  input wire          arb_read  ;
  input wire          arb_write ;
  input chid_t        arb_chid  ;
  input sdram_burst_t arb_burst ;

  //-------------------------------------------------------------------------------------------------- 
  // interface sdram chip 
  //-------------------------------------------------------------------------------------------------- 

  inout  wire   [pDataBits-1  :0] dq;
  output logic  [pDatamBits-1 :0] dqm;

  //-------------------------------------------------------------------------------------------------- 
  // Mask paramters count via pBL, pCL parameters only for clarify. 
  // unit has been designed to use fixed lengh mask patterns
  //-------------------------------------------------------------------------------------------------- 
  localparam cWDataMask = cSdramBL - 1;  // - 1 cycle for write command itself 

  localparam cRDataMask = cSdramBL - 1 + pCL - 2;  // - 1 cycle for read command itself, 
                                                   // - 2 cycle for read dqm latency 

  localparam cDataMask  = max(cWDataMask, cRDataMask);

  localparam cReadAllign = pCL + 1;  // + 1 is capture register cycle 

  //-------------------------------------------------------------------------------------------------- 
  //
  //-------------------------------------------------------------------------------------------------- 

  logic [3:0] use_wdata_srl;
  wire        use_wdata;
  wire        use_wdatam;

  logic [cDataMask-1 : 0] datam_srl; 
  logic                   datam; 


  
  logic [3:0] vld_rdata_srl;
  logic       vld_rdata;
  logic       vld_rdata_allign_srl [cReadAllign-1 : 0];

  chid_t      chid_srl [3:0];
  chid_t      chid; 
  chid_t      chid_allign_srl [cReadAllign-1 : 0];

  //-------------------------------------------------------------------------------------------------- 
  // use write data & mask 
  //-------------------------------------------------------------------------------------------------- 

  always_ff @(posedge clk or posedge reset) begin : use_wdata_generate 
    if (reset)
      use_wdata_srl <= 4'b0000; 
    else if (sclr) 
      use_wdata_srl <= 4'b0000; 
    else if (arb_write) 
      unique case (arb_burst) 
        2'h0    : use_wdata_srl <= 4'b1000;         
        2'h1    : use_wdata_srl <= 4'b1100; 
        2'h2    : use_wdata_srl <= 4'b1110; 
        2'h3    : use_wdata_srl <= 4'b1111;                 
      endcase
    else 
      use_wdata_srl <= (use_wdata_srl << 1); 
  end 

  assign use_wdata  = use_wdata_srl[3];
  assign use_wdatam = use_wdata_srl[3];

  //-------------------------------------------------------------------------------------------------- 
  // read/write data mask for command terminate  
  //-------------------------------------------------------------------------------------------------- 

  always_ff @(posedge clk or posedge reset) begin : data_burst_mask_generate 
    if (reset)
      datam_srl <= '0; 
    else if (sclr)
      datam_srl <= '0; 
    else begin  
      if (arb_write) 
        datam_srl <= WriteMaskBits(arb_burst); 
      else if (arb_read) 
        datam_srl <= ReadMaskBits(arb_burst); 
      else 
        datam_srl <= (datam_srl << 1);
    end       
  end 

  always_ff @(posedge clk or posedge reset) begin : data_mask_generate
    if (reset)
      datam <= 1'b0; 
    else if (sclr) 
      datam <= 1'b0; 
    else begin 
      if (arb_write) 
        datam <= 1'b0; 
      else if (arb_read) 
        datam <= FirstReadMaskBit(arb_burst); 
      else 
        datam <= datam_srl [cDataMask-1];
    end 
  end 

  //
  // dqm
  // 

  assign dqm = use_wdatam ? sys_wdatam : {pDatamBits{datam}};

  //-------------------------------------------------------------------------------------------------- 
  // write data request 
  //-------------------------------------------------------------------------------------------------- 

`ifndef HSSDRC_COMBINATORY_USE_WDATA   

  assign sys_use_wdata = use_wdata;

`else 

  logic [2:0] use_wdata_srl_small; 

  always_ff @(posedge clk or posedge reset) begin : use_wdata_small_generate 
    if (reset)
      use_wdata_srl_small <= 3'b000; 
    else if (sclr) 
      use_wdata_srl_small <= 3'b000; 
    else if (arb_write) 
      unique case (arb_burst) 
        2'h0    : use_wdata_srl_small <= 3'b000;
        2'h1    : use_wdata_srl_small <= 3'b100;       
        2'h2    : use_wdata_srl_small <= 3'b110;
        2'h3    : use_wdata_srl_small <= 3'b111;
      endcase
    else 
      use_wdata_srl_small <= (use_wdata_srl_small << 1); 
  end 

  assign sys_use_wdata = arb_write | use_wdata_srl_small[2];

`endif 
  //
  // dq
  // 

  assign dq = use_wdata ? sys_wdata : {pDataBits{1'bz}};

  //-------------------------------------------------------------------------------------------------- 
  // read data 
  //-------------------------------------------------------------------------------------------------- 

  always_ff @(posedge clk or posedge reset) begin : vld_rdata_generate 
    if (reset)
      vld_rdata_srl <= 4'b0000; 
    else if (sclr) 
      vld_rdata_srl <= 4'b0000; 
    else if (arb_read) 
      unique case (arb_burst) 
        2'h0    : vld_rdata_srl <= 4'b1000; 
        2'h1    : vld_rdata_srl <= 4'b1100; 
        2'h2    : vld_rdata_srl <= 4'b1110; 
        2'h3    : vld_rdata_srl <= 4'b1111;         
      endcase      
    else 
      vld_rdata_srl <= (vld_rdata_srl << 1); 
  end 

  assign vld_rdata  = vld_rdata_srl [3];

  //
  //
  //

  always_ff @(posedge clk) begin : chid_rdata_generate  
    int i;

    if (arb_read) begin 
      for (i = 0; i < 4; i++) 
        chid_srl[i] <= arb_chid; // load all with chid
    end 
    else begin 
      for (i = 1; i < 4; i++) 
        chid_srl[i] <= chid_srl[i-1]; // shift left 
    end 
  end 
  
  assign chid = chid_srl [3];

  //
  //
  //

  always_ff @(posedge clk or posedge reset) begin : vld_rdata_allign_generate 
    int i;

    if (reset) begin 
      for (i = 0; i < cReadAllign; i++) 
        vld_rdata_allign_srl[i] <= 1'b0; 
    end 
    else if (sclr) begin 
      for (i = 0; i < cReadAllign; i++) 
        vld_rdata_allign_srl[i] <= 1'b0; 
    end 
    else begin 
      vld_rdata_allign_srl[0] <= vld_rdata; // shift left

      for (i = 1; i < cReadAllign; i++) 
        vld_rdata_allign_srl[i] <= vld_rdata_allign_srl [i-1];
    end 
  end 


  assign sys_vld_rdata = vld_rdata_allign_srl [cReadAllign-1];

  //
  //
  //

  always_ff @(posedge clk) begin : chid_allign_generate 
    int i;

    chid_allign_srl[0] <= chid; // shift left 

    for (i = 1; i < cReadAllign; i++) 
      chid_allign_srl[i] <= chid_allign_srl[i-1];
  end 

  
  assign sys_chid_o    = chid_allign_srl [cReadAllign-1];

  //
  //
  //

  always_ff @(posedge clk) begin : rdata_reclock 
    sys_rdata <= dq;
  end 

  //-------------------------------------------------------------------------------------------------- 
  // function to count write bit mask pattern for different burst value and 
  // for different Cas Latency paramter value 
  // full burst == 2'h3 no need to be masked 
  //-------------------------------------------------------------------------------------------------- 

  function automatic bit [cDataMask-1:0] WriteMaskBits (input bit [1:0] burst); 
    if (pCL == 3) begin 
      WriteMaskBits = 4'b0000;
      case (burst)
        2'h0 : WriteMaskBits = 4'b1110; 
        2'h1 : WriteMaskBits = 4'b0110; 
        2'h2 : WriteMaskBits = 4'b0010;        
      endcase
    end 
    else if (pCL == 2) begin 
      WriteMaskBits = 3'b000;
      case (burst) 
        2'h0 : WriteMaskBits = 3'b111; 
        2'h1 : WriteMaskBits = 3'b011; 
        2'h2 : WriteMaskBits = 3'b001;
      endcase
    end 
    else if (pCL == 1) begin
      WriteMaskBits = 3'b000;
      case (burst) 
        2'h0 : WriteMaskBits = 3'b111; 
        2'h1 : WriteMaskBits = 3'b011; 
        2'h2 : WriteMaskBits = 3'b001;
      endcase
    end 
    else begin 
      WriteMaskBits = '0;
    end 
  endfunction

  //-------------------------------------------------------------------------------------------------- 
  // function to count first read bit mask pattern for different burst value and 
  // for different Cas Latency paramter value 
  //--------------------------------------------------------------------------------------------------  
  
  function automatic bit FirstReadMaskBit (input bit [1:0] burst); 
    if ((pCL == 1) && (burst == 0)) 
      FirstReadMaskBit = 1'b1;
    else 
      FirstReadMaskBit = 1'b0; 
  endfunction 

  //-------------------------------------------------------------------------------------------------- 
  // function to count read bit mask pattern for different burst value and 
  // for different Cas Latency paramter value 
  // full burst == 2'h3 no need to be masked 
  //--------------------------------------------------------------------------------------------------    

  function automatic bit [cDataMask-1:0] ReadMaskBits (input bit [1:0] burst); 
    if (pCL == 3) begin 
      ReadMaskBits = 4'b0000;
      case (burst)
        2'h0 : ReadMaskBits = 4'b0111; 
        2'h1 : ReadMaskBits = 4'b0011; 
        2'h2 : ReadMaskBits = 4'b0001;         
      endcase
    end 
    else if (pCL == 2) begin 
      ReadMaskBits = 3'b000;
      case (burst) 
        2'h0 : ReadMaskBits = 3'b111; 
        2'h1 : ReadMaskBits = 3'b011; 
        2'h2 : ReadMaskBits = 3'b001; 
      endcase
    end 
    else if (pCL == 1) begin
      ReadMaskBits = 3'b000;
      case (burst) 
        2'h0 : ReadMaskBits = 3'b110; 
        2'h1 : ReadMaskBits = 3'b110; 
        2'h2 : ReadMaskBits = 3'b010; 
      endcase
    end 
    else begin 
      ReadMaskBits = '0;
    end 
  endfunction

endmodule 
