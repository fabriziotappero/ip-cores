module hazard_unit	
		( 
		  clk,load,rt,hold,
		  load_o,rt_o
		);


input clk;
wire clk;
input load;
wire load;
input [4:0] rt;
wire [4:0] rt;
output load_o;
wire load_o;
output [4:0] rt_o;
wire [4:0] rt_o;
input hold;
wire hold;





r1_reg load1 (.hold(hold),
		.clk(clk),
		.r1_i(load),
		.r1_o(load_o)
	    );

r5_reg rt1
            (.hold(hold),
                .clk(clk),
                .r5_i(rt),
                .r5_o(rt_o)
            );

		
	
	
endmodule