library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ff_reset is
  port (
    phi2         : in  std_logic;
    reset_glitch : in  std_logic;
    reset_clean  : out std_logic);
end ff_reset;

architecture behavior of ff_reset is

begin  -- behavior

  -- purpose: Clean and synchronize the reset with the clock
  -- type   : sequential
  -- inputs : phi2, reset_glitch
  -- outputs: reset_clean
  p_ff_reset: process (phi2)
  begin  -- process p_big_xor_register
    if phi2'event and phi2 = '1' then  -- rising clock edge
       reset_clean <= reset_glitch;
    end if;
  end process p_ff_reset;

end behavior;
























