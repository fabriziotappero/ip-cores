------------------------------------------------------------------
-- PROJECT:     HiCoVec (highly configurable vector processor)
--
-- ENTITY:      system
--
-- PURPOSE:     top level module of processor
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.cfg.all;
use work.datatypes.all;

entity system is
     port(
        clk: in std_logic;
        reset: in std_logic;
        
        rs232_txd: out std_logic; 
        rs232_rxd: in std_logic
     );
end system;

architecture rtl of system is
    
    component cpu
        port(
            clk: in std_logic;
            reset: in std_logic;
            dbg_a: out std_logic_vector(31 downto 0);
            dbg_x: out std_logic_vector(31 downto 0);
            dbg_y: out std_logic_vector(31 downto 0);
            dbg_ir: out std_logic_vector(31 downto 0);
            dbg_ic: out std_logic_vector(31 downto 0);
            dbg_carry: out std_logic;
            dbg_zero: out std_logic;
            dbg_ir_ready: out std_logic;
            dbg_halted: out std_logic;
            mem_data_in: in std_logic_vector(31 downto 0);
            mem_data_out: out std_logic_vector(31 downto 0);
            mem_vdata_in: in vectordata_type;
            mem_vdata_out: out vectordata_type;
            mem_address: out std_logic_vector(31 downto 0);
            mem_access: out std_logic_vector(2 downto 0);
            mem_ready: in std_logic
         );
    end component;
    
    component memoryinterface
        port (   
            clk:            in  std_logic;
            address:        in  std_logic_vector(31 downto 0) := (others => '0'); 
            access_type:    in  std_logic_vector(2 downto 0) := "000"; -- we, oe, cs
            data_in:        in  std_logic_vector(31 downto 0);
            vdata_in:       in  vectordata_type;
            data_out:       out std_logic_vector(31 downto 0);
            vdata_out:      out vectordata_type;
            ready:          out std_logic;
            we:             out std_logic;
            en:             out std_logic;
            addr:           out std_logic_vector(31 downto 0);
            di:             out std_logic_vector(31 downto 0);
            do:             in std_logic_vector(31 downto 0)
        );
    end component;
    
    component debugger
        port ( 
            clk_in: in std_logic;
            clk_cpu: out std_logic;         
            clk_mem: out std_logic;
            reset_out: out std_logic;    
            rs232_txd: out std_logic; 
            rs232_rxd: in std_logic;
            a: in std_logic_vector(31 downto 0);
            x: in std_logic_vector(31 downto 0);
            y: in std_logic_vector(31 downto 0);
            ir: in std_logic_vector(31 downto 0);
            ic: in std_logic_vector(31 downto 0);
            mem_switch: out std_logic;
            mem_ready: in std_logic;
            mem_access: in std_logic_vector(2 downto 0);
            mem_access_dbg: out std_logic_vector(2 downto 0);
            mem_addr: in std_logic_vector(31 downto 0);
            mem_addr_dbg: out std_logic_vector(31 downto 0);
            mem_data: in std_logic_vector(31 downto 0);
            mem_data_dbg: out std_logic_vector(31 downto 0);
            carry: in std_logic;
            zero: in std_logic;
            ir_ready: in std_logic;
            halted: in std_logic
        );
    end component;
    
    component sram
        port (
            clk : in std_logic;
            we : in std_logic;
            en : in std_logic;
            addr : in std_logic_vector(31 downto 0);
            di : in std_logic_vector(31 downto 0);
            do : out std_logic_vector(31 downto 0)
        );    
    end component;
    
    for sram_impl:              sram                use entity work.sram(rtl);
    for cpu_impl:               cpu                 use entity work.cpu(rtl);
    for memoryinterface_impl:   memoryinterface     use entity work.memoryinterface(rtl);
    for debugger_impl:          debugger            use entity work.debugger(rtl);
   
    
    -- sram signals
    signal we, en: std_logic;
    signal addr, di, do: std_logic_vector(31 downto 0);
    
    -- debugger signals
    signal clk_cpu:         std_logic;
    signal clk_mem:         std_logic;
    signal reset_cpu:       std_logic;
    signal mem_switch:      std_logic;
    
    -- cpu signals
    signal dbg_a, dbg_x, dbg_y, dbg_ir, dbg_ic: std_logic_vector(31 downto 0);
    signal dbg_carry, dbg_zero, dbg_ir_ready, dbg_halted: std_logic;
    
    -- memory interface signals
    signal mem_access, mem_access_cpu, mem_access_dbg: std_logic_vector(2 downto 0);
    signal mem_address, mem_address_cpu, mem_address_dbg: std_logic_vector(31 downto 0);
    signal mem_data_out, mem_data_out_cpu, mem_data_out_dbg: std_logic_vector(31 downto 0);
    
    signal mem_data_in: std_logic_vector(31 downto 0);
    signal mem_vdata_in, mem_vdata_out: vectordata_type;
    signal mem_ready: std_logic;
    
    -- attributes for xilinx synthesis tool
    attribute clock_signal : string;
    attribute clock_signal of "clk" : signal is "yes"; 
    attribute clock_signal of "clk_cpu" : signal is "yes"; 

