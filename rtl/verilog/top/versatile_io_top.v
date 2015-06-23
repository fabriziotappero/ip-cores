module versatile_io (
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    input [3:0] wbs_sel_i,
    input wbs_we_i, wbs_stb_i, wbs_cyc_i,
    output [31:0] wbs_dat_o,
    output wbs_ack_o,
`ifdef B4
    output wbs_stall_o,
`endif
`include "versatile_io_module.v"
`ifdef UART0
    output uart0_irq,
`endif
    input wbs_clk, wbs_rst,
    input clk, rst
);

wire [31:0] uart0_dat_o;
`ifdef UART0
parameter uart0_mem_map_hi = `UART0_MEM_MAP_HI;
parameter uart0_mem_map_lo = `UART0_MEM_MAP_LO;
parameter [31:0] uart0_base_adr = `UART0_BASE_ADR;
`endif
function [7:0] tobyte;
input [3:0] sel_i;
input [31:0] dat_i;
begin
    tobyte = ({8{sel_i[3]}} & dat_i[31:24]) | ({8{sel_i[2]}} & dat_i[23:16]) | ({8{sel_i[1]}} & dat_i[15:8]) | ({8{sel_i[0]}} & dat_i[7:0]);
end
endfunction

function [31:0] toword;
input [7:0] dat_i;
begin
    toword = {4{dat_i}};
end
endfunction

function [31:0] mask;
input [31:0] dat_i;
input sel;
begin
    mask = {32{sel}} & dat_i;
end
endfunction

`ifdef UART0
wire uart0_cs;
assign uart0_cs = wbs_adr_i[uart0_mem_map_hi:uart0_mem_map_lo] == uart0_base_adr[uart0_mem_map_hi:uart0_mem_map_lo];
wire [7:0] uart0_temp;
wire uart0_ack_o;
/*
uart_top uart0	(
    .wb_clk_i(wbs_clk), .wb_rst_i(wbs_rst), 	
    // Wishbone signals
    .wb_adr_i(wbs_adr_i[2:0]), .wb_dat_i(tobyte(wbs_sel_i,wbs_dat_i)), .wb_dat_o(uart0_temp), .wb_we_i(wbs_we_i), .wb_stb_i(wbs_stb_i), .wb_cyc_i(wbs_cyc_i & uart0_cs), .wb_ack_o(uart0_ack_o), .wb_sel_i(4'b0),
    .int_o(uart0_irq), // interrupt request
    // UART	signals
    // serial input/output
    .stx_pad_o(uart0_tx_pad_o), .srx_pad_i(uart0_rx_pad_i),
    // modem signals
    .rts_pad_o(), .cts_pad_i(1'b0), .dtr_pad_o(), .dsr_pad_i(1'b0), .ri_pad_i(1'b0), .dcd_pad_i(1'b0) );
*/
uart16750_wb uart0(
    // UART signals
    .rx(uart0_rx_pad_i),
    .tx(uart0_tx_pad_o),
    .irq(uart0_irq),
    // wishbone slave
    .wbs_dat_i(tobyte(wbs_sel_i,wbs_dat_i)),
    .wbs_adr_i(wbs_adr_i[2:0]),
    .wbs_we_i(wbs_we_i),
    .wbs_cyc_i(wbs_cyc_i & uart0_cs),
    .wbs_stb_i(wbs_stb_i),
    .wbs_dat_o(uart0_temp),
    .wbs_ack_o(uart0_ack_o),
    .wb_clk_i(wbs_clk),
    .wb_rst_i(wbs_rst) );
assign uart0_dat_o = mask( toword(uart0_temp), uart0_ack_o);
`else
assign uart0_dat_o = 32'h0;
assign uart0_ack_o = 1'b0;
`endif

assign wbs_dat_o = uart0_dat_o;
assign wbs_ack_o = uart0_ack_o;
`ifdef WB4
assign wbs_stall_o = 1'b0;
`endif

endmodule
