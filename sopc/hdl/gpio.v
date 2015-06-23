//                              -*- Mode: Verilog -*-
// Filename        : gpio.v
// Description     : a bitwise gpio
// Author          : Thomas Chou

// this is a bitwise gpio to be used with i2c,spi,sdio,1 wire etc.
// it is unlike Altera's pio, each access is bit by bit.
// it is designed to work with generic gpio interface of Linux
// so that it will run faster and use less LEs
// you may turn on FAST_OUTPUT_REGISTER for the port pins to reduce LEs usage further
// interrupt is not supported
// port pin[i] can be addressed with base+(i*4)
// writedata[1] : output enable
// writedata[0] : output data
// readdata[0] : input data from pin
// paramters
// GPIO_WIDTH for total number of io pins (bidir + input_only), 
// GPIO_BIDIR for number of bidir pins.
// GPIO_ADDR the address width
// WIDTH <= 2^ADDR

module gpio (
             /*AUTOARG*/
   // Outputs
   readdata,
   // Inouts
   bidir_port,
   // Inputs
   input_port, address, clk, reset_n, write_n, writedata
   );

   parameter BIDIR_WIDTH = 8;
   parameter INPUT_WIDTH = 4;
   parameter ADDR_WIDTH = 3;
   
   inout [  BIDIR_WIDTH - 1: 0] bidir_port;
   input [  INPUT_WIDTH - 1: 0 ] input_port;   
   output [  1: 0] 	readdata;
   input [  ADDR_WIDTH - 1: 0] 	address;
   input 		clk;
   input 		reset_n;
   input 		write_n;
   input [  1: 0] 	writedata;

   wire [ (BIDIR_WIDTH + INPUT_WIDTH) - 1: 0]      data_in; 
   reg [  BIDIR_WIDTH - 1: 0] 	bidir_port;
   reg [  1: 0] 	readdata;
   reg [  BIDIR_WIDTH - 1: 0] 	data_mode;
   reg [  BIDIR_WIDTH - 1: 0] 	data_outz;
   reg [  BIDIR_WIDTH - 1: 0] 	data_mode_v;
   reg [  BIDIR_WIDTH - 1: 0] 	data_outz_v;
   integer N;

   assign  data_in = { input_port,bidir_port };
   
   always @(data_mode or data_outz)
     for (N = 0; N <= (BIDIR_WIDTH - 1) ; N = N+1)
       bidir_port[N] = data_mode[N]? ~data_outz[N] : 1'bz;

   always @(/*AS*/address or data_in)
     readdata = { 1'b0, data_in[address] };
   
   always @(/*AS*/BIDIR_WIDTH or address or data_outz or write_n
	    or writedata)
     for (N = 0; N <= (BIDIR_WIDTH - 1) ; N = N+1)
       data_outz_v[N] = (~write_n & (address == N)) ? ~writedata[0] : data_outz[N];

   always @(/*AS*/BIDIR_WIDTH or address or data_mode or write_n
	    or writedata)
     for (N = 0; N <= (BIDIR_WIDTH - 1) ; N = N+1)
       data_mode_v[N] = (~write_n & (address == N)) ? writedata[1] : data_mode[N];

   always @(posedge clk or negedge reset_n)
     begin
	if (reset_n == 0)
	  begin
             data_outz <= 0;
	     data_mode <=0;
	  end       
	else
	  begin
	     data_outz <= data_outz_v;
	     data_mode <= data_mode_v;	   
	  end	   
     end // always @ (posedge clk or negedge reset_n)

endmodule
   