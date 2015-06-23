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
// Workfile     : tb_prog.sv
// 
// Description  : testbench program for all cases
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
`include "hssdrc_timing.vh"
`include "tb_define.svh"

`include "message_class.sv"

`include "hssdrc_driver_class.sv"
`include "hssrdc_bandwidth_monitor_class.sv"
`include "hssrdc_scoreboard_class.sv"

`include "sdram_transaction_class.sv"

`include "sdram_tread_class.sv"
`include "sdram_agent_class.sv"

program tb_prog (interface sys_if);

  // agent <-> driver mailbox
  sdram_tr_mbx      agent2drv_mbx;
  sdram_tr_ack_mbx  drv2agent_mbx;

  // message service
  message_class msg;

  // test program -> agent mailbox
  sdram_tr_mbx agent_write_mbx;
  sdram_tr_mbx agent_read_mbx;

  // transaction agent class
  sdram_agent_class   agent;

  // virtual sdram treads
  sdram_tread_class   tread;

  // driver to uut
  hssrdc_driver_class             driver;

  // driver callbacks
  hssdrc_bandwidth_monitor_class  bandwidth_mon;
  hssdrc_scoreboard_class         scoreboard;

  event scoreboard_event;
  event bandwidth_mon_event; 

  initial begin

    agent2drv_mbx     = new (8);
    drv2agent_mbx     = new (8);

    agent_write_mbx   = new (8);
    agent_read_mbx    = new (8);

    // init objects
    msg           = new ("tb_hssdrc.log");

    driver        = new (sys_if, agent2drv_mbx, drv2agent_mbx);

    agent         = new (agent2drv_mbx, drv2agent_mbx, agent_write_mbx, agent_read_mbx);

    tread         = new ;

    bandwidth_mon = new (sys_if, bandwidth_mon_event);

    scoreboard    = new (msg, scoreboard_event);

    driver.run();

    agent.run_write_read ();

    // calibrate bandwidth monitor 
    
    bandwidth_mon.count_mbps_mfactor(1000);

    // disable debug process inside sdram model

    force tb_top.sdram_chip.Debug = 0;

    wait (sys_if.reset == 1'b0);

    wait (sys_if.cb.ready == 1'b1);

    msg.note ("Program start");

`ifdef HSSDRC_NOT_SHARE_ACT_COMMAND
    msg.note ("Controller use HSSDRC_NOT_SHARE_ACT_COMMAND macros");
`endif 

`ifdef HSSDRC_SHARE_ONE_DECODER
    msg.note ("Controller use HSSDRC_SHARE_ONE_DECODER macros");
`endif 

`ifdef HSSDRC_SHARE_NONE_DECODER
    msg.note ("Controller use HSSDRC_SHARE_NONE_DECODER macros");
