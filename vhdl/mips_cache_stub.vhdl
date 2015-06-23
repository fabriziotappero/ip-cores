--------------------------------------------------------------------------------
-- mips_cache_stub.vhdl -- 1-word cache module
--
-- This module has the same interface and logic as a real cache but the cache
-- memory is just 1 word for each of code and data, and it's missing any tag
-- matching logic so all accesses 'miss'.
--
-- It interfaces the CPU to the following:
--
--  1.- Internal 32-bit-wide BRAM for read only
--  2.- Internal 32-bit I/O bus
--  3.- External 16-bit or 8-bit wide static memory (SRAM or FLASH)
--
-- The SRAM memory interface signals are meant to connect directly to FPGA pins
-- and all outputs are registered (tco should be minimal).
-- SRAM data inputs are NOT registered, though. They go through a couple muxes
-- before reaching the first register so watch out for tsetup.
--
-- Obviously this module provides no performance gain; on the contrary, by
-- coupling the CPU to slow external memory (16 bit bus) it actually slows it
-- down. The purpose of this module is just to test the SRAM interface and the
-- cache logic and timing.
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
-- Anyway, you need to take care of this yourself (constraints).
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
-- KNOWN TROUBLE:
--
-- Apart from the very rough looks of the code, there's a few known problems:
--
-- 1.- Write cycles too long
--      In order to guarantee setup and hold times for WE controlled write
--      cycles, two extra clock cycles are inserted for each SRAM write access.
--      This is the most reliable way and the easiest but probably not the best.
--      Until I come up with something better, write cycles to SRAM are going
--      to be very slow.
--
-- 2.- Access to unmapped areas will crash the CPU
--      A couple states are missing in the state machine for handling accesses
--      to unmapped areas. I haven't yet decided how to handle that (return
--      zero, trigger trap, mirror another mapped area...).
--
-- 3.- Does not work as a real 1-word cache yet
--      That functionality is still missing, all accesses 'miss'. It should be
--      implemented, as a way to test the real cache logic on a small scale.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.mips_pkg.all;


