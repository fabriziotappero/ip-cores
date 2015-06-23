/**********************************************************************
	File: fwft_fifo.v 
	
	Copyright (C) 2013  Alireza Monemi

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
	
	Purpose:
	An small  First Word Fall Through FIFO. The code will use LUTs
	and  optimized for low LUTs utilization.

	Info: monemi@fkegraduate.utm.my


*******************************************************************/

`include "../define.v"
`timescale 1ns/1ps
module fwft_fifo #(
		parameter WIDTH = 1,
		parameter MAX_DEPTH_BITS = 2
	)
	(
		input [WIDTH-1:0] din,     // Data in
		input          wr_en,   // Write enable
		input          rd_en,   // Read the next word
		output reg [WIDTH-1:0]  dout,    // Data out
		output         full,
		output         nearly_full,
		output 			recieve_more_than_0,
		output 			recieve_more_than_1,
		input          reset,
		input          clk
	
	);
	
	
	
	`LOG2
	
	localparam DEPTH_WIDTH = log2(MAX_DEPTH_BITS +1);
	
	wire 	[MAX_DEPTH_BITS-2 	: 	0]	mux_in	[WIDTH-1		:0];
	wire	[DEPTH_WIDTH-1			:	0] mux_sel;
	wire 	[WIDTH-1					:	0] mux_out;
	
	wire 										empty;
	reg	[MAX_DEPTH_BITS-2 	: 	0]	shiftreg [WIDTH-1		:0];
	reg	[DEPTH_WIDTH-1			:	0]	depth;
	
	wire out_sel ;
	wire out_ld ;
	wire [WIDTH-1					:	0]  dout_next;
	
	
	genvar i;
	generate 
		for(i=0;i<WIDTH; i=i+1) begin : lp
			if(MAX_DEPTH_BITS>2) begin 
				always @(posedge clk ) begin 
					//if (reset) begin 
					//	shiftreg[i] <= {MAX_DEPTH_BITS{1'b0}};
					//end else begin
						if(wr_en) shiftreg[i] <= {shiftreg[i][MAX_DEPTH_BITS-3 	: 	0]	,din[i]};
					//end
				end
			end else begin
				always @(posedge clk ) begin 
					//if (reset) begin 
					//	shiftreg[i] <= {MAX_DEPTH_BITS{1'b0}};
					//end else begin
						if(wr_en) shiftreg[i] <= din[i];
					//end
				end //always
			end //else
			assign mux_in[i] 	= shiftreg[i];
			assign mux_out[i]	= mux_in[i][mux_sel];
			assign dout_next[i] = (out_sel) ? mux_out[i] : din[i]; 	
		end //for
	endgenerate
	
	
	always @(posedge clk) begin
		if (reset) begin
			 depth  <= {DEPTH_WIDTH{1'b0}};
		end else begin
			 if (wr_en & ~rd_en) depth <=
						// synthesis translate_off
						#1
						// synthesis translate_on
						depth + 1'h1;
			else if (~wr_en & rd_en) depth <=
						// synthesis translate_off
						#1
						// synthesis translate_on
						depth - 1'h1;
			
		end
	end//always
	
	
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			 dout  <= {WIDTH{1'b0}};
		end else begin
			 if (out_ld) dout <= dout_next;
		end
	end//always
	
		
assign full 						= depth == MAX_DEPTH_BITS;
assign nearly_full 				= depth >= MAX_DEPTH_BITS-1;
assign empty 						= depth == 'h0;
assign recieve_more_than_0 	= ~ empty;
assign recieve_more_than_1 	= ~( depth == 0 ||  depth== 1 );
assign out_sel 					= (recieve_more_than_1)	 ? 1'b1 : 1'b0;
assign out_ld 						= (depth !=0 )?  rd_en : wr_en;
assign mux_sel 					= depth-2'd2;	
	
	 // synthesis translate_off
   always @(posedge clk)
   begin
      if (wr_en && full) begin
         $display("%t ERROR: Attempt to write to full FIFO: %m", $time);
      end
      if (rd_en && !recieve_more_than_0) begin
         $display("%t ERROR: Attempt to read an empty FIFO: %m", $time);
      end
   end // always @ (posedge clk)
   // synthesis translate_on
	





endmodule	
	
