----------------------------------------------------------------------
----                                                              ----
---- Data RGBA module                                             ----
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

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity data_rgb is
Generic(
   C_FAMILY             : string  := "virtex5";
   C_VD_DATA_WIDTH      : integer := 32;
   V_CNT_SIZE           : integer := 10;
   H_CNT_SIZE           : integer := 10;
   PIXEL_WIDTH          : natural := 32;
   PIXEL_DEPTH          : integer := 6);
port (
   -- System interface      
   Sys_Rst                       : in     std_logic;                    -- System reset
   Sys_Clk                       : in     std_logic;
   NPI_CLK                       : in     std_logic;

   VIDEO_CLK                     : in     std_logic;                    -- LCD Clock signal
   VIDEO_DE                      : in     std_logic;
   VIDEO_EN                      : in     std_logic;

   VIDEO_R                       : out    std_logic_vector(PIXEL_DEPTH - 1 downto 0);
   VIDEO_G                       : out    std_logic_vector(PIXEL_DEPTH - 1 downto 0);
   VIDEO_B                       : out    std_logic_vector(PIXEL_DEPTH - 1 downto 0);
   VIDEO_A                       : out    std_logic_vector(PIXEL_DEPTH - 1 downto 0);

   INTR                          : out    std_logic;

-- DMA Channel input and control
   DMA_INIT                      : in     std_logic;
   DMA_DACK                      : in     std_logic;
   DMA_DATA                      : in     std_logic_vector(C_VD_DATA_WIDTH - 1 downto 0);
   DMA_DREQ                      : out    std_logic;
   DMA_RSYNC                     : out    std_logic;
   DMA_TC                        : in     std_logic;

   X_0                           : out    std_logic;
   X_1                           : out    std_logic;
   X_2                           : out    std_logic;
   X_3                           : out    std_logic;
   X_4                           : out    std_logic;
   X_5                           : out    std_logic);

end data_rgb;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------
architecture implementation of data_rgb is

component d_fifo
generic (
   C_FAMILY                      : string;
   C_VD_DATA_WIDTH               : integer);
port (
-- System interface      
   Sys_Clk                       : in     std_logic;                    -- Base system clock
   NPI_CLK                       : in     std_logic;
   Sys_Rst                       : in     std_logic;                    -- System reset

-- DMA Channel interface
--   DMA_CLK                       : in     std_logic;     -- DMA clock time domain (the asynchronous FIFO will be used)
   DMA_DREQ                      : out    std_logic;     -- Data request
   DMA_DACK                      : in     std_logic;     -- Data ack
   DMA_RSYNC                     : out    std_logic;     -- Synchronization reset (restarts the channel)
   DMA_TC                        : in     std_logic;     -- Terminal count (the signal is generated at the end of the transfer)
   DMA_DATA                      : in     std_logic_vector(C_VD_DATA_WIDTH - 1 downto 0);

-- User interface (the reader side)
   USER_CLK                      : in     std_logic;                    -- User clk is used as an asynchronous read clock
   USER_RST                      : in     std_logic;
   USER_DREQ                     : in     std_logic;
   USER_RD                       : in     std_logic;
   USER_DRDY                     : out    std_logic;

   XXX                           : out    std_logic_vector(3 downto 0);
   
   USER_DATA                     : out    std_logic_vector(31 downto 0));
end component;

constant VCC                     : std_logic := '1';
constant GND                     : std_logic := '0';

signal de_i                      : std_logic;

-- Fifo signals
signal dreq_i                    : std_logic;
signal dack_i                    : std_logic;
signal rsync                     : std_logic;
signal tc_i                      : std_logic;
signal data_in                   : std_logic_vector(31 downto 0);
signal user_rst                  : std_logic;
signal user_dreq                 : std_logic;
signal user_read                 : std_logic;
signal user_drdy                 : std_logic;
signal fifo_data_out             : std_logic_vector(31 downto 0);
signal fifo_init                 : std_logic;

signal de_cnt                    : integer range 0 to (32 / PIXEL_WIDTH) - 1;
signal de_cnt_preset             : integer range 0 to (32 / PIXEL_WIDTH) - 1;

signal video_d                   : std_logic_vector(PIXEL_DEPTH - 1 downto 0);

signal XXX                       : std_logic_vector(3 downto 0);

BEGIN

