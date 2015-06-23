//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Testbench for uart.vhd                                      ////
////                                                              ////
////  This file is part of the XXX project                        ////
////  http://www.opencores.org/cores/xxx/                         ////
////                                                              ////
////  Description                                                 ////
////  Self checking testbench for uart.vhd. SV class implements a serial UART driver and monitor.
////  The driver accepts byte transactions and converts the byte to a serial stream.
////  The monitor converts serial UART bitstream to byte transactions.  
////                                                              ////
////  To Do:                                                      ////
////   -                                                          ////
////                                                              ////
////  Author(s):                                                  ////
////      - Andrew Bridger, andrew.bridger@gmail.com              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log$
//

timeunit 1ns;
timeprecision 1ps;

import std_defs::*;

interface uart_if ();
  logic txd = 0; //from testbench driver
  logic rxd;     //to testbench monitor
endinterface : uart_if

typedef logic[11:0] cpu_addr_t;
typedef logic[7:0]  cpu_data_t;



module uart_tb();

`define BAUD_RATE      115200  //baud rate to test.
`define UART_FIFO_SIZE 32      //DUT FIFO size.
  
  //Instantiate the DUT interfaces;
  uart_if  uart_();
  //Keep Testbench simple for the CPU register interface - use tasks for bus functional model, so don't require SV i/f. 
  cpu_addr_t cpu_addr;
  cpu_data_t cpu_data_in;
  cpu_data_t cpu_data_out;
  logic cpu_we;
  logic cpu_rd;
  logic clk, reset;     
  
  //DUT
  \work.uart(rtl) vhdl_module (
                               .clk           (clk),
                               .reset         (reset),
                               //Serial UART
                               .i_rxd         (uart_.txd),
                               .o_txd         (uart_.rxd),
                               //Cpu register interface
                               .i_addr         (cpu_addr),
                               .i_write_enable (cpu_we),
                               .i_read_enable  (cpu_rd),
                               .i_data         (cpu_data_in),
                               .o_data         (cpu_data_out) );
  
  //Takes byte transactions and generates serial data on TXD. No parity, 8 data bits, 1 stop bit.
  class uart_driver;
    virtual uart_if  uart_;
    mailbox #(uint8) mbx;
    bit     verbose = false;
    uint16           baud_rate;  

    function new( virtual uart_if uart_, uint16 baud_rate, mailbox #(uint8) mbx );
      uart_     = uart_;
      baud_rate = baud_rate;
      mbx       = mbx;
    endfunction

    //Main driver thread. Empty the mailbox by looking for transactions, and driving them out onto TXD.
    task automatic run();
      //spawn processes required for this driver.
      fork begin
        uint8      data;
        logic[7:0] data_bits;

        forever begin
          mbx.get( data ); //block if no transactions waiting.
          data_bits = data; 
          //start bit
          uart_.txd = 0;
          #(1s/baud_rate);
          //8 bits of data
          for(uint8 i=0; i<8; i++) begin
            uart_.txd = data_bits[i]; //least significant bit first.
            #(1s/baud_rate);
          end
          //1 stop bit
          uart_.txd = 1;
          #(1s/baud_rate);
        end
      end
      join_none
    endtask 
  endclass
    
  //Looks for serial bytes on RXD, and converts them into byte transactions into a mailbox.
  class uart_monitor;
    virtual uart_if  uart_;
    mailbox #(uint8) mbx;
    bit     verbose = false;
    uint16           baud_rate;  

    function new( virtual uart_if uart_, uint16 baud_rate, mailbox #(uint8) mbx );
      uart_     = uart_;
      baud_rate = baud_rate;
      mbx       = mbx;
    endfunction

    //Main monitor thread. 
    task automatic run();
      fork begin
        forever begin
          //Look for a valid start bit. Must be at least 1/2 bit period duration.
          @(negedge uart_.rxd);
          #(0.5 * 1s/baud_rate);
          if ( uart_.rxd == 0 ) begin
            logic[7:0] data_bits;
            //read in 8 data bits, LSBit first, sampling in the center of the bit period.
            for(uint8 i=0; i<8; i++) begin
              #(1s/baud_rate);
              data_bits[i] = uart_.rxd;
            end
            //check stop bit.
            #(1s/baud_rate);
            if ( uart_.rxd != 1 ) begin
              $display("Monitor: Invalid stop bit.");
            end
            else begin
              //valid stop bit so generate transaction.
              uint8 data;
              data = data_bits;
              mbx.put( data );
            end
          end
        end
      end
      join_none
    endtask
  endclass

  task automatic cpu_init();
    cpu_addr    = 0;
    cpu_data_in = 0;
    cpu_we      = 0;
    cpu_rd      = 0;
  endtask
  
  //Read a register.
  task automatic cpu_read( cpu_addr_t addr, cpu_data_t data );
    @(negedge clk); //setup on falling edge. DUT reads on rising edge.
    cpu_addr = addr;
    cpu_rd   = 1;
    cpu_we   = 0;
    @(negedge clk);
    cpu_rd   = 0;
    @(negedge clk); //uart returns data maximum of 2 clocks after read enable.
    data = cpu_data_out;
  endtask

  //Write a register.
  task automatic cpu_write( cpu_addr_t addr, cpu_data_t data );
    @(negedge clk); //setup on falling edge. DUT reads on rising edge.
    cpu_addr    = addr;
    cpu_rd      = 0;
    cpu_we      = 1;
    cpu_data_in = data;
    @(negedge clk);
  endtask

  //System clock
  initial
    begin
      clk = 0;
      forever #20ns clk <= ~clk;
    end

  //Main sim process.
  initial
    begin
      $display("%t << Starting the simulation >>", $time);
      cpu_init(); 
        
      //ok, now run some tests.
      test_cpu_interface(); 
      test_serial_facing_loopback(); //This one is also a good test for the testbench UART monitor/driver classes. 
      test_cpu_to_txd();
      //test_rxd_to_cpu();
      
      $display("%m: %t << Simulation ran to completion >>", $time);
      //     $stop(0); //stop the simulation
    end
  
  task automatic dut_reset();
    reset <= 1;
    repeat(16) @(negedge clk);
    reset <= 0;
  endtask
  
  uart_driver  Uart_driver;
  uart_monitor Uart_monitor;
  
  task automatic build_test_harness( mailbox #(uint8) uart_driver_mbx, mailbox #(uint8) uart_monitor_mbx);
    //transaction mailboxes for comms between driver/monitor and main testbench thread.
    uart_driver_mbx  = new(0); //unbounded
    uart_monitor_mbx = new(0); //unbounded
    
    //construct UART monitor and driver.
    Uart_driver  = new( uart_, `BAUD_RATE, uart_driver_mbx );
    Uart_monitor = new( uart_, `BAUD_RATE, uart_monitor_mbx );

    //start them up.
    Uart_driver.run();
    Uart_monitor.run();
  endtask
  
  task automatic test_cpu_interface();
    cpu_data_t readval;
    $display("Testing cpu register interface...");

    dut_reset();
    //test read/write baud rate register
    cpu_write( 'h002, 'h55 );
    cpu_write( 'h003, 'hAA );
    cpu_read(  'h002, readval );
    assert (readval == 'h55) else $display("Failed to readback register 2 correctly.");
    cpu_read(  'h003, readval );
    assert (readval == 'hAA) else $display("Failed to readback register 2 correctly.");
  endtask

  task automatic test_serial_facing_loopback();
    //This loopback is right at the UART txd/rxd pins.
    mailbox #(uint8) sent_data_mbx;
    mailbox #(uint8) uart_driver_mbx;
    mailbox #(uint8) uart_monitor_mbx;
    build_test_harness( uart_driver_mbx, uart_monitor_mbx);
    dut_reset();

    $display("Testing serial facing loopback...");
    cpu_write( 'h002, 'h80 ); //enable the loopback.

    //Send a bunch of serial UART bytes. 
    repeat(1000) begin
      uint8 data;
      data = $random();
      uart_driver_mbx.put( data );
      sent_data_mbx.put( data );
    end

    //Gives some time for any remaining transactions to propagate through the DUT.
    #( `UART_FIFO_SIZE * (12 * 1s/`BAUD_RATE)); //10 bits/ baud, but allow for 12.

    //Check the sent data comes back error free.
    compare_mailbox_data( sent_data_mbx, uart_monitor_mbx );
  endtask
               
  task automatic test_cpu_to_txd();
    mailbox #(uint8) sent_data_mbx;

    mailbox #(uint8) uart_driver_mbx;
    mailbox #(uint8) uart_monitor_mbx;
    build_test_harness( uart_driver_mbx, uart_monitor_mbx);
    dut_reset();
    
    sent_data_mbx = new(0);
    $display("Testing cpu to UART serial TXD interface...");
    
    //Using the UART's cpu interface, write a bunch of data in. Make sure we don't overflow the uart tx FIFO by
    //always reading the FIFO full flag prior to writing. Check all data is correctly received by the monitor.
    repeat(1000) begin
      uint8 readval;
      uint8 data;
      data = $random();
      //check uart tx fifo is not full
      cpu_read( 'h001, readval );
      if ((readval & 'h08) == 0) begin
        cpu_write( 'h000, data );
        sent_data_mbx.put(data);
      end
    end

    //Gives some time for any remaining transactions to propagate through the DUT.
    #( `UART_FIFO_SIZE * (12 * 1s/`BAUD_RATE)); //10 bits/ baud, but allow for 12.
    
    //Check the sent and received data is the same.
    compare_mailbox_data( sent_data_mbx, uart_monitor_mbx );
  endtask

  //Check all reference mailbox items against dut mailbox items. Expected to be identical, report differences.
  function automatic void compare_mailbox_data( mailbox #(uint8) ref_mbx, mailbox #(uint8) dut_mbx );
    uint32 error = 0;
    uint32 good = 0;
    uint32 ref_mbx_num;
    uint32 dut_mbx_num;

    ref_mbx_num = ref_mbx.num();
    dut_mbx_num = dut_mbx.num();
    
    repeat( ref_mbx_num ) begin
      uint8 dut_data;
      uint8 ref_data;
      uint32 tryget_result;
      
      ref_mbx.try_get( ref_data );
      //try to get dut data, may not be there if dut swallowed it.
      tryget_result = dut_mbx.try_get( dut_data );
      if (tryget_result) begin
        if (ref_data != dut_data) begin
          error++;
        end
        else begin
          good++;
        end
        break; //no more DUT data
      end
    end
    $display("Good: %2d, Errored: %2d, Excess reference %2d, Excess DUT %2d", 
             good, error, ref_mbx_num, dut_mbx_num);
  endfunction
  
endmodule 



   