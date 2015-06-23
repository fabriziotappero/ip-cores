//=tab Main
//=comment <b>Versatile IO</b>
//=tab UART
`define UART0
`define UART0_BASE_ADR 32'h90000000
`define UART0_MEM_MAP_HI 31
`define UART0_MEM_MAP_LO 24
`ifdef UART0
`define UART
`endif
//=comment
//`define UART1
`define UART1_BASE 32'h92100000
`define UART1_MEM_MAP_HI 31
`define UART1_MEM_MAP_LO 24
`ifdef UART1
`ifndef UART
`define UART
`endif
`endif
