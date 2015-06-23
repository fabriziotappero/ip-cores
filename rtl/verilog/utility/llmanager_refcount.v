module llmanager_refcount
  #(parameter     lpsz = 8,
    parameter     refsz = 3)
  (
   input clk,
   input reset,

   input            drq_srdy,
   output reg       drq_drdy,
   input [lpsz-1:0]         drq_start_page,
   input [lpsz-1:0]         drq_end_page,

   output reg reclaim_srdy,
   input      reclaim_drdy,
   output reg [lpsz-1:0] reclaim_start_page,
   output reg [lpsz-1:0] reclaim_end_page,

   // reference count update interface
   input                  refup_srdy,
   output reg             refup_drdy,
   input [lpsz-1:0]       refup_page,
   input [refsz-1:0]      refup_count,

   // reference count memory interface
   output reg                ref_wr_en,
   output reg [lpsz-1:0]     ref_wr_addr,
   output reg [refsz-1:0]    ref_wr_data,
   output reg [lpsz-1:0]     ref_rd_addr,
   output reg                ref_rd_en,
   input [refsz-1:0]         ref_rd_data
   );

  reg [lpsz-1:0]          dref_start_addr, nxt_dref_start_addr;
  reg [lpsz-1:0]          dref_end_addr, nxt_dref_end_addr;
  reg [2:0]               state, nxt_state;

  localparam s_idle = 0, s_dreq = 1, s_reclaim = 2;

  always @*
    begin
      reclaim_srdy = 0;
      reclaim_start_page = 0;
      reclaim_end_page = 0;
      ref_wr_en = 0;
      ref_wr_addr = 0;
      ref_wr_data = 0;
      ref_rd_addr = 0;
      ref_rd_en = 0;
      drq_drdy = 0;
      refup_drdy = 0;
      nxt_state = state;
      nxt_dref_start_addr = dref_start_addr;
      nxt_dref_end_addr   = dref_end_addr;

      case (1'b1)
        state[s_idle] :
          begin
            refup_drdy = 1;
            if (refup_srdy)
              begin
                ref_wr_en = 1;
                ref_wr_addr = refup_page;
                ref_wr_data = refup_count;
              end
            else if (drq_srdy)
              begin
                ref_rd_en = 1;
                ref_rd_addr = drq_start_page;
                nxt_state = 1 << s_dreq;
                nxt_dref_start_addr = drq_start_page;
                nxt_dref_end_addr   = drq_end_page;
              end
          end // case: s_idle

        state[s_dreq] :
          begin
            drq_drdy = 1;
            ref_wr_en = 1;
            ref_wr_addr = dref_start_addr;
            ref_wr_data = ref_rd_data - 1;
            if (ref_rd_data == 1)
              nxt_state = 1 << s_reclaim;
            else
              nxt_state = 1 << s_idle;
          end

        state[s_reclaim] :
          begin
            reclaim_srdy = 1;
            reclaim_start_page = dref_start_addr;
            reclaim_end_page = dref_end_addr;
            if (reclaim_drdy)
              nxt_state = 1 << s_idle;
          end
      endcase // case (1'b1)
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
        begin
          state <= 1 << s_idle;
        end
      else
        begin
          state <= nxt_state;
        end
    end

  always @(posedge clk)
    begin
      dref_start_addr <= nxt_dref_start_addr;
      dref_end_addr   <= nxt_dref_end_addr;
    end

endmodule // llmanager_refcount
