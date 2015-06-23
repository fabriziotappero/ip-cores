----------------------------------------------------------------------
----                                                              ----
---- NPI VGA Top module                                           ----
----                                                              ----
---- Author(s):                                                   ----
---- - Slavek Valach, s.valach@dspfpga.com                        ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2008 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU General          ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.0 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU General Public License for more details.----
----                                                              ----
---- You should have received a copy of the GNU General           ----
---- Public License along with this source; if not, download it   ----
---- from http://www.gnu.org/licenses/gpl.txt                     ----
----                                                              ----
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.video_cfg.all;

entity npi_vga is
generic (
   C_VD_ADDR               : std_logic_vector   := x"00800000";
   C_VD_STRIDE             : natural            := 1280;
   C_VD_WIDTH              : natural            := 1280;
   C_VD_HEIGHT             : integer            := 1024;
   C_VD_PIXEL_D            : natural            := 32;
   C_VD_PIXEL_DEPTH        : natural            := 8;
   
   C_VD_H_BP               : natural            := 48 + 8;   
   C_VD_H_FP               : natural            := 8 + 8;
   C_VD_H_SYNC_W           : natural            := 96;
   C_VD_H_POL              : std_logic          := '0';
   C_VD_V_BP               : natural            := 25 + 8;
   C_VD_V_FP               : natural            := 2 + 8;
   C_VD_V_SYNC_W           : natural            := 2;
   C_VD_V_POL              : std_logic          := '0';

   C_NPI_BURST_SIZE        : integer            := 256;
   C_NPI_ADDR_WIDTH        : integer            := 32;
   C_NPI_DATA_WIDTH        : integer            := 64;
   C_NPI_BE_WIDTH          : integer            := 8;
   C_NPI_RDWDADDR_WIDTH    : integer            := 4;
   C_SPLB_AWIDTH           : integer            := 32;
   C_SPLB_DWIDTH           : integer            := 128;
   C_SPLB_NUM_MASTERS      : integer            := 8;
   C_SPLB_MID_WIDTH        : integer            := 3;
   C_SPLB_NATIVE_DWIDTH    : integer            := 32;
   C_SPLB_P2P              : integer            := 0;
   C_SPLB_SUPPORT_BURSTS   : integer            := 0;
   C_SPLB_SMALLEST_MASTER  : integer            := 32;
   C_SPLB_CLK_PERIOD_PS    : integer            := 10000;
   C_FAMILY                : string             := "virtex5";
   C_MEM0_BASEADDR         : std_logic_vector   := X"FFFFFFFF";
   C_MEM0_HIGHADDR         : std_logic_vector   := X"00000000";
   C_MEM1_BASEADDR         : std_logic_vector   := X"FFFFFFFF";
   C_MEM1_HIGHADDR         : std_logic_vector   := X"00000000"

   );
