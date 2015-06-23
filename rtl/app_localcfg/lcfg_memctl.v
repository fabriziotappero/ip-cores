/* Copyright (c) 2011, Guy Hutchison
   All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

//----------------------------------------------------------------------
//  Author: Guy Hutchison
//
//  Memory Controller/Arbiter
//----------------------------------------------------------------------

module lcfg_memctl
  (/*AUTOARG*/
  // Outputs
  a_wait_n, a_rdata, b_wait_n, b_rdata, cfgi_trdy, cfgi_rd_data,
  // Inputs
  clk, reset_n, a_mreq_n, a_rd_n, a_wr_n, a_addr, a_wdata, b_mreq_n,
  b_wr_n, b_addr, b_wdata, lcfg_init, cfgi_irdy, cfgi_addr,
  cfgi_write, cfgi_wr_data
  );

  // address size of memory
  parameter mem_asz = 13, mem_depth = 8192;

  input         clk;
  input         reset_n;

  // read port A (uP)
  input         a_mreq_n;
  input         a_rd_n;
  input         a_wr_n;
  input [mem_asz+1:0]  a_addr;
  output        a_wait_n;
  input [7:0]   a_wdata;
  output [7:0]  a_rdata;
  reg           a_wait_n;

  // read port B
  input         b_mreq_n;
  input         b_wr_n;
  input [mem_asz-1:0]  b_addr;
  output        b_wait_n;
  input [31:0]  b_wdata;
  output [31:0] b_rdata;
  reg           b_wait_n;

  input         lcfg_init;

  // incoming config interface to 
  // read/write processor memory
  input         cfgi_irdy;
  output     cfgi_trdy;
  input [mem_asz-1:0] cfgi_addr;
  input         cfgi_write;
  input [31:0]  cfgi_wr_data;
  output [31:0] cfgi_rd_data;
  reg           cfgi_trdy, nxt_cfgi_trdy;

  reg           ram_nwrt;
  reg           ram_nce;
  reg [31:0]    ram_din;
  reg [mem_asz-1:0]    ram_addr;
  wire [31:0]   dout;
  reg [7:0]     a_rdata;

  reg [mem_asz-1:0]    ca_addr, nxt_ca_addr;
  reg [31:0]    ca_data, nxt_ca_data;
  reg [mem_asz-1:0]    wc_addr, nxt_wc_addr;
  reg [31:0]    wc_data, nxt_wc_data;
  reg           cvld, nxt_cvld;
  reg           wcvld, nxt_wcvld;

  reg           a_prio, nxt_a_prio;
  reg           a_rip, nxt_a_rip;  // read in progress by A
  reg           a_wip, nxt_a_wip;  // write (read-cache-fill) in progress by A
  reg           b_rip, nxt_b_rip;  // read in progress by B
  wire          c_rip = cfgi_trdy;
  wire          a_cache_hit, b_cache_hit;

  /*AUTOWIRE*/

  assign        cfgi_rd_data = dout;
  assign        b_rdata = dout;

  assign a_cache_hit = cvld & (ca_addr == a_addr[mem_asz+1:2]);
  assign b_cache_hit = wcvld & (wc_addr == a_addr[mem_asz+1:2]);
  
  
  /* behave1p_mem AUTO_TEMPLATE
   (
   // Outputs
   .d_out                              (dout),
   // Inputs
   .wr_en                             (!ram_nce & !ram_nwrt),
   .rd_en                             (!ram_nce & ram_nwrt),
   .clk                               (clk),
   .d_in                               (ram_din[]),
   .addr                                (ram_addr[]), 
   );
   */

  behave1p_mem #(.width(32),
                 .depth (mem_depth),
                 .addr_sz (mem_asz))  mem
    (/*AUTOINST*/
     // Outputs
     .d_out                             (dout),                  // Templated
     // Inputs
     .wr_en                             (!ram_nce & !ram_nwrt),  // Templated
     .rd_en                             (!ram_nce & ram_nwrt),   // Templated
     .clk                               (clk),                   // Templated
     .d_in                              (ram_din[31:0]),         // Templated
     .addr                              (ram_addr[(mem_asz)-1:0])); // Templated
  
  always @*
    begin
      nxt_ca_addr = ca_addr;
      ram_nwrt = 1;
      ram_nce  = 1;
      ram_din = 32'h0;
      ram_addr = a_addr[mem_asz+1:2];
      a_wait_n = 1;
      b_wait_n = 1;
      nxt_a_prio = a_prio;
      nxt_a_rip  = 0;
      nxt_b_rip  = 0;
      nxt_a_wip  = a_wip;
      nxt_ca_data = ca_data;
      nxt_cvld    = cvld;
      nxt_wcvld   = wcvld;
      nxt_wc_data = wc_data;
      nxt_wc_addr = wc_addr;
      nxt_cfgi_trdy = 0;

      if (a_cache_hit)
        begin
          case (a_addr[1:0])
            0 : a_rdata = ca_data[7:0];
            1 : a_rdata = ca_data[15:8];
            2 : a_rdata = ca_data[23:16];
            3 : a_rdata = ca_data[31:24];
          endcase // case(a_addr[1:0])
        end
      else if (b_cache_hit)
        begin
          case (a_addr[1:0])
            0 : a_rdata = wc_data[7:0];
            1 : a_rdata = wc_data[15:8];
            2 : a_rdata = wc_data[23:16];
            3 : a_rdata = wc_data[31:24];
          endcase // case(a_addr[1:0])
        end
      else
        a_rdata = 0;
      

      if (lcfg_init)
        begin
          // repurpose the cache bits as FSM status bits
          // cvld == done
          if (!cvld)
            begin
              ram_nce    = 0;
              ram_addr = ca_addr;
              ram_nwrt = 0;
              ram_din = 32'h0;
              if (ca_addr == 8191)
                begin
                  nxt_ca_addr = ca_addr;
                  nxt_cvld = 1;
                  nxt_ca_data = 32'h0;
                end
              else
                nxt_ca_addr = ca_addr + 1;
            end              
        end
      else
        begin
          if (!a_mreq_n)
            begin
              if (!a_rd_n)
                begin
                  // check for cache hit
                  if (!a_cache_hit & !b_cache_hit)
                    begin
                      a_wait_n   = 0;
                      if (a_rip)
                        begin
                          nxt_ca_addr = a_addr[mem_asz+1:2];
                          nxt_ca_data = dout;
                          nxt_cvld    = 1;
                        end
                      else if (a_prio | b_mreq_n)
                        begin                  
                          ram_addr = a_addr[mem_asz+1:2];
                          nxt_a_prio = 0;
                          ram_nce    = 0;
                          nxt_a_rip  = 1;
                        end
                    end // if (ca_addr != a_addr[14:2])
                end // if (!rd_n)
              else if (!a_wr_n)
                begin
                  if (a_prio | b_mreq_n)
                    begin
                      // if data is in our read cache, transfer it to the
                      // write cache, invalidate the read cache, update the
                      // appropriate data byte, and start the B cache
                      // write-back
                      if (a_cache_hit)
                        begin
                          nxt_cvld = 0;
                          
                          case (a_addr[1:0])
                            0 : nxt_wc_data = { ca_data[31:8], a_wdata };
                            1 : nxt_wc_data = { ca_data[31:16], a_wdata, ca_data[7:0] };
                            2 : nxt_wc_data = { ca_data[31:24], a_wdata, ca_data[15:0] };
                            3 : nxt_wc_data = { a_wdata, ca_data[23:0] };
                          endcase // case(a_addr[1:0])
                          nxt_wc_addr = ca_addr;
                          nxt_a_wip = 1;
                          nxt_a_prio = 1;
                        end
                      

                      // if read is in progress, we have the results of our
                      // cache fill.  Store this in the write cache so next
                      // cycle we will get a cache hit.
                      else if (a_rip)
                        begin
                          a_wait_n    = 0;
                          nxt_wc_data = dout;
                          nxt_wc_addr = a_addr[mem_asz+1:2];
                          nxt_wcvld   = 1;
                        end

                      // if we get a write cache hit, we have the data we
                      // need.  Change the data in the write cache and trigger
                      // a write-back next cycle.
                      else if (b_cache_hit)
                        begin
                          case (a_addr[1:0])
                            0 : nxt_wc_data[7:0] = a_wdata;
                            1 : nxt_wc_data[15:8] = a_wdata;
                            2 : nxt_wc_data[23:16] = a_wdata;
                            3 : nxt_wc_data[31:24] = a_wdata;
                          endcase // case(a_addr[1:0])
                          nxt_a_wip = 1;
                          nxt_a_prio = 1;
                        end

                      // otherwise we do not have the data in our write cache
                      // yet.  Trigger a read to fill the write cache.
                      else if (a_prio | b_mreq_n)
                        begin
                          a_wait_n   = 0;
                          ram_addr = a_addr[mem_asz+1:2];
                          nxt_a_prio = 0;
                          ram_nce    = 0;
                          nxt_a_rip  = 1;
                        end                      
                    end
                  else
                    a_wait_n = 0;
                end
            end // if (!a_mreq_n)
          else
            begin
              if (a_wip & (a_prio|b_mreq_n))
                begin
                  ram_addr = wc_addr;
                  nxt_a_prio = 0;
                  ram_nce = 0;
                  ram_nwrt = 0;
                  nxt_a_wip = 0;
                  ram_din = wc_data;
                end
            end
          

          if (!b_mreq_n)
            begin
              if (!b_wr_n)
                begin
                  if (!a_prio | a_mreq_n)
                    begin
                      ram_addr = b_addr;
                      nxt_a_prio = 1;
                      ram_nce = 0;
                      ram_nwrt = 0;
                      ram_din = b_wdata;
                      if (b_addr == ca_addr)
                        nxt_cvld = 0;
                      if (wc_addr == ca_addr)
                        nxt_wcvld = 0;
                    end
                  else
                    b_wait_n = 0;
                end // if (!b_wr_n)
              else
                begin
                  if (b_rip)
                    begin
                      b_wait_n = 1;
                    end
                  else if (!a_prio | a_mreq_n)
                    begin
                      ram_addr = b_addr;
                      nxt_b_rip = 1;
                      nxt_a_prio = 1;
                      ram_nce = 0;
                      b_wait_n = 0;
                    end                  
                end
            end // if (!b_mreq_n)

          if (cfgi_irdy)
            begin
              if ((a_mreq_n & b_mreq_n) & !c_rip & !a_wip)
                begin
                  if (cfgi_write & !cfgi_trdy)
                    begin
                      nxt_cfgi_trdy = 1;
                      ram_nce = 0;
                      ram_nwrt = 0;
                      ram_addr = cfgi_addr[mem_asz-1:0];
                      ram_din = cfgi_wr_data;
                      // invalidate caches as precaution
                      nxt_cvld = 0;
                      nxt_wcvld = 0;
                    end
                  else if (!cfgi_write & !cfgi_trdy)
                    begin
                      ram_nce = 0;
                      ram_addr = cfgi_addr[mem_asz-1:0];
                      nxt_cfgi_trdy = 1;
                    end
                end
            end
        end // if (lcfg_init)      
    end // always @ *

  always @(posedge clk or negedge reset_n)
    begin
      if (~reset_n)
        begin
          ca_addr <= 13'h0;
          cvld    <= 0;
          /*AUTORESET*/
          // Beginning of autoreset for uninitialized flops
          a_prio <= 1'h0;
          a_rip <= 1'h0;
          a_wip <= 1'h0;
          b_rip <= 1'h0;
          ca_data <= 32'h0;
          cfgi_trdy <= 1'h0;
          wc_addr <= {mem_asz{1'b0}};
          wc_data <= 32'h0;
          wcvld <= 1'h0;
          // End of automatics
        end
      else
        begin
          cvld    <= nxt_cvld;
          ca_addr <= nxt_ca_addr;
          ca_data <= nxt_ca_data;
          wcvld   <= nxt_wcvld;
          wc_addr <= nxt_wc_addr;
          wc_data <= nxt_wc_data;
          a_prio  <= nxt_a_prio;
          a_rip   <= nxt_a_rip;
          b_rip   <= nxt_b_rip;
          a_wip   <= nxt_a_wip;
          cfgi_trdy <= nxt_cfgi_trdy;
        end
    end  

endmodule // memcontrol

// Local Variables:
// verilog-library-files:(".")
// End:

