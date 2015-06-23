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
--library synplify;
--use synplify.attributes.all;

entity blockdram is
generic( 
	depth: natural;
	Dwidth: natural;
	Awidth:	natural
);
      port (
        clkin   : in  std_logic;
        wen     : in  std_logic;
        addrin  : in  std_logic_vector(Awidth-1 downto 0);
        din     : in  std_logic_vector(Dwidth-1 downto 0);
        clkout  : in  std_logic;
        addrout : in  std_logic_vector(Awidth-1 downto 0);
        dout    : out std_logic_vector(Dwidth-1 downto 0));
end blockdram;

architecture blockdram of blockdram is

type ram_memtype is array (depth-1 downto 0) of std_logic_vector
	(Dwidth-1 downto 0);
signal mem : ram_memtype := (others => (others => '0'));
--attribute syn_ramstyle of mem : signal is "block_ram";

signal addrb_reg: std_logic_vector(Awidth-1 downto 0);

begin
	wr: process( clkin )
	begin
		if rising_edge(clkin) then
			if wen = '1' then
				mem(conv_integer(addrin)) <= din;
			end if;
		end if;
	end process wr;

	rd: process( clkout )
	begin
		if rising_edge(clkout) then
			addrb_reg <= addrout;
		end if;
    end process rd;
	dout <= mem(conv_integer(addrb_reg));
end blockdram;

