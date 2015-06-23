`define BIG_ENDIAN
`define TIME_OUT_TIME 255

//OBS komihåg Master SEL to 1111 vid port dek

//`define SIM
`define SYN

`define ACTEL

`ifdef SYN
`define RESET_CLK_DIV 2
`define MEM_OFFSET 4
`endif

`ifdef SIM
`define RESET_CLK_DIV 0
`define MEM_OFFSET 1
`endif


//SD-Clock Defines ---------
//Use bus clock or a seperate external clock?
`define SD_CLK_BUS_CLK
//`define SD_CLK_EXT

// Use internal clock divider?
`define SD_CLK_STATIC
//`define SD_CLK_DYNAMIC


//SD DATA-transfer defines---
`define BLOCK_SIZE 512
`define SD_BUS_WIDTH_4
`define SD_BUS_W 4

//at 512 bytes per block, equal 1024 4 bytes writings with a bus width of 4, add 2 for startbit and Z bit.
//Add 18 for crc, endbit and z.
`define BIT_BLOCK 1044
`define CRC_OFF 19
`define BIT_BLOCK_REC 1024

`define BIT_CRC_CYCLE 16

//FIFO defines---------------








