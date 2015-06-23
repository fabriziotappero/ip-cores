//
// Project      : High-Speed SDRAM Controller with adaptive bank management and command pipeline
// 
// Project Nick : HSSDRC
// 
// Version      : 1.0-beta 
//  
// Revision     : $Revision: 1.1 $ 
// 
// Date         : $Date: 2008-03-06 13:54:00 $ 
// 
// Workfile     : hssrdc_scoreboard_class.sv
// 
// Description  : scoreboard for test read transaction  
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



`include "tb_define.svh"

`include "message_class.sv"
`include "hssrdc_driver_cbs_class.sv"

class hssdrc_scoreboard_class extends hssrdc_driver_cbs_class; 

  sdram_tr_mbx   out_mbx; 
  message_class  msg; 

  event done; 

  function new (message_class msg, ref event done); 
    
    this.msg      = msg; 

    this.done     = done;

  endfunction

  int checked_tr_num;
  int check_err_num;

  //
  // 
  //

  task start ();
    checked_tr_num = 0; 
    check_err_num  = 0;
  endtask 

  //
  //
  //

  virtual task post_ReadData (input realtime t, sdram_transaction_class tr); 
    tb_data_t golden_data2cmp; 
    tb_data_t data2cmp;

    tb_chid_t golden_chid2cmp;
    tb_chid_t chid2cmp;

    tb_datam_t datam;

    int burst;

    string str; 
  begin 

    burst = tr.burst + 1; 

    golden_chid2cmp = tr.chid; 

    for (int i = 0; i < burst; i++) begin 

      datam           = tr.wdatam [i];

      data2cmp        = MaskData(tr.rdata [i], datam);
      golden_data2cmp = MaskData(tr.wdata [i], datam);

      chid2cmp = tr.rchid [i];

      if (data2cmp !== golden_data2cmp) begin         
        str = $psprintf("data compare error at ba = %0d, rowa = %0d, cola = %0d : ", tr.ba, tr.rowa, tr.cola); 
        str = {str, ($psprintf("write data %h : read data %h", golden_data2cmp, data2cmp))};
        msg.err(str);

        check_err_num++; 
      end 

      if (chid2cmp !== golden_chid2cmp) begin 
        str = $psprintf("chid compare error at ba = %0d, rowa = %0d, cola = %0d : ", tr.ba, tr.rowa, tr.cola); 
        str = {str, ($psprintf("write chid %h : read chid %h", golden_chid2cmp, chid2cmp))};
        msg.err(str);

        check_err_num++; 
      end 

    end   

    checked_tr_num++; 
    -> done;
  end     
  endtask

  //
  //
  //
    
  function data_t MaskData (input tb_data_t data, tb_datam_t datam);
    if (datam == 0) 
      MaskData = data;
    else begin 
      for (int m = 0; m < $size(datam); m++) begin 
        for (int b = 0; b < 8; b++) begin 
          MaskData[8*m + b] = data [8*m + b] & ~datam[m];
        end 
      end 
    end 
  endfunction

endclass 
