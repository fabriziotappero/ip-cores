library IEEE;
use ieee.std_logic_1164.all;
use work.leval2_package.all;

entity bidirbus is
	port (
		bidir : inout std_logic_vector(WORD_BITS - 1 downto 0);
		oe : in std_logic;
		clk : in std_logic;
		inp : in std_logic_vector(WORD_BITS - 1 downto 0);
		outp : out std_logic_vector(WORD_BITS - 1 downto 0)
	);
end entity;

architecture rtl of bidirbus is
	signal a : std_logic_vector(WORD_BITS - 1 downto 0);
	signal b : std_logic_vector(WORD_BITS - 1 downto 0);
begin
	busback : process(clk)
	begin
		if rising_edge(clk) then
			a <= inp;
			outp <= b;
		end if;
	end process;
	
	process(oe, bidir, a)
	begin
		if oe = '0' then -- write operation
			bidir <= (others => 'Z');
			b <= bidir;
		else 
			bidir <= a;
			b <= bidir;
		end if;
	end process;
end architecture;