port(

   NPI_Clk                 : in     std_logic;
   NPI_RST                 : in     std_logic;

   NPI_Addr                : out    std_logic_vector(C_NPI_ADDR_WIDTH - 1 downto 0);
   NPI_AddrReq             : out    std_logic;
   NPI_AddrAck             : in     std_logic;
   NPI_RNW                 : out    std_logic;
   NPI_Size                : out    std_logic_vector(3 downto 0);
   NPI_WrFIFO_Data         : out    std_logic_vector(C_NPI_DATA_WIDTH - 1 downto 0);
   NPI_WrFIFO_BE           : out    std_logic_vector(C_NPI_BE_WIDTH - 1 downto 0);
   NPI_WrFIFO_Push         : out    std_logic;
   NPI_RdFIFO_Data         : in     std_logic_vector(C_NPI_DATA_WIDTH - 1 downto 0);
   NPI_RdFIFO_Pop          : out    std_logic;
   NPI_RdFIFO_RdWdAddr     : in     std_logic_vector(C_NPI_RDWDADDR_WIDTH - 1 downto 0);
   NPI_WrFIFO_Empty        : in     std_logic;
   NPI_WrFIFO_AlmostFull   : in     std_logic;
   NPI_WrFIFO_Flush        : out    std_logic;
   NPI_RdFIFO_Empty        : in     std_logic;
   NPI_RdFIFO_Flush        : out    std_logic;
   NPI_RdFIFO_Latency      : in     std_logic_vector(1 downto 0);
   NPI_RdModWr             : out    std_logic;
   NPI_InitDone            : in     std_logic;

   INTR                    : out    std_logic;
   
   VIDEO_CLK               : in     std_logic;                    -- LCD Clock signal
   VIDEO_VSYNC             : out    std_logic;
   VIDEO_HSYNC             : out    std_logic;
   VIDEO_DE                : out    std_logic;
   VIDEO_CLK_OUT           : out    std_logic;
   VIDEO_R                 : out    std_logic_vector(C_VD_PIXEL_DEPTH - 1 downto 0);
   VIDEO_G                 : out    std_logic_vector(C_VD_PIXEL_DEPTH - 1 downto 0);
   VIDEO_B                 : out    std_logic_vector(C_VD_PIXEL_DEPTH - 1 downto 0); 
      
   X                       : out    std_logic_vector(7 downto 0);
   X1                      : out    std_logic;
   X2                      : out    std_logic;
   X3                      : out    std_logic;
   X4                      : out    std_logic;
   X5                      : out    std_logic;
   X6                      : out    std_logic;
   X7                      : out    std_logic;
   X8                      : out    std_logic;
   X9                      : out    std_logic;
   X10                     : out    std_logic;

   SPLB_Clk                : in  std_logic;
   SPLB_Rst                : in  std_logic;
   PLB_ABus                : in  std_logic_vector(0 to 31);
   PLB_UABus               : in  std_logic_vector(0 to 31);
   PLB_PAValid             : in  std_logic;
   PLB_SAValid             : in  std_logic;
   PLB_rdPrim              : in  std_logic;
   PLB_wrPrim              : in  std_logic;
   PLB_masterID            : in  std_logic_vector(0 to C_SPLB_MID_WIDTH-1);
   PLB_abort               : in  std_logic;
   PLB_busLock             : in  std_logic;
   PLB_RNW                 : in  std_logic;
   PLB_BE                  : in  std_logic_vector(0 to C_SPLB_DWIDTH/8-1);
   PLB_MSize               : in  std_logic_vector(0 to 1);
   PLB_size                : in  std_logic_vector(0 to 3);
   PLB_type                : in  std_logic_vector(0 to 2);
   PLB_lockErr             : in  std_logic;
   PLB_wrDBus              : in  std_logic_vector(0 to C_SPLB_DWIDTH-1);
   PLB_wrBurst             : in  std_logic;
   PLB_rdBurst             : in  std_logic;
   PLB_wrPendReq           : in  std_logic;
   PLB_rdPendReq           : in  std_logic;
   PLB_wrPendPri           : in  std_logic_vector(0 to 1);
   PLB_rdPendPri           : in  std_logic_vector(0 to 1);
   PLB_reqPri              : in  std_logic_vector(0 to 1);
   PLB_TAttribute          : in  std_logic_vector(0 to 15);
   Sl_addrAck              : out std_logic;
   Sl_SSize                : out std_logic_vector(0 to 1);
   Sl_wait                 : out std_logic;
   Sl_rearbitrate          : out std_logic;
   Sl_wrDAck               : out std_logic;
   Sl_wrComp               : out std_logic;
   Sl_wrBTerm              : out std_logic;
   Sl_rdDBus               : out std_logic_vector(0 to C_SPLB_DWIDTH-1);
   Sl_rdWdAddr             : out std_logic_vector(0 to 3);
   Sl_rdDAck               : out std_logic;
   Sl_rdComp               : out std_logic;
   Sl_rdBTerm              : out std_logic;
   Sl_MBusy                : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
   Sl_MWrErr               : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
   Sl_MRdErr               : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
   Sl_MIRQ                 : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1)
   );
end entity;

architecture arch_npi_vga OF npi_vga IS

