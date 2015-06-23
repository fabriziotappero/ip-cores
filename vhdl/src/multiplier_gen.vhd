----------
--! @file
--! @brief This is signed constant multiplier with unsigned input port.
----------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
USE ieee.std_logic_arith.all;

ENTITY multiplier_gen IS
  generic (multi_width_const 	: natural;
           multi_width_in 	: natural);
    port (multiplier_const  : in  std_logic_vector(multi_width_const-1 downto 0);			--! Constant multiplier hardwired to the filter coefficient
          multiplier_in     : in  std_logic_vector(multi_width_in-1 downto 0);				--! Constant multiplier input port with variable bit-width
          multiplier_out    : out std_logic_vector((multi_width_const+multi_width_in)+1 downto 0));	--! Constant multiplier output port
END ENTITY multiplier_gen;

--
ARCHITECTURE behave OF multiplier_gen IS
signal tmp_multiplier_out 	: std_logic_vector((multi_width_const+multi_width_in) downto 0);
signal tmp_msb 			: std_logic;
BEGIN
	tmp_multiplier_out 	<= unsigned(multiplier_in) * signed(multiplier_const);
	tmp_msb 		<= tmp_multiplier_out(tmp_multiplier_out'left);
  	multiplier_out 		<= tmp_msb&tmp_multiplier_out;
END ARCHITECTURE behave;

