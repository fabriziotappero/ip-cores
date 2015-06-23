//----------------------------------------------------------------------
// Srdy/Drdy sequence checker
//
// Simplistic traffic checker for srdy/drdy blocks.  Checks for an
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

module sd_seq_check
  #(parameter width=8)
  (input clk,
   input reset,
   input          c_srdy,
   output reg     c_drdy,
   input [width-1:0] c_data);

  parameter pat_dep = 8;

  reg [width-1:0]    last_seq;
  reg 		     first;
  reg [pat_dep-1:0]  drdy_pat;
  integer 	     dpp;
  reg 		     nxt_c_drdy;
  integer            err_cnt;

  initial
    begin
      drdy_pat = {pat_dep{1'b1}};
      dpp = 0;
    end

  initial
    begin
      first = 1;
      c_drdy = 0;
      err_cnt = 0;
    end

  always @*
    begin
      nxt_c_drdy = c_drdy;

      if (c_srdy & c_drdy)
	begin
	  if (drdy_pat[dpp])
	    begin
	      nxt_c_drdy = 1;
	    end
	  else
	    nxt_c_drdy = 0;
	end
      else if (!c_drdy)
	begin
	  if (drdy_pat[dpp])
	    begin
	      nxt_c_drdy = 1;
	    end
	  else
	    nxt_c_drdy = 0;
	end
    end
  always @(posedge clk)
    begin
      if ((c_srdy & c_drdy) | !c_drdy)
	dpp = (dpp + 1) % pat_dep;
    end

  always @(posedge clk)
    begin
      if (reset)
	begin
	  c_drdy <= `SDLIB_DELAY 0;
          err_cnt  = 0;
          drdy_pat = {pat_dep{1'b1}};
          dpp = 0;
          first = 1;
          last_seq = 0;
	end
      else
	begin
	  c_drdy <= `SDLIB_DELAY nxt_c_drdy;
	  if (c_srdy & c_drdy)
	    begin
	      if (!first && (c_data !== (last_seq + 1)))
                begin
		  $display ("%t: ERROR   : %m: Sequence miscompare rcv=%x exp=%x",
			    $time, c_data, last_seq+1);
                  err_cnt = err_cnt + 1;
                end
	      else
		begin
		  last_seq = c_data;
		  first = 0;
		end
	    end // if (c_srdy & c_drdy)
	end // else: !if(reset)
    end

endmodule // sd_seq_check