constant c_vcnt_range      : natural := C_VD_V_BP + C_VD_V_FP + C_VD_HEIGHT + C_VD_V_SYNC_W;
constant C_VCNT_SIZE       : natural := log2(c_vcnt_range);
constant c_hcnt_range      : natural := C_VD_H_BP + C_VD_H_FP + C_VD_WIDTH + C_VD_H_SYNC_W;
constant C_HCNT_SIZE       : natural := log2(c_hcnt_range);

component plbbr is
generic (
   C_SPLB_AWIDTH           : integer;
   C_SPLB_DWIDTH           : integer;
   C_SPLB_NUM_MASTERS      : integer;
   C_SPLB_MID_WIDTH        : integer;
   C_SPLB_NATIVE_DWIDTH    : integer;
   C_SPLB_P2P              : integer;
   C_SPLB_SUPPORT_BURSTS   : integer;
   C_SPLB_SMALLEST_MASTER  : integer;
   C_SPLB_CLK_PERIOD_PS    : integer;
   C_FAMILY                : string;
   C_MEM0_BASEADDR         : std_logic_vector;
   C_MEM0_HIGHADDR         : std_logic_vector;
   C_MEM1_BASEADDR         : std_logic_vector;
   C_MEM1_HIGHADDR         : std_logic_vector);
port (
   GR_DATA_O               : out    std_logic_vector(31 downto 0);
   GR_DATA_I0              : in     std_logic_vector(31 downto 0);
   GR_DATA_I1              : in     std_logic_vector(31 downto 0);
   GR_ADDR                 : out    std_logic_vector(15 downto 2);
   GR_RNW                  : out    std_logic;
   GR_CS                   : out    std_logic_vector(1 downto 0);                  

   SPLB_Clk                : in  std_logic;
   SPLB_Rst                : in  std_logic;
   PLB_ABus                : in  std_logic_vector(0 to 31);
   PLB_UABus               : in  std_logic_vector(0 to 31);
   PLB_PAValid             : in  std_logic;
   PLB_SAValid             : in  std_logic;
   PLB_rdPrim              : in  std_logic;
   PLB_wrPrim              : in  std_logic;
   PLB_masterID            : in  std_logic_vector(0 to C_SPLB_MID_WIDTH-1);
   PLB_abort               : in  std_logic;
   PLB_busLock             : in  std_logic;
   PLB_RNW                 : in  std_logic;
   PLB_BE                  : in  std_logic_vector(0 to C_SPLB_DWIDTH/8-1);
   PLB_MSize               : in  std_logic_vector(0 to 1);
   PLB_size                : in  std_logic_vector(0 to 3);
   PLB_type                : in  std_logic_vector(0 to 2);
   PLB_lockErr             : in  std_logic;
   PLB_wrDBus              : in  std_logic_vector(0 to C_SPLB_DWIDTH-1);
   PLB_wrBurst             : in  std_logic;
   PLB_rdBurst             : in  std_logic;
   PLB_wrPendReq           : in  std_logic;
   PLB_rdPendReq           : in  std_logic;
   PLB_wrPendPri           : in  std_logic_vector(0 to 1);
   PLB_rdPendPri           : in  std_logic_vector(0 to 1);
   PLB_reqPri              : in  std_logic_vector(0 to 1);
   PLB_TAttribute          : in  std_logic_vector(0 to 15);
   Sl_addrAck              : out std_logic;
   Sl_SSize                : out std_logic_vector(0 to 1);
   Sl_wait                 : out std_logic;
   Sl_rearbitrate          : out std_logic;
   Sl_wrDAck               : out std_logic;
   Sl_wrComp               : out std_logic;
   Sl_wrBTerm              : out std_logic;
   Sl_rdDBus               : out std_logic_vector(0 to C_SPLB_DWIDTH-1);
   Sl_rdWdAddr             : out std_logic_vector(0 to 3);
   Sl_rdDAck               : out std_logic;
   Sl_rdComp               : out std_logic;
   Sl_rdBTerm              : out std_logic;
   Sl_MBusy                : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
   Sl_MWrErr               : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
   Sl_MRdErr               : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
   Sl_MIRQ                 : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1));
end component;

