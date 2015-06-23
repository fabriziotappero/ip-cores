--##############################################################################
-- Simulation test bench -- not synthesizable.
--
-- Simulates the MCU core connected to a simulated external static RAM on a 
-- 16-bit bus, plus an optional 8-bit static ROM. This setup is more or less 
-- that of develoment board DE-1 from Terasic.
--------------------------------------------------------------------------------
-- Simulated I/O
-- Apart from the io devices within the SoC module, this test bench simulates
-- the following ports:
--
-- 20010000: HW IRQ 0 countdown register (R/o).
-- 20010004: HW IRQ 1 countdown register (R/o).
-- 20010008: HW IRQ 2 countdown register (R/o).
-- 2001000c: HW IRQ 3 countdown register (R/o).
-- 20010010: HW IRQ 4 countdown register (R/o).
-- 20010014: HW IRQ 5 countdown register (R/o).
-- 20010018: HW IRQ 6 countdown register (R/o).
-- 2001001c: HW IRQ 7 countdown register (R/o).
-- 20010020: Debug register 0 (R/W).
-- 20010024: Debug register 1 (R/W).
-- 20010028: Debug register 2 (R/W).
-- 2001002c: Debug register 3 (R/W).
--
-- NOTE: these addresses are for write accesses only. for read accesses, the 
-- debug registers 0..3 are mirrored over all the io address range 2001xxxxh.
--
-- Writing N to an IRQ X countdown register will trigger hardware interrupt X
-- N clock cycles later. The interrupt line will be asserted for 1 clock cycle.
--
-- The debug registers 0 to 3 can only be used to test 32-bit i/o.
-- All of these registers can only be addressed as 32-bit words. Any other type
-- of access will yield undefined results.
--------------------------------------------------------------------------------
-- Console logging:
--
-- Console output (at addresses compatible to Plasma's) is logged to text file
-- "hw_sim_console_log.txt".
--
-- IMPORTANT: The code that echoes UART TX data to the simulation console does
-- line buffering; it will not print anything until it gets a CR (0x0d), and
-- will ifnore LFs (0x0a). Bear this in mind if you see no output when you 
-- expect it.
--
-- Console logging is done by monitoring CPU writes to the UART, NOT by looking
-- at the TxD pin. It will NOT catch baud-related problems, etc.
--------------------------------------------------------------------------------
-- WARNING: Will only work on Modelsim; uses custom library SignalSpy.
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

use work.txt_util.all;
use work.mips_pkg.all;
use work.mips_tb_pkg.all;
use work.sim_params_pkg.all;
--use work.obj_code_pkg.obj_code;


entity mips_tb is
end;


architecture testbench of mips_tb is

-- External 16-bit SRAM and interface signals ----------------------------------

-- External SRAM address length -- these are 16-bit word addresses.
constant SRAM_ADDR_SIZE : integer := log2(SRAM_SIZE);

-- Static 16-bit wide RAM.
-- Using shared variables for big memory arrays speeds up simulation a lot;
-- see Modelsim 6.3 User Manual, section on 'Modelling Memory'.
-- WARNING: I have only tested this construct with Modelsim SE 6.3.
shared variable sram : t_hword_table(0 to SRAM_SIZE-1) := objcode_to_htable(SRAM_INIT, SRAM_SIZE);


signal sram_chip_addr :     std_logic_vector(SRAM_ADDR_SIZE downto 1);
signal sram_output :        t_halfword;


-- PROM table and interface signals --------------------------------------------

constant PROM_ADDR_SIZE : integer := log2(PROM_SIZE);
subtype t_prom_address is std_logic_vector(PROM_ADDR_SIZE-1 downto 0);

-- We'll simulate a 16-bit-wide static PROM (e.g. a Flash) with some serious
-- cycle time (70 or 90 ns).
-- FIXME FLASH read cycle time not modelled yet.
signal prom_rd_addr :       t_prom_address; 
signal prom_output :        t_byte;
signal prom_oe_n :          std_logic;

-- 8-bit wide FLASH modelled as read only block.
-- We don't simulate the actual FLASH chip: no FLASH writes, control regs, etc.
shared variable prom : t_byte_table(0 to PROM_SIZE-1) := objcode_to_btable(PROM_INIT, PROM_SIZE);


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
signal mpu_sram_address :   std_logic_vector(31 downto 0);
signal mpu_sram_data_rd :   t_halfword;
signal mpu_sram_data_wr :   t_halfword;
signal mpu_sram_byte_we_n : std_logic_vector(1 downto 0);
signal mpu_sram_oe_n :      std_logic;

-- interface to i/o
signal io_rd_data :         std_logic_vector(31 downto 0);
signal io_wr_data :         std_logic_vector(31 downto 0);
signal io_rd_addr :         std_logic_vector(31 downto 2);
signal io_wr_addr :         std_logic_vector(31 downto 2);
signal io_rd_vma :          std_logic;
signal io_byte_we :         std_logic_vector(3 downto 0);

signal rxd :                std_logic;
signal txd :                std_logic;

-- Other CPU signals 
signal cpu_irq :            std_logic_vector(7 downto 0);

--------------------------------------------------------------------------------
-- Logging signals


-- Log file
file log_file: TEXT open write_mode is "hw_sim_log.txt";

-- Console output log file
file con_file: TEXT open write_mode is "hw_sim_console_log.txt";

-- All the info needed by the logger is here
signal log_info :           t_log_info;

-- IRQ trigger simulation ------------------------------------------------------

signal irq_trigger_addr :   std_logic_vector(2 downto 0);
signal irq_trigger_data :   std_logic_vector(31 downto 0);
signal irq_trigger_load :   std_logic;

subtype t_irq_countdown     is std_logic_vector(31 downto 0);
type t_irq_countdown_array  is array(0 to 7) of t_irq_countdown;

signal irq_countdown :      t_irq_countdown_array;

-- Simulated block of 4 read/write, 32-bit I/O registers, used in cache test. 
type t_debug_reg_block is array(0 to 3) of t_word;
signal debug_reg_block :    t_debug_reg_block;


begin

    -- UUT instantiation -------------------------------------------------------
    mpu: entity work.mips_soc
    generic map (
        BOOT_BRAM_SIZE => bram_size,
        OBJECT_CODE    => obj_code,
        CLOCK_FREQ     => 50000000,
        SRAM_ADDR_SIZE => 32
    )
    port map (
        interrupt       => cpu_irq,

        -- interface to FPGA i/o devices
        io_rd_data      => io_rd_data,
        io_rd_addr      => io_rd_addr,
        io_wr_addr      => io_wr_addr,
        io_wr_data      => io_wr_data,
        io_rd_vma       => io_rd_vma,
        io_byte_we      => io_byte_we,

        -- interface to asynchronous 16-bit-wide EXTERNAL SRAM
        sram_address    => mpu_sram_address,
        sram_data_rd    => mpu_sram_data_rd,
        sram_data_wr    => mpu_sram_data_wr,
        sram_byte_we_n  => mpu_sram_byte_we_n,
        sram_oe_n       => mpu_sram_oe_n,

        uart_rxd        => rxd,
        uart_txd        => txd,

        p0_out          => OPEN,
        p1_in           => X"00000000",
        
        debug_info      => OPEN,
        
        clk             => clk,
        reset           => reset
    );


    -- Master clock: free running clock used as main module clock --------------
    run_master_clock:
    process(done, clk)
    begin
        if done = '0' then
            clk <= not clk after T/2;
        end if;
    end process run_master_clock;

    -- Main simulation process: reset MCU and wait for fixed period ------------
    drive_uut:
    process
    variable l : line;
    begin
        wait for T*4;
        reset <= '0';
        
        wait for T*SIMULATION_LENGTH;

        -- Flush console output to log console file (in case the end of the
        -- simulation caugh an unterminated line in the buffer)
        if log_info.con_line_ix > 1 then
            write(l, log_info.con_line_buf(1 to log_info.con_line_ix));
            writeline(con_file, l);
        end if;

        print("TB finished");
        done <= '1';
        wait;
        
    end process drive_uut;



    -- SRAM/FLASH mux (on a real board this would be a simple address decoder)
    mpu_sram_data_rd <= 
        X"00" & prom_output when mpu_sram_address(31 downto 27)="10110" else
        sram_output;
            

    -- Do a very basic simulation of an external SRAM --------------------------

    sram_chip_addr <= mpu_sram_address(SRAM_ADDR_SIZE downto 1);

    -- FIXME should add some verification of /WE 
    sram_output <=
        sram(conv_integer(unsigned(sram_chip_addr))) when mpu_sram_oe_n='0'
        else (others => 'Z');

    simulated_sram_write:
    process(mpu_sram_byte_we_n, mpu_sram_address, mpu_sram_oe_n)
    begin
        -- Write cycle
        -- FIXME should add OE\ to write control logic
        if mpu_sram_byte_we_n'event or mpu_sram_address'event then
            if mpu_sram_byte_we_n(1)='0' then
                sram(conv_integer(unsigned(sram_chip_addr)))(15 downto 8) := mpu_sram_data_wr(15 downto  8);
            end if;
            if mpu_sram_byte_we_n(0)='0' then
                sram(conv_integer(unsigned(sram_chip_addr)))( 7 downto 0) := mpu_sram_data_wr( 7 downto  0);
            end if;            
        end if;
    end process simulated_sram_write;


    -- Do a very basic simulation of an external PROM (FLASH) ------------------
    -- (wired to the same bus as the sram and both are static).
    
    prom_rd_addr <= mpu_sram_address(PROM_ADDR_SIZE-1 downto 0);
    
    prom_oe_n <= mpu_sram_oe_n;

    simulated_flash:
    if PROM_SIZE > 0 generate    
        prom_output <=
            prom(conv_integer(unsigned(prom_rd_addr))) when prom_oe_n='0' else
            (others => 'Z');
    end generate;    

    unused_flash:
    if PROM_SIZE <= 0 generate    
        prom_output <= (others => 'Z');
    end generate;    
    
    -- Simulate dummy I/O traffic external to the MCU --------------------------
    -- The only IO present is the test interrupt trigger registers and the
    -- debug register block.
    simulated_io:
    process(clk)
    variable i : integer;
    variable uart_data : integer;
    begin
        if clk'event and clk='1' then
            if io_byte_we /= "0000" then
                if io_wr_addr(31 downto 16)=X"2001" then
                    if io_wr_addr(5)='0' then
                        -- IRQ trigger register block (write only)
                        irq_trigger_load <= '1';
                        irq_trigger_data <= io_wr_data;
                        irq_trigger_addr <= io_wr_addr(4 downto 2);
                    else 
                        -- Debug register block (read/write)
                        debug_reg_block(conv_integer(unsigned(io_wr_addr(3 downto 2)))) <= io_wr_data;
                    end if;
                else
                    irq_trigger_load <= '0';
                end if;
            else
                irq_trigger_load <= '0';
            end if;
        end if;
    end process simulated_io;
    
    -- The only readable i/o is the debug reg block. We simulate an asynchronous
    -- read port (a mux). 
    -- For read accesses, this register block is mirrored all over the io 
    --- address space 2001xxxxh.
    io_rd_data <= debug_reg_block(conv_integer(unsigned(io_rd_addr(3 downto 2))));
    
    -- Simulate IRQs -----------------------------------------------------------
    irq_trigger_registers:
    process(clk)
    variable index : integer range 0 to 7;
    begin
        if clk'event and clk='1' then
            if reset='1' then
                cpu_irq <= "00000000";
            else
                if irq_trigger_load='1' then
                    index := conv_integer(irq_trigger_addr);
                    irq_countdown(index) <= irq_trigger_data;
                else
                    for index in 0 to 7 loop
                        if irq_countdown(index) = X"00000001" then
                            cpu_irq(index) <= '1';
                            irq_countdown(index) <= irq_countdown(index) - 1;
                        elsif irq_countdown(index)/=X"00000000" then
                            irq_countdown(index) <= irq_countdown(index) - 1;
                            cpu_irq(index) <= '0';
                        else
                            cpu_irq(index) <= '0';
                        end if;
                    end loop;
                end if;
            end if;
        end if;
    end process irq_trigger_registers;

    
    -- This is useless (the simulated UART will not be actually used)
    -- but at least prevents the simulator from optimizing the logic away.
    rxd <= txd;
    
    
    -- Logging process: launch logger function ---------------------------------
    log_execution:
    process
    begin
        log_cpu_activity(clk, reset, done, 
                         "mips_tb/mpu", "cpu",
                         log_info, "log_info", 
                         LOG_TRIGGER_ADDRESS, log_file, con_file);
        wait;
    end process log_execution;
    
end architecture testbench;
