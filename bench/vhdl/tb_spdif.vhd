----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- Top-level testbench for both receiver and transmitter.       ----
---- Output from the transmitter is connected to input of recevier----
---- and checking is done on data transfer and channel status     ----
---- capture.                                                     ----
----                                                              ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Geir Drange, gedra@opencores.org                           ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2004 Authors and OPENCORES.ORG                 ----
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
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
-- Revision 1.1  2004/07/19 16:58:01  gedra
-- Top level testbench for transmitter and receiver.
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use work.wb_tb_pack.all;

entity tb_spdif is

end tb_spdif;

architecture behav of tb_spdif is

   component rx_spdif is
      generic (DATA_WIDTH    : integer range 16 to 32;
               ADDR_WIDTH    : integer range 8 to 64;
               CH_ST_CAPTURE : integer range 0 to 8;
               WISHBONE_FREQ : natural);
      port (
         -- Wishbone interface
         wb_clk_i   : in  std_logic;
         wb_rst_i   : in  std_logic;
         wb_sel_i   : in  std_logic;
         wb_stb_i   : in  std_logic;
         wb_we_i    : in  std_logic;
         wb_cyc_i   : in  std_logic;
         wb_bte_i   : in  std_logic_vector(1 downto 0);
         wb_cti_i   : in  std_logic_vector(2 downto 0);
         wb_adr_i   : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
         wb_dat_i   : in  std_logic_vector(DATA_WIDTH -1 downto 0);
         wb_ack_o   : out std_logic;
         wb_dat_o   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
         -- Interrupt line
         rx_int_o   : out std_logic;
         -- SPDIF input signal
         spdif_rx_i : in  std_logic);
   end component;

   component tx_spdif
      generic (DATA_WIDTH    : integer range 16 to 32;
               ADDR_WIDTH    : integer range 8 to 64;
               USER_DATA_BUF : integer range 0 to 1;
               CH_STAT_BUF   : integer range 0 to 1);
      port (
         -- Wishbone interface
         wb_clk_i   : in  std_logic;
         wb_rst_i   : in  std_logic;
         wb_sel_i   : in  std_logic;
         wb_stb_i   : in  std_logic;
         wb_we_i    : in  std_logic;
         wb_cyc_i   : in  std_logic;
         wb_bte_i   : in  std_logic_vector(1 downto 0);
         wb_cti_i   : in  std_logic_vector(2 downto 0);
         wb_adr_i   : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
         wb_dat_i   : in  std_logic_vector(DATA_WIDTH -1 downto 0);
         wb_ack_o   : out std_logic;
         wb_dat_o   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
         -- Interrupt line
         tx_int_o   : out std_logic;
         -- SPDIF output signal
         spdif_tx_o : out std_logic);
   end component;

   signal wb_clk_o, wb_rst_o, wb_sel_o, wb_stb_o, wb_we_o : std_logic;
   signal wb_cyc_o, wb_ack_i, rx_int_o, spdif_signal      : std_logic;
   signal tx_int_o, tx_ack, rx_ack                        : std_logic;
   signal wb_bte_o                                        : std_logic_vector(1 downto 0);
   signal wb_cti_o                                        : std_logic_vector(2 downto 0);
   signal wb_adr_o                                        : std_logic_vector(15 downto 0);
   signal wb_dat_i, wb_dat_o, rx_dat_i, tx_dat_i          : std_logic_vector(31 downto 0);
   signal wb_stb_32bit_rx, wb_stb_32bit_tx                : std_logic;
   constant RX_VERSION                                    : natural := 16#1000#;
   constant RX_CONFIG                                     : natural := 16#1001#;
   constant RX_STATUS                                     : natural := 16#1002#;
   constant RX_INTMASK                                    : natural := 16#1003#;
   constant RX_INTSTAT                                    : natural := 16#1004#;
   constant RX_CHSTCAP0                                   : natural := 16#1010#;
   constant RX_CHSTDAT0                                   : natural := 16#1011#;
   constant RX_CHSTCAP1                                   : natural := 16#1012#;
   constant RX_CHSTDAT1                                   : natural := 16#1013#;
   constant RX_BUF_BASE                                   : natural := 16#1080#;
   constant TX_VERSION                                    : natural := 16#2000#;
   constant TX_CONFIG                                     : natural := 16#2001#;
   constant TX_CHSTAT                                     : natural := 16#2002#;
   constant TX_INTMASK                                    : natural := 16#2003#;
   constant TX_INTSTAT                                    : natural := 16#2004#;
   constant TX_UD_BASE                                    : natural := 16#2020#;
   constant TX_CS_BASE                                    : natural := 16#2040#;
   constant TX_BUF_BASE                                   : natural := 16#2080#;
   
   
