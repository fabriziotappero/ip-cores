library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity mux32 is
    Port ( A : in std_logic_vector(31 downto 0);
           B : in std_logic_vector(31 downto 0);
           SEL : in std_logic;
           MUX_OUT : out std_logic_vector(31 downto 0));
end mux32;

architecture Behavioral of mux32 is

begin

process (SEL, A, B)
begin
   case SEL is
      when '0' => MUX_OUT <= A;
      when '1' => MUX_OUT <= B;
      when others => NULL;
   end case;
end process;



end Behavioral;
