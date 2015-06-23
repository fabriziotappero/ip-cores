--
--  Copyright 2011 Martin Schoeberl <masca@imm.dtu.dk>,
--                 Technical University of Denmark, DTU Informatics. 
--  All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
--    1. Redistributions of source code must retain the above copyright notice,
--       this list of conditions and the following disclaimer.
-- 
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
-- NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation are
-- those of the authors and should not be interpreted as representing official
-- policies, either expressed or implied, of the copyright holder.
-- 

--
--	leroscyc12.vhd
--
--	top level for cycore board with EP1C12
--
--	2011-02-20	creation
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.leros_types.all;


entity leros_top is

generic (
	ram_cnt		: integer := 2		-- clock cycles for external ram
);

port (
	clk		: in std_logic;
--
--	serial interface
--
	ser_txd			: out std_logic;
	ser_rxd			: in std_logic;
	ser_ncts		: in std_logic;
	ser_nrts		: out std_logic;

--
--	watchdog
--
	wd		: out std_logic;
	freeio	: out std_logic;

--
--	two ram banks
--
-- 	rama_a		: out std_logic_vector(17 downto 0);
-- 	rama_d		: inout std_logic_vector(15 downto 0);
-- 	rama_ncs	: out std_logic;
-- 	rama_noe	: out std_logic;
-- 	rama_nlb	: out std_logic;
-- 	rama_nub	: out std_logic;
-- 	rama_nwe	: out std_logic;
-- 	ramb_a		: out std_logic_vector(17 downto 0);
-- 	ramb_d		: inout std_logic_vector(15 downto 0);
-- 	ramb_ncs	: out std_logic;
-- 	ramb_noe	: out std_logic;
-- 	ramb_nlb	: out std_logic;
-- 	ramb_nub	: out std_logic;
-- 	ramb_nwe	: out std_logic;

--
--	I/O pins of board
--
	io_b	: inout std_logic_vector(10 downto 1);
	io_l	: inout std_logic_vector(20 downto 1);
	io_r	: inout std_logic_vector(20 downto 1);
	io_t	: inout std_logic_vector(6 downto 1)
);
end leros_top;

architecture rtl of leros_top is


	signal clk_int			: std_logic;

	-- for generation of internal reset
	signal int_res			: std_logic;
	signal res_cnt			: unsigned(2 downto 0) := "000";	-- for the simulation

	attribute altera_attribute : string;
	attribute altera_attribute of res_cnt : signal is "POWER_UP_LEVEL=LOW";

	signal wd_out			: std_logic;
	
	signal ioout : io_out_type;
	signal ioin : io_in_type;

	signal outp 			: std_logic_vector(15 downto 0);
	
begin

	-- let's go for 200 MHz ;-)
	-- but for now 100 MHz is enough
	pll_inst : entity work.pll generic map(
		multiply_by => 5, -- shall be 5 for 100 MHz
		divide_by => 1
	)
	port map (
		inclk0	 => clk,
		c0	 => clk_int
	);

--
--	internal reset generation
--	should include the PLL lock signal
--

process(clk_int)
begin
	if rising_edge(clk_int) then
		if (res_cnt/="111") then
			res_cnt <= res_cnt+1;
		end if;

		int_res <= not res_cnt(0) or not res_cnt(1) or not res_cnt(2);
	end if;
end process;

	wd <= wd_out;

	cpu: entity work.leros
		port map(clk_int, int_res, ioout, ioin);

	ioin.rddata <= (others => '0');
			
process(clk_int)
begin

	if rising_edge(clk_int) then
		if ioout.wr='1' then
			outp <= ioout.wrdata;
		end if;
		wd_out <= outp(0);
	end if;
end process;

end rtl;
