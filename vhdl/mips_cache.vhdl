--------------------------------------------------------------------------------
-- mips_cache.vhdl -- cache + memory interface module
--
-- This module contains both MIPS caches (I-Cache and D-Cache) combined with
-- all the glue logic used to decode and interface external memories and
-- devices, both synchronous and asynchronous. 
-- Everything that goes into or comes from the CPU passes through this module.
--
-- See a list of known problems at the bottom of this header.
-- 
--------------------------------------------------------------------------------
-- Main cache parameters:
--
-- I-Cache: 256 4-word lines, direct mapped.
-- D-Cache: 256 4-word lines, direct mapped, write-through
--
-- The cache works mostly like the R3000 caches, except for the following 
-- traits:
--
-- 1.- When bit CP0[12].17='0' (reset value) the cache is 'disabled'. In this 
-- state, ALL memory reads miss the cache and force a line refill -- even 
-- succesive reads from the same line will refill the entire line. This 
-- simplifies the cache logic a lot but slows uncached code a lot. Which means 
-- you should initialize the cache and enable it ASAP after reset. 
-- 
-- 2.- When bits CP0[12].17:16 = "01", the CPU can invalidate a cache line N
-- by writing word N to ANY address. The write will be executed as normal AND
-- the cache controller will invalidate I-Cache line N.
--
-- Note that the standard behavior for bits 17 and 16 of the SR is not
-- implemented at all -- no cache swapping, etc.
--
-- 3.- In this version, all areas of memory are cacheable, except those mapped 
-- as MT_IO_SYNC or MT_UNMAPPED in mips_pkg. 
-- Since you can enable or disable the cache at will this difference doesn't 
-- seem too important.
-- There is a 'cacheable' flag in the t_range_attr record which is currently 
-- unused.
--
-- 4.- The tag is only 14 bits long, which means the memory map is severely
-- restricted in this version. See @note2.
--
-- This is not the standard MIPS way but is compatible enough and above all it
-- is simple.
--
--------------------------------------------------------------------------------
-- NOTES:
--
-- @note1: I-Cache initialization and tag format
--
-- In the tag table (code_tag_table), tags are stored together with a 'valid' 
-- bit (MSB), which is '0' for VALID tags.
-- When the CPU invalidates a line, it writes a '1' in the proper tag table 
-- entry together with the tag value.
-- When tags are matched, the valid bit is matched against 
--
--
-- @note2: I-Cache tags and cache mirroring
-- 
-- To save space in the I-Cache tag table, the tags are shorter than they 
-- should -- 14 bits instead of the 20 bits we would need to cover the
-- entire 32-bit address:
--
--             ___________ <-- These address bits are NOT in the tag
--            /           \
--  31 ..   27| 26 .. 21  |20 ..          12|11  ..        4|3:2|
--  +---------+-----------+-----------------+---------------+---+---+
--  | 5       |           | 9               | 8             | 2 |   |
--  +---------+-----------+-----------------+---------------+---+---+
--  ^                     ^                 ^               ^- LINE_INDEX_SIZE
--  5 bits                9 bits            LINE_NUMBER_SIZE
--
-- Since bits 26 downto 21 are not included in the tag, there will be a 
-- 'mirror' effect in the cache. We have split the memory space 
-- into 32 separate blocks of 1MB which is obviously not enough but will do
-- for the initial tests.
-- In subsequent versions of the cache, the tag size needs to be enlarged AND 
-- some of the top bits might be omitted when they're not needed to implement 
-- the default memory map (namely bit 30 which is always '0').
--
--
-- @note3: Synthesis problem in Quartus-II and workaround
--
-- I had to put a 'dummy' mux between the cache line store and the CPU in order 
-- to get rid of a quirk in Quartus-II synthesizer (several versions).
-- If we omit this extra dummy layer of logic the synth will fail to infer the 
-- tag table as a BRAM and will use logic fabric instead, crippling performance.
-- The mux is otherwise useless and hits performance badly, but so far I haven't
-- found any other way to overcome this bug, not even with the help of the  
-- Altera support forum.
-- Probable cause of this behavior: according to the Cyclone-II manual (section 
-- 'M4K Routing Interface'), no direct connection is possible between an M4K 
-- data output and the address input of another M4K (in this case, the cache 
-- line BRAM and the register bank BRAM). And apparently Quartus-2 won't insert 
-- intermediate logic itself for some reason.
-- This does not happen with ISE on Spartan-3.
-- FIXME: Move this comment to the relevant section of the doc.
--
-- @note4: Startup values for the cache tables
-- 
-- The cache tables has been given startup values; these are only for simulation
-- convenience and have no effect on the cache behaviour (and obviously they
-- are only used after FPGA config, not after reset). 
--
--------------------------------------------------------------------------------
-- This module interfaces the CPU to the following:
--
--  1.- Internal 32-bit-wide BRAM for read only
--  2.- Internal 32-bit I/O bus
--  3.- External 16-bit or 8-bit wide static memory (SRAM or FLASH)
--  4.- External 16-bit wide SDRAM (NOT IMPLEMENTED YET)
--
-- The SRAM memory interface signals are meant to connect directly to FPGA pins
-- and all outputs are registered (tco should be minimal).
-- SRAM data inputs are NOT registered, though. They go through a couple muxes
-- before reaching the first register so watch out for tsetup.
--
--------------------------------------------------------------------------------
-- External FPGA signals
--
-- This module has signals meant to connect directly to FPGA pins: the SRAM
-- interface. They are either direct register outputs or at most with an
-- intervening 2-mux, in order to minimize the Tco (clock-to-output).
--
-- The Tco of these signals has to be accounted for in the real SRAM interface.
-- For example, under Quartus-2 and with a Cyclone-2 grade -7 device, the
-- worst Tco for the SRAM data pins is below 5 ns, enough to use a 10ns SRAM
-- with a 20 ns clock cycle.
-- Anyway, you need to take care of this yourself (synthesis constraints).
--
--------------------------------------------------------------------------------
-- Interface to CPU
--
-- 1.- All signals coming from the CPU are registered.
-- 2.- All CPU inputs come directly from a register, or at most have a 2-mux in
--     between.
--
-- This means this block will not degrade the timing performance of the system,
-- as long as its logic is shallower than the current bottleneck (the ALU).
--
--------------------------------------------------------------------------------
-- KNOWN PROBLEMS:
--
-- 1.- All parameters hardcoded -- generics are almost ignored.
-- 2.- SRAM read state machine does not guarantee internal FPGA Thold. 
--     Currently it works because the FPGA hold tines (including an input mux
--     in the parent module) are far smaller than the SRAM response times, but
--     it would be better to insert an extra cycle after the wait states in
--     the sram read state machine.
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
use work.mips_pkg.all;


