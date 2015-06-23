
////////////////////////////////////////////////////////////
//
// number sorting device, sequential, O(N)
//
//	autor:   Alexey Birukov, leshabirukov@opencores.org
//	license: LGPL 
//
//	notes:
//	reset signal is not implemented, to make reset wait R_SZ clocks
//	while hold==0 and is_input==0 to empty the buffer
//	or implement reset signal by yourself
//
//	to make sorting in increasing order, use module call like this:
//  Sorting_Stack #(HBIT,R_SZ) cstack ( clk, hold, is_input, -1-data_in, _data_out	);
//  wire [HBIT:0] data_out= -1-_data_out;	
//
////////////////////////////////////////////////////////////

// linear buffer implementation
//	sequential, stable, can be partly readed, decreasing order
//	reset signal is not implemented, to make reset wait R_SZ clocks
//	while hold==0 and is_input==0

//	see sort_stack_algorithm.png to catch the idea



module Sorting_Stack ( clk, hold, is_input, data_in, data_out	);

parameter HBIT= 15;				//	size of number in bits
parameter R_SZ= 256;				//	capacity, max sequence size

parameter _R_SZ= (R_SZ+1)/2;	//	not to modify

input clk;
input hold;							// 1 - to freeze state
input is_input;					//	1 - while loading

input [HBIT:0] data_in;			//	load one number at a clock
output [HBIT:0] data_out;		//	while is_input==0, max value popping out here

wire [HBIT:0] in_prev[_R_SZ];
wire [HBIT:0] in_next[_R_SZ];
wire [HBIT:0] out[_R_SZ];

// storage
Cell_Compare #(HBIT) ribbon[_R_SZ] ( clk, hold, is_input,	in_prev, in_next, out );

// wiring
generate
  genvar i,j;
  for (i=0; i<_R_SZ-1; i=i+1) 
  begin : block_name01
		assign in_prev[i+1]= out[i];
		assign in_next[i]= out[i+1];
  end
  assign in_prev[0]= data_in;
  assign data_out= out[0];
  assign in_next[_R_SZ-1]= 0;
endgenerate

endmodule








module Cell_Compare ( clk, hold, is_input, in_prev, in_next, out );

parameter HBIT= 15;


input clk;
input hold;

input is_input;

input [HBIT:0] in_prev;
input [HBIT:0] in_next;

output [HBIT:0] out= is_input ? lower : higher;

bit [HBIT:0] higher;
bit [HBIT:0] lower;

wire [HBIT:0] cand_h= is_input ? higher : lower;
wire [HBIT:0] cand_l= is_input ? in_prev : in_next;

always@(posedge clk )
if (~hold)
begin
	higher <= ( cand_h >= cand_l ) ? cand_h : cand_l;
	lower  <= ( cand_h >= cand_l ) ? cand_l : cand_h;
end
endmodule


 

 
 
