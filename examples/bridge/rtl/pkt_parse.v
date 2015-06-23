// packet parser
//
// Takes input packet on rxg interface and copies packet to pdo
// interface, without changing packet data.  If packet is too
// short to be parsed, converts packet to an error code.
//
// If packet parses correctly and is not an error packet, sends
// a parse result to the FIB for lookup.  Otherwise aborts the
// packet so it is flushed from the packet FIFO.
module pkt_parse
  #(parameter port_num=0)
  (input          clk,
   input          reset,

   input          rxg_srdy,
   output         rxg_drdy,
   input  [1:0]   rxg_code,
   input [7:0]    rxg_data,

   output reg     p2f_srdy,
   input          p2f_drdy,
   output reg [`PAR_DATA_SZ-1:0] p2f_data,

   output         pdo_srdy,
   input          pdo_drdy,
   output [1:0]   pdo_code,
   output [7:0]   pdo_data
   );

  wire 		  lp_srdy;
  reg 		  lp_drdy;
  wire [1:0] 	  lp_code;
  wire [7:0] 	  lp_data;
  reg 		  lc_srdy;
  wire 		  lc_drdy;
  reg [1:0] 	  lc_code;

  reg [3:0] 	  count, nxt_count;
  reg 		  nxt_p2f_srdy;
  reg [`PAR_DATA_SZ-1:0] nxt_p2f_data;

  sd_input #(8+2) rxg_in
    (
     // Outputs
     .c_drdy				(rxg_drdy),
     .ip_srdy				(lp_srdy),
     .ip_data				({lp_code,lp_data}),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .c_srdy				(rxg_srdy),
     .c_data				({rxg_code,rxg_data}),
     .ip_drdy				(lp_drdy));

  always @*
    begin
      nxt_p2f_srdy = p2f_srdy;
      nxt_p2f_data = p2f_data;
      nxt_count = count;
      lc_code = lp_code;

      if (p2f_srdy)
	begin
	  lp_drdy = 0;
	  lc_srdy = 0;
	  if (p2f_drdy)
	    nxt_p2f_srdy = 0;
	end
      else if (lp_srdy & lc_drdy)
	begin
	  lp_drdy = 1;
	  lc_srdy = 1;
	
	  case (count)
	    0, 1, 2, 3, 4, 5 : 
	      begin
		if (count == 0)
                  begin
		    nxt_p2f_data = 0;
                    nxt_p2f_data[`PAR_SRCPORT] = port_num;
                  end

		if ((lp_code == `PCC_EOP) || (lp_code == `PCC_BADEOP))
		  begin
		    lc_code = `PCC_BADEOP;
		    nxt_count = 0;
		  end
		else
		  begin
		    nxt_p2f_data[`PAR_MACDA] = { p2f_data[`PAR_MACDA] << 8, lp_data };
		    nxt_count = count + 1;
		  end
	      end // case: 0, 1, 2, 3, 4, 5

	    6, 7, 8, 9, 10, 11 : 
	      begin
		if ((lp_code == `PCC_EOP) || (lp_code == `PCC_BADEOP))
		  begin
		    lc_code = `PCC_BADEOP;
		    nxt_count = 0;
		  end
		else
		  begin
		    nxt_p2f_data[`PAR_MACSA] = { p2f_data[`PAR_MACSA] << 8, lp_data };
		    nxt_count = count + 1;
		  end
	      end // case: 6, 7, 8, 9, 10, 11

	    // done with parsing, wait for packet EOP
	    12 :
	      begin
		if (lp_code == `PCC_EOP)
		  begin
		    nxt_p2f_srdy = 1;
		    nxt_count = 0;
		  end
		else if (lp_code == `PCC_BADEOP)
		  nxt_count = 0;
	      end

	    default : nxt_count = 0;
	  endcase // case (count)
	end
      else
	begin
	  lp_drdy = 0;
	  lc_srdy = 0;
	end // else: !if(lp_srdy & lc_drdy)
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
	begin
	  /*AUTORESET*/
	  // Beginning of autoreset for uninitialized flops
	  count <= 4'h0;
	  p2f_data <= {(1+(`PAR_DATA_SZ-1)){1'b0}};
	  p2f_srdy <= 1'h0;
	  // End of automatics
	end
      else
	begin
	  p2f_srdy <= #1 nxt_p2f_srdy;
	  p2f_data <= #1 nxt_p2f_data;
	  count <= #1 nxt_count;
	end
    end

  sd_output #(8+2) par_out
    (
     // Outputs
     .ic_drdy				(lc_drdy),
     .p_srdy				(pdo_srdy),
     .p_data				({pdo_code,pdo_data}),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .ic_srdy				(lc_srdy),
     .ic_data				({lp_code,lp_data}),
     .p_drdy				(pdo_drdy));

endmodule // pkt_parse
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/memory" "../../../rtl/verilog/forks")
// End:  

 