`endif 

    //test(-1,-1); // simple_debug_test
    //test(0,0);   // linear_test
    test(1,1);   // random_test 
    //test(2,2);   // bandwidth_measurement 

    agent.stop_write_read();

    driver.stop();

    msg.stop();

    $stop;
    $finish (2);

  end

  //
  // 
  //

  task test (input int start_task, end_task);
    int task_num;

    sdram_transaction_class write_tr;
    sdram_transaction_class read_tr;

    sdram_transaction_class rand_tr;
    sdram_transaction_class tr;

    int err;

    int         tr_burst;
    tr_type_e_t tr_type;
    int         tr_id;
    int         tr_chid;
    int         tr_num;

    bit tread_end;
    int next_cola;

    sdram_tread_state_s_t tread_state;  // selected tread state
    int                   tread_num;    // selected tread num

    string log_str;
  begin

    for (task_num = start_task; task_num <= end_task; task_num++)
    begin
      //
      // Task -1 : manualy checking write/read transactions 
      // 
      if (task_num == -1) begin : simple_debug_test

        msg.note ($psprintf("test %0d : simple debug test", task_num));

        //
        // test for debug only 
        // 

        tr = new (0, cTR_WRITE_LOCKED, .ba(0), .rowa(0), .cola(0), .burst(3));
        tr.GetLinearPacket();          
        agent.SetTransaction(tr); 
        
        tr = new (0, cTR_WRITE_LOCKED, .ba(0), .rowa(0), .cola(0), .burst(4));
        tr.GetLinearPacket();          
        agent.SetTransaction(tr); 

        tr = new (0, cTR_READ_LOCKED, .ba(0), .rowa(0), .cola(0), .burst(4), .chid(1));
        tr.GetLinearPacket();          
        agent.SetTransaction(tr); 
        
//      tr = new (0, cTR_READ, .ba(0), .rowa(1), .cola(0), .burst(2));
//      tr.GetLinearPacket();
//      agent.SetTransaction(tr);

        tr = new (0, cTR_REFR_LOCKED, .ba(0), .rowa(0));
        agent.SetTransaction(tr); 

        repeat (10) @(sys_if.cb);
      end : simple_debug_test

      //
      // Task 0 : linear write -> read with linear data (random burst only)
      //

      else if (task_num == 0) begin : linear_test

        msg.note ($psprintf("test %0d : linear write -> read with linear data", task_num));

        //
        // test for correctness. set scoreboard callbacks
        //

        driver.cbs = {};
        scoreboard.start();
        driver.cbs.push_back(scoreboard);

        driver.random_delay_mode = 1;
        //
        // transaction generator
        //

        tread.Init();

        msg.note ($psprintf("test %0d start_task with number of treads is %0d", task_num, tread.active_tread_state.num()));

        for (tread_num = 0; tread_num < tread.active_tread_state.num(); tread_num++) begin

          //
          // get tread state
          //

          tread_state = tread.active_tread_state [tread_num];

          msg.note ($psprintf("start tread %0d" , tread_num));

          //
          // full tread transaction
          //

          tr_num = 0;

          do begin
            //
            // generate transaction
            //
            tr_id     = tread_num;
            tr_type   = cTR_WRITE;
            tr_burst  = tread.GetBurst (tread_state);
            tr_chid   = tread_state.ba;

            write_tr = new (tr_id, tr_type, tread_state.ba, tread_state.rowa, tread_state.cola, tr_burst, tr_chid);
            write_tr.GetLinearPacket();

            read_tr = new write_tr;
            read_tr.tr_type = cTR_READ;
            //
            // set transaction
            //
            #10;
            agent_write_mbx.put (write_tr);
            #10;
            agent_read_mbx.put  (read_tr);
            //
            // update tread state
            //
            tr_num++;

            next_cola = tread_state.cola + tr_burst;

            tread_end = (next_cola >= cColaMaxValue);

            tread_state.cola = next_cola;

          end
          while (tread_end != 1);

          msg.note ($psprintf("done tread %0d. number of tread transactions %0d", tread_num, tr_num));

        end

        //
        // wait compare done
        //

        do
          @(scoreboard_event);
        while (agent.read_tr_done_num != scoreboard.checked_tr_num);

        msg.note ($psprintf("test%0d done. Number of errors = %0d", task_num, scoreboard.check_err_num));

      end : linear_test

      //
      // Task 1 : random write -> read with random data, rowa, ba, burst, linear cola 
      //

      else if (task_num == 1) begin : random_test

        msg.note ($psprintf("test %0d : random write -> read with random data", task_num));

        //
        // test for correctness. set scoreboard callbacks
        //

        driver.cbs = {};
        scoreboard.start();
        driver.cbs.push_back(scoreboard);

        driver.random_delay_mode = 1;

        //
        // transaction generator
        //

        tread.Init();

        msg.note ($psprintf("test %0d start_task with number of treads is %0d", task_num, tread.active_tread_state.num()));

        tr_num = 0;

        do begin

          //
          // select tread
          //

          assert (tread.randomize()) else $error ("generate tread selection error");

          tread_num   = tread.curr_tread_num;

          tread_state = tread.active_tread_state [tread_num];

          //
          // generate transaction
          //

          tr_burst  = tread.GetBurst (tread_state);
          tr_type   = cTR_WRITE;
          tr_id     = tread_num;
          tr_chid   = tread_state.ba;

          write_tr = new (tr_id, tr_type, tread_state.ba, tread_state.rowa, tread_state.cola, tr_burst, tr_chid);
          //write_tr.GetLinearPacket();
          write_tr.GetRandomPacket();

          read_tr = new write_tr;
          read_tr.tr_type = cTR_READ;
          //
          // set transaction
          //
          #10;
          agent_write_mbx.put (write_tr);
          #10;
          agent_read_mbx.put  (read_tr);
          //
          // update tread state
          //
          tr_num++;

          next_cola = tread_state.cola + tr_burst;

          tread_end = (next_cola >= cColaMaxValue);

          tread_state.cola = next_cola;

          tread.active_tread_state [tread_num] = tread_state;
          //
          // if tread end kill it
          //
          if (tread_end) begin
            tread.active_tread_state.delete   (tread_num);
            tread.disable_tread_num.push_back (tread_num);  // random pointer constrain update
            msg.note ($psprintf("done tread %0d", tread_num));
          end

          if (tr_num > cTransactionMaxValue) break;

          if (tr_num % cTransactionLogPeriod == 0)
            msg.note($psprintf("transaction done %0d", tr_num));

        end
        while (tread.active_tread_state.num() != 0);

        //
        // wait compare done
        //

        do
          @(scoreboard_event);
        while (agent.read_tr_done_num != scoreboard.checked_tr_num);

        msg.note ($psprintf("test%0d done. Number of errors = %0d", task_num, scoreboard.check_err_num));

      end : random_test

      //
      // Task 2 : bandwidth measurement 
      //

      else if (task_num == 2) begin : bandwidth_measurement 

        msg.note ($psprintf("test %0d : access bandwidth measurement", task_num));

        //
        // test for perfromance. set bandwidth monitor callbacks, no random delay mode 
        //

        driver.cbs = {};        
        driver.cbs.push_back(bandwidth_mon);

        driver.random_delay_mode = 0;

        //
        // generate transactions
        // 
        foreach ( test_mode [t] ) begin : test_mode_cycle

          msg.note ($psprintf("test %0d start %0s test mode", task_num, test_mode_name[test_mode[t]]));

          foreach (burst_mode [b]) begin : burst_cycle

            foreach (address_mode [a] ) begin : address_cycle 
          
              time start_time; 
              string str; 

              tr_num = 0; 
              start_time = $time;

              //
              // init tr.generator 
              // 

              rand_tr = new;
              rand_tr.burst_random_mode   = burst_mode [b];
              rand_tr.address_random_mode = address_mode [a];

              bandwidth_mon.start();

              do begin 

                assert ( rand_tr.randomize() ) else begin 
                  $error("test %0d : random transaction generate error", task_num);                  
                  $stop; 
                end 

                if ( test_mode[t].write_mode) begin 
                  write_tr          = new rand_tr; 
                  write_tr.id       = tr_num++;
                  write_tr.tr_type  = cTR_WRITE;

                  agent.SetTransaction(write_tr);
                end 

                if ( test_mode[t].read_mode) begin 
                  read_tr         = new rand_tr;
                  read_tr.id      = tr_num++;
                  read_tr.tr_type = cTR_READ;

                  agent.SetTransaction(read_tr);
                end 

                if (tr_num % cTransactionLogPeriod == 0)
                  msg.note($psprintf("task %0d transaction done %0d", task_num, tr_num));

              end 
              while (($time - start_time) < cPerfomanceInterval);

              //
              // syncronize output for measure
              // 
              do 
                @(bandwidth_mon_event); 
              while (tr_num != bandwidth_mon.measured_tr_num); 

              //
              // stop measure 
              //
              bandwidth_mon.stop();

              //
              // logs 
              // 

              str = $psprintf("task %0d done. %0s mode bandwith : %0s and %0s is :\n", task_num, 
                test_mode_name[test_mode[t]], address_mode_name [address_mode[a]], burst_mode_name [burst_mode[b]]);

              if (test_mode [t].write_mode)
                str = {str, $psprintf("\t\twrite bandwidth %0f MBps, %0f %% maximum ram bandwidth\n", 
                  bandwidth_mon.write_bandwidth, bandwidth_mon.write_bandwidth_percent)};

              if (test_mode [t].read_mode) 
                str = {str, $psprintf("\t\t read bandwidth %0f MBps, %0f %% maximum ram bandwidth\n", 
                  bandwidth_mon.read_bandwidth, bandwidth_mon.read_bandwidth_percent)};

              if (test_mode [t].read_mode & test_mode [t].write_mode) 
                str = {str, $psprintf("\t\tram bandwidth %0f MBps, %0f %% maximum ram bandwidth\n", 
                  bandwidth_mon.bandwidth, bandwidth_mon.bandwidth_percent)};

              msg.note(str); 
              
            end : address_cycle 

          end : burst_cycle 

        end : test_mode_cycle

        
      end : bandwidth_measurement

    end

    msg.note ("all test done");

    repeat (100) @(sys_if.cb);
  end

  endtask



endprogram 
