library ieee;
use ieee.std_logic_1164.ALL;



entity core_b is
port(
   mysig_con1a : out std_logic_vector( 7 downto 0 );
   mysig_con1b : out std_logic_vector( 31 downto 0 );
   mysig_con1c : in  std_logic
);
end entity core_b;

architecture IMPL of core_b is


begin


   mysig_con1a <= "11001010";
   mysig_con1b <= ( others => '1' );

end architecture IMPL;


