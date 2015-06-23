--##############################################################################
-- WARNING: THIS FILE IS DEPRECATED and will be removed soon.
-- As of revision 193 the test bench used is tb/mips_tb.vhdl.
-- Just ignore this file.
-- 
--------------------------------------------------------------------------------
-- Simulation test bench TB2 -- not synthesizable.
--
-- Simulates the CPU core connected to a simulated external static RAM and an
-- internal BRAM block through a stub (i.e. empty).
-- BRAM is initialized with the program object code, and SRAM is initialized 
-- with data secions from program. 
-- The makefile for the source samples include targets to build simulation test 
-- benches using this template, use them as usage examples.
--
-- The memory setup is meant to test the basic 'dummy' cache. 
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
end;


architecture @arch_name@ of @entity_name@ is

-------------------------------------------------------------------------------
-- Simulation parameters

-- Master clock period
constant T : time           := 20 ns;
-- Time the UART is unavailable after writing to the TX register
-- WARNING: slite does not simulate this. The logs may be different when > 0.0!
constant SIMULATED_UART_TX_TIME : time := 0.0 us;

-- Simulation length in clock cycles, should be long enough (you have to try...)
constant SIMULATION_LENGTH : integer := @sim_len@;

-- Simulated external SRAM size in 32-bit words 
constant SRAM_SIZE : integer := @xram_size@;
-- Ext. SRAM address length (memory is 16 bits wide so it needs an extra address bit)
constant SRAM_ADDR_SIZE : integer := log2(SRAM_SIZE)+1;


-- BRAM table and interface signals --------------------------------------------
constant BRAM_SIZE : integer := @code_table_size@;
constant BRAM_ADDR_SIZE : integer := @code_addr_size@;
subtype t_bram_address is std_logic_vector(BRAM_ADDR_SIZE-1 downto 0);
-- (this table holds one byte-slice; the RAM will have 4 of these)
type t_bram is array(0 to BRAM_SIZE-1) of std_logic_vector(7 downto 0);

signal bram_rd_addr :       t_bram_address; 
signal bram_wr_addr :       t_bram_address;
signal bram_rd_data :       t_word;
signal bram_wr_data :       t_word;
signal bram_byte_we :       std_logic_vector(3 downto 0);
signal bram_data_rd_vma :   std_logic;

-- bram0 is LSB, bram3 is MSB
signal bram3 : t_bram := (@code3@);
signal bram2 : t_bram := (@code2@);
signal bram1 : t_bram := (@code1@);
signal bram0 : t_bram := (@code0@);

-- This is a 16-bit SRAM split in 2 byte slices; so each slice will have two
-- bytes for each word of SRAM_SIZE
type t_sram is array(0 to SRAM_SIZE*2-1) of std_logic_vector(7 downto 0);
signal sram1 : t_sram := (@data31@);
signal sram0 : t_sram := (@data20@);

signal sram_chip_addr :     std_logic_vector(SRAM_ADDR_SIZE downto 1);
signal sram_output :        std_logic_vector(15 downto 0);

-- PROM table and interface signals --------------------------------------------

-- We'll simulate a 16-bit-wide static PROM (e.g. a Flash) with some serious
-- cycle time (70 or 90 ns).

constant PROM_SIZE : integer := @prom_size@;
constant PROM_ADDR_SIZE : integer := log2(PROM_SIZE);

subtype t_prom_address is std_logic_vector(PROM_ADDR_SIZE-1 downto 0);
type t_prom is array(0 to PROM_SIZE-1) of t_word;

signal prom_rd_addr :       t_prom_address; 
signal prom_output :        std_logic_vector(7 downto 0);
signal prom_oe_n :          std_logic;

-- bram0 is LSB, bram3 is MSB
signal prom : t_prom := (@flash@);



-- I/O devices -----------------------------------------------------------------

signal data_uart :          std_logic_vector(31 downto 0);
signal data_uart_status :   std_logic_vector(31 downto 0);
signal uart_tx_rdy :        std_logic := '1';
signal uart_rx_rdy :        std_logic := '1';

--------------------------------------------------------------------------------

signal clk :                std_logic := '0';
signal reset :              std_logic := '1';
signal interrupt :          std_logic := '0';
signal done :               std_logic := '0';

-- interface to asynchronous 16-bit-wide external SRAM
signal sram_address :       std_logic_vector(31 downto 0);
signal sram_data_rd :       std_logic_vector(15 downto 0);
signal sram_data_wr :       std_logic_vector(15 downto 0);
signal sram_byte_we_n :     std_logic_vector(1 downto 0);
signal sram_oe_n :          std_logic;

