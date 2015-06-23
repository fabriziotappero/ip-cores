--/**************************************************************************************************************
--*
--*    L Z R W 1   E N C O D E R   C O R E
--*
--*  A high throughput loss less data compression core.
--* 
--* Copyright 2012-2013   Lukas Schrittwieser (LS)
--*
--*    This program is free software: you can redistribute it and/or modify
--*    it under the terms of the GNU General Public License as published by
--*    the Free Software Foundation, either version 2 of the License, or
--*    (at your option) any later version.
--*
--*    This program is distributed in the hope that it will be useful,
--*    but WITHOUT ANY WARRANTY; without even the implied warranty of
--*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--*    GNU General Public License for more details.
--*
--*    You should have received a copy of the GNU General Public License
--*    along with this program; if not, write to the Free Software
--*    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
--*    Or see <http://www.gnu.org/licenses/>
--*
--***************************************************************************************************************
--*
--* Change Log:
--*
--* Version 1.0 - 2012/6/30 - LS
--*   started file
--*
--* Version 1.0 - 2013/04/05 - LS
--*   release
--*
--***************************************************************************************************************
--*
--* Naming convention:  http://dz.ee.ethz.ch/en/information/hdl-help/vhdl-naming-conventions.html
--*
--***************************************************************************************************************
--*
--* Compares a the look ahead buffer to a candidate and returns the number of bytes before the first
--* non-matching pair. The counting starts at the least significant end of the look ahead and the candidate
--*
--***************************************************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VComponents.all;

entity comparator is

  port (
    -- ClkxCI          : in  std_logic;
    -- RstxRI          : in  std_logic;
    -- EnxSI           : in  std_logic;
    LookAheadxDI    : in  std_logic_vector(16*8-1 downto 0);
    LookAheadLenxDI : in  integer range 0 to 16;  -- how many bytes of LookAheadxDI are valid 
    CandidatexDI    : in  std_logic_vector(16*8-1 downto 0);
    CandidateLenxDI : in  integer range 0 to 16;  -- how many bytes of CandidatexDI are valid
    MatchLenxDO     : out integer range 0 to 16);  -- length of the match in bytes

end comparator;



architecture Behavioral of comparator is

  signal MatchVectorxS : std_logic_vector(15 downto 0);  -- match signals for the individual bytes
  signal RawMatchLenxD : integer range 0 to 16;  -- number of matching bytes (before further processing)
  signal MaxLengthxD   : integer range 0 to 16;  -- smaller of the two input signal length;
begin

  -- implement 16 byte wide comparators
  genByteComps : for i in 0 to 15 generate
    MatchVectorxS(i) <= '1' when CandidatexDI((i+1)*8-1 downto i*8) = LookAheadxDI((i+1)*8-1 downto i*8) else '0';
  end generate genByteComps;

  -- count the number of leading bytes to determine the match length
  process (MatchVectorxS)
    variable cnt : integer range 0 to 16 := 0;
  begin  -- process
    cnt := 0;
    cntLoop : for i in 0 to 15 loop
      if MatchVectorxS(i) = '1' then
        cnt := cnt + 1;
      else
        exit cntLoop;
      end if;
    end loop;  -- i
    RawMatchLenxD <= cnt;
  end process;


-- the match length can not be longer than the shorter of the two data inputs
  MaxLengthxD <= CandidateLenxDI when CandidateLenxDI < LookAheadLenxDI else LookAheadLenxDI;

-- make sure the match length is not bigger than the max length
  MatchLenxDO <= RawMatchLenxD when RawMatchLenxD <= MaxLengthxD else MaxLengthxD;

end Behavioral;
