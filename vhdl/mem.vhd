--  This file is part of the marca processor.
--  Copyright (C) 2007 Wolfgang Puffitsch

--  This program is free software; you can redistribute it and/or modify it
--  under the terms of the GNU Library General Public License as published
--  by the Free Software Foundation; either version 2, or (at your option)
--  any later version.

--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Library General Public License for more details.

--  You should have received a copy of the GNU Library General Public
--  License along with this program; if not, write to the Free Software
--  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

-------------------------------------------------------------------------------
-- MARCA fetch stage
-------------------------------------------------------------------------------
-- architecture for the instruction-fetch pipeline stage
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.marca_pkg.all;
use work.sc_pkg.all;

architecture behaviour of mem is

type WAIT_STATE is (WAIT_LOAD_EVEN,  WAIT_LOAD_ODD,
                    WAIT_LOADL_EVEN, WAIT_LOADL_ODD,
                    WAIT_LOADH_EVEN, WAIT_LOADH_ODD,
                    WAIT_LOADB_EVEN, WAIT_LOADB_ODD,
                    WAIT_STORE,
                    WAIT_NONE);

signal state      : WAIT_STATE;
signal next_state : WAIT_STATE;

signal old_data   : std_logic_vector(REG_WIDTH-1 downto 0);
signal next_data  : std_logic_vector(REG_WIDTH-1 downto 0);

component data_memory
  port (
    clken   : in  std_logic;
    clock   : in  std_logic;
    wren    : in  std_logic;
    address : in  std_logic_vector (ADDR_WIDTH-2 downto 0);
    data    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
    q       : out std_logic_vector (DATA_WIDTH-1 downto 0));
end component;

signal ram_enable : std_logic;

signal wren0 : std_logic;
signal a0 : std_logic_vector(ADDR_WIDTH-2 downto 0);
signal d0 : std_logic_vector(DATA_WIDTH-1 downto 0);
signal q0 : std_logic_vector(DATA_WIDTH-1 downto 0);

signal wren1 : std_logic;
signal a1 : std_logic_vector(ADDR_WIDTH-2 downto 0);
signal d1 : std_logic_vector(DATA_WIDTH-1 downto 0);
signal q1 : std_logic_vector(DATA_WIDTH-1 downto 0);

component data_rom
  generic (
    init_file : string);
  port (
    clken   : in  std_logic;
    clock   : in  std_logic;
    address : in  std_logic_vector (RADDR_WIDTH-2 downto 0);
    q       : out std_logic_vector (RDATA_WIDTH-1 downto 0));
end component;

signal rom_enable : std_logic;

signal ra0 : std_logic_vector(RADDR_WIDTH-2 downto 0);
signal rq0 : std_logic_vector(RDATA_WIDTH-1 downto 0);

signal ra1 : std_logic_vector(RADDR_WIDTH-2 downto 0);
signal rq1 : std_logic_vector(RDATA_WIDTH-1 downto 0);


signal sc_input  : SC_IN;
signal sc_output : SC_OUT;

component sc_uart
  generic (
    clock_freq : integer;
    baud_rate  : integer;
    txf_depth  : integer; txf_thres  : integer;
    rxf_depth  : integer; rxf_thres  : integer);
  port (
    clock  : in  std_logic;
    reset  : in  std_logic;
    input  : in  SC_IN;
    output : out SC_OUT;
    intr   : out std_logic;
    txd    : out std_logic;
    rxd    : in  std_logic;
    nrts   : out std_logic;
    ncts   : in  std_logic);
end component;

signal uart_input  : SC_IN;
signal uart_output : SC_OUT;

