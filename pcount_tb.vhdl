library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity pcount_tb is
end pcount_tb;

architecture test of pcount_tb is
  component pdchain
    generic (
      n: natural
    );
    port (
      clock: in std_logic;
      en: in std_logic;
      q: out std_logic_vector (n-1 downto 0)
    );
  end component;
  --
  constant T: time := 5 ns;
  signal clock: std_logic := '0';
  signal count: std_logic_vector (23 downto 0);
begin
  pdchain0: pdchain
    generic map (
      n => count'length
    )
    port map (
      clock => clock,
      en => '1',
      q => count
    );

  clk: process
    variable s: line;
  begin
    clock <= '1';
    wait for T/2;
    clock <= '0';
    wait for T/2;
    --
    write(s, to_bitvector(count));
    writeline(output, s);
  end process;
end test;
