------------------------------------------------------------------
-- Universal dongle board source code
-- 
-- Copyright (C) 2006 Artec Design <jyrit@artecdesign.ee>
-- 
-- This source code is free hardware; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
-- 
-- This source code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
-- 
-- 
-- The complete text of the GNU Lesser General Public License can be found in 
-- the file 'lesser.txt'.



--                   bit 0,A
--                 ----------
--                |          |
--                |          |
--             5,F|          |  1,B
--                |    6,G   |
--                 ----------
--                |          |
--                |          |
--             4,E|          |  2,C
--                |    3,D   |
--                 ----------  
--                              # 7,H


-- Select signal order
--   ---    ---      ---    --- 
--  |   |  |   |    |   |  |   |  
--  |   |  |   |    |   |  |   |
--   ---    ---      ---    ---
--  |   |  |   |    |   |  |   |
--  |   |  |   |    |   |  |   |
--   ---    ---      ---    ---
--  sel(3) sel(2)   sel(1) sel(0)



library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity byte_scan is
  port (
    clk          : in std_logic;
    hi_seg_1     : in std_logic_vector(7 downto 0);
    lo_seg_1     : in std_logic_vector(7 downto 0);
    hi_seg_0     : in std_logic_vector(7 downto 0);
    lo_seg_0     : in std_logic_vector(7 downto 0);    
    seg_out      : out std_logic_vector(7 downto 0);
    sel_out      : out std_logic_vector(3 downto 0)
    );
end byte_scan;

architecture rtl of byte_scan is

signal sel_p : std_logic_vector(3 downto 0);
signal count : std_logic_vector(1 downto 0):="00";  
signal hi_seg_1_3 : std_logic_vector(7 downto 0);
signal lo_seg_1_3 : std_logic_vector(7 downto 0);
signal hi_seg_0_2 : std_logic_vector(7 downto 0);
signal lo_seg_0_2 : std_logic_vector(7 downto 0);

begin  -- rtl


hi_seg_1_3 <= hi_seg_1; -- when sel_hib_n ='1' else hi_seg_3;
lo_seg_1_3 <= lo_seg_1; --when sel_hib_n ='1' else lo_seg_3;
hi_seg_0_2 <= hi_seg_0; --when sel_hib_n ='1' else hi_seg_2;
lo_seg_0_2 <= lo_seg_0; --when sel_hib_n ='1' else lo_seg_2;

  
seg_out <=hi_seg_1_3  when count="01" else 
		  lo_seg_1_3  when count="10" else 
		  hi_seg_0_2  when count="11" else
		  lo_seg_0_2  when count="00";

sel_out <= sel_p;

sel_p <= "1110" when count="00" else
		 "0111" when count="01" else
		 "1011" when count="10" else
		 "1101" when count="11";




process (clk)  --enable the scanning while in reset (simulation will be incorrect)
begin  -- process
  if clk'event and clk = '1' then    -- rising clock edge
	 count <= count + 1;
  end if;
end process;

end rtl;
