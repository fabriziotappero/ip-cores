library ieee;
use ieee.std_logic_1164.all;

entity prog_rom is port (
	input:	in std_logic_vector(15 downto 0);
	output:	out std_logic_vector(15 downto 0)
);
end;

architecture rom_arch of prog_rom is
begin
	process(input)
	begin
		case input is
			when "0000000000000000" =>
				output <= "0100000000000010";
			when "0000000000000001" =>
				output <= "0100000000000001";
			when "0000000000000010" =>
				output <= "0100001000000100";
			when "0000000000000011" =>
				output <= "0100001000000001";
			when "0000000000000100" =>
				output <= "0100010000000110";
			when "0000000000000101" =>
				output <= "0100010000000001";
			when "0000000000000110" =>
				output <= "0100011000010010";
			when "0000000000000111" =>
				output <= "0100011000001101";
			when "0000000000001000" =>
				output <= "0100100000000000";
			when "0000000000001001" =>
				output <= "0100100000001001";
			when "0000000000001010" =>
				output <= "0100101000000010";
			when "0000000000001011" =>
				output <= "0100101000000011";
			when "0000000000001100" =>
				output <= "0100110000001100";
			when "0000000000001101" =>
				output <= "0100110000001101";
			when "0000000000001110" =>
				output <= "0100111000001110";
			when "0000000000001111" =>
				output <= "0100111000001111";
                  when "0000000000010000" =>
				output <= x"2660";
			when others =>
				output <= "1111000000000000";
		end case;
	end process;
end;
