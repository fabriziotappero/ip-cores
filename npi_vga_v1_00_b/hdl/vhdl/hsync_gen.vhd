----------------------------------------------------------------------
----                                                              ----
---- Horizontal generator                                         ----
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity hsync_gen is
Generic (
      C_HCNT_SIZE          : natural := 11;
      C_BACK_PORCH         : natural := 40+8;
      C_FRONT_PORCH        : natural := 8+8;
      C_VIDEO_ACTIVE       : natural := 640;
      C_HSYNC_PULSE        : natural := 96);
Port (
      CLK                  : in     std_logic;
      RST                  : in     std_logic;
      
      HSYNC_VALUE          : out    std_logic_vector(C_HCNT_SIZE - 1 downto 0);
      HSYNC_EN             : in     std_logic;
      LINE_E               : out    std_logic;
      DE                   : out    std_logic;
      HSYNC                : out    std_logic);
end hsync_gen;

architecture Behavioral of hsync_gen is

constant c_scan_line       : std_logic_vector(C_HCNT_SIZE - 1 downto 0) := 
                             CONV_STD_LOGIC_VECTOR(C_BACK_PORCH + C_FRONT_PORCH +
                             C_VIDEO_ACTIVE + C_HSYNC_PULSE, C_HCNT_SIZE);

signal pixel_cnt           : std_logic_vector(C_HCNT_SIZE - 1 downto 0);
signal hsync_i             : std_logic;
signal de_i                : std_logic;
signal line_rst            : std_logic;
signal rst_i               : std_logic;

begin

rst_i <= line_rst Or (Not HSYNC_EN);

hsync_cnt : PROCESS(CLK, rst_i, pixel_cnt)
BEGIN
   If RST = '1' Then
      pixel_cnt <= (Others => '0');
   ElsIf CLK'event And CLK = '1' Then
      If rst_i = '1' Then
         pixel_cnt <= (Others => '0');
      Else
         pixel_cnt <= pixel_cnt + 1;
      End If;
   End If;
END PROCESS;

line_rst <= '0' When pixel_cnt < c_scan_line - 1 Else '1' after 1 ns;
hsync_i <= '1' When (pixel_cnt >= 0) And (pixel_cnt < C_HSYNC_PULSE) Else '0';
de_i <= '1' When (pixel_cnt >= C_HSYNC_PULSE + C_BACK_PORCH) And (pixel_cnt < 
                  C_HSYNC_PULSE + C_BACK_PORCH + C_VIDEO_ACTIVE) Else '0';

HSYNC <= hsync_i;
DE <= de_i;
LINE_E <= line_rst;
HSYNC_VALUE <= pixel_cnt;

end Behavioral;

