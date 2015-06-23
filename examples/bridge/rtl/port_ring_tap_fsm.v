module port_ring_tap_fsm
  #(parameter rdp_sz = 64,
    parameter pdp_sz = 64,
    parameter portnum = 0)
  (
   input               clk,
   input               reset,
   
   output reg               lfli_drdy,
   output reg               lprx_drdy,
   output reg[pdp_sz-1:0]    lptx_data,
   output reg               lptx_srdy,
   output reg               lri_drdy, 
   output reg[rdp_sz-1:0]    lro_data, 
   output reg               lro_srdy, 

   input [`NUM_PORTS-1:0]   lfli_data, 
   input               lfli_srdy, 
   input [pdp_sz-1:0]   lprx_data, 
   input               lprx_srdy, 
   input               lptx_drdy, 
   input [rdp_sz-1:0]   lri_data,  
   input               lri_srdy,  
   input               lro_drdy,

   output              rarb_req,
   input               rarb_ack
   );

  reg [5:0]            state, nxt_state;

  wire [`NUM_PORTS-1:0] port_mask;
  wire [`NUM_PORTS-1:0] nxt_pe_vec = lri_data[`PRW_DATA] & ~port_mask;

  assign port_mask = 1 << portnum;

  localparam s_idle = 0,
             s_rfwd = 1,
             s_rcopy = 2,
             s_rsink = 3,
             s_tdata = 4,
              s_tdrop = 5;
  localparam ns_idle = 1,
             ns_rfwd = 2,
             ns_rcopy = 4,
             ns_rsink = 8,
             ns_tdata = 16,
    ns_tdrop = 32;

  assign rarb_req = lfli_srdy & lprx_srdy | state[s_tdata];
  
  always @*
    begin
      lro_data = lri_data;
      lptx_data = lri_data;
      lfli_drdy = 0;
      lprx_drdy = 0;
      lptx_srdy = 0;
      lri_drdy  = 0;
      lro_srdy  = 0;
      nxt_state = state;
      
      case (1'b1)
        state[s_idle] :
          begin
            if (lfli_srdy & lprx_srdy & rarb_ack)
              begin
		if (lfli_data != 0)
		  begin
		    lro_data = 0;
		    lro_data[`PRW_PVEC] = 1;
		    lro_data[`PRW_DATA] = lfli_data;
		    if (lro_drdy)
		      begin
			lfli_drdy = 1;
			lro_srdy = 1;
			nxt_state = ns_tdata;
		      end
		  end
		else
                  begin
		    lfli_drdy = 1;
                    nxt_state = ns_tdrop;
                  end
              end
            else if (lri_srdy)
              begin
                if (lri_data[`PRW_DATA] & port_mask)
                  begin
                    // packet is for our port
                    //nxt_pe_vec = lri_data[`PRW_DATA] & ~port_mask;

                    // if enable vector is not empty, send the
                    // vector to the next port
                    if ((nxt_pe_vec != 0) & lro_drdy)
                      begin
                        lro_data[`PRW_DATA] = nxt_pe_vec;
                        lro_data[`PRW_PVEC] = 1;
                        lro_srdy = 1;
                        lri_drdy = 1;
                        nxt_state = ns_rcopy;
                      end
                    else if (nxt_pe_vec == 0)
                      begin
                        lri_drdy = 1;
                        nxt_state = ns_rsink;
                      end // else: !if((nxt_pe_vec != 0) & lro_drdy)
                  end // if (lri_data[`PRW_DATA] & port_mask)
                else
                  // packet is not for our port, forward it on the
                  // ring
                  begin
                    if (lro_drdy)
                      begin
                        lri_drdy = 1;
                        lro_srdy = 1;
                        nxt_state = ns_rfwd;
                      end
                  end // else: !if(lri_data[`PRW_DATA] & port_mask)
              end // if (lri_srdy)
          end // case: state[s_idle]

	// transmit data from port on to the ring
	state[s_tdata] :
	  begin
	    lro_data = lprx_data;
	    lro_data[`PRW_PVEC] = 0;
	    if (lro_drdy & lprx_srdy)
	      begin
		lprx_drdy = 1;
		lro_srdy  = 1;
		if ((lprx_data[`PRW_PCC] == `PCC_EOP) |
		    (lprx_data[`PRW_PCC] == `PCC_BADEOP))
		  nxt_state = ns_idle;
	      end
	  end // case: state[s_tdata]

        // received lookup from FIB with zero port index; drop
        // the packet by reading out
        state[s_tdrop] :
          begin
            lprx_drdy = 1;
            if (lprx_srdy)
              begin
 		if ((lprx_data[`PRW_PCC] == `PCC_EOP) |
		    (lprx_data[`PRW_PCC] == `PCC_BADEOP))
		  nxt_state = ns_idle;
              end
          end

	// data on ring is for our port as well as further ports
	// copy ring data to our TX buffer as well as on the ring
	state[s_rcopy] :
	  begin
	    lro_data = lri_data;
	    lptx_data = lri_data[`PFW_SZ-1:0];
	    if (lri_srdy & lro_drdy & lptx_drdy)
	      begin
		lri_drdy = 1;
		lro_srdy = 1;
		lptx_srdy = 1;
		if ((lri_data[`PRW_PCC] == `PCC_EOP) |
		    (lri_data[`PRW_PCC] == `PCC_BADEOP))
		  nxt_state = ns_idle;
	      end
	  end

	// data on ring is not for our port, copy from ring in to ring out
	state[s_rfwd] :
	  begin
	    lro_data = lri_data;
	    if (lri_srdy & lro_drdy)
	      begin
		lri_drdy = 1;
		lro_srdy = 1;
		if ((lri_data[`PRW_PCC] == `PCC_EOP) |
		    (lri_data[`PRW_PCC] == `PCC_BADEOP))
		  nxt_state = ns_idle;
	      end
	  end

	// data on ring is for our port and we are the last port
	// copy ring data to our TX buffer but do not copy to ring
	state[s_rsink] :
	  begin
	    lptx_data = lri_data[`PFW_SZ-1:0];
	    if (lri_srdy & lptx_drdy)
	      begin
		lri_drdy = 1;
		lptx_srdy = 1;
		if ((lri_data[`PRW_PCC] == `PCC_EOP) |
		    (lri_data[`PRW_PCC] == `PCC_BADEOP))
		  nxt_state = ns_idle;
	      end
	  end

        default : nxt_state = ns_idle;
      endcase // case (1'b1)
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
	begin
	  state <= #1 1;
	  /*AUTORESET*/
	end
      else
	begin
	  state <= #1 nxt_state;
	end
    end // always @ (posedge clk)

            

endmodule // port_ring_tap_fsm
