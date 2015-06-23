`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:51:55 05/08/2009 
// Design Name: 
// Module Name:    time_analysis 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//           rs232
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//  Marius TIVADAR.
//
//////////////////////////////////////////////////////////////////////////////////
module time_analysis(
		clk,
		RST,
		start,
		time_cnt,
		busy,
		TxD
    );

input clk;
input RST;
input [31:0] time_cnt;
input start;
output busy;
output TxD;



reg [31:0] data;

wire TxD_busy;

reg [7:0] chunk_q;
reg [7:0] chunk_d;
//reg [3:0] nibble;
reg [7:0] hex_byte_d;
reg [7:0] hex_byte_q;
reg [4:0] how_many_q;
reg busy_q;

reg [2:0] state_d;
reg [2:0] state_q;



parameter GATHER_0   = 3'b000;
parameter GATHER     = 3'b001;
parameter TRANSMIT_0 = 3'b010;
parameter TRANSMIT   = 3'b011;
parameter DONE       = 3'b100;

 rs232 tx(.clk(clk), 
			 .RST(RST), 
			 .TxD_data(hex_byte_q), 
			 .TxD_start(state_q == TRANSMIT_0), 
			 .TxD_busy(TxD_busy),
			 .TxD(TxD));
 


//assign test = TxD;
wire [3:0] nibble = data[31:28];
assign busy = busy_q;
reg busy_nibble_d;
reg busy_nibble_q;

always @( * ) begin
   state_d = state_q;
	busy_nibble_d = busy_nibble_q;
	hex_byte_d = hex_byte_q;
	case (state_q) 
		 GATHER_0: begin
						 state_d  = GATHER; 
						 busy_nibble_d = 1;						 
					  end
	    GATHER:
		     begin
					if ( how_many_q == 5'b01000) begin
							hex_byte_d = 8'd10;
					end
					else begin
						case (nibble)
							 4'b0000 : hex_byte_d = 8'h30;
							 4'b0001 : hex_byte_d = 8'h31;
							 4'b0010 : hex_byte_d = 8'h32;
							 4'b0011 : hex_byte_d = 8'h33;
							 4'b0100 : hex_byte_d = 8'h34;
							 4'b0101 : hex_byte_d = 8'h35;
							 4'b0110 : hex_byte_d = 8'h36;
							 4'b0111 : hex_byte_d = 8'h37;
							 4'b1000 : hex_byte_d = 8'h38;
							 4'b1001 : hex_byte_d = 8'h39;
							 4'b1010 : hex_byte_d = 8'h61;
							 4'b1011 : hex_byte_d = 8'h62;
							 4'b1100 : hex_byte_d = 8'h63;
							 4'b1101 : hex_byte_d = 8'h64;
							 4'b1110 : hex_byte_d = 8'h65;
							 4'b1111 : hex_byte_d = 8'h66;
							 
						endcase
						
						
					end
					state_d = TRANSMIT_0;
			  end
		TRANSMIT_0: begin
						//hex_byte_q is ready
		              state_d = TRANSMIT;
					   end
						/*
		TRANSMIT_1: begin
							if ( ~TxD_busy ) begin
													state_d = TRANSMIT_1;
												 end
							else begin
								state_d = TRANSMIT;
							end
					   end
						*/
		TRANSMIT: begin
						if ( TxD_busy ) begin
							state_d = TRANSMIT;
						end
						else begin
						   busy_nibble_d = 0;
							state_d = DONE;
						end
						
					 end
		DONE: begin
					busy_nibble_d = 1;
					state_d = state_q;
				end
	endcase
end

always @(posedge clk) begin
    if (RST) begin
		data <= 0;
		how_many_q <= 0;
		busy_q <= 0;
		state_q <= GATHER_0;
		busy_nibble_q <= 0;
		hex_byte_q <= 0;
	 end
	 else begin
		if ( start ) begin
		   data <= time_cnt;
			state_q <= GATHER_0;
			how_many_q <= 0;
			busy_q <= 1;
			busy_nibble_q <= 1;
			hex_byte_q <= 0;
			
		end
		else begin
		
		  if ( (how_many_q < 5'b01000) && (~busy_nibble_q) ) begin
		     busy_q <= 1;
 			  data <= { data[28:0], data[31:28] };

			  how_many_q <= how_many_q + 1;
			  state_q <= GATHER_0;
		  end	
		  else
		  if ( (how_many_q == 5'b01000) && (~busy_nibble_q) )
		  begin
		      how_many_q <= how_many_q;
				state_q <= state_d;
				busy_q <= 0;
		  end
		  else begin
			  how_many_q <= how_many_q;
			  state_q <= state_d;
			  hex_byte_q <= hex_byte_d;
			  busy_q <= busy_q;
				
		  end
		  busy_nibble_q  <= busy_nibble_d;
		  hex_byte_q <= hex_byte_d;
  
		end
	 end
end


endmodule
