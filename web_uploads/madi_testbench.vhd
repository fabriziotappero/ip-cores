LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_textio.all;
USE std.textio.all;

ENTITY madi_test IS
END madi_test;

ARCHITECTURE behavior OF madi_test IS

 component madi_to_adat
  port(
   clk_125_in : in std_logic;
   madi_in : in std_logic;
   
   word_clk_in : in std_logic;
--  word_clk_out : out std_logic;
   bit_clk_in : in std_logic;
   adat_0_out : out std_logic;
   adat_1_out : out std_logic;
   adat_2_out : out std_logic;
   adat_3_out : out std_logic;
   adat_4_out : out std_logic;
   adat_5_out : out std_logic;
   adat_6_out : out std_logic;
   adat_7_out : out std_logic
  );
 end component;
 
 signal clk_125_in : std_logic;
 signal madi_in : std_logic := '0';
 signal word_clk_in : std_logic;
-- signal word_clk_out : std_logic;
 signal bit_clk_in : std_logic;
 signal adat_0_out : std_logic;
 signal adat_1_out : std_logic;
 signal adat_2_out : std_logic;
 signal adat_3_out : std_logic;
 signal adat_4_out : std_logic;
 signal adat_5_out : std_logic;
 signal adat_6_out : std_logic;
 signal adat_7_out : std_logic;
 
 constant clk_125_in_half_period : time := 4 ns;
 constant madi_clk : time := 8 ns;
 constant bit_clk_in_half_period : time := 40.690104166666666666666666666667 ns; -- 12.288MHz for a period
 constant word_clk_in_half_period : time := 10.416666666666666666666666666667 us; -- 48kHz for a period
 
 begin
  
  uut: madi_to_adat port map(
   clk_125_in => clk_125_in,
   madi_in => madi_in,
   word_clk_in => word_clk_in,
--   word_clk_out => word_clk_out,
   bit_clk_in => bit_clk_in,
   adat_0_out => adat_0_out,
   adat_1_out => adat_1_out,
   adat_2_out => adat_2_out,
   adat_3_out => adat_3_out,
   adat_4_out => adat_4_out,
   adat_5_out => adat_5_out,
   adat_6_out => adat_6_out,
   adat_7_out => adat_7_out
  );
 
  clk_125_gen : process is
  begin
   clk_125_in <= '0' after clk_125_in_half_period, '1' after 2 * clk_125_in_half_period;
   wait for 2 * clk_125_in_half_period;
  end process clk_125_gen;
  
  bit_clk_in_gen : process is
  begin
   bit_clk_in <= '0' after bit_clk_in_half_period, '1' after 2 * bit_clk_in_half_period;
   wait for 2 * bit_clk_in_half_period;
  end process bit_clk_in_gen;

  word_clk_in_gen : process is
  begin
   word_clk_in <= '0' after word_clk_in_half_period, '1' after 2 * word_clk_in_half_period;
   wait for 2 * word_clk_in_half_period;
  end process word_clk_in_gen;

 
  testbench : process
   file infile : text open read_mode is "bitsequence.txt";
   variable input : std_logic;
   variable buf : line;
  begin
   while (not endfile(infile)) loop
    readline (infile,buf);
    read (buf,input);
    if input = '0' then
     madi_in <= madi_in;
    else
     madi_in <= not madi_in;
    end if;
    wait for madi_clk;
   end loop;
  wait; -- wait forever
 end process;
end;