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
// Workfile     : sdram_transaction_class.sv
// 
// Description  : sdram transaction structure
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
`include "tb_define.svh"

`ifndef __SDRAM_TRANSACTION_CLASS_SV__

`define __SDRAM_TRANSACTION_CLASS_SV__

  class sdram_transaction_class; 
  
    // transaction id 
    int id;
    // transacton type for driver 
    tr_type_e_t tr_type ;
    // input sdram path 
    rand tb_ba_t        ba      ;  
    rand tb_rowa_t      rowa    ;
    rand tb_cola_t      cola    ;
    rand tb_burst_t     burst   ; 
    rand tb_chid_t      chid    ;  
    // input data path
    rand tb_data_t  wdata   [0:cBurstMaxValue-1];
         tb_datam_t wdatam  [0:cBurstMaxValue-1];
    // output data path
    tb_data_t  rdata [0:cBurstMaxValue-1];
    tb_chid_t  rchid [0:cBurstMaxValue-1];

    // random generate controls 
    int burst_random_mode   = 0;
    int address_random_mode = 0;
    // used in random generate variables 
    tb_ba_t    last_used_ba; 
    tb_rowa_t  last_used_rowa; 

    
    function new (int id = 0, tr_type_e_t tr_type = cTR_WRITE, int ba = 0, rowa = 0, cola = 0, burst = 1, chid = 0);

      this.id       = id;
      this.tr_type  = tr_type;
      this.ba       = ba;
      this.rowa     = rowa;
      this.cola     = cola;
      this.burst    = burst - 1;
      this.chid     = chid;

    endfunction

    //
    // function to generate linear data packet
    //     

    function void GetLinearPacket;
      data_t tmp_data;
    begin
    
      tmp_data  = {ba, rowa, this.cola}; 
      
      for (int i = 0; i <= burst; i++)
        wdata  [i] = tmp_data + i + 1;         

      wdatam = '{default : 0};
    end 
    endfunction

    //
    //
    //

    function void GetRandomPacket;
      data_t tmp_data;
    begin
    
      assert ( std::randomize(wdata)) else $error ("random packet generate");

      wdatam = '{default : 0};

    end 
    endfunction

    //
    // randomize callback function to store transaction addres's
    //
    function void post_randomize(); 
      last_used_ba   = ba; 
      last_used_rowa = rowa;
    endfunction 

    // 
    // constraint for use for performance measuring 
    // 

    // burst constraint

    // mode 0 : any birst, no cola allign 

    // mode 1 : fixed burst = 1, cola allign 
    constraint burst_constraint_1 { (burst_random_mode == 1) -> burst == 0; }
    // mode 2 : fixed burst = 2, cola allign  
    constraint burst_constraint_2 { (burst_random_mode == 2) -> burst == 1; }
    // mode 3 : fixed burst = 4, cola allign  
    constraint burst_constraint_3 { (burst_random_mode == 3) -> burst == 3; }
    // mode 4 : fixed burst == 8, cola allign  
    constraint burst_constraint_4 { (burst_random_mode == 4) -> burst == 7; }
    // mode 5 : fixed burst == 16, cola allign  
    constraint burst_constraint_5 { (burst_random_mode == 5) -> burst == 15; }
    // mode 6 : max performance burst, cola allign  
    constraint burst_constraint_6 { (burst_random_mode == 6) -> burst inside {0, 1, 3, 7, 15}; }

    // cola constraint
    constraint cola_constraint { (burst_random_mode != 0) -> 
      (burst == 1)  -> (cola[0]   == 0);
      (burst == 3)  -> (cola[1:0] == 0);
      (burst == 7)  -> (cola[2:0] == 0);
      (burst == 15) -> (cola[3:0] == 0);    
    }

    constraint burst_order {solve burst before cola; } 

    // address constraint 

    // mode 0 : same bank same row 
    constraint address_constraint_0 { (address_random_mode == 0) -> {
      (ba   == last_used_ba); 
      (rowa == last_used_rowa); 
      }
    }
    // mode 1 : same bank 
    constraint address_constraint_1 { (address_random_mode == 1) -> {
      (ba   == last_used_ba); 
      (rowa != last_used_rowa);
      }
    }
    // mode 2 : any bank same row
    constraint address_constraint_2 { (address_random_mode == 2) -> {
      (ba   != last_used_ba); 
      (rowa == last_used_rowa); 
      }
    }
    // mode 3 : linear bank same row 
    constraint address_constraint_3 { (address_random_mode == 3) -> {
      (last_used_ba == 0) -> (ba == 1);
      (last_used_ba == 1) -> (ba == 2);
      (last_used_ba == 2) -> (ba == 3);
      (last_used_ba == 3) -> (ba == 0);
      (rowa == last_used_rowa); 
      }
    }
    // mode 4 : any bank any row 
    constraint address_constraint_4 { (address_random_mode == 4) -> {
      (ba   != last_used_ba); 
      (rowa != last_used_rowa); 
      }
    }
    // mode 5 : linear bank any row 
    constraint address_constraint_5 { (address_random_mode == 5) -> {
      (last_used_ba == 0) -> (ba == 1);
      (last_used_ba == 1) -> (ba == 2);
      (last_used_ba == 2) -> (ba == 3);
      (last_used_ba == 3) -> (ba == 0);
      (rowa != last_used_rowa); 
      }
    }
    // mode 6 : ba varies more often than rowa 
    constraint address_constraint_6 { (address_random_mode == 6) -> {
      ba    dist { (ba    == last_used_ba)    := 1, (ba   != last_used_ba)    :/5}; // 1/6 const ba  
      rowa  dist { (rowa  == last_used_rowa)  := 5, (rowa != last_used_rowa)  :/1}; // 5/6 const rowa
      }
    } 
    // mode 7 : ba varies less often than rowa 
    constraint address_constraint_7 { (address_random_mode == 7) -> {
      ba    dist { (ba    == last_used_ba)    := 3, (ba   != last_used_ba)    :/1}; // 75% const ba  
      rowa  dist { (rowa  == last_used_rowa)  := 1, (rowa != last_used_rowa)  :/3}; // 25% const rowa
      }
    } 

  endclass 
  //
  // mailbox for connet agent with driver 
  //   
  typedef mailbox #(sdram_transaction_class)    sdram_tr_mbx; 

`endif 
