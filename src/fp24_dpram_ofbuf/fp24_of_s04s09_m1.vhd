-------------------------------------------------------------------------------
--
-- Title       : fp24_of_s04s09_m1
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 1.0 
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

package	fp24_of_s04s09_m1_pkg is
	component fp24_of_s04s09_m1 is
		port(
			addr_in 		: in std_logic_vector(11 downto 0);
			din				: in std_logic_vector(31 downto 0);
			ena				: in std_logic;
			wr_en			: in std_logic;
			clk_in			: in std_logic;
			addr_out 		: in std_logic_vector(10 downto 0);
			dout			: out std_logic_vector(63 downto 0);
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

entity fp24_of_s04s09_m1 is
	port(
		addr_in 		: in std_logic_vector(11 downto 0);
		din				: in std_logic_vector(31 downto 0);
		ena				: in std_logic;
		wr_en			: in std_logic;
		clk_in			: in std_logic;
		addr_out 		: in std_logic_vector(10 downto 0);
		dout			: out std_logic_vector(63 downto 0);
		rd_en			: in std_logic;
		clk				: in std_logic;
		reset			: in std_logic
	);
end fp24_of_s04s09_m1;

architecture fp24_of_s04s09_m1 of fp24_of_s04s09_m1 is	

signal dob 				: std_logic_vector(63 downto 0);
signal rstn				: std_logic;   	 
signal addr_in_z		: std_logic_vector(11 downto 0);
signal addr_out_z		: std_logic_vector(10 downto 0);		
signal wr_en_z			: std_logic;

begin
	
rstn <= not reset;

addr_in_z <= addr_in after 1 ns when rising_edge( clk_in );
addr_out_z <= addr_out after 1 ns when rising_edge( clk );
wr_en_z <= wr_en after 1 ns when rising_edge( clk_in );

gen_width: for ii in 0 to 7 generate	
	ramb : RAMB16_S4_S9	
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
			dob 	=> dob(8*ii+7 downto 8*ii),
			addra 	=> addr_in_z,
			addrb 	=> addr_out_z,
			clka 	=> clk_in,
			clkb 	=> clk,
			dia 	=> din(4*ii+3 downto 4*ii),
			dib 	=> x"00",
			--dipa	=> "0",
			dipb	=> "0",
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
		dout <= (others => '0') after 1 ns;	
	elsif rising_edge(clk) then
		dout <= dob after 1 ns;
	end if;
end process;	

end fp24_of_s04s09_m1;
