
//
// BAUD.v
//
// www.cmosexod.com
// 4/13/2001 (c) 2001
// Jeung Joon Lee
//
// This is the "baud-rate-genrator"
// The "baud_clk" is the output clock feeding the
// receiver and transmitter modules of the UART.
//
// By design, the purpose of the "baud_clk" is to 
// take in the "sys_clk" and generate a clock 
// which is 16 x BaudRate, where BaudRate is the
// desired UART baud rate.  
//
// Refer to "inc.h" for the setting of system clock
// and the desired baud rate.
//	  

module baud(
			sys_clk,
			sys_rst_l,
		
			baud_clk				
		);
								  

`include "inc.h"


input 			sys_clk;
input			sys_rst_l;
output			baud_clk;

reg		[CW-1:0]	clk_div;
reg				baud_clk;


always @(posedge sys_clk or negedge sys_rst_l)
  if (~sys_rst_l) begin
    clk_div  <= 0;
    baud_clk <= 0; 
  end else if (clk_div == CLK_DIV) begin
    clk_div  <= 0;
    baud_clk <= ~baud_clk;
  end else begin
    clk_div  <= clk_div + 1;
    baud_clk <= baud_clk;
  end

endmodule