begin

   wb_ack_i <= rx_ack or tx_ack;
   wb_dat_i <= rx_dat_i or tx_dat_i;

-- SPDIF recevier in 32bit mode with two capture registers
   SRX32 : rx_spdif
      generic map (
         DATA_WIDTH    => 32,
         ADDR_WIDTH    => 8,            -- 128 byte sample buffer
         CH_ST_CAPTURE => 2,            -- two capture regs.
         WISHBONE_FREQ => 33)           -- 33 MHz
      port map (
         wb_clk_i   => wb_clk_o,
         wb_rst_i   => wb_rst_o,
         wb_sel_i   => wb_sel_o,
         wb_stb_i   => wb_stb_32bit_rx,
         wb_we_i    => wb_we_o,
         wb_cyc_i   => wb_cyc_o,
         wb_bte_i   => wb_bte_o,
         wb_cti_i   => wb_cti_o,
         wb_adr_i   => wb_adr_o(7 downto 0),
         wb_dat_i   => wb_dat_o(31 downto 0),
         wb_ack_o   => rx_ack,
         wb_dat_o   => rx_dat_i,
         rx_int_o   => rx_int_o,
         spdif_rx_i => spdif_signal);

-- SPDIF transmitter with all bells and whistles
   STX32 : tx_spdif
      generic map (DATA_WIDTH    => 32,
                   ADDR_WIDTH    => 8,
                   USER_DATA_BUF => 1,
                   CH_STAT_BUF   => 1)
      port map (
         -- Wishbone interface
         wb_clk_i   => wb_clk_o,
         wb_rst_i   => wb_rst_o,
         wb_sel_i   => wb_sel_o,
         wb_stb_i   => wb_stb_32bit_tx,
         wb_we_i    => wb_we_o,
         wb_cyc_i   => wb_cyc_o,
         wb_bte_i   => wb_bte_o,
         wb_cti_i   => wb_cti_o,
         wb_adr_i   => wb_adr_o(7 downto 0),
         wb_dat_i   => wb_dat_o(31 downto 0),
         wb_ack_o   => tx_ack,
         wb_dat_o   => tx_dat_i,
         tx_int_o   => tx_int_o,
         spdif_tx_o => spdif_signal);

