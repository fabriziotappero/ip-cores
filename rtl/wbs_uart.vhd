--------------------------------------------------------------------------------
-- This sourcecode is released under BSD license.
-- Please see http://www.opensource.org/licenses/bsd-license.php for details!
--------------------------------------------------------------------------------
--
-- Copyright (c) 2010, Stefan Fischer <Ste.Fis@OpenCores.org>
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without 
-- modification, are permitted provided that the following conditions are met:
--
--  * Redistributions of source code must retain the above copyright notice, 
--    this list of conditions and the following disclaimer.
--  * Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
-- POSSIBILITY OF SUCH DAMAGE.
--
--------------------------------------------------------------------------------
-- filename: wbs_uart.vhd
-- description: synthesizable wishbone slave uart sio module using Xilinx (R)
--              macros and adding some functionality like a configurable 
--              baud rate and buffer level checking 
-- todo4user: add other uart functionality as needed, i. e. interrupt logic or
--            modem control signals
-- version: 0.0.0
-- changelog: - 0.0.0, initial release
--            - ...
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity wbs_uart is
  port
  (
    rst : in std_logic;
    clk : in std_logic;
    
    wbs_cyc_i : in std_logic;
    wbs_stb_i : in std_logic;
    wbs_we_i : in std_logic;
    wbs_adr_i : in std_logic_vector(7 downto 0);
    wbs_dat_m2s_i : in std_logic_vector(7 downto 0);
    wbs_dat_s2m_o : out std_logic_vector(7 downto 0);
    wbs_ack_o : out std_logic;
    
    uart_rx_si_i : in std_logic;
    uart_tx_so_o : out std_logic
  );
end wbs_uart;


architecture rtl of wbs_uart is

  signal wbs_dat_s2m : std_logic_vector(7 downto 0) := (others => '0');
  signal wbs_ack : std_logic := '0';
  
  signal uart_tx_so : std_logic := '0';
  
  signal wb_reg_we : std_logic := '0';
      
  constant ADDR_MSB : natural := 1;
  constant UART_RXTX_ADDR : std_logic_vector(7 downto 0) := x"00";
  constant UART_SR_ADDR : std_logic_vector(7 downto 0) := x"01";
  constant UART_SR_RX_F_FLAG : natural := 0;
  constant UART_SR_RX_HF_FLAG : natural := 1;
  constant UART_SR_RX_DP_FLAG : natural := 2;
  constant UART_SR_TX_F_FLAG : natural := 4;
  constant UART_SR_TX_HF_FLAG : natural := 5;
  constant UART_BAUD_LO_ADDR : std_logic_vector(7 downto 0) := x"02";
  constant UART_BAUD_HI_ADDR : std_logic_vector(7 downto 0) := x"03";
  
  signal baud_count : std_logic_vector(15 downto 0) := (others => '0');
  signal baud_limit : std_logic_vector(15 downto 0) := (others => '0');
  
  signal en_16_x_baud : std_logic := '0';
  
  component uart_rx is
    port 
    (
      serial_in : in std_logic;
      data_out : out std_logic_vector(7 downto 0);
      read_buffer : in std_logic;
      reset_buffer : in std_logic;
      en_16_x_baud : in std_logic;
      buffer_data_present : out std_logic;
      buffer_full : out std_logic;
      buffer_half_full : out std_logic;
      clk : in std_logic
    );
  end component;
  
  signal rx_read_buffer : std_logic := '0';
  signal rx_buffer_full : std_logic := '0';
  signal rx_buffer_half_full : std_logic := '0';
  signal rx_buffer_data_present : std_logic := '0';
  signal rx_data_out : std_logic_vector(7 downto 0) := (others => '0');

  component uart_tx is
    port 
    (
      data_in : in std_logic_vector(7 downto 0);
      write_buffer : in std_logic;
      reset_buffer : in std_logic;
      en_16_x_baud : in std_logic;
      serial_out : out std_logic;
      buffer_full : out std_logic;
      buffer_half_full : out std_logic;
      clk : in std_logic
    );
  end component;
  
  signal tx_write_buffer : std_logic := '0';
  signal tx_buffer_full : std_logic := '0';
  signal tx_buffer_half_full : std_logic := '0';

