-- Test bench created by Fernando Blanco (ferblanco@anagramix.com)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ts is
end ts;

architecture testbench of ts is

-- To start the program: 
signal avuc_start: std_logic;
-- To stop the program:
signal avuc_rst: std_logic;
-- Main clock:
signal clk: std_logic;
-- Memory data bus:
signal mem_data: std_logic_vector(7 downto 0);
-- Memory address bus:
signal mem_addr: std_logic_vector(6 downto 0);
-- State of the program (running/stopped):
signal avuc_state: std_logic;
 
constant clk_cycle: time := 10 ns;

component max_mem 
   port (
      -- To start the program:
      avuc_start: in std_logic;
      -- To stop the program:
      avuc_rst: in std_logic;
      -- Main clock:
      clk: in std_logic;
      -- Memory data bus:
      mem_data: in std_logic_vector(7 downto 0);
      -- Memory address bus:
      mem_addr: out std_logic_vector(6 downto 0);
      -- State of the program (running/stopped):
      avuc_state: out std_logic
   );
end component max_mem;

   begin

   i_max_mem: max_mem port map (avuc_start => avuc_start,
      avuc_rst => avuc_rst,
      clk => clk,
      mem_data => mem_data,
      mem_addr => mem_addr,
      avuc_state => avuc_state );

   mem_data <= x"2B" when mem_addr = 0 else
               x"2F" when mem_addr = 1 else
               x"32" when mem_addr = 2 else
               x"24" when mem_addr = 3 else
               x"16" when mem_addr = 4 else
               x"1A" when mem_addr = 5 else
               x"34" when mem_addr = 6 else
               x"27" when mem_addr = 7 else
               x"11" when mem_addr = 8 else
               x"13" when mem_addr = 9 else
               x"02" when mem_addr = 10 else
               x"39" when mem_addr = 11 else
               x"41" when mem_addr = 12 else
               x"46" when mem_addr = 13 else
               x"2E" when mem_addr = 14 else
               x"1C" when mem_addr = 15 else
               x"04" when mem_addr = 16 else
               x"07" when mem_addr = 17 else
               x"53" when mem_addr = 18 else
               x"03" when mem_addr = 19 else
               x"13" when mem_addr = 20 else
               x"35" when mem_addr = 21 else
               x"4F" when mem_addr = 22 else
               x"00";

   avuc_start <= '0',
                 '1' after 80*clk_cycle,
                 '0' after 81*clk_cycle;

   avuc_rst <= '0';

   p_clk: process
   begin
      clk <= '0' after 0 ns, '1' after clk_cycle/2;
      wait for clk_cycle;
   end process p_clk;

end testbench;