entity mips_cache is
    generic (
        BRAM_ADDR_SIZE : integer    := 10;  -- BRAM address size
        SRAM_ADDR_SIZE : integer    := 17;  -- Static RAM/Flash address size
        
        -- these cache parameters are unused in this implementation, they're
        -- here for compatibility to the final cache module.
        LINE_SIZE : integer         := 4;   -- Line size in words
        CACHE_SIZE : integer        := 256  -- I- and D- cache size in lines
    );
    port(
        clk             : in std_logic;
        reset           : in std_logic;

        -- Interface to CPU core
        data_addr       : in std_logic_vector(31 downto 0);
        data_rd         : out std_logic_vector(31 downto 0);
        data_rd_vma     : in std_logic;

        code_rd_addr    : in std_logic_vector(31 downto 2);
        code_rd         : out std_logic_vector(31 downto 0);
        code_rd_vma     : in std_logic;

        byte_we         : in std_logic_vector(3 downto 0);
        data_wr         : in std_logic_vector(31 downto 0);

        mem_wait        : out std_logic;
        cache_ready     : out std_logic;
        cache_enable    : in std_logic;
        ic_invalidate   : in std_logic;
        unmapped        : out std_logic;

        -- interface to FPGA i/o devices
        io_rd_data      : in std_logic_vector(31 downto 0);
        io_rd_addr      : out std_logic_vector(31 downto 2);
        io_wr_addr      : out std_logic_vector(31 downto 2);
        io_wr_data      : out std_logic_vector(31 downto 0);
        io_rd_vma       : out std_logic;
        io_byte_we      : out std_logic_vector(3 downto 0);

        -- interface to synchronous 32-bit-wide FPGA BRAM (possibly used as ROM)
        bram_rd_data    : in std_logic_vector(31 downto 0);
        bram_wr_data    : out std_logic_vector(31 downto 0);
        bram_rd_addr    : out std_logic_vector(BRAM_ADDR_SIZE+1 downto 2);
        bram_wr_addr    : out std_logic_vector(BRAM_ADDR_SIZE+1 downto 2);
        bram_byte_we    : out std_logic_vector(3 downto 0);
        bram_data_rd_vma: out std_logic;

        -- interface to asynchronous 16-bit-wide or 8-bit-wide static memory
        sram_address    : out std_logic_vector(SRAM_ADDR_SIZE-1 downto 0);
        sram_data_rd    : in std_logic_vector(15 downto 0);
        sram_data_wr    : out std_logic_vector(15 downto 0);
        sram_byte_we_n  : out std_logic_vector(1 downto 0);
        sram_oe_n       : out std_logic
    );
end entity mips_cache;


architecture direct of mips_cache is

-- Address of line within line store
constant LINE_NUMBER_SIZE : integer := log2(CACHE_SIZE);
-- Address of word within line
constant LINE_INDEX_SIZE : integer  := log2(LINE_SIZE);
-- Address of word within line store
constant LINE_ADDR_SIZE : integer   := LINE_NUMBER_SIZE+LINE_INDEX_SIZE;

-- Code tag size, excluding valid bit
-- FIXME should be a generic
constant CODE_TAG_SIZE : integer    := 14;
-- Data tag size, excluding valid bit
-- FIXME should be a generic
constant DATA_TAG_SIZE : integer    := 14;


-- Wait state counter -- we're supporting static memory from 10 to >100 ns
-- (0 to 7 wait states with realistic clock rates).
subtype t_wait_state_counter is std_logic_vector(2 downto 0);

-- State machine ----------------------------------------------------

type t_cache_state is (
    cache_reset,                -- Between reset and 1st code refill,
    idle,                       -- Cache is hitting, control machine idle

    -- Code refill --------------------------------------------------
    code_refill_bram_0,         -- pc in bram_rd_addr
    code_refill_bram_1,         -- op in bram_rd
    code_refill_bram_2,         -- op in code_rd

    code_refill_sram_0,         -- rd addr in SRAM addr bus (low hword)
    code_refill_sram_1,         -- rd addr in SRAM addr bus (high hword)

    code_refill_sram8_0,        -- rd addr in SRAM addr bus (byte 0)
    code_refill_sram8_1,        -- rd addr in SRAM addr bus (byte 1)
    code_refill_sram8_2,        -- rd addr in SRAM addr bus (byte 2)
    code_refill_sram8_3,        -- rd addr in SRAM addr bus (byte 3)

    code_crash,                 -- tried to run from i/o or something like that

    -- Data refill & write-through ----------------------------------
    data_refill_sram_0,         -- rd addr in SRAM addr bus (low hword)
    data_refill_sram_1,         -- rd addr in SRAM addr bus (high hword)

    data_refill_sram8_0,        -- rd addr in SRAM addr bus (byte 0)
    data_refill_sram8_1,        -- rd addr in SRAM addr bus (byte 1)
    data_refill_sram8_2,        -- rd addr in SRAM addr bus (byte 2)
    data_refill_sram8_3,        -- rd addr in SRAM addr bus (byte 3)

    data_refill_bram_0,         -- rd addr in bram_rd_addr
    data_refill_bram_1,         -- rd data in bram_rd_data
    data_refill_bram_2,

    data_read_io_0,             -- rd addr on io_rd_addr, io_vma active
    data_read_io_1,             -- rd data on io_rd_data

    data_write_io_0,            -- wr addr & data in io_wr_*, io_byte_we active

    data_writethrough_sram_0a,  -- wr addr & data in SRAM buses (low hword)
    data_writethrough_sram_0b,  -- WE asserted
    data_writethrough_sram_0c,  -- WE deasserted
    data_writethrough_sram_1a,  -- wr addr & data in SRAM buses (high hword)
    data_writethrough_sram_1b,  -- WE asserted
    data_writethrough_sram_1c,  -- WE deasserted

    data_ignore_write,          -- hook for raising error flag FIXME untested
    data_ignore_read,           -- hook for raising error flag FIXME untested

    -- Other states -------------------------------------------------

    --code_wait_for_dcache,       -- wait for D-cache to stop using the buses
    bug                         -- caught an error in the state machine
   );

-- Cache state machine state register & next state
signal ps, ns :             t_cache_state;
-- Wait state down-counter, formally part of the state machine register
signal ws_ctr :             t_wait_state_counter;
-- Wait states for memory being accessed
signal ws_value :           t_wait_state_counter;
-- Asserted to initialize the wait state counter
signal load_ws_ctr :        std_logic;
-- Asserted when the wait state counter has reached zero
signal ws_wait_done :       std_logic;
-- Refill word counters
signal code_refill_ctr :    integer range 0 to LINE_SIZE-1;
signal data_refill_ctr :    integer range 0 to LINE_SIZE-1;
signal data_refill_start :  std_logic;
signal data_refill_end :    std_logic;


