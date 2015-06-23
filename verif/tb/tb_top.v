//////////////////////////////////////////////////////////////////////
////                                                              ////
////  UART2SPI Test Bench Top Module                              ////
////                                                              ////
////  This file is part of the uart2spi  cores project            ////
////  http://www.opencores.org/cores/uart2spi/                    ////
////                                                              ////
////  Description:                                                ////
////  Uart2SPI testbench top level integration.                   ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
module tb_top;

parameter XTAL_CLK_PERIOD = 20; // 50Mhz

reg    reset_n;
reg    xtal_clk;
initial begin
  xtal_clk = 1'b0;
  forever #(XTAL_CLK_PERIOD/2.0) xtal_clk = ~xtal_clk;
end

//-------------------------------------
// Spi I/F
//-------------------------------------
wire              spi_sck         ; // clock out
wire              spi_so          ; // serial data out
wire              spi_si             ; // serial data in
wire [3:0]        spi_cs_n           ; // cs_n

top u_uart_top (  
        .line_reset_n      (reset_n),
        .line_clk          (xtal_clk),

	// configuration control
        .cfg_tx_enable  (1'b1),     // Enable Transmit Path
        .cfg_rx_enable  (1'b1),     // Enable Received Path
        .cfg_stop_bit   (1'b1),     // 0 -> 1 Start , 1 -> 2 Stop Bits
        .cfg_pri_mod    (2'b0),     // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd
	.cfg_baud_16x   (12'hA0),


       // Status information
        .frm_error (),
	.par_error (),
	.baud_clk_16x(uart_clk_16x),


       // Line Interface
        .rxd    (rxd),
        .txd    (txd),

        // line interface
        .sck    (spi_sck          ),
        .so     (spi_so           ),
        .si     (spi_si           ),
        .cs_n   (spi_cs_n         ) 

     );


uart_agent tb_uart (
               . test_clk          (uart_clk_16x       ),
               . sin               (rxd                ),
               . dsr_n             (                   ),
               . cts_n             (                   ),
               . dcd_n             (                   ),

               . sout              (txd                ),
               . dtr_n             (1'b0               ),
               . rts_n             (1'b0               ),
               . out1_n            (1'b0               ),
               . out2_n            (1'b0               )
       );



//----------------------- SPI Agents

m25p16 i_m25p16_0 ( 
               .c                  (spi_sck            ),
               .s                  (spi_cs_n[0]        ), // Include selection logic
               .w                  (1'b1               ), // Write protect is always disabled
               .hold               (1'b1               ), // Hold support not used
               .data_in            (spi_so             ),
               .data_out           (spi_si             )
             );

reg 	fifo_enable      ;	// fifo mode disable
reg [15:0] timeout       ;// wait time limit
reg	  parity_en       ; // parity enable
reg	  stop_bits       ; // 0: 1 stop bit; 1: 2 stop bit;
reg [1:0] data_bit        ;
reg       flag;
reg [7:0] read_data;
reg	  even_odd_parity ; // 0: odd parity; 1: even parity
initial begin

        reset_n = 1;
   #100 reset_n = 0;
   #100 reset_n = 1;

    tb_uart.uart_init;
    data_bit         = 2'b11;
    stop_bits         = 1'b1;
    parity_en         = 1'b0;
    even_odd_parity   = 1'b1;
    timeout           = 500;
    fifo_enable       = 0;
    tb_top.tb_uart.control_setup (data_bit, stop_bits, parity_en, even_odd_parity, timeout, fifo_enable);

   $write ("\n(%t)Received Character:\n",$time);
   flag = 0;
   while(flag == 0)
   begin
        tb_top.tb_uart.read_char(read_data,flag);
        //$write ("%c",read_data);
   end


//  uart_test;
   spi_test;

   #1000 $finish;
end
//initial begin
//$dumpfile ("spi.vcd");
//$dumpvars(0);
//end

//initial begin
//$shm_open("verilog.trn"); 
//$shm_probe("tb_top"); 
//end
`include "uart_tasks.v"
`include "spi_tasks.v"
`include "uart_test.v"
`include "spi_test.v"

endmodule


