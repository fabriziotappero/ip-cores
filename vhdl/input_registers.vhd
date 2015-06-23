library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------
-- We first describe the entities of the two types of registers used in the
-- pipelining.

entity input_phi1_register is
  
  port (
    reset  : in  std_logic;
    phi1   : in  std_logic;
    input  : in  std_logic_vector(15 downto 0);
    output : out std_logic_vector(15 downto 0));

end input_phi1_register;

architecture behavior of input_phi1_register is

begin  -- behavior

  -- purpose: Pipelining register activated by phi1
  -- type   : sequential
  -- inputs : phi1, reset, input (16 bits)
  -- outputs: output (16 bits)
  p_input_phi1_register : process (phi1, reset)
  begin  -- process
    if reset = '0' then                 -- asynchronous reset (active low)
      output <= (others => '0');
    elsif phi1'event and phi1 = '1' then  -- rising clock edge
      output <= input;
    end if;
  end process;

end behavior;

-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity input_phi2_register is

  port (
    reset  : in  std_logic;
    phi2   : in  std_logic;
    input  : in  std_logic_vector(15 downto 0);
    output : out std_logic_vector(15 downto 0));

end input_phi2_register;

architecture behavior of input_phi2_register is

begin  -- behavior

  -- purpose: Pipelining register activated by phi2
  -- type   : sequential
  -- inputs : phi2, reset, input (16 bits)
  -- outputs: output (16 bits)
  p_input_phi2_register: process (phi2, reset)
  begin  -- process p_input_phi2_register
    if reset = '0' then                 -- asynchronous reset (active low)
      output <= (others => '0');
    elsif phi2'event and phi2 = '1' then  -- rising clock edge
      output <= input;
    end if;
  end process p_input_phi2_register;

end behavior;






