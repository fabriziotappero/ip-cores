//////////////////////////////////////////////////////////////////////////////////////////
//Design Engineer:	Ravi Gupta							//
//Company Name	 :	Toomuch Semiconductor	
//Email		 :	ravi1.gupta@toomuchsemi.com					//
//											//
//											//	
//Purpose	 :	This module will simply interconnect controller interface 	//																			    //					
//			controller_interface with ms_core.				//
//											//		
//											//
//Date		 :	11-12-07							//
//											//
//											//
//											//
//											//
//											//
//											//								
//											//
//////////////////////////////////////////////////////////////////////////////////////////
/*// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"*/


module block(scl_oe,scl_in,scl_o,sda_oe,sda_in,sda_o,wb_add_i,wb_data_i,wb_data_o,wb_we_i,wb_stb_i,wb_cyc_i,irq,trans_comp,wb_clk_i,wb_rst_i,wb_ack_o);

//inout scl;				//Bi-directional lines to follow i2c protocol for data transfer.
input sda_in;				//sda input
output sda_oe;				//control line for bidirectional buffer
output sda_o;				//input line for bi_firectional buffer
input scl_in;
output	scl_o;
output scl_oe;
input [7:0]wb_data_i;			//Bi-direction buses for transfering data to/from processor.
input [7:0]wb_add_i;			//Transfer the addresses of intenal registers.
input wb_we_i;				//signal from processor to indicate whether its a read or write cycle.
input wb_stb_i;				//when asserted indicates address is valid.
input wb_cyc_i;				//when asserted indicates data is valid.
output irq;				//interupt signal to processor.
input wb_clk_i;				//system clock.
input wb_rst_i;				//asynchrnous reset active high.
inout trans_comp;			//temprory signal for testing the core 
output [7:0]wb_data_o;
output wb_ack_o;

//declaratiion of internal signals
//////////////////////////////////

  //   control register
  wire [7:0] slave_add;     		  	//   I2C address
  wire arb_lost;                		//   indicates that arbitration for the i2c bus is lost
  wire bus_busy;                		//   indicates the i2c bus is busy
  wire [7:0] i2c_up;        			//   i2c data register
  wire [7:0] data;   				//   uC data register
  wire core_en;            			//   i2c enable - used as i2c reset
  wire inter_en;           			//   interrupt enable
  wire inter;           			//   interrupt pending
  wire mode;               			//   i2c master/slave select
  wire master_rw;         			//   master read/write
  wire rep_start;          			//   generate a repeated start
  wire ack_rec;           			//   value of received acknowledge
  wire slave_rw;           			//   slave read/write
  wire ack;               			//   value of acknowledge to be transmitted
  wire byte_trans;				//   indicates that one byte of data is being transferred
  wire slave_addressed;				//   address of core matches with address transferred
  wire time_out;					//   max low period for SCL has excedded
  wire [7:0]time_out_reg;			//   programmable max time for SCL low period
  wire [7:0]prescale;
  wire inter_rst;
  wire [7:0]wb_data_o;
  wire halt;
  wire data_en;
  wire time_rst;	
  reg wb_ack_o;			
  wire rst; 

assign trans_comp = byte_trans;

always@(posedge wb_clk_i)
begin
	wb_ack_o <= #1 wb_stb_i & wb_cyc_i & ~wb_ack_o;
end

//port map for i2c controller 
////////////////////////////

core i2c_core

	(
		.clk(wb_clk_i),
		.rst(core_en),
		.sda_oe(sda_oe),
		.sda_in(sda_in),
		.sda_o(sda_o),
		.scl_oe(scl_oe),
		.scl_o(scl_o),
		.scl_in(scl_in),
		.ack(ack),
		.mode(mode),
		.rep_start(rep_start),
		.master_rw(master_rw),
		.data_in(data[7:0]),
		.slave_add(slave_add[7:0]),
		.bus_busy(bus_busy),
		.byte_trans(byte_trans),
		.slave_addressed(slave_addressed),
		.arb_lost(arb_lost),
		.slave_rw(slave_rw),
		.time_out(time_out),
		.inter(inter),
		.ack_rec(ack_rec),
		.i2c_up(i2c_up[7:0]),
		.time_out_reg(time_out_reg[7:0]),
		.prescale_reg(prescale[7:0]),
		.inter_en(inter_en),
		.inter_rst(inter_rst),
		.data_en(data_en),
		.halt_rst(halt),
		.h_rst(wb_rst_i),
		.time_rst(time_rst));


//port map for controller interface
///////////////////////////////////	

processor_interface processor_interface

	(
		.clk(wb_clk_i),
		.rst(wb_rst_i),
		.add_bus(wb_add_i[7:0]),
		.data_in(wb_data_i[7:0]),
		.as(wb_stb_i),
		.ds(wb_cyc_i),
		.rw(wb_we_i),
		.bus_busy(bus_busy),
		.byte_trans(byte_trans),
		.slave_addressed(slave_addressed),
		.arb_lost(arb_lost),
		.slave_rw(slave_rw),
		.inter(inter),
		.ack_rec(ack_rec),
		.core_en(core_en),
		.inter_en(inter_en),
		.mode(mode),
		.master_rw(master_rw),
		.ack(ack),
		.rep_start(rep_start),
		.data(data[7:0]),
		.i2c_data(i2c_up[7:0]),
		.slave_add(slave_add),
		.time_out_reg(time_out_reg[7:0]),
		.prescale(prescale[7:0]),
		.irq(irq),
		.time_out(time_out),
		.inter_rst(inter_rst),
		.halt(halt),
		.data_en(data_en),
		.time_rst(time_rst),
		.data_out(wb_data_o));

//always@(scl or sda)
//$display($time,"scl=%b\tsda=%b\t\n",scl,sda);


endmodule
	
	
	

