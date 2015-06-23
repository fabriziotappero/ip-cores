----------------------------------------------------------------------
--                                                                  --
--  THIS VHDL SOURCE CODE IS PROVIDED UNDER THE GNU PUBLIC LICENSE  --
--                                                                  --
----------------------------------------------------------------------
--                                                                  --
--    Filename            : waveform_gen_bench.vhd                  --
--                                                                  --
--    Author              : Simon Doherty                           --
--                          Senior Design Consultant                --
--                          www.zipcores.com                        --
--                                                                  --
--    Date last modified  : 24.10.2008                              --
--                                                                  --
--    Description         : NCO / Periodic Waveform Generator TB    --
--                                                                  --
----------------------------------------------------------------------


use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;


entity waveform_gen_bench is
begin
end waveform_gen_bench;


architecture behav of waveform_gen_bench is


component waveform_gen

port (

  -- system signals
  clk         : in  std_logic;
  reset       : in  std_logic;
  
  -- clock-enable
  en          : in  std_logic;
  
  -- NCO frequency control
  phase_inc   : in  std_logic_vector(31 downto 0);
  
  -- Output waveforms
  sin_out     : out std_logic_vector(11 downto 0);
  cos_out     : out std_logic_vector(11 downto 0);
  squ_out     : out std_logic_vector(11 downto 0);
  saw_out     : out std_logic_vector(11 downto 0) );
  
end component;


signal  clk        : std_logic := '0';
signal  reset      : std_logic := '0';
signal  capture    : std_logic := '0';
signal  en         : std_logic := '1';

signal  phase_inc  : std_logic_vector(31 downto 0) := (others => '0');

signal  sin_out    : std_logic_vector(11 downto 0);
signal  cos_out    : std_logic_vector(11 downto 0);
signal  squ_out    : std_logic_vector(11 downto 0);
signal  saw_out    : std_logic_vector(11 downto 0);

signal  sin_int    : integer;
signal  cos_int    : integer;
signal  squ_int    : integer;
signal  saw_int    : integer;


begin


-- Generate a 100MHz clk
clk <= not clk after 5 ns;


-- Set NCO frequency : Phase_inc = (Fout/Fclk)*2^32
phase_inc <= X"045a1cac"; -- 1.7MHz example frequency


-- Test bench control
test_bench_control: process
begin
    -- start of test
    wait for 1 us;
	wait until clk'event and clk = '1';
	-- bring out of reset
    reset <= '1';

    -- start output capture
    wait for 1 us;
	wait until clk'event and clk = '1';
    capture <= '1';
        
    -- run sim for a while
    wait for 100 us;
    wait until clk'event and clk = '1';
    assert false report "    SIMULATION FINISHED!" severity failure;
end process test_bench_control;


-- DUT
nco: waveform_gen

port map (

  -- system signals
  clk         => clk,
  reset       => reset,
  
  -- clock-enable
  en          => en,
  
  -- NCO frequency control
  phase_inc   => phase_inc,
  
  -- Output waveforms
  sin_out     => sin_out,
  cos_out     => cos_out,
  squ_out     => squ_out,
  saw_out     => saw_out );

  
-- Convert 12-bit outputs to integers
sin_int <= conv_integer(signed(sin_out));
cos_int <= conv_integer(signed(cos_out));
squ_int <= conv_integer(signed(squ_out));
saw_int <= conv_integer(signed(saw_out));


-- Capture output data
grab_data: process (clk)

  file     terminal   : text open write_mode is "waveform_out.txt";
  variable resoutline : line;

begin

  if clk'event and clk = '1' then
    if capture = '1' then
       write(resoutline, sin_int);
       write(resoutline, string'(" "));
       write(resoutline, cos_int);
       write(resoutline, string'(" "));
       write(resoutline, squ_int);
       write(resoutline, string'(" "));
       write(resoutline, saw_int);
       writeline(terminal, resoutline);
     end if;
   end if;
end process grab_data;

  
end behav;