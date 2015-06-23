library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity big_xor is
  port (
    reset       : in  std_logic;
    -- This reset is more a "set" to the initial FCS value
    phi2        : in  std_logic;
    input_input : in  std_logic_vector(15 downto 0);
    fcs_input   : in  std_logic_vector(15 downto 0);  -- LS Word
    gf_input    : in  std_logic_vector(15 downto 0);  -- MS Word
    output      : out std_logic_vector(31 downto 0));
end big_xor ;

architecture behavior of big_xor is

  signal output_xor : std_logic_vector(15 downto 0);  
  -- Intermediate signal between the XOR and the FCS register
  
begin  -- behavior

  -- purpose: This is the final part of the generator. The input and the
  -- output from the multiplier are XOR-ed in order to obtain the final value.
  -- type   : sequential
  -- inputs : phi2, reset, input_input, fcs_input, gf_input
  -- outputs: output
  p_big_xor_register: process (phi2, reset)
  begin  -- process p_big_xor_register
    if reset = '0' then                 -- asynchronous reset (active low)
      output <= X"46AF6449";
--      output_xor <= X"46AF";
-- The line before is not needed
    elsif phi2'event and phi2 = '1' then  -- rising clock edge
      output(15 downto 0)  <= output_xor(15 downto 0);
      output(31 downto 16) <= fcs_input(15 downto 0);
--    else
--	output_xor <= gf_input xor input_input;
    end if;
  end process p_big_xor_register;

  p_big_xor_combinational: process (gf_input, input_input)
  begin  -- process p_big_xor_combinational
      output_xor <= gf_input xor input_input;
  end process p_big_xor_combinational;

end behavior;
