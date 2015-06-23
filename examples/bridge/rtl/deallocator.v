module deallocator
  (
   input          clk,
   input          reset,

   input [1:0]    port_num,

   // packet input from FIB
   input            f2d_srdy,
   output reg       f2d_drdy,
   input [`LL_PG_ASZ-1:0] f2d_data,

   // read link page i/f
   output reg         rlp_srdy,
   input              rlp_drdy,
   output [`LL_PG_ASZ-1:0]  rlp_rd_page,

   // read link page reply i/f
   input                rlpr_srdy,
   output reg           rlpr_drdy,
   input [`LL_PG_ASZ:0] rlpr_data,
   
   // page dereference interface
   output reg           drf_srdy,
   input                drf_drdy,
   output [`LL_PG_ASZ*2-1:0]  drf_page_list,

   // interface to packet buffer
   output  [`PBR_SZ-1:0] pbrd_data,
   output reg            pbrd_srdy,
   input                 pbrd_drdy,

   // return interface from packet buffer
   input                 pbrr_srdy,
   output                pbrr_drdy,
   input [`PFW_SZ-1:0]   pbrr_data,

   // i/f to distributor
   output               ptx_srdy,
   input                ptx_drdy,
   output [`PFW_SZ-1:0] ptx_data
   
   );

  reg [2:0]             state, nxt_state;
  reg [`LL_PG_ASZ-1:0]        start, nxt_start;
  reg [`LL_PG_ASZ-1:0]        cur, nxt_cur;
  reg [1:0]             lcount, nxt_lcount;

  reg                   pb_req, eop_seen, nxt_eop_seen;

  assign rlp_rd_page = cur;
  assign drf_page_list = { start, cur };

  assign pbrd_data[`PBR_DATA] = 0;
  assign pbrd_data[`PBR_ADDR] = { cur, lcount };
  assign pbrd_data[`PBR_WRITE] = 1'b0;
  assign pbrd_data[`PBR_PORT] = port_num;

  sd_iohalf #(.width(`PFW_SZ)) pkt_rd_buf
    (.clk (clk), .reset (reset),

     .c_srdy (pbrr_srdy),
     .c_drdy (pbrr_drdy),
     .c_data (pbrr_data),

     .p_srdy (ptx_srdy),
     .p_drdy (ptx_drdy),
     .p_data (ptx_data));

  always @(posedge clk)
    begin
      if (reset)
        pb_req <= 0;
      else
        begin
          if (ptx_srdy & ptx_drdy)
            pb_req <= 0;
          else if (pbrd_srdy & pbrd_drdy)
            pb_req <= 1;
        end
    end // always @ (posedge clk)

  localparam s_idle = 0, s_fetch = 1, s_link = 2, s_link_reply = 3,
    s_return = 4;

  always @(posedge clk)
    begin
      if (f2d_srdy & f2d_drdy)
        $display ("%t %m: Dealloc packet %0d", $time, f2d_data);
      if (drf_srdy & drf_drdy)
        $display ("%t %m: Returning packet (%0d,%0d)", $time, start, cur);
    end

  always @*
    begin
      f2d_drdy = 0;
      nxt_state = state;
      nxt_start = start;
      nxt_cur = cur;
      nxt_lcount = lcount;
      nxt_eop_seen = eop_seen;
      rlp_srdy = 0;
      rlpr_drdy = 0;
      drf_srdy = 0;
      pbrd_srdy = 0;

      case (state)
        s_idle :
          begin
            f2d_drdy = 1;
            if (f2d_srdy)
              begin
                nxt_start = f2d_data;
                nxt_cur   = f2d_data;
                nxt_state = s_fetch;
                nxt_eop_seen = 0;
                nxt_lcount = 0;
              end
          end

        // if no requests to the packet buffer are outstanding,
        // then dispatch another request to the packet buffer.
        // If this was the last request of a page then go to
        // link page fetch state.
        s_fetch :
          begin
            if (ptx_srdy & (`ANY_EOP(ptx_data[`PRW_PCC])))
              nxt_eop_seen = 1;

            if (!pb_req & !eop_seen)
              begin
                pbrd_srdy = 1;
                if (pbrd_drdy)
                  begin
                    nxt_lcount = lcount + 1;
                    if (lcount == 3)
                      nxt_state = s_link;
                  end
              end
            else if (eop_seen)
              nxt_state = s_link;
          end // case: s_fetch

        s_link :
          begin
            rlp_srdy = 1;
            if (rlp_drdy)
              nxt_state = s_link_reply;
          end

        s_link_reply :
          begin
            rlpr_drdy = 1;
            if (rlpr_srdy)
              begin
                if (rlpr_data == `LL_ENDPAGE)
                  nxt_state = s_return;
                else
                  begin
                    nxt_cur = rlpr_data;
                    nxt_state = s_fetch;
                  end
              end
          end // case: s_link_reply

        s_return :
          begin
            drf_srdy = 1;
            if (drf_drdy)
              nxt_state = s_idle;
          end

        default : nxt_state = s_idle;
      endcase // case (state)
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
        begin
          state <= s_idle;
          /*AUTORESET*/
          // Beginning of autoreset for uninitialized flops
          cur <= {(1+(`LL_PG_ASZ-1)){1'b0}};
          eop_seen <= 1'h0;
          lcount <= 2'h0;
          start <= {(1+(`LL_PG_ASZ-1)){1'b0}};
          // End of automatics
        end
      else
        begin
          state <= nxt_state;
          start <= nxt_start;
          cur <= nxt_cur;
          lcount <= nxt_lcount;
          eop_seen <= nxt_eop_seen;
        end
    end

endmodule // deallocator
