library ieee;
use ieee.std_logic_1164.ALL;




entity core_a is
generic(
   param1   : natural := 8;
   param2   : natural := 4;
   param3   : natural := 5
  ); 
port(
   sig_con1a : in  std_logic_vector( param1-1 downto 0 );
   sig_con1b : in  std_logic_vector( param2-1 downto 0 );
   sig_con1c : out std_logic
);
end entity core_a;

architecture IMPL of core_a is


begin

   sig_con1c <= '1';

end architecture IMPL;


