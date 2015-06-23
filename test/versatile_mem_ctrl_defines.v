//=tab Main

//=comment Select number of <b>WB Groups</b>

// Number of WB groups
//=select
//`define WB_GRPS_1 // 1
//`define WB_GRPS_2 // 2
`define WB_GRPS_3 // 3
//`define WB_GRPS_4 // 4
//`define WB_GRPS_5 // 5
//`define WB_GRPS_6 // 6
//`define WB_GRPS_7 // 7
//`define WB_GRPS_8 // 8
//=end

`ifdef WB_GRPS_2
    `define WB_GRPS_1
    `define NR_OF_WB_GRPS 2
    `define NR_OF_PORTS 2
`endif
`ifdef WB_GRPS_3
    `define WB_GRPS_1
    `define WB_GRPS_2
    `define NR_OF_WB_GRPS 3
    `define NR_OF_PORTS 3
`endif
`ifdef WB_GRPS_4
    `define WB_GRPS_1
    `define WB_GRPS_2
    `define WB_GRPS_3
    `define NR_OF_WB_GRPS 4
    `define NR_OF_PORTS 4
`endif
`ifdef WB_GRPS_5
    `define WB_GRPS_1
    `define WB_GRPS_2
    `define WB_GRPS_3
    `define WB_GRPS_4
    `define NR_OF_WB_GRPS 5
    `define NR_OF_PORTS 5
`endif
`ifdef WB_GRPS_6
    `define WB_GRPS_1
    `define WB_GRPS_2
    `define WB_GRPS_3
    `define WB_GRPS_4
    `define WB_GRPS_5
    `define NR_OF_WB_GRPS 6
    `define NR_OF_PORTS 6
`endif
`ifdef WB_GRPS_7
    `define WB_GRPS_1
    `define WB_GRPS_2
    `define WB_GRPS_3
    `define WB_GRPS_4
    `define WB_GRPS_5
    `define WB_GRPS_6
    `define NR_OF_WB_GRPS 7
    `define NR_OF_PORTS 7
`endif
`ifdef WB_GRPS_8
    `define WB_GRPS_1
    `define WB_GRPS_2
    `define WB_GRPS_3
    `define WB_GRPS_4
    `define WB_GRPS_5
    `define WB_GRPS_6
    `define WB_GRPS_7
    `define NR_OF_WB_GRPS 8
    `define NR_OF_PORTS 8
`endif

//=comment Clock domain settings

// Clock domain crossing WB1
//=select
//`define WB1_MEM_CLK // mem clk domain
`define WB1_CLK // wb1 clk domain
//=end
// Clock domain crossing WB1
//=select
//`define WB2_MEM_CLK // mem clk domain
`define WB2_CLK // wb2 clk domain
//=end
// Clock domain crossing WB1
//=select
`define WB3_MEM_CLK // mem clk domain
//`define WB3_CLK // wb3 clk domain
//=end
// Clock domain crossing WB1
//=select
//`define WB4_MEM_CLK // mem clk domain
`define WB4_CLK // wb4 clk domain
//=end
// Clock domain crossing WB1
//=select
//`define WB5_MEM_CLK // mem clk domain
`define WB5_CLK // wb5 clk domain
//=end
// Clock domain crossing WB1
//=select
//`define WB6_MEM_CLK // mem clk domain
`define WB6_CLK // wb6 clk domain
//=end
// Clock domain crossing WB1
//=select
//`define WB7_MEM_CLK // mem clk domain
`define WB7_CLK // wb7 clk domain
//=end
// Clock domain crossing WB1
//=select
//`define WB8_MEM_CLK // mem clk domain
`define WB8_CLK // wb8 clk domain
//=end

//=comment Misc. settings

// Module base name
`define BASE versatile_mem_ctrl_

// Memory type
//=select
//`define RAM // RAM
//`define SDR // SDR
//`define DDR2 // DDR2
`define DDR3 // DDR3
//=end

// Shadow RAM
`define SHADOW_RAM

//=tab RAM
// Number of bits in address
`define RAM_ADR_SIZE 16
// Capacity in KBytes
`define RAM_MEM_SIZE_KB 48
`ifdef RAM_MEM_SIZE_KB
`define RAM_MEM_SIZE `RAM_MEM_SIZE_KB*1024
`endif

// Memory init
`define RAM_MEM_INIT_DUMMY
`ifndef RAM_MEM_INIT_DUMMY
    `define RAM_MEM_INIT 0
`else
    `define RAM_MEM_INIT 1
`endif

// Memory init file
`define RAM_MEM_INIT_FILE "ram_init.v"

`ifdef RAM
`define WB_ADR_SIZE `RAM_ADR_SIZE
`endif
`ifdef SHADOW_RAM
`define WB_RAM_ADR_SIZE `RAM_ADR_SIZE
`endif
//=tab SDR SDRAM

// External data bus size
`define SDR_EXT_DAT_SIZE 16

// Memory part
//=select Memory part
//`define MT48LC4M16 // Micron 4M16, 8MB
`define MT48LC16M16 // Micron 16M16, 32MB
//`define MT48LC32M16 // Micron 32M16, 64MB
//=end

// SDRAM clock frequency
// set refresh counter timeout
// all rows should be refreshed every 64 ms
// SDRAM CLK frequency
//=select SDRAM CLK
`define SDR_SDRAM_CLK_64 // SDRAM_CLK_64
//`define SDR_SDRAM_CLK_75 // SDRAM_CLK_75
//`define SDR_SDRAM_CLK_125 // SDRAM_CLK_125
//`define SDR_SDRAM_CLK_133 // SDRAM_CLK_133
//`define SDR_SDRAM_CLK_154 // SDRAM_CLK_154
//=end

