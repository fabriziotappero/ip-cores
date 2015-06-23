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
//  Local Configuration Processor Application
//----------------------------------------------------------------------

module lcfg
  (input         clk,
   input         reset_n,
   input         lcfg_init,  // initialize memory to all 0
   input         lcfg_proc_reset,

   // incoming config interface to 
   // read/write processor memory
   input         cfgi_irdy,
   output        cfgi_trdy,
   input [12:0]  cfgi_addr,
   input         cfgi_write,
   input [31:0]  cfgi_wr_data,
   output [31:0] cfgi_rd_data,

   // outgoing config interface to system
   // configuration bus
   output        cfgo_irdy,
   input         cfgo_trdy,
   output [15:0] cfgo_addr,
   output        cfgo_write,
   output [31:0] cfgo_wr_data,
   input [31:0]  cfgo_rd_data

   );

  wire [15:0] 	 addr;
  wire [7:0] 	 dout;
  reg [7:0] 	 di;
  wire 		 mreq_n;
  wire           rd_n, wr_n;
  wire           iorq_n;

  reg            fw_mode;
  wire           ram_wait_n;

  wire           fw_en = (addr[15:13] == {1'b0, !fw_mode, 1'b0}) && !mreq_n;
  wire 		 fw_we = !wr_n;

  wire [7:0] 	 ram_rd_data;  
  reg 		 last_wait;
  reg 		 wait_n;

  wire [7:0]     reg_addr1, reg_addr0;
  wire [7:0]     reg_wr_data3;
  wire [7:0]     reg_wr_data2;
  wire [7:0]     reg_wr_data1;
  wire [7:0]     reg_wr_data0;
  wire [7:0]     cb_rd_data;
  wire [1:0]     cb_control;
  reg [1:0]      cb_control_clr;
  wire [7:0]     tim_rd_data;
  wire [1:0]     fw_up_ctrl;
  wire           dma_iorq_n;
  wire [7:0]     dma_rd_data;
  reg [31:0]     read_hold;
  reg            read_latch;
  wire           proc_reset_n;
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [7:0]            cd_rdata;               // From cfgo_driver of lcfg_cfgo_driver.v
  wire                  cfgo_wait_n;            // From cfgo_driver of lcfg_cfgo_driver.v
  // End of automatics
  wire           ram_mreq_n;

  assign ram_mreq_n = ~ (~mreq_n & ~addr[15]);
  assign         proc_reset_n = ~lcfg_proc_reset;

  tv80s tv80 (
     // Outputs
     .dout                              (dout),
     .m1_n				(),
     .mreq_n				(mreq_n),
     .iorq_n				(iorq_n),
     .rd_n				(rd_n),
     .wr_n				(wr_n),
     .rfsh_n				(),
     .halt_n				(),
     .busak_n				(),
     .A					(addr),
     // Inputs
     .reset_n				(proc_reset_n),
     .clk				(clk),
     .wait_n				(wait_n),
     .int_n				(1'b1),
     .nmi_n				(1'b1),
     .busrq_n				(1'b1),
     .di				(di));

  always @(posedge clk)
    begin
      last_wait <= #1 wait_n;
    end
  
  always @*
    begin
      wait_n = 1;
      
      if (!mreq_n)
	begin
	  if (~ram_mreq_n)
            begin
	      di = ram_rd_data[7:0];
              wait_n = ram_wait_n;
            end
	  else
            begin
	      di = 8'h0;
            end
	end
      else if (!iorq_n)
	begin
          if (addr[7:3] == 0)
            begin
              di = cd_rdata;
              wait_n = cfgo_wait_n;
            end
	  else
	    di = 8'h0;
	end
      else
	di = 8'h0;
    end // always @ *
  
/*  lcfg_memctl AUTO_TEMPLATE
    (
     // Outputs
     .a_mreq_n                          (ram_mreq_n),
     .a_rd_n                            (rd_n),
     .a_wr_n                            (wr_n),
     .a_addr                            (addr[14:0]),
     .a_wdata                           (dout),
     .a_wait_n                          (ram_wait_n),
     .a_rdata                           (ram_rd_data),
 
     .b_wait_n				(),
     .b_rdata				(),
     .b_mreq_n				(1'b1),
     .b_wr_n				(1'b1),
     .b_addr				(13'h0),
     .b_wdata				(32'h0),
 
    );
*/
  lcfg_memctl #(.mem_asz(13)) memctl
    (/*AUTOINST*/
     // Outputs
     .a_wait_n                          (ram_wait_n),            // Templated
     .a_rdata                           (ram_rd_data),           // Templated
     .b_wait_n                          (),                      // Templated
     .b_rdata                           (),                      // Templated
     .cfgi_trdy                         (cfgi_trdy),
     .cfgi_rd_data                      (cfgi_rd_data[31:0]),
     // Inputs
     .clk                               (clk),
     .reset_n                           (reset_n),
     .a_mreq_n                          (ram_mreq_n),            // Templated
     .a_rd_n                            (rd_n),                  // Templated
     .a_wr_n                            (wr_n),                  // Templated
     .a_addr                            (addr[14:0]),            // Templated
     .a_wdata                           (dout),                  // Templated
     .b_mreq_n                          (1'b1),                  // Templated
     .b_wr_n                            (1'b1),                  // Templated
     .b_addr                            (13'h0),                 // Templated
     .b_wdata                           (32'h0),                 // Templated
     .lcfg_init                         (lcfg_init),
     .cfgi_irdy                         (cfgi_irdy),
     .cfgi_addr                         (cfgi_addr[12:0]),
     .cfgi_write                        (cfgi_write),
     .cfgi_wr_data                      (cfgi_wr_data[31:0]));
 

/* lcfg_cfgo_driver AUTO_TEMPLATE
 (
     .cd_wdata                          (dout[7:0]),
 );
 */
  lcfg_cfgo_driver #(.io_base_addr(8'h0)) cfgo_driver
    (/*AUTOINST*/
     // Outputs
     .cd_rdata                          (cd_rdata[7:0]),
     .cfgo_wait_n                       (cfgo_wait_n),
     .cfgo_irdy                         (cfgo_irdy),
     .cfgo_addr                         (cfgo_addr[15:0]),
     .cfgo_write                        (cfgo_write),
     .cfgo_wr_data                      (cfgo_wr_data[31:0]),
     // Inputs
     .clk                               (clk),
     .reset_n                           (reset_n),
     .addr                              (addr[15:0]),
     .cd_wdata                          (dout[7:0]),             // Templated
     .rd_n                              (rd_n),
     .wr_n                              (wr_n),
     .iorq_n                            (iorq_n),
     .cfgo_trdy                         (cfgo_trdy),
     .cfgo_rd_data                      (cfgo_rd_data[31:0]));

endmodule
