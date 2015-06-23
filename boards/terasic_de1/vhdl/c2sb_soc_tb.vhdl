--------------------------------------------------------------------------------
-- c2sb_soc_tb.vhdl -- Minimal test bench for c2sb_soc.
--
-- c2sb_soc is a light52 MCU demo on a Cyclone 2 starter Board (C2SB). This
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
use std.textio.all;

use work.light52_tb_pkg.all;
use work.txt_util.all;


entity c2sb_soc_tb is
end entity c2sb_soc_tb;

architecture testbench of c2sb_soc_tb is

--------------------------------------------------------------------------------
-- Simulation parameters

-- T: simulated clock period (50MHz)
constant T : time := 20 ns;

-- SIMULATION_LENGTH: maximum simulation time in clock cycles 
constant SIMULATION_LENGTH : natural := 99000000; -- enough for most purposes

-- Size of ROM, as defined in the top file. Used to catch stray jumps.
constant ROM_SIZE : natural := 16384;


--------------------------------------------------------------------------------
-- FPGA interface & simulation signals

signal clk :                std_logic := '0';
signal reset :              std_logic;
signal done :               std_logic := '0';
signal buttons :            std_logic_vector(3 downto 0);
signal switches :           std_logic_vector(9 downto 0);
signal green_leds :         std_logic_vector(7 downto 0);
signal txd :                std_logic;


--------------------------------------------------------------------------------
-- Logging signals

-- Log file
file log_file: TEXT open write_mode is "hw_sim_log.txt";
-- Console output log file
file con_file: TEXT open write_mode is "hw_sim_console_log.txt";
-- Info record needed by the logging fuctions
signal log_info :           t_log_info;


begin

---- UUT instantiation ---------------------------------------------------------
  
  -- We're leaving unconnected all the FPGA pins that ars not used in the demo
    uut: entity work.c2sb_soc 
    port map (
        clk_50MHz =>        clk,
        buttons =>          buttons,
        switches =>         switches,
        rxd =>              txd,
        txd =>              txd,
        
        flash_data =>       (others => '0'),
        sd_data =>          '0',
        green_leds =>       green_leds
    );
    
    -- The reset signal is used by the logging functions only.
    reset <= not switches(9);
    
    
    ---- Master clock: free running clock used as main module clock ------------
    run_master_clock:
    process(done, clk)
    begin
        if done = '0' then
            clk <= not clk after T/2;
        end if;
    end process run_master_clock;

    ---- Main simulation process: reset MCU and wait for fixed period ----------

    drive_uut:
    process
    begin
        switches <= (others => '0');
        -- Leave reset asserted for a few clock cycles...
        switches(9) <= '0';
        wait for T*4;
        switches(9) <= '1';
        
        -- ...and wait for the test to hit a termination condition (evaluated by
        -- function log_cpu_activity) or to just timeout.
        wait for T * SIMULATION_LENGTH;

        -- If we arrive here, the simulation timed out (termination conditions
        -- trigger a failed assertion).
        -- So print a timeout message and quit.
        print("TB timed out.");
        done <= '1';
        wait;
        
    end process drive_uut;


    -- Logging process: launch logger functions --------------------------------
    log_execution:
    process
    begin
        -- Log cpu activity until done='1'.
        log_cpu_activity(clk, reset, done, "/uut/mcu",
                         log_info, ROM_SIZE, "log_info", 
                         X"0000", log_file, con_file);
        
        -- Flush console log file when finished.
        log_flush_console(log_info, con_file);
        
        wait;
    end process log_execution;
  
end testbench;