-- Fifo instance and DMA CTRL
INTR <= '0';
dack_i <= DMA_DACK;
DMA_DREQ <= dreq_i;
user_dreq <= VIDEO_EN;
rsync <= '0';
fifo_init <= (Not video_en) Or Sys_Rst Or (Not DMA_INIT);
user_rst <= Not VIDEO_EN;
de_i <= VIDEO_DE;

de_cnt_preset <= 0 When PIXEL_WIDTH = 32 Else
                 1 When PIXEL_WIDTH = 16 Else
                 3 When PIXEL_WIDTH = 8 Else 0;

PROCESS(VIDEO_CLK, Sys_Rst)
BEGIN
   If Sys_Rst = '1' Then
      de_cnt <= de_cnt_preset;
   ElsIf VIDEO_CLK'event And VIDEO_CLK = '1' Then
      If de_i = '1' Then 
         If de_cnt = 0 Then
            de_cnt <= de_cnt_preset;
         Else
            de_cnt <= de_cnt - 1;
         End If;
      Else
      de_cnt <= de_cnt_preset;
      End If;
   End If;
END PROCESS;

user_read <= '1' When (de_i = '1') And (de_cnt = 0) And (user_drdy = '1') Else '0';

fifo_i : d_fifo
generic map (
   C_FAMILY                      => C_FAMILY,
   C_VD_DATA_WIDTH               => C_VD_DATA_WIDTH)
port map (
-- System interface      
   Sys_Clk                       => Sys_Clk,                    -- Base system clock
   NPI_CLK                       => NPI_CLK,
   Sys_Rst                       => fifo_init,

-- DMA Channel interface
   DMA_DREQ                      => dreq_i,
   DMA_DACK                      => dack_i,
   DMA_RSYNC                     => rsync,
   DMA_TC                        => tc_i,
   DMA_DATA                      => DMA_DATA,

-- User interface (the reader side)
   USER_CLK                      => VIDEO_CLK,
   USER_RST                      => user_rst,
   USER_DREQ                     => user_dreq,
   USER_RD                       => user_read,
   USER_DRDY                     => user_drdy,
   
   XXX                           => XXX,

   USER_DATA                     => fifo_data_out);

G_32 : If PIXEL_WIDTH = 32 Generate
   PROCESS(VIDEO_CLK)      -- 32 bits data
   BEGIN
      If VIDEO_CLK'event And VIDEO_CLK = '1' Then
         VIDEO_R <= fifo_data_out(7 downto 2);--fifo_data_out(2 to 7);
         VIDEO_G <= fifo_data_out(15 downto 10);--fifo_data_out(10 to 15);
         VIDEO_B <= fifo_data_out(23 downto 18);--fifo_data_out(18 to 23);
         VIDEO_A <= fifo_data_out(31 downto 26);--fifo_data_out(26 to 31);
      End If;
   END PROCESS;
End Generate;

G_16 : If PIXEL_WIDTH = 16 Generate
   PROCESS(VIDEO_CLK)    -- 16 bits data 
   BEGIN
      If VIDEO_CLK'event And VIDEO_CLK = '1' Then
         VIDEO_A <= (Others => '0');
         If de_cnt = 1 Then
            VIDEO_R <= fifo_data_out(4 downto 0) & '0';
            VIDEO_G <= fifo_data_out(9 downto 5) & '0';
            VIDEO_B <= fifo_data_out(14 downto 10) & '0';
         Else
            VIDEO_R <= fifo_data_out(20 downto 16) & '0';
            VIDEO_G <= fifo_data_out(25 downto 21) & '0';
            VIDEO_B <= fifo_data_out(30 downto 26) & '0';
         End If;
      End If;
   END PROCESS;
End Generate;

G_8 : If PIXEL_WIDTH = 8 Generate
   PROCESS(VIDEO_CLK)    -- 8 bits data - go through the LUT (will be added later)
   BEGIN
      If VIDEO_CLK'event And VIDEO_CLK = '1' Then
         If de_cnt = 0 Then
            video_d <= fifo_data_out(31 downto 24);
         ElsIf de_cnt = 1 Then
            video_d <= fifo_data_out(23 downto 16);
         ElsIf de_cnt = 2 Then 
            video_d <= fifo_data_out(15 downto 8);
         Else
            video_d <= fifo_data_out(7 downto 0);
         End If;
      End If;
   END PROCESS;

   VIDEO_R <= video_d;
   VIDEO_G <= video_d;
   VIDEO_B <= video_d;

End Generate;


X_0 <= XXX(0);
X_1 <= XXX(1);
X_2 <= XXX(2);
X_3 <= XXX(3);


end implementation;

