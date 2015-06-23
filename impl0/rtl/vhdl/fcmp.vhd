--------------------------------------------------------------
-- fcmp.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: helps in conditional execution of jump and interrupts 
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


entity fcmp is
   port( tttnField_in : in std_logic_vector(3 downto 0);       ---(COSZ)
         flags_in : in std_logic_vector(3 downto 0);
         result_out : out std_logic
       );
end fcmp;

architecture Behavioral of fcmp is
begin
   process(tttnField_in, flags_in) is 
      -----------------------------------------------------
      -- "refactored" on 14Jan2006
      -----------------------------------------------------
      variable CF_in : std_logic;
      variable OF_in : std_logic;
      variable SF_in : std_logic;
      variable ZF_in : std_logic;      
   begin
      CF_in := flags_in(3);
      OF_in := flags_in(2);
      SF_in := flags_in(1);
      ZF_in := flags_in(0);

      case tttnField_in is
         when "0000" => -- JO
            if OF_in = '1' then 
               result_out <= '1';
            else 
               result_out <= '0';
            end if; 
         when "0001" => -- JNO
            if OF_in = '0' then 
               result_out <= '1';
            else 
               result_out <= '0';
            end if; 
         when "0010" => -- JB or JNAE
            if CF_in = '1' then
               result_out <= '1';
            else 
               result_out <= '0';
            end if;
         when "0011" => -- JNB or JAE
            if CF_in = '0' then
               result_out <= '1';
            else 
               result_out <= '0';
            end if;                  
         when "0100" => -- JE or JZ
            if ZF_in = '1' then
               result_out <= '1';
            else 
               result_out <= '0';
            end if;           
         when "0101" => -- JNE or JNZ
            if ZF_in = '0' then
               result_out <= '1';
            else 
               result_out <= '0';
            end if;                 
         when "0110" => -- JBE or JNA
            if (CF_in or ZF_in) = '1' then
               result_out <= '1';
            else 
               result_out <= '0';
            end if;
         when "0111" => -- JNBE or JA
            if (CF_in or ZF_in) = '0' then
               result_out <= '1';
            else 
               result_out <= '0';
            end if;
         when "1000" => -- JS
            if SF_in = '1' then
               result_out <= '1';
            else 
               result_out <= '0';
            end if;
         when "1001" => -- JNS
            if SF_in = '0' then
               result_out <= '1';
            else 
               result_out <= '0';
            end if;
         when "1010" => 
            result_out <= '0';
         when "1011" =>
            result_out <= '0';
         when "1100" => -- JL or JNGE 
            if (SF_in xor OF_in) = '1' then
               result_out <= '1';
            else 
               result_out <= '0';
            end if;
         when "1101" => -- JNL or JGE
            if (SF_in xor OF_in) = '0' then
               result_out <= '1';
            else 
               result_out <= '0';
            end if;            
         when "1110" => -- JLE or JNG
            if ((SF_in xor OF_in) or ZF_in) = '1' then
               result_out <= '1';
            else 
               result_out <= '0';
            end if;
         when "1111" => -- JNLE or JG
            if ((SF_in xor OF_in) or ZF_in) = '0' then
               result_out <= '1';
            else 
               result_out <= '0';
            end if;
         when others =>
            result_out <= '0';
      end case;        
   end process;

end Behavioral;
