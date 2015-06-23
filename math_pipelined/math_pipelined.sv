
module mull_pipelined(
	input clk,
	input [7:0] x,
	input [7:0] y,
	output [15:0] z
	);
	
reg [7:0] cx [7:0];
reg [7:0] cy [7:0];
reg [15:0] cz [15:0];
assign z= cz[7];

	
always @( posedge clk ) 
begin : multblk
	integer ind;
	cx[0]<= x;
	cy[0]<= y;
	cz[0]<= y[0]? x : 0;
	for (ind=0; ind<6; ind=ind+1)
	begin
		cy[ind+1]<= cy[ind];
		cx[ind+1]<= cx[ind];
		cz[ind+1]<= cz[ind] + (cy[ind][ind+1]? (cx[ind]<<(ind+1)) : 0);
	end
	cz[7]<= cz[6] + (cy[6][7]? cx[6] : 0);
end
endmodule
	
	
//module div_pipelined(
//	input clk,
//	input [15:0] x,
//	input [7:0] y,
//	output [7:0] z
//	);
//
//parameter BITS= 8;
//	
//reg [15:0] cx [15:0];
//reg [7:0] cy [7:0];
//reg [7:0] cz [7:0];
//assign z= cz[7];
//
//wire [15:0] candidate [7:0]; 
//
//assign candidate[0]= x- (y<<7);
//
//`define MY_EXPR(ind) assign candidate[(ind+1)]= cx[(ind)]- (cy[(ind)]<<(6-ind))
//
//`MY_EXPR( 0 );
//`MY_EXPR( 1 );
//`MY_EXPR( 2 );
//`MY_EXPR( 3 );
//`MY_EXPR( 4 );
//`MY_EXPR( 5 );
//`MY_EXPR( 6 );
//
//always @( posedge clk ) 
//begin : multblk
//	integer ind;
//	integer j;
//	cx[0]<= candidate[0][15] ? x : candidate[0];
//	cy[0]<= y;
//	cz[0][7]<= candidate[0][15] ? 0 : 1;
//	for (ind=0; ind<6; ind=ind+1)
//	begin
//		cy[ind+1]<= cy[ind];
//		cx[ind+1]<= candidate[ind+1][15] ? cx[ind] : candidate[ind+1];
//		cz[ind+1][6-ind]<= candidate[ind+1][15] ? 0 : 1;
//		for (j=7; j>6-ind; j=j-1)
//		begin
//			cz[ind+1][j]<= cz[ind][j];	
//		end
//	end
//	cz[7][0]<= candidate[7][15] ? 0 : 1;
//	cz[7][7:1]<=cz[6][7:1];
//end
//endmodule
	
















	
module div_pipelined(
	input clk,
	input [D_UP:0] x,
	input [UP:0] y,
	output [UP:0] z
	);

parameter BITS= 48;
//	���������� ���������, �� ��������������.
parameter UP= BITS-1;
parameter D_UP= 2*BITS-1;
	
reg [D_UP:0] cx [UP:0];
reg [UP:0] cy [UP:0];
reg [UP:0] cz [UP:0];
reg csign [UP:0];

assign z= (csign[UP] ? -cz[UP]:cz[UP]);

wire [D_UP:0] candidate [UP:0]; 

wire [D_UP:0] ux= ( (x[D_UP]) ? (-x):x );
wire [UP:0] uy= ( (y[UP]) ? (-y):y );
wire [D_UP:0] _uy= uy;

wire [D_UP:0] _cy [UP:0];

always @* 
begin
	integer ind;
	candidate[0]<= ux- (_uy<<UP);
	for (ind=0; ind< BITS-2 ; ind=ind+1)
	begin
		_cy <= cy;
		candidate[ind+1]<= cx[ind]- (_cy[ind]<<(BITS-2-ind));
	end
end


always @( posedge clk ) 
begin : multblk
	integer ind;
	integer j;
	csign[0]= x[D_UP]^y[UP];
	cx[0]<= candidate[0][D_UP] ? ux : candidate[0];
	cy[0]<= uy;
	cz[0][UP]<= ~candidate[0][D_UP];	//	!!! sign bit?
	for (ind=0; ind< BITS-1 ; ind=ind+1)
	begin
		cy[ind+1]<= cy[ind];
		cx[ind+1]<= candidate[ind+1][D_UP] ? cx[ind] : candidate[ind+1];
		cz[ind+1][ BITS-2 -ind]<= ~candidate[ind+1][D_UP];
		csign[ind+1]<= csign[ind];
		for (j=UP; j> BITS-2 -ind; j=j-1)
		begin
			cz[ind+1][j]<= cz[ind][j];	
		end
	end
//	cz[UP][0]<= ~candidate[UP][D_UP];
//	cz[UP][UP:1]<=cz[ BITS-2 ][UP:1];
//	csign[UP]<= csign[UP-1];
end
endmodule


module id_pipelined(
	input clk,
	input [UP:0] i,
	output [UP:0] o
	);

parameter BITS= 32;
parameter DELAY= 32;
//	���������� ���������, �� ��������������.
parameter UP= BITS-1;
	
reg [UP:0] cx [DELAY];

assign o= cx[DELAY-1];

always @( posedge clk ) 
begin : blk
	integer ind;
	cx[0]<= i;
	for (ind=0; ind< DELAY-1 ; ind=ind+1)
	begin
		cx[ind+1]<= cx[ind];
	end
end
endmodule
	
	

	