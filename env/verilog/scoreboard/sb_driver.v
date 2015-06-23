//----------------------------------------------------------------------
// Srdy/Drdy sequence generator
//
// Simplistic traffic generator for srdy/drdy blocks.  Generates an
// incrementing data sequence.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

// delay unit for nonblocking assigns, default is to #1
`ifndef SDLIB_DELAY 
 `define SDLIB_DELAY #1 
`endif

module sb_driver
  #(parameter width=8,
    parameter items=64,
    parameter use_txid=0,
    parameter use_mask=0,
    parameter txid_sz=2,
    parameter asz=$clog2(items))
  (input clk,
   input reset,
   output reg     p_srdy,
   input          p_drdy,
   output reg      p_req_type, // 0=read, 1=write
   output reg [txid_sz-1:0] p_txid,
   output reg [width-1:0] p_mask,
   output reg [asz-1:0]   p_itemid,
   output reg [width-1:0] p_data);

/* -----\/----- EXCLUDED -----\/-----
  parameter pat_dep = 8;

  reg [pat_dep-1:0] 	  srdy_pat;
  integer 		  spp, startup;
  integer 		  rep_count;

  initial
    begin
      srdy_pat = {pat_dep{1'b1}};
      spp = 0;
      startup = 0;
      rep_count = 0;
    end

  always @*
    begin
      nxt_p_data = p_data;
      nxt_p_srdy = p_srdy;
      nxt_p_req_type = p_req_type;
      
      if (p_srdy & p_drdy)
	begin

	  if (srdy_pat[spp] && (rep_count > 1))
	    begin
	      nxt_p_data = p_data + 1;
	      nxt_p_srdy = 1;
	    end
	  else
	    nxt_p_srdy = 0;
	end // if (p_srdy & p_drdy)
      else if (!p_srdy && (rep_count != 0))
	begin
	  if (srdy_pat[spp])
	    begin
	      nxt_p_data = p_data + 1;
	      nxt_p_srdy = 1;
	    end
	  else
	    nxt_p_srdy = 0;
	end
    end // always @ *

  always @(posedge clk)
    begin
      if ((p_srdy & p_drdy) | !p_srdy)
	spp = (spp + 1) % pat_dep;

      if (p_srdy & p_drdy)
	begin
	  if (rep_count != -1)
	    rep_count = rep_count - 1;
	end
    end

  always @(posedge clk)
    begin
      if (reset)
	begin
	  p_srdy <= `SDLIB_DELAY 0;
	  p_data <= `SDLIB_DELAY 0;
	end
      else
	begin
	  p_srdy <= `SDLIB_DELAY nxt_p_srdy;
	  p_data <= `SDLIB_DELAY nxt_p_data;
	end
    end // always @ (posedge clk)
 -----/\----- EXCLUDED -----/\----- */

  initial
    begin
      p_srdy <= #1 0;
      p_req_type <= #1 0;
      p_txid <= #1 0;
      p_mask <= #1 0;
      p_itemid <= #1 0;
      p_data <= #1 0;
    end
      

  task send;
    input req_type;
    //input [txid_sz-1:0] txid;
    input [width-1:0]   mask;
    input [width-1:0]   data;
    input [asz-1:0]     itemid;
    begin
      p_srdy <= #1 1;
   //input          p_drdy,
      p_req_type <= #1 req_type;
      p_txid <= #1 itemid;
      p_mask <= #1 mask;
      p_itemid <= #1 itemid;
      p_data <= #1 data;
      @(negedge clk);
      if (p_drdy)
        begin
          @(posedge clk);
          p_srdy <= #1 0;
        end
      else 
        begin
          while (!p_drdy)
            @(posedge clk);
          p_srdy <= #1 0;
        end
    end
  endtask

endmodule // sb_driver
