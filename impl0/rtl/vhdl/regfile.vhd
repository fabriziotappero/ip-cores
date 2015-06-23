--------------------------------------------------------------
-- regfile.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: register file with async read and sync write operations 
--
-- dependency: none 
--
-- Author: M. Umair Siddiqui (umairsiddiqui@opencores.org)
---------------------------------------------------------------
------------------------------------------------------------------------------------
--                                                                                --
--    Copyright (c) 2005, M. Umair Siddiqui all rights reserved                   --
--                                                                                --
--    This file is part of HPC-16.                                                --
--                                                                                --
--    HPC-16 is free software; you can redistribute it and/or modify              --
--    it under the terms of the GNU Lesser General Public License as published by --
--    the Free Software Foundation; either version 2.1 of the License, or         --
--    (at your option) any later version.                                         --
--                                                                                --
--    HPC-16 is distributed in the hope that it will be useful,                   --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of              --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               --
--    GNU Lesser General Public License for more details.                         --
--                                                                                --
--    You should have received a copy of the GNU Lesser General Public License    --
--    along with HPC-16; if not, write to the Free Software                       --
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   --
--                                                                                --
------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;


entity regfile is
   port(
      aadr : in std_logic_vector(3 downto 0);
      badr : in std_logic_vector(3 downto 0);
      ad : in std_logic_vector(15 downto 0);
      adwe : in std_logic;
      clk : in std_logic;
      aq : out std_logic_vector(15 downto 0);
      bq : out std_logic_vector(15 downto 0)
   );
end regfile;

architecture Behavioral of regfile is       
   type regfile_type is array(0 to 15) of std_logic_vector(15 downto 0);
   signal regfile_data : regfile_type;
begin
   process(clk)
   begin
      if rising_edge(clk) then
         if adwe = '1' then
            regfile_data(conv_integer(aadr)) <= ad;   
         end if;
      end if;
   end process;
   aq <= regfile_data(conv_integer(aadr));
   bq <= regfile_data(conv_integer(badr));
end Behavioral;
