-- Rom file for twiddle factors 
-- ../../../rtl/vhdl/WISHBONE_FFT/rom4.vhd contains 16 points of 16 width 
--  for a 1024 point fft.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;


ENTITY rom4 IS
         GENERIC(
        data_width : integer :=16;
        address_width : integer :=4
    );
    PORT(
        clk :in std_logic;
        address :in std_logic_vector (3      downto 0);
        datar : OUT std_logic_vector (data_width-1 DOWNTO 0) ;
        datai : OUT std_logic_vector (data_width-1 DOWNTO 0)
    );
end rom4;
ARCHITECTURE behavior OF rom4 IS

 BEGIN

process (address,clk)
begin
    	if(rising_edge(clk)) then 
 case address is
        when "0000" => datar <= "0111111111111111";datai <= "0000000000000000"; --0
        when "0001" => datar <= "0101101010000010";datai <= "1010010101111110"; --128
        when "0010" => datar <= "0000000000000000";datai <= "1000000000000001"; --256
        when "0011" => datar <= "1010010101111110";datai <= "1010010101111110"; --384
        when "0100" => datar <= "0111111111111111";datai <= "0000000000000000"; --0
        when "0101" => datar <= "0111011001000001";datai <= "1100111100000101"; --64
        when "0110" => datar <= "0101101010000010";datai <= "1010010101111110"; --128
        when "0111" => datar <= "0011000011111011";datai <= "1000100110111111"; --192
        when "1000" => datar <= "0111111111111111";datai <= "0000000000000000"; --0
        when "1001" => datar <= "0011000011111011";datai <= "1000100110111111"; --192
        when "1010" => datar <= "1010010101111110";datai <= "1010010101111110"; --384
        when "1011" => datar <= "1000100110111111";datai <= "0011000011111011"; --576
           when "1100" => datar <= "0111111111111111";datai <= "0000000000000000"; --0
           when "1101" => datar <= "0111111111111111";datai <= "0000000000000000"; --0
           when "1110" => datar <= "0111111111111111";datai <= "0000000000000000"; --0
           when "1111" => datar <= "0111111111111111";datai <= "0000000000000000"; --0
        when others => for i in data_width-1 downto 0 loop
            datar(i)<='0';datai(i)<='0';end loop;
    end case;

    end if;

end process;
END behavior;
