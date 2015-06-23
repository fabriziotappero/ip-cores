--------------------------------------------------------------
-- flags.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: FLAGS register implementation 
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

entity flags is
   port(

   Flags_in : in std_logic_vector(4 downto 0);
  
   CLK_in : in std_logic;   

   ResetAll_in : in std_logic;
   CE_in : in std_logic;
   CFCE_in : in std_logic;
   IFCE_in : in std_logic;
   CLC_in : in std_logic;
   CMC_in : in std_logic;
   STC_in : in std_logic;
   STI_in : in std_logic;
   CLI_in : in std_logic;

   Flags_out : out std_logic_vector(4 downto 0)

   );

end flags;

architecture Behavioral of flags is
   signal CF_in : std_logic;
   signal OF_in : std_logic;
   signal SF_in : std_logic;
   signal ZF_in : std_logic;
   signal IF_in : std_logic;
   signal CFout_temp : std_logic;
   signal OFout_temp : std_logic;
   signal SFout_temp : std_logic;
   signal ZFout_temp : std_logic;
   signal IFout_temp : std_logic;
begin
   
   (CF_in, OF_in, SF_in, ZF_in, IF_in) <= Flags_in;

   process(Clk_in, ResetAll_in) is 
   begin 
      if ResetAll_in = '1' then
         CFout_temp <= '0';
         OFout_temp <= '0';
         SFout_temp <= '0';
         ZFout_temp <= '0';
         IFout_temp <= '0';
      elsif rising_edge(CLK_in) then
         if    STI_in = '1' then
            IFout_temp <= '1';
         elsif CLI_in = '1' then
            IFout_temp <= '0';
         elsif STC_in = '1' then
            CFout_temp <= '1';
         elsif CLC_in = '1' then
            CFout_temp <= '0';
         elsif CMC_in = '1' then
            CFout_temp <= not CFout_temp;
         elsif CE_in = '1' then
            if CFCE_in = '1' then
               CFout_temp <= CF_in;
            end if; 
            if IFCE_in = '1' then
               IFout_temp <= IF_in;
            end if;
            SFout_temp <= SF_in;
            OFout_temp <= OF_in;
            ZFout_temp <= ZF_in;   
         end if;
      end if;
   end process;

   Flags_out <= (CFout_temp, OFout_temp, SFout_temp, ZFout_temp, IFout_temp);

end Behavioral;
