`include "versatile_io_defines.v"
`ifdef B4
wire wbs_vio_stall_o;
`endif
`ifdef UART0
wire vio_uart0_irq;
`endif
`ifdef UART1
wire vio_uart1_irq;
`endif
