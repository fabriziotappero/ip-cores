----------------------------------------------------------------------
----                                                              ----
---- WISHBONE GPU IP Core                                         ----
----                                                              ----
---- This file is part of the GPU project                         ----
---- http://www.opencores.org/project,gpu                         ----
----                                                              ----
---- Description                                                  ----
---- Implementation of GPU IP core according to                   ----
---- GPU IP core specification document.                          ----
----                                                              ----
---- Author:                                                      ----
----     - Diego A. González Idárraga, diegoandres91b@hotmail.com ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2009 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pfloat_pkg.all;
use work.core_pkg.all;

entity gpu is
    generic(
        INSTRUCTION_SLAVE_ADDRESS_WIDTH : natural range 0 to 32 := 12
    );
    port(
        clk   : in std_logic;
        reset : in std_logic;
        
        avs_control_slave_read      : in  std_logic;
        avs_control_slave_readdata  : out std_logic_vector(7 downto 0);
        avs_control_slave_write     : in  std_logic;
        avs_control_slave_writedata : in  std_logic_vector(7 downto 0);
        
        avs_instruction_slave_address   : in std_logic_vector(INSTRUCTION_SLAVE_ADDRESS_WIDTH-1 downto 0);
        avs_instruction_slave_write     : in std_logic;
        avs_instruction_slave_writedata : in std_logic_vector(31 downto 0);
        
        avm_data_master_address     : out    std_logic_vector(31 downto 0);
        avm_data_master_read        : buffer std_logic;
        avm_data_master_readdata    : in     std_logic_vector(31 downto 0);
        avm_data_master_write       : buffer std_logic;
        avm_data_master_writedata   : out    std_logic_vector(31 downto 0);
        avm_data_master_waitrequest : in     std_logic;
        
        ins_irq : out std_logic
    );
end entity;

architecture rtl of gpu is
    type memory_t is array(0 to 2**INSTRUCTION_SLAVE_ADDRESS_WIDTH-1) of std_logic_vector(31 downto 0);
    
    signal control     : std_logic_vector(1 downto 0);
    signal cke         : std_logic;
    signal memory      : memory_t;
    signal pc          : unsigned(31 downto 0);
    signal instruction : std_logic_vector(31 downto 0);
    signal address     : unsigned(31 downto 0);
    signal read        : std_logic;
    signal write       : std_logic;
    signal stop_core   : std_logic;
    signal irq         : std_logic;
begin
    -- control signal process
    process(clk, reset,
            avs_control_slave_read, avs_control_slave_write, avs_control_slave_writedata,
            control, stop_core, irq)
    begin
        if reset = '1' then
            avs_control_slave_readdata(1 downto 0) <= (others=> '0');
        elsif rising_edge(clk) and (avs_control_slave_read = '1') then
            avs_control_slave_readdata(1 downto 0) <= control;
        end if;
        
        avs_control_slave_readdata(7 downto 2) <= (others=> '0');
        
        if reset = '1' then
            control <= (others=> '0');
        elsif rising_edge(clk) then
            if stop_core = '1' then
                control(0) <= '0';
            end if;
            
            if irq = '1' then
                control(1) <= '1';
            end if;
            
            if avs_control_slave_write = '1' then
                control <= avs_control_slave_writedata(1 downto 0);
            end if;
        end if;
    end process;
    
    -- cke signal process
    process(avm_data_master_read, avm_data_master_write, avm_data_master_waitrequest,
            control)
    begin
        if ((avm_data_master_read = '1') and (avm_data_master_waitrequest = '1')) or
           ((avm_data_master_write = '1') and (avm_data_master_waitrequest = '1')) then
            cke <= '0';
        else
            cke <= control(0);
        end if;
    end process;
    
    -- program memory process
    process(clk, reset,
            avs_instruction_slave_address, avs_instruction_slave_write, avs_instruction_slave_writedata,
            cke, memory, pc)
    begin
        if reset = '1' then
            instruction <= (others=> '0');
        elsif rising_edge(clk) and (cke = '1') then
            instruction <= memory(to_integer(pc));
        end if;
        
        if rising_edge(clk) and (avs_instruction_slave_write = '1') then
            memory(to_integer(unsigned(avs_instruction_slave_address))) <= avs_instruction_slave_writedata;
        end if;
    end process;
    
    -- core
    avm_data_master_address <= std_logic_vector(address);
    avm_data_master_read <= control(0) and read;
    avm_data_master_write <= control(0) and write;
    u0 : core
    generic map(
        USE_SUBNORMAL=>       false,
        ROUND_STYLE=>         round_to_nearest,
        DEDICATED_REGISTERS=> false,
        LATENCY_1=>           false,
        FADD_LATENCY=>        2,
        EMBEDDED_MULTIPLIER=> true,
        FMUL_LATENCY=>        2,
        FDIV_LATENCY=>        10,
        FCOMP_LATENCY=>       0
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        pc=>          pc,
        instruction=> instruction,
        
        address=>   address,
        read=>      read,
        readdata=>  avm_data_master_readdata,
        write=>     write,
        writedata=> avm_data_master_writedata,
        
        stop_core=> stop_core,
        irq=>       irq
    );
    
    -- ins_irq
    ins_irq <= control(1);
end architecture;