----------------------------------------------------------------------
----                                                              ----
---- Main Graphics controller                                     ----
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

entity graphic is
Generic(
   C_FAMILY                : string := "virtex5";
   C_VD_DATA_WIDTH         : integer := 64;
   PIXEL_DEPTH             : integer := 6;
   PIXEL_WIDTH             : natural := 32;

   C_VD_V_POL              : std_logic := '0';
   C_VCNT_SIZE             : natural := 10;
   C_VBACK_PORCH           : natural := 25+8;
   C_VFRONT_PORCH          : natural := 2+8;
   C_VVIDEO_ACTIVE         : natural := 480;
   C_VSYNC_PULSE           : natural := 2;

   C_VD_H_POL              : std_logic := '0';
   C_HCNT_SIZE             : natural := 10;
   C_HBACK_PORCH           : natural := 40+8;
   C_HFRONT_PORCH          : natural := 8+8+31;
   C_HVIDEO_ACTIVE         : natural := 640;
   C_HSYNC_PULSE           : natural := 96);

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
   VIDEO_R                 : out    std_logic_vector(PIXEL_DEPTH - 1 downto 0);
   VIDEO_G                 : out    std_logic_vector(PIXEL_DEPTH - 1 downto 0);
   VIDEO_B                 : out    std_logic_vector(PIXEL_DEPTH - 1 downto 0);
   INTR                    : out    std_logic;
   
   DMA_INIT                : in     std_logic;
   DMA_DACK                : in     std_logic;
   DMA_DATA                : in     std_logic_vector(C_VD_DATA_WIDTH - 1 downto 0);
   DMA_DREQ                : out    std_logic;
   DMA_RSYNC               : out    std_logic;
   DMA_TC                  : in     std_logic;

   GR_DATA_I               : in     std_logic_vector(31 downto 0);
   GR_DATA_O               : out    std_logic_vector(31 downto 0);
   GR_ADDR                 : in     std_logic_vector(15 downto 0);
   GR_RNW                  : in     std_logic;
   GR_CS                   : in     std_logic;                  

   X                       : out    std_logic_vector(7 downto 0));
end graphic;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------
architecture implementation of graphic is

component video_ctrl is
Generic(

   C_FAMILY             : string;
   PIXEL_DEPTH          : integer;

   C_VCNT_SIZE          : natural;
   C_VBACK_PORCH        : natural;
   C_VFRONT_PORCH       : natural;
   C_VVIDEO_ACTIVE      : natural;
   C_VSYNC_PULSE        : natural;

   C_HCNT_SIZE          : natural;
   C_HBACK_PORCH        : natural;
   C_HFRONT_PORCH       : natural;
   C_HVIDEO_ACTIVE      : natural;
   C_HSYNC_PULSE        : natural);
port (
   -- System interface      
   Sys_Rst                       : in     std_logic;                    -- System reset

   VSYNC_POL                     : in     std_logic;
   HSYNC_POL                     : in     std_logic;
   DE_POL                        : in     std_logic;

   X_HSYNC_DELAY                 : in     std_logic_vector(3 downto 0);
   X_VSYNC_DELAY                 : in     std_logic_vector(3 downto 0);
   X_DE_DELAY                    : in     std_logic_vector(3 downto 0);

   VSYNC                         : out    std_logic;
   HSYNC                         : out    std_logic;
   DE                            : out    std_logic;
   VSYNC_VALUE                   : out    std_logic_vector(C_VCNT_SIZE - 1 downto 0);
   HSYNC_VALUE                   : out    std_logic_vector(C_HCNT_SIZE - 1 downto 0);
   LAST_LINE                     : out    std_logic;
   FRAME_END                     : out    std_logic;

   VIDEO_EN                      : in     std_logic;
   VIDEO_DATA_R                  : in     std_logic_vector(PIXEL_DEPTH - 1 downto 0);
   VIDEO_DATA_G                  : in     std_logic_vector(PIXEL_DEPTH - 1 downto 0);
   VIDEO_DATA_B                  : in     std_logic_vector(PIXEL_DEPTH - 1 downto 0);
   VIDEO_CLK_IN                  : in     std_logic;                    -- LCD Clock signal
   VIDEO_VSYNC                   : out    std_logic;
   VIDEO_HSYNC                   : out    std_logic;
   VIDEO_DE                      : out    std_logic;
   VIDEO_CLK_OUT                 : out    std_logic;
   VIDEO_R                       : out    std_logic_vector(PIXEL_DEPTH - 1 downto 0);
   VIDEO_G                       : out    std_logic_vector(PIXEL_DEPTH - 1 downto 0);
   VIDEO_B                       : out    std_logic_vector(PIXEL_DEPTH - 1 downto 0);

   X_0                           : out    std_logic;
   X_1                           : out    std_logic;
   X_2                           : out    std_logic;
   X_3                           : out    std_logic;
   X_4                           : out    std_logic;
   X_5                           : out    std_logic);