-- interface cpu-cache
signal cpu_data_addr :      t_word;
signal cpu_data_rd_vma :    std_logic;
signal cpu_data_rd :        t_word;
signal cpu_code_rd_addr :   t_pc;
signal cpu_code_rd :        t_word;
signal cpu_code_rd_vma :    std_logic;
signal cpu_data_wr :        t_word;
signal cpu_byte_we :        std_logic_vector(3 downto 0);
signal cpu_mem_wait :       std_logic;
signal cpu_ic_invalidate :  std_logic;
signal cpu_cache_enable :   std_logic;

-- interface to i/o
signal io_rd_data :         std_logic_vector(31 downto 0);
signal io_wr_data :         std_logic_vector(31 downto 0);
signal io_rd_addr :         std_logic_vector(31 downto 2);
signal io_wr_addr :         std_logic_vector(31 downto 2);
signal io_rd_vma :          std_logic;
signal io_byte_we :         std_logic_vector(3 downto 0);


--------------------------------------------------------------------------------
-- Logging signals


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

signal log_info :           t_log_info;

-- Debug signals ---------------------------------------------------------------


signal full_rd_addr :       std_logic_vector(31 downto 0);
signal full_wr_addr :       std_logic_vector(31 downto 0);
signal full_code_addr :     std_logic_vector(31 downto 0);


