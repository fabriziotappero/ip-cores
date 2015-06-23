-------------------------------------------------------------------------------
--
-- Title       : fp24fftk_dpram36_1kx32_m1
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 1.0
--
-- Stages: 10: Length 2^10 = 1024 
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

package	fft_dpram36_1kx32_m1_pkg is
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
end package;

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all; 

entity fft_dpram36_1kx32_m1 is
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
end fft_dpram36_1kx32_m1;

architecture fft_dpram36_1kx32_m1 of fft_dpram36_1kx32_m1 is	

signal dob 				: std_logic_vector(31 downto 0);
signal rstn				: std_logic;   		 
signal addr_in_z		: std_logic_vector(9 downto 0);
signal addr_out_z		: std_logic_vector(9 downto 0);		
signal wr_en_z			: std_logic;

begin
	
rstn <= not reset;

addr_in_z <= addr_in after 1 ns when rising_edge( clk_in );
addr_out_z <= addr_out after 1 ns when rising_edge( clk );
wr_en_z <= wr_en after 1 ns when rising_edge( clk_in );

gen_width: for ii in 0 to 1 generate	
ramb : RAMB16_S18_S18	
	generic	map(
		INIT_A => "0", -- Value of output RAM registers on Port A at startup
		INIT_B => "0", -- Value of output RAM registers on Port B at startup
		SRVAL_A => "0", -- Port A ouput value upon SSR assertion
		SRVAL_B => "0", -- Port B ouput value upon SSR assertion
	    WRITE_MODE_A => "READ_FIRST",
	    WRITE_MODE_B => "READ_FIRST"
	)
	port map(
		--doa 	=> doa,
		dipa	=> "00",
		dipb	=> "00",
		dob 	=> dob(16*ii+15 downto 16*ii),
		addra 	=> addr_in_z,
		addrb 	=> addr_out_z,
		clka 	=> clk_in,
		clkb 	=> clk,
		dia 	=> din(16*ii+15 downto 16*ii),
		dib 	=> (others => '0'),
		ena 	=> ena,
		enb 	=> rd_en,
		ssra 	=> rstn,
		ssrb 	=> rstn,
		wea 	=> wr_en_z,
		web 	=> '0'
	);	 	
end generate;
process(clk, rstn) is
begin
	if rstn = '1' then
		dout		<= (others => '0') after 1 ns;
	elsif rising_edge(clk) then
		dout		<= dob(31 downto 0) after 1 ns;
	end if;
end process;	

end fft_dpram36_1kx32_m1;
