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
// Workfile     : tb_define.svh
// 
// Description  : testbench types, values, parameters
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


`include "hssdrc_define.vh"

`ifndef __TB_DEFINE_SVH__

  `define __TB_DEFINE_SVH__

  //
  // tb types without Z, X states
  //
  typedef bit [pColaBits  - 1 : 0] tb_cola_t; 
  typedef bit [pRowaBits  - 1 : 0] tb_rowa_t; 
  typedef bit [pBaBits    - 1 : 0] tb_ba_t; 
  typedef bit [pBurstBits - 1 : 0] tb_burst_t; 
  typedef bit [pChIdBits  - 1 : 0] tb_chid_t; 
  typedef bit [pDataBits  - 1 : 0] tb_data_t; 
  typedef bit [pDatamBits - 1 : 0] tb_datam_t;

  //
  // ram test parameters for correctness test 
  //

  localparam int cColaMaxValue  = 2**pColaBits;
  localparam int cRowaMaxValue  = 2**pRowaBits;
  localparam int cBaMaxValue    = 2**pBaBits;
  localparam int cBurstMaxValue = 2**pBurstBits;

  //
  // number of transactions in random correctness test
  // 

  localparam int cTransactionMaxValue = cColaMaxValue*cBaMaxValue*cRowaMaxValue; 

  //
  // time interval for bandwidth measure for each bandwidth measure mode 
  // 

  const time cPerfomanceInterval = 200us;//10ms;  

  //
  // number of transaction for done log message 
  //

  const int cTransactionLogPeriod = 1024;

  //
  // bandwidth measure modes
  // 
  
  typedef struct packed {
    bit  read_mode;
    bit write_mode;     
  } test_mode_t;  // used tests : 1 - write, 2 - read, 3 write -> read;

  int burst_mode        [$] = '{1, 2, 3, 4, 5};
  int address_mode      [$] = '{0, 1, 2, 3, 4, 5};
  test_mode_t test_mode [$] = '{1, 2, 3} ;

  const string test_mode_name [4] = '{
    0 : "error mode",
    1 : "sequental write", 
    2 : "sequental read",
    3 : "sequental write -> read"
  }; 

  const string burst_mode_name [7] = '{
    0 : "burst mode : {any, no cola allign}", 
    1 : "burst mode : {fixed == 1, cola allign}",
    2 : "burst mode : {fixed == 2, cola allign}",
    3 : "burst mode : {fixed == 4, cola allign}",
    4 : "burst mode : {fixed == 8, cola allign}",
    5 : "burst mode : {fixed == 16, cola allign}",    
    6 : "burst mode : {any inside [1,2, 4,8,16], cola allign}"
  }; 

  const string address_mode_name [8] = '{
    0 : "address mode : {same   bank : same row}", 
    1 : "address mode : {same   bank : any  row}", 
    2 : "address mode : {any    bank : same row}", 
    3 : "address mode : {linear bank : same row}", 
    4 : "address mode : {any    bank : any  row}", 
    5 : "address mode : {linear bank : any  row}", 
    6 : "address mode : {any  bank : any  row : ba varies more often than rowa}", 
    7 : "address mode : {any  bank : any  row : ba varies less often than rowa}"
  }; 

  //
  // virtual transaction tread types & parameters  
  //

  localparam int cTreadMaxNumber    = cBaMaxValue*cRowaMaxValue;
  localparam int cTreadPointerWidth = clogb2(cTreadMaxNumber);
  
  typedef bit [cTreadPointerWidth-1:0] sdram_tread_ptr_t;

  typedef struct {
    ba_t    ba;
    rowa_t  rowa; 
    cola_t  cola; 
    } sdram_tread_state_s_t;

  //
  // sdram transaction types 
  //

  typedef enum {cTR_WRITE, cTR_READ, cTR_REFR, 
                cTR_WRITE_LOCKED, cTR_READ_LOCKED, cTR_REFR_LOCKED
                }  tr_type_e_t;

  //
  // transaction acknowledge mailbox. use only for locked transaction
  //

  typedef mailbox #(tr_type_e_t) sdram_tr_ack_mbx; 

  //
  //
  //

`endif 
