--------------------------------------------------------------
-- alu.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: ALU of microprocessor
--
-- dependency: log.vhd, arith.sch 
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

--Opsel_in--|--ALU Operation--
--000-------|--sub------------
--001-------|--add------------
--010-------|--sbb------------
--011-------|--adc------------
--100-------|--not------------
--101-------|--and------------
--110-------|--or-------------
--111-------|--xor------------

entity alu is
   port(   
   a     : in std_logic_vector(15 downto 0);
   b     : in std_logic_vector(15 downto 0);
   opsel : in std_logic_vector(2 downto 0);
   c_in : in std_logic;
   result: out std_logic_vector(15 downto 0);
   c_out: out std_logic;
   ofl_out: out std_logic
   );   
end alu;

architecture struct of alu is
   COMPONENT arith
   PORT(  c_out :   OUT STD_LOGIC; 
          ofl_out   :   OUT STD_LOGIC; 
          s0    :   IN  STD_LOGIC; 
          c_in  :   IN  STD_LOGIC; 
          s1    :   IN  STD_LOGIC; 
          a :   IN  STD_LOGIC_VECTOR (15 DOWNTO 0); 
          b :   IN  STD_LOGIC_VECTOR (15 DOWNTO 0); 
          result    :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
   END COMPONENT;

   component log 
   port (  a : in std_logic_vector(15 downto 0);
           b : in std_logic_vector(15 downto 0);
           s0 : in std_logic;
           s1 : in std_logic;
           result : out std_logic_vector(15 downto 0)
         );
   end component;
   
   signal cout_temp : std_logic;
   signal ofl_temp : std_logic;
   signal result_arith : std_logic_vector(15 downto 0);
   signal result_log : std_logic_vector(15 downto 0);
   signal result_temp : std_logic_vector(15 downto 0);

begin
   
   u1 : arith
   PORT map (  c_out => cout_temp,  
               ofl_out => ofl_temp,  
               s0 => opsel(0), 
               c_in => c_in, 
               s1 => opsel(1), 
               a => a, 
               b => b, 
               result => result_arith
            );
   

   u2 : log 
   port map (  a => a,
               b => b,
               s0 => opsel(0), 
               s1 => opsel(1),
               result => result_log
            );


   result_temp <= result_arith when opsel(2) = '0' else
                  result_log;
                 
   result <= result_temp;

   c_out <= cout_temp when opsel(2) = '0' else
                '0';   
                
   ofl_out <= ofl_temp when opsel(2) = '0' else
                   '0';

end struct;