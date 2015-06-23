module tb_wb_lcd;

reg wb_clk_i;
reg wb_rst_i;
reg [31:0] wb_dat_i;
wire [31:0] wb_dat_o;
reg [31:0] wb_adr_i;
reg [3:0] wb_sel_i;
reg wb_we_i;
reg wb_cyc_i;
reg wb_stb_i;
wire wb_ack_o;
wire [3:0] SF_D;
wire LCD_E;
wire LCD_RS;
wire LCD_RW;

initial begin
    $from_myhdl(
        wb_clk_i,
        wb_rst_i,
        wb_dat_i,
        wb_adr_i,
        wb_sel_i,
        wb_we_i,
        wb_cyc_i,
        wb_stb_i
    );
    $to_myhdl(
        wb_dat_o,
        wb_ack_o,
        SF_D,
        LCD_E,
        LCD_RS,
        LCD_RW
    );
end

wb_lcd dut(
    wb_clk_i,
    wb_rst_i,
    wb_dat_i,
    wb_dat_o,
    wb_adr_i,
    wb_sel_i,
    wb_we_i,
    wb_cyc_i,
    wb_stb_i,
    wb_ack_o,
    SF_D,
    LCD_E,
    LCD_RS,
    LCD_RW
);

endmodule
