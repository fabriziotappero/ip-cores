library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cctest is
    Port ( fN : in std_logic;
           fV : in std_logic;
           fC : in std_logic;
           fZ : in std_logic;
           what : in std_logic_vector(3 downto 0);
           result : out std_logic);
end cctest;

architecture Behavioral of cctest is

begin
  process(what, fN, fV, fC, fZ)
  begin
  case what is
    when "0000" =>     -- ever true
      result <= '1';
    when "0001" =>     -- carry clear
      result <= not fC;
    when "0010" =>     -- carry set
      result <= fC;
    when "0011" =>     -- zero set
      result <= fZ;
    when "0100" =>     -- greater equal
      result <= (fN and fV) or (not fN and not fV);
    when "0101" =>     -- greater than
      result <= (fN and fV and not fZ) or (not fN and not fV and not fZ);
    when "0110" =>     -- higher
      result <= not fC and not fZ;
    when "0111" =>     -- less equal
      result <= fZ or (fN and not fV) or (not fN and fV);
    when "1000" =>     -- less
      result <= fC or fZ;
    when "1001" =>     -- less than
      result <= (fN and not fV) or (not fN and fV);
    when "1010" =>     -- minus
      result <= fN;
    when "1011" =>     -- zero clear
      result <= not fZ;
    when "1100" =>     -- plus
      result <= not fN;
    when "1101" =>     -- overflow clear
      result <= not fV;
    when "1110" =>     -- overflow set
      result <= fV;
    when "1111" =>     -- ever false
      result <= '0';
    when others =>
      result <= '0';
  end case;
  end process;
end Behavioral;
