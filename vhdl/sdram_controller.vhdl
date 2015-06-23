--------------------------------------------------------------------------------
-- sdram_controller.vhdl -- Interface for 16-bit SDRAM (non-DDR).
--
-- This module has been tested with a PSC A2V64S40 chip (equivalent to ISSI's
-- IS42S16400). Many parameters are still hardcoded (see below) including the
-- number of banks.
--------------------------------------------------------------------------------
-- To Be Done:
-- 1) CL and BL are hardcoded, generics are ignored.
-- 2) Column width is partially hardcoded (see 'column' signal).
-- 3) Auto-refresh logic is missing.
-- 4) No. of banks is hardcoded to 4.
--
--------------------------------------------------------------------------------
-- Copyright (C) 2011 Jose A. Ruiz
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
use ieee.std_logic_unsigned.all;


package sdram_pkg is

-- Record with all SDRAM control lines; all are outputs, data lines are excluded
type sdram_control_t is 
record
    addr            : std_logic_vector(11 downto 0);
    ba              : std_logic_vector(1 downto 0);
    ldqm            : std_logic;
    udqm            : std_logic;
    ras_n           : std_logic;
    cas_n           : std_logic;
    cke             : std_logic;
    we_n            : std_logic;
    cs_n            : std_logic;
end record sdram_control_t;

type sdram_command_t is (
    cmd_inhibit,
    cmd_nop,
    cmd_active,
    cmd_read,
    cmd_reada,
    cmd_write,
    cmd_writea,
    cmd_burst_terminate,
    cmd_precharge,
    cmd_auto_refresh,
    cmd_self_refresh,
    cmd_load_mode_register
   );


end package sdram_pkg;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.sdram_pkg.all;


entity sdram_controller is
    generic (
        CLOCK_PERIOD    : integer := 20; -- Tclk in ns; for reset delay counters
        LATENCY         : integer := 2; -- CAS latency in clock cycles
        BURST           : integer := 8; -- Rd Burst Length in clock cycles
        
        ROW_WIDTH       : integer := 12;
        COL_WIDTH       : integer := 8
    );
    port (
    clk                 : in std_logic;
    reset               : in std_logic;
    
    -- ***** Cache interface
    data_rd             : out std_logic_vector(31 downto 0);
    data_wr             : in std_logic_vector(31 downto 0);
    data_addr           : in std_logic_vector(31 downto 2);
    enable              : in std_logic;
    byte_we             : in std_logic_vector(3 downto 0);
    rd                  : in std_logic;
    wr                  : in std_logic;
    busy                : out std_logic;
    done                : out std_logic;
    rd_data_valid       : out std_logic;
    burst_addr          : out std_logic_vector(2 downto 0); --@note1
    
    -- ***** DRAM interface pins (Tristate buffers not included)
    dram_control        : out sdram_control_t;
    dram_clk            : out std_logic;
    dram_dq_out         : out std_logic_vector(15 downto 0);
    dram_dq_in          : in std_logic_vector(15 downto 0)
    );
end sdram_controller;

architecture simple of sdram_controller is

