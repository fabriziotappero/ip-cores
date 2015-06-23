
module sd(
    input               CLOCK_50,
    
    //SDRAM
    output      [12:0]  DRAM_ADDR,
    output      [1:0]   DRAM_BA,
    output              DRAM_CAS_N,
    output              DRAM_CKE,
    output              DRAM_CLK,
    output              DRAM_CS_N,
    inout       [31:0]  DRAM_DQ,
    output      [3:0]   DRAM_DQM,
    output              DRAM_RAS_N,
    output              DRAM_WE_N,
    
    //SD
    output              SD_CLK,
    inout               SD_CMD,
    inout       [3:0]   SD_DAT,
    input               SD_WP_N
);

//------------------------------------------------------------------------------

assign DRAM_CLK = clk_sys;

//------------------------------------------------------------------------------

wire clk_sys;

wire rst_n;

pll pll_inst(
    .inclk0     (CLOCK_50),
    .c0         (clk_sys),
    .locked     (rst_n)
);

system u0 (
    .clk_clk          (clk_sys),
    .reset_reset_n    (rst_n),

    .sdram_wire_addr  (DRAM_ADDR),
    .sdram_wire_ba    (DRAM_BA),
    .sdram_wire_cas_n (DRAM_CAS_N),
    .sdram_wire_cke   (DRAM_CKE),
    .sdram_wire_cs_n  (DRAM_CS_N),
    .sdram_wire_dq    (DRAM_DQ),
    .sdram_wire_dqm   (DRAM_DQM),
    .sdram_wire_ras_n (DRAM_RAS_N),
    .sdram_wire_we_n  (DRAM_WE_N),
    
    .conduit_clk_export (SD_CLK),
    .conduit_cmd_export (SD_CMD),
    .conduit_dat_export (SD_DAT)
);

//------------------------------------------------------------------------------

endmodule
