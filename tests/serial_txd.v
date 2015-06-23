/* 
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module serial_txd(
	input clk_30,
	input reset_n,
	
	// WISHBONE slave
	input [7:0] DAT_I,
    output reg ACK_O,
    
	input CYC_I,
	input STB_I,
	input WE_I,
	
	//serial output
	input uart_rxd,
	input uart_rts,
	output reg uart_txd,
	output uart_cts
);

assign uart_cts = uart_rts;

reg [12:0] counter;

// 115200 baud -> 8680.5555 ns / bit = 260 * 33.333 ns 
parameter [9:0] one_bit = 10'd260;

always @(posedge clk_30 or negedge reset_n) begin
	if(reset_n == 1'b0) begin
		ACK_O <= 1'b0;
		uart_txd <= 1'b1;
		counter <= 13'd0;
	end
	
	else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0) begin
		if(counter < 13'd8191) counter <= counter + 13'd1;
		
		
		if(counter < one_bit*1) 		uart_txd <= 1'b0;
		else if(counter < one_bit*2) 	uart_txd <= DAT_I[0];
		else if(counter < one_bit*3) 	uart_txd <= DAT_I[1];
		else if(counter < one_bit*4) 	uart_txd <= DAT_I[2];
		else if(counter < one_bit*5) 	uart_txd <= DAT_I[3];
		else if(counter < one_bit*6) 	uart_txd <= DAT_I[4];
		else if(counter < one_bit*7) 	uart_txd <= DAT_I[5];
		else if(counter < one_bit*8) 	uart_txd <= DAT_I[6];
		else if(counter < one_bit*9) 	uart_txd <= DAT_I[7];
		else if(counter < one_bit*10) 	uart_txd <= 1'b1;
		else begin
			uart_txd <= 1'b1;
			ACK_O <= 1'b1;
		end
	end
	else begin
		ACK_O <= 1'b0;
		uart_txd <= 1'b1;
		counter <= 13'd0;
	end
end

endmodule

