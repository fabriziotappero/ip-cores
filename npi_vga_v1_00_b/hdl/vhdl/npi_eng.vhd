----------------------------------------------------------------------
----                                                              ----
---- NPI DMA Engine                                               ----
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
use npi_vga_v1_00_b.video_cfg.all;

entity npi_eng is
generic (
   C_FAMILY                : string := "virtex5";
   C_VD_ADDR               : std_logic_vector := x"00800000";
   C_VD_PIXEL_D            : natural := 32;
   C_VD_STRIDE             : natural := 640;
   C_VD_WIDTH              : natural := 640;
   C_VD_HEIGHT             : natural := 480;
   C_NPI_BURST_SIZE        : natural := 256;
   C_NPI_ADDR_WIDTH        : natural := 32;
   C_NPI_DATA_WIDTH        : natural := 64;
   C_NPI_BE_WIDTH          : natural := 8;
   C_NPI_RDWDADDR_WIDTH    : natural := 4);
port(

   NPI_Clk                 : in     std_logic;
   Sys_Clk                 : in     std_logic;
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
end entity;

architecture arch_npi_eng of npi_eng is

constant BYTES_PER_PIXEL      : natural := (C_VD_PIXEL_D / 8);   
constant VD_STRIDE            : natural := C_VD_STRIDE * BYTES_PER_PIXEL;
constant BURST_LENGHT         : natural := (C_VD_WIDTH * BYTES_PER_PIXEL) / C_NPI_BURST_SIZE;
   
signal burst_cnt              : integer range 0 to BURST_LENGHT;
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

signal vd_addr_i              : std_logic_vector(C_NPI_ADDR_WIDTH - 1 downto 0);

BEGIN

PROCESS(Sys_Clk)
BEGIN
   If Sys_Clk'event And Sys_Clk = '1' Then
      If (NPI_RST_i = '1') Then
         vd_addr_i <= C_VD_ADDR;
      Else
         If gr_cs = '1' And gr_rnw = '0' Then
            vd_addr_i <= GR_DATA_I;
         End If;
      End If;
   End If;
END PROCESS;

PROCESS(NPI_Clk)
BEGIN
   If NPI_Clk'event And NPI_Clk = '1' Then
      If (NPI_RST_i = '1') Then
         burst_cnt <= BURST_LENGHT;
      ElsIf NPI_AddrAck = '1' Then
         If burst_cnt_one = '1' Then
            burst_cnt <= BURST_LENGHT;
         Else
            burst_cnt <= burst_cnt - 1;
         End If;
      End If;
   End If;
END PROCESS;

burst_cnt_one <= '1' When burst_cnt = 1 Else '0';

PROCESS(NPI_Clk)
BEGIN
   If NPI_Clk'event And NPI_Clk = '1' Then
      If (NPI_RST_i = '1') Then
         line_cnt <= C_VD_HEIGHT;
      ElsIf NPI_AddrAck = '1' And burst_cnt_one = '1' Then
         If line_cnt_one = '1' Then
            line_cnt <= C_VD_HEIGHT;
         Else
            line_cnt <= line_cnt - 1;
         End If;
      End If;
   End If;
END PROCESS;

line_cnt_one <= '1' When line_cnt = 1 Else '0';

PROCESS(NPI_Clk)
BEGIN
   If NPI_Clk'event And NPI_Clk = '1' Then
      If NPI_RST_i = '1' Then
         line_addr <= C_VD_ADDR;
         addr_cnt_i <= C_VD_ADDR;
      ElsIf NPI_AddrAck = '1' Then
         If burst_cnt_one = '1' Then
            If line_cnt_one = '1' Then
               line_addr <= vd_addr_i;
               addr_cnt_i <= vd_addr_i;
            Else
               line_addr <= line_addr + VD_STRIDE;
               addr_cnt_i <= line_addr + VD_STRIDE;
            End If;
         Else
            addr_cnt_i <= addr_cnt_i + C_NPI_BURST_SIZE;
         End If;
      End If;
   End If;
END PROCESS;

DMA_DataReq <= DMA_DREQ;

NPI_RST_i <= Not NPI_InitDone Or NPI_RST;   

PROCESS (NPI_Clk)
BEGIN
   If NPI_Clk'event And NPI_CLK = '1' Then
      If NPI_RST_i = '1' Then
         NPI_AddrReq_i <= '0';
      ElsIf RD_Req = '1' Then
         NPI_AddrReq_i <= '1';
      ElsIf NPI_AddrAck = '1' Then
         NPI_AddrReq_i <= '0';
      End If;
   End If;
END PROCESS;

NPI_RNW_i <= NPI_AddrReq_i;
NPI_RNW <= NPI_RNW_i;
NPI_AddrReq <= NPI_AddrReq_i;

RD_Req <= '1' When NPI_AddrAck = '0' And DMA_DataReq = '1' Else '0';

NPI_RdFIFO_Pop_i <= Not NPI_RdFIFO_Empty;

NPI_Addr                <= addr_cnt_i;
NPI_Size                <= get_NPI_Size(C_NPI_DATA_WIDTH, C_NPI_BURST_SIZE);
NPI_WrFIFO_Data         <= (Others => '0');
NPI_WrFIFO_BE           <= (Others => '0');
NPI_WrFIFO_Push         <= '0';
NPI_WrFIFO_Flush        <= '0';
NPI_RdFIFO_Flush        <= NPI_RST_i;
NPI_RdModWr             <= '0';

NPI_RdFIFO_Pop <= NPI_RdFIFO_Pop_i;

-- Data are fliped
DMA_DATA <= NPI_RdFIFO_Data(31 downto 0) & NPI_RdFIFO_Data(63 downto 32) When C_NPI_DATA_WIDTH = 64
            Else NPI_RdFIFO_Data(31 downto 0);

PROCESS (NPI_Clk)
BEGIN
   If NPI_Clk'event And NPI_CLK = '1' Then
      If NPI_RST_i = '1' Then
         dma_dack_d0 <= '0';
         dma_dack_d1 <= '0';
      Else
         dma_dack_d0 <= NPI_RdFIFO_Empty;
         dma_dack_d1 <= dma_dack_d0;
      End If;
   End If;
END PROCESS;

DMA_DACK <= Not NPI_RdFIFO_Empty When NPI_RdFIFO_Latency = "00" Else
            Not dma_dack_d0 When NPI_RdFIFO_Latency = "01" Else
            Not dma_dack_d1 When NPI_RdFIFO_Latency = "10" Else '0';

DMA_INIT <= NPI_InitDone;

X(0) <= NPI_AddrReq_i;
X(1) <= NPI_RNW_i;
X(2) <= NPI_AddrAck;
X(3) <= NPI_RdFIFO_Empty;
X(4) <= NPI_RdFIFO_Pop_i;

end arch_npi_eng;