begin
    -- include debugger
    debugger_gen: if use_debugger generate
        debugger_impl: debugger
            port map (
                clk_in => clk, clk_cpu => clk_cpu, clk_mem => clk_mem, reset_out => reset_cpu,
                rs232_txd => rs232_txd, rs232_rxd => rs232_rxd, a => dbg_a, x => dbg_x, y => dbg_y, ir => 
                dbg_ir, ic => dbg_ic, mem_switch => mem_switch, mem_ready  => mem_ready, mem_access =>
                mem_access_cpu, mem_access_dbg => mem_access_dbg, mem_addr => mem_address_cpu,
                mem_addr_dbg => mem_address_dbg, mem_data => mem_data_in, mem_data_dbg => mem_data_out_dbg,
                carry => dbg_carry, zero => dbg_zero, ir_ready => dbg_ir_ready, halted => dbg_halted
            );
        
        -- allow memory access from debugger unit
        mem_access <= mem_access_cpu when mem_switch = '0' else mem_access_dbg; 
        mem_address <= mem_address_cpu when mem_switch = '0' else mem_address_dbg; 
        mem_data_out <= mem_data_out_cpu when mem_switch = '0' else mem_data_out_dbg; 
    end generate;
    
    -- dont include debugger
    not_debugger_gen: if not use_debugger generate
        reset_cpu <= reset;
        clk_cpu <= clk;
        
        -- allow memory access only from cpu
        mem_access <= mem_access_cpu;
        mem_address <= mem_address_cpu;
        mem_data_out <= mem_data_out_cpu;
    end generate;
    
    cpu_impl: cpu
        port map (
            clk => clk_cpu, reset => reset_cpu, dbg_a => dbg_a, dbg_x => dbg_x, dbg_y => dbg_y,
            dbg_ir => dbg_ir, dbg_ic => dbg_ic, dbg_carry => dbg_carry, dbg_zero => dbg_zero,
            dbg_ir_ready => dbg_ir_ready, dbg_halted => dbg_halted, mem_data_in => mem_data_in,
            mem_data_out => mem_data_out_cpu, mem_vdata_in => mem_vdata_in, mem_vdata_out => mem_vdata_out,
            mem_address => mem_address_cpu, mem_access => mem_access_cpu,  mem_ready => mem_ready
        );
    
    
    memoryinterface_impl: memoryinterface 
        port map (
            clk => clk_mem, address => mem_address, access_type => mem_access, data_in => mem_data_out,
            vdata_in => mem_vdata_out, data_out => mem_data_in, vdata_out => mem_vdata_in, ready => mem_ready,
            we => we, en => en, addr => addr, di => di, do => do
        );
    
    sram_impl: sram
        port map (
            clk => clk_mem, we => we, en => en, addr => addr, di => di, do => do
        );
    
end;

