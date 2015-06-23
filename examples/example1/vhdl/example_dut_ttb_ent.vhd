
library IEEE;
--library dut_lib;
use IEEE.STD_LOGIC_1164.all;
--use dut_lib.all;

entity example_dut_ttb is
  generic (
           stimulus_file: string := "stm/stimulus_file.stm"
          );
end example_dut_ttb;
