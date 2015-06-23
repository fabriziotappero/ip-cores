--------------------------------------------------------------------------------
-- c2sb_soc_tb.vhdl -- Minimal test bench for c2sb_soc.
--
-- c2sb_soc is a light8080 SoC demo on a Cyclone 2 starter Board (C2SB). This
-- is a minimalistic simulation test bench. The test bench only drives the clock
-- and reset inputs.
--
-- This simulation test bench can be marginally useful for basic troubleshooting
-- of a C2SB board demo or as a starting point for a true test bench.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.ALL;

entity c2sb_soc_tb is
end entity c2sb_soc_tb;

architecture behavior of c2sb_soc_tb is

--------------------------------------------------------------------------------
-- Simulation parameters

-- T: simulated clock period
constant T : time := 100 ns;

-- MAX_SIM_LENGTH: maximum simulation time
constant MAX_SIM_LENGTH : time := T*7000000; -- enough for most purposes


--------------------------------------------------------------------------------

signal clk :              std_logic := '0';
signal done :             std_logic := '0';
signal buttons :          std_logic_vector(3 downto 0);
signal green_leds :       std_logic_vector(7 downto 0);
signal txd :              std_logic;

begin

  -- Instantiate the Unit Under Test (UUT)
  -- The only mandatory signals are clk and buttons(3)
  uut: entity work.c2sb_soc 
  port map (
    clk_50MHz =>        clk,
    buttons =>          buttons,
    
    rxd =>              txd,
    txd =>              txd,
    flash_data =>       (others => '0'),
    switches =>         (others => '0'),
    sd_data =>          '0',
    green_leds =>       green_leds
  );


  -- clock: run clock until test is done
  clock:
  process(done, clk)
  begin
    if done = '0' then
      clk <= not clk after T/2;
    end if;
  end process clock;


  -- Drive reset and done 
  main_test:
  process
  begin
    -- Assert reset for at least one full clk period
    buttons(0) <= '0';
    wait until clk = '1';
    wait for T/2;
    buttons(0) <= '1';

    -- Remember to 'cut away' the preceding 3 clk semiperiods from 
    -- the wait statement...
    wait for (MAX_SIM_LENGTH - T*1.5);

    -- Maximum sim time elapsed, stop the clk process asserting 'done' (which 
    -- will stop the simulation)
    done <= '1';
    
    assert (done = '1') 
    report "Test timed out."
    severity failure;
    
    wait;
  end process main_test;
  
end;
