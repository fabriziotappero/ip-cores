//----------------------------------------------------------------------
// Srdy/Drdy input/output block
//
// Halts timing on all signals.  Efficiency of block is only 0.5, so
// it can produce data at most on every other cycle.
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

module sd_iohalf
  #(parameter width = 8)
  (
   input              clk,
   input              reset,
   input              c_srdy,
   output             c_drdy,
   input [width-1:0]  c_data,

   output reg         p_srdy,
   input              p_drdy,
   output reg [width-1:0] p_data
   );

  reg 	  load;   // true when data will be loaded into p_data
  reg 	  nxt_p_srdy;

  always @*
    begin
      load  = c_srdy & !p_srdy;
      nxt_p_srdy = (p_srdy & !p_drdy) | (!p_srdy & c_srdy);
    end
  assign c_drdy = ~p_srdy;
  
  always @(`SDLIB_CLOCKING)
    begin
      if (reset)
	begin
	  p_srdy <= `SDLIB_DELAY 0;
	end
      else
	begin
	  p_srdy <= `SDLIB_DELAY nxt_p_srdy;
	end // else: !if(reset)
    end // always @ (posedge clk)

  always @(posedge clk)
    if (load)
      p_data <= `SDLIB_DELAY c_data;

endmodule // it_output
