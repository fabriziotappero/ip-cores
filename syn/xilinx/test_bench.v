`timescale 1ns/1ps
module s3_test_bench;
	reg clk=0;
	wire tx,rx;
	reg [3:0] button;

	initial begin
		button=4'b1111;//HIGH ACTIVE RESET 
		#800;
		button=4'b0000;	

	end

	always #10 clk=~clk;
	
 s3_vsmpl s3(
  .tx(tx),.rx(rx),.button(button),.clk(clk)
);


endmodule

