`include "timescale.v"
`include "spi_defines.v"
//	spi_top tb
module spi_top_tb2();

	//
	// FOR SPI_TOP COMPLETED SUNDAY NOV 15th
	//
	
	//parameters
	parameter CLKPERIOD = 20;
	//
	// Control words
	//
	
	parameter CTRL_PREP		= 	14'h0E18; //TXC=0, SAMPLE = 0,| LSB=1, TXN=1, RXN=1, GO=0,| WR=0, LEN=24bits
	parameter CTRL_TXC		=	14'h2E18; //TXC=1, SAMPLE = 0,| LSB=1, TXN=1, RXN=1, GO=0,| WR=0, LEN=24bits 
	parameter CTRL_GOSAMPLE	=	14'h1F18; //TXC=0, SAMPLE = 1,| LSB=1, TXN=1, RXN=1, GO=1,| WR=0, LEN=24bits
	parameter CTRL_GOWRITE	=	14'h0F98; //TXC=0, SAMPLE = 0,| LSB=1, TXN=1, RXN=1, GO=1,| WR=1, LEN=24bits
	parameter CTRL_GOALL	=	14'h1F98; //TXC=0, SAMPLE = 1,| LSB=1, TXN=1, RXN=1, GO=1,| WR=1, LEN=24bits

	parameter DIV_VALUE		=	24'h000010; //dec 16
	
	parameter DAC_A			=	4'h0; // choose dac A
	parameter DAC_COMMAND	=	4'h3; // write to adn update dac n
	parameter FINISHTIME	=	186*1000; //17 ns per write...

	// dut inputs
	reg clk;
	reg rst;
	reg ampDAC;
	reg load_div;
	reg load_ctrl;
	reg [23:0] data_in;
	// interconnect wires
	wire spi_mosi;
	wire amp_miso;
	wire dac_miso;
	wire adc_miso;
	wire spi_clk;	
	wire [1:0] ss_o;
	wire conv;

	reg fin, fin1;
	reg [23:0] data_tbw; //data to be written
	reg [11:0] dac_data_in;
	
	//output wires
	wire [7:0] 	gain_state;
	wire [3:0] 	dac_command;
	wire [3:0] 	dac_n;
	wire [11:0] dac_data;
	wire 		go;
	wire [13:0] chanA;
	wire [13:0] chanB;
	wire 		adcValid;

	// events
	event write_command, reset, write_div, write_dac, write_amp, read_adc, rw_DSP;

	// dut outputs
	
	/*
	// dut
	/*spi_top spi_core (.clk(), .rst(), .ampDAC(), .data_in(), .chanA(), .chanB(), .adcValud(), .load_div(),
		 	.load_ctrl(), . go(), .conv, ss_pad_o(), 
			.sclk_pad_o(), .mosi_pad_o(), .miso_pad_i()); */
	spi_top spi_core (.clk(clk), 
					.rst(rst), 
					.ampDAC(ampDAC), 
					.data_in(data_in),
					.chanA(chanA),
					.chanB(chanB),
					.adcValid(adcValid),
					.load_div(load_div),
				 	.load_ctrl(load_ctrl),
				  	.go(go), 
					.conv(conv),
				 	.ss_pad_o(ss_o), 
					.sclk_pad_o(spi_clk),
					.mosi_pad_o(spi_mosi),
					.miso_pad_i(adc_miso));

	// spi models
	// dac(.spi_clk(), .reset(), .cs(), .din(), .dout(), .command(), .dacN(), .dacDATA());
	// amp(.spi_clk(), .reset(), .cs(), .din(), .dout(), .gain_state());
	// adc(.sdo(), .spi_clk(), .clk(), .rst(), .conv() );
	dac dac_test (.spi_clk(spi_clk), 
	.reset(rst), .cs(ss_o[0]), .din(spi_mosi), 
					.dout(dac_miso), 
					.command(dac_command), 
					.dacN(dac_n), 
					.dacDATA(dac_data));
	amp amp_test (.spi_clk(spi_clk), 
					.reset(rst), 
					.cs(ss_o[1]), 
					.din(spi_mosi), 
					.dout(amp_miso),
				 	.gain_state(gain_state));
	adc adc_test(.sdo(adc_miso), 
					.spi_clk(spi_clk),
				 	.clk(clk), 
					.rst(rst), 
					.conv(conv));
	// dut stimulus
	// 1 reset
	// 2 write the divider
	// 3 write the control
	// 4 write a word to the amp
	// 5 write a word to the dac
	// 6 read a word from the adc
	// 6 write a procedure for checking the words written

	//clk
	always
		#(CLKPERIOD/2) clk = ~clk;

	//initial conditions
	initial
	begin
		load_div	=0;
		load_ctrl	=0;
		clk			=1;
		ampDAC		=0;
		rst			=0;
		fin 		=0;
		fin1		=0;
		data_in		=24'b0;
		dac_data_in	='b0;
		#FINISHTIME ;
		$display ("Finishing simulation due to simulation constraint.");
		$display ("Time is - %d",$time);
		$finish;
	end
	
	// CTRL_PREP		TXC=0, SAMPLE = 0,| LSB=1, TXN=1, RXN=1, GO=0,| WR=0, LEN=24bits
	// CTRL_TXC			TXC=1, SAMPLE = 0,| LSB=1, TXN=1, RXN=1, GO=0,| WR=0, LEN=24bits 
	// CTRL_GOSAMPLE	TXC=0, SAMPLE = 1,| LSB=1, TXN=1, RXN=1, GO=1,| WR=0, LEN=24bits
	// CTRL_GOWRITE		TXC=0, SAMPLE = 0,| LSB=1, TXN=1, RXN=1, GO=1,| WR=1, LEN=24bits
	// CTRL_GOALL		TXC=0, SAMPLE = 1,| LSB=1, TXN=1, RXN=1, GO=1,| WR=1, LEN=24bits
	// events: write_command, reset, write_div, write_word;
	
	//event ordering
	initial
	begin
		$display("Starting simulation");
		#CLKPERIOD	-> reset;
		wait(fin)
		fin =0;
		
		$display("Reset finished");
		data_in=CTRL_PREP;
		#CLKPERIOD	-> write_command;
		wait(fin)
		fin =0;
		
		data_in=DIV_VALUE;
		#CLKPERIOD  -> write_div;
		wait(fin)
		fin =0;
		
		data_tbw =24'h110000; //write 0x11 to AMP
		#CLKPERIOD 	-> write_amp;
		wait(fin)
		fin =0;
		
		data_tbw = {DAC_COMMAND, DAC_A,dac_data_in,4'b0};
		#CLKPERIOD 	-> write_dac;
		wait(fin)
		fin =0;
		dac_data_in=dac_data_in+1;
		data_tbw = {DAC_COMMAND, DAC_A,dac_data_in,4'b0};
		#CLKPERIOD 	-> write_dac;
		wait(fin)
		fin =0;
		dac_data_in=dac_data_in+1;
		data_tbw = {DAC_COMMAND, DAC_A,dac_data_in,4'b0};
		#CLKPERIOD 	-> write_dac;
		wait(fin)
		fin =0;
		dac_data_in=dac_data_in+1;
		data_tbw = {DAC_COMMAND, DAC_A,dac_data_in,4'b0};
		#CLKPERIOD 	-> write_dac;
		wait(fin)
		fin =0;
		dac_data_in=dac_data_in+1;
		data_tbw = {DAC_COMMAND, DAC_A,dac_data_in,4'b0};
		#CLKPERIOD 	-> write_dac;
		wait(fin)
		fin =0;
		dac_data_in=dac_data_in+1;
		data_tbw = {DAC_COMMAND, DAC_A,dac_data_in,4'b0};
		#CLKPERIOD 	-> write_dac;
		wait(fin)
		fin =0;
		#CLKPERIOD 	-> read_adc;
		wait(fin)
		fin =0;
		#CLKPERIOD 	-> read_adc;
		wait(fin)
		fin =0;
		dac_data_in=dac_data_in+1;
		data_tbw = {DAC_COMMAND, DAC_A,dac_data_in,4'b0};
		#CLKPERIOD 	-> rw_DSP;
		wait(fin)
		fin =0;
		dac_data_in=dac_data_in+1;
		data_tbw = {DAC_COMMAND, DAC_A,dac_data_in,4'b0};
		#CLKPERIOD 	-> rw_DSP;
		wait(fin)
		fin =0;
		dac_data_in=dac_data_in+1;
		data_tbw = {DAC_COMMAND, DAC_A,dac_data_in,4'b0};
		#CLKPERIOD 	-> rw_DSP;
		wait(fin)
		fin =0;
		
		#CLKPERIOD;
		#CLKPERIOD;
		$display ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		$display ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		#CLKPERIOD;
		$display("Finishing up at time %7d", $time);
		$display ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		$display ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

		$finish;
	end
	
	//event definitions
	always @(reset)
	begin
		$display ("entering reset at time %6d",$time);
		#10;
		rst=1;
		#100;
		rst=0;
		$display ("leaving event at time %6d",$time);
		fin =1;
	end
	
	always @(write_div)
	begin
		$display("writing value %3d to divider register",data_in);
		load_div=1;
		#CLKPERIOD;
		load_div=0;
		$display("leaving write_div at time %6d",$time);
		fin =1;
	end

	always @(write_command)
	begin
		$display("writing word %4h to control register",data_in);
		load_ctrl=1;
		#CLKPERIOD;
		load_ctrl=0;
		$display("leaving write_command at time %6d",$time);
		fin =1;
	end

	always @(write_amp)
	begin
		$display("writing word %4h to tx AMP at time %6d",data_tbw, $time);
		data_in = CTRL_TXC;
		$display("writing word %4h to control register",data_in);
		load_ctrl=1;
		#CLKPERIOD;
		load_ctrl=0;
		$display ("returned to write_word event at time %5d",$time);
		data_in = data_tbw;
		#CLKPERIOD;
		load_ctrl=1;
		ampDAC =0;
		data_in = CTRL_GOWRITE;
		#CLKPERIOD;
		load_ctrl=0;
		$display("waiting for go to go low...");
		wait(!go)
		$display("go went low at time %6d",$time);
		#CLKPERIOD;
		fin =1;
	end

	always @(write_dac)
	begin
		$display("writing word %4h to tx DAC at time %6d",data_tbw, $time);
		data_in = CTRL_TXC;
		$display("writing word %4h to control register",data_in);
		load_ctrl=1;
		#CLKPERIOD;
		load_ctrl=0;
		$display ("returned to write_word event at time %6d",$time);
		data_in = data_tbw;
		#CLKPERIOD;
		load_ctrl=1;
		ampDAC =1;
		data_in = CTRL_GOWRITE;
		#CLKPERIOD;
		load_ctrl=0;
		$display("waiting for go to go low...");
		wait(!go)
		$display("go went low at time %6d",$time);
		#CLKPERIOD;
		fin =1;
	end

	always @(read_adc)
	begin
		$display ("Reading from the ADC");
		#CLKPERIOD;
		load_ctrl=1;
		data_in = CTRL_GOSAMPLE;
		#CLKPERIOD;
		load_ctrl=0;
		#2;
		$display("waiting for go to go low...");
		wait(!go)
		$display("go went low at time %6d",$time);
		#CLKPERIOD;
		fin =1;
	end

	always @(rw_DSP)
	begin
		$display("writing word %4h to tx DAC and SAMPLING at time %6d",data_tbw, $time);
		data_in = CTRL_TXC;
		$display("writing word %4h to control register",data_in);
		load_ctrl=1;
		#CLKPERIOD;
		load_ctrl=0;
		$display ("returned to write_word event at time %6d",$time);
		data_in = data_tbw;
		#CLKPERIOD;
		load_ctrl=1;
		ampDAC =1;
		data_in = CTRL_GOALL;
		#CLKPERIOD;
		load_ctrl=0;
		$display("waiting for go to go low...");
		#2;
		wait(!go)
		$display("go went low at time %6d",$time);
		#CLKPERIOD;
		fin =1;	
	end
	//monitor
	//dump the activity
	initial
	begin
		$dumpfile ("waves.vcd");
		$dumpvars(0,spi_top_tb2);
	end

endmodule