type sdram_state_t is (
    --**** Chip initialization states
    init_reset,             -- initial state
    init_wait_for_clock,    -- waiting for power & clock to stabilize
    init_wait_for_chip,     -- waiting for SDRAM chip to reset
    init_precharge_all,     -- Issue PALL
    init_wait_trp,          -- Wait for command latency
    init_autorefresh,       -- Issue SELF command
    init_wait_trfc_0,       -- Wait for command latency
    init_wait_trfc_1,       -- Wait for command latency
    init_wait_trfc_2,       -- Wait for command latency
    init_wait_trfc_3,       -- Wait for command latency
    init_load_mode_reg,     -- Issue LMR command
    init_wait_tmrd_0,       -- Wait for command latency
    init_wait_tmrd_1,       -- Wait for command latency
    init_wait_tmrd_2,       -- Wait for command latency
    
    --**** States for write operation *******************************
    
    -- Activate target row
    write_00_act,           -- Issue ACT command
    write_01_act_wait,      -- Wait for command latency
    write_02_act_wait,      -- Wait for command latency
    
    -- Actual write cycles
    write_03_whi,           -- Write high halfword
    write_04_wlo,           -- Write low halfword, with autoprecharge

    write_05_pre_wait,      -- Wait for autoprecharge delay (tRP)
    write_06_pre_wait,      -- 
    write_07_pre_wait,      -- 
    
    idle,                   -- Waiting for r/w request
    
    --**** states for read operation ********************************
    
    -- Activate target row
    read_00_act,            -- Issue ACT command
    read_01_act_wait,       -- Wait for command latency
    read_02_act_wait,       -- Wait for command latency
    
    -- Read burst
    read_03_rd,             -- Issue READ command with autoprecharge
    read_04_rd_wait,        -- Wait for command latency
    read_05_rd_wait,        -- Wait for command latency
    read_06_rd_w0hi,        -- On bus: Word 0, HI
    read_07_rd_w0lo,        -- On bus: Word 0, LO
    read_08_rd_w1hi,        -- On bus: Word 1, HI
    read_09_rd_w1lo,        -- On bus: Word 1, LO
    read_10_rd_w2hi,        -- On bus: Word 2, HI
    read_11_rd_w2lo,        -- On bus: Word 2, LO
    read_12_rd_w3hi,        -- On bus: Word 3, HI
    read_13_rd_w3lo,        -- On bus: Word 3, LO
    
    void
   );


signal ps, ns :             sdram_state_t;
signal ctr_pause :          integer range 0 to 16383;
signal end_pause :          std_logic;

signal ddr_command :        sdram_command_t;
signal command_code :       std_logic_vector(3 downto 0);


signal end_autorefresh_loop : std_logic;
signal ctr_auto_refresh :   integer range 0 to 15;

signal byte_we_reg :        std_logic_vector(3 downto 0); --
signal data_wr_reg :        std_logic_vector(31 downto 0); --
signal data_rd_reg :        std_logic_vector(31 downto 0);
signal addr_reg :           std_logic_vector(31 downto 2);
signal load_hw_hi :         std_logic;
signal load_hw_lo :         std_logic;

signal row :                std_logic_vector(11 downto 0);
signal column :             std_logic_vector(9 downto 0);
signal bank :               std_logic_vector(1 downto 0);
signal halfword_addr :      std_logic;

begin

state_machine_reg:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            ps <= init_reset;
        else
            ps <= ns;
        end if;
    end if;
end process state_machine_reg;

