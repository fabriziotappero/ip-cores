--  ttb_gen generated file
library IEEE;
library ieee_proposed;
library work;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee_proposed.STD_LOGIC_1164_additions.all;
use std.textio.all;
use work.tb_pkg.all;  --  test bench package


entity example_dut_tb is
   generic (
            stimulus_file: in string
           );
   port (
         ex_reset_n : buffer  std_logic;
         ex_clk_in  : buffer  std_logic;
         ex_data1   : in      std_logic_vector(31 downto 0);
         ex_data2   : in      std_logic_vector(31 downto 0);
         stm_add    : buffer  std_logic_vector(31 downto 0);
         stm_dat    : inout   std_logic_vector(31 downto 0);
         stm_rwn    : buffer  std_logic;
         stm_req_n  : buffer  std_logic;
         stm_ack_n  : in      std_logic
        );
end example_dut_tb;
