module amp(spi_clk, reset, cs, din, dout, gain_state);

	parameter Tp = 1;
	
	input spi_clk, reset, cs, din;
	output dout;
	output [7:0] gain_state;
	
	reg [0:7] data;
	reg [7:0] gain_state;
 	
	reg temp, dout;
		
	always @(cs or reset)
	begin
		if(reset)
			gain_state <= 'bz;
		else
			gain_state <= #Tp data;
	end	
		
	always @(posedge spi_clk or posedge reset)
	begin
		if(reset)
		begin
			temp <= 1'b0;
			data <= 'b0;
		end
		else if(!cs)
		begin
			data <= #Tp  {din,data[0:6]};
			temp <= #Tp  data[7];
		end
	end

	always @(negedge spi_clk)
		dout <= #Tp data[7];

	
endmodule