--------------------------------------------------------------------------------
-- Synthesizable ION SoC -- CPU + cache + bootstrap ROM (BRAM) + UART
--------------------------------------------------------------------------------
-- This SoC is meant as a vehicle for building demos around the ION CPU, and not
-- really as an useable SoC. 
--------------------------------------------------------------------------------
--
-- This SoC includes a small BRAM block mapped at 0xbfc00000 and used to hold
-- the application's bootstrap code.
-- The bootstrap object code is passed as a generic in the form of a byte array
-- (type t_obj_code, defined in mips_pkg). This byte array can be generated with
-- script 'build_pkg.py', included in the tools directory. 
-- In the present implementation, the boot BRAM can't be omitted even if the 
-- memory map is changed or its size is set to zero.
--
--------------------------------------------------------------------------------
-- Generics
------------
--
-- BOOT_BRAM_SIZE:  Size of boot BRAM in 32-bit words. Can't be zero.
-- OBJECT_CODE:     Bootstrap object code (mapped at 0xbfc00000).
-- SRAM_ADDR_SIZE:  Size of address bus for SRAM interface.
-- CLOCK_FREQ:      Clock rate in Hz. Used for the UART configuration.
-- BAUD_RATE:       UART baud rate.
--
--------------------------------------------------------------------------------
-- Memory map
--------------
--
-- The memory map used in this SoC is defined in package mips_pkg, in function 
-- decode_addr_mips1. It is used in the module 'mips_cache.vhdl', where 
-- the I- and D-Caches are implemented along with the memory controller -- see
-- the project doc.
-- This map has been chosen for development convenience and includes all the 
-- external memory types available in the development target, Terasic's DE-1 
-- board. It is meant to change as development progresses.
--
-- A[31..27]
-- 00000    => Static, 16-bit (SRAM)
-- 10000    => Static, 16-bit (SRAM)
-- 00100    => I/O
-- 10110    => Static, 8-bit (flash)
-- 10111    => Internal BRAM (boot BRAM)
--
-- I/O devices
---------------
--
-- The only I/O device in this SoC is an UART (module 'uart.vhdl':
--
-- 2XXX0XXX0h => UART register 0
-- 2XXX0XXX4h => UART register 1
-- 2XXX0XXX8h => UART register 2
-- 2XXX0XXXch => UART register 3
--
-- The UART is hardwired to a fixed baud rate and can be configured through
-- generics.
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.mips_pkg.all;

entity mips_soc is
    generic (
        CLOCK_FREQ :        integer := 50000000;
        BAUD_RATE :         integer := 19200;
        BOOT_BRAM_SIZE :    integer := 1024;
        -- FIXME Boot BRAM can't be omitted
        OBJECT_CODE :       t_obj_code := default_object_code;
        SRAM_ADDR_SIZE :    integer := 17           -- < 10 to disable SRAM I/F
        -- FIXME SRAM I/F can't be disabled
    );
    port(
        clk             : in std_logic;
        reset           : in std_logic;
        interrupt       : in std_logic_vector(7 downto 0);
        
        -- interface to FPGA i/o devices
        io_rd_data      : in std_logic_vector(31 downto 0);
        io_rd_addr      : out std_logic_vector(31 downto 2);
        io_wr_addr      : out std_logic_vector(31 downto 2);
        io_wr_data      : out std_logic_vector(31 downto 0);
        io_rd_vma       : out std_logic;
        io_byte_we      : out std_logic_vector(3 downto 0);
        
        -- interface to asynchronous 16-bit-wide EXTERNAL SRAM
        sram_address    : out std_logic_vector(SRAM_ADDR_SIZE-1 downto 0);
        sram_data_wr    : out std_logic_vector(15 downto 0);
        sram_data_rd    : in std_logic_vector(15 downto 0);
        sram_byte_we_n  : out std_logic_vector(1 downto 0);
        sram_oe_n       : out std_logic;

        -- UART 
        uart_rxd        : in std_logic;
        uart_txd        : out std_logic;
        
        -- I/O ports
        p0_out          : out std_logic_vector(31 downto 0);
        p1_in           : in std_logic_vector(31 downto 0);
        
        -- Debug info register output
        debug_info      : out t_debug_info
    );
end; --entity mips_soc

architecture rtl of mips_soc is

-- Interface cpu-cache
signal cpu_data_addr :      t_word;
signal cpu_data_rd_vma :    std_logic;
signal cpu_data_rd :        t_word;
signal cpu_code_rd_addr :   t_pc;
signal cpu_code_rd :        t_word;
signal cpu_code_rd_vma :    std_logic;
signal cpu_data_wr :        t_word;
signal cpu_byte_we :        std_logic_vector(3 downto 0);
signal cpu_mem_wait :       std_logic;
signal cpu_cache_ready :    std_logic;
signal cpu_ic_invalidate :  std_logic;
signal cpu_cache_enable :   std_logic;
signal unmapped_access :    std_logic;

-- Interface to i/o
signal mpu_io_rd_data :     std_logic_vector(31 downto 0);
signal mpu_io_wr_data :     std_logic_vector(31 downto 0);
signal mpu_io_rd_addr :     std_logic_vector(31 downto 2);
signal mpu_io_wr_addr :     std_logic_vector(31 downto 2);
signal mpu_io_rd_vma :      std_logic;
signal mpu_io_byte_we :     std_logic_vector(3 downto 0);

-- Interface to UARTs
signal uart_ce :            std_logic;
signal uart_irq :           std_logic;
signal uart_rd_byte :       std_logic_vector(7 downto 0);

-- I/O registers
signal p0_reg :             std_logic_vector(31 downto 0);
signal p1_reg :             std_logic_vector(31 downto 0);
signal gpio_rd_data :       std_logic_vector(31 downto 0);

-- Bootstrap code BRAM
constant BOOT_BRAM_ADDR_SIZE : integer := log2(BOOT_BRAM_SIZE);
subtype t_boot_bram_address is std_logic_vector(BOOT_BRAM_ADDR_SIZE-1 downto 0);
-- Boot BRAM, initialized with constant object code table
signal boot_bram :          t_word_table(0 to BOOT_BRAM_SIZE-1) := 
                                objcode_to_wtable(OBJECT_CODE, BOOT_BRAM_SIZE);

-- NOTE: 'write' signals are a remnant from a previous version, to be removed
signal bram_rd_addr :       t_boot_bram_address; 
signal bram_wr_addr :       t_boot_bram_address;
signal bram_rd_data :       t_word;
signal bram_wr_data :       t_word;
signal bram_byte_we :       std_logic_vector(3 downto 0);
                                    
                                    
--------------------------------------------------------------------------------
begin

cpu: entity work.mips_cpu
    port map (
        interrupt   => interrupt,
        
        data_addr   => cpu_data_addr,
        data_rd_vma => cpu_data_rd_vma,
        data_rd     => cpu_data_rd,
        
        code_rd_addr=> cpu_code_rd_addr,
        code_rd     => cpu_code_rd,
        code_rd_vma => cpu_code_rd_vma,
        
        data_wr     => cpu_data_wr,
        byte_we     => cpu_byte_we,
    
        mem_wait    => cpu_mem_wait,
        cache_ready => cpu_cache_ready,
        cache_enable=> cpu_cache_enable,
        ic_invalidate=>cpu_ic_invalidate,
        
        clk         => clk,
        reset       => reset
    );

cache: entity work.mips_cache
    generic map (
        BRAM_ADDR_SIZE => BOOT_BRAM_ADDR_SIZE,
        SRAM_ADDR_SIZE => SRAM_ADDR_SIZE
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
        cache_ready     => cpu_cache_ready,
        cache_enable    => cpu_cache_enable,
        ic_invalidate   => cpu_ic_invalidate,
        unmapped        => unmapped_access,
        
        -- interface to FPGA i/o devices
        io_rd_data      => mpu_io_rd_data,
        io_wr_data      => mpu_io_wr_data,
        io_rd_addr      => mpu_io_rd_addr,
        io_wr_addr      => mpu_io_wr_addr,
        io_rd_vma       => mpu_io_rd_vma,
        io_byte_we      => mpu_io_byte_we,
    
        -- interface to synchronous 32-bit-wide FPGA BRAM
        bram_rd_data    => bram_rd_data,
        bram_wr_data    => bram_wr_data,
        bram_rd_addr    => bram_rd_addr,
        bram_wr_addr    => bram_wr_addr,
        bram_byte_we    => bram_byte_we,
        
        -- interface to asynchronous 16-bit-wide external SRAM
        sram_address    => sram_address,
        sram_data_rd    => sram_data_rd,
        sram_data_wr    => sram_data_wr,
        sram_byte_we_n  => sram_byte_we_n,
        sram_oe_n       => sram_oe_n
    );


--------------------------------------------------------------------------------
-- BRAM interface -- read only 

fpga_ram_block:
process(clk)
begin
    if clk'event and clk='1' then
        bram_rd_data <= boot_bram(conv_integer(unsigned(bram_rd_addr)));
    end if;
end process fpga_ram_block;


--------------------------------------------------------------------------------
-- Debug stuff

-- Register some debug signals. These are meant to be connected to LEDs on a 
-- dev board, or maybe to logic analyzer probes. They are not useful once
-- the core is fully debugged.
debug_info_register:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            debug_info.unmapped_access <= '0';
        else
            if unmapped_access='1' then
                -- This flag will be asserted permanently after any kind of 
                -- unmapped access (code, data read or data write).
                debug_info.unmapped_access <= '1';
            end if;
        end if;
        -- This flag will be asserted as long as the cache is enabled
        debug_info.cache_enabled <= cpu_cache_enable;
    end if;
end process debug_info_register;


--------------------------------------------------------------------------------
-- UART -- 8-bit interface, connected to LOW byte of word (address *3h)

uart : entity work.uart
generic map (
        BAUD_RATE =>    BAUD_RATE,
        CLOCK_FREQ =>   CLOCK_FREQ
    )
    port map (
        clk_i =>        clk,
        reset_i =>      reset,
        
        irq_o =>        uart_irq,
        data_i =>       mpu_io_wr_data(7 downto 0),
        data_o =>       uart_rd_byte,
        addr_rd_i =>    mpu_io_rd_addr(3 downto 2),
        addr_wr_i =>    mpu_io_wr_addr(3 downto 2),
        
        ce_i =>         uart_ce,
        wr_i =>         mpu_io_byte_we(3),
        rd_i =>         mpu_io_rd_vma,
        
        rxd_i =>        uart_rxd,
        txd_o =>        uart_txd
  );
  
-- UART chip enable
uart_ce <= '1'
    when (mpu_io_rd_addr(15 downto 12)=X"0" or 
          mpu_io_wr_addr(15 downto 12)=X"0")
    else '0';

    
--------------------------------------------------------------------------------
-- GPIO registers

gpio_output_registers:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            p0_reg <= (others => '0');
        else
            if mpu_io_wr_addr(19 downto 12)=X"01" then
                if mpu_io_byte_we(0)='1' then
                    p0_reg( 7 downto  0) <= mpu_io_wr_data( 7 downto  0);
                end if;
                if mpu_io_byte_we(1)='1' then
                    p0_reg(15 downto  8) <= mpu_io_wr_data(15 downto  8);
                end if;
                if mpu_io_byte_we(2)='1' then
                    p0_reg(23 downto 16) <= mpu_io_wr_data(23 downto 16);
                end if;
                if mpu_io_byte_we(3)='1' then
                    p0_reg(31 downto 24) <= mpu_io_wr_data(31 downto 24);
                end if;
            end if;
        end if;
    end if;
end process gpio_output_registers; 

p0_out <= p0_reg;

gpio_input_registers:
process(clk)
begin
    -- Note the input register needs no reset value.
    if clk'event and clk='1' then
        p1_reg <= p1_in;
    end if;
end process gpio_input_registers;

with mpu_io_rd_addr(2) select gpio_rd_data <=
    p0_reg      when '0',
    p1_reg      when others;

    
--------------------------------------------------------------------------------
-- I/O port multiplexor 
    
    
-- IO Rd mux: either the UART data/status word or the IO coming from outside
with mpu_io_rd_addr(19 downto 12) select mpu_io_rd_data <= 
    X"000000" & uart_rd_byte    when X"00",
    gpio_rd_data                when X"01",
    io_rd_data                  when others;

-- io_rd_data 
io_rd_addr <= mpu_io_rd_addr;
io_wr_addr <= mpu_io_wr_addr;
io_wr_data <= mpu_io_wr_data;
io_rd_vma <= mpu_io_rd_vma;
io_byte_we <= mpu_io_byte_we;


end architecture rtl;
