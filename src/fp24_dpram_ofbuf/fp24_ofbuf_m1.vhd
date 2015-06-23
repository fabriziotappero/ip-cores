-------------------------------------------------------------------------------
--
-- Title       : fp24_ofbuf_m1
-- Design      : fp24fftk
-- Author      : Kapitanov
-- Company     :
--
-------------------------------------------------------------------------------
--
-- Description : version 1.0 
--
-- Universal OF (optimal function) buffer for FFT project
-- It has K independent	DPRAM components for FFT stages between 1k and 64k
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

package	fp24_ofbuf_m1_pkg is
	component fp24_ofbuf_m1 is
		generic(
			stages		: integer :=16
		);		
		port(
			of_re		: in std_logic_vector(15 downto 0);
			of_im		: in std_logic_vector(15 downto 0);
 			
			reset  		: in std_logic;
			clk 		: in std_logic;	
			clk_in		: in std_logic;							
			
			din_en		: in std_logic;
			rw_en		: in std_logic;
			dout_en		: in std_logic;
			
			of_re_even	: out std_logic_vector(15 downto 0);
			of_re_odd	: out std_logic_vector(15 downto 0);
			of_im_even	: out std_logic_vector(15 downto 0);
			of_im_odd	: out std_logic_vector(15 downto 0);		
	
			dout_val	: out std_logic
		);	
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.fp24_of_stages_m1_pkg.all; 

entity fp24_ofbuf_m1 is
	generic(
		stages		: integer :=16
	);
	port(
		of_re		: in std_logic_vector(15 downto 0);
		of_im		: in std_logic_vector(15 downto 0);
 			
		reset  		: in std_logic;
		clk 		: in std_logic;	
		clk_in		: in std_logic;							
		
		din_en		: in std_logic;
		rw_en		: in std_logic;
		dout_en		: in std_logic;
		
		of_re_even	: out std_logic_vector(15 downto 0);
		of_re_odd	: out std_logic_vector(15 downto 0);
		of_im_even	: out std_logic_vector(15 downto 0);
		of_im_odd	: out std_logic_vector(15 downto 0);		
	
		dout_val	: out std_logic		
	);	
end fp24_ofbuf_m1;

architecture fp24_ofbuf_m1 of fp24_ofbuf_m1 is

signal addra, addra_z	: std_logic_vector(stages-1 downto 0);
signal addrb, addrb_z	: std_logic_vector(stages-2 downto 0);

signal cnt_a			: std_logic_vector(stages downto 0);
signal cnt_b			: std_logic_vector(stages-1 downto 0);

signal ena				: std_logic;
signal din				: std_logic_vector(31 downto 0);

signal addr_in 			: std_logic_vector(stages-1 downto 0);
signal addr_out 		: std_logic_vector(stages-2 downto 0);

signal dout_enz			: std_logic;

begin
	
din <= of_im & of_re after 1 ns;-- after 1 ns when rising_edge(clk_in);
ena <= din_en after 1 ns;-- after 1 ns when rising_edge(clk_in);
	
pr_cnt_a: process(clk_in, reset) is
begin
	if reset = '0' then
		cnt_a <= (others => '0');	
	elsif rising_edge(clk_in) then
		if din_en = '1' then
			cnt_a <= cnt_a + '1' after 1 ns;
		else
			null;
		end if;
	end if;
end process;

pr_cnt_b: process(clk, reset) is
begin
	if reset = '0' then
		cnt_b <= (others => '0');	
	elsif rising_edge(clk) then
		if dout_en = '1' then
			cnt_b <= cnt_b + '1' after 1 ns;
		else
			null;
		end if;
	end if;
end process;

addr_in <= cnt_a(stages-1 downto 0);
addr_out <= cnt_b(stages-2 downto 0);

dout_val <= dout_enz after 1 ns when rising_edge(clk);
dout_enz <= dout_en	 after 1 ns when rising_edge(clk);

x_gen_ramb: fp24_of_stages_m1
	generic map (
		stages => stages
	)
	port map (
		addr_in 		=> addr_in,
		din				=> din,
		ena				=> ena,
		wr_en			=> rw_en, -- write
		clk_in			=> clk_in,
		addr_out 		=> addr_out,
		re_even			=> of_re_even,
		re_odd			=> of_re_odd,
		im_even			=> of_im_even,
		im_odd			=> of_im_odd,
		rd_en			=> dout_en,
		clk				=> clk,
		reset			=> reset
		);	

end fp24_ofbuf_m1;
