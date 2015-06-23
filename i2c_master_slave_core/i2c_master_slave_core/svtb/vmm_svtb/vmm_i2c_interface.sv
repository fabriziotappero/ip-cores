//////////////////////////////////////////////////////////////////////////////////////////
//																						//
//	Verification Engineer:	Atish Jaiswal												//
//	Company Name		 :	TooMuch Semiconductor Solutions Pvt Ltd.					//
//																						//
//  Description of the Source File:														//
//	This source code is used to declare interface.										//
//																						//
//																						//
//////////////////////////////////////////////////////////////////////////////////////////


interface i2c_pin_if();

reg clk;					// System_clk						
logic rst;					// Reset
logic [7:0] addr_in;		// W/B Address Input lines
logic [7:0] data_in;		// W/B Data Input lines
wire  [7:0] data_out;		// W/B Data Output lines
logic wb_stb_i;				// W/B Strobe 
logic wb_cyc_i;				// W/B Cycle valid
logic we;					// W/B Write Enable
wire trans_comp;			// Transacation Complete
logic ack_o;				// W/B Acknowledgment
wire irq;					// Interrupt from DUT
logic scl_o;				// SCL O/P
reg scl_oe;					// SCL O/P Enable
wire scl;					// SCL I/P
logic sda_o;				// SDL O/P
logic sda_oe;				// SDA O/P Enable
wire sda;					// SDA I/P


modport dut_mp ( 
    input   clk,
	input   rst,
	input   addr_in,
	input   data_in,
	output  data_out,
	input   wb_stb_i,
	input   wb_cyc_i,
	input   we,
	output  ack_o,
	output  trans_comp,
	output  irq,
	output  scl ,
	output  scl_o,
	output  scl_oe,
	output  sda_o,
	output  sda_oe,
	output  sda  
);


modport driver_mp ( 
    input  clk,
	input  rst,
	input  addr_in,
	input  data_in,
	output data_out,
	input  wb_stb_i,
	input  wb_cyc_i,
	input  we,
	output trans_comp,
	output  ack_o,
	output irq,
	output  scl ,
	output  scl_o,
	output  scl_oe,
	output  sda_o,
	output  sda_oe,
	output  sda 
);


modport monitor_mp ( 
    input  clk,
	input  rst,
	input  addr_in,
	input  data_in,
	input  data_out,
	input  wb_stb_i,
	input  wb_cyc_i,
	input  we,
	input  ack_o,
	input  trans_comp,
	input  irq,
	input  scl ,
	input  sda ,
	input scl_o,
	input scl_oe, 
	input sda_o,
	input sda_oe 
);

      
modport slave_mp ( 
	output scl   ,
    output sda   , 
	output scl_o , 
	output scl_oe, 
	output sda_o , 
	output sda_oe 
);

endinterface  : i2c_pin_if

