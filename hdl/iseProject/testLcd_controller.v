`timescale 1ns / 1ps

module testLcd_controller;

	// Inputs
	reg rst;
	reg clk;
	reg rs_in;
	reg [7:0] data_in;
	reg strobe_in;
	reg [7:0] period_clk_ns;

	// Outputs
	wire lcd_e;
	wire [3:0] lcd_nibble;
	wire lcd_rs;
	wire lcd_rw;
	wire disable_flash;
	wire done;

	// Instantiate the Unit Under Test (UUT)
	lcd_controller uut (
		.rst(rst), 
		.clk(clk), 
		.rs_in(rs_in),
		.data_in(data_in), 
		.strobe_in(strobe_in), 
		.period_clk_ns(period_clk_ns), 
		.lcd_e(lcd_e), 
		.lcd_nibble(lcd_nibble), 
		.lcd_rs(lcd_rs), 
		.lcd_rw(lcd_rw), 
		.disable_flash(disable_flash), 
		.done(done)
	);

	// Create clock
	always
	begin
		#10 clk = ~clk;	// Toogle the clock each 10ns (20ns period is 50Mhz)
	end
	
	initial 
	begin
		// Initialize Inputs
		$display($time, " << Starting the Simulation >>");
		$monitor ("lcd_e=%b,lcd_nibble=%b,done=%b", lcd_e,lcd_nibble,done);
		rst = 1;
		clk = 0;
		rs_in = 0;
		data_in = 0;
		strobe_in = 0;
		period_clk_ns = 20;	// Indicate the number of time at each cycle (20 ns in our case)

		// Wait for one clock cycle to reset
		#20;
		rst = 0;
        
		// One advantege over of Verilog over VHDL (Access to internal signals...)
		// Like wait until... from Verilog		
		@(posedge uut.lcd_init_done);
		data_in = 65;
		#20 strobe_in = 1; #20 strobe_in = 0;
		@(posedge done);
		
		// Finish simulation (on VHDL assert false report...)
		$finish;
	end
      
endmodule

