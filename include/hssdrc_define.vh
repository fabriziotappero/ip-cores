//
// Project      : High-Speed SDRAM Controller with adaptive bank management and command pipeline
// 
// Project Nick : HSSDRC
// 
// Version      : 1.0-beta 
//  
// Revision     : $Revision: 1.1 $ 
// 
// Date         : $Date: 2008-03-06 13:51:55 $ 
// 
// Workfile     : hssdrc_define.vh
// 
// Description  : controller hardware paramters & settings
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


`ifndef __HSSDRC_DEFINE_VH__

  `define __HSSDRC_DEFINE_VH__

  //`define HSSDRC_DQ_PIPELINE              // uncomment when need dq data register output 
  //`define HSSDRC_REFR_HI_DISABLE          // uncomment when not need high priority refresh logic
  //`define HSSDRC_REFR_LOW_DISABLE         // uncomment when not need low  priority refresh logic
  //----------------------------------------------------------------------------------
  // default    : controller used use_wdata signal with register output type
  // optionaly  : controller can use combinative use_wdata signal which set 1 cycle early 
  //----------------------------------------------------------------------------------  
  //`define HSSDRC_COMBINATORY_USE_WDATA // uncomment when need to use non register use_wdata signal 
  //----------------------------------------------------------------------------------
  // default : decoders sharing PRE & ACT command inside sdram command pipeline waiting
  //----------------------------------------------------------------------------------
  //`define HSSDRC_NOT_SHARE_ACT_COMMAND  // uncomment for not generate logic for share ACT command
  //----------------------------------------------------------------------------------
  // default : 2 decoders sharing sdram command pipeline inside PRE & ACT command waiting
  //----------------------------------------------------------------------------------
  //`define HSSDRC_SHARE_ONE_DECODER  // uncoment for only 1 decoder share
  //`define HSSDRC_SHARE_NONE_DECODER   // uncoment for none decoder   share
  //----------------------------------------------------------------------------------
  // sdram controller command interface parameters 
  //----------------------------------------------------------------------------------
  parameter int pRowaBits   = 11; // >= 11 (0..10)
  parameter int pColaBits   =  8; // <= pRowBits
  parameter int pBaBits     =  2; // fixed == 2 (don't change !!!)
  parameter int pBurstBits  =  4; // <= 4 
  parameter int pChIdBits   =  2; // >= 1 
  //----------------------------------------------------------------------------------
  // sdram controller data interface & sdram chip data interface parameters 
  //----------------------------------------------------------------------------------
  parameter int pDataBits   = 32; // >= 8
  parameter int pDatamBits  = byte_lanes(pDataBits);
  //----------------------------------------------------------------------------------
  // sdram controller command interface parameters 
  //----------------------------------------------------------------------------------
  parameter int pSdramAddrBits  = 11; // (>= pRowaBits & >= 11)
  parameter int pSdramBurstBits = 2;  // fixed == 2 (don't change !!!)
  parameter int cSdramBL        = 2**pSdramBurstBits;
  //----------------------------------------------------------------------------------
  // sdram controller mode parameters (don't change except CL !!!!)
  //----------------------------------------------------------------------------------
  parameter  bit       pInitWBM  = 1'b0;    // write burst mode = programed burst
  parameter  bit  [1:0] pInitOM  = 1'b0;    // operation mode   = standart 
  parameter  bit  [2:0] pCL      = 3'b011;  // cas latency      = 3 
  parameter  bit        pInitBT  = 1'b0;    // burst type       = sequental 
  parameter  bit  [2:0] pInitBL  = 3'b010;  // burst            = 4   

  parameter  bit [pSdramAddrBits-1:10] pReserved = '0;
  parameter  bit [pSdramAddrBits-1: 0] cInitLmrValue = {pReserved, pInitWBM, pInitOM, pCL, pInitBT, pInitBL};
  //----------------------------------------------------------------------------------   
  // used types 
  //----------------------------------------------------------------------------------    
  typedef logic [pColaBits  - 1 : 0] cola_t; 
  typedef logic [pRowaBits  - 1 : 0] rowa_t; 
  typedef logic [pBaBits    - 1 : 0] ba_t; 
  typedef logic [pBurstBits - 1 : 0] burst_t; 
  typedef logic [pChIdBits  - 1 : 0] chid_t; 
  typedef logic [pDataBits  - 1 : 0] data_t; 
  typedef logic [pDatamBits - 1 : 0] datam_t;
   
  typedef logic [pSdramAddrBits-1 :0] sdram_addr_t; 
  typedef logic [pSdramBurstBits-1:0] sdram_burst_t; 
  //----------------------------------------------------------------------------------     
  //
  //----------------------------------------------------------------------------------     
  function automatic int clogb2 (input int data);
    int i;

    for (i = 0; 2**i < data; i++) 
      clogb2 = i + 1; 
  endfunction
  //----------------------------------------------------------------------------------     
  //
  //----------------------------------------------------------------------------------     
  function automatic int byte_lanes (input int data); 
    int num;

    byte_lanes  = 0;

    num = data;
    // synthesis translate_off
    assert (num != 0) else $error ("wrong data parameter");
    // synthesis translate_on 
    while (num > 0) begin
      byte_lanes++; 
      num = num - 8; 
    end 

  endfunction
  //----------------------------------------------------------------------------------     
  //
  //----------------------------------------------------------------------------------     
  function automatic int unsigned max(input int unsigned a, b); 
    if (a >= b) max = a; 
    else        max = b; 
  endfunction

`endif 

