////////////////////////////////////////////////////////////////////////////////
// This sourcecode is released under BSD license.
// Please see http://www.opensource.org/licenses/bsd-license.php for details!
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2010, Stefan Fischer <Ste.Fis@OpenCores.org>
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without 
// modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.
//
////////////////////////////////////////////////////////////////////////////////
// filename: wbs_gpio.v
// description: synthesizable wishbone slave general purpose i/o module
// todo4user: add more i/o ports as needed
// version: 0.0.0
// changelog: - 0.0.0, initial release
//            - ...
////////////////////////////////////////////////////////////////////////////////


module wbs_gpio (
  rst,
  clk,
  
  wbs_cyc_i,
  wbs_stb_i,
  wbs_we_i,
  wbs_adr_i,
  wbs_dat_m2s_i,
  wbs_dat_s2m_o,
  wbs_ack_o,
  
  gpio_in_i,
  gpio_out_o,
  gpio_oe_o
);

  input rst; 
  wire  rst;
  input clk; 
  wire  clk;
  
  input wbs_cyc_i;
  wire  wbs_cyc_i;
  input wbs_stb_i; 
  wire  wbs_stb_i;
  input wbs_we_i; 
  wire  wbs_we_i;
  input[7:0] wbs_adr_i; 
  wire [7:0] wbs_adr_i;
  input[7:0] wbs_dat_m2s_i;
  wire [7:0] wbs_dat_m2s_i;
  output[7:0] wbs_dat_s2m_o;
  reg   [7:0] wbs_dat_s2m_o;
  output wbs_ack_o;
  reg    wbs_ack_o;
  
  input[7:0] gpio_in_i;
  wire [7:0] gpio_in_i;
  output[7:0] gpio_out_o;
  reg   [7:0] gpio_out_o;
  output[7:0] gpio_oe_o;
  reg   [7:0] gpio_oe_o;

  wire wb_reg_we;
  
  reg[7:0] gpio_in;
  
  parameter IS_INPUT = 1'b0;
  parameter IS_OUTPUT = ! IS_INPUT;

  parameter ADDR_MSB = 0;
  parameter[7:0] GPIO_IO_ADDR = 8'h00;
  parameter[7:0] GPIO_OE_ADDR = 8'h01;
  
  // internal register write enable signal
  assign wb_reg_we = wbs_cyc_i && wbs_stb_i && wbs_we_i;
 
  always@(posedge clk) begin
  
    gpio_in <= gpio_in_i;
  
    wbs_dat_s2m_o <= 8'h00;
    // registered wishbone slave handshake
    wbs_ack_o <= wbs_cyc_i && wbs_stb_i && (! wbs_ack_o);
    
    case(wbs_adr_i[ADDR_MSB:0])
      // i/o register access
      GPIO_IO_ADDR[ADDR_MSB:0]: begin
        if (wb_reg_we)
          gpio_out_o <= wbs_dat_m2s_i;
        wbs_dat_s2m_o <= gpio_in;
      end
      // output enable register access
      GPIO_OE_ADDR[ADDR_MSB:0]: begin
        if (wb_reg_we)
          gpio_oe_o <= wbs_dat_m2s_i;
        wbs_dat_s2m_o <= gpio_oe_o;
      end
      default: ;
    endcase
  
    if (rst) begin
      wbs_ack_o <= 1'b0;
      gpio_oe_o <= {8{IS_INPUT}};
    end
      
  end

endmodule
