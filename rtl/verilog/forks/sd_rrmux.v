//----------------------------------------------------------------------
// Srdy/drdy round-robin arbiter
//
// Asserts drdy for an input and then moves to the next input.
//
// This component supports multiple round-robin modes:
//
// Mode 0 : Each input gets a single cycle, regardless of data
//          availability.  This mode functions like a TDM
//          demultiplexer.  Output flow control will cause the
//          component to stall, so that inputs do not miss their
//          turn due to flow control.
// Mode 0 fast arb : Each input gets a single grant. If the
//          output is not ready (p_drdy deasserted), then the
//          machine will hold on that particular input until it
//          receives a grant.  Once a single token has been
//          accepted the machine will round-robin arbitrate.
//          When there are no requests the machine returns to
//          its default state.
// Mode 1 : Each input can transmit for as long as it has data.
//          When input deasserts, device will begin to hunt for a
//          new input with data.
// Mode 2 : Continue to accept input until the incoming data
//          matches a particular "end pattern".  The end pattern
//          is provided on the c_rearb (re-arbitrate) input.  When
//          c_rearb is high, will hunt for new inputs on next clock.
//
// This component also supports two arbitration modes: slow and fast.
// slow rotates the grant from requestor to requestor cycle by cycle,
// so each requestor gets serviced at most once every #inputs cycles.
// This can be useful for producing a TDM-type interface, however
// requestors may be delayed waiting for the grant to come around even
// if there are no other requestors.
//
// Fast mode immediately grants the highest-priority requestor, however
// it is drdy-noncompliant (drdy will not be asserted until srdy is
// asserted).
//
// Naming convention: c = consumer, p = producer, i = internal interface
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

module sd_rrmux
  #(parameter width=8,
    parameter inputs=2,
    parameter inputs_asz=1,  // log2(inputs)
    parameter mode=0,
    parameter fast_arb=0)
  (
   input               clk,
   input               reset,
  
   input [(width*inputs)-1:0] c_data,
   input [inputs-1:0]      c_srdy,
   output  [inputs-1:0]    c_drdy,
   input                   c_rearb,  // for use with mode 2 only

   output     [width-1:0]  p_data,
   output [inputs-1:0]     p_grant,
   output                  p_srdy,
   input                   p_drdy
   );
  
  reg [inputs-1:0]    rr_state;
  reg [inputs-1:0]    nxt_rr_state;

  //wire [width-1:0]     rr_mux_grid [0:inputs-1];
  reg 		       rr_locked;
  //genvar               i;
  integer              j;

  assign c_drdy = rr_state & {inputs{p_drdy}};
  assign p_grant = rr_state;

  function [inputs-1:0] nxt_grant;
    input [inputs-1:0] cur_grant;
    input [inputs-1:0] cur_req;
    reg [inputs-1:0]   msk_req;
    reg [inputs-1:0]   tmp_grant;
    begin
      msk_req = cur_req & ~((cur_grant - 1) | cur_grant);
      tmp_grant = msk_req & (~msk_req + 1);

      if (msk_req != 0)
        nxt_grant = tmp_grant;
      else
        nxt_grant = cur_req & (~cur_req + 1);
    end
  endfunction
  
  always @*
    begin
      data_ind = 0;
      for (j=0; j<inputs; j=j+1)
        if (rr_state[j])
          data_ind = j;
    end

  generate
/* -----\/----- EXCLUDED -----\/-----
    for (i=0; i<inputs; i=i+1)
      begin : grid_assign
        wire [width-1:0] temp;
        assign temp = c_data >> (i*width);
        assign rr_mux_grid[i] = c_data >> (i*width);
      end
 -----/\----- EXCLUDED -----/\----- */

    if (mode == 2)
      begin : tp_gen
        reg nxt_rr_locked;
        reg selected_srdy;
        
        always @*
          begin
/* -----\/----- EXCLUDED -----\/-----
            data_ind = 0;
            for (j=0; j<inputs; j=j+1)
              if (rr_state[j])
                data_ind = j;
 -----/\----- EXCLUDED -----/\----- */

            nxt_rr_locked = rr_locked;

            if ((c_srdy & rr_state) & (!rr_locked))
              nxt_rr_locked = 1;
            else if ((c_srdy & rr_state & c_rearb) & p_drdy )
              nxt_rr_locked = 0;
            else if ((nxt_rr_state != rr_state) && (nxt_rr_state != 0))
              nxt_rr_locked = 1;
            else
              nxt_rr_locked = rr_locked;              
          end

        always @(`SDLIB_CLOCKING)
          begin
            if (reset)
              rr_locked <= `SDLIB_DELAY 0;
            else
              rr_locked <= `SDLIB_DELAY nxt_rr_locked;
          end
      end // block: tp_gen
  endgenerate

  assign p_srdy = |(rr_state & c_srdy);
  assign p_data = c_data[data_ind*width +: width];
  
  always @*
    begin
      if ((mode ==  1) & (c_srdy & rr_state))
        nxt_rr_state = rr_state;
      else if ((mode == 0) && !p_drdy && !fast_arb)
        nxt_rr_state = rr_state;
      else if ((mode == 0) && |(rr_state & c_srdy) && !p_drdy && fast_arb)
        nxt_rr_state = rr_state;
      else if ((mode == 2) & (rr_locked | (c_srdy & rr_state)))
        nxt_rr_state = rr_state;
      else if (fast_arb)
        nxt_rr_state = nxt_grant (rr_state, c_srdy);
      else
        nxt_rr_state = { rr_state[0], rr_state[inputs-1:1] };
    end

  always @(`SDLIB_CLOCKING)
    begin
      if (reset)
        rr_state <= `SDLIB_DELAY (fast_arb)? 0 : 1;
      else
        rr_state <= `SDLIB_DELAY nxt_rr_state;
    end

endmodule // sd_rrmux
