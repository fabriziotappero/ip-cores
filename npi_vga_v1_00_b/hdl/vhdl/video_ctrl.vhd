----------------------------------------------------------------------
----                                                              ----
---- Video Control Module                                         ----
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

entity video_ctrl is
Generic(
   C_FAMILY             : string := "virtex5";
   PIXEL_DEPTH          : integer := 6;

   C_VCNT_SIZE          : natural := 10;
   C_VBACK_PORCH        : natural := 25+8;
   C_VFRONT_PORCH       : natural := 2+8;
   C_VVIDEO_ACTIVE      : natural := 480;
   C_VSYNC_PULSE        : natural := 2;

   C_HCNT_SIZE          : natural := 10;
   C_HBACK_PORCH        : natural := 40+8;
   C_HFRONT_PORCH       : natural := 8+8+31;
   C_HVIDEO_ACTIVE      : natural := 640;
   C_HSYNC_PULSE        : natural := 96);

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

end video_ctrl;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------
architecture implementation of video_ctrl is

constant arch : string := "SPARTAN";

component hsync_gen is
Generic (
   C_HCNT_SIZE          : natural;
   C_BACK_PORCH         : natural;
   C_FRONT_PORCH        : natural;
   C_VIDEO_ACTIVE       : natural;
   C_HSYNC_PULSE        : natural);
Port (
   CLK                  : in     std_logic;
   RST                  : in     std_logic;
      
   HSYNC_VALUE          : out    std_logic_vector(C_HCNT_SIZE - 1 downto 0);
   HSYNC_EN             : in     std_logic;
   LINE_E               : out    std_logic;
   DE                   : out    std_logic;
   HSYNC                : out    std_logic);
end component;

component vsync_gen is
Generic(
   C_VCNT_SIZE          : natural;
   C_BACK_PORCH         : natural;
   C_FRONT_PORCH        : natural;
   C_VIDEO_ACTIVE       : natural;
   C_VSYNC_PULSE        : natural);
Port(
   CLK                  : in     std_logic;
   RST                  : in     std_logic;
   VSYNC_VALUE          : out    std_logic_vector(C_VCNT_SIZE - 1 downto 0);
   LCD_EN               : in     std_logic;
   LINE_E               : in     std_logic;
   FRAME_E              : out    std_logic;
   LAST_LINE            : out    std_logic;
   V_DE                 : out    std_logic;
   VSYNC                : out    std_logic);
end component;

component video_clk_gen is
Generic (
   POLARITY             : natural);                       -- Define polarity of the output clock signal
port (
   CLK                  : in     std_logic;                    -- Input clock
   RST                  : in     std_logic;                    -- System reset
   CLK_OUT              : out    std_logic);
end component;

component video_clk_gen_v4 is
Generic (
   POLARITY             : natural);                       -- Define polarity of the output clock signal
port (
   CLK                  : in     std_logic;                    -- Input clock
   RST                  : in     std_logic;                    -- System reset
   CLK_OUT              : out    std_logic);
end component;

component delay is
port (
   CLK                  : in     std_logic;                    -- Input clock
   ADD_DELAY            : in     std_logic_vector(3 downto 0);
   D_IN                 : in     std_logic;
   D_OUT                : out    std_logic);
end component;

constant R_MSB                   : natural := 0;
constant G_MSB                   : natural := 6;
constant B_MSB                   : natural := 12;

constant VCC                     : std_logic := '1';
constant GND                     : std_logic := '0';

signal line_e_i                  : std_logic;
signal hsync_de                  : std_logic;
signal hsync_i                   : std_logic;
signal hsync_d                   : std_logic;
signal vsync_de                  : std_logic;
signal vsync_i                   : std_logic;
signal vsync_d                   : std_logic;

signal de_i                      : std_logic;
signal de_d                      : std_logic;

BEGIN

gen_sp_cp : If (C_FAMILY = "spartan3e") Or (C_FAMILY = "spartan3a") generate
begin
   video_clk_gen_i : entity video_clk_gen
   Generic map (
      POLARITY             => 1)                       -- Define polarity of the output clock signal
   port map (
      CLK                  => VIDEO_CLK_IN,                    -- Input clock
      RST                  => sys_rst,                    -- System reset
      CLK_OUT              => VIDEO_CLK_OUT);
end generate;

gen_v_cp : If (C_FAMILY = "virtex4") Or (C_FAMILY = "virtex5fx") Or  
              (C_FAMILY = "virtex5lx") generate
