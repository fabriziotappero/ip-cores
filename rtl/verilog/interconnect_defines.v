//
// Interrupts
//
`define APP_INT_RES1        1:0
`define APP_INT_UART        2
`define APP_INT_RES2        3
`define APP_INT_ETH         4
`define APP_INT_PS2         5
`define APP_INT_JSP         6
`define APP_INT_RES3        19:7

//
// Address map
//
`define APP_ADDR_DEC_W      8
`define APP_ADDR_SRAM       `APP_ADDR_DEC_W'h00
`define APP_ADDR_FLASH      `APP_ADDR_DEC_W'h04
`define APP_ADDR_DECP_W     4
`define APP_ADDR_PERIP      `APP_ADDR_DECP_W'h9
`define APP_ADDR_SPI        `APP_ADDR_DEC_W'h97
`define APP_ADDR_ETH        `APP_ADDR_DEC_W'h92
`define APP_ADDR_AUDIO      `APP_ADDR_DEC_W'h9d
`define APP_ADDR_UART       `APP_ADDR_DEC_W'h90
`define APP_ADDR_PS2        `APP_ADDR_DEC_W'h94
`define APP_ADDR_JSP        `APP_ADDR_DEC_W'h9e
`define APP_ADDR_RES2       `APP_ADDR_DEC_W'h9f
