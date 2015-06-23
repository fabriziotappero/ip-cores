--------------------------------------------------------------------------------
-- light52_timer.vhdl -- 16-bit timer with prescaler.
--------------------------------------------------------------------------------
--  Basic timer, not directly compatible to any of the original MCS51 timers. 
--  This timer is totally independent of the UART.
-- 
--  This is essentially a reloadable up-counter that optionally triggers an 
--  interrupt every time the count reaches a certain value.
-- 
--------------------------------------------------------------------------------
-- REGISTERS
-------------
--
--  The core includes 3 registers:
--  - A configurable prescaler register of up to 31 bits.
--  - A 16-bit compare register accessible through TCL and TCH.
--  - A 16-bit counter register accessible through TL and TH.
--  
--  Reading TL or TH will give the value of the timer register. If the registers
--  are read while the count is enabled, the software has to deal with a 
--  possibly inconsistent (TL,TH) pair and should apply the usual tricks.
--  
--  The prescaler is reset to 0 when TCON.CEN=0. When TCON.CEN=1 it counts up to 
--  PRESCALER_VALUE-1, then rolls over to 0 and the timer register is 
--  incremented.
--
--  The compare register is write-only, in order to save logic. Reading TCH or
--  TCL will give the value of TCON.
--  
-- OPERATION
-------------
--
--  The counter register is reset to 0 when TCON.CEN=0. 
--  When flag TCON.CEN is set to 1, the counter starts counting up at a rate
--  of one count every PRESCALER_VALUE clock cycles. 
--  When counter register = reload register, the following will happen:
--
--    - If flag ARL is 0 the core will clear flag CEN and and raise flag Irq,
--      triggering an interrupt. 
--      The counter will overflow to 0000h and stop.
--
--    - If flag ARL is 1 then flag CEN will remain high and flag Irq will be 
--      raised, triggering an interrupt.  
--      The counter will overflow to 0000h and continue counting.
--
--------------------------------------------------------------------------------
-- CONTROL REGISTERS
---------------------
--
-- The timer has a number of registers addressable with input signal addr_i:
--
-- [000] => TCON: Status/control register (r/w).
-- [100] => TCL: Counter register, low byte.
-- [101] => TCH: Counter register, high byte.
-- [110] => TRL: Reload register, low byte. Write only, will read TCON.
-- [111] => TRL: Reload register, low byte. Write only, will read TCON.
--
-- All other addresses are unused and will read TCON.
--
-- Note that the SFR address mapping is determined externally.
--
-- TCON Control/Status register flags:
---------------------------------------
--
--      7       6       5       4       3       2       1       0
--  +-------+-------+-------+-------+-------+-------+-------+-------+
--  |   0   |   0   |  CEN  |  ARL  |   0   |   0   |   0   |  Irq  |
--  +-------+-------+-------+-------+-------+-------+-------+-------+
--      h       h      r/w      r/w      h       h       h      W1C    
--
--  Bits marked 'h' are hardwired and can't be modified. 
--  Bits marked 'r' are read only; they are set and clear by the core.
--  Bits marked 'r/w' can be read and written to by the CPU.
--  Bits marked W1C ('Write 1 Clear') are set by the core when an interrupt 
--  has been triggered and must be cleared by the software by writing a '1'.
--
-- -# Flag CEN (Count ENable) must be set to 1 by the CPU to start the timer. 
--    When CEN is 0, the prescaler is reset and the timer register is stopped.
--    Writing a 1 to CEN will start the count up. The counter will count 
--    until it matches the compare register value (if ARL=1) or it overflows 
--    (if ARL=0). At which moment it will roll back to zero.
--
-- -# Flag ARL (Auto ReLoad) must be set to 1 for autoreload mode. Its reset 
--    value is 0.
--
-- -# Status bit Irq is raised when the counter reaches zero and an interrupt 
--    is triggered, and is cleared when a 1 is written to it.
--
-- When writing to the status/control registers, only flags TxIrq and RxIrq are
-- affected, and only when writing a '1' as explained above. All other flags 
-- are read-only.
--
--------------------------------------------------------------------------------
-- Copyright (C) 2012 Jose A. Ruiz
--                                                              
-- This source file may be used and distributed without         
-- restriction provided that this copyright statement is not    
-- removed from the file and that any derivative work contains  
-- the original copyright notice and the associated disclaimer. 
--                                                              
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--                                                              
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--                                                              
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.opencores.org/lgpl.shtml
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.light52_pkg.all;

