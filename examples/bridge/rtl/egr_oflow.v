module egr_oflow
  #(parameter drop_thr=`TX_FIFO_DEPTH-128)
  (
   input        clk,
   input        reset,

   input        c_srdy,
   output reg   c_drdy,
   input [`PFW_SZ-1:0] c_data,

   input [`TX_USG_SZ-1:0] tx_usage,

   output reg   p_srdy,
   input        p_drdy,
   output [`PFW_SZ-1:0] p_data,
   output reg   p_commit,
   output reg   p_abort
   );

  reg  	state, nxt_state;

  localparam s_idle = 0, s_packet = 1, s_flush = 2;

  assign p_data = c_data;

  always @*
    begin
      c_drdy = 0;
      p_srdy = 0;
      p_commit = 0;
      p_abort = 0;

      case (state)
	s_idle :
	  begin
	    if (c_srdy & p_drdy & (c_data[`PRW_PCC] == `PCC_SOP))
	      begin
		nxt_state = s_packet;
		c_drdy = 1;
		p_srdy = 1;
	      end
	    else if (c_srdy)
	      begin
		c_drdy = 1;
	      end
	  end // case: state[s_idle]

	s_packet :
	  begin
	    if (c_srdy & (c_data[`PRW_PCC] == `PCC_BADEOP))
	      begin
		c_drdy = 1;
		p_abort = 1;
		nxt_state = s_idle;
	      end
	    else if (c_srdy & p_drdy & (c_data[`PRW_PCC] == `PCC_EOP))
	      begin
		p_srdy = 1;
		c_drdy = 1;
		p_commit = 1;
		nxt_state = s_idle;
	      end
	    else if (!p_drdy | (tx_usage >= drop_thr))
	      begin
		c_drdy = 1;
		nxt_state = s_idle;
		p_abort = 1;
	      end
	    else if (c_srdy & p_drdy)
	      begin
		p_srdy = 1;
		c_drdy = 1;
	      end
	  end // case: state[s_packet]

	default : nxt_state = s_idle;
      endcase // case (1'b1)
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
	begin
	  state <= #1 s_idle;
	end
      else
	begin
	  state <= #1 nxt_state;
	end
    end // always @ (posedge clk)

endmodule // egr_oflow
