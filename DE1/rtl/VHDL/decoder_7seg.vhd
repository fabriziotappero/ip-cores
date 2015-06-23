LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

entity decoder_7seg is
	port
	(
		NUMBER		: in   std_logic_vector(3 downto 0);
		HEX_DISP	: out  std_logic_vector(6 downto 0)
	);
end decoder_7seg;

architecture rtl of decoder_7seg is
begin
process(NUMBER)
begin
	case NUMBER is
		--0 to 9
		when "0000" => HEX_DISP <= "1000000";
		when "0001" => HEX_DISP <= "1111001";
		when "0010" => HEX_DISP <= "0100100";
		when "0011" => HEX_DISP <= "0110000";
		when "0100" => HEX_DISP <= "0011001";
		when "0101" => HEX_DISP <= "0010010";
		when "0110" => HEX_DISP <= "0000011";
		when "0111" => HEX_DISP <= "1111000";
		when "1000" => HEX_DISP <= "0000000";
		when "1001" => HEX_DISP <= "0011000";
		-- A to F
		when "1010" => HEX_DISP <= "0001000";
		when "1011" => HEX_DISP <= "0000011";
		when "1100" => HEX_DISP <= "1000110";
		when "1101" => HEX_DISP <= "0100001";
		when "1110" => HEX_DISP <= "0000110";
		when "1111" => HEX_DISP <= "0001110";
		when others => HEX_DISP <= "1111111";
	end case;
end process;
end rtl;

