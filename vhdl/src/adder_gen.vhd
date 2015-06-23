----------
--! @file
--! @brief This is a two input signed adder.
---------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;

ENTITY adder_gen IS
  generic (add_width : natural);
    port (add_a_in : in std_logic_vector(add_width-1 downto 0);	--! Two input adder element first input port with variable input bit-width
          add_b_in : in std_logic_vector(add_width-1 downto 0);	--! Two input adder element second input port with variable input bit-width
          add_out : out std_logic_vector(add_width-1 downto 0));--! Two input adder element output port with variable input bit-width
END ENTITY adder_gen;

ARCHITECTURE behave OF adder_gen IS
BEGIN
  add_out <= add_a_in + add_b_in;
END ARCHITECTURE behave;

