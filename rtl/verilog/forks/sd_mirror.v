//----------------------------------------------------------------------
//  Srdy/drdy mirrored fork
//
//  Used when a single item of data needs to be used by more than one
//  block, and all blocks may finish at different times.  This creates
//  separate srdy/drdy signals for each block, and holds drdy to the
//  sender until all blocks have individually asserted drdy.
//
//  The input c_dst_vld allows the data to be selectively sent to some
//  or all of the downstream endpoints.  At least one bit in c_dst_vld
//  must be asserted with c_srdy.  If this functionality is not desired
//  the input should be tied to 0.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
//  Author: Guy Hutchison
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

module sd_mirror
  #(parameter mirror=2,
    parameter width=128)
  (input        clk,
   input        reset,

   input              c_srdy,
   //output reg         c_drdy,
   output             c_drdy,
   input [width-1:0]  c_data,
   input [mirror-1:0] c_dst_vld,

   output reg [mirror-1:0] p_srdy,
   input [mirror-1:0]      p_drdy,
   output reg [width-1:0]  p_data
   );

  reg 			 state, nxt_state;
  reg [mirror-1:0] 	 nxt_p_srdy;
  reg                    load;
 
  always @(posedge clk)
    if (load)
      p_data <= `SDLIB_DELAY c_data;

  assign c_drdy = (p_srdy == 0);

  always @*
    begin
      nxt_p_srdy = p_srdy;
      load         = 0;
      
      if (p_srdy == {mirror{1'b0}})
          begin
	    if (c_srdy)
	      begin
                if (c_dst_vld == {mirror{1'b0}})
                  nxt_p_srdy = {mirror{1'b1}};
                else
	          nxt_p_srdy = c_dst_vld;
                load         = 1;
	      end
          end
      else
	begin
	  nxt_p_srdy = p_srdy & ~p_drdy;
	end
    end

  always @(`SDLIB_CLOCKING)
    begin
      if (reset)
	begin
	  p_srdy   <= `SDLIB_DELAY {mirror{1'b0}};
	  state    <= `SDLIB_DELAY 1'b0;
	end
      else
	begin
	  p_srdy   <= `SDLIB_DELAY nxt_p_srdy;
	  state    <= `SDLIB_DELAY nxt_state;
	end
    end

endmodule // sd_mirror
