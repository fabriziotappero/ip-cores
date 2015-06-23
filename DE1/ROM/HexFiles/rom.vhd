library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
entity rom is
        port(
                Clk : in std_logic;
                A   : in std_logic_vector(13 downto 0);
                D   : out std_logic_vector(7 downto 0)
        );
end rom;
architecture rtl of rom is
begin
process (Clk)
begin
 if Clk'event and Clk = '1' then
        case A is
             when "00000000000000" => D <= x"C3";
             when "00000000000001" => D <= x"72";
             when "00000000000010" => D <= x"00";
             when "00000000000011" => D <= x"FF";
             when "00000000000100" => D <= x"AA";
             when "00000000000101" => D <= x"00";
             when "00000000000110" => D <= x"8C";
             when "00000000000111" => D <= x"0C";
             when "00000000001000" => D <= x"01";
             when "00000000001001" => D <= x"00";
             when "00000000001010" => D <= x"00";
             when "00000000001011" => D <= x"00";
             when "00000000001100" => D <= x"00";
             when "00000000001101" => D <= x"00";
             when "00000000001110" => D <= x"00";
             when "00000000001111" => D <= x"00";
             when "00000000010000" => D <= x"00";
             when "00000000010001" => D <= x"00";
             when "00000000010010" => D <= x"00";
             when "00000000010011" => D <= x"00";
             when "00000000010100" => D <= x"00";
             when "00000000010101" => D <= x"00";
             when "00000000010110" => D <= x"00";
             when "00000000010111" => D <= x"00";
             when "00000000011000" => D <= x"00";
             when "00000000011001" => D <= x"00";
             when "00000000011010" => D <= x"00";
             when "00000000011011" => D <= x"00";
             when "00000000011100" => D <= x"00";
             when "00000000011101" => D <= x"00";
             when "00000000011110" => D <= x"00";
             when others => D <= "ZZZZZZZZ";
        end case;
 end if;
end process;
end;
