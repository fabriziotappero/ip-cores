//////////////////////////////////////////////////////////////////////
////                                                              ////
////  spi_top.v                                                   ////
////                                                              ////
////  This file is part of the SPI IP core project                ////
////  http://www.opencores.org/projects/spi/                      ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Srot (simons@opencores.org)                     ////
////      - William Gibb (williamgibb@gmail.com)                  ////
//// 			Modified to break RX and TX up					  ////
////			Fixed TX Width of 24 Bits                         ////
////            Fixed RX Width for LTC ADC on S3A/S3AN Starter Kit////
////                                                              ////
////  All additional information is avaliable in the Readme.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002 Authors                                   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


`include "spi_defines.v"
`include "timescale.v"

module spi_top
(
	// Input
 clk, rst, ampDAC, data_in, load_div, load_ctrl, 
	// output 
	go, chanA, chanB, adcValid,
  // SPI signals
  ss_pad_o, sclk_pad_o, mosi_pad_o, miso_pad_i, conv 
);

	parameter Tp = 1; //assume register transactions will take some time...
	parameter MAXCOUNT = 24;
	parameter CONVCOUNT = 12;			
	

	input 			clk;		// master system clock
	input			rst;		// synchronous active high reset
	input			ampDAC;		// ampDAC chip select signal, used to select between
	 							// sending data to the preamp and DAC
	input	[23:0]	data_in;	// data input
	input			load_ctrl;	// load the ctrl register
	input			load_div;	// load the divider
	
	output 				go;			// go! signal
	output 		[13:0]	chanA;		// adc channelB
	output 		[13:0]	chanB;		// adc channelA
	output 				adcValid;	// data valid output signal
	
                                                     
  // SPI signals
	output	[1:0]	ss_pad_o;	// spi slave select
	output 			conv;		// ADC sampling signal
	output			sclk_pad_o;	// serial clock
	output			mosi_pad_o; // master out slave in
	input			miso_pad_i; // master in slave out			
                                                     
