---- $Author: songching $
---- $Date: 2004-04-07 15:38:47 $
---- $Revision: 1.1 $
----------------------------------------------------------------------
---- $Log: not supported by cvs2svn $
----------------------------------------------------------------------
----
---- Copyright (C) 2004 Song Ching Koh, Free Software Foundation, Inc. and OPENCORES.ORG
----
---- This program is free software; you can redistribute it and/or modify
---- it under the terms of the GNU General Public License as published by
---- the Free Software Foundation; either version 2 of the License, or
---- (at your option) any later version.
----
---- This program is distributed in the hope that it will be useful,
---- but WITHOUT ANY WARRANTY; without even the implied warranty of
---- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
---- GNU General Public License for more details.
----
---- You should have received a copy of the GNU General Public License
---- along with this program; if not, write to the Free Software
---- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fuzzycore is
    Port ( X : in std_logic_vector(63 downto 0);
           Y : in std_logic_vector(63 downto 0);
           CLK : in std_logic;
           RST : in std_logic;
           Model : in std_logic;
           Inference : in std_logic;
			  DONE : out std_logic;
           Z : out std_logic_vector(63 downto 0));
end fuzzycore;

architecture core_structure of fuzzycore is
	component counter
		port ( CLK : in std_logic;
				 RST : in std_logic;
				 START : in std_logic;
				 DONE : out std_logic;
				 q : out std_logic_vector(2 downto 0));
	end component;
	component MUX1
		port ( Input : in std_logic_vector(63 downto 0);
				 Sel : in std_logic_vector(2 downto 0);
				 Output : out std_logic_vector(7 downto 0));
	end component;
	component MUX2
		port ( A : in std_logic_vector(63 downto 0);
				 B : in std_logic_vector(63 downto 0);
				 Sel : in std_logic;
				 Output : out std_logic_vector(63 downto 0));
	end component;
	component MUX3
   	Port ( A : in std_logic_vector(63 downto 0);
      	    B : in std_logic_vector(63 downto 0);
      	    Sel : in std_logic;
         	 Count : in std_logic_vector(2 downto 0);
	          C : out std_logic_vector(63 downto 0));
	end component;
	component min1to8
   	Port ( A : in std_logic_vector(7 downto 0);
      		 B : in std_logic_vector(63 downto 0);
      		 C : out std_logic_vector(63 downto 0));
	end component;
	component max8to8
		PORT(
			A : IN std_logic_vector(63 downto 0);
			B : IN std_logic_vector(63 downto 0);          
			C : OUT std_logic_vector(63 downto 0));
	end component;
	component rule
   	Port ( Input : in std_logic_vector(63 downto 0);
      		 Add : in std_logic_vector(2 downto 0);
      		 En : in std_logic;
      		 CLK : in std_logic;
      		 RST : in std_logic;
      		 Output : out std_logic_vector(63 downto 0));
	end component;
	component Zreg
   	Port ( Input : in std_logic_vector(63 downto 0);
      	    CLK : in std_logic;
         	 RST : in std_logic;
      		 En : in std_logic;
      		 Output : out std_logic_vector(63 downto 0));
	end component;
	signal start_count: std_logic;
	signal count: std_logic_vector(2 downto 0);
	signal mux1_output : std_logic_vector(7 downto 0);
	signal mux2_output : std_logic_vector(63 downto 0);
	signal mux3_output : std_logic_vector(63 downto 0);
	signal rule_output : std_logic_vector(63 downto 0);
	signal min_output : std_logic_vector(63 downto 0);
	signal max_output : std_logic_vector(63 downto 0);
	signal zreg_output : std_logic_vector(63 downto 0);
begin
	start_count <= Model or Inference;
	Z <= zreg_output;
	inst_counter: counter port map( CLK => CLK,
											  RST => RST,
											  START => start_count,
											  DONE => DONE,
											  q => count);
	inst_mux1: MUX1 port map ( Input => X,
										Sel => count,
										Output => mux1_output);
	inst_mux2: MUX2 port map(A => Y,
									 B => rule_output,
									 Sel => Inference,
									 Output => mux2_output);
	inst_min: min1to8 port map(A => mux1_output,
										B => mux2_output,
										C => min_output);
	inst_mux3: MUX3 port map(A => rule_output,
									 B => zreg_output,
									 Sel => Inference,
									 Count => count,
									 C => mux3_output);
	inst_max: max8to8 port map(A => min_output,
										B => mux3_output,
										C => max_output);
	inst_rule: rule port map(Input => max_output,
									 Add => count,
									 En => Model,
									 CLK => CLK,
									 RST => RST,
									 Output => rule_output);
	inst_zreg: Zreg port map(Input => max_output,
									 CLK => CLK,
									 RST => RST,
									 En => Inference,
									 Output => zreg_output);
end core_structure;