-- CPU interface registers ------------------------------------------
-- Registered CPU addresses
signal data_rd_addr_reg :   t_pc;
signal data_wr_addr_reg :   t_pc;
signal code_rd_addr_reg :   t_pc;

-- Data write register (data to be written to external RAM)
signal data_wr_reg :        std_logic_vector(31 downto 0);
-- Registered byte_we vector
signal byte_we_reg :        std_logic_vector(3 downto 0);

-- SRAM interface ---------------------------------------------------
-- Stores first (high) Half-Word read from SRAM
signal sram_rd_data_reg :   std_logic_vector(31 downto 8);
-- Data read from SRAM, valid in refill_1
signal sram_rd_data :       t_word;


-- I-cache ----------------------------------------------------------

subtype t_line_addr is std_logic_vector(LINE_NUMBER_SIZE-1 downto 0);
subtype t_word_addr is std_logic_vector(LINE_ADDR_SIZE-1 downto 0);

subtype t_code_tag is std_logic_vector(CODE_TAG_SIZE+1-1 downto 0);
type t_code_tag_table is array(CACHE_SIZE-1 downto 0) of t_code_tag;
type t_code_line_table is array((CACHE_SIZE*LINE_SIZE)-1 downto 0) of t_word;

-- Code tag table (stores line tags) (@note4)
signal code_tag_table :     t_code_tag_table   := (others => "000000000000000");
-- Code line table  (stores lines)
signal code_line_table :    t_code_line_table  := (others => X"00000000");

-- Tag from code fetch address ('target' address, straight from CPU lines)
signal code_tag :           t_code_tag;
-- Registered code_tag, used matching after reading from code_tag_table
signal code_tag_reg :       t_code_tag;
-- Tag read from cache (will be matched against code_tag_reg)
signal code_cache_tag :     t_code_tag;
-- Code cache line address for read and write ports
signal code_line_addr :     t_line_addr;
-- Code cache word address (read from cache)
signal code_word_addr :     t_word_addr;
-- Code cache word address (write to cache in refills)
signal code_word_addr_wr :  t_word_addr;

-- Word written into code cache
signal code_refill_data :   t_word;
-- Address the code refill data is fetched from
signal code_refill_addr :   t_pc;

-- code word read from cache
signal code_cache_rd :      t_word;
-- raised when code_cache_rd is not valid due to a cache miss
signal code_miss :          std_logic;
-- code_miss for accesses to CACHED areas with cache enabled
signal code_miss_cached : std_logic;
-- code_miss for accesses to UNCACHED areas OR with cache disabled
signal code_miss_uncached : std_logic;
-- '1' when the I-cache state machine stalls the pipeline (mem_wait)
signal code_wait :          std_logic;


-- D-cache ----------------------------------------------------------

subtype t_data_tag is std_logic_vector(DATA_TAG_SIZE+1-1 downto 0);
type t_data_tag_table is array(CACHE_SIZE-1 downto 0) of t_data_tag;
type t_data_line_table is array((CACHE_SIZE*LINE_SIZE)-1 downto 0) of t_word;

-- Data tag table (stores line tags)
signal data_tag_table :     t_data_tag_table   := (others => "000000000000000");
-- Data line table  (stores lines)
signal data_line_table :    t_data_line_table  := (others => X"00000000");

-- Asserted when the D-Cache line table is to be written to
signal update_data_line :   std_logic;
signal update_data_tag :    std_logic;

-- Tag from data load address ('target' address, straight from CPU lines)
signal data_tag :           t_data_tag;
-- Registered data_tag, used matching after reading from data_tag_table
signal data_tag_reg :       t_data_tag;
-- Tag read from cache (will be matched against data_tag_reg)
signal data_cache_tag :     t_data_tag;
-- '1' when the read OR write data address tag matches the cache tag
signal data_tags_match :    std_logic;
-- Data cache line address for read and write ports
signal data_line_addr :     t_line_addr;
-- Data cache word address (read from cache)
signal data_word_addr :     t_word_addr;
-- Data cache word address (write to cache in refills)
signal data_word_addr_wr :  t_word_addr;

-- Word written into data cache
signal data_refill_data :   t_word;
-- Address the code refill data is fetched from (word address)
signal data_refill_addr :   t_pc;

-- Data word read from cache
signal data_cache_rd :      t_word;
-- Raised when data_cache_rd is not valid due to a cache miss
signal data_miss :          std_logic;
-- Data miss logic, portion used with cache enabledº
signal data_miss_cached :   std_logic;
-- Data miss logic, portion used with cach disabled
signal data_miss_uncached : std_logic;
-- Active when LW follows right after a SW (see caveats in code below)
signal data_miss_by_invalidation : std_logic;
-- Active when the data tag comparison result is valid (1 cycle after rd_vma)
-- Note: no relation to byte_we. 
signal data_tag_match_valid:std_logic;
-- Active when the D-cache state machine stalls the pipeline (mem_wait)
signal data_wait :          std_logic;
-- Active when there's a write waiting to be done
signal write_pending :      std_logic;
-- Active when there's a read waiting to be done
signal read_pending :       std_logic;


-- Address decoding -------------------------------------------------

-- Address slices used to decode
signal code_rd_addr_mask :  t_addr_decode;
signal data_rd_addr_mask :  t_addr_decode;
signal data_wr_addr_mask :  t_addr_decode;

-- Memory map area being accessed for each of the 3 buses:
signal code_rd_attr :       t_range_attr;
signal data_rd_attr :       t_range_attr;
signal data_wr_attr :       t_range_attr;

--------------------------------------------------------------------------------
begin

--------------------------------------------------------------------------------
-- Cache control state machine

cache_state_machine_reg:
process(clk)
begin
   if clk'event and clk='1' then
        if reset='1' then
            ps <= cache_reset;
        else
            ps <= ns;
        end if;
    end if;
end process cache_state_machine_reg;

-- Unified control state machine for I-Cache and D-cache -----------------------
-- FIXME The state machine deals with all supported widths and types of memory, 
-- there should be a simpler version with only SRAM/ROM and DRAM.
control_state_machine_transitions:
process(ps, code_rd_vma, data_rd_vma, code_miss, 
        data_wr_attr.mem_type, data_rd_attr.mem_type, code_rd_attr.mem_type, 
        ws_wait_done, code_refill_ctr, data_refill_ctr,
        write_pending, read_pending)
