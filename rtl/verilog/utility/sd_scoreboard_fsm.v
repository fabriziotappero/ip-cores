//----------------------------------------------------------------------
//  Scoreboard FSM
//
// Keeps track of data regarding N items.  Allows multiple entities
// to track data about a particular item.  Supports masked writes,
// allowing only part of a record to be updated by a particular
// transaction.
//
// If masks are enabled, 
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

module sd_scoreboard_fsm
  #(parameter width=8,
    parameter items=64,
    parameter use_txid=0,
    parameter use_mask=0,
    parameter txid_sz=2,
    parameter asz=6)  //log2(items))
  (input      clk,
   input      reset,

   input      ip_srdy,
   output reg     ip_drdy,
   input      ip_req_type, // 0=read, 1=write
   input [txid_sz-1:0] ip_txid,
   input [width-1:0] ip_mask,
   input [width-1:0] ip_data,
   input [asz-1:0]   ip_itemid,

   output reg     ic_srdy,
   input      ic_drdy,
   output reg [txid_sz-1:0] ic_txid,
   output reg [width-1:0]   ic_data,

   input [width-1:0]    d_out,
   output reg               wr_en,
   output reg               rd_en,
   output reg [width-1:0]   d_in,
   output reg [asz-1:0]     addr
   );

  localparam s_idle = 0, s_read = 1, s_rdmod = 2;
  
  reg [2:0]                 state, nxt_state;
  reg [txid_sz-1:0]         txid, nxt_txid;

  always @*
    begin
      ip_drdy = 0;
      ic_srdy = 0;
      ic_data = 0;
      wr_en = 0;
      rd_en = 0;
      d_in = 0;
      addr = ip_itemid;
      nxt_state = state;
      nxt_txid  = txid;
      if (use_txid)
        ic_txid = txid;
      else
        ic_txid = 0;

      nxt_state[s_read] = 0;
      
      if (state[s_idle])
        begin
	  if (state[s_read] & !ic_drdy)
	    begin
	      // output is busy, stall
	    end
          else if (ip_srdy & (ip_req_type==1))
            begin
              if ((use_mask==0) | (ip_mask=={width{1'b1}}))
                begin
                  ip_drdy = 1;
                  wr_en   = 1;
                  d_in    = ip_data;
                end
              else
                begin
                  rd_en = 1;
                  nxt_state[s_rdmod] = 1;
                  nxt_state[s_idle]  = 0;
                end
            end
          else if (ip_srdy & (ip_req_type==0))
            begin
              rd_en = 1;
              nxt_state[s_read] = 1;
              nxt_txid  = ip_txid;
              ip_drdy   = 1;
            end
        end // case: s_idle

      if (state[s_read])
        begin
          ic_srdy = 1;
          ic_data = d_out;
          if (!ic_drdy)
            begin
              nxt_state[s_read] = 1;
              //nxt_state[s_idle] = 1;
            end
        end // case: state[s_read]

      if (state[s_rdmod])
        begin
          ip_drdy = 1;
          d_in = (d_out & ~ip_mask) | (ip_data & ip_mask);
          wr_en   = 1;

          nxt_state[s_rdmod] = 0;
          nxt_state[s_idle]  = 1;
        end
    end // always @ *


  always @(`SDLIB_CLOCKING)
    begin
      if (reset)
        begin
          state <= `SDLIB_DELAY 1;
        end
      else
        begin
          state <= `SDLIB_DELAY nxt_state;
        end
    end // always @ (`SDLIB_CLOCKING)

  generate
    if (use_txid != 0)
      begin : gen_txid_hold
        always @(`SDLIB_CLOCKING)
          begin
            if (reset)
              begin
                txid  <= `SDLIB_DELAY 0;
              end
            else
              begin
                txid  <= `SDLIB_DELAY nxt_txid;
              end
          end // always @ (`SDLIB_CLOCKING)
      end // block: gen_txid_hold
  endgenerate

endmodule // sd_scoreboard_fsm
