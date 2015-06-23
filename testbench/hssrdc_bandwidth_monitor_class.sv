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
// Workfile     : hssrdc_bandwidth_monitor_class.sv
// 
// Description  : bandwidth monitor measurement class
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
`include "hssdrc_timing.vh"
`include "hssdrc_tb_sys_if.vh"

`include "sdram_transaction_class.sv"
`include "hssrdc_driver_cbs_class.sv"


`ifndef __HSSDRC_BANDWIDTH_MONITOR_CLASS__

  `define __HSSDRC_BANDWIDTH_MONITOR_CLASS__

  class hssdrc_bandwidth_monitor_class extends hssrdc_driver_cbs_class;

    virtual hssdrc_tb_sys_if sys_if; 

    // bandwidth measurement FSM 
    enum {idle, wait_start, work} state = idle; 

    // timestamps 
    realtime end_time;
    realtime start_time;

    // word transfer counters 
    int unsigned wr_word_num;
    int unsigned rd_word_num;

    // bandwidth measurement itself 
    real write_bandwidth ;
    real read_bandwidth  ;
    real bandwidth       ;

    real write_bandwidth_percent  ;
    real read_bandwidth_percent   ;
    real bandwidth_percent        ;

    // semaphore to controll access to variables 
    semaphore sem;

    // bandwidth measurement parameters 
    real mbps_mfactor;
    real max_bandwidth;

    //  tb syncronization 
    int measured_tr_num = 0;
    event done;

    function new (virtual hssdrc_tb_sys_if sys_if, ref event done); 
      sem = new (1);

      this.sys_if = sys_if;

      this.done   = done; 
    endfunction  


    //
    // function to start measurement process 
    //

    task start();

      sem.get (1) ;      

      // set begin
      state = wait_start; 

      // clear all counters
      end_time    = 0ns; 
      start_time  = 0ns;

      wr_word_num = 0; 
      rd_word_num = 0;

      measured_tr_num = 0;

      sem.put (1) ;
    endtask

    //
    // function to stop measurement process
    // 

    task stop();
     sem.get (1);

     state = idle;      
     count_bandwidth();

     sem.put (1);

    endtask

    //
    // callback for command part of hssdrc_driver_class 
    // 

    task post_Command (input realtime t);
    endtask 

    //
    // callback for write part of hssdrc_driver_class 
    // 

    task post_WriteData (input realtime t, sdram_transaction_class tr);
      int burst; 
    begin

      burst = tr.burst + 1;

      sem.get (1);

      if (state == wait_start) begin
        start_time  = t;
        state       = work;
      end
      else if (state == work) begin 
        wr_word_num += burst; 
        end_time    = t;
      end         

      measured_tr_num++; 
      -> done; 

      sem.put (1);
    end 
    endtask   

    //
    // callback for read part of hssdrc_driver_class 
    // 

    task post_ReadData ( input realtime t, sdram_transaction_class tr); 
      int burst;
    begin

      burst = tr.burst + 1;

      sem.get (1);

      if (state == wait_start) begin
        start_time  = t;
        state       = work;
      end 
      else if (state == work) begin 
        rd_word_num += burst; 
        end_time    = t;
      end 

      measured_tr_num++;

      -> done; 

      sem.put (1);
    end 
    endtask

    //
    // measurement count function bwth = mbps_mfactor*num/(end_time - start_time); 
    // 

    function void count_bandwidth();
      realtime delta;    
      int unsigned wrrd_word_num;
    begin 

      delta = (end_time - start_time);

      wrrd_word_num = wr_word_num + rd_word_num;

      write_bandwidth =   (wr_word_num/delta)*mbps_mfactor;
      read_bandwidth  =   (rd_word_num/delta)*mbps_mfactor;
      bandwidth       = (wrrd_word_num/delta)*mbps_mfactor;

      write_bandwidth_percent = write_bandwidth*100.0/max_bandwidth ;
      read_bandwidth_percent  = read_bandwidth *100.0/max_bandwidth ;
      bandwidth_percent       = bandwidth      *100.0/max_bandwidth ;

    end
    endfunction 

    //
    // task to get multiplicatin factor for counters 
    // 

    task count_mbps_mfactor (int bytes_in_kilobytes) ; 
      realtime delta; 
      realtime scale; 
    begin 
      // define current timeunit value 
      delta = $realtime; 
      #1;  
      delta = $realtime - delta; 

      // define time scale factor 
      scale = 1s/delta; 

      // kilobytes 
      mbps_mfactor = real'(scale)/(bytes_in_kilobytes); 

      // megabytes 
      mbps_mfactor = mbps_mfactor/(bytes_in_kilobytes); 

      mbps_mfactor = mbps_mfactor*pDatamBits;

      // define max bandwwidth : 1 world per cycle period
      @(sys_if.cb); 
      delta = $realtime; 
      @(sys_if.cb); 
      delta = $realtime - delta; 
      
      max_bandwidth = (1/delta)*mbps_mfactor;

    end
    endtask      

  endclass

`endif 
