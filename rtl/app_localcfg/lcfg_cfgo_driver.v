/* Copyright (c) 2011, Guy Hutchison
   All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

module lcfg_cfgo_driver
  (/*AUTOARG*/
  // Outputs
  cd_rdata, cfgo_wait_n, cfgo_irdy, cfgo_addr, cfgo_write,
  cfgo_wr_data,
  // Inputs
  clk, reset_n, addr, cd_wdata, rd_n, wr_n, iorq_n, cfgo_trdy,
  cfgo_rd_data
  );

  parameter io_base_addr = 0;
  input          clk;
  input          reset_n;

  // TV80 processor interface
  input [15:0]   addr;
  output [7:0]   cd_rdata;
  input [7:0]    cd_wdata;
  
  input          rd_n, wr_n;
  input          iorq_n;
  output         cfgo_wait_n;

  // outgoing config interface to system
  // configuration bus
  output         cfgo_irdy;
  input          cfgo_trdy;
  output [15:0]  cfgo_addr;
  output         cfgo_write;
  output [31:0]  cfgo_wr_data;
  input [31:0]   cfgo_rd_data;

  wire           rf_irdy;
  wire           rf_write;
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [7:0]            cfg_addr0;              // From cfgo_regs of lcfg_cfgo_regs.v
  wire [7:0]            cfg_addr1;              // From cfgo_regs of lcfg_cfgo_regs.v
  wire [7:0]            cfg_data0_wr_data;      // From cfgo_regs of lcfg_cfgo_regs.v
  wire [7:0]            cfg_data1_wr_data;      // From cfgo_regs of lcfg_cfgo_regs.v
  wire [7:0]            cfg_data2_wr_data;      // From cfgo_regs of lcfg_cfgo_regs.v
  wire [7:0]            cfg_data3_wr_data;      // From cfgo_regs of lcfg_cfgo_regs.v
  wire [3:0]            rd_stb;                 // From cfgo_regs of lcfg_cfgo_regs.v, ...
  wire [3:0]            wr_stb;                 // From cfgo_regs of lcfg_cfgo_regs.v, ...
  // End of automatics

  parameter s_idle = 0, s_write = 1, s_read = 2, s_ack = 3;
  
  reg [31:0]     chold, nxt_chold;
  reg [3:0]      state, nxt_state;
  
  assign rf_irdy = !iorq_n & ((addr[7:0] & 8'hF8) == io_base_addr);
  assign rf_write = ~wr_n;
  assign cfgo_addr = { cfg_addr1, cfg_addr0 };
  assign cfgo_wr_data = chold;
  assign cfgo_irdy = state[s_write] | state[s_read];
  assign cfgo_write = state[s_write];

  always @*
    begin
      nxt_chold = chold;
      nxt_state = state;
      
      case (1'b1) /* verilator lint_off CASEINCOMPLETE */
        state[s_idle] :
          begin
            case (wr_stb)
              4'b0001 : nxt_chold[7:0] = cfg_data0_wr_data;
              4'b0010 : nxt_chold[15:8] = cfg_data1_wr_data;
              4'b0100 : nxt_chold[23:16] = cfg_data2_wr_data;
              4'b1000 : nxt_chold[31:24] = cfg_data3_wr_data;
            endcase // case (wr_stb)
  
            if (rd_stb[0])
              nxt_state = 1 << s_read;
            else if (wr_stb[3])
              nxt_state = 1 << s_write;
          end // case: state[s_idle]

        state[s_write] :
          begin
            if (cfgo_trdy)
              nxt_state = 1 << s_idle;
          end

        state[s_read] :
          begin
            if (cfgo_trdy)
              begin
                nxt_state = 1 << s_ack;
                nxt_chold = cfgo_rd_data;
              end
          end

        state[s_ack] :
          begin
            nxt_state = 1 << s_idle;
          end
      endcase // verilator lint_on CASEINCOMPLETE
    end // always @ *

  always @(posedge clk or negedge reset_n)
    begin
      if (~reset_n)
        begin
          state <= 1 << s_idle;
          chold <= 0;
        end
      else
        begin
          state <= nxt_state;
          chold <= nxt_chold;
        end
    end
  
/* lcfg_cfgo_regs AUTO_TEMPLATE
 (
     .rf_trdy                           (cfgo_wait_n),
     .rf_rd_data                        (cd_rdata[]),
     .rf_addr                           (addr[]),
     .rf_wr_data                        (cd_wdata[]),
     .cfg_data\([0-3]\)_rd_data         (chold[@"(+ (* 8 @) 7)":@"(* 8 @)"]),
     .cfg_data0_rd_data (chold[7:0]),
     .cfg_data1_rd_data (chold[15:8]),
     .cfg_data2_rd_data (chold[23:16]),
     .cfg_data3_rd_data (chold[31:24]),
     .cfg_data0_rd_ack                  (state[s_ack]),
     .cfg_status                        ({4'h0, state}),
     .cfg_data[1-3]_rd_ack              (1'b1),
     .cfg_data[0-3]_wr_ack              (state[s_idle]),
     .cfg_data\([0-3]\)_wr_stb          (wr_stb[\1]),
     .cfg_data\([0-3]\)_rd_stb          (rd_stb[\1]),
     .cfg_status ({4'h0,state}),
 );
 */
  lcfg_cfgo_regs cfgo_regs
    (/*AUTOINST*/
     // Outputs
     .rf_trdy                           (cfgo_wait_n),           // Templated
     .rf_rd_data                        (cd_rdata[7:0]),         // Templated
     .cfg_addr0                         (cfg_addr0[7:0]),
     .cfg_addr1                         (cfg_addr1[7:0]),
     .cfg_data0_wr_stb                  (wr_stb[0]),             // Templated
     .cfg_data0_rd_stb                  (rd_stb[0]),             // Templated
     .cfg_data0_wr_data                 (cfg_data0_wr_data[7:0]),
     .cfg_data1_wr_stb                  (wr_stb[1]),             // Templated
     .cfg_data1_rd_stb                  (rd_stb[1]),             // Templated
     .cfg_data1_wr_data                 (cfg_data1_wr_data[7:0]),
     .cfg_data2_wr_stb                  (wr_stb[2]),             // Templated
     .cfg_data2_rd_stb                  (rd_stb[2]),             // Templated
     .cfg_data2_wr_data                 (cfg_data2_wr_data[7:0]),
     .cfg_data3_wr_stb                  (wr_stb[3]),             // Templated
     .cfg_data3_rd_stb                  (rd_stb[3]),             // Templated
     .cfg_data3_wr_data                 (cfg_data3_wr_data[7:0]),
     // Inputs
     .clk                               (clk),
     .reset_n                           (reset_n),
     .rf_irdy                           (rf_irdy),
     .rf_write                          (rf_write),
     .rf_addr                           (addr[3:0]),             // Templated
     .rf_wr_data                        (cd_wdata[7:0]),         // Templated
     .cfg_data0_rd_data                 (chold[7:0]),            // Templated
     .cfg_data0_rd_ack                  (state[s_ack]),          // Templated
     .cfg_data0_wr_ack                  (state[s_idle]),         // Templated
     .cfg_data1_rd_data                 (chold[15:8]),           // Templated
     .cfg_data1_rd_ack                  (1'b1),                  // Templated
     .cfg_data1_wr_ack                  (state[s_idle]),         // Templated
     .cfg_data2_rd_data                 (chold[23:16]),          // Templated
     .cfg_data2_rd_ack                  (1'b1),                  // Templated
     .cfg_data2_wr_ack                  (state[s_idle]),         // Templated
     .cfg_data3_rd_data                 (chold[31:24]),          // Templated
     .cfg_data3_rd_ack                  (1'b1),                  // Templated
     .cfg_data3_wr_ack                  (state[s_idle]),         // Templated
     .cfg_status                        ({4'h0,state}));          // Templated
endmodule
