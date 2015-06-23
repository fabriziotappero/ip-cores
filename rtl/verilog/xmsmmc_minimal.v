//
// BootX-XMSMMC IP Core demonstration
// Minimal configuration - to show the absolute minimal resource useage
// This configuration uses 20 Macrocells in Xilinx XCR3032
// 
// Copyright 2004-2005 Openchip
// http://www.openchip.org
//
`include "mmc_boot_defines.v"

module xmsmmc_minimal( cclk, done, init, mmc_cmd, mmc_clk );

// Connect to FPGA CCLK, INIT, DONE
// Init and Done need an external PULLUP Resistor!
input  cclk;
input  init; 
input  done; 

// MMC Card DAT goes to FPGA DIN
// MMC Card CS (pin 1) tie high or leave floating
// Connect to MMC Card CMD and CLK
inout  mmc_cmd;
output mmc_clk;

// Instantiate XMSMMC IP
xmsmmc_core boot_i (
    .cclk    (   cclk    ), 
    .done    (   done    ), 
    .init    (   init    ), 
    .mmc_cmd (   mmc_cmd ), 
    .mmc_clk (   mmc_clk ), 
    .dis     (   1'b0    ),  // Tristate control not used
    .error   (           )   // Error output not used
    );

endmodule
