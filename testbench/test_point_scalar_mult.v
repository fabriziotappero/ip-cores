`timescale 1ns / 1ps
`include "../rtl/inc.v"

module test_point_scalar_mult;

	// Inputs
	reg clk;
	reg reset;
	reg [`WIDTH:0] x1, y1;
	reg zero1;
    reg [`SCALAR_WIDTH:0] c;

	// Outputs
	wire done;
	wire zero3;
    wire [`WIDTH:0] x3, y3;

	// Instantiate the Unit Under Test (UUT)
	point_scalar_mult uut (
		.clk(clk), 
		.reset(reset), 
		.x1(x1), 
		.y1(y1), 
		.zero1(zero1), 
		.c(c), 
		.done(done), 
		.x3(x3), 
		.y3(y3), 
		.zero3(zero3)
	);

    initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		x1 = 0;
		y1 = 0;
		zero1 = 0;
		c = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        // if scalar value is zero, then the result is inf point
        x1 = 194'h2a4290286121261a82446a41200622024988295015114486;
        y1 = 194'h16595a61040a8611209820112a1582a081a1a182264601252;
        zero1 = 0;
        c = 0;
        go;
        if (zero3 !== 1) begin $display("E"); $finish; end else $display(":D");

        // if scalar value is one, then the result is the input point, test case 1
        x1 = 194'h2a4290286121261a82446a41200622024988295015114486;
        y1 = 194'h16595a61040a8611209820112a1582a081a1a182264601252;
        zero1 = 0;
        c = 1;
        go;
        if (zero3 !== 0 ||
            x3 !== 194'h2a4290286121261a82446a41200622024988295015114486 ||
            y3 !== 194'h16595a61040a8611209820112a1582a081a1a182264601252
            ) begin $display("E"); $finish; end 
        else $display(":D");

        // if scalar value is one, then the result is the input point, test case 2
        x1 = 194'h2a4290286121261a82446a41200622024988295015114486;
        y1 = 194'h16595a61040a8611209820112a1582a081a1a182264601252;
        zero1 = 1;
        c = 1;
        go;
        if (zero3 !== 1) begin $display("E"); $finish; end        
        else $display(":D");

        // if scalar value is one thousand. test case 1
        x1 = 194'h126569286a9860859046680265109015266416aa984082610;
        y1 = 194'h2a41880890628944a6844a269258216041061196854181160;
        zero1 = 0;
        c = 1000;
        go;
        if (zero3 !== 0 ||
            x3 !== 194'h221495405a9425682104a6a005a42a562564469158a962019 ||
            y3 !== 194'h1048569408a2846964811161095218005098aa06582419a46
            ) begin $display("E"); $finish; end        
        else $display(":D");
        
        // if scalar value is one thousand. test case 2
        x1 = 194'h126569286a9860859046680265109015266416aa984082610;
        y1 = 194'h2a41880890628944a6844a269258216041061196854181160;
        zero1 = 1;
        c = 1000;
        go;
        if (zero3 !== 1) begin $display("E"); $finish; end        
        else $display(":D");

        // if scalar value is the order of the generator point, then the result is the inf point
        x1 = 194'h288162298554054820552a05426081a1842886a58916a6249;
        y1 = 194'h2895955069089214054596a189a4420556589054140941695;
        zero1 = 0;
        c = 152'd2726865189058261010774960798134976187171462721;
        go;
        if (zero3 !== 1) begin $display("E"); $finish; end
        else $display(":D");
        
        // good work, buddy
        $display("nice!");
        $finish;
	end
	
	always #5 clk = ~clk;
	
	task go;
      begin
    	@ (negedge clk); reset = 1; @ (negedge clk); reset = 0;
        @ (posedge done); #5 ;
      end
	endtask
endmodule

