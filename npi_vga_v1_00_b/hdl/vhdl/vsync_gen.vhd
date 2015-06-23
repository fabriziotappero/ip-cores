----------------------------------------------------------------------
----                                                              ----
---- Vertical sync generator                                      ----
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vsync_gen is
   Generic(
      C_VCNT_SIZE          : natural := 11;
      C_BACK_PORCH         : natural := 25+8;
      C_FRONT_PORCH        : natural := 2+8;
      C_VIDEO_ACTIVE       : natural := 480;
      C_VSYNC_PULSE        : natural := 2);
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
end vsync_gen;

architecture Behavioral of vsync_gen is

constant c_frame           : std_logic_vector(C_VCNT_SIZE - 1 downto 0) := 
                             CONV_STD_LOGIC_VECTOR(C_BACK_PORCH + C_FRONT_PORCH
                             + C_VIDEO_ACTIVE + C_VSYNC_PULSE, C_VCNT_SIZE);


signal line_cnt            : std_logic_vector(C_VCNT_SIZE - 1 downto 0);
signal vsync_i             : std_logic;
signal de_i                : std_logic;
signal frame_rst           : std_logic;
signal rst_i               : std_logic;
signal last_line_i         : std_logic;

begin

rst_i <= frame_rst Or Not LCD_EN;

PROCESS(CLK, rst_i, line_cnt, LINE_E)
BEGIN
   If RST = '1' Then
      line_cnt <= (Others => '0');
   ElsIf CLK'event And CLK = '1' Then
      If rst_i = '1' Then
         line_cnt <= (Others => '0');
      ElsIf LINE_E = '1' Then
         line_cnt <= line_cnt + '1';
      End If;
   End If;
END PROCESS;

last_line_i <= '0' When line_cnt < c_frame - 1 Else '1' after 1 ns;
vsync_i <= '1' When (line_cnt >= 0) And (line_cnt < C_VSYNC_PULSE) Else '0';
de_i <= '1' When (line_cnt >= C_VSYNC_PULSE + C_BACK_PORCH) And (line_cnt < 
                  C_VSYNC_PULSE + C_BACK_PORCH + C_VIDEO_ACTIVE) Else '0';

frame_rst <= last_line_i And LINE_E;

VSYNC <= vsync_i;
V_DE <= de_i;
FRAME_E <= frame_rst;
VSYNC_VALUE <= line_cnt;
LAST_LINE <= last_line_i;

end Behavioral;