state_machine_transitions:
process(ps,end_pause,end_autorefresh_loop, rd, byte_we, enable)
begin
    case ps is
    when init_reset =>
        ns <= init_wait_for_clock;
    when init_wait_for_clock =>
        if end_pause='1' then 
            ns <= init_wait_for_chip;
        else
            ns <= ps;
        end if;
    when init_wait_for_chip =>
        if end_pause='1' then 
            ns <= init_precharge_all;
        else
            ns <= ps;
        end if;
    
    when init_precharge_all =>
        ns <= init_wait_trp;
    when init_wait_trp =>
        ns <= init_autorefresh;
    when init_autorefresh => 
        ns <= init_wait_trfc_0;
    when init_wait_trfc_0 =>
        ns <= init_wait_trfc_1;
    when init_wait_trfc_1 =>
        ns <= init_wait_trfc_2;
    when init_wait_trfc_2 =>
        ns <= init_wait_trfc_3;
    when init_wait_trfc_3 =>
        ns <= init_load_mode_reg;
    when init_load_mode_reg =>
        ns <= init_wait_tmrd_0;
    when init_wait_tmrd_0 =>
        ns <= init_wait_tmrd_1;
    when init_wait_tmrd_1 =>
        ns <= init_wait_tmrd_2;
    when init_wait_tmrd_2 =>
        ns <= idle;
    
    
    when idle =>
        if rd='1' then
            ns <= read_00_act;
        elsif wr='1' then
            ns <= write_00_act;
        else
            ns <= ps;
        end if;
    
    when write_00_act =>
        ns <= write_01_act_wait;
    when write_01_act_wait =>
        ns <= write_02_act_wait;
    when write_02_act_wait =>
        ns <= write_03_whi;
    when write_03_whi =>
        ns <= write_04_wlo;
    when write_04_wlo =>
        ns <= write_05_pre_wait;
    when write_05_pre_wait =>
        ns <= write_06_pre_wait;
    when write_06_pre_wait =>
        ns <= write_07_pre_wait;
    when write_07_pre_wait =>
        ns <= idle;
    
    when read_00_act =>
        ns <= read_01_act_wait;
    when read_01_act_wait =>
        ns <= read_02_act_wait;
    when read_02_act_wait =>
        ns <= read_03_rd;
    when read_03_rd =>
        ns <= read_04_rd_wait;
    when read_04_rd_wait => -- FIXME RD burst latency hardcoded
        --ns <= read_05_rd_wait;
        ns <= read_06_rd_w0hi;
    when read_05_rd_wait =>
        ns <= read_06_rd_w0hi;
    when read_06_rd_w0hi =>
        ns <= read_07_rd_w0lo;
    when read_07_rd_w0lo =>
        ns <= read_08_rd_w1hi;
    when read_08_rd_w1hi =>
        ns <= read_09_rd_w1lo;
    when read_09_rd_w1lo =>
        ns <= read_10_rd_w2hi;
    when read_10_rd_w2hi =>
        ns <= read_11_rd_w2lo;
    when read_11_rd_w2lo =>
        ns <= read_12_rd_w3hi;
    when read_12_rd_w3hi =>
        ns <= read_13_rd_w3lo;
    when read_13_rd_w3lo =>
        ns <= idle;

    when void =>
        ns <= void;

    when others =>
        ns <= init_reset;
    end case;
end process state_machine_transitions;


with ps select ddr_command <= 
    cmd_precharge           when init_precharge_all,
    cmd_auto_refresh        when init_autorefresh,
    cmd_load_mode_register  when init_load_mode_reg,
    
    cmd_active              when read_00_act,
    cmd_active              when write_00_act,
    cmd_write               when write_03_whi,
    cmd_writea              when write_04_wlo,
    cmd_reada               when read_03_rd,

    cmd_nop                 when others;

-- assert 'busy' when the controller is idle
with ps select busy <=
    '0' when idle,
    '1' when others;

-- assert 'done' for 1 cycle when current operation ends, before clearing 'busy'
with ps select done <=
    '1' when init_wait_tmrd_2,
    '1' when read_13_rd_w3lo,
    '1' when write_07_pre_wait,
    '0' when others;

--%%%%% Counters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pause_counter:
process(clk)
begin
    if clk'event and clk='1' then
        if ps=init_reset then
            ctr_pause <= 20000 / CLOCK_PERIOD; -- 20 us -- clock & vcc stable
        elsif ps=init_wait_for_clock then
            if ctr_pause/=0 then
                ctr_pause <= ctr_pause - 1;
            else
                ctr_pause <= 1000 / CLOCK_PERIOD; -- 1 us -- chip reset
            end if;
        elsif ps=init_wait_for_chip then
            if ctr_pause/=0 then
                ctr_pause <= ctr_pause - 1;
            end if;
        end if;
    end if;
end process pause_counter;

end_pause <= '1' when ctr_pause=0 else '0';

-- FIXME auto-refresh control logic missing

--init_auto_refresh_counter:
--process(clk)
--begin
--    if clk'event and clk='1' then
--        if ps=init_reset then
--            ctr_auto_refresh <= 10;
--        else
--            if ps=init_wait_trfc_3 and ctr_auto_refresh /= 0 then
--                ctr_auto_refresh <= ctr_auto_refresh - 1;
--            end if;
--        end if;
--    end if;
--end process init_auto_refresh_counter;
--
--end_autorefresh_loop <= '1' when ctr_auto_refresh = 0 else '0';


