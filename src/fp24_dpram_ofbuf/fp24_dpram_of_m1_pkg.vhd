-------------------------------------------------------------------------------
--
-- Title       : fp24_of_sZxY_pkg_m1
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 1.0 
--
-- Stages: 9-16;
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--		(c) Copyright 2015 													 
--		Kapitanov.                                          				 
--		All rights reserved.                                                 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package	fp24_dpram_of_m1_pkg is
	-- FFT 1k
	component fp24_of_s18s36_m1 is
		port(
			addr_in 		: in std_logic_vector(9 downto 0);
			din				: in std_logic_vector(31 downto 0);
			ena				: in std_logic;
			wr_en			: in std_logic;
			clk_in			: in std_logic;
			addr_out 		: in std_logic_vector(8 downto 0);
			dout			: out std_logic_vector(31 downto 0);
			rd_en			: in std_logic;
			clk				: in std_logic;
			reset			: in std_logic
		);
	end component;
	-- FFT 2k
	component fp24_of_s09s18_m1 is
		port(
			addr_in 		: in std_logic_vector(10 downto 0);
			din				: in std_logic_vector(31 downto 0);
			ena				: in std_logic;
			wr_en			: in std_logic;
			clk_in			: in std_logic;
			addr_out 		: in std_logic_vector(9 downto 0);
			dout			: out std_logic_vector(31 downto 0);
			rd_en			: in std_logic;
			clk				: in std_logic;
			reset			: in std_logic
		);
	end component;
	-- FFT 4k
	component fp24_of_s04s09_m1 is
		port(
			addr_in 		: in std_logic_vector(11 downto 0);
			din				: in std_logic_vector(31 downto 0);
			ena				: in std_logic;
			wr_en			: in std_logic;
			clk_in			: in std_logic;
			addr_out 		: in std_logic_vector(10 downto 0);
			dout			: out std_logic_vector(31 downto 0);
			rd_en			: in std_logic;
			clk				: in std_logic;
			reset			: in std_logic
		);
	end component;	
	-- FFT 8k
	component fp24_of_s02s04_m1 is
		port(
			addr_in 		: in std_logic_vector(12 downto 0);
			din				: in std_logic_vector(31 downto 0);
			ena				: in std_logic;
			wr_en			: in std_logic;
			clk_in			: in std_logic;
			addr_out 		: in std_logic_vector(11 downto 0);
			dout			: out std_logic_vector(31 downto 0);
			rd_en			: in std_logic;
			clk				: in std_logic;
			reset			: in std_logic
		);
	end component;
	-- FFT 16k
	component fp24_of_s01s02_m1 is
		port(
			addr_in 		: in std_logic_vector(13 downto 0);
			din				: in std_logic_vector(31 downto 0);
			ena				: in std_logic;
			wr_en			: in std_logic;
			clk_in			: in std_logic;
			addr_out 		: in std_logic_vector(12 downto 0);
			dout			: out std_logic_vector(31 downto 0);
			rd_en			: in std_logic;
			clk				: in std_logic;
			reset			: in std_logic
		);
	end component;
	
end fp24_dpram_of_m1_pkg;