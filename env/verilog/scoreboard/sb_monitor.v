// combination refmodel/monitor for scoreboard

module sb_monitor
  #(parameter width=8,
    parameter items=64,
    parameter use_txid=0,
    parameter use_mask=0,
    parameter txid_sz=2,
    parameter asz=$clog2(items))
  (input      clk,
   input      reset,

   input      c_srdy,
   input      c_drdy,
   input      c_req_type, // 0=read, 1=write
   input [txid_sz-1:0] c_txid,
   input [width-1:0] c_mask,
   input [width-1:0] c_data,
   input [asz-1:0]   c_itemid,

   input     p_srdy,
   output reg   p_drdy,
   input  [txid_sz-1:0] p_txid,
   input [width-1:0]   p_data
   );

  localparam pat_dep = 8;

  reg [width-1:0]      sbmem [0:items-1];
  reg [7:0] 	       drdy_pat;
  integer 	       dpp;
  reg 		       nxt_p_drdy;

  reg [width-1:0]      outbuf[0:items-1];

  initial
    begin
      drdy_pat = {pat_dep{1'b1}};
      dpp = 0;
    end

  always @*
    begin
      nxt_p_drdy = p_drdy;

      if (p_srdy & p_drdy)
	begin
	  if (drdy_pat[dpp])
	    begin
	      nxt_p_drdy = 1;
	    end
	  else
	    nxt_p_drdy = 0;
	end
      else if (!p_drdy)
	begin
	  if (drdy_pat[dpp])
	    begin
	      nxt_p_drdy = 1;
	    end
	  else
	    nxt_p_drdy = 0;
	end
    end // always @ *

  always @(posedge clk)
    begin
      if ((c_srdy & p_drdy) | !p_drdy)
	dpp = (dpp + 1) % pat_dep;

      p_drdy <= #1 nxt_p_drdy;
    end

  always @(posedge clk)
    begin
      if (c_srdy & c_drdy & (c_req_type == 1))
        begin
          sbmem[c_itemid] <= #18 (sbmem[c_itemid] & ~c_mask) | (c_data & c_mask);
        end
      else if (c_srdy & c_drdy & (c_req_type == 0))
	begin
	  outbuf[c_itemid] = sbmem[c_itemid];
	end

      if (p_srdy & p_drdy)
        begin
          if (p_data != outbuf[p_txid])
            begin
              $display ("%t: ERROR: sb returned %x, expected %x",
                        $time, p_data, outbuf[p_txid]);
            end
        end
    end
  
  initial
    begin
      p_drdy = 1;
    end

endmodule // sb_monitor
