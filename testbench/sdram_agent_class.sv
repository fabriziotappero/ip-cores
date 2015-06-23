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
// Workfile     : sdram_agent_class.sv
// 
// Description  : agent for connect with hssdrc controller via driver
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
`include "sdram_transaction_class.sv"

class sdram_agent_class; 

  // to hssdrc_driver 
  sdram_tr_mbx in_mbx; 

  // input transaction 
  sdram_tr_mbx write_tr_mbx;  
  sdram_tr_mbx read_tr_mbx;

  // tb syncronization : transaction done numbers 
  int write_tr_done_num;      
  int  read_tr_done_num;

  // acknowledge from driver 
  sdram_tr_ack_mbx done_mbx;   

  //
  //
  //

  function new (sdram_tr_mbx in_mbx, sdram_tr_ack_mbx done_mbx, sdram_tr_mbx write_tr_mbx, read_tr_mbx); 
    
    this.in_mbx   = in_mbx; 

    this.done_mbx = done_mbx;

    this.write_tr_mbx = write_tr_mbx;
    this.read_tr_mbx  = read_tr_mbx;

  endfunction

  //
  //
  //

  task SetTransaction (sdram_transaction_class tr);     
    tr_type_e_t ret_code;

    in_mbx.put (tr);

    case (tr.tr_type) 
      cTR_WRITE_LOCKED, cTR_READ_LOCKED, cTR_REFR_LOCKED : done_mbx.get (ret_code);
      default : begin end 
    endcase 

  endtask

  //
  //
  //

  task run_write_read (); 

    fork 
      write_read();
    join_none 

  endtask

  //
  //
  //

  task stop_write_read (); 
    disable this.run_write_read;
  endtask

  //
  //
  //

  task write_read (); 
    const int sequental_tr_max_num = 6;

    int tr_num;
    
    int write_tr_max_num; 
    int  read_tr_max_num; 

    int avail_read_tr_num;

    sdram_transaction_class write_tr;
    sdram_transaction_class read_tr;

    write_tr_done_num = 0;
    read_tr_done_num  = 0; 

    forever begin 

      //
      // if there is something to write 
      // 
      assert ( std::randomize(write_tr_max_num) with {write_tr_max_num inside {[1:sequental_tr_max_num]};} )

      for (tr_num = 0; tr_num < write_tr_max_num; tr_num++) begin : write_state 

        if (!write_tr_mbx.try_get (write_tr)) 
          break; 
          
        SetTransaction (write_tr); 

        write_tr_done_num++;   
      end : write_state

      //
      // read 
      // 

      assert ( std::randomize(read_tr_max_num) with {read_tr_max_num inside {[1:sequental_tr_max_num]};} );

      avail_read_tr_num = write_tr_done_num - read_tr_done_num; 

      if (read_tr_max_num > avail_read_tr_num)
        read_tr_max_num = avail_read_tr_num;

      for (tr_num = 0; tr_num < read_tr_max_num; tr_num++) begin : read_state

        if (!read_tr_mbx.try_get(read_tr))
          break;
        
        SetTransaction (read_tr);

        read_tr_done_num++;
      end : read_state 

      #10;
    end 

  endtask

endclass 