begin

    cpu: entity work.mips_cpu
    port map (
        interrupt   => '0',
        
        data_addr   => cpu_data_addr,
        data_rd_vma => cpu_data_rd_vma,
        data_rd     => cpu_data_rd,
        
        code_rd_addr=> cpu_code_rd_addr,
        code_rd     => cpu_code_rd,
        code_rd_vma => cpu_code_rd_vma,
        
        data_wr     => cpu_data_wr,
        byte_we     => cpu_byte_we,

        mem_wait    => cpu_mem_wait,
        cache_enable=> cpu_cache_enable,
        ic_invalidate=>cpu_ic_invalidate,
        
        clk         => clk,
        reset       => reset
    );


    cache: entity work.mips_cache
    generic map (
        BRAM_ADDR_SIZE => BRAM_ADDR_SIZE,
        SRAM_ADDR_SIZE => 32,-- we need the full address to decode sram vs flash
        LINE_SIZE =>      4,
        CACHE_SIZE =>     256
    )
    port map (
        clk             => clk,
        reset           => reset,
        
        -- Interface to CPU core
        data_addr       => cpu_data_addr,
        data_rd         => cpu_data_rd,
        data_rd_vma     => cpu_data_rd_vma,
                        
        code_rd_addr    => cpu_code_rd_addr,
        code_rd         => cpu_code_rd,
        code_rd_vma     => cpu_code_rd_vma,

        byte_we         => cpu_byte_we,
        data_wr         => cpu_data_wr,
                        
        mem_wait        => cpu_mem_wait,
        cache_enable    => cpu_cache_enable,
        ic_invalidate   => cpu_ic_invalidate,
        unmapped        => OPEN,
        
        -- interface to FPGA i/o devices
        io_rd_data      => io_rd_data,
        io_wr_data      => io_wr_data,
        io_rd_addr      => io_rd_addr,
        io_wr_addr      => io_wr_addr,
        io_rd_vma       => io_rd_vma,
        io_byte_we      => io_byte_we,

        -- interface to synchronous 32-bit-wide FPGA BRAM
        bram_rd_data    => bram_rd_data,
        bram_wr_data    => bram_wr_data,
        bram_rd_addr    => bram_rd_addr,
        bram_wr_addr    => bram_wr_addr,
        bram_byte_we    => bram_byte_we,
        bram_data_rd_vma=> bram_data_rd_vma,
        
        -- interface to asynchronous 16-bit-wide external SRAM
        sram_address    => sram_address,
        sram_data_rd    => sram_data_rd,
        sram_data_wr    => sram_data_wr,
        sram_byte_we_n  => sram_byte_we_n,
        sram_oe_n       => sram_oe_n
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

    full_rd_addr <= cpu_data_addr;
    full_wr_addr <= cpu_data_addr(31 downto 2) & "00";
    full_code_addr <= cpu_code_rd_addr & "00";

    data_ram_block:
    process(clk)
    begin
        if clk'event and clk='1' then
            if reset='0' then
                bram_rd_data <= 
                    bram3(conv_integer(unsigned(bram_rd_addr))) &
                    bram2(conv_integer(unsigned(bram_rd_addr))) &
                    bram1(conv_integer(unsigned(bram_rd_addr))) &
                    bram0(conv_integer(unsigned(bram_rd_addr)));
                
                if bram_byte_we(3)='1' then
                    bram3(conv_integer(unsigned(bram_wr_addr))) <= cpu_data_wr(31 downto 24);
                end if;
                if bram_byte_we(2)='1' then
                    bram2(conv_integer(unsigned(bram_wr_addr))) <= cpu_data_wr(23 downto 16);
                end if;
                if bram_byte_we(1)='1' then
                    bram1(conv_integer(unsigned(bram_wr_addr))) <= cpu_data_wr(15 downto  8);
                end if;
                if bram_byte_we(0)='1' then
                    bram0(conv_integer(unsigned(bram_wr_addr))) <= cpu_data_wr( 7 downto  0);
                end if;
            end if;
        end if;
    end process data_ram_block;

    sram_data_rd <= 
        X"00" & prom_output when sram_address(31 downto 27)="10110" else
        sram_output;
            


    -- Do a very basic simulation of an external SRAM ---------------

    sram_chip_addr <= sram_address(SRAM_ADDR_SIZE downto 1);

    -- FIXME should add some verification of /WE 
    sram_output <=
        sram1(conv_integer(unsigned(sram_chip_addr))) &
        sram0(conv_integer(unsigned(sram_chip_addr)))   when sram_oe_n='0'
        else (others => 'Z');

    simulated_sram_write:
    process(sram_byte_we_n, sram_address, sram_oe_n)
    begin
        -- Write cycle
        -- FIXME should add OE\ to write control logic
        if sram_byte_we_n'event or sram_address'event then
            if sram_byte_we_n(1)='0' then
                sram1(conv_integer(unsigned(sram_chip_addr))) <= sram_data_wr(15 downto  8);
            end if;
            if sram_byte_we_n(0)='0' then
                sram0(conv_integer(unsigned(sram_chip_addr))) <= sram_data_wr( 7 downto  0);
            end if;            
        end if;
    end process simulated_sram_write;


    -- Do a very basic simulation of an external PROM wired to the same bus 
    -- as the sram (both are static).
    
    prom_rd_addr <= sram_address(PROM_ADDR_SIZE+1 downto 2);
    
    prom_oe_n <= sram_oe_n;
    
    prom_output <=
        prom(conv_integer(unsigned(prom_rd_addr)))(31 downto 24) when prom_oe_n='0' and sram_address(1 downto 0)="00" else
        prom(conv_integer(unsigned(prom_rd_addr)))(23 downto 16) when prom_oe_n='0' and sram_address(1 downto 0)="01" else
        prom(conv_integer(unsigned(prom_rd_addr)))(15 downto  8) when prom_oe_n='0' and sram_address(1 downto 0)="10" else
        prom(conv_integer(unsigned(prom_rd_addr)))( 7 downto  0) when prom_oe_n='0' and sram_address(1 downto 0)="11" else
        (others => 'Z');
    
    
    simulated_io:
    process(clk)
    variable i : integer;
    variable uart_data : integer;
    begin
        if clk'event and clk='1' then
            
            if io_byte_we/="0000" then
                if io_wr_addr(31 downto 28)=X"2" then
                    -- Write to UART
                    
                    -- If we're simulating the UART TX time, pulse RDY low
                    if SIMULATED_UART_TX_TIME > 0 us then
                        uart_tx_rdy <= '0', '1' after SIMULATED_UART_TX_TIME;
                    end if;
                    
                    -- TX data may come from the high or low byte (opcodes.s
                    -- uses high byte, no_op.c uses low)
                    if io_byte_we(0)='1' then
                        uart_data := conv_integer(unsigned(io_wr_data(7 downto 0)));
                    else
                        uart_data := conv_integer(unsigned(io_wr_data(31 downto 24)));
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
                end if;
            end if;
        end if;
    end process simulated_io;

    -- UART read registers; only status, and hardwired, for the time being
    io_rd_data <= X"00000003";
    data_uart <= data_uart_status;
    data_uart_status <= X"0000000" & "00" & uart_tx_rdy & uart_rx_rdy;

    log_execution:
    process
    begin
        log_cpu_activity(clk, reset, done, 
                         "@entity_name@/cpu", log_info, "log_info", 
                         @log_trigger_addr@, log_file);
        wait;
    end process log_execution;

    
end architecture @arch_name@;
