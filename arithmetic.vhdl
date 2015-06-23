-- ALU
-- 10/24/05
-- Everything here works except for division

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity arithmetic is port(
  a:	in signed(15 downto 0);
  b:	in signed(15 downto 0);
  fcn:	in std_logic_vector(2 downto 0);
  o:	out signed(15 downto 0);
  m_o:	out signed(31 downto 0)
  );
end arithmetic;

architecture arith_arch of arithmetic is

  signal temp: signed(31 downto 0);

begin
  arith_logic: process(fcn, a, b)
  begin
    case fcn is
      when "000" =>			-- add
        o <= a + b;
      when "001" =>			-- subtract
        o <= a - b;
      when "010" =>			-- multiply
        m_o <= a * b;
      when "011" =>			-- divide
        --o <= a / b;
      when "100" =>			-- 2's complement inverse
        o <= signed((not std_logic_vector(a))) + '1';
      when others =>
        o <= x"0000";
    end case;
  end process arith_logic;
end arith_arch;
