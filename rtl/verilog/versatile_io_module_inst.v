`include "versatile_io_defines.v"

versatile_io vio0 (
    .wbs_dat_i(wbs_vio_dat_i),
    .wbs_adr_i(wbs_vio_adr_i),
    .wbs_sel_i(wbs_vio_sel_i),
    .wbs_we_i(wbs_vio_we_i),
    .wbs_stb_i(wbs_vio_stb_i),
    .wbs_cyc_i(wbs_vio_cyc_i),
    .wbs_dat_o(wbs_vio_dat_o),
    .wbs_ack_o(wbs_vio_ack_o),
`ifdef B4
    .wbs_stall_o(wbs_vio_stall_o),
`endif
`ifdef UART0
    .uart0_rx_pad_i(uart0_rx_pad_i),
    .uart0_tx_pad_o(uart0_tx_pad_o),
    .uart0_irq(vio_uart0_irq),
`endif
`ifdef UART1
    .uart1_rx_pad_i(uart1_rx_pad_i),
    .uart1_tx_pad_o(uart1_tx_pad_o),
    .uart1_irq(vio_uart1_irq),
`endif
    .wbs_clk(wb_clk), .wbs_rst(wb_rst),
    .clk(clk33), .rst(rst33));
