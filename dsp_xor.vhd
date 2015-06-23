
-- Copyright (c) 2013 Antonio de la Piedra
 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
  
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
   
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity dsp_xor is
	port (clk     : in std_logic;
			op_1	  : in std_logic_vector(47 downto 0);
			op_2	  : in std_logic_vector(47 downto 0);
			op_3	  : out std_logic_vector(47 downto 0));
end dsp_xor;

architecture Behavioral of dsp_xor is

	signal alumode_s : std_logic_vector(3 downto 0);
	signal opmode_s  : std_logic_vector(6 downto 0);
	
	signal a_s       : std_logic_vector(29 downto 0);
	signal b_s       : std_logic_vector(17 downto 0);
	signal c_s       : std_logic_vector(47 downto 0);
	signal p_s       : std_logic_vector(47 downto 0);

begin

	a_s <= op_1(47 downto 18);
	b_s <= op_1(17 downto 0);
	c_s <= op_2;
	
	alumode_s <= "0100";
	opmode_s <= "0110011";		

	op_3 <= p_s;

dsp48e1_inst : dsp48e1
   generic map (
        ACASCREG => 0,
        ADREG => 1,
        ALUMODEREG => 0,
        AREG => 0,
        AUTORESET_PATDET => "NO_RESET",
        A_INPUT => "DIRECT",
        BCASCREG => 0,
        BREG => 0,
        B_INPUT => "DIRECT",
        CARRYINREG => 0,
        CARRYINSELREG => 0,
        CREG => 0,
        DREG => 1,
        INMODEREG	=> 0,
        MASK => X"3FFFFFFFFFFF",
        MREG => 0,
        OPMODEREG	=> 0,
        PATTERN => X"000000000000",
        PREG => 0,
        SEL_MASK => "MASK",
        SEL_PATTERN => "PATTERN",
        USE_DPORT	 => FALSE,
        USE_MULT => "NONE",
        USE_PATTERN_DETECT	=> "NO_PATDET",
        USE_SIMD => "ONE48")
   port map (
		  ACOUT => open,
        BCOUT => open,                   
        CARRYCASCOUT => open,           
        CARRYOUT => open,                 
        MULTSIGNOUT => open,             
        OVERFLOW => open,                
        P => p_s,                       
        PATTERNBDETECT => open,         
        PATTERNDETECT => open,          
        PCOUT => open,                  
        UNDERFLOW => open,               
        A  => a_s,
        ACIN  => (others => '0'),
        ALUMODE => alumode_s,
        B => b_s,
        BCIN => (others => '0'),
        C => c_s,
        CARRYCASCIN => '0',
        CARRYIN => '0',
        CARRYINSEL => (others => '0'),		  
        CEA1 => '0',
        CEA2  => '1',
        CEAD   => '0', 
        CEALUMODE   => '0',
        CEB1 => '0',
        CEB2  => '1',
        CEC => '1',
        CECARRYIN  => '0',
        CECTRL   => '1',
        CED  => '0', 
        CEINMODE  => '1', 
        CEM => '0',
        CEP => '0',
        CLK => clk,
        D => (others => '0'),       
        INMODE => (others => '0'),                  
        MULTSIGNIN => '0',             
        OPMODE => opmode_s,                  
        PCIN => (others => '0'),                   
        RSTA => '0',
        RSTALLCARRYIN  => '0',
        RSTALUMODE => '0',
        RSTB  => '0',
        RSTC  => '0',
        RSTCTRL  => '0',
        RSTD  => '0',
        RSTINMODE  => '0',
        RSTM  => '0',
        RSTP => '0');
		  
end Behavioral;
