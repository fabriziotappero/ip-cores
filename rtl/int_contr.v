`timescale 1ns / 1ps

module interrupt_controller( clk,
                             reset,
									  cs,
									  adr,
									  oe,
									  we,
									  data_i,
									  data_o,
									  int1,
                             int2,
									  int3,
									  int4,
									  int5,
									  int6,
									  int7,
									  ack,
									  dtack,
									  ipl
                            );

input  clk;
input  reset;
input  cs;
input  [3:0] adr;
input  oe;
input  we;
input  [7:0] data_i;
output [7:0] data_o;
input  int1, int2, int3, int4, int5, int6, int7;
input  ack;
output dtack;
output [2:0] ipl;

reg dtack = 1'b0;
reg ack_r = 1'b0;
reg [7:0] data_r;
reg [7:0] vectors [0:6];
reg [2:0] irq_nr [0:6];
reg [6:0] int_mask;
reg [6:0] int_pending;
reg [6:0] ie_reg;
reg [2:0] ipl_r, ipl_n;

wire [2:0] int_no = (6 - ipl_r);
wire assert_ack   = (ack && ~ack_r);
wire deassert_ack = (ack_r && ~ack);

wire [2:0] ix = adr[2:0];
wire vectors_stb_we = (cs && we && adr[3] == 1'b0 && adr[2:0] != 3'b111 );
wire vectors_stb_oe = (cs && oe && adr[3] == 1'b0 && adr[2:0] != 3'b111 );
wire irq_stb_we     = (cs && we && adr[3] == 1'b1 && adr[2:0] != 3'b111 );
wire irq_stb_oe     = (cs && oe && adr[3] == 1'b1 && adr[2:0] != 3'b111 );
wire ier_stb_we     = (cs && we && adr == 4'b0111);
wire ier_stb_oe     = (cs && oe && adr == 4'b0111);

reg int1_r, int2_r, int3_r, int4_r, int5_r, int6_r, int7_r;

wire int1_on = (int1_r == 1'b0 && int1);
wire int2_on = (int2_r == 1'b0 && int2);
wire int3_on = (int3_r == 1'b0 && int3);
wire int4_on = (int4_r == 1'b0 && int4);
wire int5_on = (int5_r == 1'b0 && int5);
wire int6_on = (int6_r == 1'b0 && int6);
wire int7_on = (int7_r == 1'b0 && int7);
wire int1_of = (int1_r == 1'b1 && !int1);
wire int2_of = (int2_r == 1'b1 && !int2);
wire int3_of = (int3_r == 1'b1 && !int3);
wire int4_of = (int4_r == 1'b1 && !int4);
wire int5_of = (int5_r == 1'b1 && !int5);
wire int6_of = (int6_r == 1'b1 && !int6);
wire int7_of = (int7_r == 1'b1 && !int7);

wire pos_edge_trigger = (int1_on || int2_on || int3_on || int4_on || int5_on || int6_on || int7_on );
wire neg_edge_trigger = (int1_of || int2_of || int3_of || int4_of || int5_of || int6_of || int7_of );

integer i;

initial
begin
	int_pending = 7'b0000000;
	int_mask    = 7'b1111111;
	ie_reg      = 7'b1111111;
	ipl_r       = 3'b111;
	dtack       = 1'b1;
	int1_r      = 1'b0;
	int2_r      = 1'b0;
	int3_r      = 1'b0;
	int4_r      = 1'b0;
	int5_r      = 1'b0;
	int6_r      = 1'b0;
	int7_r      = 1'b0;
	for(i=0;i<7;i=i+1)
	begin
		vectors[i] = 25 + i;
		irq_nr[i]  = i;
	end
end

always @(posedge clk)
begin
	if( reset )
	begin
		int1_r <= 1'b0;
		int2_r <= 1'b0;
		int3_r <= 1'b0;
		int4_r <= 1'b0;
		int5_r <= 1'b0;
		int6_r <= 1'b0;
		int7_r <= 1'b0;
	end else begin
		int1_r <= int1;
		int2_r <= int2;
		int3_r <= int3;
		int4_r <= int4;
		int5_r <= int5;
		int6_r <= int6;
		int7_r <= int7;
	end
end

always @(posedge clk)
	if( reset )
		ack_r <= 1'b0;
	else
		ack_r <= ack;

always @(posedge clk)
begin
	if( vectors_stb_we )
		vectors[ix] = data_i;
end

always @(posedge clk)
begin
	if( irq_stb_we )
		irq_nr[ix]  = data_i;
end

always @(posedge clk)
begin
	if( reset )
		ie_reg      = 7'b1111111;
	else if( ier_stb_we )
		ie_reg      = data_i;
end

always @(posedge clk)
begin
	dtack = 1'b1;
	if( ack )
	begin
		if( assert_ack )
			data_r = vectors[int_no];
		dtack  = (ipl_r == 3'b111);
	end else if( cs ) begin
		if( vectors_stb_oe )
			data_r = vectors[ix];
		else if( irq_stb_oe )
			data_r = irq_nr[ix];
		else if( ier_stb_oe )
			data_r = ie_reg;
		else
			data_r = 8'bZ;
		dtack = 1'b0;
	end else
		data_r = 8'bZ;
end

always @(posedge clk)
begin
	if( reset )
	begin
		int_pending = 7'b0000000;
	end else if( pos_edge_trigger ) begin
		if(int7 && ie_reg[6])
			int_pending[6] = 1;
		else if(int6 && ie_reg[5])
			int_pending[5] = 1;
		else if(int5 && ie_reg[4])
			int_pending[4] = 1;
		else if(int4 && ie_reg[3])
			int_pending[3] = 1;
		else if(int3 && ie_reg[2])
			int_pending[2] = 1;
		else if(int2 && ie_reg[1])
			int_pending[1] = 1;
		else if(int1 && ie_reg[0])
			int_pending[0] = 1;
	end else if( neg_edge_trigger ) begin
		if(!int7)
			int_pending[6] = 0;
		if(!int6)
			int_pending[5] = 0;
		if(!int5)
			int_pending[4] = 0;
		if(!int4)
			int_pending[3] = 0;
		if(!int3)
			int_pending[2] = 0;
		if(!int2)
			int_pending[1] = 0;
		if(!int1)
			int_pending[0] = 0;
	end
end

always @(posedge clk)
begin
	if( deassert_ack || reset )
	begin
		ipl_r  = 3'b111;
	end else if( ipl_r == 3'b111 ) begin
		if( int_pending[6] && int_mask[6] )
			ipl_r     = ~irq_nr[6];
		else if( int_pending[5] && int_mask[5] )
			ipl_r     = ~irq_nr[5];
		else if( int_pending[4] && int_mask[4] )
			ipl_r     = ~irq_nr[4];
		else if( int_pending[3] && int_mask[3] )
			ipl_r     = ~irq_nr[3];
		else if( int_pending[2] && int_mask[2] )
			ipl_r     = ~irq_nr[2];
		else if( int_pending[1] && int_mask[1] )
			ipl_r     = ~irq_nr[1];
		else if( int_pending[0] && int_mask[0] )
			ipl_r     = ~irq_nr[0];
	end
end

always @(posedge clk)
begin
	if( reset )
		int_mask = 7'b1111111;
	else if ( !pos_edge_trigger && !neg_edge_trigger )
		casex(int_pending)
			7'b1xxxxxx: int_mask = 7'b0000000;
			7'b01xxxxx: int_mask = 7'b1000000;
			7'b001xxxx: int_mask = 7'b1100000;
			7'b0001xxx: int_mask = 7'b1110000;
			7'b00001xx: int_mask = 7'b1111000;
			7'b000001x: int_mask = 7'b1111100;
			7'b0000001: int_mask = 7'b1111110;
			7'b0000000: int_mask = 7'b1111111;
		endcase
end

assign data_o = data_r;

assign ipl = ipl_r;

endmodule
