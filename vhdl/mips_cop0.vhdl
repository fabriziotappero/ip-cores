--------------------------------------------------------------------------------
-- mips_cop0.vhdl -- COP0 for ION CPU.
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
-- Copyright (C) 2013 Jose A. Ruiz
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
use ieee.std_logic_arith.all;
use work.mips_pkg.all;

entity mips_cop0 is
    generic(
        -- Type of memory to be used for register bank in xilinx HW
        XILINX_REGBANK  : string    := "distributed" -- {distributed|block}
    );
    port(
        clk             : in std_logic;
        reset           : in std_logic;

        cpu_i           : in t_cop0_mosi;
        cpu_o           : out t_cop0_miso
    );
end;

architecture rtl of mips_cop0 is

--------------------------------------------------------------------------------
-- CP0 registers and signals

-- CP0[12]: status register, KUo/IEo & KUP/IEp & KU/IE  bits
signal cp0_status :         std_logic_vector(5 downto 0);
signal cp0_sr_ku_reg :      std_logic;
-- CP0[12]: status register, cache control
signal cp0_cache_control :  std_logic_vector(17 downto 16);
-- CP0[14]: EPC register (PC value saved at exceptions)
signal cp0_epc :            t_pc;
-- CP0[13]: 'Cause' register (cause and attributes of exception)
signal cp0_cause :          t_word;
signal cp0_cause_bd :       std_logic;
signal cp0_cause_ce :       std_logic_vector(1 downto 0);
signal cp0_cause_exc_code : std_logic_vector(4 downto 0);

begin


cp0_registers:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            -- KU/IE="10"  ==>  mode=kernel; ints=disabled
            cp0_status <= "000010";  -- bits (KUo/IEo & KUp/IEp) reset to zero
            cp0_sr_ku_reg <= '1'; -- delayed KU flag
            cp0_cache_control <= "00";
            cp0_cause_exc_code <= "00000";
            cp0_cause_bd <= '0';
        else
            if cpu_i.pipeline_stalled='0' then
                if cpu_i.exception='1' then
                    -- Exception: do all that needs to be done right here
                
                    -- Save PC in EPC register...
                    cp0_epc <= cpu_i.pc_restart;
                    -- ... set KU flag to Kernel mode ...
                    cp0_status(1) <= '1';
                    -- ... and 'push' old KU/IE flag values 
                    cp0_status(5 downto 4) <= cp0_status(3 downto 2);
                    cp0_status(3 downto 2) <= cp0_status(1 downto 0);
                    
                    -- Set the 'exception cause' code... 
                    if cpu_i.unknown_opcode='1' then
                        cp0_cause_exc_code <= "01010"; -- bad opcode ('reserved')
                    elsif cpu_i.missing_cop='1' then
                        -- this triggers for mtc0/mfc0 in user mode too
                        cp0_cause_exc_code <= "01011"; -- CP* unavailable 
                    else
                        if cpu_i.syscall='1' then
                            cp0_cause_exc_code <= "01000"; -- syscall
                        else
                            cp0_cause_exc_code <= "01001"; -- break
                        end if;
                    end if;
                    -- ... and the BD flag for exceptions in delay slots
                    cp0_cause_bd <= cpu_i.in_delay_slot;
                
                elsif cpu_i.rfe='1' and cp0_status(1)='1' then
                    -- RFE: restore ('pop') the KU/IE flag values
                    
                    cp0_status(3 downto 2) <= cp0_status(5 downto 4);
                    cp0_status(1 downto 0) <= cp0_status(3 downto 2);
                    
                elsif cpu_i.we='1' and cp0_status(1)='1' then
                    -- MTC0: load CP0[xx] with Rt
                
                    -- NOTE: in MTCx, the source register is Rt
                    -- FIXME this works because only SR is writeable; when 
                    -- CP0[13].IP1-0 are implemented, check for CP0 reg index.
                    cp0_status <= cpu_i.data(cp0_status'high downto 0);
                    cp0_cache_control <= cpu_i.data(17 downto 16);
                end if;
            end if;
            if cpu_i.stall='0' then
                cp0_sr_ku_reg <= cp0_status(1);
            end if;
        end if;
    end if;
end process cp0_registers;

cpu_o.idcache_enable <= cp0_cache_control(17);
cpu_o.icache_invalidate <= cp0_cache_control(16);
cpu_o.kernel <= cp0_sr_ku_reg;

cp0_cause_ce <= "00"; -- FIXME CP* traps merged with unimplemented opcode traps
cp0_cause <= cp0_cause_bd & '0' & cp0_cause_ce & 
             X"00000" & '0' & cp0_cause_exc_code & "00";

-- FIXME the mux should mask to zero for any unused reg index
with cpu_i.index select cpu_o.data <=
    X"000000" & "00" & cp0_status   when "01100",
    cp0_cause                       when "01101",
    cp0_epc & "00"                  when others;


end architecture rtl;
