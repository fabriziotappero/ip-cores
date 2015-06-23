//=tab Main

//=comment
//=comment Defines base part of module names
`define BASE vl_

//=comment Defines target technology
//=select
//`define GENERIC // GENERIC
`define ALTERA // ALTERA
//`define ACTEL // ACTEL
//=end

//=comment
//=comment Generate all modules
`define ALL


//=comment System Verilog
`define SYSTEMVERILOG

//=tab Clk and reset

//=comment Global buffer for high fanout signals
//`define GBUF
//`define SYNC_RST
//`define PLL

//=tab registers
//`define DFF
//`define DFF_ARRAY
//`define DFF_CE
//`define DFF_CE_CLEAR
//`define DF_CE_SET
//`define SPR
//`define SRP
//`define DFF_SR
//`define LATCH
//`define SHREG
//`define SHREG_CE
//`define DELAY
//`define DELAY_EMPTYFLAG
//`define PULSE2TOGGLE
//`define TOGGLE2PULSE
//`define SYNCHRONIZER
//`define CDC

//=tab Logic
//`define MUX_ANDOR
//`define MUX2_ANDOR
//`define MUX3_ANDOR
//`define MUX4_ANDOR
//`define MUX5_ANDOR
//`define MUX6_ANDOR
//`define PARITY
//`define SHIFT_UNIT_32
//`define LOGIC_UNIT

//=tab

//=tab IO
//`define IO_DFF_OE
//`define O_DFF
//`define O_DDR
//`define O_CLK

//=tab Counters
//=comment Binary counters
//`define CNT_BIN
//`define CNT_BIN_CE
//`define CNT_BIN_CLEAR
//`define CNT_BIN_CE_CLEAR
//`define CNT_BIN_CE_CLEAR_L1_L2
//`define CNT_BIN_CE_CLEAR_SET_REW
//`define CNT_BIN_CE_REW_L1
//`define CNT_BIN_CE_REW_ZQ_L1
//`define CNT_BIN_CE_REW_Q_ZQ_L1
//=comment Gray counters
//`define CNT_GRAY
//`define CNT_GRAY_CE
//`define CNT_GRAY_CE_BIN
//=comment LFSR counters
//`define CNT_LFSR_ZQ
//`define CNT_LFSR_CE
//`define CNT_LFSR_CE_CLEAR_Q
//`define CNT_LFSR_CE_Q
//`define CNT_LFSR_CE_ZQ
//`define CNT_LFSR_CE_Q_ZQ
//`define CNT_LFSR_CE_REW_L1
//=comment Shift register based counters
//`define CNT_SHREG_WRAP
//`define CNT_SHREG_CLEAR
//`define CNT_SHREG_CE_WRAP
//`define CNT_SHREG_CE_CLEAR
//`define CNT_SHREG_CE_CLEAR_WRAP

//=tab Memories
//`define ROM_INIT
//`define RAM
//`define RAM_BE
//`define DPRAM_1R1W
//`define DPRAM_2R1W
//`define DPRAM_1R2W
//`define DPRAM_2R2W
//`define DPRAM_BE_2R2W
//`define FIFO_1R1W_FILL_LEVEL_SYNC
//`define FIFO_2R2W_SYNC_SIMPLEX
//`define FIFO_CMP_ASYNC
//`define FIFO_1R1W_ASYNC
//`define FIFO_2R2W_ASYNC
//`define FIFO_2R2W_ASYNC_SIMPLEX
//`define REG_FILE

//=tab Wishbone
//`define WB3AVALON_BRIDGE
//`define WB3WB3_BRIDGE
//`define WB3_ARBITER_TYPE1
//`define WB_ADR_INC
//`define WB_RAM
//`define WB_SHADOW_RAM
//`define WB_B4_ROM
//`define WB_BOOT_ROM
//`define WB_DPRAM
//`define WB_CACHE
//`define WB_AVALON_BRIDGE
//`define WB_AVALON_MEM_CACHE
//`define WB_SDR_SDRAM_CTRL

//=tab Arithmetic
//`define MULTS
//`define MULTS18X18
//`define MULT
//`define ARITH_UNIT
//`define COUNT_UNIT
//`define EXT_UNIT

///////////////////////////////////////
// dependencies
///////////////////////////////////////

`ifdef PLL
`ifndef SYNC_RST
`define SYNC_RST
`endif
`endif

`ifdef SYNC_RST
`ifndef GBUF
`define GBUF
`endif
`endif

`ifdef WB_SDR_SDRAM_CTRL
`ifndef WB_SHADOW_RAM
`define WB_SHADOW_RAM
`endif
`ifndef WB_CACHE
`define WB_CACHE
`endif
`ifndef WB_SDR_SDRAM
`define WB_SDR_SDRAM
`endif
`ifndef IO_DFF_OE
`define IO_DFF_OE
`endif
`ifndef O_DFF
`define O_DFF
`endif
`ifndef O_CLK
`define O_CLK
`endif
`endif

`ifdef WB_SDR_SDRAM
`ifndef CNT_SHREG_CLEAR
`define CNT_SHREG_CLEAR
`endif
`ifndef CNT_LFSR_ZQ
`define CNT_LFSR_ZQ
`endif
`ifndef DELAY_EMPTYFLAG
`define DELAY_EMPTYFLAG
`endif
`endif

`ifdef WB_DPRAM
`ifndef WB_ADR_INC
`define WB_ADR_INC
`endif
`ifndef DPRAM_BE_2R2W
`define DPRAM_BE_2R2W
`endif
`endif

`ifdef WB3_ARBITER_TYPE1
`ifndef SPR
`define SPR
`endif
`ifndef MUX_ANDOR
`define MUX_ANDOR
`endif
`endif

`ifdef WB3AVALON_BRIDGE
`ifndef WB3WB3_BRIDGE
`define WB3WB3_BRIDGE
`endif
`endif

