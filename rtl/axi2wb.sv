//Author     : Alex Zhang (cgzhangwei@gmail.com)
//Date       : 03-11-2015
`include "wb2axi_parameters.vh"
module axi2wb (
axi_clk,
wb_clk,
axi_resetn,
wb_resetn,
ENABLE,
AXI_IF,
WB_TX_IF
);
parameter AXI_ID_W         = `WB2AXI_AXI_ID_W   ;
parameter AXI_ADDR_W       = `WB2AXI_AXI_ADDR_W ;
parameter AXI_DATA_W       = `WB2AXI_AXI_DATA_W ;
parameter AXI_PROT_W       = `WB2AXI_AXI_PROT_W ;
parameter AXI_STB_W        = `WB2AXI_AXI_STB_W  ;
parameter AXI_LEN_W        = `WB2AXI_AXI_LEN_W  ;
parameter AXI_SIZE_W       = `WB2AXI_AXI_SIZE_W ;
parameter AXI_BURST_W      = `WB2AXI_AXI_BURST_W;
parameter AXI_LOCK_W       = `WB2AXI_AXI_LOCK_W ;
parameter AXI_CACHE_W      = `WB2AXI_AXI_CACHE_W;
parameter AXI_RESP_W       = `WB2AXI_AXI_RESP_W ;

parameter FIFO_ADDR_DEPTH_W = 10;
parameter FIFO_ADDR_W       = AXI_ID_W+AXI_ADDR_W+AXI_PROT_W+AXI_LEN_W+AXI_SIZE_W+AXI_BURST_W+AXI_LOCK_W+AXI_CACHE_W+1;
parameter FIFO_DATA_DEPTH_W = 11;
parameter FIFO_DATA_W       = AXI_ID_W+AXI_DATA_W+AXI_STB_W+2;

parameter WB_ADR_W          = 32;
parameter WB_DAT_W          = 32;
parameter WB_TGA_W          = 8;
parameter WB_TGD_W          = 8;
parameter WB_TGC_W          = 4;
parameter WB_SEL_W          = 4;
parameter WB_CTI_W          = 3;
parameter WB_BTE_W          = 2;

localparam SRAM_UNUSED_ADDR_W= 4;
localparam AXI_MAX_RESP_W    = 4;
localparam FA_SRAM_UNUSED_ADDR_W = 1;
localparam FD_SRAM_UNUSED_ADDR_W = 1;
input  wire             axi_clk;
input  wire             wb_clk;
input  wire             axi_resetn;
input  wire             wb_resetn;
input  wire             ENABLE;
axi_if.target           AXI_IF;
wishbone_if.master      WB_TX_IF;

sram_if #(.DATA_W(32), .ADDR_W(11))  dat_sram_tx();
sram_if #(.DATA_W(64), .ADDR_W(10))  adr_sram_tx();

wire                   sync_ENABLE_axi;
wire                   sync_ENABLE_wb ;
wire                   fifo_adr_full  ;
wire                   fifo_dat_full  ;
wire [FIFO_DATA_W-1:0] fifo_dat_rdata ;
wire [FIFO_ADDR_W-1:0] fifo_adr_rdata ;

sync_doble_ff #(.DATA_W(1)) I_SYNC_ENABLE_AXI (
  .CLK              (           axi_clk ),
  .RESET_N          (        axi_resetn ),
  .DIN              (            ENABLE ),
  .DOUT             (   sync_ENABLE_axi )
);
sync_doble_ff #(.DATA_W(1)) I_SYNC_ENABLE_WB (
  .CLK              (            wb_clk ),
  .RESET_N          (         wb_resetn ),
  .DIN              (            ENABLE ),
  .DOUT             (   sync_ENABLE_wb  )
);
wire [FIFO_ADDR_W-1:0]  fifo_addr_info;
wire [FIFO_DATA_W-1:0]  fifo_data_info;
wire                    fifo_addr_wr  ;
wire                    fifo_data_wr  ;
wire [FIFO_ADDR_W-1:0]  fifo_adr_wdata;
wire [FIFO_DATA_W-1:0]  fifo_dat_wdata;