end component;

component data_rgb is
Generic(
   C_FAMILY                      : string;
   C_VD_DATA_WIDTH               : integer;
   V_CNT_SIZE                    : integer;
   H_CNT_SIZE                    : integer;
   PIXEL_WIDTH                   : natural;
   PIXEL_DEPTH                   : integer);
port (
   -- System interface      
   Sys_Rst                       : in     std_logic;                    -- System reset
   NPI_CLK                       : in     std_logic;
   Sys_Clk                       : in     std_logic;
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
end component;


constant VCC                     : std_logic := '1';
constant GND                     : std_logic := '0';

signal line_e_i                  : std_logic;

signal frame_end                 : std_logic;

signal lcd_en_i                  : std_logic;

signal vsync_value               : std_logic_vector(C_VCNT_SIZE - 1 downto 0);
signal hsync_value               : std_logic_vector(C_HCNT_SIZE - 1 downto 0);
signal hsync_i                   : std_logic;
signal vsync_i                   : std_logic;
signal de_i                      : std_logic;

-- OPB signals section

signal video_data_in             : std_logic_vector((3 * PIXEL_DEPTH) - 1 downto 0);

signal x_hsync_delay             : std_logic_vector(3 downto 0);
signal x_vsync_delay             : std_logic_vector(3 downto 0);
signal x_de_delay                : std_logic_vector(3 downto 0);

signal row_position              : std_logic_vector(C_VCNT_SIZE - 1 downto 0);
signal col_position              : std_logic_vector(C_HCNT_SIZE - 1 downto 0);

signal last_line                 : std_logic;
signal video_en                  : std_logic;

signal video_en_video_clk        : std_logic;
signal video_en_i_video_clk      : std_logic;
signal video_en_p_video_clk      : std_logic;

-- Service signals
signal V_CTRL_X0                 : std_logic;
signal V_CTRL_X1                 : std_logic;
signal V_CTRL_X2                 : std_logic;
signal V_CTRL_X3                 : std_logic;
signal V_CTRL_X4                 : std_logic;
signal V_CTRL_X5                 : std_logic;

-- Fifo signals
signal dreq_i                    : std_logic;
signal dack_i                    : std_logic;
signal rsync                     : std_logic;
signal tc_i                      : std_logic;
signal data_in                   : std_logic_vector(31 downto 0);
signal user_rst                  : std_logic;
signal fifo_data_out             : std_logic_vector(31 downto 0);
signal fifo_init                 : std_logic;

signal ch0_r                     : std_logic_vector(PIXEL_DEPTH - 1 downto 0);
signal ch0_g                     : std_logic_vector(PIXEL_DEPTH - 1 downto 0);
signal ch0_b                     : std_logic_vector(PIXEL_DEPTH - 1 downto 0);
signal ch0_a                     : std_logic_vector(PIXEL_DEPTH - 1 downto 0);
signal ch0_int                   : std_logic;

-- Control Registers and bit aliases
signal video_ctrl_reg            : std_logic_vector(31 downto 0) := (Others => '0');

signal xxx                       : std_logic_vector(3 downto 0);
signal xxx_1                     : std_logic_vector(3 downto 0);

signal ctrl_data                 : std_logic_vector(31 downto 0);
signal ctrl_addr                 : std_logic_vector(31 downto 0);
signal ctrl_wr                   : std_logic;

signal delay_cnt                 : std_logic_vector(20 downto 0);
signal video_en_e                : std_logic;

BEGIN

-- Fifo instance and DMA CTRL

user_rst <= Not video_en_video_clk;
--user_read <= '0';

CH0_FIFO_I : data_rgb
Generic map (
   C_FAMILY                      => C_FAMILY,
   C_VD_DATA_WIDTH               => C_VD_DATA_WIDTH,
   V_CNT_SIZE                    => C_VCNT_SIZE,
   H_CNT_SIZE                    => C_HCNT_SIZE,
   PIXEL_WIDTH                   => PIXEL_WIDTH,
   PIXEL_DEPTH                   => PIXEL_DEPTH)
port map (
   -- System interface      
   Sys_Rst                       => Sys_Rst,
   NPI_CLK                       => NPI_CLK,

   Sys_Clk                       => Sys_Clk,
   VIDEO_CLK                     => VIDEO_CLK,
   VIDEO_DE                      => de_i,
   VIDEO_EN                      => video_en_video_clk,

   VIDEO_R                       => ch0_r,
   VIDEO_G                       => ch0_g,
   VIDEO_B                       => ch0_b,
   VIDEO_A                       => ch0_a,

   INTR                          => ch0_int,

   DMA_INIT                      => DMA_INIT,
   DMA_DACK                      => DMA_DACK,
   DMA_DATA                      => DMA_DATA,
   DMA_DREQ                      => DMA_DREQ,
   DMA_RSYNC                     => DMA_RSYNC,
   DMA_TC                        => DMA_TC,

   X_0                           => open,
   X_1                           => open,
   X_2                           => open,
   X_3                           => open,
   X_4                           => open,
   X_5                           => open);

x_hsync_delay <= conv_std_logic_vector(2, x_hsync_delay'length);
x_vsync_delay <= conv_std_logic_vector(2, x_vsync_delay'length);
x_de_delay <= conv_std_logic_vector(0, x_de_delay'length);

-- Video CTRL instance

PROCESS(sys_clk)
BEGIN
   If Sys_Rst = '1' Then
      delay_cnt <= (others => '1');
   ElsIf sys_clk'event And sys_clk = '1' Then
      If DMA_INIT = '0' Then
         delay_cnt <= (others => '1');
      ElsIf delay_cnt > 0 Then
         delay_cnt <= delay_cnt - 1;
      End If;
   video_en <= video_en_e;
   End If;
END PROCESS;

video_en_e <= '1' When delay_cnt = 0 Else '0'; --video_ctrl_reg(0);

res_video_en : entity work.resample_r 
port map(
   Clk   => VIDEO_CLK,
   Rst   => Sys_Rst,
   D_i   => video_en,
   D_o   => video_en_video_clk);

video_ctrl_i : video_ctrl
generic map (
   C_FAMILY                   => C_FAMILY,
   PIXEL_DEPTH                => PIXEL_DEPTH,

   C_VCNT_SIZE                => C_VCNT_SIZE,
   C_VBACK_PORCH              => C_VBACK_PORCH,
   C_VFRONT_PORCH             => C_VFRONT_PORCH,
   C_VVIDEO_ACTIVE            => C_VVIDEO_ACTIVE,
   C_VSYNC_PULSE              => C_VSYNC_PULSE,

   C_HCNT_SIZE                => C_HCNT_SIZE,
   C_HBACK_PORCH              => C_HBACK_PORCH,
   C_HFRONT_PORCH             => C_HFRONT_PORCH,
   C_HVIDEO_ACTIVE            => C_HVIDEO_ACTIVE,
   C_HSYNC_PULSE              => C_HSYNC_PULSE)

port map (
   -- System interface      
   Sys_Rst                       => SYS_RST,                    -- System reset

   VSYNC_POL                     => C_VD_V_POL,
   HSYNC_POL                     => C_VD_H_POL,
   DE_POL                        => VCC,

   X_HSYNC_DELAY                 => x_hsync_delay,
   X_VSYNC_DELAY                 => x_vsync_delay,
   X_DE_DELAY                    => x_de_delay,

   VSYNC                         => vsync_i,
   HSYNC                         => hsync_i,
   DE                            => de_i,
   VSYNC_VALUE                   => row_position,
   HSYNC_VALUE                   => col_position,
   LAST_LINE                     => last_line,
   FRAME_END                     => frame_end,

   VIDEO_EN                      => video_en_video_clk,
   VIDEO_DATA_R                  => ch0_r,
   VIDEO_DATA_G                  => ch0_g,
   VIDEO_DATA_B                  => ch0_b,
   VIDEO_CLK_IN                  => VIDEO_CLK,
   VIDEO_VSYNC                   => VIDEO_VSYNC,
   VIDEO_HSYNC                   => VIDEO_HSYNC,
   VIDEO_DE                      => VIDEO_DE,
   VIDEO_CLK_OUT                 => VIDEO_CLK_OUT,
   VIDEO_R                       => VIDEO_R,
   VIDEO_G                       => VIDEO_G,
   VIDEO_B                       => VIDEO_B,

   X_0                           => V_CTRL_X0,
   X_1                           => V_CTRL_X1,
   X_2                           => V_CTRL_X2,
   X_3                           => V_CTRL_X3,
   X_4                           => V_CTRL_X4,
   X_5                           => V_CTRL_X5);


end implementation;