begin

  wbs_dat_s2m_o <= wbs_dat_s2m;
  wbs_ack_o <= wbs_ack;
  
  uart_tx_so_o <= uart_tx_so;
  
  -- internal register write enable signal
  wb_reg_we <= wbs_cyc_i and wbs_stb_i and wbs_we_i;
 
  process(clk) 
  begin
    if clk'event and clk = '1' then

      -- baud rate configuration:
      -- baud_limit = round( system clock frequency / (16 * baud rate) ) - 1
      -- i. e. 9600 baud at 50 MHz system clock =>
      -- baud_limit = round( 50.0E6 / (16 * 9600) ) - 1 = 325 = 0x0145

      -- baud timer
      if baud_count = baud_limit then
        baud_count <= (others => '0');
        en_16_x_baud <= '1';
      else
        baud_count <= std_logic_vector(unsigned(baud_count) + 1);
        en_16_x_baud <= '0';
      end if;

      rx_read_buffer <= '0';
      tx_write_buffer <= '0';
    
      wbs_dat_s2m <= (others => '0');
      -- registered wishbone slave handshake (default)
      wbs_ack <= wbs_cyc_i and wbs_stb_i and (not wbs_ack);
      
      case wbs_adr_i(ADDR_MSB downto 0) is
        -- receive/transmit buffer access
        when UART_RXTX_ADDR(ADDR_MSB downto 0) =>
          if (wbs_cyc_i and wbs_stb_i) = '1' then
            -- overwriting wishbone slave handshake for blocking transactions 
            -- to rx/tx fifos by using buffer status flags
            if wbs_we_i = '1' then
              tx_write_buffer <= (not tx_buffer_full) and (not wbs_ack);
              wbs_ack <= (not tx_buffer_full) and (not wbs_ack);
            else
              rx_read_buffer <= rx_buffer_data_present and (not wbs_ack);
              wbs_ack <= rx_buffer_data_present and (not wbs_ack);
            end if;
          end if;
          wbs_dat_s2m <= rx_data_out;
        -- status register access
        when UART_SR_ADDR(ADDR_MSB downto 0) =>
          wbs_dat_s2m(UART_SR_RX_F_FLAG) <= rx_buffer_full;
          wbs_dat_s2m(UART_SR_RX_HF_FLAG) <= rx_buffer_half_full;
          wbs_dat_s2m(UART_SR_RX_DP_FLAG) <= rx_buffer_data_present;
          wbs_dat_s2m(UART_SR_TX_F_FLAG) <= tx_buffer_full;
          wbs_dat_s2m(UART_SR_TX_HF_FLAG) <= tx_buffer_half_full;
        -- baud rate register access / low byte
        when UART_BAUD_LO_ADDR(ADDR_MSB downto 0) =>
          if wb_reg_we = '1' then
            baud_limit(7 downto 0) <= wbs_dat_m2s_i;
            baud_count <= (others => '0');
          end if;
          wbs_dat_s2m <= baud_limit(7 downto 0);
        -- baud rate register access / high byte
        when UART_BAUD_HI_ADDR(ADDR_MSB downto 0) =>
          if wb_reg_we = '1' then
            baud_limit(15 downto 8) <= wbs_dat_m2s_i;
            baud_count <= (others => '0');
          end if;
          wbs_dat_s2m <= baud_limit(15 downto 8);
        when others => null;
      end case;
    
      if rst = '1' then
        wbs_ack <= '0';
      end if;
    
    end if;
  end process;
  
  -- Xilinx (R) uart macro instances
  ----------------------------------
  
  inst_uart_rx : uart_rx
    port map
    (
      serial_in => uart_rx_si_i,
      data_out => rx_data_out,
      read_buffer => rx_read_buffer,
      reset_buffer => rst,
      en_16_x_baud => en_16_x_baud,
      buffer_data_present => rx_buffer_data_present,
      buffer_full => rx_buffer_full,
      buffer_half_full => rx_buffer_half_full,
      clk => clk
    );

  inst_uart_tx : uart_tx
    port map
    (
      data_in => wbs_dat_m2s_i,
      write_buffer => tx_write_buffer,
      reset_buffer => rst,
      en_16_x_baud => en_16_x_baud,
      serial_out => uart_tx_so,
      buffer_full => tx_buffer_full,
      buffer_half_full => tx_buffer_half_full,
      clk => clk
    );

end rtl;