begin
    case ps is
        
    -- The cache will remain in 'cache_reset' state until the first code miss,
    -- at which time the state machine proceeds as usual.
    -- The only difference between states idle and cache_reset is that in
    -- cache_reset the output cache_ready is '0', which will prevent the CPU
    -- from loading its IR with the cache output -- which is known invalid.
    when idle | cache_reset =>
        if code_miss='1' then
            case code_rd_attr.mem_type is
            when MT_BRAM        => ns <= code_refill_bram_0;
            when MT_SRAM_16B    => ns <= code_refill_sram_0;
            when MT_SRAM_8B     => ns <= code_refill_sram8_0;
            when others         => ns <= code_crash;
            end case;

        elsif write_pending='1' then
            case data_wr_attr.mem_type is
            when MT_BRAM        => ns <= data_ignore_write;
            when MT_SRAM_16B    => ns <= data_writethrough_sram_0a;
            when MT_IO_SYNC     => ns <= data_write_io_0;
            -- FIXME ignore write to undecoded area (clear pending flag)
            when others         => ns <= data_ignore_write;
            end case;

        elsif read_pending='1' then
            case data_rd_attr.mem_type is
            when MT_BRAM        => ns <= data_refill_bram_0;
            when MT_SRAM_16B    => ns <= data_refill_sram_0;
            when MT_SRAM_8B     => ns <= data_refill_sram8_0;
            when MT_IO_SYNC     => ns <= data_read_io_0;
            -- FIXME ignore read from undecoded area (clear pending flag)
            when others         => ns <= data_ignore_read;
            end case;

        else
            ns <= ps;
        end if;


    -- Code refill states -------------------------------------------

    when code_refill_bram_0 =>
        ns <= code_refill_bram_1;

    when code_refill_bram_1 =>
        ns <= code_refill_bram_2;

    when code_refill_bram_2 =>
        if code_refill_ctr/=0 then
            -- Still not finished refilling line, go for next word
            ns <= code_refill_bram_0;
        else
            -- If there's a data operation pending, do it now
            if write_pending='1' then
                case data_wr_attr.mem_type is
                when MT_BRAM        => ns <= data_ignore_write;
                when MT_SRAM_16B    => ns <= data_writethrough_sram_0a;
                when MT_IO_SYNC     => ns <= data_write_io_0;
                -- FIXME ignore write to undecoded area (clear pending flag)
                when others         => ns <= data_ignore_write;
                end case;
    
            elsif read_pending='1' then
                case data_rd_attr.mem_type is
                when MT_BRAM        => ns <= data_refill_bram_0;
                when MT_SRAM_16B    => ns <= data_refill_sram_0;
                when MT_SRAM_8B     => ns <= data_refill_sram8_0;
                when MT_IO_SYNC     => ns <= data_read_io_0;
                -- FIXME ignore read from undecoded area (clear pending flag)
                when others         => ns <= data_ignore_read;
                end case;
    
            else
                ns <= idle;
            end if;
        end if;

    when code_refill_sram_0 =>
        if ws_wait_done='1' then
            ns <= code_refill_sram_1;
        else
            ns <= ps;
        end if;

    when code_refill_sram_1 =>
        if code_refill_ctr/=0 and ws_wait_done='1' then
            -- Still not finished refilling line, go for next word
            ns <= code_refill_sram_0;
        else
            if ws_wait_done='1' then
                -- If there's a data operation pending, do it now
                if write_pending='1' then
                    case data_wr_attr.mem_type is
                    when MT_BRAM        => ns <= data_ignore_write;
                    when MT_SRAM_16B    => ns <= data_writethrough_sram_0a;
                    when MT_IO_SYNC     => ns <= data_write_io_0;
                    -- FIXME ignore write to undecoded area (clear pending flag)
                    when others         => ns <= data_ignore_write;
                    end case;
    
                elsif read_pending='1' then
                    case data_rd_attr.mem_type is
                    when MT_BRAM        => ns <= data_refill_bram_0;
                    when MT_SRAM_16B    => ns <= data_refill_sram_0;
                    when MT_SRAM_8B     => ns <= data_refill_sram8_0;
                    when MT_IO_SYNC     => ns <= data_read_io_0;
                    -- FIXME ignore read from undecoded area (clear pending flag)
                    when others         => ns <= data_ignore_read;
                    end case;
    
                else
                    ns <= idle;
                end if;
            else
                ns <= ps;
            end if;
        end if;

    when code_refill_sram8_0 =>
        if ws_wait_done='1' then
            ns <= code_refill_sram8_1;
        else
            ns <= ps;
        end if;

    when code_refill_sram8_1 =>
        if ws_wait_done='1' then
            ns <= code_refill_sram8_2;
        else
            ns <= ps;
        end if;

    when code_refill_sram8_2 =>
        if ws_wait_done='1' then
            ns <= code_refill_sram8_3;
        else
            ns <= ps;
        end if;

    when code_refill_sram8_3 =>
        if code_refill_ctr/=0 and ws_wait_done='1' then
            -- Still not finished refilling line, go for next word
            ns <= code_refill_sram8_0;
        else
            if ws_wait_done='1' then
                -- If there's a data operation pending, do it now
                if write_pending='1' then
                    case data_wr_attr.mem_type is
                    when MT_BRAM        => ns <= data_ignore_write;
                    when MT_SRAM_16B    => ns <= data_writethrough_sram_0a;
                    when MT_IO_SYNC     => ns <= data_write_io_0;
                    -- FIXME ignore write to undecoded area (clear pending flag)
                    when others         => ns <= data_ignore_write;
                    end case;
    
                elsif read_pending='1' then
                    case data_rd_attr.mem_type is
                    when MT_BRAM        => ns <= data_refill_bram_0;
                    when MT_SRAM_16B    => ns <= data_refill_sram_0;
                    when MT_SRAM_8B     => ns <= data_refill_sram8_0;
                    when MT_IO_SYNC     => ns <= data_read_io_0;
                    -- FIXME ignore read from undecoded area (clear pending flag)
                    when others         => ns <= data_ignore_read;
                    end case;
    
                else
                    ns <= idle;
                end if;
            else
                ns <= ps;
            end if;
        end if;
        
    -- Data refill & write-through states ---------------------------

    when data_write_io_0 =>
        ns <= idle;

    when data_read_io_0 =>
        ns <= data_read_io_1;

    when data_read_io_1 =>
        ns <= idle;

    when data_refill_sram8_0 =>
        if ws_wait_done='1' then
            ns <= data_refill_sram8_1;
        else
            ns <= ps;
        end if;

    when data_refill_sram8_1 =>
        if ws_wait_done='1' then
            ns <= data_refill_sram8_2;
        else
            ns <= ps;
        end if;

    when data_refill_sram8_2 =>
        if ws_wait_done='1' then
            ns <= data_refill_sram8_3;
        else
            ns <= ps;
        end if;

    when data_refill_sram8_3 =>
        if ws_wait_done='1' then
            if data_refill_ctr/=LINE_SIZE-1 then
                ns <= data_refill_sram8_0;
            else
                ns <= idle;
            end if;
        else
            ns <= ps;
        end if;

    when data_refill_sram_0 =>
        if ws_wait_done='1' then
            ns <= data_refill_sram_1;
        else
            ns <= ps;
        end if;

    when data_refill_sram_1 =>
        if ws_wait_done='1' then
            if data_refill_ctr=LINE_SIZE-1 then
                ns <= idle;
            else
                ns <= data_refill_sram_0;
            end if;
        else
            ns <= ps;
        end if;

    when data_refill_bram_0 =>
        ns <= data_refill_bram_1;

    when data_refill_bram_1 =>
        ns <= data_refill_bram_2;

    when data_refill_bram_2 => 
        if data_refill_ctr/=(LINE_SIZE-1) then
            -- Still not finished refilling line, go for next word
            ns <= data_refill_bram_0;
        else
            if read_pending='1' then
                case data_rd_attr.mem_type is
                when MT_BRAM        => ns <= data_refill_bram_0;
                when MT_SRAM_16B    => ns <= data_refill_sram_0;
                when MT_SRAM_8B     => ns <= data_refill_sram8_0;
                when MT_IO_SYNC     => ns <= data_read_io_0;
                -- FIXME ignore read from undecoded area (clear pending flag)
                when others         => ns <= data_ignore_read;
                end case;
            else
                ns <= idle;
            end if;
        end if;



    when data_writethrough_sram_0a =>
        ns <= data_writethrough_sram_0b;

    when data_writethrough_sram_0b =>
        if ws_wait_done='1' then
            ns <= data_writethrough_sram_0c;
        else
            ns <= ps;
        end if;

    when data_writethrough_sram_0c =>
        ns <= data_writethrough_sram_1a;

    when data_writethrough_sram_1a =>
        ns <= data_writethrough_sram_1b;

    when data_writethrough_sram_1b =>
        if ws_wait_done='1' then
            ns <= data_writethrough_sram_1c;
        else
            ns <= ps;
        end if;

    when data_writethrough_sram_1c =>
        if read_pending='1' then
            case data_rd_attr.mem_type is
            when MT_BRAM        => ns <= data_refill_bram_0;
            when MT_SRAM_16B    => ns <= data_refill_sram_0;
            when MT_SRAM_8B     => ns <= data_refill_sram8_0;
            when MT_IO_SYNC     => ns <= data_read_io_0;
            -- FIXME ignore read from undecoded area (clear pending flag)
            when others         => ns <= data_ignore_read;
            end case; 
        else
            ns <= idle;
        end if;

    when data_ignore_write =>
        ns <= idle;

    when data_ignore_read =>
        ns <= idle;

    -- Exception states (something went wrong) ----------------------

    when code_crash =>
        -- Attempted to fetch from i/o area. This is a software bug, probably,
        -- and should trigger a trap. We have 1 cycle to do something about it.
        -- FIXME do something about wrong fetch: trap, etc.
        -- After this cycle, back to normal.
        ns <= idle;

    when bug =>
        -- Something weird happened, we have 1 cycle to do something like raise
        -- an error flag, etc. After 1 cycle, back to normal.
        -- FIXME raise trap or flag or something
        ns <= idle;

    when others =>
        -- We should never arrive here. If we do we handle it in state bug.
        ns <= bug;
    end case;
