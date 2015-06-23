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

module ssram(
	input CLK_I,
	input RST_I,
	
	//slave
	output reg [31:0] DAT_O,
	input [31:0] DAT_I,
	output reg ACK_O,
	
	input CYC_I,
	input [20:2] ADR_I,
	input STB_I,
	input WE_I,
	input [3:0] SEL_I,
	
	//ssram interface
	output [18:0] ssram_address,
	output reg ssram_oe_n,
	output reg ssram_writeen_n,
	output reg ssram_byteen0_n,
	output reg ssram_byteen1_n,
	output reg ssram_byteen2_n,
	output reg ssram_byteen3_n,
	
	inout [31:0] ssram_data,
	
	output ssram_clk,
	output ssram_mode,
	output ssram_zz,
	output ssram_globalw_n,
	output ssram_advance_n,
	output reg ssram_adsp_n,
	output ssram_adsc_n,
	output ssram_ce1_n,
	output ssram_ce2,
	output ssram_ce3_n
);

assign ssram_address = ADR_I;

assign ssram_clk = CLK_I;
assign ssram_mode = 1'b0;
assign ssram_zz = 1'b0;
assign ssram_globalw_n = 1'b1;
assign ssram_advance_n = 1'b1;
assign ssram_adsc_n = 1'b1;
assign ssram_ce1_n = 1'b0;
assign ssram_ce2 = 1'b1;
assign ssram_ce3_n = 1'b0;

reg [31:0] ssram_data_o;
assign ssram_data = (ssram_oe_n == 1'b1) ? ssram_data_o : 32'dZ;

reg [2:0] counter;

//reg second;

always @(posedge CLK_I) begin
	if(RST_I == 1'b1) begin
		DAT_O <= 32'd0;
		ACK_O <= 1'b0;
		//ssram_address <= 19'd0;
		ssram_oe_n <= 1'b1;
		ssram_writeen_n <= 1'b1;
		ssram_byteen0_n <= 1'b1;
		ssram_byteen1_n <= 1'b1;
		ssram_byteen2_n <= 1'b1;
		ssram_byteen3_n <= 1'b1;
		ssram_data_o <= 32'd0;
		ssram_adsp_n <= 1'b1;
		counter <= 3'd0;
		
		//second <= 1'b0;
	end
	else begin
		
		if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && ACK_O == 1'b0) begin
			
			if(counter == 3'd0) begin
				ssram_adsp_n <= 1'b0;
				//ssram_address <= ADR_I;
				
				counter <= counter + 3'd1;
			end
			else if(counter == 3'd1) begin
				ssram_adsp_n <= 1'b1;
				ssram_writeen_n <= 1'b1;
				ssram_byteen0_n <= 1'b0;
				ssram_byteen1_n <= 1'b0;
				ssram_byteen2_n <= 1'b0;
				ssram_byteen3_n <= 1'b0;
				
				counter <= counter + 3'd1;
			end
			else if(counter == 3'd2) begin
				ssram_oe_n <= 1'b0;
				
				counter <= counter + 3'd1;
			end
			else if(counter == 3'd3) begin
				ssram_oe_n <= 1'b1;
				
				counter <= 3'd0;
				DAT_O <= ssram_data;
				ACK_O <= 1'b1;
			end
			
		end
		else if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1 && ACK_O == 1'b0) begin
			
			if(counter == 3'd0) begin
				ssram_adsp_n <= 1'b0;
				//ssram_address <= ADR_I[20:2];
				ssram_oe_n <= 1'b1;
				
				counter <= counter + 3'd1;
			end
			else if(counter == 3'd1) begin
				ssram_adsp_n <= 1'b1;
				ssram_writeen_n <= 1'b0;
				ssram_byteen0_n <= (SEL_I[0] == 1'b1) ? 1'b0 : 1'b1;
				ssram_byteen1_n <= (SEL_I[1] == 1'b1) ? 1'b0 : 1'b1;
				ssram_byteen2_n <= (SEL_I[2] == 1'b1) ? 1'b0 : 1'b1;
				ssram_byteen3_n <= (SEL_I[3] == 1'b1) ? 1'b0 : 1'b1;
				ssram_data_o <= DAT_I;
				
				counter <= counter + 3'd1;
			end
			else if(counter == 3'd2) begin
				ssram_writeen_n <= 1'b1;
				
				counter <= 3'd0;
				ACK_O <= 1'b1;
			end
		end
		else begin
			ACK_O <= 1'b0;
		end
	end	
end


endmodule
