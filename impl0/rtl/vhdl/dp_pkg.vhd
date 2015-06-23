--------------------------------------------------------------
-- dp_pkg.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: component declarations for datapath, constant  
--        declarations for predefined interrupt vectors
--
-- dependency: alu.vhd, shifter.vhd, regfile.vhd, flags.vhd, fcmp.vhd
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

library ieee;
use ieee.std_logic_1164.all;

package dp_pkg is
   component alu is
      port(   
      a     : in std_logic_vector(15 downto 0);
      b     : in std_logic_vector(15 downto 0);
      opsel : in std_logic_vector(2 downto 0);
      c_in : in std_logic;
      result: out std_logic_vector(15 downto 0);
      c_out: out std_logic;
      ofl_out: out std_logic
      );   
   end component;
   
   component shifter is
      port
      (
         a : in std_logic_vector(15 downto 0);
         b : in std_logic_vector(3 downto 0);
         c_in : in std_logic;
         opsel : in std_logic_vector(2 downto 0);
         result : out std_logic_vector(15 downto 0);
         c_out : out std_logic;
         ofl_out : out std_logic
      );                             
   end component;
   
   component regfile is
      port(
         aadr : in std_logic_vector(3 downto 0);
         badr : in std_logic_vector(3 downto 0);
         ad : in std_logic_vector(15 downto 0);
         adwe : in std_logic;
         clk : in std_logic;
         aq : out std_logic_vector(15 downto 0);
         bq : out std_logic_vector(15 downto 0)
      );
   end component;      
   
   component flags is
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

   end component;
   
   component fcmp is
      port( tttnField_in : in std_logic_vector(3 downto 0);       ---(COSZ)
            flags_in : in std_logic_vector(3 downto 0);
            result_out : out std_logic
          );
   end component;
   
   
   constant invaild_inst_vec : std_logic_vector(3 downto 0) := "0001";
   constant align_err_vec : std_logic_vector(3 downto 0) := "0010";
   constant stack_err_vec : std_logic_vector(3 downto 0) := "0011";
   constant df_err_vec : std_logic_vector(3 downto 0) := "0100";
              
end package;