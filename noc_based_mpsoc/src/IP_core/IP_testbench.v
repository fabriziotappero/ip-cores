`timescale  1ns/1ps

module IP_testbench ();
parameter SEVEN_SEG_NUM					=	8;

reg clk,reset,sys_ena_i,sys_int_i;
wire [(SEVEN_SEG_NUM*7)-1:0] seven_segment;

aeMB_SOC #(
.SEVEN_SEG_NUM	(SEVEN_SEG_NUM	)
)
the_soc

(

	.clk					(clk),
	.reset				(reset),
	.sys_int_i			(sys_int_i),
	.sys_ena_i			(sys_ena_i),
	.seven_segment		(seven_segment)
);

	initial begin
		clk = 1'b0;
		forever clk = # 10 ~clk;
	end
	
	initial begin 
	reset =1'b0;
	sys_ena_i =1'b1;
	sys_int_i	=	1'b0;
	
	# 50 
	@(posedge clk )  # 1 reset =1'b1;
	
	#100 
	@(posedge clk )  # 1 reset =1'b0;
	
	
	
	
	
	
	end
	
	
endmodule	