`ifdef WB3WB3_BRIDGE
`ifndef CNT_SHREG_CE_CLEAR
`define CNT_SHREG_CE_CLEAR
`endif
`ifndef DFF
`define DFF
`endif
`ifndef DFF_CE
`define DFF_CE
`endif
`ifndef CNT_SHREG_CE_CLEAR
`define CNT_SHREG_CE_CLEAR
`endif
`ifndef FIFO_2R2W_ASYNC_SIMPLEX
`define FIFO_2R2W_ASYNC_SIMPLEX
`endif
`endif


`ifdef WB_AVALON_MEM_CACHE
`ifndef WB_SHADOW_RAM
`define WB_SHADOW_RAM
`endif
`ifndef WB_CACHE
`define WB_CACHE
`endif
`ifndef WB_AVALON_BRIDGE
`define WB_AVALON_BRIDGE
`endif
`endif

`ifdef WB_CACHE
`ifndef RAM
`define RAM
`endif
`ifndef WB_ADR_INC
`define WB_ADR_INC
`endif
`ifndef DPRAM_1R1W
`define DPRAM_1R1W
`endif
`ifndef DPRAM_1R2W
`define DPRAM_1R2W
`endif
`ifndef DPRAM_BE_2R2W
`define DPRAM_BE_2R2W
`endif
`ifndef CDC
`define CDC
`endif
`ifndef O_DFF
`define O_DFF
`endif
`ifndef O_CLK
`define O_CLK
`endif
`endif

`ifdef WB_SHADOW_RAM
`ifndef WB_RAM
`define WB_RAM
`endif
`endif

`ifdef WB_RAM
`ifndef WB_ADR_INC
`define WB_ADR_INC
`endif
`ifndef RAM_BE
`define RAM_BE
`endif
`endif

`ifdef MULTS18X18
`ifndef MULTS
`define MULTS
`endif
`endif

`ifdef SHIFT_UNIT_32
`ifndef MULTS
`define MULTS
`endif
`endif

`ifdef MUX2_ANDOR
`ifndef MUX_ANDOR
`define MUX_ANDOR
`endif
`endif

`ifdef MUX3_ANDOR
`ifndef MUX_ANDOR
`define MUX_ANDOR
`endif
`endif

`ifdef MUX4_ANDOR
`ifndef MUX_ANDOR
`define MUX_ANDOR
`endif
`endif

`ifdef MUX5_ANDOR
`ifndef MUX_ANDOR
`define MUX_ANDOR
`endif
`endif

`ifdef MUX6_ANDOR
`ifndef MUX_ANDOR
`define MUX_ANDOR
`endif
`endif

`ifdef FIFO_1R1W_FILL_LEVEL_SYNC
`ifndef CNT_BIN_CE
`define CNT_BIN_CE
`endif
`ifndef DPRAM_1R1W
`define DPRAM_1R1W
`endif
`ifndef CNT_BIN_CE_REW_Q_ZQ_L1
`define CNT_BIN_CE_REW_Q_ZQ_L1
`endif
`endif

`ifdef FIFO_1R1W_FILL_LEVEL_SYNC
`ifndef CNT_LFSR_CE
`define CNT_LFSR_CE
`endif
`ifndef DPRAM_2R2W
`define DPRAM_2R2W
`endif
`ifndef CNT_BIN_CE_REW_ZQ_L1
`define CNT_BIN_CE_REW_ZQ_L1
`endif
`endif

`ifdef FIFO_2R2W_ASYNC_SIMPLEX
`ifndef CNT_GRAY_CE_BIN
`define CNT_GRAY_CE_BIN
`endif
`ifndef DPRAM_2R2W
`define DPRAM_2R2W
`endif
`ifndef FIFO_CMP_ASYNC
`define FIFO_CMP_ASYNC
`endif
`endif

`ifdef FIFO_2R2W_ASYNC
`ifndef FIFO_1R1W_ASYNC
`define FIFO_1R1W_ASYNC
`endif
`endif

`ifdef FIFO_1R1W_ASYNC
`ifndef CNT_GRAY_CE_BIN
`define CNT_GRAY_CE_BIN
`endif
`ifndef DPRAM_1R1W
`define DPRAM_1R1W
`endif
`ifndef FIFO_CMP_ASYNC
`define FIFO_CMP_ASYNC
`endif
`endif

`ifdef FIFO_CMP_ASYNC
`ifndef DFF_SR
`define DFF_SR
`endif
`ifndef DFF
`define DFF
`endif
`endif

`ifdef REG_FILE
`ifndef DPRAM_1R1W
`define DPRAM_1R1W
`endif
`endif

`ifdef CDC
`ifndef PULSE2TOGGLE
`define PULSE2TOGGLE
`endif
`ifndef TOGGLE2PULSE
`define TOGGLE2PULSE
`endif
`ifndef SYNCHRONIZER
`define SYNCHRONIZER
`endif
`endif

`ifdef O_CLK
`ifndef O_DDR
`define O_DDR
`endif
`endif

// size to width
//`define SIZE2WIDTH_EXPR
