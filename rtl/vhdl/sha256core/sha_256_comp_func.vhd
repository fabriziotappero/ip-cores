------------------------------------------------------------------- 
--                                                               --
--  Copyright (C) 2013 Author and VariStream Studio              --
--  Author : Yu Peng                                             --
--                                                               -- 
--  This source file may be used and distributed without         -- 
--  restriction provided that this copyright statement is not    -- 
--  removed from the file and that any derivative work contains  -- 
--  the original copyright notice and the associated disclaimer. -- 
--                                                               -- 
--  This source file is free software; you can redistribute it   -- 
--  and/or modify it under the terms of the GNU Lesser General   -- 
--  Public License as published by the Free Software Foundation; -- 
--  either version 2.1 of the License, or (at your option) any   -- 
--  later version.                                               -- 
--                                                               -- 
--  This source is distributed in the hope that it will be       -- 
--  useful, but WITHOUT ANY WARRANTY; without even the implied   -- 
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      -- 
--  PURPOSE.  See the GNU Lesser General Public License for more -- 
--  details.                                                     -- 
--                                                               -- 
--  You should have received a copy of the GNU Lesser General    -- 
--  Public License along with this source; if not, download it   -- 
--  from http://www.opencores.org/lgpl.shtml                     -- 
--                                                               -- 
-------------------------------------------------------------------
-- Notes : Introduce delay of 3 clock cycle
-------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use work.sha_256_pkg.ALL;

entity sha_256_comp_func is
	port(
		iClk : in std_logic;
		iRst_async : in std_logic;
		
		ivA : in std_logic_vector(31 downto 0);
		ivB : in std_logic_vector(31 downto 0);
		ivC : in std_logic_vector(31 downto 0);
		ivD : in std_logic_vector(31 downto 0);
		ivE : in std_logic_vector(31 downto 0);
		ivF : in std_logic_vector(31 downto 0);
		ivG : in std_logic_vector(31 downto 0);
		ivH : in std_logic_vector(31 downto 0);
				 
		ivK : in std_logic_vector(31 downto 0);
		ivW : in std_logic_vector(31 downto 0);
				 
		ovA : out std_logic_vector(31 downto 0);
		ovB : out std_logic_vector(31 downto 0);
		ovC : out std_logic_vector(31 downto 0);
		ovD : out std_logic_vector(31 downto 0);
		ovE : out std_logic_vector(31 downto 0);
		ovF : out std_logic_vector(31 downto 0);
		ovG : out std_logic_vector(31 downto 0);
		ovH : out std_logic_vector(31 downto 0)
	);
end sha_256_comp_func;

architecture behavioral of sha_256_comp_func is

	component pipelines_without_reset IS
		GENERIC (gBUS_WIDTH : integer := 3; gNB_PIPELINES: integer range 1 to 255 := 2);
		PORT(
			iClk				: IN		STD_LOGIC;
			iInput				: IN		STD_LOGIC;
			ivInput				: IN		STD_LOGIC_VECTOR(gBUS_WIDTH-1 downto 0);
			oDelayed_output		: OUT		STD_LOGIC;
			ovDelayed_output	: OUT		STD_LOGIC_VECTOR(gBUS_WIDTH-1 downto 0)
		);
	end component;
	
	signal svS0, svS1 : std_logic_vector(31 downto 0);
	signal svMaj, svCh : std_logic_vector(31 downto 0);
	signal svTemp1_temp : std_logic_vector(31 downto 0);
	signal svTemp2, svTemp1 : std_logic_vector(31 downto 0); 
	signal svD_2d : std_logic_vector(31 downto 0);
	signal svAOut : std_logic_vector(31 downto 0); 
	signal svBOut : std_logic_vector(31 downto 0);
	signal svCOut : std_logic_vector(31 downto 0);
	signal svDOut : std_logic_vector(31 downto 0);
	signal svEOut : std_logic_vector(31 downto 0);
	signal svFOut : std_logic_vector(31 downto 0);
	signal svGOut : std_logic_vector(31 downto 0);
	signal svHOut : std_logic_vector(31 downto 0);

begin

	proc_delay1: process(iClk)
	begin
		if rising_edge(iClk) then
			svS0 <= sum_0(ivA);
			svMaj <= maj(ivA, ivB, ivC);
			svS1 <= sum_1(ivE);
			svCh <= chi(ivE, ivF, ivG);
			svTemp1_temp <= ivH + ivK + ivW;
		end if;
	end process;

	proc_delay2: process(iClk)
	begin
		if rising_edge(iClk) then
			svTemp2 <= svS0 + svMaj;
			svTemp1 <= svTemp1_temp + svS1 + svCh;
		end if;
	end process;
	
	pipelines_without_reset_for_D_2d : pipelines_without_reset
	generic map (
		gBUS_WIDTH => 32,
		gNB_PIPELINES => 2)
	port map (
		iClk => iClk,
		iInput => '0',
		oDelayed_output => open,
		ivInput => ivD,
		ovDelayed_output => svD_2d);
	
	proc_delay3: process(iClk)
	begin
		if rising_edge(iClk) then
			svAOut <= svTemp2 + svTemp1;
			svEOut <= svD_2d + svTemp1;
		end if;
	end process;
	
	pipelines_without_reset_for_B : pipelines_without_reset
	generic map (
		gBUS_WIDTH => 32,
		gNB_PIPELINES => 3)
	port map (
		iClk => iClk,
		iInput => '0',
		oDelayed_output => open,
		ivInput => ivA,
		ovDelayed_output => svBOut);  
		
	pipelines_without_reset_for_C : pipelines_without_reset
	generic map (
		gBUS_WIDTH => 32,
		gNB_PIPELINES => 3)
	port map (
		iClk => iClk,
		iInput => '0',
		oDelayed_output => open,
		ivInput => ivB,
		ovDelayed_output => svCOut);
	
	pipelines_without_reset_for_D : pipelines_without_reset
	generic map (
		gBUS_WIDTH => 32,
		gNB_PIPELINES => 3)
	port map (
		iClk => iClk,
		iInput => '0',
		oDelayed_output => open,
		ivInput => ivC,
		ovDelayed_output => svDOut);
		
	pipelines_without_reset_for_F : pipelines_without_reset
	generic map (
		gBUS_WIDTH => 32,
		gNB_PIPELINES => 3)
	port map (
		iClk => iClk,
		iInput => '0',
		oDelayed_output => open,
		ivInput => ivE,
		ovDelayed_output => svFOut);
		
	pipelines_without_reset_for_G : pipelines_without_reset
	generic map (
		gBUS_WIDTH => 32,
		gNB_PIPELINES => 3)
	port map (
		iClk => iClk,
		iInput => '0',
		oDelayed_output => open,
		ivInput => ivF,
		ovDelayed_output => svGOut);
		
	pipelines_without_reset_for_H : pipelines_without_reset
	generic map (
		gBUS_WIDTH => 32,
		gNB_PIPELINES => 3)
	port map (
		iClk => iClk,
		iInput => '0',
		oDelayed_output => open,
		ivInput => ivG,
		ovDelayed_output => svHOut);
	
	ovA <= svAOut;
	ovB <= svBOut;
	ovC <= svCOut;
	ovD <= svDOut;
	ovE <= svEOut;
	ovF <= svFOut;
	ovG <= svGOut;
	ovH <= svHOut;
		
end behavioral;
