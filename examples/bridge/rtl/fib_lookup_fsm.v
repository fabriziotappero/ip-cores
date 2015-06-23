module fib_lookup_fsm
  (/*AUTOARG*/
  // Outputs
  lpp_drdy, ft_wdata, ft_rd_en, ft_wr_en, ft_addr, lout_start,
  lout_srdy, lout_dst_vld, refup_srdy, refup_page, refup_count,
  // Inputs
  clk, reset, lpp_data, lpp_srdy, ft_rdata, lout_drdy, refup_drdy
  );

  input clk, reset;
  
  input [`PM2F_SZ-1:0] lpp_data;
  input                    lpp_srdy;
  output reg               lpp_drdy;

  input [`FIB_ENTRY_SZ-1:0]       ft_rdata;
  output reg [`FIB_ENTRY_SZ-1:0]  ft_wdata;
  output reg                      ft_rd_en, ft_wr_en;
  output reg [`FIB_ASZ-1:0]       ft_addr;
  
  output [`LL_PG_ASZ-1:0]         lout_start;
  output reg                      lout_srdy;
  input                           lout_drdy;
  output reg [`NUM_PORTS-1:0]     lout_dst_vld;
  
  output                          refup_srdy;
  input                           refup_drdy;
  output [`LL_PG_ASZ-1:0]         refup_page;
  output [`LL_REFSZ-1:0]          refup_count;

  wire [`FIB_ASZ-1:0]             hf_out;
  reg [47:0]                      hf_in;

  wire [`NUM_PORTS-1:0]           source_port_mask;

  reg [`FIB_ASZ-1:0]              init_ctr, nxt_init_ctr;
  reg [5:0]                       state, nxt_state;
  reg                             lrefup_srdy;
  reg [`LL_REFSZ-1:0]             lrefup_count;

  assign source_port_mask = 1 << lpp_data[`PAR_SRCPORT];

  //assign lrefup_count = count_bits (lout_dst_vld);
  //assign refup_page  = lpp_data[`A2F_STARTPG];
  assign lout_start  = lpp_data[`A2F_STARTPG];
  
  function [`LL_REFSZ-1:0] count_bits;
    input [`NUM_PORTS-1:0] dest;
    integer     i, count;
    begin
      count = 0;
      for (i=0; i<4; i=i+1)
        if (dest[i]) count = count + 1;
      count_bits = count;
    end
  endfunction // for

  sd_iohalf #(.width(`LL_PG_ASZ+`LL_REFSZ)) refup_buf
    (.clk (clk), .reset (reset),
     .c_srdy (lrefup_srdy),
     .c_drdy (lrefup_drdy),
     .c_data ({lrefup_count, lpp_data[`A2F_STARTPG]}),
     .p_srdy (refup_srdy),
     .p_drdy (refup_drdy),
     .p_data ({refup_count, refup_page}));
  
  basic_hashfunc #(48, `FIB_ENTRIES) hashfunc
    (
     // Outputs
     .hf_out                            (hf_out),
     // Inputs
     .hf_in                             (hf_in));

  localparam s_idle = 0, s_da_lookup = 1, s_sa_lookup = 2,
    s_init0 = 3, s_init1 = 4, s_wait_refup = 5;
  localparam ns_idle = 1, ns_da_lookup = 2, ns_sa_lookup = 4,
    ns_init0 = 8, ns_init1 = 16, ns_wait_refup = 1 << s_wait_refup;

  reg 				  amux;

  always @*
    begin
      case (amux)
	0 : ft_addr = hf_out;
	1 : ft_addr = init_ctr;
      endcase // case (amux)
    end
  
  always @*
    begin
      hf_in = 0;
      nxt_state = state;
      ft_rd_en = 0;
      ft_wr_en = 0;
      amux = 0;
      lout_dst_vld = 0;
      lout_srdy = 0;
      lpp_drdy = 0;
      nxt_init_ctr = init_ctr;
      lrefup_srdy = 0;
      
      case (1'b1)
        state[s_idle] :
          begin
            // DA lookup
            if (lpp_srdy)
              begin
                if (lpp_data[`PAR_MACDA] & `MULTICAST)
                  begin
                    // flood the packet, don't bother to do DA lookup
                    lout_dst_vld = ~source_port_mask;
                    lout_srdy = 1;
                    if (lout_drdy)
                      nxt_state = ns_sa_lookup;
                  end
                else
                  begin
                    hf_in = lpp_data[`PAR_MACDA];
                    ft_rd_en = 1;
                    nxt_state = ns_da_lookup;
                  end // else: !if(lpp_data[`PAR_MACDA] & `MULTICAST)
              end
          end

        // results from DA lookup are available this
        // state.  Make forwarding decision at this
        // point.
        state[s_da_lookup] :
          begin
            // no match, flood packet
            if (ft_rdata[`FIB_AGE] == 0)
              begin
                lout_dst_vld = ~source_port_mask;
              end
            else
              begin
                lout_dst_vld = (1 << ft_rdata[`FIB_PORT]) & ~source_port_mask;
              end
            
            lout_srdy = 1;
            if (lout_drdy)
              nxt_state = ns_sa_lookup;
          end // case: state[s_da_lookup]

        // blind write out MACSA to FIB table
        // will bump out current occupant and update
        state[s_sa_lookup] :
          begin
            ft_wr_en = 1;
            hf_in = lpp_data[`PAR_MACSA];
            ft_wdata[`FIB_MACADDR] = lpp_data[`PAR_MACSA];
            ft_wdata[`FIB_AGE]  = `FIB_MAX_AGE;
            ft_wdata[`FIB_PORT] = lpp_data[`PAR_SRCPORT];
            nxt_state = ns_idle;

            lrefup_srdy = 1;
            if (lrefup_drdy)
              begin
                nxt_state = ns_idle;
                lpp_drdy = 1;
              end
            else
              nxt_state = ns_wait_refup;
          end // case: state[s_sa_lookup]

        state[s_wait_refup] :
          begin
            lrefup_srdy = 1;
            if (lrefup_drdy)
              begin
                nxt_state = ns_idle;
                lpp_drdy = 1;
              end
          end

        state[s_init0] :
          begin
            nxt_init_ctr = 0;
            nxt_state = ns_init1;
          end

        state[s_init1] :
          begin
            nxt_init_ctr = init_ctr + 1;
            ft_wr_en = 1;
	    amux = 1;
            ft_wdata = 0;
            if (init_ctr == (`FIB_ENTRIES-1))
              nxt_state = ns_idle;
          end

        default :
          nxt_state = ns_idle;
      endcase // case (1'b1)
    end // always @ *
  
  always @(posedge clk)
    begin
      if (reset)
        begin
          init_ctr <= #1 0;
          state    <= #1 ns_init0;
          lrefup_count <= #1 0;
        end
      else
        begin
          init_ctr <= #1 nxt_init_ctr;
          state    <= #1 nxt_state;
          if (lout_srdy)
            lrefup_count <= #1 count_bits (lout_dst_vld);
        end
    end

endmodule // fib_lookup_fsm
