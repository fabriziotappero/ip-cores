-- Copied from Altera VHDL Custom Instruction Template File for Combinatorial Logic

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity logsig_approx is
port(
	signal dataa: in std_logic_vector(31 downto 0);		-- Operand A (input to tansig)
	signal result: out std_logic_vector(31 downto 0)	-- result (tansig approximation)
);
end entity logsig_approx;

architecture behavior of logsig_approx is
	-- the "exponent" part of the input (in IEEE754 format)
	signal in_exponent : std_logic_vector(7 downto 0);
	-- the most significant bits of the mantissa (for this LUT, we only need the first 5 bits
	signal in_mantissa_msbits : std_logic_vector(4 downto 0);	
begin
	-- separate the exponent and mantissa portions of the input
	in_exponent <= dataa(30 downto 23);
	in_mantissa_msbits <= dataa(22 downto 18);
	-- propagate the sign directly to the output since the tansig is an odd function
	result(31) <= dataa(31);
	-- use a linear approximation if exponent is smaller than 2^-2
	process(dataa)
	begin
		if( in_exponent >= "10000001" ) THEN result(30 downto 0) <= "0111111100000000000000000000000"; -- for high values go to 1
		elsif (in_exponent = "10000001") AND (in_mantissa_msbits >= "00000") THEN result(30 downto 0) <= "0111111011111111101011010110101";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "11111") THEN result(30 downto 0) <= "0111111011111111101000100110110";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "11110") THEN result(30 downto 0) <= "0111111011111111100101011111100";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "11101") THEN result(30 downto 0) <= "0111111011111111100001111101110";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "11100") THEN result(30 downto 0) <= "0111111011111111011101111101111";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "11011") THEN result(30 downto 0) <= "0111111011111111011001011100000";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "11010") THEN result(30 downto 0) <= "0111111011111111010100010011101";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "11001") THEN result(30 downto 0) <= "0111111011111111001110011111101";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "11000") THEN result(30 downto 0) <= "0111111011111111000111111010001";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "10111") THEN result(30 downto 0) <= "0111111011111111000000011100101";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "10110") THEN result(30 downto 0) <= "0111111011111110110111111111101";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "10101") THEN result(30 downto 0) <= "0111111011111110101110011010110";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "10100") THEN result(30 downto 0) <= "0111111011111110100011100100100";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "10011") THEN result(30 downto 0) <= "0111111011111110010111010010001";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "10010") THEN result(30 downto 0) <= "0111111011111110001001010111011";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "10001") THEN result(30 downto 0) <= "0111111011111101111001100110100";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "10000") THEN result(30 downto 0) <= "0111111011111101100111110000000";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "01111") THEN result(30 downto 0) <= "0111111011111101010011100010000";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "01110") THEN result(30 downto 0) <= "0111111011111100111100101000101";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "01101") THEN result(30 downto 0) <= "0111111011111100100010101101100";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "01100") THEN result(30 downto 0) <= "0111111011111100000101010111000";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "01011") THEN result(30 downto 0) <= "0111111011111011100100001000011";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "01010") THEN result(30 downto 0) <= "0111111011111010111110100001010";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "01001") THEN result(30 downto 0) <= "0111111011111010010011111101000";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "01000") THEN result(30 downto 0) <= "0111111011111001100011110010010";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "00111") THEN result(30 downto 0) <= "0111111011111000101101010010101";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "00110") THEN result(30 downto 0) <= "0111111011110111101111101001100";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "00101") THEN result(30 downto 0) <= "0111111011110110101001111100010";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "00100") THEN result(30 downto 0) <= "0111111011110101011011001000101";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "00011") THEN result(30 downto 0) <= "0111111011110100000010000100001";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "00010") THEN result(30 downto 0) <= "0111111011110010011101011011100";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "00001") THEN result(30 downto 0) <= "0111111011110000101011110001011";
		elsif (in_exponent = "10000000") AND (in_mantissa_msbits >= "00000") THEN result(30 downto 0) <= "0111111011101110101011011101110";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "11110") THEN result(30 downto 0) <= "0111111011101100011010101100000";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "11100") THEN result(30 downto 0) <= "0111111011101001110111011010110";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "11010") THEN result(30 downto 0) <= "0111111011100110111111011010001";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "11000") THEN result(30 downto 0) <= "0111111011100011110000001011000";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "10110") THEN result(30 downto 0) <= "0111111011100000000110111101010";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "10100") THEN result(30 downto 0) <= "0111111011011100000000101111111";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "10010") THEN result(30 downto 0) <= "0111111011010111011010001110101";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "10000") THEN result(30 downto 0) <= "0111111011010010001111110010111";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "01110") THEN result(30 downto 0) <= "0111111011001100011101100010000";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "01100") THEN result(30 downto 0) <= "0111111011000101111111001110100";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "01010") THEN result(30 downto 0) <= "0111111010111110110000011000000";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "01000") THEN result(30 downto 0) <= "0111111010110110101100001100110";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "00110") THEN result(30 downto 0) <= "0111111010101101101101101100011";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "00100") THEN result(30 downto 0) <= "0111111010100011101111101010101";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "00010") THEN result(30 downto 0) <= "0111111010011000101100110100011";
		elsif (in_exponent = "01111111") AND (in_mantissa_msbits >= "00000") THEN result(30 downto 0) <= "0111111010001100011111110101110";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "11111") THEN result(30 downto 0) <= "0111111010000100001111110000110";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "11110") THEN result(30 downto 0) <= "0111111010000000110011100100111";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "11101") THEN result(30 downto 0) <= "0111111001111101010010001010001";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "11100") THEN result(30 downto 0) <= "0111111001111001101011011011101";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "11011") THEN result(30 downto 0) <= "0111111001110101111111010100111";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "11010") THEN result(30 downto 0) <= "0111111001110010001101110001001";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "11001") THEN result(30 downto 0) <= "0111111001101110010110101100010";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "11000") THEN result(30 downto 0) <= "0111111001101010011010000001101";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "10111") THEN result(30 downto 0) <= "0111111001100110010111101101100";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "10110") THEN result(30 downto 0) <= "0111111001100010001111101011110";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "10101") THEN result(30 downto 0) <= "0111111001011110000001111000101";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "10100") THEN result(30 downto 0) <= "0111111001011001101110010000110";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "10011") THEN result(30 downto 0) <= "0111111001010101010100110000101";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "10010") THEN result(30 downto 0) <= "0111111001010000110101010101011";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "10001") THEN result(30 downto 0) <= "0111111001001100001111111100000";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "10000") THEN result(30 downto 0) <= "0111111001000111100100100001111";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "01111") THEN result(30 downto 0) <= "0111111001000010110011000100111";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "01110") THEN result(30 downto 0) <= "0111111000111101111011100010111";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "01101") THEN result(30 downto 0) <= "0111111000111000111101111010011";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "01100") THEN result(30 downto 0) <= "0111111000110011111010001001101";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "01011") THEN result(30 downto 0) <= "0111111000101110110000010000000";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "01010") THEN result(30 downto 0) <= "0111111000101001100000001100100";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "01001") THEN result(30 downto 0) <= "0111111000100100001001111110111";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "01000") THEN result(30 downto 0) <= "0111111000011110101101100111011";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "00111") THEN result(30 downto 0) <= "0111111000011001001011000110001";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "00110") THEN result(30 downto 0) <= "0111111000010011100010011100011";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "00101") THEN result(30 downto 0) <= "0111111000001101110011101011000";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "00100") THEN result(30 downto 0) <= "0111111000000111111110110100000";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "00011") THEN result(30 downto 0) <= "0111111000000010000011111001011";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "00010") THEN result(30 downto 0) <= "0111110111111000000101111011100";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "00001") THEN result(30 downto 0) <= "0111110111101011111000001000101";
		elsif (in_exponent = "01111110") AND (in_mantissa_msbits >= "00000") THEN result(30 downto 0) <= "0111110111011111011110100000111";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "11110") THEN result(30 downto 0) <= "0111110111010010111001001100101";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "11100") THEN result(30 downto 0) <= "0111110111000110001000010100111";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "11010") THEN result(30 downto 0) <= "0111110110111001001100000011100";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "11000") THEN result(30 downto 0) <= "0111110110101100000100100011101";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "10110") THEN result(30 downto 0) <= "0111110110011110110010000001010";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "10100") THEN result(30 downto 0) <= "0111110110010001010100101001101";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "10010") THEN result(30 downto 0) <= "0111110110000011101100101010101";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "10000") THEN result(30 downto 0) <= "0111110101110101111010010011100";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "01110") THEN result(30 downto 0) <= "0111110101100111111101110100011";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "01100") THEN result(30 downto 0) <= "0111110101011001110111011110010";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "01010") THEN result(30 downto 0) <= "0111110101001011100111100011100";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "01000") THEN result(30 downto 0) <= "0111110100111101001110010111001";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "00110") THEN result(30 downto 0) <= "0111110100101110101100001101011";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "00100") THEN result(30 downto 0) <= "0111110100100000000001011011000";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "00010") THEN result(30 downto 0) <= "0111110100010001001110010110011";
		elsif (in_exponent = "01111101") AND (in_mantissa_msbits >= "00000") THEN result(30 downto 0) <= "0111110100000010010011010110010";
		elsif (in_exponent = "01111100") AND (in_mantissa_msbits >= "11100") THEN result(30 downto 0) <= "0111110011100110100001100101000";
		else
			-- for smaller values, use linear approximation
			result(30 downto 0) <= dataa(30 downto 0);
		end if;
	end process;
end architecture behavior;