entity light52_timer is
    generic (
        PRESCALER_VALUE : natural := 1
    );
    port(
        irq_o     : out std_logic;
        
        data_i    : in std_logic_vector(7 downto 0);
        data_o    : out std_logic_vector(7 downto 0);
        
        addr_i    : in std_logic_vector(2 downto 0);
        wr_i      : in std_logic;
        ce_i      : in std_logic;
        
        clk_i     : in std_logic;
        reset_i   : in std_logic

    );
end entity light52_timer;


architecture plain of light52_timer is

constant PRESCALER_WIDTH : natural := log2(PRESCALER_VALUE);

signal clk, reset :         std_logic;

signal prescaler_ctr_reg :  unsigned(PRESCALER_WIDTH-1 downto 0);
signal prescaler_overflow : std_logic;
signal counter_reg :        unsigned(15 downto 0);
signal compare_reg :        unsigned(15 downto 0);
signal counter_match :      std_logic;
signal load_enable :        std_logic;
signal load_status_reg :    std_logic;

signal flag_autoreload_reg: std_logic;
signal flag_counting_reg :  std_logic;
signal flag_irq_reg :       std_logic;
signal status_reg :         std_logic_vector(7 downto 0);


begin

clk <= clk_i;
reset <= reset_i;

-- If the prescaler is longer than a reasonable arbitrary value, kill the
-- synthesis and let the user deal with this -- possibly modifying this 
-- file if a long prescaler is actually necessary.
assert PRESCALER_WIDTH <= 31
report "Timer prescaler is wider than 31 bits."
severity failure;

prescaler_counter:
process(clk)
begin
    if clk'event and clk='1' then
        if status_reg(5)='0' or reset='1' then
            -- Disabling the count initializes the prescaler too.
            prescaler_ctr_reg <= (others => '0');
        else
            if prescaler_overflow='1' then 
                prescaler_ctr_reg <= (others => '0');
            else 
                prescaler_ctr_reg <= prescaler_ctr_reg + 1;
            end if;
        end if;
    end if;
end process prescaler_counter;

prescaler_overflow <= '1' when to_integer(prescaler_ctr_reg)=PRESCALER_VALUE-1 
                      else '0';

                     
timer_counter:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            compare_reg <= (others => '1');
            counter_reg <= (others => '0');
        else 
            if load_enable='1' and addr_i(2)='1' then
                case addr_i(1 downto 0) is
                when "00" =>    counter_reg(7 downto 0) <= unsigned(data_i);
                when "01" =>    counter_reg(15 downto 8) <= unsigned(data_i);
                when "10" =>    compare_reg(7 downto 0) <= unsigned(data_i);
                when others =>  compare_reg(15 downto 8) <= unsigned(data_i);
                end case;
            else
                if flag_counting_reg='0' then
                    counter_reg <= (others => '0');
                else
                    if prescaler_overflow='1' then
                        if (counter_match and flag_autoreload_reg)='1' then 
                            counter_reg <= (others => '0');
                        else
                            counter_reg <= counter_reg + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end if;
end process timer_counter;

counter_match <= '1' when counter_reg=compare_reg else '0';


---- Status register -----------------------------------------------------------

status_register:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            flag_irq_reg <= '0';
            flag_autoreload_reg <= '0';
            flag_counting_reg <= '0';
        else
            if (counter_match and prescaler_overflow)='1' then
                flag_irq_reg <= '1';
            elsif load_status_reg='1' then
                if data_i(0)='1' then
                    flag_irq_reg <= '0';
                end if;
            end if;
            if load_status_reg='1' then
                flag_autoreload_reg <= data_i(4);
                flag_counting_reg <= data_i(5);
            elsif (counter_match and not flag_autoreload_reg)='1' then
                flag_counting_reg <= '0';
            end if;
        end if;
    end if;
end process status_register;

status_reg <= "00" & flag_counting_reg & flag_autoreload_reg & 
              "000" & flag_irq_reg;


---- SFR interface -------------------------------------------------------------

load_enable <= '1' when wr_i='1' and ce_i='1' else '0';
load_status_reg   <= '1' when load_enable='1' and addr_i="000" else '0';

with addr_i select data_o <=
    std_logic_vector(counter_reg( 7 downto  0))     when "100",
    std_logic_vector(counter_reg(15 downto  8))     when "101",
    status_reg                                      when others;

irq_o <= flag_irq_reg;
                     

end architecture plain;