entity mips_cache_stub is
    generic (
        BRAM_ADDR_SIZE : integer    := 10;  -- BRAM address size
        SRAM_ADDR_SIZE : integer    := 17;  -- Static RAM/Flash address size
        
        -- these cache parameters are unused in thie implementation, they're
        -- here for compatibility to the real cache module.
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

        byte_we         : in std_logic_vector(3 downto 0);
        data_wr         : in std_logic_vector(31 downto 0);

        code_rd_addr    : in std_logic_vector(31 downto 2);
        code_rd         : out std_logic_vector(31 downto 0);
        code_rd_vma     : in std_logic;

        mem_wait        : out std_logic;
        cache_enable    : in std_logic;
        ic_invalidate   : in std_logic;

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
end entity mips_cache_stub;



architecture stub of mips_cache_stub is

-- Wait state counter -- we're supporting static memory from 10 to >100 ns
subtype t_wait_state_counter is std_logic_vector(2 downto 0);

-- State machine ----------------------------------------------------

type t_cache_state is (
    idle,                       -- Cache hitting, control machine idle

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


-- CPU interface registers ------------------------------------------
signal data_rd_addr_reg :   t_pc;
signal data_wr_addr_reg :   t_pc;
signal code_rd_addr_reg :   t_pc;

signal data_wr_reg :        std_logic_vector(31 downto 0);
signal byte_we_reg :        std_logic_vector(3 downto 0);

-- SRAM interface ---------------------------------------------------
-- Stores first (high) HW read from SRAM
signal sram_rd_data_reg :   std_logic_vector(31 downto 8);
-- Data read from SRAM, valid in refill_1
signal sram_rd_data :       t_word;



-- I-cache -- most of this is unimplemented -------------------------

subtype t_code_tag is std_logic_vector(23 downto 2);
signal code_cache_tag :     t_code_tag;
signal code_cache_tag_store : t_code_tag;
signal code_cache_store :   t_word;
-- code word read from cache
signal code_cache_rd :      t_word;
-- raised whel code_cache_rd is not valid due to a cache miss
signal code_miss :          std_logic;

-- '1' when the I-cache state machine stalls the pipeline (mem_wait)
signal code_wait :          std_logic;

-- D-cache -- most of this is unimplemented -------------------------
subtype t_data_tag is std_logic_vector(23 downto 2);
signal data_cache_tag :     t_data_tag;
signal data_cache_tag_store : t_data_tag;
signal data_cache_store :   t_word;
-- active when there's a write waiting to be done
signal write_pending :      std_logic;
-- active when there's a read waiting to be done
signal read_pending :       std_logic;
-- data word read from cache
signal data_cache_rd :      t_word;
-- '1' when data_cache_rd is not valid due to a cache miss
signal data_miss :          std_logic;

-- '1' when the D-cache state machine stalls the pipeline (mem_wait)
signal data_wait :          std_logic;


-- Address decoding -------------------------------------------------

-- Address slices used to decode
signal code_rd_addr_mask :  t_addr_decode;
signal data_rd_addr_mask :  t_addr_decode;
signal data_wr_addr_mask :  t_addr_decode;

-- Memory map area being accessed for each of the 3 buses:
signal code_rd_attr :       t_range_attr;
signal data_rd_attr :       t_range_attr;
signal data_wr_attr :       t_range_attr;

begin

--------------------------------------------------------------------------------
-- Cache control state machine

cache_state_machine_reg:
process(clk)
begin
   if clk'event and clk='1' then
        if reset='1' then
            ps <= idle;
        else
            ps <= ns;
        end if;
    end if;
end process cache_state_machine_reg;

-- Unified control state machine for I-Cache and D-cache -----------------------
control_state_machine_transitions:
process(ps, code_rd_vma, code_miss, 
        data_wr_attr.mem_type, data_rd_attr.mem_type, code_rd_attr.mem_type, 
        ws_wait_done,
        write_pending, read_pending)
begin
    case ps is
    when idle =>
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
            when others         => ns <= ps;
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
        -- If there's a data operation pending, do it now
        if write_pending='1' then
            case data_wr_attr.mem_type is
            when MT_BRAM        => ns <= data_ignore_write;
            when MT_SRAM_16B    => ns <= data_writethrough_sram_0a;
            when MT_IO_SYNC     => ns <= data_write_io_0;
            -- FIXME ignore write to undecoded area (clear pending flag)
            when others         => ns <= ps;
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

    when code_refill_sram_0 =>
        if ws_wait_done='1' then
            ns <= code_refill_sram_1;
        else
            ns <= ps;
        end if;

    when code_refill_sram_1 =>
        if ws_wait_done='1' then
            -- If there's a data operation pending, do it now
            if write_pending='1' then
                case data_wr_attr.mem_type is
                when MT_BRAM        => ns <= data_ignore_write;
                when MT_SRAM_16B    => ns <= data_writethrough_sram_0a;
                when MT_IO_SYNC     => ns <= data_write_io_0;
                -- FIXME ignore write to undecoded area (clear pending flag)
                when others         => ns <= ps;
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
            ns <= idle;
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
            ns <= idle;
        else
            ns <= ps;
        end if;

    when data_refill_bram_0 =>
        ns <= data_refill_bram_1;

    when data_refill_bram_1 =>
        ns <= idle;

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
        ns <= idle;


    when data_ignore_write =>
        ns <= idle;

    when data_ignore_read =>
        ns <= idle;

    -- Exception states (something went wrong) ----------------------

    when code_crash =>
        -- Attempted to fetch from i/o area. This is a software bug, probably,
        -- and should trigger a trap. We have 1 cycle to do something about it.
        -- After this cycle, back to normal.
        ns <= idle;

    when bug =>
        -- Something weird happened, we have 1 cycle to do something like raise
        -- an error flag, etc. After 1 cycle, back to normal.
        ns <= idle;

    when others =>
        -- We should never arrive here. If we do we handle it in state bug.
        ns <= bug;
    end case;
end process control_state_machine_transitions;

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
-- CPU interface registers and address decoding --------------------------------


-- Everything coming and going to the CPU is registered, so that the CPU has
-- some timing marging.

cpu_data_interface_registers:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            write_pending <= '0';
            read_pending <= '0';
            byte_we_reg <= "0000";
        else
            -- Raise 'read_pending' at 1st cycle of a data read, clear it when
            -- the read (and/or refill) operation has been done.
            -- data_rd_addr_reg always has the addr of any pending read
            if data_rd_vma='1' then
                read_pending <= '1';
                data_rd_addr_reg <= data_addr(31 downto 2);
            elsif ps=data_refill_sram_1 or
                  ps=data_refill_sram8_3 or
                  ps=data_refill_bram_1 or
                  ps=data_read_io_0 or
                  ps=data_ignore_read then
                read_pending <= '0';
            end if;

            -- Raise 'write_pending' at the 1st cycle of a write, clear it when
            -- the write (writethrough actually) operation has been done.
            -- data_wr_addr_reg always has the addr of any pending write
            if byte_we/="0000" and ps=idle then
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


--------------------------------------------------------------------------------
-- BRAM interface


-- BRAM address can come from code or data buses
-- (note both inputs to this mux are register outputs)
bram_rd_addr <=
    data_rd_addr_reg(bram_rd_addr'high downto 2)
        when ps=data_refill_bram_0 else
    code_rd_addr_reg(bram_rd_addr'high downto 2) ;

bram_data_rd_vma <= '1' when ps=data_refill_bram_1 else '0';



--------------------------------------------------------------------------------
-- Code cache

-- All the tag match logic is unfinished and will be simplified away in synth.

-- CPU is wired directly to cache output, no muxes
code_rd <= code_cache_rd;

-- FIXME Actual 1-word cache functionality is unimplemented yet
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            code_miss <= '0';
        else
            code_miss <= code_rd_vma; -- always miss
        end if;
    end if;
end process;

-- Read cache code and tag from code store
code_cache_rd <= code_cache_store;
code_cache_tag <= code_cache_tag_store;

code_cache_memory:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            -- in the real hardware the tag store can't be reset and it's up
            -- to the SW to initialize the cache.
            code_cache_tag_store <= (others => '0');
            code_cache_store <= (others => '0');
        else
            -- Refill cache if necessary
            if ps=code_refill_bram_1 then
                code_cache_tag_store <=
                    "01" & code_rd_addr_reg(t_code_tag'high-2 downto t_code_tag'low);
                code_cache_store <= bram_rd_data;
            elsif ps=code_refill_sram_1 or ps=code_refill_sram8_3 then
                code_cache_tag_store <=
                    "01" & code_rd_addr_reg(t_code_tag'high-2 downto t_code_tag'low);
                code_cache_store <= sram_rd_data;
            end if;
        end if;
    end if;
end process code_cache_memory;


--------------------------------------------------------------------------------
-- Data cache

-- CPU data input mux: direct cache output OR uncached io input
with ps select data_rd <=
    io_rd_data      when data_read_io_1,
    data_cache_rd   when others;

-- All the tag match logic is unfinished and will be simplified away in synth.
-- The 'cache' is really a single register.
data_cache_rd <= data_cache_store;
data_cache_tag <= data_cache_tag_store;

data_cache_memory:
process(clk)
begin
    if clk'event and clk='1' then
        if reset='1' then
            -- in the real hardware the tag store can't be reset and it's up
            -- to the SW to initialize the cache.
            data_cache_tag_store <= (others => '0');
            data_cache_store <= (others => '0');
        else
            -- Refill data cache if necessary
            if ps=data_refill_sram_1 or ps=data_refill_sram8_3 then
                data_cache_tag_store <=
                    "01" & data_rd_addr_reg(t_data_tag'high-2 downto t_data_tag'low);
                data_cache_store <= sram_rd_data;
            elsif ps=data_refill_bram_1 then
                data_cache_tag_store <=
                    "01" & data_rd_addr_reg(t_data_tag'high-2 downto t_data_tag'low);
                data_cache_store <= bram_rd_data;
            end if;
        end if;
    end if;
end process data_cache_memory;


--------------------------------------------------------------------------------
-- SRAM interface

-- Note this signals are meant to be connected directly to FPGA pins (and then
-- to a SRAM, of course). They are the only signals whose tco we care about.

-- FIXME should add a SRAM CE\ signal

-- SRAM address bus (except for LSB) comes from cpu code or data addr registers

sram_address(sram_address'high downto 2) <=
    data_rd_addr_reg(sram_address'high downto 2)
        when   (ps=data_refill_sram_0  or ps=data_refill_sram_1 or
                ps=data_refill_sram8_0 or ps=data_refill_sram8_1 or
                ps=data_refill_sram8_2 or ps=data_refill_sram8_3) else
    code_rd_addr_reg(sram_address'high downto 2)
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
mem_wait <= (code_wait or data_wait or code_miss) and not reset; -- FIXME

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
    '1' when data_read_io_0,
    '0' when others;

end architecture stub;