constant BYTES_PER_PIXEL   : natural := (C_VD_PIXEL_D / 8);   
constant VD_STRIDE         : natural := C_VD_STRIDE * BYTES_PER_PIXEL;
constant BURST_LENGHT      : natural := (C_VD_WIDTH * BYTES_PER_PIXEL) / C_NPI_BURST_SIZE;

component graphic is
Generic(
   C_FAMILY                : string;
   C_VD_DATA_WIDTH         : integer;
   PIXEL_DEPTH             : integer;
   PIXEL_WIDTH             : natural;

   C_VD_V_POL              : std_logic;
   C_VCNT_SIZE             : integer;
   C_VBACK_PORCH           : natural;
   C_VFRONT_PORCH          : natural;
   C_VVIDEO_ACTIVE         : natural;
   C_VSYNC_PULSE           : natural;

   C_VD_H_POL              : std_logic;
   C_HCNT_SIZE             : natural;
   C_HBACK_PORCH           : natural;
   C_HFRONT_PORCH          : natural;
   C_HVIDEO_ACTIVE         : natural;
   C_HSYNC_PULSE           : natural);
port (
   -- System interface      
   Sys_Clk                 : in     std_logic;                    -- Base system clock
   NPI_CLK                 : in     std_logic;

   Sys_Rst                 : in     std_logic;                    -- System reset

   VIDEO_CLK               : in     std_logic;                    -- LCD Clock signal

   VIDEO_VSYNC             : out    std_logic;
   VIDEO_HSYNC             : out    std_logic;
   VIDEO_DE                : out    std_logic;
   VIDEO_CLK_OUT           : out    std_logic;

   VIDEO_R                 : out    std_logic_vector(0 to PIXEL_DEPTH - 1);
   VIDEO_G                 : out    std_logic_vector(0 to PIXEL_DEPTH - 1);
   VIDEO_B                 : out    std_logic_vector(0 to PIXEL_DEPTH - 1);

   INTR                    : out    std_logic;

   DMA_INIT                : in     std_logic;
   DMA_DACK                : in     std_logic;
   DMA_DATA                : in     std_logic_vector(0 to C_VD_DATA_WIDTH - 1);
   DMA_DREQ                : out    std_logic;
   DMA_RSYNC               : out    std_logic;
   DMA_TC                  : in     std_logic;

   GR_DATA_I               : in     std_logic_vector(31 downto 0);
   GR_DATA_O               : out    std_logic_vector(31 downto 0);
   GR_ADDR                 : in     std_logic_vector(15 downto 0);
   GR_RNW                  : in     std_logic;
   GR_CS                   : in     std_logic;                  

   X                       : out    std_logic_vector(7 downto 0));
end component;

component npi_eng is
generic (
   C_FAMILY                : string;
   C_VD_ADDR               : std_logic_vector;
   C_VD_PIXEL_D            : natural;
   C_VD_STRIDE             : integer;
   C_VD_WIDTH              : integer;
   C_VD_HEIGHT             : integer;
   C_NPI_BURST_SIZE        : integer;
   C_NPI_ADDR_WIDTH        : integer;
   C_NPI_DATA_WIDTH        : integer;
   C_NPI_BE_WIDTH          : integer;
   C_NPI_RDWDADDR_WIDTH    : integer);
