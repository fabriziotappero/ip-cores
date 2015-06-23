-- this is totally unimplemented becasue I don't feel like
-- doing it right now => .

library ieee;
use ieee.std_logic_1164.all;

entity shifter is
  
  port (
    n_shift : in  std_logic_vector(7 downto 0);    -- number of bits to shift
    sh_type : in  std_logic_vector(1 downto 0);    -- which type of shift?
    data    : in  std_logic_vector(15 downto 0);   -- input data
    o       : out std_logic_vector(15 downto 0));  -- shifted data

end shifter;

architecture s_arch of shifter is

begin  -- s_arch

  sh_logic:process(sh_type)
    begin
    case sh_type is
      when "00" =>                       -- left, logical
        o <= "0000000000000000";
                 
      when others => null;
                     
    end case;
  end process sh_logic;

end s_arch;