begin  -- behaviour

  intrs(VEC_COUNT-1 downto 4) <= (others => '0');
  
  data_memory_0_unit : data_memory
    port map (
      clken     => ram_enable,
      clock     => clock,
      wren      => wren0,
      address   => a0,
      data      => d0,
      q         => q0);

  data_memory_1_unit : data_memory
    port map (
      clken     => ram_enable,
      clock     => clock,
      wren      => wren1,
      address   => a1,
      data      => d1,
      q         => q1);

  data_rom_0_unit : data_rom
    generic map (
      init_file => "../vhdl/rom0.mif")
    port map (
      clken     => rom_enable,
      clock     => clock,
      address   => ra0,
      q         => rq0);

  data_rom_1_unit : data_rom
    generic map (
      init_file => "../vhdl/rom1.mif")
    port map (
      clken     => rom_enable,
      clock     => clock,
      address   => ra1,
      q         => rq1);

  uart_unit : sc_uart
    generic map (
      clock_freq => CLOCK_FREQ,
      baud_rate => UART_BAUD_RATE,
      txf_depth => 2, txf_thres => 1,
      rxf_depth => 2, rxf_thres => 1)
    port map (
      clock => clock,
      reset => reset,
      input => uart_input,
      output => uart_output,
      intr => intrs(UART_INTR),
      txd => ext_out(UART_TXD),
      rxd => ext_in(UART_RXD),
      nrts => ext_out(UART_NRTS),
      ncts => ext_in(UART_NCTS));
  
  syn_proc: process (clock, reset)
  begin  -- process syn_proc
    if reset = RESET_ACTIVE then                 -- asynchronous reset (active low)
      state <= WAIT_NONE;
      old_data <= (others => '0');
    elsif clock'event and clock = '1' then  -- rising clock edge
      state <= next_state;
      old_data <= next_data;
    end if;
  end process syn_proc;

  business: process (next_state)
  begin  -- process business
    if next_state /= WAIT_NONE then
      busy <= '1';
    else
      busy <= '0';
    end if;
  end process business;

  sc_mux: process (address, sc_input,
                   uart_output)
  begin  -- process sc_mux

    uart_input <= SC_IN_NULL;
    sc_output  <= SC_OUT_NULL;
    
    case address(REG_WIDTH-1 downto SC_ADDR_WIDTH+1) is
      when UART_BASE_ADDR =>
        uart_input <= sc_input;
        sc_output <= uart_output;
      when others => null;
    end case;
    
  end process sc_mux;
  
  readwrite: process (state, op, address, data, old_data, q0, q1, rq0, rq1, sc_output)
  begin  -- process readwrite
    exc <= '0';

    ram_enable <= '0';
    
    wren0 <= '0';
    wren1 <= '0';

    a0 <= (others => '0');
    d0 <= (others => '0');

    a1 <= (others => '0');
    d1 <= (others => '0');

    rom_enable <= '0';

    ra0 <= (others => '0');
    ra1 <= (others => '0');
    
    sc_input <= SC_IN_NULL;
    
    result <= (others => '0');
    
    next_state <= WAIT_NONE;
    next_data <= data;
    
    if unsigned(address) >= unsigned(MEM_MIN_ADDR)
      and unsigned(address) <= unsigned(MEM_MAX_ADDR) then
      
      -- regular memory access
      if op /= MEM_NOP then
        ram_enable <= '1';
      end if;
      
      case state is
        when WAIT_LOAD_EVEN => result(REG_WIDTH-1 downto REG_WIDTH/2) <= q1;
                               result(REG_WIDTH/2-1 downto 0) <= q0;
                               next_state <= WAIT_NONE;
                               
        when WAIT_LOAD_ODD => result(REG_WIDTH-1 downto REG_WIDTH/2) <= q0;
                              result(REG_WIDTH/2-1 downto 0) <= q1;
                              next_state <= WAIT_NONE;
                              
        when WAIT_LOADL_EVEN => result(REG_WIDTH-1 downto REG_WIDTH/2) <= old_data(REG_WIDTH-1 downto REG_WIDTH/2);
                                result(REG_WIDTH/2-1 downto 0) <= q0;
                                next_state <= WAIT_NONE;
                                
        when WAIT_LOADL_ODD => result(REG_WIDTH-1 downto REG_WIDTH/2) <= old_data(REG_WIDTH-1 downto REG_WIDTH/2);
                               result(REG_WIDTH/2-1 downto 0) <= q1;
                               next_state <= WAIT_NONE;

        when WAIT_LOADH_EVEN => result(REG_WIDTH-1 downto REG_WIDTH/2) <= q0;
                                result(REG_WIDTH/2-1 downto 0) <= old_data(REG_WIDTH/2-1 downto 0);
                                next_state <= WAIT_NONE;
                                
        when WAIT_LOADH_ODD => result(REG_WIDTH-1 downto REG_WIDTH/2) <= q1;
                               result(REG_WIDTH/2-1 downto 0) <= old_data(REG_WIDTH/2-1 downto 0);
                               next_state <= WAIT_NONE;

        when WAIT_LOADB_EVEN => result <= std_logic_vector(resize(signed(q0), REG_WIDTH));
                                next_state <= WAIT_NONE;
                                
        when WAIT_LOADB_ODD => result <= std_logic_vector(resize(signed(q1), REG_WIDTH));
                               next_state <= WAIT_NONE;
                               
        when WAIT_NONE =>
          case op is
            when MEM_LOAD => if address(0) = '0' then
                               a0 <= address(ADDR_WIDTH-1 downto 1);
                               a1 <= address(ADDR_WIDTH-1 downto 1);
                               next_state <= WAIT_LOAD_EVEN;                         
                             else
                               a1 <= address(ADDR_WIDTH-1 downto 1);
                               a0 <= std_logic_vector(unsigned(address(ADDR_WIDTH-1 downto 1)) + 1);
                               next_state <= WAIT_LOAD_ODD;
                             end if;
            when MEM_LOADL => if address(0) = '0' then
                                a0 <= address(ADDR_WIDTH-1 downto 1);
                                next_state <= WAIT_LOADL_EVEN;
                              else
                                a1 <= address(ADDR_WIDTH-1 downto 1);
                                next_state <= WAIT_LOADL_ODD;
                              end if;
            when MEM_LOADH => if address(0) = '0' then
                                a0 <= address(ADDR_WIDTH-1 downto 1);
                                next_state <= WAIT_LOADH_EVEN;
                              else
                                a1 <= address(ADDR_WIDTH-1 downto 1);
                                next_state <= WAIT_LOADH_ODD;
                              end if;
            when MEM_LOADB => if address(0) = '0' then
                                a0 <= address(ADDR_WIDTH-1 downto 1);
                                next_state <= WAIT_LOADB_EVEN;
                              else
                                a1 <= address(ADDR_WIDTH-1 downto 1);
                                next_state <= WAIT_LOADB_ODD;
                              end if;
            when MEM_STORE => if address(0) = '0' then
                                wren0 <= '1';
                                wren1 <= '1';
                                a0 <= address(ADDR_WIDTH-1 downto 1);
                                a1 <= address(ADDR_WIDTH-1 downto 1);
                                d0 <= data(REG_WIDTH/2-1 downto 0);
                                d1 <= data(REG_WIDTH-1 downto REG_WIDTH/2);
                                next_state <= WAIT_NONE;
                              else
                                wren0 <= '1';
                                wren1 <= '1';
                                a1 <= address(ADDR_WIDTH-1 downto 1);
                                a0 <= std_logic_vector(unsigned(address(ADDR_WIDTH-1 downto 1)) + 1);
                                d1 <= data(REG_WIDTH/2-1 downto 0);
                                d0 <= data(REG_WIDTH-1 downto REG_WIDTH/2);
                                next_state <= WAIT_NONE;
                              end if;
            when MEM_STOREL => if address(0) = '0' then
                                 wren0 <= '1';
                                 a0 <= address(ADDR_WIDTH-1 downto 1);
                                 d0 <= data(REG_WIDTH/2-1 downto 0);
                                 next_state <= WAIT_NONE;
                               else
                                 wren1 <= '1';
                                 a1 <= address(ADDR_WIDTH-1 downto 1);
                                 d1 <= data(REG_WIDTH/2-1 downto 0);
                                 next_state <= WAIT_NONE;
                               end if;
            when MEM_STOREH => if address(0) = '0' then
                                 wren0 <= '1';
                                 a0 <= address(ADDR_WIDTH-1 downto 1);
                                 d0 <= data(REG_WIDTH-1 downto REG_WIDTH/2);
                                 next_state <= WAIT_NONE;
                               else
                                 wren1 <= '1';
                                 a1 <= address(ADDR_WIDTH-1 downto 1);
                                 d1 <= data(REG_WIDTH-1 downto REG_WIDTH/2);
                                 next_state <= WAIT_NONE;
                               end if;
            when MEM_NOP => next_state <= WAIT_NONE;
            when others => null;
          end case;
        when others => null;
      end case;

    elsif unsigned(address) >= unsigned(ROM_MIN_ADDR)
      and unsigned(address) <= unsigned(ROM_MAX_ADDR) then

      -- accessing the ROM
      if op /= MEM_NOP then
        rom_enable <= '1';
      end if;
    
      case state is
        when WAIT_LOAD_EVEN => result(REG_WIDTH-1 downto REG_WIDTH/2) <= rq1;
                               result(REG_WIDTH/2-1 downto 0) <= rq0;
                               next_state <= WAIT_NONE;
                               
        when WAIT_LOAD_ODD => result(REG_WIDTH-1 downto REG_WIDTH/2) <= rq0;
                              result(REG_WIDTH/2-1 downto 0) <= rq1;
                              next_state <= WAIT_NONE;
                              
        when WAIT_LOADL_EVEN => result(REG_WIDTH-1 downto REG_WIDTH/2) <= old_data(REG_WIDTH-1 downto REG_WIDTH/2);
                                result(REG_WIDTH/2-1 downto 0) <= rq0;
                                next_state <= WAIT_NONE;
                                
        when WAIT_LOADL_ODD => result(REG_WIDTH-1 downto REG_WIDTH/2) <= old_data(REG_WIDTH-1 downto REG_WIDTH/2);
                               result(REG_WIDTH/2-1 downto 0) <= rq1;
                               next_state <= WAIT_NONE;

        when WAIT_LOADH_EVEN => result(REG_WIDTH-1 downto REG_WIDTH/2) <= rq0;
                                result(REG_WIDTH/2-1 downto 0) <= old_data(REG_WIDTH/2-1 downto 0);
                                next_state <= WAIT_NONE;
                                
        when WAIT_LOADH_ODD => result(REG_WIDTH-1 downto REG_WIDTH/2) <= rq1;
                               result(REG_WIDTH/2-1 downto 0) <= old_data(REG_WIDTH/2-1 downto 0);
                               next_state <= WAIT_NONE;

        when WAIT_LOADB_EVEN => result <= std_logic_vector(resize(signed(rq0), REG_WIDTH));
                                next_state <= WAIT_NONE;
                                
        when WAIT_LOADB_ODD => result <= std_logic_vector(resize(signed(rq1), REG_WIDTH));
                               next_state <= WAIT_NONE;
                               
        when WAIT_NONE =>
          case op is
            when MEM_LOAD => if address(0) = '0' then
                               ra0 <= address(RADDR_WIDTH-1 downto 1);
                               ra1 <= address(RADDR_WIDTH-1 downto 1);
                               next_state <= WAIT_LOAD_EVEN;                         
                             else
                               ra1 <= address(RADDR_WIDTH-1 downto 1);
                               ra0 <= std_logic_vector(unsigned(address(RADDR_WIDTH-1 downto 1)) + 1);
                               next_state <= WAIT_LOAD_ODD;
                             end if;
            when MEM_LOADL => if address(0) = '0' then
                                ra0 <= address(RADDR_WIDTH-1 downto 1);
                                next_state <= WAIT_LOADL_EVEN;
                              else
                                ra1 <= address(RADDR_WIDTH-1 downto 1);
                                next_state <= WAIT_LOADL_ODD;
                              end if;
            when MEM_LOADH => if address(0) = '0' then
                                ra0 <= address(RADDR_WIDTH-1 downto 1);
                                next_state <= WAIT_LOADH_EVEN;
                              else
                                ra1 <= address(RADDR_WIDTH-1 downto 1);
                                next_state <= WAIT_LOADH_ODD;
                              end if;
            when MEM_LOADB => if address(0) = '0' then
                                ra0 <= address(RADDR_WIDTH-1 downto 1);
                                next_state <= WAIT_LOADB_EVEN;
                              else
                                ra1 <= address(RADDR_WIDTH-1 downto 1);
                                next_state <= WAIT_LOADB_ODD;
                              end if;
            when MEM_NOP => next_state <= WAIT_NONE;
            when others => exc <= '1';  -- inhibit invalid operations
          end case;
        when others => null;
      end case;      

    elsif unsigned(address) >= unsigned(SC_MIN_ADDR)
      and unsigned(address) <= unsigned(SC_MAX_ADDR)
      and address(0) = '0' then
      
      -- access via SimpCon interface
      case state is
        
        when WAIT_LOAD_EVEN =>
          if sc_output.rdy_cnt /= "00" then
            next_state <= WAIT_LOAD_EVEN;
          else
            result <= sc_output.rd_data;
            next_state <= WAIT_NONE;
          end if;          
          
        when WAIT_STORE =>
          if sc_output.rdy_cnt /= "00" then
            next_state <= WAIT_STORE;
          else
            next_state <= WAIT_NONE;
          end if;          
          
        when WAIT_NONE =>
          case op is
            
            when MEM_LOAD =>
              sc_input.address <= address(SC_ADDR_WIDTH downto 1);
              sc_input.wr      <= '0';
              sc_input.wr_data <= (others => '0');
              sc_input.rd      <= '1';
              next_state <= WAIT_LOAD_EVEN;

            when MEM_STORE =>
              sc_input.address <= address(SC_ADDR_WIDTH downto 1);
              sc_input.wr      <= '1';
              sc_input.wr_data <= data;
              sc_input.rd      <= '0';
              next_state <= WAIT_STORE;
              
            when MEM_NOP => next_state <= WAIT_NONE;
                            
            when others => exc <= '1';   -- inhibit invalid operations
                             
          end case;
        when others => null;
      end case;

    else
      -- invalid address and/or alignment
      if op /= MEM_NOP then
        exc <= '1';
      end if;
    end if;   
    
  end process readwrite;
  
end behaviour;