port(

   NPI_Clk                 : in     std_logic;
   Sys_Clk                 : in     std_logic;
   NPI_RST                 : in     std_logic;

   NPI_Addr                : out    std_logic_vector(C_NPI_ADDR_WIDTH-1 downto 0);
   NPI_AddrReq             : out    std_logic;
   NPI_AddrAck             : in     std_logic;
   NPI_RNW                 : out    std_logic;
   NPI_Size                : out    std_logic_vector(3 downto 0);
   NPI_WrFIFO_Data         : out    std_logic_vector(C_NPI_DATA_WIDTH-1 downto 0);
   NPI_WrFIFO_BE           : out    std_logic_vector(C_NPI_BE_WIDTH-1 downto 0);
   NPI_WrFIFO_Push         : out    std_logic;
   NPI_RdFIFO_Data         : in     std_logic_vector(C_NPI_DATA_WIDTH-1 downto 0);
   NPI_RdFIFO_Pop          : out    std_logic;
   NPI_RdFIFO_RdWdAddr     : in     std_logic_vector(C_NPI_RDWDADDR_WIDTH-1 downto 0);
   NPI_WrFIFO_Empty        : in     std_logic;
   NPI_WrFIFO_AlmostFull   : in     std_logic;
   NPI_WrFIFO_Flush        : out    std_logic;
   NPI_RdFIFO_Empty        : in     std_logic;
   NPI_RdFIFO_Flush        : out    std_logic;
   NPI_RdFIFO_Latency      : in     std_logic_vector(1 downto 0);
   NPI_RdModWr             : out    std_logic;
   NPI_InitDone            : in     std_logic;

   GR_DATA_I               : in     std_logic_vector(31 downto 0);
   GR_DATA_O               : out    std_logic_vector(31 downto 0);
   GR_ADDR                 : in     std_logic_vector(15 downto 0);
   GR_RNW                  : in     std_logic;
   GR_CS                   : in     std_logic;                  
   
   DMA_INIT                : out    std_logic;
   DMA_DREQ                : in     std_logic;     -- Data request
   DMA_DACK                : out    std_logic;     -- Data ack
   DMA_RSYNC               : in     std_logic;     -- Synchronization reset (restarts the channel)
   DMA_TC                  : out    std_logic;     -- Terminal count (the signal is generated at the end of the transfer)
   DMA_DATA                : out    std_logic_vector(C_NPI_DATA_WIDTH - 1 downto 0); 
   
   X                       : out    std_logic_vector(7 downto 0));
end component;

signal burst_cnt              : integer range 0 to C_VD_WIDTH / C_NPI_BURST_SIZE;
signal burst_cnt_one          : std_logic;

signal line_cnt               : integer range 0 to C_VD_HEIGHT;
signal line_cnt_one           : std_logic;

signal addr_cnt_i             : std_logic_vector(C_NPI_ADDR_WIDTH - 1 downto 0);   
signal line_addr              : std_logic_vector(C_NPI_ADDR_WIDTH - 1 downto 0);

signal NPI_AddrReq_i          : std_logic;
signal NPI_RNW_i              : std_logic;
signal NPI_RdFIFO_Pop_i       : std_logic;

signal NPI_RST_i              : std_logic;
signal RD_Req                 : std_logic;

signal DMA_DataReq            : std_logic;

signal dma_dack_d0            : std_logic;
signal dma_dack_d1            : std_logic;

signal dma_dreq               : std_logic;
signal dma_dack               : std_logic;
signal dma_rsync              : std_logic;
signal dma_tc                 : std_logic;
signal dma_data               : std_logic_vector(C_NPI_DATA_WIDTH - 1 downto 0);
signal dma_init               : std_logic;
 
signal gr_data_i              : std_logic_vector(31 downto 0);
signal gr_data_o0             : std_logic_vector(31 downto 0);
signal gr_data_o1             : std_logic_vector(31 downto 0);
signal gr_addr                : std_logic_vector(15 downto 0);
signal gr_rnw                 : std_logic;
signal gr_cs                  : std_logic_vector(0 to 1);

BEGIN

npi_eng_inst : npi_eng 
generic map (
   C_FAMILY                => C_FAMILY,
   C_VD_ADDR               => C_VD_ADDR,
   C_VD_PIXEL_D            => C_VD_PIXEL_D,
   C_VD_STRIDE             => C_VD_STRIDE,
   C_VD_WIDTH              => C_VD_WIDTH,
   C_VD_HEIGHT             => C_VD_HEIGHT,
   C_NPI_BURST_SIZE        => C_NPI_BURST_SIZE,
   C_NPI_ADDR_WIDTH        => C_NPI_ADDR_WIDTH,
   C_NPI_DATA_WIDTH        => C_NPI_DATA_WIDTH,
   C_NPI_BE_WIDTH          => C_NPI_BE_WIDTH,
   C_NPI_RDWDADDR_WIDTH    => C_NPI_RDWDADDR_WIDTH)
