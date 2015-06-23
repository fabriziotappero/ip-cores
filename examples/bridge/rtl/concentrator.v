module concentrator
  (input         clk,
   input         reset,
   input [7:0]	 c_data,
   input [1:0]   c_code,
   input		 c_srdy,			// To sdin of sd_input.v
   input		 p_drdy,			// To sdout of sd_output.v
   output  		 c_drdy,			// From sdin of sd_input.v
   output reg [`PFW_SZ-1:0] p_data,			// From sdout of sd_output.v
   output reg		 p_srdy,
   output reg            p_commit,
   output reg            p_abort
   // End of automatics
   );

  wire [7:0]	ip_data;		// From sdin of sd_input.v
  wire [1:0] 	ip_code;
  reg			ip_drdy;
  wire			ip_srdy;		// From sdin of sd_input.v

  reg [`PFW_SZ-1:0] 	nxt_p_data;
  reg 			nxt_p_srdy;
  reg [2:0] 		count, nxt_count;
  reg 			nxt_p_abort, nxt_p_commit;
  wire [1:0]            pkt_code = p_data[`PRW_PCC];

  sd_input #(8+2) sdin
    (
     // Outputs
     .c_drdy				(c_drdy),
     .ip_srdy				(ip_srdy),
     .ip_data				({ip_code,ip_data}),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .c_srdy				(c_srdy),
     .c_data				({c_code,c_data}),
     .ip_drdy				(ip_drdy));

  always @*
    begin
      nxt_p_data = p_data;
      nxt_p_srdy = p_srdy;
      nxt_p_data = p_data;
      nxt_count = count;
      nxt_p_commit = p_commit;
      nxt_p_abort  = 0;

      if (p_srdy)
	begin
	  if (p_drdy)
	    begin
	      nxt_p_srdy = 0;
	      nxt_p_commit = 0;
	      ip_drdy = 1;
	      nxt_p_data[`PRW_PCC] = `PCC_DATA;
	      nxt_count = 0;

	      if (ip_srdy)
		begin
		  nxt_count = 1;
		  if (ip_code != `PCC_DATA)
		    nxt_p_data[`PRW_PCC] = ip_code;
		  nxt_p_data[63:56] = ip_data;
		end
	    end
	end
      else if (ip_srdy)
	begin
	  ip_drdy = 1;
	  if (ip_code != `PCC_DATA)
	    nxt_p_data[`PRW_PCC] = ip_code;

	  nxt_count = count + 1;
	  case (count)
	    0 : nxt_p_data[63:56] = ip_data;
	    1 : nxt_p_data[55:48] = ip_data;
	    2 : nxt_p_data[47:40] = ip_data;
	    3 : nxt_p_data[39:32] = ip_data;
	    4 : nxt_p_data[31:24] = ip_data;
	    5 : nxt_p_data[23:16] = ip_data;
	    6 : nxt_p_data[15: 8] = ip_data;
	    7 : nxt_p_data[ 7: 0] = ip_data;
	  endcase // case (count)
	  if ((count == 7) | (ip_code == `PCC_BADEOP) | (ip_code == `PCC_EOP))
	    begin
	      if (ip_code == `PCC_EOP)
		begin
		  nxt_p_commit = 1;
		  nxt_p_srdy   = 1;
                  nxt_p_data[`PRW_VALID] = count + 1;
		end
	      else if ((ip_code == `PCC_BADEOP) || (pkt_code == `PCC_BADEOP))
		begin
		  nxt_p_abort = 1;
		end
	      else
                begin
		  nxt_p_srdy = 1;
                  nxt_p_data[`PRW_VALID] = 0;
                end
	    end
	end
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
	begin
	  /*AUTORESET*/
	  // Beginning of autoreset for uninitialized flops
	  count <= 3'h0;
	  p_abort <= 1'h0;
	  p_commit <= 1'h0;
	  p_data <= {(1+(`PFW_SZ-1)){1'b0}};
	  p_srdy <= 1'h0;
	  // End of automatics
	end
      else
	begin
	  p_commit <= #1 nxt_p_commit;
	  p_abort  <= #1 nxt_p_abort;
	  p_srdy   <= #1 nxt_p_srdy;
	  p_data   <= #1 nxt_p_data;
	  count    <= #1 nxt_count;
	end // else: !if(reset)
    end
  
endmodule // template_1i1o
