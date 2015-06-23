----------------------------------------------------------------------------------
-- Author:          Jonny Doin, jdoin@opencores.org, jonnydoin@gmail.com
-- 
-- Create Date:     01:21:32 06/30/2011 
-- Design Name: 
-- Module Name:     debounce_atlys_top
-- Project Name:    debounce_vhdl
-- Target Devices:  Spartan-6 LX45
-- Tool versions:   ISE 13.1
-- Description: 
--
--          This is a verification project for the Digilent Atlys board, to test the GRP_DEBOUNCE core.
--          It uses the board's 100MHz clock input, and clocks all sequential logic at this clock.
--
--          See the "debounce_atlys.ucf" file for pin assignments.
--          The test circuit uses the VHDCI connector on the Atlys to implement a 16-pin debug port to be used
--          with a Tektronix MSO2014. The 16 debug pins are brought to 2 8x2 headers that form a umbilical
--          digital pod port.
--          If you want details of the testing circuit, send me an e-mail: jdoin@opencores.org
--
------------------------------ REVISION HISTORY -----------------------------------------------------------------------
--
-- 2011/08/10   v1.01.0025  [JD]    changed to test the grp_debouncer.vhd module alone.
-- 2011/08/11   v1.01.0026  [JD]    reduced switch inputs to 7, to save digital pins to the strobe signal.
--
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity debounce_atlys_top is
    Port (
        gclk_i : in std_logic := 'X';               -- board clock input 100MHz
        --- input slide switches ---            
        sw_i : in std_logic_vector (6 downto 0);    -- 7 input slide switches
        --- output LEDs ----            
        led_o : out std_logic_vector (6 downto 0);  -- 7 output leds
        --- debug outputs ---
        dbg_o : out std_logic_vector (15 downto 0)  -- 16 generic debug pins
    );                      
end debounce_atlys_top;

architecture rtl of debounce_atlys_top is

    --=============================================================================================
    -- Constants
    --=============================================================================================
    -- debounce generics
    constant N          : integer   := 7;           -- 7 bits (7 switch inputs)
    constant CNT_VAL    : integer   := 5000;        -- debounce period = 1000 * 10 ns (50 us)
    
    --=============================================================================================
    -- Signals for internal operation
    --=============================================================================================
    --- switch debouncer signals ---
    signal sw_data          : std_logic_vector (6 downto 0) := (others => '0'); -- debounced switch data
    signal sw_reg           : std_logic_vector (6 downto 0) := (others => '0'); -- registered switch data 
    signal sw_new           : std_logic := '0';
    -- debug output signals
    signal leds_reg         : std_logic_vector (6 downto 0) := (others => '0');
    signal dbg              : std_logic_vector (15 downto 0) := (others => '0');
begin

    --=============================================================================================
    -- COMPONENT INSTANTIATIONS FOR THE CORES UNDER TEST
    --=============================================================================================
    -- debounce for the input switches, with new data strobe output
    Inst_sw_debouncer: entity work.grp_debouncer(rtl)
        generic map (N => N, CNT_VAL => CNT_VAL)
        port map(  
            clk_i => gclk_i,                        -- system clock
            data_i => sw_i,                         -- noisy input data
            data_o => sw_data,                      -- registered stable output data
            strb_o => sw_new                        -- transition detection
        );

    --=============================================================================================
    --  REGISTER TRANSFER PROCESSES
    --=============================================================================================
    -- data registers: synchronous to the system clock
    dat_reg_proc : process (gclk_i) is
    begin
        -- transfer switch data when new switch is detected
        if gclk_i'event and gclk_i = '1' then
            if sw_new = '1' then                    -- clock enable
                sw_reg <= sw_data;                  -- only provide local reset for the state registers
            end if;
        end if;
    end process dat_reg_proc;

    --=============================================================================================
    --  COMBINATORIAL LOGIC PROCESSES
    --=============================================================================================
    -- LED register update
    leds_reg_proc: leds_reg <= sw_reg;              -- leds register is a copy of the updated switch register

    -- update debug register
    dbg_in_proc:    dbg(6 downto 0) <= sw_i;        -- lower debug port has direct switch connections
    dbg_out_proc:   dbg(13 downto 7) <= sw_data;    -- upper debug port has debounced switch data
    dbg_strb_proc:  dbg(14) <= sw_new;              -- monitor new data strobe
    

    --=============================================================================================
    --  OUTPUT LOGIC PROCESSES
    --=============================================================================================
    -- connect leds_reg signal to LED outputs
    led_o_proc: led_o <= leds_reg;              -- drive the output leds

    --=============================================================================================
    --  DEBUG LOGIC PROCESSES
    --=============================================================================================
    -- connect the debug vector outputs
    dbg_o_proc: dbg_o <= dbg;                   -- drive the logic analyzer port
    
end rtl;

