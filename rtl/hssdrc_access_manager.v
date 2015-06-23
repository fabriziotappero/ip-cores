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
// Workfile     : hssdrc_access_manager.v
// 
// Description  : sdram bank access manager
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


// used command sequenceces 
// 1. {pre a -> act a -> rw a} -> {pre a -> act a -> rw a }
//                             -> {rw a }               
//                             -> {pre_all -> refr}
// 2. {pre a -> act a -> rw a} -> {pre b -> act b -> rw b }
//                             -> {act b -> rw b}
//                             -> {rw b }               
//                             -> {pre_all -> refr}
// 3. {pre_all -> refr} -> refr 
//                      -> act 
//
// just need to control : 
// +-------------------+-------------------------+--------------------------+
// | command           | sequental decoder part  | concurent/pipeline part  |
// +===================+=========================+==========================+
// | pre [0] ->        | act [0]                 |             act [1,2,3]  |
// | pre [0] ->        |                         |             pre [1,2,3]  |
// +-------------------+-------------------------+--------------------------+
// | pre [1] ->        | act [1]                 |             act [0,2,3]  |
// | pre [1] ->        |                         |             pre [0,2,3]  | 
// +-------------------+-------------------------+--------------------------+
// | pre [2] ->        | act [2]                 |             act [0,1,3]  |
// | pre [2] ->        |                         |             pre [0,1,3]  | 
// +-------------------+-------------------------+--------------------------+
// | pre [3] ->        | act [3]                 |             act [0,1,2]  |
// | pre [3] ->        |                         |             pre [0,1,2]  | 
// +-------------------+-------------------------+--------------------------+
// | act [0] ->        | write [0]               |                          |  
// | act [0] ->        |                         |    act [1,2,3]           |  
// | act [0] ->        |                         |  pre [0,1,2,3]           |  
// | act [0] ->        | read  [0]               |                          |    
// +-------------------+-------------------------+--------------------------+  
// | act [1] ->        | write [1]               |                          |  
// | act [1] ->        |                         |    act [0,2,3]           |  
// | act [1] ->        |                         |  pre [0,1,2,3]           |  
// | act [1] ->        | read  [1]               |                          |    
// +-------------------+-------------------------+--------------------------+  
// | act [2] ->        | write [2]               |                          |  
// | act [2] ->        |                         |    act [0,1,3]           |  
// | act [2] ->        |                         |  pre [0,1,2,3]           |  
// | act [2] ->        | read  [2]               |                          |    
// +-------------------+-------------------------+--------------------------+  
// | act [3] ->        | write [3]               |                          |  
// | act [3] ->        |                         |    act [0,1,2]           |  
// | act [3] ->        |                         |  pre [0,1,2,3]           |  
// | act [3] ->        | read  [3]               |                          |    
// +-------------------+-------------------------+--------------------------+
// | write/read [0] -> |                         |  pre [0,1,2,3]           |
// | write/read [0] -> |                         |    act [1,2,3]           |
// | write/read [0] -> |                         |  write[0,1,2,3]          |
// | write/read [0] -> |                         |  read [0,1,2,3]          |
// +-------------------+-------------------------+--------------------------+
// | write/read [1] -> |                         |  pre [0,1,2,3]           |
// | write/read [1] -> |                         |    act [0,2,3]           |
// | write/read [1] -> |                         |  write[0,1,2,3]          |
// | write/read [1] -> |                         |  read [0,1,2,3]          |
// +-------------------+-------------------------+--------------------------+
// | write/read [2] -> |                         |  pre [0,1,2,3]           |
// | write/read [2] -> |                         |    act [0,1,3]           |
// | write/read [2] -> |                         |  write[0,1,2,3]          |
// | write/read [2] -> |                         |  read [0,1,2,3]          |
// +-------------------+-------------------------+--------------------------+
// | write/read [3] -> |                         |  pre [0,1,2,3]           |
// | write/read [3] -> |                         |    act [0,1,2]           |
// | write/read [3] -> |                         |  write[0,1,2,3]          |
// | write/read [3] -> |                         |  read [0,1,2,3]          |
// +-------------------+-------------------------+--------------------------+
// | pre_all  ->       | refr                    |                          | 
// |                   |                         |                          |
// +-------------------+-------------------------+--------------------------+
// | refr     ->       |                         | refr                     |
// | refr     ->       |                         | act[0,1,2,3]             |
// +-------------------+-------------------------+--------------------------+
//
//
//
// +-----------------+---------------+-----------------+---------------------+-----------+
// | past command    | control tread | current command | contol time value   | note      |
// +=================+===============+=================+=====================+===========+
// | act   [0]       |   0           | pre [0]         | Tras                |           |
// | write [0]       |   1           |                 | Twr + Burst         |  1,2,3    |
// | read  [0]       |   2           |                 |       Burst         |  bank     |
// | pre   [1,2,3]   |               |                 | 0                   |   is      |
// | act   [1,2,3]   |               |                 | 0                   |  same     |
// | write [1,2,3]   |               |                 | 0                   |           |
// | read  [1,2,3]   |               |                 | 0                   |           |
// +-----------------+---------------+-----------------+---------------------+-----------+
// | pre   [0]       |   3 [1]_      | act [0]         | Trp                 |           |
// | refr            |   4           |                 | Trfc                |  1,2,3    |
// | act   [0]       |   5           |                 | Trc                 |           |  
// | act   [1,2,3]   |   6           |                 | Trrd                |  bank     |
// | pre   [1,2,3]   |               |                 | 0                   |   is      |
// | write [1,2,3]   |               |                 | 0                   |  same     |
// | read  [1,2,3]   |               |                 | 0                   |           |
// +-----------------+---------------+-----------------+---------------------+-----------+
// | act   [0]       |   7 [1]_      | write [0]       | Trcd                |  1,2,3    |
// | write [0,1,2,3] |   8           |                 | Burst               |  bank     |
// | read  [0,1,2,3] |   9           |                 | Burst + CL + 1(?bta)|   is      |
// |                 |               |                 |                     |  same     |
// +-----------------+---------------+-----------------+---------------------+-----------+
// | act   [0]       |   10 [1]_     | read  [0]       | Trcd                |  1,2,3    |
// | write [0,1,2,3] |   11          |                 | Burst + 1(?bta)     |  bank     |
// | read  [0,1,2,3] |   12          |                 | Burst               |   is      |
// |                 |               |                 |                     |  same     |
// +-----------------+---------------+-----------------+---------------------+-----------+
// | pre_all         |   13          | refr            | Trp                 |           |
// | refr            |   14          |                 | Trfc                |           |
// +-----------------+---------------+-----------------+---------------------+-----------+
//
//  ..[1] Trp (pre -> act) & Trcd (act -> read/write) contolled internal in decoder FSM 
//

