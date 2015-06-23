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

module timer(
	input CLK_I,
	input RST_I,
	
	input [31:2] ADR_I,
	input CYC_I,
	input STB_I,
	input WE_I,
	
	output reg RTY_O,
	output reg interrupt_o
);

reg [27:0] counter;

always @(posedge CLK_I) begin
	if(RST_I == 1'b1) begin
		RTY_O <= 1'b0;
		interrupt_o <= 1'b0;
		counter <= 28'd0;
	end
	else if(counter == 28'h00FFFFF) begin
		if(ADR_I == { 27'b1111_1111_1111_1111_1111_1111_111, 3'b001 } && CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b0 && interrupt_o == 1'b1) begin
			RTY_O <= 1'b1;
			interrupt_o <= 1'b0;
			counter <= 28'd0;
		end
		else begin
			interrupt_o <= 1'b1;
		end
	end
	else begin
		RTY_O <= 1'b0;
		counter <= counter + 28'd1;
	end
end

endmodule