port map (
   NPI_Clk                 => NPI_Clk,
   Sys_Clk                 => SPLB_Clk,
   NPI_RST                 => NPI_Rst,

   NPI_Addr                => NPI_Addr,
   NPI_AddrReq             => NPI_AddrReq,
   NPI_AddrAck             => NPI_AddrAck,
   NPI_RNW                 => NPI_RNW,
   NPI_Size                => NPI_Size,
   NPI_WrFIFO_Data         => NPI_WrFIFO_Data,
   NPI_WrFIFO_BE           => NPI_WrFIFO_BE,
   NPI_WrFIFO_Push         => NPI_WrFIFO_Push,
   NPI_RdFIFO_Data         => NPI_RdFIFO_Data,
   NPI_RdFIFO_Pop          => NPI_RdFIFO_Pop,
   NPI_RdFIFO_RdWdAddr     => NPI_RdFIFO_RdWdAddr,
   NPI_WrFIFO_Empty        => NPI_WrFIFO_Empty,
   NPI_WrFIFO_AlmostFull   => NPI_WrFIFO_AlmostFull,
   NPI_WrFIFO_Flush        => NPI_WrFIFO_Flush,
   NPI_RdFIFO_Empty        => NPI_RdFIFO_Empty,
   NPI_RdFIFO_Flush        => NPI_RdFIFO_Flush,
   NPI_RdFIFO_Latency      => NPI_RdFIFO_Latency,
   NPI_RdModWr             => NPI_RdModWr,
   NPI_InitDone            => NPI_InitDone,

   GR_DATA_I               => gr_data_i,
   GR_DATA_O               => gr_data_o1,
   GR_ADDR                 => gr_addr,
   GR_RNW                  => gr_rnw,
   GR_CS                   => gr_cs(1),                  

   DMA_INIT                => dma_init,
   DMA_DREQ                => dma_dreq,
   DMA_DACK                => dma_dack,
   DMA_RSYNC               => dma_rsync,
   DMA_TC                  => dma_tc,
   DMA_DATA                => dma_data,
   
   X                       => X);

graphic_ctrl_inst : graphic 
Generic map (

   C_FAMILY                => C_FAMILY,
   C_VD_DATA_WIDTH         => C_NPI_DATA_WIDTH,
   PIXEL_DEPTH             => C_VD_PIXEL_DEPTH,
   PIXEL_WIDTH             => C_VD_PIXEL_D,

   C_VCNT_SIZE             => C_VCNT_SIZE,
   C_VD_V_POL              => C_VD_V_POL,
   C_VBACK_PORCH           => C_VD_V_BP,
   C_VFRONT_PORCH          => C_VD_V_FP,
   C_VVIDEO_ACTIVE         => C_VD_HEIGHT,
   C_VSYNC_PULSE           => C_VD_V_SYNC_W,

   C_HCNT_SIZE             => C_HCNT_SIZE,
   C_VD_H_POL              => C_VD_H_POL,   
   C_HBACK_PORCH           => C_VD_H_BP,
   C_HFRONT_PORCH          => C_VD_H_FP,
   C_HVIDEO_ACTIVE         => C_VD_WIDTH,
   C_HSYNC_PULSE           => C_VD_H_SYNC_W)

port map (
   -- System interface      
   Sys_Clk                 => SPLB_Clk,
   NPI_CLK                 => NPI_CLK,
   Sys_Rst                 => NPI_Rst,

   VIDEO_CLK               => VIDEO_CLK,

   VIDEO_VSYNC             => VIDEO_VSYNC,
   VIDEO_HSYNC             => VIDEO_HSYNC,
   VIDEO_DE                => VIDEO_DE,
   VIDEO_CLK_OUT           => VIDEO_CLK_OUT,

   VIDEO_R                 => VIDEO_R,
   VIDEO_G                 => VIDEO_G,
   VIDEO_B                 => VIDEO_B,

   INTR                    => INTR,
   
   DMA_INIT                => dma_init,
   DMA_DACK                => dma_dack,
   DMA_DATA                => dma_data,
   DMA_DREQ                => dma_dreq,
   DMA_RSYNC               => dma_rsync,
   DMA_TC                  => dma_tc,

   GR_DATA_I               => gr_data_i,
   GR_DATA_O               => gr_data_o0,
   GR_ADDR                 => gr_addr,
   GR_RNW                  => gr_rnw,   
   GR_CS                   => gr_cs(0),

   X                       => open);