end process control_state_machine_transitions;


--------------------------------------------------------------------------------
-- Wait state logic

-- load wait state counter when we're entering the state we will wait on
load_ws_ctr <= '1' when
    (ns=code_refill_sram_0  and ps/=code_refill_sram_0) or
    (ns=code_refill_sram_1  and ps/=code_refill_sram_1) or
    (ns=code_refill_sram8_0 and ps/=code_refill_sram8_0) or
    (ns=code_refill_sram8_1 and ps/=code_refill_sram8_1) or
    (ns=code_refill_sram8_2 and ps/=code_refill_sram8_2) or
    (ns=code_refill_sram8_3 and ps/=code_refill_sram8_3) or
    (ns=data_refill_sram_0  and ps/=data_refill_sram_0) or
    (ns=data_refill_sram_1  and ps/=data_refill_sram_1) or
    (ns=data_refill_sram8_0 and ps/=data_refill_sram8_0) or
    (ns=data_refill_sram8_1 and ps/=data_refill_sram8_1) or
    (ns=data_refill_sram8_2 and ps/=data_refill_sram8_2) or
    (ns=data_refill_sram8_3 and ps/=data_refill_sram8_3) or
    (ns=data_writethrough_sram_0a) or
    (ns=data_writethrough_sram_1a)
    else '0';


-- select the wait state counter value as that of read address or write address
with ns select ws_value <=
    data_rd_attr.wait_states    when data_refill_sram_0,
    data_rd_attr.wait_states    when data_refill_sram_1,
    data_rd_attr.wait_states    when data_refill_sram8_0,
    data_rd_attr.wait_states    when data_refill_sram8_1,
    data_rd_attr.wait_states    when data_refill_sram8_2,
    data_rd_attr.wait_states    when data_refill_sram8_3,
    data_wr_attr.wait_states    when data_writethrough_sram_0a,
    data_wr_attr.wait_states    when data_writethrough_sram_1a,
    code_rd_attr.wait_states    when code_refill_sram_0,
    code_rd_attr.wait_states    when code_refill_sram_1,
    code_rd_attr.wait_states    when code_refill_sram8_0,
    code_rd_attr.wait_states    when code_refill_sram8_1,
    code_rd_attr.wait_states    when code_refill_sram8_2,
    code_rd_attr.wait_states    when code_refill_sram8_3,
    data_wr_attr.wait_states    when others;


wait_state_counter_reg:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            ws_ctr <= (others => '0');
        else
            if load_ws_ctr='1' then
                ws_ctr <= ws_value;
            elsif ws_wait_done='0' then
                ws_ctr <= ws_ctr - 1;
            end if;
        end if;
    end if;
end process wait_state_counter_reg;

ws_wait_done <= '1' when ws_ctr="000" else '0';

--------------------------------------------------------------------------------
-- Refill word counters

code_refill_word_counter:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' or (code_miss='1' and ps=idle) then
            code_refill_ctr <= LINE_SIZE-1;
        else
            if (ps=code_refill_bram_2 or 
               ps=code_refill_sram_1 or 
               ps=code_refill_sram8_3) and 
               ws_wait_done='1'  and
               code_refill_ctr/=0 then
            code_refill_ctr <= code_refill_ctr-1; --  FIXME explain downcount
            end if;
        end if;
    end if;
end process code_refill_word_counter;

with ps select data_refill_end <=
    '1' when data_refill_bram_2,
    '1' when data_refill_sram_1,
    '1' when data_refill_sram8_3,
    '0' when others;

