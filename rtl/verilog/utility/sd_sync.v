//----------------------------------------------------------------------
// Srdy/Drdy Sync Block
//
// Provides synchronization across clock domains for an srdy/drdy
// pair.  Assumes low utilization; for high utilization see sd_fifo_a.
//
// Only syncs control signals, data can be passed directly to the
// receiver.
//
// Naming convention: c = consumer, p = producer
//----------------------------------------------------------------------
//  Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

// delay unit for nonblocking assigns, default is to #1
`ifndef SDLIB_DELAY 
 `define SDLIB_DELAY #1 
`endif

module sd_sync
  #(parameter edge_det = 0)
  (
   input       c_clk,
   input       c_reset,
   input       c_srdy,
   output reg  c_drdy,

   input       p_clk,
   input       p_reset,
   output reg  p_srdy,
   input       p_drdy
   );

  reg          launch_a, nxt_launch_a;

  reg          sync_ack_b, ack_b;
  reg [1:0]    psync_b; // pulse sync A to B
  reg          p_ack;
  reg          p_state, nxt_p_state;
  reg [1:0]    c_state, nxt_c_state;

  localparam ps_idle = 0, ps_ack = 1;
  localparam cs_idle = 0, cs_req = 1, cs_clear = 2;

  //------------------------------------------------------------
  // Consumer Clock Domain
  //------------------------------------------------------------

  always @*
    begin
      nxt_launch_a = 0;
      c_drdy = 0;
      nxt_c_state = c_state;

      case (c_state)
        cs_idle :
          begin
            if (c_srdy)
              begin
                nxt_launch_a = 1;
                nxt_c_state  = cs_req;
              end
          end

        cs_req :
          begin
            nxt_launch_a = 1;

            if (ack_b)
              begin
                c_drdy = 1;
                nxt_c_state = cs_clear;
              end
          end

        cs_clear :
          begin
            if (!ack_b)
              nxt_c_state = cs_idle;
          end

        default : nxt_c_state = cs_idle;
      endcase
    end // always @ *
  
  
  always @(posedge c_clk or posedge c_reset)
    begin
      if (c_reset)
        begin
          launch_a <= `SDLIB_DELAY 1'b0;
          c_state  <= `SDLIB_DELAY cs_idle;
        end
      else
        begin
          launch_a <= `SDLIB_DELAY nxt_launch_a;
          c_state  <= `SDLIB_DELAY nxt_c_state;
        end
    end

  always @(posedge c_clk)
    begin
      ack_b      <= `SDLIB_DELAY sync_ack_b;
      sync_ack_b <= `SDLIB_DELAY p_ack;
    end

  //------------------------------------------------------------
  // Producer Clock Domain
  //------------------------------------------------------------

  always @(posedge p_clk or posedge p_reset)
    begin
      if (p_reset)
        p_state <= `SDLIB_DELAY ps_idle;
      else
        p_state <= `SDLIB_DELAY nxt_p_state;
    end
      
  always @(posedge p_clk)
    begin
      psync_b   <= `SDLIB_DELAY { launch_a, psync_b[1] };
    end

  always @*
    begin
      p_ack = 0;
      p_srdy = 0;
      nxt_p_state = p_state;
      
      case (p_state)
        ps_idle :
          begin
            p_srdy = psync_b[0];

            if (psync_b[0] & p_drdy)
              begin
                nxt_p_state = ps_ack;
              end
          end

        ps_ack :
          begin
            p_srdy = 0;
            p_ack  = 1;

            if (!psync_b[0])
              nxt_p_state = ps_idle;
          end

      endcase // case (p_state)
    end // always @ *

endmodule // sd_sync