`include "hssdrc_timescale.vh"

`include "hssdrc_define.vh"
`include "hssdrc_timing.vh"

module hssdrc_access_manager (
  clk               ,
  reset             ,
  sclr              ,
  //
  arb_pre_all       , 
  arb_refr          ,
  arb_pre           ,
  arb_act           ,
  arb_read          ,
  arb_write         ,
  arb_ba            ,
  arb_burst         ,
  //
  am_pre_all_enable ,
  am_refr_enable    ,
  am_pre_enable     ,
  am_act_enable     ,
  am_read_enable    ,
  am_write_enable  
  );

  input wire clk;
  input wire reset;
  input wire sclr;

  //--------------------------------------------------------------------------------------------------
  // interface from output arbiter 
  //-------------------------------------------------------------------------------------------------- 

  input logic         arb_pre_all  ;
  input logic         arb_refr     ;
  input logic         arb_pre      ;
  input logic         arb_act      ;
  input logic         arb_read     ;
  input logic         arb_write    ;
  input ba_t          arb_ba       ;
  input sdram_burst_t arb_burst    ;

  //--------------------------------------------------------------------------------------------------
  // outputs 
  //-------------------------------------------------------------------------------------------------- 

  output logic       am_pre_all_enable  ;
  output logic       am_refr_enable     ;
  output logic [0:3] am_pre_enable      ;
  output logic [0:3] am_act_enable      ;
  output logic [0:3] am_read_enable     ;
  output logic [0:3] am_write_enable    ;


  //-------------------------------------------------------------------------------------------------- 
  // all timings is select using shift register techique. 
  // enable is 1'b1 level on output. 
  // all shift is shift rigth. 
  // shift register command load pattern is 'b{{x{1'b0}}, {y{1'b1}}} 
  //-------------------------------------------------------------------------------------------------- 

  //-------------------------------------------------------------------------------------------------- 
  // take into acount load shift register cycle 
  //-------------------------------------------------------------------------------------------------- 

  localparam int cTras_m1     =    cTras - 1;
  localparam int cTrfc_m1     =    cTrfc - 1;
//  localparam int  cTrc_m1     =     cTrc - 1; tras + trp contolled  
//  localparam int cTrcd_m1     =    cTrcd - 1; fsm contolled 
  localparam int  cTwr_m1     =     cTwr - 1;
  localparam int  cTrp_m1     =     cTrp - 1; 
  localparam int cTrrd_m1     =    cTrrd - 1;
  localparam int cSdramBL_m1  = cSdramBL - 1;

  //-------------------------------------------------------------------------------------------------- 
  // tread 0/1/2 : Tras (act -> pre) & Twr + Burst (write -> pre) & Burst (read -> write) 
  // Twr + Burst & Burst control via one register becouse write/read has atomic access
  //--------------------------------------------------------------------------------------------------  

  localparam int cPreActEnableLength  = max(cTwr_m1 + cSdramBL_m1, cTras_m1); 
  localparam int cPreRwEnableLength   = max(cTwr_m1 + cSdramBL_m1, cTras_m1);

  typedef logic [cPreActEnableLength-1:0]   pre_act_enable_srl_t; 
  typedef logic [cPreRwEnableLength-1 :0]   pre_rw_enable_srl_t; 

  // to pre load patterns
  localparam pre_act_enable_srl_t cPreActEnableInitValue  = {cPreActEnableLength{1'b1}}; 
  localparam pre_act_enable_srl_t cPreActEnableActValue   = PercentRelation(cTras_m1, cPreActEnableLength);

  // to pre load patterns
  localparam pre_rw_enable_srl_t  cPreRwEnableInitValue   = {cPreRwEnableLength{1'b1}};

  // Remember : burst already has -1 offset (!!!!)
  function automatic pre_rw_enable_srl_t PreRwEnableWriteValue (input sdram_burst_t burst);     
    PreRwEnableWriteValue = PercentRelation (cTwr_m1 + burst, cPreRwEnableLength);    
  endfunction

  function automatic pre_rw_enable_srl_t PreRwEnableReadValue (input sdram_burst_t burst);     
    PreRwEnableReadValue = PercentRelation (burst, cPreRwEnableLength); 
  endfunction

  // each bank has own control registers 
  pre_act_enable_srl_t pre_act_enable_srl [0:3]; 
  pre_rw_enable_srl_t  pre_rw_enable_srl  [0:3]; 

  wire [0:3] pre_enable ;

  genvar p; 

  generate  
    
    for (p = 0; p < 4; p++) begin : pre_enable_generate

      always_ff @(posedge clk or posedge reset) begin : pre_enable_shift_register 

        if (reset)
          pre_act_enable_srl [p] <= cPreActEnableInitValue;          
        else if (sclr) 
          pre_act_enable_srl [p] <= cPreActEnableInitValue;
        else begin 
          if (arb_act && (arb_ba == p)) 
            pre_act_enable_srl [p] <= cPreActEnableActValue;
          else 
            pre_act_enable_srl [p] <= (pre_act_enable_srl [p] << 1) | 1'b1;
        end 


        if (reset)
          pre_rw_enable_srl [p] <= cPreRwEnableInitValue; 
        else if (sclr) 
          pre_rw_enable_srl [p] <= cPreRwEnableInitValue; 
        else begin 
          if (arb_write && (arb_ba == p))
            pre_rw_enable_srl [p] <= PreRwEnableWriteValue (arb_burst) & ((pre_act_enable_srl [p] << 1) | 1'b1); 
          else if (arb_read && (arb_ba == p))
            pre_rw_enable_srl [p] <= PreRwEnableReadValue (arb_burst)  & ((pre_act_enable_srl [p] << 1) | 1'b1); 
          else 
            pre_rw_enable_srl [p] <= (pre_rw_enable_srl [p] << 1) | 1'b1;
        end 

      end 

      assign pre_enable [p] = pre_rw_enable_srl  [p] [cPreRwEnableLength-1] ; 

    end 

  endgenerate

  //-------------------------------------------------------------------------------------------------- 
  // pre_all_enable has same logic as pre enable. 
  // pre_all_enable == &(pre_enable), but for increase performance it have own control registers 
  //--------------------------------------------------------------------------------------------------  

  pre_act_enable_srl_t pre_all_act_enable_srl ;
  pre_rw_enable_srl_t  pre_all_rw_enable_srl  ;

  wire pre_all_enable;

  always_ff @(posedge clk or posedge reset) begin : pre_all_enable_shift_register 

    if (reset) 
      pre_all_act_enable_srl <= cPreActEnableInitValue;
    else if (sclr) 
      pre_all_act_enable_srl <= cPreActEnableInitValue;
    else begin 
      if (arb_act) 
        pre_all_act_enable_srl <= cPreActEnableActValue; 
      else 
        pre_all_act_enable_srl <= (pre_all_act_enable_srl << 1) | 1'b1;  
    end 


    if (reset) 
      pre_all_rw_enable_srl <= cPreRwEnableInitValue; 
    else if (sclr) 
      pre_all_rw_enable_srl <= cPreRwEnableInitValue; 
    else begin 
      if (arb_write) 
        pre_all_rw_enable_srl <= PreRwEnableWriteValue (arb_burst) & ((pre_all_act_enable_srl << 1) | 1'b1);
      else if (arb_read) 
        pre_all_rw_enable_srl <= PreRwEnableReadValue  (arb_burst) & ((pre_all_act_enable_srl << 1) | 1'b1);
      else 
        pre_all_rw_enable_srl <= (pre_all_rw_enable_srl << 1) | 1'b1; 
    end 

  end 

  assign pre_all_enable = pre_all_rw_enable_srl [cPreRwEnableLength-1];

  //-------------------------------------------------------------------------------------------------- 
  // tread 4/5/6 : Trfc (refr -> act) & Trc (act -> act) & Trrd (act a -> act b)
  // Trc don't need to be contolled, becouse Trc = Tras + Trcd
  // Trfc & Trrd control via one register becouse refr -> any act has locked & sequental access.
  // for Trc we can use 1 register, becouse act a -> act a is imposible sequence 
  //--------------------------------------------------------------------------------------------------  

  localparam int cActEnableLength = max (cTrfc_m1, cTrrd_m1);

  typedef logic [cActEnableLength-1:0]  act_enable_srl_t;   

  // to act load patterns
  localparam act_enable_srl_t cActEnableInitValue = {cActEnableLength{1'b1}};
  localparam act_enable_srl_t cActEnableRefrValue = PercentRelation(cTrfc_m1, cActEnableLength);
  localparam act_enable_srl_t cActEnableActValue  = PercentRelation(cTrrd_m1, cActEnableLength);

  act_enable_srl_t   act_enable_srl ;

  wire [0:3] act_enable ;

  always_ff @(posedge clk or posedge reset) begin : act_enable_shift_register 

    if (reset)
      act_enable_srl <= cActEnableInitValue; 
    else if (sclr) 
      act_enable_srl <= cActEnableInitValue; 
    else begin 

      if (arb_refr) 
        act_enable_srl <= cActEnableRefrValue; 
      else if (arb_act) 
        act_enable_srl <= cActEnableActValue;
      else 
        act_enable_srl <= (act_enable_srl << 1) | 1'b1;

    end 
  end 

  assign act_enable = {4{act_enable_srl [cActEnableLength-1]}} ;
   
  //-------------------------------------------------------------------------------------------------- 
  // tread 8/9 : Burst (write -> write) & Burst + CL + BTA (read -> write).
  // control via one register becouse write/read -> write is atomic sequental access.
  //-------------------------------------------------------------------------------------------------- 

  localparam int cWriteEnableLength = max (cSdramBL_m1, cSdramBL_m1 + pCL + pBTA); 

  typedef logic [cWriteEnableLength-1:0] write_enable_srl_t; 

  // to write load patterns
  localparam write_enable_srl_t cWriteEnableInitValue = {cWriteEnableLength{1'b1}};

  // Remember : burst already has -1 offset (!!!!)
  function automatic write_enable_srl_t WriteEnableWriteValue (input sdram_burst_t burst); 
    WriteEnableWriteValue = PercentRelation(burst, cWriteEnableLength);
  endfunction

  function automatic write_enable_srl_t WriteEnableReadValue (input sdram_burst_t burst); 
    WriteEnableReadValue = PercentRelation(burst + pCL + pBTA, cWriteEnableLength);
  endfunction

  write_enable_srl_t  write_enable_srl; 

  wire [0:3] write_enable ;

  always_ff @(posedge clk or posedge reset) begin : write_enable_shift_register

    if (reset)
      write_enable_srl <= cWriteEnableInitValue; 
    else if (sclr)
      write_enable_srl <= cWriteEnableInitValue;
    else begin
      if (arb_write) 
        write_enable_srl <= WriteEnableWriteValue (arb_burst);         
      else if (arb_read) 
        write_enable_srl <= WriteEnableReadValue (arb_burst); 
      else 
        write_enable_srl <= (write_enable_srl << 1) | 1'b1;
    end 
  end 

  assign write_enable = {4{write_enable_srl [cWriteEnableLength-1]}};

  //-------------------------------------------------------------------------------------------------- 
  // tread 11/12 : Burst + BTA (write -> read) & Burst (read -> read).
  // contorl via one register becouse write/read -> read is atomic sequental access
  // BTA from write -> read is not need !!! becouse read have read latency !!!!
  //-------------------------------------------------------------------------------------------------- 
  
  localparam int cReadEnableLength = max(cSdramBL_m1, cSdramBL_m1); 

  typedef logic [cReadEnableLength-1:0] read_enable_srl_t;

  // to read load patterns
  localparam read_enable_srl_t cReadEnableInitValue   = {cReadEnableLength{1'b1}}; 
  // Remember : burst already has -1 offset (!!!!)
  function automatic read_enable_srl_t ReadEnableWriteValue (input sdram_burst_t burst); 
    ReadEnableWriteValue = PercentRelation(burst, cReadEnableLength); 
  endfunction

  function automatic read_enable_srl_t ReadEnableReadValue (input sdram_burst_t burst); 
    ReadEnableReadValue = PercentRelation(burst, cReadEnableLength); 
  endfunction

  read_enable_srl_t read_enable_srl;

  wire [0:3] read_enable ;

  always_ff @(posedge clk or posedge reset) begin : read_enable_shift_register 

    if (reset)
      read_enable_srl <= cReadEnableInitValue;       
    else if (sclr) 
      read_enable_srl <= cReadEnableInitValue;      
    else begin 
      if (arb_write) 
        read_enable_srl <= ReadEnableWriteValue (arb_burst);         
      else if (arb_read) 
        read_enable_srl <= ReadEnableReadValue (arb_burst);         
      else 
        read_enable_srl <= (read_enable_srl << 1) | 1'b1;
    end 

  end 

  assign read_enable = {4{read_enable_srl [cReadEnableLength-1]}};

  //-------------------------------------------------------------------------------------------------- 
  // tread 13/14 : Trp (pre_all -> refr) & Trfc (refr -> refr).
  // contol via one register becouse pre_all/refr has locked access & (pre_all -> refr) has sequental access
  //--------------------------------------------------------------------------------------------------  

  localparam int cRefrEnableLength = max (cTrp_m1, cTrfc_m1); 

  typedef logic [cRefrEnableLength-1:0] refr_enable_srl_t; 

  // to refr load patterns
  localparam refr_enable_srl_t cRefrEnableInitValue   = {cRefrEnableLength{1'b1}};
  localparam refr_enable_srl_t cRefrEnablePreAllValue = PercentRelation( cTrp_m1, cRefrEnableLength);
  localparam refr_enable_srl_t cRefrEnableRefrValue   = PercentRelation(cTrfc_m1, cRefrEnableLength);

  refr_enable_srl_t refr_enable_srl; 

  wire refr_enable;

  always_ff @(posedge clk or posedge reset) begin : refr_enable_shift_register 

    if (reset)
      refr_enable_srl <= cRefrEnableInitValue;       
    else if (sclr)
      refr_enable_srl <= cRefrEnableInitValue; 
    else begin 
      if (arb_pre_all) 
        refr_enable_srl <= cRefrEnablePreAllValue;        
      else if (arb_refr) 
        refr_enable_srl <= cRefrEnableRefrValue;         
      else 
        refr_enable_srl <= (refr_enable_srl << 1) | 1'b1;
    end 

  end 

  assign refr_enable = refr_enable_srl [cRefrEnableLength-1];

  //--------------------------------------------------------------------------------------------------  
  // output mapping 
  //-------------------------------------------------------------------------------------------------- 
  
  assign am_pre_all_enable = pre_all_enable;
  assign am_refr_enable    = refr_enable; 
  assign am_act_enable     = act_enable;  
  assign am_pre_enable     = pre_enable;
  assign am_write_enable   = write_enable;
  assign am_read_enable    = read_enable;

  //-------------------------------------------------------------------------------------------------- 
  // function to generate 'b{{{data}1'b0}, {{length-data}{1'b1}}} shift register load pattern 
  //-------------------------------------------------------------------------------------------------- 

  function automatic int unsigned PercentRelation (input int unsigned data, length);
    int unsigned value; 
    int i;
    int ones_num;

    value = 0;
    ones_num = length - data; // number of ones from lsb in constant vector 
    for ( i = 0; i < length; i++) begin
      if (i < ones_num) value[i] = 1'b1; 
      else              value[i] = 1'b0;
    end

    return value;       
  endfunction


endmodule 

