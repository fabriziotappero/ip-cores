

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

// number sorting, tree-like implementation, sequential, 
// energy efficient (theoreticaly) 
//	see sort_tree_algorithm.png to catch the idea


//	following code is for recursive module idea 
// description, it is not part of the project

module NodeType (  );
endmodule



module TreeTemplate (  );
 
parameter TREE_LEVEL= 4;

NodeType node();	

generate
if ( TREE_LEVEL >0 )
begin
	TreeTemplate #( TREE_LEVEL-1 ) leftSubtree (  );
	TreeTemplate #( TREE_LEVEL-1 ) rightSubtree (  );
end
endgenerate

endmodule


//	here is the real implementation

module Sorting_Tree ( clk, hold, is_input, data_in, data_out	);
 
parameter HBIT= 15;

parameter R_SZ= 256;
parameter TREE_LEVEL= 4;

input clk;
input hold;
input is_input;

input [HBIT:0] data_in;
output [HBIT:0] data_out;
wire [HBIT:0] in_next= lead_1 ? d_out1 : d_out2;

wire [HBIT:0] d_out1;
wire [HBIT:0] d_out2;

generate
if ( TREE_LEVEL >0 )
begin
	Cell_Compare  #( HBIT ) top_buf ( clk, hold,  is_input, data_in, in_next, data_out );
	Sorting_Tree #( HBIT, R_SZ/2,     TREE_LEVEL-1 ) cstack1 ( clk, hold1, is_input, data_out, d_out1	);
	Sorting_Tree #( HBIT, (R_SZ-1)/2, TREE_LEVEL-1 ) cstack2 ( clk, hold2, is_input, data_out, d_out2	);
end
else
begin
	Sorting_Stack #( HBIT, R_SZ ) leaf ( clk, hold, is_input, data_in, data_out );
end
endgenerate

bit flipper;

wire lead_1= ( d_out1 > d_out2 );
wire hold1= hold | ~( is_input ? flipper : lead_1 );
wire hold2= hold |  ( is_input ? flipper : lead_1 );

always@(posedge clk )
if (~hold)
begin
  if (is_input)
  begin
	 flipper <= ~flipper;
  end
end

endmodule



