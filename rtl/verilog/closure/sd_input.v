//----------------------------------------------------------------------
// Srdy/Drdy input block
//
// Halts timing on c_drdy.  Intended to be used on the input side of
// a design block.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

// Clocking statement for synchronous blocks.  Default is for
// posedge clocking and positive async reset
`ifndef SDLIB_CLOCKING 
 `define SDLIB_CLOCKING posedge clk or posedge reset
`endif

// delay unit for nonblocking assigns, default is to #1
`ifndef SDLIB_DELAY 
 `define SDLIB_DELAY #1 
`endif

module sd_input
  #(parameter width = 8)
  (
   input              clk,
   input              reset,
   input              c_srdy,
   output reg         c_drdy,
   input [width-1:0]  c_data,

   output reg         ip_srdy,
   input              ip_drdy,
   output reg [width-1:0] ip_data
   );

  reg 	  load;
  reg 	  drain;
  reg 	  occupied, nxt_occupied;
  reg [width-1:0] hold, nxt_hold;
  reg 		  nxt_c_drdy;

  
  always @*
    begin
      nxt_hold = hold;
      nxt_occupied = occupied;

      drain = occupied & ip_drdy;
      load = c_srdy & c_drdy & (!ip_drdy | drain);
      if (occupied)
	ip_data = hold;
      else
	ip_data = c_data;

      ip_srdy = (c_srdy & c_drdy) | occupied;

      if (load)
	begin
	  nxt_hold = c_data;
	  nxt_occupied =  1;
	end
      else if (drain)
	nxt_occupied = 0;

      nxt_c_drdy = (!occupied & !load) | (drain & !load);
    end

  always @(`SDLIB_CLOCKING)
    begin
      if (reset)
	begin
	  hold     <= `SDLIB_DELAY 0;
	  occupied <= `SDLIB_DELAY 0;
	  c_drdy   <= `SDLIB_DELAY 0;
	end
      else
	begin
	  hold     <= `SDLIB_DELAY nxt_hold;
	  occupied <= `SDLIB_DELAY nxt_occupied;
	  c_drdy   <= `SDLIB_DELAY nxt_c_drdy;
	end // else: !if(reset)
    end // always @ (posedge clk)  
 
endmodule