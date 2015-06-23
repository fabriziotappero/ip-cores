---------------------------------------------------------------------------------------------------
--
-- Title       : blockram
-- Design      : cfft
-- Author      : MENG Lin
-- email	: 
--
---------------------------------------------------------------------------------------------------
--
-- File        : blockram.vhd
-- Generated   : unknown
--
---------------------------------------------------------------------------------------------------
--
-- Description : Dual port ram
--
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library synplify;
use synplify.attributes.all;

entity blockdram is
generic( 
	depth:	integer;
	Dwidth: integer;
	Awidth:	integer
);
port(
	addra: IN std_logic_VECTOR(Awidth-1 downto 0);
	clka: IN std_logic;
	addrb: IN std_logic_VECTOR(Awidth-1 downto 0);
	clkb: IN std_logic;
	dia: IN std_logic_VECTOR(Dwidth-1 downto 0);
	wea: IN std_logic;
	dob: OUT std_logic_VECTOR(Dwidth-1 downto 0));
end blockdram;

architecture arch_blockdram of blockdram is

type ram_memtype is array (depth-1 downto 0) of std_logic_vector
	(Dwidth-1 downto 0);
signal mem : ram_memtype := (others => (others => '0'));
attribute syn_ramstyle of mem : signal is "block_ram";

signal addrb_reg: std_logic_vector(Awidth-1 downto 0);

begin
	wr: process( clka )
	begin
		if rising_edge(clka) then
			if wea = '1' then
				mem(conv_integer(addra)) <= dia;
			end if;
		end if;
	end process wr;

	rd: process( clkb )
	begin
		if rising_edge(clkb) then
			addrb_reg <= addrb;
		end if;
    end process rd;
	dob <= mem(conv_integer(addrb_reg));
end arch_blockdram;

