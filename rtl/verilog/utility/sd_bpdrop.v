//----------------------------------------------------------------------
// Srdy/drdy backpressure drop (control path only)
//
// Monitors the srdy/drdy signals and looks for backpressure on the
// consumer interface which exceeds a certain time (in clocks).  If
// the time threshold is exceeded, sinks the packet until the end
// of a token frame.
//
// Naming convention: c = consumer, p = producer, 
// n = non-timing closed (combintorial) output
//----------------------------------------------------------------------
//  Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

// Clocking statement for synchronous blocks.  Default is for
// posedge clocking and positive async reset
`ifndef SDLIB_CLOCKING 
 `define SDLIB_CLOCKING posedge clk or posedge reset
`endif

// delay unit for nonblocking assigns, default is to #1
`ifndef SDLIB_DELAY 
 `define SDLIB_DELAY #1 
`endif

module sd_bpdrop
  #(parameter cnt_sz = 3)
  (
   input               clk,
   input               reset,

   input               g_enable,
   input [cnt_sz-1:0]  g_max_count,
   output reg          g_drop,     // token frame was sunk
  
   input               c_srdy,
   input               c_fr_start, // start of frame signal
   input               c_fr_end,   // end of frame signal
   output reg          nc_drdy,

   output reg          np_srdy,
   input               p_drdy
   );

  localparam s_idle = 2'b00, s_xfer = 2'b01, s_sink = 2'b11;
  
  reg [1:0]            state, nxt_state;
  reg [cnt_sz-1:0]     count, nxt_count;

  always @*
    begin
      nc_drdy = 0;
      np_srdy = 0;
      nxt_state = state;
      nxt_count = count;
      g_drop = 0;
      
      case (state)
        s_idle :
          begin
            if (!g_enable)
              begin
                nc_drdy = p_drdy;
                np_srdy = c_srdy;
              end
            else if (c_srdy & c_fr_start)
              begin
                np_srdy = 1;
                if (p_drdy)
                  begin
                    nc_drdy = 1;
                    nxt_state = s_xfer;
                  end
                else
                  begin
                    nxt_count = count + 1;
                    if (count >= g_max_count)
                      begin
                        nc_drdy = 1;
                        nxt_state = s_sink;
                        g_drop = 1;
                      end
                  end
              end
            else
              begin
                nxt_count = 0;

                // if data other than c_fr_start shows up sink it
                if (c_srdy)
                  nc_drdy = 1;
              end
          end // case: s_idle

        s_xfer :
          begin
            nxt_count = 0;
            np_srdy = c_srdy;
            nc_drdy = p_drdy;
            if (c_srdy & p_drdy & c_fr_end)
              nxt_state = s_idle;
         end // case: s_xfer

        s_sink :
          begin
            nc_drdy = 1;
            nxt_count = 0;

            if (c_srdy & c_fr_end)
              nxt_state = s_idle;
          end

        default : nxt_state = s_idle;
      endcase // case (state)
    end // always @ *

  always @(`SDLIB_CLOCKING)
    begin
      if (reset)
        begin
          state <= `SDLIB_DELAY s_idle;
          count <= `SDLIB_DELAY 0;
        end
      else
        begin
          state <= `SDLIB_DELAY nxt_state;
          count <= `SDLIB_DELAY nxt_count;
        end
    end // always @ (`SDLIB_CLOCKING)
            

endmodule // sd_rrmux
