-------------------------------------------------------------------------------
--
-- Title       : fp24fftk_dpram36_ZxY_pkg_v1
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

package	fft_dpram36_ZxY_m1_pkg is

--	component fft_dpram36_8x32_m1 is
--		port(
--			addr_in 		: in std_logic_vector(8 downto 0);
--			din				: in std_logic_vector(31 downto 0);
--			ena				: in std_logic;
--			wr_en			: in std_logic;
--			clk_in			: in std_logic;
--			addr_out 		: in std_logic_vector(8 downto 0);
--			dout			: out std_logic_vector(31 downto 0);
--			rd_en			: in std_logic;
--			clk				: in std_logic;
--			reset			: in std_logic
--		);
--	end component;	
--	
--	component fft_dpram36_16x32_m1 is
--		port(
--			addr_in 		: in std_logic_vector(8 downto 0);
--			din				: in std_logic_vector(31 downto 0);
--			ena				: in std_logic;
--			wr_en			: in std_logic;
--			clk_in			: in std_logic;
--			addr_out 		: in std_logic_vector(8 downto 0);
--			dout			: out std_logic_vector(31 downto 0);
--			rd_en			: in std_logic;
--			clk				: in std_logic;
--			reset			: in std_logic
--		);
--	end component;	
--	
--	component fft_dpram36_32x32_m1 is
--		port(
--			addr_in 		: in std_logic_vector(8 downto 0);
--			din				: in std_logic_vector(31 downto 0);
--			ena				: in std_logic;
--			wr_en			: in std_logic;
--			clk_in			: in std_logic;
--			addr_out 		: in std_logic_vector(8 downto 0);
--			dout			: out std_logic_vector(31 downto 0);
--			rd_en			: in std_logic;
--			clk				: in std_logic;
--			reset			: in std_logic
--		);
--	end component;	
--	
--	component fft_dpram36_64x32_m1 is
--		port(
--			addr_in 		: in std_logic_vector(8 downto 0);
--			din				: in std_logic_vector(31 downto 0);
--			ena				: in std_logic;
--			wr_en			: in std_logic;
--			clk_in			: in std_logic;
--			addr_out 		: in std_logic_vector(8 downto 0);
--			dout			: out std_logic_vector(31 downto 0);
--			rd_en			: in std_logic;
--			clk				: in std_logic;
--			reset			: in std_logic
--		);
--	end component;	
--	
--	component fft_dpram36_128x32_m1 is
--		port(
--			addr_in 		: in std_logic_vector(8 downto 0);
--			din				: in std_logic_vector(31 downto 0);
--			ena				: in std_logic;
--			wr_en			: in std_logic;
--			clk_in			: in std_logic;
--			addr_out 		: in std_logic_vector(8 downto 0);
--			dout			: out std_logic_vector(31 downto 0);
--			rd_en			: in std_logic;
--			clk				: in std_logic;
--			reset			: in std_logic
--		);
--	end component;	
	
	component fft_dpram36_512x32_m1 is
		port(
			addr_in 		: in std_logic_vector(8 downto 0);
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
	
	component fft_dpram36_1kx32_m1 is
		port(
			addr_in 		: in std_logic_vector(9 downto 0);
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
	
	component fft_dpram36_2kx32_m1 is
		port(
			addr_in 		: in std_logic_vector(10 downto 0);
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
	
	component fft_dpram36_4kx32_m1 is
		port(
			addr_in 		: in std_logic_vector(11 downto 0);
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
	
	component fft_dpram36_8kx32_m1 is
		port(
			addr_in 		: in std_logic_vector(12 downto 0);
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
	
	component fft_dpram36_16kx32_m1 is
		port(
			addr_in 		: in std_logic_vector(13 downto 0);
			din				: in std_logic_vector(31 downto 0);
			ena				: in std_logic;
			wr_en			: in std_logic;
			clk_in			: in std_logic;
			addr_out 		: in std_logic_vector(13 downto 0);
			dout			: out std_logic_vector(31 downto 0);
			rd_en			: in std_logic;
			clk				: in std_logic;
			reset			: in std_logic
		);
	end component;
	
end fft_dpram36_ZxY_m1_pkg;

