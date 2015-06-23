////////////////////////////////////////////////////////////////////////////////
// This sourcecode is released under BSD license.
// Please see http://www.opensource.org/licenses/bsd-license.php for details!
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2011, Stefan Fischer <Ste.Fis@OpenCores.org>
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
// filename: avnet_sp3a_eval_uart_vlog.v
// description: synthesizable PicoBlaze (TM) uart example using wishbone /
//              AVNET (R) Sp3A-Eval-Kit version
// todo4user: add other modules as needed
// version: 0.0.0
// changelog: - 0.0.0, initial release
//            - ...
////////////////////////////////////////////////////////////////////////////////


module avnet_sp3a_eval_uart_vlog (
  FPGA_RESET,
  CLK_16MHZ,
  
  UART_TXD,
  UART_RXD,
  
  LED1
);

  input FPGA_RESET;
  wire  FPGA_RESET;
  input CLK_16MHZ;
  wire  CLK_16MHZ;
  
  input UART_TXD;
  wire  UART_TXD;
  output UART_RXD;
  wire   UART_RXD;

  output LED1;
  wire   LED1;

  reg rst;
  wire clk;
  
  wire wb_cyc;
  wire wb_stb;
  wire wb_we;
  wire[7:0] wb_adr;
  wire[7:0] wb_dat_m2s;
  wire[7:0] wb_dat_s2m;
  wire wb_ack;
  
  wire pb_write_strobe;
  wire pb_read_strobe;
  wire[7:0] pb_port_id;
  wire[7:0] pb_in_port;
  wire[7:0] pb_out_port;
  
  wire[17:0] instruction;
  wire[9:0] address;
  
  wire interrupt;
  wire interrupt_ack;
  
  reg[23:0] timer;
  
  wire dcm_locked;
  
  // 50 mhz clock generation
  DCM_SP # ( 
    .CLK_FEEDBACK("NONE"), 
    .CLKDV_DIVIDE(2.0), 
    .CLKFX_DIVIDE(8), 
    .CLKFX_MULTIPLY(25), 
    .CLKIN_DIVIDE_BY_2("FALSE"), 
    .CLKIN_PERIOD(62.500), 
    .CLKOUT_PHASE_SHIFT("NONE"), 
    .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), 
    .DFS_FREQUENCY_MODE("LOW"), 
    .DLL_FREQUENCY_MODE("LOW"), 
    .DUTY_CYCLE_CORRECTION("TRUE"), 
    .FACTORY_JF(16'hC080), 
    .PHASE_SHIFT(0), 
    .STARTUP_WAIT("FALSE") 
  ) 
  DCM_SP_INST (
    .CLKFB(1'B0), 
    .CLKIN(CLK_16MHZ), 
    .DSSEN(1'B0), 
    .PSCLK(1'B0), 
    .PSEN(1'B0), 
    .PSINCDEC(1'B0), 
    .RST(FPGA_RESET), 
    .CLKDV(), 
    .CLKFX(clk), 
    .CLKFX180(), 
    .CLK0(), 
    .CLK2X(), 
    .CLK2X180(), 
    .CLK90(), 
    .CLK180(), 
    .CLK270(), 
    .LOCKED(dcm_locked), 
    .PSDONE(), 
    .STATUS()
  );
  
  // reset synchronisation
  always@(negedge dcm_locked or posedge clk)
    if (! dcm_locked)
      rst <= 1'b1;
    else
      rst <= ! dcm_locked;
  
  // module instances
  ///////////////////
    
  kcpsm3 inst_kcpsm3 (
    .address(address),
    .instruction(instruction),
    .port_id(pb_port_id),
    .write_strobe(pb_write_strobe),
    .out_port(pb_out_port),
    .read_strobe(pb_read_strobe),
    .in_port(pb_in_port),
    .interrupt(interrupt),
    .interrupt_ack(interrupt_ack),
    .reset(rst),
    .clk(clk)
  );

  pbwbuart inst_pbwbuart (
    .address(address),
    .instruction(instruction),
    .clk(clk)
  );

  wbm_picoblaze inst_wbm_picoblaze (
    .rst(rst),
    .clk(clk),
    
    .wbm_cyc_o(wb_cyc),
    .wbm_stb_o(wb_stb),
    .wbm_we_o(wb_we),
    .wbm_adr_o(wb_adr),
    .wbm_dat_m2s_o(wb_dat_m2s),
    .wbm_dat_s2m_i(wb_dat_s2m),
    .wbm_ack_i(wb_ack),
    
    .pb_port_id_i(pb_port_id),
    .pb_write_strobe_i(pb_write_strobe),
    .pb_out_port_i(pb_out_port),
    .pb_read_strobe_i(pb_read_strobe),
    .pb_in_port_o(pb_in_port)
  );

  wbs_uart inst_wbs_uart (
    .rst(rst),
    .clk(clk),
    
    .wbs_cyc_i(wb_cyc),
    .wbs_stb_i(wb_stb),
    .wbs_we_i(wb_we),
    .wbs_adr_i(wb_adr),
    .wbs_dat_m2s_i(wb_dat_m2s),
    .wbs_dat_s2m_o(wb_dat_s2m),
    .wbs_ack_o(wb_ack),
    
    .uart_rx_si_i(UART_TXD),
    .uart_tx_so_o(UART_RXD)
  );
  
  assign LED1 = timer[23];
  
  always@(posedge clk) begin : led_blinker
    timer <= timer + 1;
    if (rst)
      timer <= {24{1'b0}};
  end
  
endmodule