axi_ingress #(
      .AXI_ID_W        (    AXI_ID_W    ),
      .AXI_ADDR_W      (    AXI_ADDR_W   ),
      .AXI_DATA_W      (    AXI_DATA_W   ),
      .AXI_PROT_W      (    AXI_PROT_W   ),
      .AXI_STB_W       (    AXI_STB_W    ),
      .AXI_LEN_W       (    AXI_LEN_W    ),
      .AXI_SIZE_W      (    AXI_SIZE_W   ),
      .AXI_BURST_W     (    AXI_BURST_W  ),
      .AXI_LOCK_W      (    AXI_LOCK_W   ),
      .AXI_CACHE_W     (    AXI_CACHE_W  ),
      .AXI_RESP_W      (    AXI_RESP_W   ),
      .AXI_MAX_RESP_W  ( AXI_MAX_RESP_W  ),
      .FIFO_DAT_W      (   FIFO_DATA_W   ),
      .FIFO_ADR_W      (   FIFO_ADDR_W   )
) I_AXI_INGRESS (
  .axi_clk        ( axi_clk       ),
  .reset_n        ( axi_resetn    ),
  .AXI_IF         ( AXI_IF        ),
  .fifo_full      ( fifo_full     ),
  .fifo_addr_info ( fifo_addr_info),
  .fifo_data_info ( fifo_data_info),
  .fifo_addr_wr   ( fifo_addr_wr  ),
  .fifo_data_wr   ( fifo_data_wr  )
);

assign fifo_full  = fifo_adr_full | fifo_dat_full;