--%%%%% Interface registers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cpu_interface_registers:
process(clk)
begin
    if clk'event and clk='1' then
        if ps=idle then
            if rd='1' or byte_we/="0000" then
                data_wr_reg <= data_wr;
                addr_reg <= data_addr;
                byte_we_reg <= byte_we;
            end if;
        end if;
    end if;
end process cpu_interface_registers;



halfword_addr <= '1' when ps=write_04_wlo else '0';
-- FIXME zero-padding is not parametrized
column  <= "00" & addr_reg(COL_WIDTH downto 2) & halfword_addr;

row     <= addr_reg(COL_WIDTH+ROW_WIDTH downto COL_WIDTH+1); 
bank    <= addr_reg(COL_WIDTH+ROW_WIDTH+2 downto COL_WIDTH+ROW_WIDTH+1); 

--%%%%% Control lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

with ddr_command select command_code <=
    "1111"          when cmd_inhibit,
    "0111"          when cmd_nop,
    "0011"          when cmd_active,
    "0101"          when cmd_read,
    "0101"          when cmd_reada,
    "0100"          when cmd_write,
    "0100"          when cmd_writea,
    "0110"          when cmd_burst_terminate,
    "0010"          when cmd_precharge,
    "0001"          when cmd_self_refresh,
    "0001"          when cmd_auto_refresh,
    "0000"          when cmd_load_mode_register,
    "1111"          when others;

dram_control.cs_n   <= command_code(3);
dram_control.ras_n  <= command_code(2);
dram_control.cas_n  <= command_code(1);
dram_control.we_n   <= command_code(0);

with ps select dram_control.cke <=
    '0'             when init_reset,
    '1'             when others;

-- FIXME hardcoded BL and CL
with ps select dram_control.addr <= 
--   OOAOOLLLTBBB
    "001000100011"  when init_load_mode_reg, -- CL = 2, BL = 8
    "010000000000"  when init_precharge_all, -- A10=1 => Precharge ALL banks
    row             when read_00_act,
    row             when write_00_act,
    "00" & column   when write_03_whi,
    "01" & column   when write_04_wlo,
    "00" & column   when read_03_rd,
    "010000000000"  when others; 

dram_control.ba <= bank;
dram_clk <= clk;

-- DQM[0] is '1' when the byte is NOT to be written to
with ps select dram_control.ldqm <= 
    not byte_we_reg(2)  when write_03_whi,
    not byte_we_reg(0)  when write_04_wlo,
    '0'                 when others;

-- DQM[1] is '1' when the byte is NOT to be written to
with ps select dram_control.udqm <= 
    not byte_we_reg(3)  when write_03_whi,
    not byte_we_reg(1)  when write_04_wlo,
    '0'                 when others;

with ps select dram_dq_out <= 
    data_wr_reg(31 downto 16)  when write_03_whi,
    data_wr_reg(15 downto  0)  when others;

data_rd <= data_rd_reg;

with ps select load_hw_hi <= 
    '1' when read_06_rd_w0hi,
    '1' when read_08_rd_w1hi,
    '1' when read_10_rd_w2hi,
    '1' when read_12_rd_w3hi,
    '0' when others;
    
with ps select load_hw_lo <= 
    '1' when read_07_rd_w0lo,
    '1' when read_09_rd_w1lo,
    '1' when read_11_rd_w2lo,
    '1' when read_13_rd_w3lo,
    '0' when others;

data_valid_ff:
process(clk)
begin
    if clk'event and clk='1' then
        -- NOTE: no need to reset this FF, will always be valid when read
        rd_data_valid <= load_hw_lo; 
    end if;
end process data_valid_ff;

-- Data RD register is split in two 16-bit halves which are loaded separately
data_read_register:
process(clk)
begin
    if clk'event and clk='1' then
        if load_hw_hi='1' then
            data_rd_reg(31 downto 16) <= dram_dq_in;
        end if;
        if load_hw_lo='1' then
            data_rd_reg(15 downto  0) <= dram_dq_in;
        end if;
    end if;
end process data_read_register;


end simple;