data_refill_word_counter:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' or (data_miss='1' and ps=idle) then
            data_refill_ctr <= 0;
        else
            if data_refill_end='1' and ws_wait_done='1' then
                if data_refill_ctr=(LINE_SIZE-1) then
                    data_refill_ctr <= 0;
                else
                    data_refill_ctr <= data_refill_ctr + 1;
                end if;
            end if;
        end if;
    end if;
end process data_refill_word_counter;

--------------------------------------------------------------------------------
-- CPU interface registers and address decoding --------------------------------

data_refill_start <= 
    '1' when ((ps=data_refill_sram_0 or ps=data_refill_sram8_0 or 
            ps=data_refill_bram_0) and data_refill_ctr=0)
    else '0';

-- Everything coming and going to the CPU is registered, so that the CPU has
-- some timing marging. These are those registers.
-- Besides, we have here a couple of read/write pending flags used to properly
-- sequence the cache accesses (first fetch, then any pending r/w).
cpu_data_interface_registers:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            write_pending <= '0';
            read_pending <= '0';
            byte_we_reg <= "0000";
        else
            -- Raise 'read_pending' as soon as we know a read is to be done.
            -- Clear it as soon as the read/refill has STARTED. 
            -- Can be raised again after a read is started and before it's done.
            -- data_rd_addr_reg always has the addr of any pending read.
            if data_miss='1' then
                read_pending <= '1';
                data_rd_addr_reg <= data_addr(31 downto 2);
            elsif data_refill_start='1' or ps=data_read_io_0 or
                  ps=data_ignore_read then
                read_pending <= '0';
            end if;

            -- Raise 'write_pending' at the 1st cycle of a write, clear it when
            -- the write (writethrough actually) operation has been done.
            -- data_wr_addr_reg always has the addr of any pending write
            if byte_we/="0000" then
                byte_we_reg <= byte_we;
                data_wr_reg <= data_wr;
                data_wr_addr_reg <= data_addr(31 downto 2);
                write_pending <= '1';
            elsif ps=data_writethrough_sram_1b or
                  ps=data_write_io_0 or
                  ps=data_ignore_write then
                write_pending <= '0';
                byte_we_reg <= "0000";
            end if;

        end if;
    end if;
end process cpu_data_interface_registers;

cpu_code_interface_registers:
process(clk)
begin
    if clk'event and clk='1' then
        -- Register code fetch addresses only when they are valid; so that
        -- code_rd_addr_reg always holds the last fetch address.
        if code_rd_vma='1' then
            code_rd_addr_reg <= code_rd_addr;
        end if;
    end if;
end process cpu_code_interface_registers;

