module dac(spi_clk, reset, cs, din, dout, command, dacN, dacDATA);
	
	parameter Tp = 1;

	input spi_clk, reset, cs, din;
	output [3:0]	command;
	output [3:0]	dacN;
	output [11:0] 	dacDATA;
	output dout;
		
	reg [0:31] data;
	reg dout;
	reg temp;
		
	assign command = data [0:3];
	assign dacN = data [4:7];
	assign dacDATA = data [8:19];	
		
	always @(posedge spi_clk or posedge reset)
	begin
		if(reset)
		begin
			temp <= 1'b0;
			data <= 'b0;
		end
		else if(!cs)
		begin
			data <= #Tp  {din,data[0:30]};
			temp <= #Tp  data[31];
		end
	end

	always @(negedge spi_clk)
		dout <= #Tp data[31];
	
endmodule