library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcdchar is
        port(
                clk             : in std_logic;
                addr            : in std_logic_vector(4 downto 0);
                dout            : out std_logic_vector(7 downto 0)
        );
end lcdchar;

architecture rtl of lcdchar is
begin

process (clk)
begin
 if clk'event and clk = '1' then
        case addr is
             when "00000" => dout <= x"52";
             when "00001" => dout <= x"4F";
             when "00010" => dout <= x"4E";
             when "00011" => dout <= x"49";
             when "00100" => dout <= x"56";
             when "00101" => dout <= x"4F";
             when "00110" => dout <= x"4E";
             when "00111" => dout <= x"20";
             when "01000" => dout <= x"20";
             when "01001" => dout <= x"20";
             when "01010" => dout <= x"20";
             when "01011" => dout <= x"43";
             when "01100" => dout <= x"4F";
             when "01101" => dout <= x"53";
             when "01110" => dout <= x"54";
             when "01111" => dout <= x"41";
             when "10000" => dout <= x"20";
             when "10001" => dout <= x"20";
             when "10010" => dout <= x"5A";
             when "10011" => dout <= x"38";
             when "10100" => dout <= x"30";
             when "10101" => dout <= x"20";
             when "10110" => dout <= x"53";
             when "10111" => dout <= x"4F";
             when "11000" => dout <= x"43";
             when "11001" => dout <= x"20";
             when "11010" => dout <= x"32";
             when "11011" => dout <= x"30";
             when "11100" => dout <= x"30";
             when "11101" => dout <= x"38";
             when "11110" => dout <= x"20";
             when "11111" => dout <= x"20";
             when others => dout <= x"00";
        end case;
 end if;
end process;
end;