-- The code refill address is that of the current code line, with the running
-- refill counter appended: we will read all the words from the line in sequence
-- (in REVERSE sequence, actually, see below).
code_refill_addr <= 
    code_rd_addr_reg(code_rd_addr_reg'high downto 4) & 
    conv_std_logic_vector(code_refill_ctr,LINE_INDEX_SIZE);

data_refill_addr <= 
    data_rd_addr_reg(data_rd_addr_reg'high downto 4) & 
    conv_std_logic_vector(data_refill_ctr,LINE_INDEX_SIZE);



-- Address decoding ------------------------------------------------------------

-- Decoding is done on the high bits of the address only, there'll be mirroring.
-- Write to areas not explicitly decoded will be silently ignored. Reads will
-- get undefined data.

code_rd_addr_mask <= code_rd_addr_reg(31 downto t_addr_decode'low);
data_rd_addr_mask <= data_rd_addr_reg(31 downto t_addr_decode'low);
data_wr_addr_mask <= data_wr_addr_reg(31 downto t_addr_decode'low);


code_rd_attr <= decode_addr(code_rd_addr_mask);
data_rd_attr <= decode_addr(data_rd_addr_mask);
data_wr_attr <= decode_addr(data_wr_addr_mask);

-- Unmapped area access flag, raised for 1 cycle only after each wrong access
with ps select unmapped <=
    '1' when code_crash,
    '1' when data_ignore_read,
    '1' when data_ignore_write,
    '0' when others;


--------------------------------------------------------------------------------
-- BRAM interface (BRAM is FPGA Block RAM)

-- BRAM address can come from code or data buses, we support code execution
-- and data r/w from BRAM.
-- (note both inputs to this mux are register outputs)
bram_rd_addr <=
    --data_rd_addr_reg(bram_rd_addr'high downto 2)
    data_refill_addr(bram_rd_addr'high downto 2)
        when ps=data_refill_bram_0 else
    code_refill_addr(bram_rd_addr'high downto 2) ;

bram_data_rd_vma <= '1' when ps=data_refill_bram_1 else '0';


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Code cache

-- CPU is wired directly to cache output, no muxes -- or at least is SHOULD. 
-- Due to some unknowk reason, if we omit this extra dummy layer of logic the 
-- synth (Quartus-II) will fail to infer the tag table as a BRAM.
-- (@note3)
code_rd <= code_cache_rd when reset='0' else X"00000000";

-- Register here the requested code tag so we can compare it to the tag in the
-- cache store. Note we register and match the 'line valid' bit together with
-- the rest of the tag.
code_tag_register:
process(clk)
begin
    if clk'event and clk='1' then
        -- Together with the tag value, we register the valid bit against which 
        -- we will match after reading the tag table.
        -- The valid bit will be '0' for normal accesses or '1' when the cache 
        -- is disabled OR we're invalidating lines. This ensures that the cache
        -- will miss in those cases.
        code_tag_reg <= (ic_invalidate or (not cache_enable)) & 
                        code_tag(code_tag'high-1 downto 0);
    end if;
end process code_tag_register;

-- The I-Cache misses when the tag in the cache is not the tag we want or 
-- it is not valid.
code_miss_cached <= '1' when (code_tag_reg /= code_cache_tag) else '0';

-- When cache is disabled, ALL code fetches will miss
uncached_code_miss_logic:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            code_miss_uncached <= '0';
        else
            code_miss_uncached <= code_rd_vma; -- always miss
        end if;
    end if;
end process uncached_code_miss_logic;

-- Select the proper code_miss signal
code_miss <= code_miss_uncached when cache_enable='0' else code_miss_cached;


-- Code line address used for both read and write into the table
code_line_addr <=
    -- when the CPU wants to invalidate I-Cache lines, the addr comes from the
    -- data bus (see @note1)
    data_wr(7 downto 0) when byte_we(3)='1' and ic_invalidate='1' 
    -- otherwise the addr comes from the code address as usual
    else code_rd_addr(11 downto 4);

code_word_addr <= code_rd_addr(11 downto 2);
code_word_addr_wr <= code_line_addr & conv_std_logic_vector(code_refill_ctr,LINE_INDEX_SIZE);
-- NOTE: the tag will be marked as INVALID ('1') when the CPU is invalidating 
-- code lines (@note1)
code_tag <= 
    (ic_invalidate) &                            
    code_rd_addr(31 downto 27) &                 
    code_rd_addr(11+CODE_TAG_SIZE-5 downto 11+1);


code_tag_memory:
process(clk)
begin
    if clk'event and clk='1' then
        if ps=code_refill_bram_1 or ps=code_refill_sram8_3 or ps=code_refill_sram_1 then
            code_tag_table(conv_integer(code_line_addr)) <= code_tag;
        end if;
    
        code_cache_tag <= code_tag_table(conv_integer(code_line_addr));
    end if;
end process code_tag_memory;


code_line_memory:
process(clk)
begin
    if clk'event and clk='1' then
        if ps=code_refill_bram_1 or ps=code_refill_sram8_3 or ps=code_refill_sram_1 then
            code_line_table(conv_integer(code_word_addr_wr)) <= code_refill_data;
        end if;

        code_cache_rd <= code_line_table(conv_integer(code_word_addr));
    end if;
end process code_line_memory;

-- Code can only come from BRAM or SRAM (including 16- and 8- bit interfaces)
with ps select code_refill_data <=
    bram_rd_data    when code_refill_bram_1,
    sram_rd_data    when others;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Data cache (direct mapped, nearly identical to code cache)


-- (@note3)
with ps select data_rd <= 
    io_rd_data      when data_read_io_1,
    data_cache_rd   when others;

-- Register here the requested data tag so we can compare it to the tag in the
-- cache store. Note we register and match the 'line valid' bit together with
-- the rest of the tag.
data_tag_register:
process(clk)
begin
    if clk'event and clk='1' then
        -- Together with the tag value, we register the valid bit against which 
        -- we will match after reading the tag table.
        -- The valid bit will be '0' for normal accesses or '1' when the cache 
        -- is disabled OR we're invalidating lines. This ensures that the cache
        -- will miss in those cases.
        data_tag_reg <= (ic_invalidate or (not cache_enable)) & 
                        data_tag(data_tag'high-1 downto data_tag'low);
    end if;
end process data_tag_register;


-- The tags are 'compared' the cycle after data_rd_vma. 
-- FIXME explain role of ic_invalidate in this.
-- Note: writethroughs use the tag match result at a different moment.
data_tag_comparison_validation:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            data_tag_match_valid <= '0';
        else
            data_tag_match_valid <= data_rd_vma and not ic_invalidate;
        end if;
    end if;
end process data_tag_comparison_validation;


-- The D-Cache misses when the tag in the cache is not the tag we want or 
-- it is not valid.

-- When we write to a line right before we read from it, we have a RAW data 
-- hazard: the data cache will (usually) hit because the tag match will be done
-- before the writethrough. To prevent this, we do an additional tag match.
data_miss_by_invalidation <= '1' when 
    data_tag_match_valid='1' and update_data_tag='1' --and
    -- FIXME skip additional tag match, it's too slow. Do later as registered
    -- match and update state machine.
    -- This means that a sequence SW + LW will ALWAYS produce a data miss,
    -- even if the written lines are different. This needs fixing.
--    data_tag_reg=data_tag
    else '0';

-- When cache is disabled, assert 'miss' after vma 
data_miss_uncached <= data_tag_match_valid and not ic_invalidate;
-- When cache is enabled, assert 'miss' after the comparison is done.
data_tags_match <= '1' when (data_tag_reg = data_cache_tag) else '0';
data_miss_cached <= '1' when 
    (data_tag_match_valid='1' and data_tags_match='0') or
    data_miss_by_invalidation='1'
    else '0';

-- Select the proper data_miss source with a mux
data_miss <= data_miss_uncached when cache_enable='0' else data_miss_cached;


-- Data line address used for both read and write into the table
data_line_addr <=
    -- When the CPU wants to invalidate D-Cache lines, the addr comes from the
    -- data bus (see @note1)
    data_wr(7 downto 0) when byte_we(3)='1' and ic_invalidate='1' 
    -- otherwise the addr comes from the code address as usual
    else data_addr(11 downto 4);

data_word_addr <= data_addr(11 downto 2);
data_word_addr_wr <= data_line_addr & conv_std_logic_vector(data_refill_ctr,LINE_INDEX_SIZE);
-- NOTE: the tag will be marked as INVALID ('1') when the CPU is invalidating 
-- code lines (@note1)
-- FIXME explain role of ic_invalidate in this logic
data_tag <= 
    (ic_invalidate or not data_tag_match_valid) &
    data_addr(31 downto 27) &
    data_addr(11+DATA_TAG_SIZE-5 downto 11+1);

-- The data tag table will be written to...
update_data_tag <= '1' when 
    -- ...when a refill word is read (redundant writes) or...
    (ps=data_refill_sram8_3 or ps=data_refill_sram_1 or ps=data_refill_bram_1) or
    -- ...when writing through a line which is cached or...
    (ps=data_writethrough_sram_0a and data_tags_match='1') or
    -- ...when a D-Cache line invalidation access is made
    (data_rd_vma='1' and ic_invalidate='1')
    else '0';
    
data_tag_memory:
process(clk)
begin
    if clk'event and clk='1' then
        if update_data_tag='1' then
            data_tag_table(conv_integer(data_line_addr)) <= data_tag;
        end if;
    
        data_cache_tag <= data_tag_table(conv_integer(data_line_addr));
    end if;
end process data_tag_memory;


update_data_line <= '1' when ps=data_refill_sram8_3 or ps=data_refill_sram_1 or ps=data_refill_bram_1
                    else '0';

data_line_memory:
process(clk)
begin
    if clk'event and clk='1' then
        if update_data_line='1' then
            --assert 1=0
            --report "D-Cache["& str(conv_integer(data_word_addr_wr),10) & "] = 0x"& hstr(data_refill_data)
            --severity note;
            data_line_table(conv_integer(data_word_addr_wr)) <= data_refill_data;
        end if;

        data_cache_rd <= data_line_table(conv_integer(data_word_addr));
    end if;
end process data_line_memory;

-- Data can only come from SRAM (including 16- and 8- bit interfaces)
with ps select data_refill_data <=
    bram_rd_data    when data_refill_bram_1,
    sram_rd_data    when others;

------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- SRAM interface

-- Note this signals are meant to be connected directly to FPGA pins (and then
-- to a SRAM, of course). They are the only signals whose tco we care about.

-- FIXME should add a SRAM CE\ signal

-- SRAM address bus (except for LSB) comes from cpu code or data addr registers

sram_address(sram_address'high downto 2) <=
    data_refill_addr(sram_address'high downto 2)
        when   (ps=data_refill_sram_0  or ps=data_refill_sram_1 or
                ps=data_refill_sram8_0 or ps=data_refill_sram8_1 or
                ps=data_refill_sram8_2 or ps=data_refill_sram8_3) else
    code_refill_addr(sram_address'high downto 2)
        when   (ps=code_refill_sram_0  or ps=code_refill_sram_1 or
                ps=code_refill_sram8_0 or ps=code_refill_sram8_1 or
                ps=code_refill_sram8_2 or ps=code_refill_sram8_3) else
    data_wr_addr_reg(sram_address'high downto 2);

-- SRAM addr bus LSB depends on the D-cache state because we read/write the
-- halfwords sequentially in successive cycles.
sram_address(1) <=
    '0'     when   (ps=data_writethrough_sram_0a or
                    ps=data_writethrough_sram_0b or
                    ps=data_writethrough_sram_0c or
                    ps=data_refill_sram8_0 or
                    ps=data_refill_sram8_1 or
                    ps=data_refill_sram_0 or
                    ps=code_refill_sram8_0 or
                    ps=code_refill_sram8_1 or
                    ps=code_refill_sram_0) else
    '1'     when   (ps=data_writethrough_sram_1a or
                    ps=data_writethrough_sram_1b or
                    ps=data_writethrough_sram_1c or
                    ps=data_refill_sram8_2 or
                    ps=data_refill_sram8_3 or
                    ps=data_refill_sram_1 or
                    ps=code_refill_sram8_2 or
                    ps=code_refill_sram8_3 or
                    ps=code_refill_sram_1)
    else '0';

-- The lowest addr bit will only be used when accessing byte-wide memory, and
-- even when we're reading word-aligned code (because we need to read the four 
-- bytes one by one).
sram_address(0) <=
    '0'     when (ps=data_refill_sram8_0 or ps=data_refill_sram8_2 or
                  ps=code_refill_sram8_0 or ps=code_refill_sram8_2) else
    '1';


-- SRAM databus (when used for output) comes from either hword of the data
-- write register.
with ps select sram_data_wr <=
    data_wr_reg(31 downto 16)   when data_writethrough_sram_0a,
    data_wr_reg(31 downto 16)   when data_writethrough_sram_0b,
    data_wr_reg(31 downto 16)   when data_writethrough_sram_0c,
    data_wr_reg(15 downto  0)   when data_writethrough_sram_1a,
    data_wr_reg(15 downto  0)   when data_writethrough_sram_1b,
    data_wr_reg(15 downto  0)   when data_writethrough_sram_1c,
    (others => 'Z')             when others;

-- The byte_we is split in two similarly.
with ps select sram_byte_we_n <=
    not byte_we_reg(3 downto 2) when data_writethrough_sram_0b,
    not byte_we_reg(1 downto 0) when data_writethrough_sram_1b,
    "11"                        when others;

-- SRAM OE\ is only asserted low for read cycles
sram_oe_n <=
    '0' when   (ps=data_refill_sram_0  or ps=data_refill_sram_1 or
                ps=data_refill_sram8_0 or ps=data_refill_sram8_1 or
                ps=data_refill_sram8_2 or ps=data_refill_sram8_3 or
                ps=code_refill_sram_0  or ps=code_refill_sram_1 or
                ps=code_refill_sram8_0 or ps=code_refill_sram8_1 or
                ps=code_refill_sram8_2 or ps=code_refill_sram8_3) else
    '1';

-- When reading from the SRAM, read word comes from read hword register and
-- SRAM bus (read register is loaded in previous cycle).
sram_rd_data <=
    sram_rd_data_reg & sram_data_rd(7 downto 0)
            when ps=data_refill_sram8_3 or ps=code_refill_sram8_3 else
    sram_rd_data_reg(31 downto 16) & sram_data_rd;

sram_input_halfword_register:
process(clk)
begin
    if clk'event and clk='1' then
        if ps=data_refill_sram_0 or ps=code_refill_sram_0 then
            sram_rd_data_reg(31 downto 16) <= sram_data_rd;
        elsif ps=data_refill_sram8_0 or ps=code_refill_sram8_0 then
            sram_rd_data_reg(31 downto 24) <= sram_data_rd(7 downto 0);
        elsif ps=data_refill_sram8_1 or ps=code_refill_sram8_1 then
            sram_rd_data_reg(23 downto 16) <= sram_data_rd(7 downto 0);
        elsif ps=data_refill_sram8_2 or ps=code_refill_sram8_2 then
            sram_rd_data_reg(15 downto  8) <= sram_data_rd(7 downto 0);
        end if;
    end if;
end process sram_input_halfword_register;


--------------------------------------------------------------------------------
-- I/O interface -- IO is assumed to behave like synchronous memory

io_byte_we <= byte_we_reg when ps=data_write_io_0 else "0000";
io_rd_addr <= data_rd_addr_reg;
io_wr_addr <= data_wr_addr_reg;
io_wr_data <= data_wr_reg;
io_rd_vma <= '1' when ps=data_read_io_0 else '0';


--------------------------------------------------------------------------------
-- CPU stall control

-- Stall the CPU when either state machine needs it
mem_wait <= 
    (code_wait or data_wait or  -- code or data refill in course
     code_miss or data_miss     -- code or data miss
     ) and not reset; -- FIXME stub

-- Assert code_wait until the cycle where the CPU has valid code word on its
-- code bus
with ps select code_wait <=
    '1' when code_refill_bram_0,
    '1' when code_refill_bram_1,
    '1' when code_refill_bram_2,
    '1' when code_refill_sram_0,
    '1' when code_refill_sram_1,
    '1' when code_refill_sram8_0,
    '1' when code_refill_sram8_1,
    '1' when code_refill_sram8_2,
    '1' when code_refill_sram8_3,
    '0' when others;

-- Assert data_wait until the cycle where the CPU has valid data word on its
-- code bus AND no other operations are ongoing that may use the external buses.
with ps select data_wait <=
    '1' when data_writethrough_sram_0a,
    '1' when data_writethrough_sram_0b,
    '1' when data_writethrough_sram_0c,
    '1' when data_writethrough_sram_1a,
    '1' when data_writethrough_sram_1b,
    '1' when data_writethrough_sram_1c,
    '1' when data_refill_sram_0,
    '1' when data_refill_sram_1,
    '1' when data_refill_sram8_0,
    '1' when data_refill_sram8_1,
    '1' when data_refill_sram8_2,
    '1' when data_refill_sram8_3,
    '1' when data_refill_bram_0,
    '1' when data_refill_bram_1,
    '1' when data_refill_bram_2,
    '1' when data_read_io_0,
    -- In any other state, stall CPU only if there's a RD/WR pending.
    read_pending or write_pending when others;


    -- The cache will be ready only after the first code refill.
    -- This will prevent the CPU from loading junk into the IR.
    with ps select cache_ready <=
        '0' when cache_reset,
        '1' when others;


end architecture direct;
