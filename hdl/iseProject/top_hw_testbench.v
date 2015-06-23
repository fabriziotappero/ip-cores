`timescale 1ns / 1ps
/*
Top module that will instantiate and connect our DUT (lcd_controller) the ICON, VIO , ILA cores
For more information refer to this tutorial (Search in docs if link is broken)
http://www.stanford.edu/~phartke/chipscope_tutorial.pdf
http://www.stanford.edu/class/ee183/handouts.shtml
*/
module top_hw_testbench(    
    input clk,
	 output hw_lcd_e,
	 output hw_lcd_rs,
	 output hw_lcd_rw,
	 output [3:0] hw_lcd_nibble,
	 output hw_strata_flash_disable
    );
	
	// Declare some wires to connect the components
	wire rst;
	wire rs_in,strobe_in;
	wire[7:0] data_in, period_clk_ns;
	wire [3:0] lcd_nibble;
	wire lcd_e,lcd_rs,lcd_rw,disable_flash,done;
	
	// Declare the ICON wires
	wire [35: 0] control0;
	wire [35: 0] control1;
	// Declare VIO wires
	wire [18: 0] async_out;
	// Declare ILA wires
	wire trig_0;
	wire [16:0] data;
	
	// Declare clock DCM multiplier (3)
	wire clock3x, clock1x, clockbuf;
	
	// Instantiate our Device under test
	lcd_controller DUT (
		rst,
		clock1x,
		rs_in,
		data_in,
		strobe_in,
		period_clk_ns,
		lcd_e,
		lcd_nibble,
		lcd_rs,
		lcd_rw,
		disable_flash,
		done
		);
	
	// Instantiate the module of clock multiplier		
	 corePLL instance_name (
    .CLKIN_IN(clk), 
    .CLKFX_OUT(clock3x), 
    .CLKIN_IBUFG_OUT(clockbuf), 
    .CLK0_OUT(clock1x)
    );
	 
	 
	coreICON integratedController (
      .CONTROL0(control0), // INOUT BUS [35:0]
      .CONTROL1(control1)
		); // INOUT BUS [35:0]
		
	
	coreILA integratedLogicAnalyser (
      .CONTROL(control0), // INOUT BUS [35:0]
      .CLK(clock3x), // IN
      .DATA(data), // DATA [16:0];
      .TRIG0(trig_0)
	); // IN BUS [0:0]
	
	coreVIO VIO_inst
    (
      .CONTROL(control1), // INOUT BUS [35:0]
		.CLK(clock1x),// clock1x clock3x
		.SYNC_OUT(async_out)	// The clock must be inverted on the core to garantee a good sample point.
      //.ASYNC_OUT(async_out)
	); // IN BUS [18:0]
	
	assign trig_0 = lcd_e;
	assign {rst, rs_in, data_in, strobe_in, period_clk_ns} = async_out;
	assign data = {7'd1,lcd_e, lcd_nibble[3:0], lcd_rs, lcd_rw, disable_flash, done, strobe_in};
	
	// Send all interest output to outside
	assign hw_lcd_e = lcd_e;
	assign hw_lcd_rs = lcd_rs;
	assign hw_lcd_rw = lcd_rw;
	assign hw_lcd_nibble = lcd_nibble;
	assign hw_strata_flash_disable = disable_flash;

endmodule
