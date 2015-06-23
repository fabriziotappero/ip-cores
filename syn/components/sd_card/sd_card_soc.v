
module sd_card_soc(
    input                       CLOCK_50,
    
    output                      SD_CLK,
    inout                       SD_CMD,
    inout            [3:0]      SD_DAT,
    input                       SD_WP_N
);

wire clk_40;
wire reset_n;

pll pll_inst(
    .inclk0         (CLOCK_50),
    .c0             (clk_40),
    .locked         (reset_n)
);

soc u0 (
    .clk_clk       (clk_40),
    .reset_reset_n (reset_n),
    .sd_card_clk   (SD_CLK),
    .sd_card_dat   (SD_DAT),
    .sd_card_cmd   (SD_CMD)
);

endmodule
