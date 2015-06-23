
module vga_test(
    input               CLOCK_50,
    
    //vga
    output              VGA_CLK,
    output              VGA_SYNC_N,
    output              VGA_BLANK_N,
    output              VGA_HS,
    output              VGA_VS,
    
    output      [7:0]   VGA_R,
    output      [7:0]   VGA_G,
    output      [7:0]   VGA_B
);

wire reset_n;
wire clk_26;

pll pll_inst(
    .inclk0     (CLOCK_50),
             
    .c0         (clk_26),
    .locked     (reset_n)
);


vga_soc u0 (
    .clk_50_clk            (CLOCK_50),
    .clk_26_clk            (clk_26),
    .reset_26_reset_n      (reset_n),
    .reset_50_reset_n      (reset_n),
    
    .vga_export_clock      (VGA_CLK),
    .vga_export_sync_n     (VGA_SYNC_N),
    .vga_export_blank_n    (VGA_BLANK_N),
    .vga_export_horiz_sync (VGA_HS),
    .vga_export_vert_sync  (VGA_VS),
    .vga_export_r          (VGA_R),
    .vga_export_g          (VGA_G),
    .vga_export_b          (VGA_B)
);

endmodule
