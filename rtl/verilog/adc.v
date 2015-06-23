module adc(sdo,spi_clk,clk,rst,conv);
	parameter WIDTH=14; //multiple of two
	parameter PATTERN = {WIDTH/2{2'b10}};
	parameter COUNTMAX = 34;

	input rst, conv, spi_clk, clk;
	output sdo;
	
	reg [WIDTH-1:0] mem;
	reg sdo;
	
	reg flag;
	reg [6:0] count;
	
	integer N;
	
	initial
	begin
		mem = PATTERN;
	end
	
/*	always@ (posedge conv or posedge rst)
	begin
		if(rst)
			flag <= 0;
		else
			flag <= 1;
	end*/
	
	always@ (posedge clk or posedge rst)
	begin
		if(rst)
			flag <= 0;
		else if (conv)
			flag <= 1;
		else if (count == COUNTMAX)
		begin
			count <= 'b0;
			flag <= 0;
			mem = ~mem;	
		end
	end
	
	always @(negedge spi_clk or posedge rst)
	begin
		if (rst)
			count <= 0;
		else if(flag & !rst)
			if(count==COUNTMAX)
				count <= 'b0;
			else
				count <= count+1;
	end

	always@(count)
	begin
	case(count)
		0 : sdo <= 'bZ;
		1 : sdo <= 'bZ;
		2 : sdo <= 'bZ;
		3 : sdo <= mem[13];
		4 : sdo <= mem[12];
		5 : sdo <= mem[11];
		6 : sdo <= mem[10];
		7 : sdo <= mem[9];
		8 : sdo <= mem[8];
		9 : sdo <= mem[7];
		10 : sdo <= mem[6];
		11 : sdo <= mem[5];
		12 : sdo <= mem[4];
		13 : sdo <= mem[3];
		14 : sdo <= mem[2];
		15 : sdo <= mem[1];
		16 : sdo <= mem[0];
		17 : sdo <= 'bZ;
		18 : sdo <= 'bZ;
		19 : sdo <= mem[13];
		20 : sdo <= mem[12];
		21 : sdo <= mem[11];
		22 : sdo <= mem[10];
		23 : sdo <= mem[9];
		24 : sdo <= mem[8];
		25 : sdo <= mem[7];
		26 : sdo <= mem[6];
		27 : sdo <= mem[5];
		28 : sdo <= mem[4];
		29 : sdo <= mem[3];
		30 : sdo <= mem[2];
		31 : sdo <= mem[1];
		32 : sdo <= mem[0];
		33 : sdo <= 'bZ;
		34 : sdo <= 'bZ;
		default: sdo <= 'bZ;
	endcase
	end
	
endmodule