begin

   video_clk_gen_i : entity video_clk_gen_v4
   Generic map (
      POLARITY             => 1)                       -- Define polarity of the output clock signal
   port map (
      CLK                  => VIDEO_CLK_IN,                    -- Input clock
      RST                  => sys_rst,                    -- System reset
      CLK_OUT              => VIDEO_CLK_OUT);

end generate;

hsync_g : hsync_gen
Generic map (
   C_HCNT_SIZE          => C_HCNT_SIZE,
   C_BACK_PORCH         => C_HBACK_PORCH,
   C_FRONT_PORCH        => C_HFRONT_PORCH,
   C_VIDEO_ACTIVE       => C_HVIDEO_ACTIVE,
   C_HSYNC_PULSE        => C_HSYNC_PULSE)
Port map(
   CLK                  => VIDEO_CLK_IN,
   RST                  => sys_rst,
   HSYNC_VALUE          => hsync_value,
   HSYNC_EN             => VIDEO_EN,
   LINE_E               => line_e_i,
   DE                   => hsync_de,
   HSYNC                => hsync_i);

hsync_delay : delay
port map (
   CLK                  => VIDEO_CLK_IN,
   ADD_DELAY            => X_HSYNC_DELAY,
   D_IN                 => hsync_i,
   D_OUT                => hsync_d);

vsync_g : vsync_gen
Generic map (
   C_VCNT_SIZE          => C_VCNT_SIZE,
   C_BACK_PORCH         => C_VBACK_PORCH,
   C_FRONT_PORCH        => C_VFRONT_PORCH,
   C_VIDEO_ACTIVE       => C_VVIDEO_ACTIVE,
   C_VSYNC_PULSE        => C_VSYNC_PULSE)
Port map(
   CLK                  => VIDEO_CLK_IN,
   RST                  => sys_rst,
   VSYNC_VALUE          => vsync_value,
   LCD_EN               => VIDEO_EN,
   LINE_E               => line_e_i,
   FRAME_E              => frame_end,
   LAST_LINE            => last_line,      
   V_DE                 => vsync_de,
   VSYNC                => vsync_i);

vsync_delay : delay
port map (
   CLK                  => VIDEO_CLK_IN,
   ADD_DELAY            => X_VSYNC_DELAY,
   D_IN                 => vsync_i,
   D_OUT                => vsync_d);

de_i <= vsync_de And hsync_de;      -- Valid video
DE <= de_i;

de_delay : delay
port map (
   CLK                  => VIDEO_CLK_IN,
   ADD_DELAY            => X_DE_DELAY,
   D_IN                 => de_i,
   D_OUT                => de_d);

GEN_VSYNC_OUT : PROCESS(VIDEO_CLK_IN, VSYNC_POL, vsync_d)
BEGIN
   If VIDEO_CLK_IN'event And VIDEO_CLK_IN = '1' Then
      If VSYNC_POL = '1' Then
         VIDEO_VSYNC <= vsync_d;
      Else
         VIDEO_VSYNC <= Not vsync_d;
      End If;
   End If;
END PROCESS;

GEN_HSYNC_OUT : PROCESS(VIDEO_CLK_IN, HSYNC_POL, hsync_d)
BEGIN
   If VIDEO_CLK_IN'event And VIDEO_CLK_IN = '1' Then
      If HSYNC_POL = '1' Then
         VIDEO_HSYNC <= hsync_d;
      Else
         VIDEO_HSYNC <= Not hsync_d;
      End If;
   End If;
END PROCESS;

GEN_DE_OUT : PROCESS(VIDEO_CLK_IN, DE_POL, de_d)
BEGIN
   If VIDEO_CLK_IN'event And VIDEO_CLK_IN = '1' Then
      If DE_POL = '1' Then
         VIDEO_DE <= de_d;
      Else
         VIDEO_DE <= Not de_d;
      End If;
   End If;
END PROCESS;

GEN_DATA_OUT : PROCESS(VIDEO_CLK_IN, DE_POL, de_d)
BEGIN
   If Sys_Rst = '1' Then
      VIDEO_R <= (Others => '0');
      VIDEO_G <= (Others => '0');
      VIDEO_B <= (Others => '0');
   ElsIf VIDEO_CLK_IN'event And VIDEO_CLK_IN = '1' Then
      If de_d = '1' Then
         VIDEO_R <= VIDEO_DATA_R;
         VIDEO_G <= VIDEO_DATA_G;
         VIDEO_B <= VIDEO_DATA_B;
      Else
         VIDEO_R <= (Others => '0');
         VIDEO_G <= (Others => '0');
         VIDEO_B <= (Others => '0');
      End If;
   End If;
END PROCESS;

end implementation;


