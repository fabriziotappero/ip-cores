`define DAT_O _dat_o
`define ADR_O _adr_o
`define SEL_O _sel_o
`define CTI_O _cti_o
`define BTE_O _bte_o
`define WE_O _we_o
`define STB_O _stb_o
`define CYC_O _cyc_o
`define STALL_I _stall_i
`define DAT_I _dat_i
`define ACK_I _ack_i
`ifndef DAT_WIDTH
`define DAT_WIDTH 32
`endif
`ifndef ADR_WIDTH
`define ADR_WIDTH 30
`endif
wire [`DAT_WIDTH-1:0] `WB`DAT_O;
wire [`ADR_WIDTH-1:0] `WB`ADR_O;
wire [`DAT_WIDTH/8-1:0] `WB`SEL_O;
wire [2:0] `WB`CTI_O;
wire [1:0] `WB`BTE_O;
wire `WB`WE_O;
wire `WB`STB_O;
wire `WB`CYC_O;
wire `WB`STALL_I;
wire [`DAT_WIDTH-1:0] `WB`DAT_I;
wire `WB`ACK_I;
`undef WB
`undef DAT_O
`undef ADR_O
`undef SEL_O
`undef CTI_O
`undef BTE_O
`undef WE_O
`undef STB_O
`undef CYC_O
`undef STALL_I
`undef DAT_I
`undef ACK_I
