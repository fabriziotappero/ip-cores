LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity oct_7seg is
	port (
		CLOCK_50 : in std_logic;
		oct_digit : in std_logic_vector(2 downto 0);
		seg : buffer std_logic_vector(6 downto 0)
	);
end oct_7seg;

architecture rtl of oct_7seg is
begin
  process(CLOCK_50)
  begin
-- seg = {g,f,e,d,c,b,a};
-- 0 is on and 1 is off

    case oct_digit is
      when "000" => seg <= B"1000000";
	   when "001" => seg <= B"1111001";
	   when "010" => seg <= B"0100100";
      when "011" => seg <= B"0110000";
      when "100" => seg <= B"0011001";
      when "101" => seg <= B"0010010";
      when "110" => seg <= B"0000010";
      when "111" => seg <= B"1111000";
      when others => seg <= B"0000000";
    end case;
  end process;
end rtl;
