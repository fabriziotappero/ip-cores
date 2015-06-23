----------------------------------------------------------------------
--                                                                  --
--  THIS VHDL SOURCE CODE IS PROVIDED UNDER THE GNU PUBLIC LICENSE  --
--                                                                  --
----------------------------------------------------------------------
--                                                                  --
--    Filename            : quadratic_func_bench.vhd                --
--                                                                  --
--    Author              : Simon Doherty                           --
--                          Senior Design Consultant                --
--                          www.zipcores.com                        --
--                                                                  --
--    Date last modified  : 16.02.2009                              --
--                                                                  --
--    Description         : Quadratic function testbench            --
--                                                                  --
----------------------------------------------------------------------


use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;


entity quadratic_func_bench is
begin
end quadratic_func_bench;


architecture behav of quadratic_func_bench is


component quadratic_func

generic ( fw : integer ); -- width of fraction in range 0 to 8

port (

  -- system clock
  clk      : in  std_logic;
  
  -- clock enable
  en       : in  std_logic;
  
  -- Coefficients as 8-bit signed fraction
  coeff_a  : in  std_logic_vector(7 downto 0);
  coeff_b  : in  std_logic_vector(7 downto 0);
  coeff_c  : in  std_logic_vector(7 downto 0);
  
  -- Input as a 8-bit signed fraction
  x_in     : in  std_logic_vector(7 downto 0);
  
  -- Output as a 24-bit signed fraction
  y_out    : out std_logic_vector(23 downto 0));

end component;


signal  clk            : std_logic := '0';
signal  reset          : std_logic := '0';
signal  capture        : std_logic := '0';
signal  end_of_test    : std_logic := '0';
signal  count          : std_logic_vector(7 downto 0);

signal  coeff_a        : std_logic_vector(7 downto 0);
signal  coeff_b        : std_logic_vector(7 downto 0);
signal  coeff_c        : std_logic_vector(7 downto 0);

signal  x_in           : std_logic_vector(7 downto 0);
signal  y_out          : std_logic_vector(23 downto 0);
signal  y_int          : integer;


begin


-- Generate a 100MHz clk
clk <= not clk after 5 ns;


-- Test bench control
test_bench_control: process
begin
    -- start of test
    wait for 1 us;
	wait until clk'event and clk = '1';
	-- bring out of reset
    reset <= '1';
    -- module has 3-cycle latency
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    -- start capturing the output
    capture <= '1';
    wait until clk'event and clk = '1' and end_of_test = '1';
    -- module has 3-cycle latency
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    -- stop capturing the output
    capture <= '0';
    wait for 1 us;
    wait until clk'event and clk = '1';
    assert false report "    SIMULATION FINISHED!" severity failure;
end process test_bench_control;


-- generate input sequence from -128 to 127
counter: process(clk, reset)
begin
  if reset = '0' then
    count <= "10000000";
  elsif clk'event and clk = '1' then
    count <= unsigned(count) + '1';
  end if;
end process counter;


-- check for end of test
end_of_test <= '1' when (count = "01111111") else '0';


-- Fixed coefficients
coeff_a <= std_logic_vector(conv_signed( 55 ,8));
coeff_b <= std_logic_vector(conv_signed(-14, 8));
coeff_c <= std_logic_vector(conv_signed( 19 ,8));


-- Input stimulus
x_in <= count;


-- DUT
quad_func: quadratic_func

generic map ( fw => 6 )

port map (

  -- system clock
  clk      => clk,
  
  -- clock enable
  en       => '1',
  
  -- 8-bit signed coefficients
  coeff_a  => coeff_a,
  coeff_b  => coeff_b,
  coeff_c  => coeff_c,
  
  -- 8-bit signed input
  x_in     => x_in,
  
  -- 24-bit signed output
  y_out    => y_out );


-- Convert 24-bit output to integer
y_int <= conv_integer(unsigned(y_out));


-- Capture output data
grab_data: process (clk)

  file     terminal   : text open write_mode is "quadratic_func_out.txt";
  variable resoutline : line;

begin

  if clk'event and clk = '1' then
    if capture = '1' then
       write(resoutline, y_int);
       writeline(terminal, resoutline);
     end if;
   end if;
end process grab_data;


end behav;