-- Main test process
   MAIN : process
      variable read_32bit : std_logic_vector(31 downto 0);

      -- Make simplified versions of procedures in wb_tb_pack
      procedure wb_write_32 (
         constant ADDRESS : in natural;
         constant DATA    : in natural) is 
      begin
         wb_write(ADDRESS, DATA, wb_adr_o, wb_dat_o(31 downto 0), wb_cyc_o,
                  wb_sel_o, wb_we_o, wb_clk_o, wb_ack_i);
      end;
      
      procedure wb_check_32 (
         constant ADDRESS  : in natural;
         constant EXP_DATA : in natural) is
      begin
         wb_check(ADDRESS, EXP_DATA, wb_adr_o, wb_dat_i(31 downto 0), wb_cyc_o,
                  wb_sel_o, wb_we_o, wb_clk_o, wb_ack_i);
      end;
      
      procedure wb_read_32 (
         constant ADDRESS   : in  natural;
         variable READ_DATA : out std_logic_vector) is
      begin
         wb_read(ADDRESS, read_32bit, wb_adr_o, wb_dat_i(31 downto 0), wb_cyc_o,
                 wb_sel_o, wb_we_o, wb_clk_o, wb_ack_i);
      end;
   begin
      message("Simulation start with system reset.");
      wb_rst_o <= '1';                  -- system reset
      wb_sel_o <= '0';
      wb_stb_o <= '0';
      wb_sel_o <= '0';
      wb_we_o  <= '0';
      wb_cyc_o <= '0';
      wb_bte_o <= "00";
      wb_cti_o <= "000";
      wb_adr_o <= (others => '0');
      wb_dat_o <= (others => '0');
      wait for 200 ns;
      wb_rst_o <= '0';
      message("Start with checking version register for correct value:");
      wb_check_32(RX_VERSION, 16#00020111#);
      message("Check transmitter version register:");
      wb_check_32(TX_VERSION, 16#00003111#);
      message("Fill up sample buffer with test signal, ramp up in ch.A, ramp down in ch.B:");
      SGEN : for i in 0 to 63 loop
         wb_write_32(TX_BUF_BASE + 2*i, 32768 + i*497);      -- channel A
         wb_write_32(TX_BUF_BASE + 2*i + 1, 32768 - i*497);  -- channel B
      end loop;
      message("Setup some channel status and user data to be transmitted:");
      wb_write_32(TX_CS_BASE, 16#000000f8#);
      wb_write_32(TX_UD_BASE + 5, 16#000000a2#);
      message("Enable transmitter:");
      wb_write_32(TX_CONFIG, 16#00000851#);
      wait for 4 us;
      message("Enable receiver, interrupt on lock:");
      wb_write_32(RX_INTMASK, 16#00000001#);
      wb_write_32(RX_CONFIG, 16#00000005#);
      wait_for_event("Wait for LOCK interrupt", 120 us, rx_int_o);
      message("Check status register:");
      wb_check_32(RX_STATUS, 16#00000001#);
      message("Clear LOCK interrupt:");
      wb_write_32(RX_INTSTAT, 16#00000001#);
      wb_check_32(RX_INTSTAT, 16#00000000#);
      signal_check("rx_int_o", '0', rx_int_o);
      message("Enable recevier sample buffer:");
      wb_write_32(RX_CONFIG, 16#00000017#);
      wait for 20 us;
      message("Enable audio transmission:");
      wb_write_32(TX_CONFIG, 16#00000853#);
      message("Enable receiver LSBF/HSBF interrupts:");
      wb_write_32(RX_INTMASK, 16#00000006#);
      wait_for_event("Wait for recevier LSBF interrupt", 1.8 ms, rx_int_o);
      message("Clear LSBF interrupt:");
      wb_write_32(RX_INTSTAT, 16#00000002#);
      wb_check_32(RX_INTSTAT, 16#00000000#);
      signal_check("rx_int_o", '0', rx_int_o);
      message("Check receiver buffer for correct sample data:");
      SCHK : for i in 0 to 31 loop
         wb_check_32(RX_BUF_BASE + 2*i, 32768 + i*497);      -- channel A
         wb_check_32(RX_BUF_BASE + 2*i + 1, 32768 - i*497);  -- channel B
      end loop;
      wait_for_event("Wait for recevier HSBF interrupt", 1.8 ms, rx_int_o);
      message("Clear HSBF interrupt:");
      wb_write_32(RX_INTSTAT, 16#00000004#);
      wb_check_32(RX_INTSTAT, 16#00000000#);
      signal_check("rx_int_o", '0', rx_int_o);
      message("Check receiver buffer for correct sample data:");
      SCHK2 : for i in 32 to 63 loop
         wb_check_32(RX_BUF_BASE + 2*i, 32768 + i*497);      -- channel A
         wb_check_32(RX_BUF_BASE + 2*i + 1, 32768 - i*497);  -- channel B
      end loop;
      message("Setup receiver capture register for channel status capture:");
      wb_write_32(RX_CHSTCAP0, 16#00000286#);  -- 6 bits from bit 2
      wb_check_32(RX_CHSTCAP0, 16#00000286#);
      message("Setup receiver capture register for user data capture:");
      wb_write_32(RX_CHSTCAP1, 16#00002808#);  -- 8 bits from bit 40
      message("Enable capture interrupts:");
      wb_write_32(RX_INTMASK, 16#00030000#);
      wait_for_event("Wait for receiver CAP0 interrupt", 6 ms, rx_int_o);
      message("Check captured bits and clear interrupt:");
      wb_check_32(RX_CHSTDAT0, 16#0000003e#);
      wb_write_32(RX_INTSTAT, 16#00010006#);
      wb_check_32(RX_INTSTAT, 16#00000000#);
      signal_check("rx_int_o", '0', rx_int_o);
      wait_for_event("Wait for receiver CAP1 interrupt", 4 ms, rx_int_o);
      message("Check captured bits and clear interrupt:");
      wb_check_32(RX_CHSTDAT1, 16#000000a2#);
      wb_write_32(RX_INTSTAT, 16#00020006#);
      wb_check_32(RX_INTSTAT, 16#00000000#);
      signal_check("rx_int_o", '0', rx_int_o);
      message("Check that transmitter buffer events were generated:");
      wb_check_32(TX_INTSTAT, 16#0000001e#);
      wb_write_32(TX_INTSTAT, 16#0000001e#);
      wb_check_32(TX_INTSTAT, 16#00000000#);

      sim_report("");
      report "End of simulation! (ignore this failure)"
         severity failure;
      wait;
   end process MAIN;

-- Bus strobe generator based on address. 32bit recevier mapped to addr. 0x1000
-- 32bit transmitter mapped to address 0x2000
   wb_stb_32bit_rx <= '1' when wb_adr_o(15 downto 12) = "0001" else '0';
   wb_stb_32bit_tx <= '1' when wb_adr_o(15 downto 12) = "0010" else '0';

-- Clock process, 33Mhz Wishbone master freq.
   CLKGEN : process
   begin
      wb_clk_o <= '0';
      wait for 15.15 ns;
      wb_clk_o <= '1';
      wait for 15.15 ns;
   end process CLKGEN;
   
end behav;



