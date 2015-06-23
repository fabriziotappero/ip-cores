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
// Workfile     : hssdrc_driver_class.sv
// 
// Description  : low level API driver for hssdrc_controller
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



`include "hssdrc_tb_sys_if.vh"

`include "hssdrc_define.vh"

`include "tb_define.svh"

`include "hssrdc_driver_cbs_class.sv"

`ifndef __HSSDRC_DRIVER_SV__

  `define __HSSDRC_DRIVER_SV__

  class hssrdc_driver_class; 
  
    // callback quene 
    hssrdc_driver_cbs_class cbs[$];
  
    // mailboxes to connect with transaction agent
    sdram_tr_mbx in_mbx; 
  
    // mailbox for connect command path with data path of this driver   
    sdram_tr_mbx wdata_mbx;
    sdram_tr_mbx rdata_mbx; 
  
    // 
    virtual hssdrc_tb_sys_if sys_if;
  
    // acknowledge mailbox for agent. used in locked transaction only 
    sdram_tr_ack_mbx done_mbx; 

    // feedback to tb for waiting event 
    event write_done; 
    event read_done; 

    // driver work modes 
    bit random_delay_mode = 0;
    bit debug             = 0;

    //
    //
    //

    function new (virtual hssdrc_tb_sys_if sys_if,  sdram_tr_mbx in_mbx, sdram_tr_ack_mbx done_mbx);
  
      this.sys_if   = sys_if;
  
      this.in_mbx   = in_mbx;
  
      this.done_mbx = done_mbx;
  
      // internal not sized mailboxes : all must be controlled via in_mbx, out_mbx size
      wdata_mbx = new; 
      rdata_mbx = new;
      
    endfunction
  
    //
    // init interface task 
    //

    task init; 
      sys_if.cb.write   <= 1'b0;
      sys_if.cb.read    <= 1'b0;
      sys_if.cb.refr    <= 1'b0; 
      sys_if.cb.cola    <= '0;
      sys_if.cb.rowa    <= '0;
      sys_if.cb.ba      <= '0;
      sys_if.cb.chid_i  <= '0;
      sys_if.cb.burst   <= '0;
      sys_if.cb.wdata   <= '0;
      sys_if.cb.wdatam  <= '0;    
    endtask

    //
    // start driver task 
    // 

    task run; 
      init ();
      fork 
        CommandDriver   (); 
        WriteDataDriver (); 
        ReadDataDriver  ();
      join_none; 
    endtask

    //
    // stop driver task 
    // 

    task stop (); 
      disable this.CommandDriver;
      disable this.WriteDataDriver;
      disable this.ReadDataDriver;
    endtask

    //-----------------------------------------------------------------------
    // command driver 
    //-----------------------------------------------------------------------

    task CommandDriver; 
      sdram_transaction_class tr; 
  
      bit [4:0] delay;  // max delay is 32 bit 
      
    begin     
  
      @(sys_if.cb); 
      forever begin
  
        // syncronize mailbox to clock 
        if ( !in_mbx.try_get(tr) ) begin 
          @(sys_if.cb); 
          continue;
        end 
  
        if (debug) begin 
          if ((tr.tr_type == cTR_READ) || (tr.tr_type == cTR_READ_LOCKED)) 
            $display("%0t cmd get READ transaction id = %0d", $time, tr.id);
          else if ((tr.tr_type == cTR_WRITE) || (tr.tr_type == cTR_WRITE_LOCKED))
            $display("%0t cmd get WRITE transaction id = %0d", $time, tr.id);
        end  
  
        if (random_delay_mode) begin
          assert (std::randomize(delay) with {delay dist {0 := 1, !0 :/ 2};}) else 
            $error ("random delay generate error");
          
          repeat (delay) @(sys_if.cb);
        end
        
        
        // set command on interface
        SetCommand(tr);
  
        // if need callbacks
        foreach ( cbs [i] ) cbs[i].post_Command ($realtime);
  
        // set command for write/read drivers
        case (tr.tr_type)
          cTR_WRITE, cTR_WRITE_LOCKED : wdata_mbx.put (tr);
          cTR_READ , cTR_READ_LOCKED  : rdata_mbx.put (tr);
        endcase
  
        // for locked transactions wait done and set acknowledge
        case (tr.tr_type)
          cTR_WRITE_LOCKED : begin
            @(write_done);
            done_mbx.put (cTR_WRITE_LOCKED);
          end
          cTR_READ_LOCKED  : begin
            @(read_done);
            done_mbx.put(cTR_READ_LOCKED);
          end
          cTR_REFR_LOCKED : begin
            done_mbx.put (cTR_WRITE_LOCKED);
          end
        endcase
  
      end
    end 
    endtask
  
    //
    //
    //
  
    task SetCommand (sdram_transaction_class tr); 
  
      case (tr.tr_type)
        cTR_WRITE, cTR_WRITE_LOCKED : begin 
          sys_if.cb.write <= 1'b1;
          sys_if.cb.read  <= 1'b0;
          sys_if.cb.refr  <= 1'b0;
        end 
        cTR_READ,  cTR_READ_LOCKED  : begin 
          sys_if.cb.write <= 1'b0;
          sys_if.cb.read  <= 1'b1;
          sys_if.cb.refr  <= 1'b0;
        end 
        cTR_REFR,  cTR_REFR_LOCKED  : begin 
          sys_if.cb.write <= 1'b0;
          sys_if.cb.read  <= 1'b0;
          sys_if.cb.refr  <= 1'b1;
        end 
      endcase
  
      sys_if.cb.rowa    <= tr.rowa;
      sys_if.cb.cola    <= tr.cola;
      sys_if.cb.ba      <= tr.ba;
      sys_if.cb.burst   <= tr.burst;
      sys_if.cb.chid_i  <= tr.chid;
     
      do
        @(sys_if.cb);
      while (sys_if.cb.ready != 1'b1);
  
      sys_if.cb.write <= 1'b0;
      sys_if.cb.read  <= 1'b0;
      sys_if.cb.refr  <= 1'b0;
  
    endtask 
  
    //-----------------------------------------------------------------------
    // write data  driver 
    //-----------------------------------------------------------------------

    task WriteDataDriver; 
  
      sdram_transaction_class tr; 
      int num;    
  
    begin 
  
      forever begin
        wdata_mbx.get (tr);
  
        if (debug) 
          $display("%0t write driver get transaction id = %0d", $time, tr.id);
  
        num = tr.burst + 1;
  
        // set data
        for (int i = 0; i < num; i++) 
          SetWrData (tr.wdata [i] , tr.wdatam [i]);        
  
        -> write_done;
  
        if (debug) 
          $display("%0t write driver done transaction id = %0d", $time, tr.id);
  
        foreach ( cbs[i] ) cbs[i].post_WriteData($realtime, tr);
  
      end
    end 
    endtask

    //
    //
    //
`ifndef HSSDRC_COMBINATIVE_USE_WDATA
    task SetWrData ( input data_t data, datam_t datam); 
      sys_if.cb.wdata   <= data;
      sys_if.cb.wdatam  <= datam;
  
      do
        @(sys_if.cb);
      while (sys_if.cb.use_wdata != 1'b1);
    endtask
`else 
    task SetWrData ( input data_t data, datam_t datam); 
      do
        @(sys_if.cb);
      while (sys_if.cb.use_wdata != 1'b1);

      sys_if.cb.wdata   <= data;
      sys_if.cb.wdatam  <= datam;  
    endtask
`endif 
    //-----------------------------------------------------------------------
    // read part of  driver 
    //-----------------------------------------------------------------------

    task ReadDataDriver;
  
      sdram_transaction_class tr;
      int num;
  
    begin
      forever begin
        rdata_mbx.get (tr);
  
        if (debug) 
          $display("%0t read driver get transaction id = %0d", $time, tr.id);
  
        num = tr.burst + 1;
  
        for (int i = 0; i < num; i++)
            GetRdData (tr.rdata [i], tr.rchid [i]);
  
        -> read_done;
  
        if (debug) 
          $display("%0t read driver done transaction id = %0d", $time, tr.id);
  
        foreach ( cbs[i] ) cbs[i].post_ReadData($realtime, tr);
  
      end
    end
    endtask

    //
    //
    //

    task GetRdData (output data_t data, chid_t chid);
  
      do
        @(sys_if.cb);
      while (sys_if.cb.vld_rdata != 1'b1);
  
      data = sys_if.cb.rdata;
      chid = sys_if.cb.chid_o;
  
    endtask
  
    //
    //
    //
    
  endclass 

`endif 