`ifdef MT48LC4M16
// using 1 of MT48LC4M16
// SDRAM data width is 16
`define SDR_SDRAM_DATA_WIDTH 16
`define SDR_SDRAM_DATA_WIDTH_16
`define SDR_COL_SIZE 8
`define SDR_ROW_SIZE 12
`define SDR_ROW_SIZE_12
`define SDR_BA_SIZE 2
`endif //  `ifdef MT48LC4M16

`ifdef MT48LC16M16
// using 1 of MT48LC16M16
// SDRAM data width is 16
`define SDR_SDRAM_DATA_WIDTH 16
`define SDR_SDRAM_DATA_WIDTH_16
`define SDR_COL_SIZE 9
`define SDR_ROW_SIZE 13
`define SDR_ROW_SIZE_13
`define SDR_BA_SIZE 2
`endif //  `ifdef MT48LC16M16

`ifdef MT48LC32M16
// using 1 of MT48LC32M16
// SDRAM data width is 16
`define SDR_SDRAM_DATA_WIDTH 16
`define SDR_SDRAM_DATA_WIDTH_16
`define SDR_COL_SIZE 10
`define SDR_ROW_SIZE 13
`define SDR_ROW_SIZE_13
`define SDR_BA_SIZE 2
`endif //  `ifdef MT48LC16M16

// Refresh whole memory every 64 ms
// Refresh each row every 64 ms
// refresh timeout = 64 ms / Tperiod / number_of_rows

// 64 MHz, row_size=12
// 64ms / (1/64MHz) / 2^12 = 1000
// ./VersatileCounter.php 10 1000
// 0101100100

`ifdef SDR_SDRAM_CLK_64
    `ifdef SDR_ROW_SIZE_12
        `define SDR_RFR_LENGTH 10
        `define SDR_RFR_WRAP_VALUE 0101100100
    `endif
    `ifdef SDR_ROW_SIZE_13
        `define SDR_RFR_LENGTH 9
        `define SDR_RFR_WRAP_VALUE 001000011
    `endif
`endif
`ifdef SDR_SDRAM_CLK_75
    `ifdef SDR_ROW_SIZE_12
        `define SDR_RFR_LENGTH 11
        `define SDR_RFR_WRAP_VALUE 00110001101
    `endif
    `ifdef SDR_ROW_SIZE_13
        `define SDR_RFR_LENGTH 10
        `define SDR_RFR_WRAP_VALUE 0110111101
    `endif
`endif
`ifdef SDR_SDRAM_CLK_125
    `ifdef SDR_ROW_SIZE_12
        `define SDR_RFR_LENGTH 11
        `define SDR_RFR_WRAP_VALUE 10001000001
    `endif
    `ifdef SDR_ROW_SIZE_13
        `define SDR_RFR_LENGTH 10
        `define SDR_RFR_WRAP_VALUE 1010000111
    `endif
`endif
`ifdef SDR_SDRAM_CLK_133
    `ifdef SDR_ROW_SIZE_12
        `define SDR_RFR_LENGTH 12
        `define SDR_RFR_WRAP_VALUE 101100000111
    `endif
    `ifdef SDR_ROW_SIZE_13
        `define SDR_RFR_LENGTH 11
        `define SDR_RFR_WRAP_VALUE 11111111010
    `endif
`endif
`ifdef SDR_SDRAM_CLK_154
    `ifdef SDR_ROW_SIZE_12
        `define SDR_RFR_LENGTH 12
        `define SDR_RFR_WRAP_VALUE 000101011110
    `endif
    `ifdef SDR_ROW_SIZE_13
        `define SDR_RFR_LENGTH 11
        `define SDR_RFR_WRAP_VALUE 00111101010
    `endif
`endif


// Disable burst
//`define SDR_NO_BURST
// Enable 4 beat wishbone busrt
`define SDR_BEAT4
// Enable 8 beat wishbone busrt
`define SDR_BEAT8
// Enable 16 beat wishbone busrt
`define SDR_BEAT16

// tRFC
`define SDR_TRFC 9
// tRP
`define SDR_TRP 2
// tRCD
`define SDR_TRCD 2
// tMRD
`define SDR_TMRD 2

// LMR
// [12:10] reserved
// [9]     WB, write burst; 0 - programmed burst length, 1 - single location
// [8:7]   OP Mode, 2'b00
// [6:4]   CAS Latency; 3'b010 - 2, 3'b011 - 3
// [3]     BT, Burst Type; 1'b0 - sequential, 1'b1 - interleaved
// [2:0]   Burst length; 3'b000 - 1, 3'b001 - 2, 3'b010 - 4, 3'b011 - 8, 3'b111 - full page
// LMR: Write burst
`define SDR_INIT_WB 1'b0
// LMR: CAS latency
`define SDR_INIT_CL 3'b010
// LMR: Burst type
`define SDR_INIT_BT 1'b0
// LMR: Burst length
`define SDR_INIT_BL 3'b001

`ifdef SDR
    `ifdef SDR_SDRAM_DATA_WIDTH_16
        `define WB_ADR_SIZE `SDR_BA_SIZE+`SDR_COL_SIZE+`SDR_ROW_SIZE+1
    `endif
`endif

//=tab DDR2 SDRAM

// Use existing Avalon compatible IP
`define DDR2_AVALON
// IP module name
`define DDR2_IP_NAME ALTERA_DDR2

`ifdef DDR2
`define WB_ADR_SIZE 24
`endif

//=tab DDR3 SDRAM

// Board
//=select
`define DDR3_BOARD_2AGX125N // ARRIAII BOARD 2AGX125N
//=end
`ifdef DDR3
`ifdef DDR3_BOARD_2AGX125N
`define WB_ADR_SIZE 30
`endif
`endif
