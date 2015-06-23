


module soc_peripherals(
                      input   [31:0]  peri_data_i,
                      output  [31:0]  peri_data_o,
                      input   [31:0]  peri_addr_i,
                      input   [3:0]   peri_sel_i,
                      input           peri_we_i,
                      input           peri_cyc_i,
                      input           peri_stb_i,
                      output          peri_ack_o,
                      output          peri_err_o,
                      output          peri_rty_o,
                      
                      output          uart_txd_0,
                      input           uart_rxd_0,
      
                      input           peri_clk_i, 
                      input           peri_rst_i
                    );
                     
                           
  //---------------------------------------------------
  // uart_0
  uart_top
    i_uart_top(
                .wb_clk_i(peri_clk_i),
                .wb_rst_i(peri_rst_i),
                .wb_adr_i(peri_addr_i[4:0]),
                .wb_dat_i(peri_data_i),
                .wb_dat_o(peri_data_o),
                .wb_we_i(peri_we_i),
                .wb_stb_i(peri_stb_i),
                .wb_cyc_i(peri_cyc_i),
                .wb_ack_o(peri_ack_o),
                .wb_sel_i(peri_sel_i),

                .int_o(),

                .stx_pad_o(uart_txd_0),
                .srx_pad_i(uart_rxd_0),

                .rts_pad_o(),
                .cts_pad_i(1'b0),
                .dtr_pad_o(),
                .dsr_pad_i(1'b0),
                .ri_pad_i(1'b0),
                .dcd_pad_i(1'b0)
              );
              
  //---------------------------------------------------
  // optputs
  assign peri_err_o = 1'b0;
  assign peri_rty_o = 1'b0;

endmodule

