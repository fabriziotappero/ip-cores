library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.STD_LOGIC_UNSIGNED.ALL;
use     IEEE.STD_LOGIC_ARITH.ALL;
use     std.textio.all;

entity example_dut is
  port(
       EX_RESET_N              : in    std_logic;
       EX_CLK_IN               : in    std_logic;
       --  interface pins
       EX_DATA1                : out   std_logic_vector(31 downto 0);
       EX_DATA2                : out   std_logic_vector(31 downto 0);
       --  env access port
       STM_ADD                 : in    std_logic_vector(31 downto 0);
       STM_DAT                 : inout std_logic_vector(31 downto 0);
       STM_RWN                 : in    std_logic;
       STM_REQ_N               : in    std_logic;
       STM_ACK_N               : out   std_logic
      );
end example_dut;
