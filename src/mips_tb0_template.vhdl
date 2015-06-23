--##############################################################################
-- This file was generated automatically from '/src/mips_tb0_template.vhdl'.
-- 
--------------------------------------------------------------------------------
-- Simulation test bench TB0 -- not synthesizable.
--
-- Simulates the CPU core connected to a single memory block initialized with
-- the program object code and (initialized) data. The makefile for the source 
-- samples include targets to build simulation test benches using this template.
--
-- The memory setup is meant to test the 'bare' cpu, without cache and with 
-- all object code in a single 3-port memory block. 
-- Address decoding is harcoded to that of Plasma system, for the time being.
-- 
-- Console output (at addresses compatible to Plasma's) is logged to text file
-- "hw_sim_console_log.txt".
-- IMPORTANT: The code that echoes UART TX data to the simulation console does
-- line buffering; it will not print anything until it gets a CR (0x0d), and
-- will ifnore LFs (0x0a). Bear this in mind if you see no output when you 
-- expect it.
--
-- WARNING: Will only work on Modelsim; uses custom library SignalSpy.
--##############################################################################
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
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

use work.mips_pkg.all;
use work.mips_tb_pkg.all;
use work.txt_util.all;


entity @entity_name@ is
end @entity_name@;

architecture @arch_name@ of @entity_name@ is

--------------------------------------------------------------------------------
-- Simulation parameters

-- Master clock period
constant T : time           := 20 ns;
-- Time the UART is unavailable after writing to the TX register
-- WARNING: slite does not simulate this. The logs may be different when > 0.0!
constant SIMULATED_UART_TX_TIME : time := 0.0 us;

-- Simulation length in clock cycles 
-- 2000 is enough for 'hello' sample, 22000 enough for 10 digits of pi
constant SIMULATION_LENGTH : integer := @sim_len@;

               
--------------------------------------------------------------------------------
-- UUT & interface signals

signal data_addr :          std_logic_vector(31 downto 0);
signal prev_rd_addr :       std_logic_vector(31 downto 0);
signal vma_data :           std_logic;
signal vma_code :           std_logic;
signal full_rd_addr :       std_logic_vector(31 downto 0);
signal full_wr_addr :       std_logic_vector(31 downto 0);
signal byte_we :            std_logic_vector(3 downto 0);
signal data_r :             std_logic_vector(31 downto 0);
signal data_ram :           std_logic_vector(31 downto 0);
signal data_uart :          std_logic_vector(31 downto 0);
signal data_uart_status :   std_logic_vector(31 downto 0);
signal uart_tx_rdy :        std_logic := '1';
signal uart_rx_rdy :        std_logic := '1';
signal data_w :             std_logic_vector(31 downto 0);
signal mem_wait :           std_logic := '0';
signal interrupt :          std_logic := '0';
signal code_addr :          std_logic_vector(31 downto 2);
signal full_code_addr :     std_logic_vector(31 downto 0);
signal code_r :             std_logic_vector(31 downto 0);

--------------------------------------------------------------------------------

signal clk :                std_logic := '0';
signal reset :              std_logic := '1';
signal done :               std_logic := '0';
signal test :               integer := 0;

--------------------------------------------------------------------------------
-- Logging signals

-- These are internal CPU signal mirrored using Modelsim's SignalSpy
--signal rbank :              t_rbank;
--signal pc, cp0_epc :        std_logic_vector(31 downto 2);
--signal reg_hi, reg_lo :     t_word;
--signal negate_reg_lo :      std_logic;
--signal ld_upper_byte :      std_logic;
--signal ld_upper_hword :     std_logic;
  
signal log_info :           t_log_info;  
  
-- Log file
file log_file: TEXT open write_mode is "hw_sim_log.txt";

-- Console output log file
file con_file: TEXT open write_mode is "hw_sim_console_log.txt";

-- Maximum line size of for console output log. Lines longer than this will be
-- truncated.
constant CONSOLE_LOG_LINE_SIZE : integer := 1024*4;

-- Console log line buffer
signal con_line_buf :       string(1 to CONSOLE_LOG_LINE_SIZE);
signal con_line_ix :        integer := 1;


--------------------------------------------------------------------------------

constant MEM_SIZE : integer := @code_table_size@;
constant ADDR_SIZE : integer := @code_addr_size@;

subtype t_address is std_logic_vector(ADDR_SIZE-1 downto 0);

signal addr_rd, addr_wr :   t_address;
signal addr_code :          t_address;

type t_code_ram is array(0 to MEM_SIZE-1) of std_logic_vector(7 downto 0);

subtype t_data_address is std_logic_vector(ADDR_SIZE-1 downto 0);
signal data_addr_rd :       t_data_address; 
signal data_addr_wr :       t_data_address;
signal code_addr_rd :       t_data_address;


-- ram0 is LSB, ram3 is MSB
signal ram3 : t_code_ram := (@code3@);
signal ram2 : t_code_ram := (@code2@);
signal ram1 : t_code_ram := (@code1@);
signal ram0 : t_code_ram := (@code0@);

begin

    cpu: entity work.mips_cpu
    port map (
        interrupt   => interrupt,
        
        data_addr   => data_addr,
        data_rd_vma => vma_data,
        data_rd     => data_r,
        
        code_rd_addr=> code_addr,
        code_rd     => code_r,
        code_rd_vma => vma_code,
        
        data_wr     => data_w,
        byte_we     => byte_we,

        mem_wait    => mem_wait,
        
        clk         => clk,
        reset       => reset
    );

    ---------------------------------------------------------------------------
    -- Master clock: free running clock used as main module clock
    run_master_clock:
    process(done, clk)
    begin
        if done = '0' then
            clk <= not clk after T/2;
        end if;
    end process run_master_clock;

    drive_uut:
    process
    variable l : line;
    begin
        wait for T*4;
        reset <= '0';
        
        wait for T*SIMULATION_LENGTH;

        -- Flush console output to log console file (in case the end of the
        -- simulation caugh an unterminated line in the buffer)
        if con_line_ix > 1 then
            write(l, con_line_buf(1 to con_line_ix));
            writeline(con_file, l);
        end if;

        print("TB0 finished");
        done <= '1';
        wait;
        
    end process drive_uut;
    
    mem_wait <= '0'; -- memory wait input not simulated in this test bench
    

    -- RAM vs. IO data read mux
    data_r <= data_ram when prev_rd_addr(31 downto 28)/=X"2" else data_uart;
    
    -- UART read registers; only status, and hardwired, for the time being
    data_uart <= data_uart_status;
    data_uart_status <= X"0000000" & "00" & uart_tx_rdy & uart_rx_rdy;


    -- 'full' read address, used for simulation display only
    full_rd_addr <= data_addr;
    full_wr_addr <= data_addr(31 downto 2) & "00";
    full_code_addr <= code_addr & "00";

    data_addr_rd <= full_rd_addr(ADDR_SIZE-1+2 downto 2);
    addr_wr <= full_wr_addr(ADDR_SIZE-1+2 downto 2);
    code_addr_rd <= full_code_addr(ADDR_SIZE-1+2 downto 2);


    write_process:
    process(clk)
    variable i : integer;
    variable uart_data : integer;
    begin
        if clk'event and clk='1' then
            if reset='1' then
                data_ram <= (others =>'0');
            else
                prev_rd_addr <= data_addr;
                
                data_ram <= 
                  ram3(conv_integer(unsigned(data_addr_rd))) &
                  ram2(conv_integer(unsigned(data_addr_rd))) &
                  ram1(conv_integer(unsigned(data_addr_rd))) &
                  ram0(conv_integer(unsigned(data_addr_rd)));
                  
                code_r <= 
                  ram3(conv_integer(unsigned(code_addr_rd))) &
                  ram2(conv_integer(unsigned(code_addr_rd))) &
                  ram1(conv_integer(unsigned(code_addr_rd))) &
                  ram0(conv_integer(unsigned(code_addr_rd)));
            end if;
            
            if byte_we/="0000" then
                if full_wr_addr(31 downto 28)=X"2" then
                    -- Write to UART
                    
                    -- If we're simulating the UART TX time, pulse RDY low
                    if SIMULATED_UART_TX_TIME > 0 us then
                        uart_tx_rdy <= '0', '1' after SIMULATED_UART_TX_TIME;
                    end if;
                    
                    -- TX data may come from the high or low byte (opcodes.s
                    -- uses high byte, no_op.c uses low)
                    if byte_we(0)='1' then
                        uart_data := conv_integer(unsigned(data_w(7 downto 0)));
                    else
                        uart_data := conv_integer(unsigned(data_w(31 downto 24)));
                    end if;
                    
                    -- UART TX data goes to output after a bit of line-buffering
                    -- and editing
                    if uart_data = 10 then
                        -- CR received: print output string and clear it
                        print(con_file, con_line_buf(1 to con_line_ix));
                        con_line_ix <= 1;
                        for i in 1 to con_line_buf'high loop
                           con_line_buf(i) <= ' ';
                        end loop;
                    elsif uart_data = 13 then
                        -- ignore LF
                    else
                        -- append char to output string
                        if con_line_ix < con_line_buf'high then
                            con_line_buf(con_line_ix) <= character'val(uart_data);
                            con_line_ix <= con_line_ix + 1;
                        end if;
                    end if;
                else
                    -- Write to RAM
                    if byte_we(3)='1' then
                        ram3(conv_integer(unsigned(addr_wr))) <= data_w(31 downto 24);
                    end if;
                    if byte_we(2)='1' then
                        ram2(conv_integer(unsigned(addr_wr))) <= data_w(23 downto 16);
                    end if;
                    if byte_we(1)='1' then
                        ram1(conv_integer(unsigned(addr_wr))) <= data_w(15 downto  8);
                    end if;
                    if byte_we(0)='1' then
                        ram0(conv_integer(unsigned(addr_wr))) <= data_w( 7 downto  0);
                    end if;
                end if;
            end if;
        end if;
    end process write_process;
                  
    log_execution:
    process
    begin
        log_cpu_activity(clk, reset, done, 
                         "@entity_name@/cpu", log_info, "log_info", 
                         @log_trigger_addr@, log_file);
        wait;
    end process log_execution;


end @arch_name@;
