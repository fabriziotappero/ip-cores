--------------------------------------------------------------------------------
----                                                                        ----
---- This file is part of the yaVGA project                                 ----
---- http://www.opencores.org/?do=project&who=yavga                         ----
----                                                                        ----
---- Description                                                            ----
---- Implementation of yaVGA IP core                                        ----
----                                                                        ----
---- To Do:                                                                 ----
----                                                                        ----
----                                                                        ----
---- Author(s):                                                             ----
---- Sandro Amato, sdroamt@netscape.net                                     ----
----                                                                        ----
--------------------------------------------------------------------------------
----                                                                        ----
---- Copyright (c) 2009, Sandro Amato                                       ----
---- All rights reserved.                                                   ----
----                                                                        ----
---- Redistribution  and  use in  source  and binary forms, with or without ----
---- modification,  are  permitted  provided that  the following conditions ----
---- are met:                                                               ----
----                                                                        ----
----     * Redistributions  of  source  code  must  retain the above        ----
----       copyright   notice,  this  list  of  conditions  and  the        ----
----       following disclaimer.                                            ----
----     * Redistributions  in  binary form must reproduce the above        ----
----       copyright   notice,  this  list  of  conditions  and  the        ----
----       following  disclaimer in  the documentation and/or  other        ----
----       materials provided with the distribution.                        ----
----     * Neither  the  name  of  SANDRO AMATO nor the names of its        ----
----       contributors may be used to  endorse or  promote products        ----
----       derived from this software without specific prior written        ----
----       permission.                                                      ----
----                                                                        ----
---- THIS SOFTWARE IS PROVIDED  BY THE COPYRIGHT  HOLDERS AND  CONTRIBUTORS ----
---- "AS IS"  AND  ANY EXPRESS OR  IMPLIED  WARRANTIES, INCLUDING,  BUT NOT ----
---- LIMITED  TO, THE  IMPLIED  WARRANTIES  OF MERCHANTABILITY  AND FITNESS ----
---- FOR  A PARTICULAR  PURPOSE  ARE  DISCLAIMED. IN  NO  EVENT  SHALL  THE ----
---- COPYRIGHT  OWNER  OR CONTRIBUTORS  BE LIABLE FOR ANY DIRECT, INDIRECT, ----
---- INCIDENTAL,  SPECIAL,  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, ----
---- BUT  NOT LIMITED  TO,  PROCUREMENT OF  SUBSTITUTE  GOODS  OR SERVICES; ----
---- LOSS  OF  USE,  DATA,  OR PROFITS;  OR  BUSINESS INTERRUPTION) HOWEVER ----
---- CAUSED  AND  ON  ANY THEORY  OF LIABILITY, WHETHER IN CONTRACT, STRICT ----
---- LIABILITY,  OR  TORT  (INCLUDING  NEGLIGENCE  OR OTHERWISE) ARISING IN ----
---- ANY  WAY OUT  OF THE  USE  OF  THIS  SOFTWARE,  EVEN IF ADVISED OF THE ----
---- POSSIBILITY OF SUCH DAMAGE.                                            ----
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package yavga_pkg is

-- Declare constants

  -- chars address and data bus size
  constant c_CHR_ADDR_BUS_W : integer := 11;
  constant c_CHR_DATA_BUS_W : integer := 32;
  constant c_CHR_WE_BUS_W   : integer := 4;

  -- internal used chars address and data bus size 
  constant c_INTCHR_ADDR_BUS_W : integer := 13;
  constant c_INTCHR_DATA_BUS_W : integer := 8;

  -- internal ROM chmaps address and data bus
  constant c_INTCHMAP_ADDR_BUS_W : integer := 11;
  constant c_INTCHMAP_DATA_BUS_W : integer := 8;

  -- waveform address and data bus size
  constant c_WAVFRM_ADDR_BUS_W : integer := 10;
  constant c_WAVFRM_DATA_BUS_W : integer := 16;

  constant c_GRID_SIZE : std_logic_vector(6 downto 0) := "1111111";
  constant c_GRID_BIT  : integer                      := 6;

  --
  -- horizontal timing signals (in pixels count )
  constant c_H_DISPLAYpx    : integer := 800;
  constant c_H_BACKPORCHpx  : integer := 63;  -- also 60;
  constant c_H_SYNCTIMEpx   : integer := 120;
  constant c_H_FRONTPORCHpx : integer := 56;  --also 60;
  constant c_H_PERIODpx     : integer := c_H_DISPLAYpx +
                                         c_H_BACKPORCHpx +
                                         c_H_SYNCTIMEpx +
                                         c_H_FRONTPORCHpx;
  constant c_H_COUNT_W : integer := 11;       -- = ceil(ln2(c_H_PERIODpx))

  --
  -- vertical timing signals (in lines count)
  constant c_V_DISPLAYln    : integer := 600;
  constant c_V_BACKPORCHln  : integer := 23;
  constant c_V_SYNCTIMEln   : integer := 6;
  constant c_V_FRONTPORCHln : integer := 37;
  constant c_V_PERIODln     : integer := c_V_DISPLAYln +
                                         c_V_BACKPORCHln +
                                         c_V_SYNCTIMEln +
                                         c_V_FRONTPORCHln;
  constant c_V_COUNT_W : integer := 10;  -- = ceil(ln2(c_V_PERIODln))

  constant c_X_W : integer := c_H_COUNT_W;
  constant c_Y_W : integer := c_V_COUNT_W;

--  constant c_CHARS_WIDTH: std_logic_vector(2 downto 0) := "111";
--  constant c_CHARS_HEIGHT: std_logic_vector(3 downto 0) := "1111";
--  constant c_CHARS_COLS: std_logic_vector(6 downto 0) := "1100011";
--  constant c_CHARS_ROWS: std_logic_vector(5 downto 0) := "100100";

  -- to manage the background and cursor colors
  constant c_CFG_BG_CUR_COLOR_ADDR : std_logic_vector(12 downto 0) := "0000001101100";  -- 108 BG:5..3 CUR:2..0

  -- to manage the cursor position  
  constant c_CFG_CURS_XY1 : std_logic_vector(12 downto 0) := "0000001101101";  -- 109
  constant c_CFG_CURS_XY2 : std_logic_vector(12 downto 0) := "0000001101110";  -- 110
  constant c_CFG_CURS_XY3 : std_logic_vector(12 downto 0) := "0000001101111";  -- 111
  
end yavga_pkg;


package body yavga_pkg is

end yavga_pkg;