//  reg                     [27:0] dat_o;
//  reg                              wb_ack_o;

                                               
  // Internal signals
	reg       [`SPI_DIVIDER_LEN-1:0] 	divider;          // Divider register
	reg       [`SPI_CTRL_BIT_NB-1:0] 	ctrl;             // Control and status register
	reg             			[1:0]	ss;			// Slave select register
	reg 					[1:0] 		Q; 				//reg for delaying the go signal two cycles for the adc
	reg 					[5:0]		Qcount;
	reg									adcValid;			//rw data signal
	wire 	[`SPI_ADC_CHAR-1:0] 		adcData; //data_out
	wire                             	rx_negedge;       // miso is sampled on negative edge
	wire                             	tx_negedge;       // mosi is driven on negative edge
	wire    [`SPI_CHAR_LEN_BITS-1:0] 	char_len;         // char len
	wire                             	go;               // go
	wire                             	goRX;             // goRX
	wire                             	goTX;             // goTX
	wire                             	lsb;              // lsb first on line
	wire                             	tip;              // transfer in progress
	wire                             	tipRX;            // transfer in progress, exclusive RX
	wire                             	tipTX;            // transfer in progress, exclusive TX
	wire                             	pos_edge;         // recognize posedge of sclk
	wire                             	neg_edge;         // recognize negedge of sclk
	wire                             	last_bitTX;       // marks last character bit TX
	wire                             	last_bitRX;       // marks last character bit RX
	wire                             	last_bit;         // marks last character bit
	wire								amp;
	wire								dac;
	wire								tx_capture;
	reg									conv;
	wire								Write;
	wire								Sample;
	reg									stop;

	/* 
	TODO LIST
	
	ADD THE SPI RX PORTION
	DONE----INSTANTIATE SPI_SHIFT_IN
	DONE----SPLIT UP CONTROL SIGNALS THAT CONTROL THE TX FROM THE CONTROL SIGNALS
		WHICH WILL CONTROL THE RX	
	DONE----MAKE TIP BE FEED BY TWO SEPARATE TIP SIGNALS, TIPRX  TIPTX
		====THIS WILL LET SPI_CLGEN KEEP RUNNING IF TX FINISHES FIRST
	DONE----KEEP GO AS A SPI ENABLE SIGNAL, HAVE IT ENABLE THE APPROPRIATE MODULE
		BY USING THE WRITE/SAMPLE SIGNAL WITH AN AND GATE
	DONE----ADD A PULSE COUNTER, PARAMETERIZED TO GENERATE CONV PULSE
	DONE----ADD A DATA_VALID SIGNAL TO ENABLE THE READING OF THE DATA OUTPUT
	DONE----SPLIT THE OUTPUT OF THE RX INTO TWO CHANNELS	
	*/
	
	// Divider register
	always @(posedge clk or posedge rst)
	begin
		if (rst)
			divider <= #Tp {`SPI_DIVIDER_LEN{1'b0}};
		else if (load_div && !tip)
			divider <= #Tp data_in[`SPI_DIVIDER_LEN-1:0];
	end
  
	// Ctrl register
	always @(posedge clk or posedge rst)
		begin
			if (rst)
			begin
				ctrl <= #Tp {`SPI_CTRL_BIT_NB{1'b0}};
				$display ("Reseting CTRL Register");
			end
			else if(load_ctrl && !tip)
			begin
				ctrl[`SPI_CTRL_BIT_NB-1:0] 	<= #Tp data_in[`SPI_CTRL_BIT_NB-1:0];
				$display ("Capturing data to CTRL Register");
				end
			else
			begin
				if(tip && last_bitTX && pos_edge)
					begin
					ctrl[`SPI_CTRL_WRITE] 		<= #Tp 1'b0;
					$display ("clearing WRITE on CTRL Register");
					end		
				if(tip && last_bitRX && pos_edge)
					begin
					ctrl[`SPI_CTRL_SAMPLE] 		<= #Tp 1'b0;
					$display ("clearing SAMPLE on CTRL Register");
					end		
				if(tip && last_bit && pos_edge)
				begin
					ctrl[`SPI_CTRL_GO] 			<= #Tp 1'b0;
					$display ("clearing GO on CTRL Register");
				end	
				if(tx_capture) 
				begin
					ctrl[`SPI_CTRL_TXC] 		<= #Tp 1'b0; 
					$display ("clearing TXC on CTRL Register");
				end
			end
		end

	assign rx_negedge 	= ctrl[`SPI_CTRL_RX_NEGEDGE];
	assign tx_negedge 	= ctrl[`SPI_CTRL_TX_NEGEDGE];
	assign go         	= ctrl[`SPI_CTRL_GO];
	assign char_len   	= ctrl[`SPI_CTRL_CHAR_LEN];
	assign lsb        	= ctrl[`SPI_CTRL_LSB];
  	assign Sample		= ctrl[`SPI_CTRL_SAMPLE];
	assign tx_capture	= ctrl[`SPI_CTRL_TXC];
	assign Write		= ctrl[`SPI_CTRL_WRITE];
	
	assign goTX			= go && Write;
	assign tip			= tipRX || tipTX;
	assign last_bit		= Sample ? last_bitRX : last_bitTX; 
	
	always@(posedge clk or posedge rst)
	begin
		if(rst)
			Qcount <= #Tp 'b0;
		else if (!stop &&Sample && go)
			Qcount <= #Tp Qcount + 1;
		else if (tip && last_bitRX && pos_edge)
			Qcount <= #Tp 'b0;
	end
	
	always@(posedge clk or posedge rst)
	begin
		if(rst)
			stop <= #Tp 0;
		else if (Qcount == MAXCOUNT)
			stop <= #Tp 1;		
		else if (tip && last_bitRX && pos_edge)
			stop <= #Tp 0;
	end

	always@(posedge clk or posedge rst)
	begin
		if(rst)
			conv <= #Tp 0;		
		else if (Qcount == CONVCOUNT)
			conv <= #Tp 1;
		else if (Qcount == MAXCOUNT)
			conv <= #Tp 0;
	end


	// RX go signal generation
	assign goRX = Q[1] && Sample;
	always@(posedge clk or posedge rst)
	begin
		if(rst)
			Q<= #Tp 'b0;
		else if(pos_edge && Sample)
			Q<= #Tp {Q[0], go};
		else if(!Sample)
		begin
			Q<= #Tp 'b0;
		end	
	end

	assign amp= !(!ampDAC && go);
	assign dac=	!(ampDAC && go);
	//assign cs signals
	always @(posedge clk or posedge rst)
	begin
		if (rst)
			ss <= #Tp 2'b11;
		else if(goTX && !tip && Write)
			ss <= #Tp {amp, dac}; //cs order -> amp, dac
		else if(last_bitTX )
			ss <= #Tp 2'b11;
		else
			ss <= #Tp ss;
	end

	// data out signal generation
	assign chanA = adcData[30:17];
	assign chanB = adcData[14:1];
	always@(posedge clk or posedge rst)
	begin
		if(rst)
			adcValid<= #Tp 0;
		else if(!tip)
			adcValid<= #Tp 0;
		else if(last_bitRX && pos_edge)
			adcValid<= #Tp 1;
	end

/*	always@(posedge clk or posedge rst)
	begin
		if(rst)
			adcValid<= #Tp 0;
		else if(tip && last_bitRX && pos_edge)
			adcValid<= #Tp 0;
		else if(last_bitRX && Sample)
			adcValid<= #Tp 1;
	end*/

	assign ss_pad_o = ss;
	spi_clgen clgen (.clk_in(clk), .rst(rst), .go(go), .enable(go&&(Sample||Write)), .last_clk(last_bit),
                   .divider(divider), .clk_out(sclk_pad_o), .pos_edge(pos_edge), 
                   .neg_edge(neg_edge));

	spi_shift_out tx_shift (.clk(clk), .rst(rst), .len(char_len[`SPI_CHAR_LEN_BITS-1:0]),
                   .lsb(lsb), .go(goTX), .capture(tx_capture), .pos_edge(pos_edge), .neg_edge(neg_edge), 
                   .tx_negedge(tx_negedge), .tip(tipTX), .last(last_bitTX), .p_in(data_in),
				   .s_out(mosi_pad_o));
				
	spi_shift_in rx_shifter (.clk(clk), .rst(rst), .go(goRX),
                  .pos_edge(pos_edge), .neg_edge(neg_edge), .rx_negedge(rx_negedge),
                 .tip(tipRX), .last(last_bitRX), .p_out(adcData), .s_clk(sclk_pad_o), .s_in(miso_pad_i));			
				
endmodule
/*
module spi_shift_out (clk, rst, byte_sel, len, lsb, go,
                  pos_edge, neg_edge, tx_negedge,
                  tip, last, 
                  p_in, s_clk, s_out);

module spi_shift_in (.clk(), .rst(), .lsb(), .go,
                  pos_edge(), .neg_edge(), .rx_negedge(), .tx_negedge,
                  tip(), .last(), .p_out(), .s_clk(), .s_in());
*/