async_fifo #(
  .FIFO_DEPTH_W      (FIFO_ADDR_DEPTH_W),
  .FIFO_W            (FIFO_ADDR_W),
  .SRAM_UNUSED_ADDR_W(FA_SRAM_UNUSED_ADDR_W)
) I_FIFO_ADR (
  .wrclk_RESET_N    (      axi_resetn ),
  .rdclk_RESET_N    (       wb_resetn ),
  .wr_en            ( sync_ENABLE_axi ),
  .rd_en            ( sync_ENABLE_wb  ),
  .fifo_wr_clk      (         axi_clk ),
  .fifo_rd_clk      (         wb_clk  ),
  .fifo_wr          (     fifo_adr_wr ),
  .fifo_rd          (     fifo_adr_rd ),
  .fifo_wdata       (  fifo_adr_wdata ),
  .fifo_rdata       (  fifo_adr_rdata ),
  .fifo_empty       (  fifo_adr_empty ),
  .fifo_full        (   fifo_adr_full ),
  .fifo_level       (                 ),
  .SRAM_IF          (     adr_sram_tx )
);
wire    adr_sram_enable;
wire    adr_sram_wr;
wire [FIFO_ADDR_W-1:0] adr_sram_din;
wire [FIFO_ADDR_W-1:0] adr_sram_dout;
wire [FIFO_ADDR_DEPTH_W-1:0] adr_sram_addr;
sram_model #(
  .MEM_ADDR_W  (FIFO_ADDR_DEPTH_W),
  .MEM_DATA_W  (FIFO_ADDR_W)
) SRAM_ADR_1phc1024x32mx4tn(
  .CLK(axi_clk        ),
  .NCE(adr_sram_enable),
  .NWRT(adr_sram_wr   ),
  .NOE(1'b0           ),
  .DIN(adr_sram_din   ),
  .ADDR(adr_sram_addr ),
  .DOUT(adr_sram_dout )
);
assign adr_sram_enable   = adr_sram_tx.rd_l | adr_sram_tx.wr_l;
assign adr_sram_wr       = adr_sram_tx.wr_l;
assign adr_sram_din      = adr_sram_tx.wdata;
assign adr_sram_addr     = ~adr_sram_tx.wr_l ? adr_sram_tx.wr_address : adr_sram_tx.rd_address;
assign adr_sram_tx.rdata = adr_sram_dout;

assign fifo_adr_wr    = fifo_addr_wr;
assign fifo_adr_wdata = fifo_addr_info;
async_fifo #(
  .FIFO_DEPTH_W      (FIFO_DATA_DEPTH_W),
  .FIFO_W            (FIFO_DATA_W),
  .SRAM_UNUSED_ADDR_W(FD_SRAM_UNUSED_ADDR_W)
) I_FIFO_DAT (
  .wrclk_RESET_N    (      axi_resetn ),
  .rdclk_RESET_N    (       wb_resetn ),
  .wr_en            ( sync_ENABLE_axi ),
  .rd_en            ( sync_ENABLE_wb  ),
  .fifo_wr_clk      (         axi_clk ),
  .fifo_rd_clk      (         wb_clk  ),
  .fifo_wr          (     fifo_dat_wr ),
  .fifo_rd          (     fifo_dat_rd ),
  .fifo_wdata       (  fifo_dat_wdata ),
  .fifo_rdata       (  fifo_dat_rdata ),
  .fifo_empty       (  fifo_dat_empty ),
  .fifo_full        (   fifo_dat_full ),
  .fifo_level       (                 ),
  .SRAM_IF          (     dat_sram_tx )
);
wire    dat_sram_enable; 
wire    dat_sram_wr; 
wire [FIFO_DATA_W-1:0]       dat_sram_din;
wire [FIFO_DATA_W-1:0]       dat_sram_dout;
wire [FIFO_DATA_DEPTH_W-1:0] dat_sram_addr;
sram_model #(
  .MEM_ADDR_W  (FIFO_DATA_DEPTH_W),
  .MEM_DATA_W  (FIFO_DATA_W)
) SRAM_DAT_1phc1024x32mx4tn(
  .CLK(axi_clk        ),
  .NCE(dat_sram_enable),
  .NWRT(dat_sram_wr   ),
  .NOE(1'b0           ),
  .DIN(dat_sram_din   ),
  .ADDR(dat_sram_addr),
  .DOUT(dat_sram_dout)
);
assign dat_sram_enable   = dat_sram_tx.rd_l | dat_sram_tx.wr_l;
assign dat_sram_wr       = dat_sram_tx.wr_l;
assign dat_sram_din      = dat_sram_tx.wdata;
assign dat_sram_addr     = ~dat_sram_tx.wr_l ? dat_sram_tx.wr_address : dat_sram_tx.rd_address;
assign dat_sram_tx.rdata = dat_sram_dout;


assign fifo_dat_wr    = fifo_data_wr;
assign fifo_dat_wdata = fifo_data_info;
wb_egress #(   
  .WB_ADR_W   (WB_ADR_W   ),  
  .WB_DAT_W   (WB_DAT_W   ),  
  .WB_TGA_W   (WB_TGA_W   ),  
  .WB_TGD_W   (WB_TGD_W   ),  
  .WB_TGC_W   (WB_TGC_W   ),  
  .WB_SEL_W   (WB_SEL_W   ),  
  .WB_CTI_W   (WB_CTI_W   ),  
  .WB_BTE_W   (WB_BTE_W   ),  
  .AXI_ID_W   (AXI_ID_W   ),  
  .AXI_ADDR_W (AXI_ADDR_W ),  
  .AXI_LEN_W  (AXI_LEN_W  ),  
  .AXI_SIZE_W (AXI_SIZE_W ),  
  .AXI_BURST_W(AXI_BURST_W),  
  .AXI_LOCK_W (AXI_LOCK_W ),  
  .AXI_CACHE_W(AXI_CACHE_W),  
  .AXI_PROT_W (AXI_PROT_W ),  
  .AXI_DATA_W (AXI_DATA_W ),  
  .AXI_STB_W  (AXI_STB_W )  
) I_WB_EGRESS(
  .wb_clk         ( wb_clk         ),
  .wb_resetn      ( wb_resetn      ),
  .ENABLE         ( sync_ENABLE_wb ),
  .WB_TX_IF       ( WB_TX_IF       ),
  .fifo_adr_rdata ( fifo_adr_rdata ),
  .fifo_adr_rd    ( fifo_adr_rd    ),
  .fifo_adr_empty ( fifo_adr_empty ),
  .fifo_dat_rdata ( fifo_dat_rdata ),
  .fifo_dat_rd    ( fifo_dat_rd    ),
  .fifo_dat_empty ( fifo_dat_empty )
);

endmodule 
