
////////////////////////////////////////////////

module testbench;

	// Inputs
	reg clk;
	reg rst;
	reg load0_i;
	reg load1_i;
	reg load2_i;
	reg load3_i;
	reg load4_i;
	reg load5_i;
	reg load6_i;
	reg [7:0] writedata0_i;
	reg [7:0] writedata1_i;
	reg [7:0] writedata2_i;
	reg [7:0] writedata3_i;
	reg [7:0] writedata4_i;
	reg [7:0] writedata5_i;
	reg [7:0] writedata6_i;
	reg start_i;
	reg abort_i;

	// Outputs
	wire [7:0] readdata0_o;
	wire [7:0] readdata1_o;
	wire [7:0] readdata2_o;
	wire [7:0] readdata3_o;
	wire [7:0] readdata4_o;
	wire [7:0] readdata5_o;
	wire [7:0] readdata6_o;
	wire done_o;
	wire interrupt_o;

	// Instantiate the Unit Under Test
	bublesort #(8,7)
	uut (
		.clk(clk), 
		.rst(rst), 
		.load_i({load6_i,load5_i,load4_i,load3_i,load2_i,load1_i,load0_i}), 
		.writedata_i({writedata6_i,writedata5_i,writedata4_i,writedata3_i,writedata2_i,writedata1_i,writedata0_i}), 
		.readdata_o({readdata6_o,readdata5_o,readdata4_o,readdata3_o,readdata2_o,readdata1_o,readdata0_o}), 
		.start_i(start_i), 
		.done_o(done_o), 
		.interrupt_o(interrupt_o), 
		.abort_i(abort_i)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		load0_i = 0;

		writedata0_i = 0;

		load1_i = 0;

		writedata1_i = 0;

		load2_i = 0;

		writedata2_i = 0;

		load3_i = 0;

		writedata3_i = 0;

		load4_i = 0;

		writedata4_i = 0;

		load5_i = 0;

		writedata5_i = 0;

		load6_i = 0;

		writedata6_i = 0;

		start_i = 0;
		abort_i = 0;
         
		// Wait 10 ns
		#10;
        
		// Stimulus 
        clk = 1; #5 clk = 0; #5;

        clk = 1; #5 clk = 0; #5;

        clk = 1; #1;

            rst = 0;

            #4; clk = 0; #5;

        clk = 1; #5 clk = 0; #5;

        clk = 1; #1;

            writedata0_i = 0;

            writedata1_i = 7;

            writedata2_i = 100;

            writedata3_i = 254;

            writedata4_i = 255;

            writedata5_i = 128;

            writedata6_i = 2;

            load0_i = 1;

            load1_i = 1;

            load2_i = 1;

            load3_i = 1;

            load4_i = 1;

            load5_i = 1;

            load6_i = 1;

            #4; clk = 0; #5;

        clk = 1; #1;

            writedata0_i = 0;

            writedata1_i = 0;

            writedata2_i = 0;

            writedata3_i = 0;

            writedata4_i = 0;

            writedata5_i = 0;

            writedata6_i = 0;

            load0_i = 0;

            load1_i = 0;

            load2_i = 0;

            load3_i = 0;

            load4_i = 0;

            load5_i = 0;

            load6_i = 0;

            #4; clk = 0; #5;

        clk = 1; #1;

            start_i = 1;

            #4; clk = 0; #5;

        clk = 1; #1;

            start_i = 0;

            #4; clk = 0; #5;

        while(!interrupt_o) begin

            clk = 1; #5 clk = 0; #5;

        end

        clk = 1; #5 clk = 0; #5;

        clk = 1; #5 clk = 0; #5;

        clk = 1; #5 clk = 0; #5;

        clk = 1; #5 clk = 0; #5;

        clk = 1; #5 clk = 0; #5;

        clk = 1; #5 clk = 0; #5;

        clk = 1; #5 clk = 0; #5;

        clk = 1; #5 clk = 0; #5;

	end
      
endmodule