plbbr_inst : plbbr
generic map (
   C_SPLB_AWIDTH           => C_SPLB_AWIDTH,
   C_SPLB_DWIDTH           => C_SPLB_DWIDTH,
   C_SPLB_NUM_MASTERS      => C_SPLB_NUM_MASTERS,
   C_SPLB_MID_WIDTH        => C_SPLB_MID_WIDTH,
   C_SPLB_NATIVE_DWIDTH    => C_SPLB_NATIVE_DWIDTH, 
   C_SPLB_P2P              => C_SPLB_P2P,
   C_SPLB_SUPPORT_BURSTS   => C_SPLB_SUPPORT_BURSTS,
   C_SPLB_SMALLEST_MASTER  => C_SPLB_SMALLEST_MASTER,
   C_SPLB_CLK_PERIOD_PS    => C_SPLB_CLK_PERIOD_PS,
   C_FAMILY                => C_FAMILY,
   C_MEM0_BASEADDR         => C_MEM0_BASEADDR,
   C_MEM0_HIGHADDR         => C_MEM0_HIGHADDR,
   C_MEM1_BASEADDR         => C_MEM1_BASEADDR,
   C_MEM1_HIGHADDR         => C_MEM1_HIGHADDR)

port map (
   GR_DATA_O               => gr_data_i,
   GR_DATA_I0              => gr_data_o0,
   GR_DATA_I1              => gr_data_o1,
   GR_ADDR                 => gr_addr(15 downto 2),
   GR_RNW                  => gr_rnw,
   GR_CS                   => gr_cs,

   SPLB_Clk                => SPLB_Clk,
   SPLB_Rst                => SPLB_Rst,
   PLB_ABus                => PLB_ABus,
   PLB_UABus               => PLB_UABus,
   PLB_PAValid             => PLB_PAValid,  
   PLB_SAValid             => PLB_SAValid,
   PLB_rdPrim              => PLB_rdPrim,  
   PLB_wrPrim              => PLB_wrPrim, 
   PLB_masterID            => PLB_masterID,
   PLB_abort               => PLB_abort,  
   PLB_busLock             => PLB_busLock,
   PLB_RNW                 => PLB_RNW,   
   PLB_BE                  => PLB_BE,   
   PLB_MSize               => PLB_MSize,
   PLB_size                => PLB_size,
   PLB_type                => PLB_type,
   PLB_lockErr             => PLB_lockErr,
   PLB_wrDBus              => PLB_wrDBus,
   PLB_wrBurst             => PLB_wrBurst,
   PLB_rdBurst             => PLB_rdBurst,
   PLB_wrPendReq           => PLB_wrPendReq,
   PLB_rdPendReq           => PLB_rdPendReq,
   PLB_wrPendPri           => PLB_wrPendPri,
   PLB_rdPendPri           => PLB_rdPendPri,
   PLB_reqPri              => PLB_reqPri, 
   PLB_TAttribute          => PLB_TAttribute,
   Sl_addrAck              => Sl_addrAck,  
   Sl_SSize                => Sl_SSize,    
   Sl_wait                 => Sl_wait,    
   Sl_rearbitrate          => Sl_rearbitrate,
   Sl_wrDAck               => Sl_wrDAck, 
   Sl_wrComp               => Sl_wrComp,  
   Sl_wrBTerm              => Sl_wrBTerm,
   Sl_rdDBus               => Sl_rdDBus,
   Sl_rdWdAddr             => Sl_rdWdAddr,
   Sl_rdDAck               => Sl_rdDAck,
   Sl_rdComp               => Sl_rdComp,
   Sl_rdBTerm              => Sl_rdBTerm, 
   Sl_MBusy                => Sl_MBusy, 
   Sl_MWrErr               => Sl_MWrErr,
   Sl_MRdErr               => Sl_MRdErr,
   Sl_MIRQ                 => Sl_MIRQ);

END arch_npi_vga;


