//
// Functional Description:
//
// This has all defines used in TB
//
// *************************************************************************

// For Top level simulations
`define TB_TOP_LEVEL_SIM  1
`define TB_RAND_SEED      0

// RTL - Instance 
`define TB_TOP          tb_top
`define CHIP_TOP        `TB_TOP.chip_top
`define CORE            `TB_TOP.u_core

// TB - Global
`define TB_GLBL         `TB_TOP.tb_glbl

`define TB_AGENTS_GMAC  `TB_TOP.u_tb_eth
`define TB_AGENTS_UART  `TB_TOP.tb_uart


//--------------------------------------------------------------
// Target ID Mapping
// 4'b0100 -- MAC core
// 4'b0011 -- UART
// 4'b0010 -- SPI core
// 4'b0001 -- External RAM
// 4'b0000 -- External ROM
//--------------------------------------------------------------
`define ADDR_SPACE_MAC  4'b0100 
`define ADDR_SPACE_UART 4'b0011 
`define ADDR_SPACE_SPI  4'b0010 
`define ADDR_SPACE_RAM  4'b0001 
`define ADDR_SPACE_ROM  4'b0000 

