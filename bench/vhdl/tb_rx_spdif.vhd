----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- Test bench for SPDIF recevier.                               ----
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
-- Revision 1.3  2004/07/12 17:06:07  gedra
-- Test bench update.
--
-- Revision 1.2  2004/07/11 16:20:16  gedra
-- Improved test bench.
--
-- Revision 1.1  2004/06/26 14:12:51  gedra
-- Top level test bench for receiver. NB! Not complete.
--
--

library ieee;
use ieee.std_logic_1164.all;
use work.wb_tb_pack.all;


entity tb_rx_spdif is

end tb_rx_spdif;

architecture behav of tb_rx_spdif is

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

   component gen_spdif
      generic (Freq : natural);         -- Sampling frequency in Hz
      port (                            -- Bitrate is 64x sampling frequency
         reset : in  std_logic;
         spdif : out std_logic);        -- Output bi-phase encoded signal
   end component;

   signal wb_clk_o, wb_rst_o, wb_sel_o, wb_stb_o, wb_we_o : std_logic;
   signal wb_cyc_o, wb_ack_i, rx_int_o, spdif_rx_i        : std_logic;
   signal wb_bte_o                                        : std_logic_vector(1 downto 0);
   signal wb_cti_o                                        : std_logic_vector(2 downto 0);
   signal wb_adr_o                                        : std_logic_vector(15 downto 0);
   signal wb_dat_i, wb_dat_o                              : std_logic_vector(31 downto 0);
   signal wb_stb_16bit_rx                                 : std_logic;
   constant RX_VERSION                                    : natural := 16#1000#;
   constant RX_CONFIG                                     : natural := 16#1001#;
   constant RX_STATUS                                     : natural := 16#1002#;
   constant RX_INTMASK                                    : natural := 16#1003#;
   constant RX_INTSTAT                                    : natural := 16#1004#;
   
begin

-- Minimal SPDIF recevier in 16bit mode
   SRX16 : rx_spdif
      generic map (
         DATA_WIDTH    => 16,
         ADDR_WIDTH    => 8,            -- 128 byte sample buffer
         CH_ST_CAPTURE => 0,            -- no capture in 16bit mode
         WISHBONE_FREQ => 33)           -- 33 MHz
      port map (
         wb_clk_i   => wb_clk_o,
         wb_rst_i   => wb_rst_o,
         wb_sel_i   => wb_sel_o,
         wb_stb_i   => wb_stb_16bit_rx,
         wb_we_i    => wb_we_o,
         wb_cyc_i   => wb_cyc_o,
         wb_bte_i   => wb_bte_o,
         wb_cti_i   => wb_cti_o,
         wb_adr_i   => wb_adr_o(7 downto 0),
         wb_dat_i   => wb_dat_o(15 downto 0),
         wb_ack_o   => wb_ack_i,
         wb_dat_o   => wb_dat_i(15 downto 0),
         rx_int_o   => rx_int_o,
         spdif_rx_i => spdif_rx_i);

-- SPDIF 44.1kHz source
   SP44 : gen_spdif
      generic map (FREQ => 44100)
      port map (reset => wb_rst_o,
                spdif => spdif_rx_i);

-- Main test process
   MAIN : process
      variable read_16bit : std_logic_vector(15 downto 0);

      -- Make simplified versions of procedures in wb_tb_pack
      procedure wb_write_16 (
         constant ADDRESS : in natural;
         constant DATA    : in natural) is 
      begin
         wb_write(ADDRESS, DATA, wb_adr_o, wb_dat_o(15 downto 0), wb_cyc_o,
                  wb_sel_o, wb_we_o, wb_clk_o, wb_ack_i);
      end;
      
      procedure wb_check_16 (
         constant ADDRESS  : in natural;
         constant EXP_DATA : in natural) is
      begin
         wb_check(ADDRESS, EXP_DATA, wb_adr_o, wb_dat_i(15 downto 0), wb_cyc_o,
                  wb_sel_o, wb_we_o, wb_clk_o, wb_ack_i);
      end;
      
      procedure wb_read_16 (
         constant ADDRESS   : in  natural;
         variable READ_DATA : out std_logic_vector) is
      begin
         wb_read(ADDRESS, read_16bit, wb_adr_o, wb_dat_i(15 downto 0), wb_cyc_o,
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
      wb_check_16(RX_VERSION, 16#0101#);
      message("Enable interrupt on lock:");
      wb_write_16(RX_INTMASK, 16#0001#);
      message("Enable receiver:");
      wb_write_16(RX_CONFIG, 16#0005#);
      wb_read_16(RX_CONFIG, read_16bit);
      wait_for_event("Wait for LOCK interrupt", 60 us, rx_int_o);
      message("Check status register:");
      wb_check_16(RX_STATUS, 16#0001#);
      message("Clear interrupt:");
      wb_write_16(RX_INTSTAT, 16#0001#);
      wb_check_16(RX_INTSTAT, 16#0000#);
      signal_check("rx_int_o", '0', rx_int_o);
      message("Enable sample buffer");
      wb_write_16(RX_CONFIG, 16#0007#);
      message("Enable sample buffer interrupts");
      wb_write_16(RX_INTMASK, 16#0007#);
      wait_for_event("Wait for LSBF interrupt", 750 us, rx_int_o);
      message("Check LSBF interrupt, and read some data");
      wb_check_16(RX_INTSTAT, 16#0002#);
      wb_write_16(RX_INTSTAT, 16#0002#);
      wb_check_16(RX_INTSTAT, 16#0000#);
      signal_check("rx_int_o", '0', rx_int_o);
      wb_read_16(16#1080#, read_16bit);
      wb_read_16(16#1081#, read_16bit);
      wb_read_16(16#1082#, read_16bit);
      wb_read_16(16#1083#, read_16bit);
      wait_for_event("Wait for HSBF interrupt", 750 us, rx_int_o);
      message("Check HSBF interrupt, and read some data");
      wb_check_16(RX_INTSTAT, 16#0004#);
      wb_write_16(RX_INTSTAT, 16#0004#);
      wb_check_16(RX_INTSTAT, 16#0000#);
      signal_check("rx_int_o", '0', rx_int_o);


      report "End of simulation! (ignore this failure)"
         severity failure;
      wait;
      
   end process MAIN;

-- Bus strobe generator based on address. 16bit recevier mapped to addr. 0x1000
   wb_stb_16bit_rx <= '1' when wb_adr_o(15 downto 12) = "0001" else '0';

-- Clock process, 33Mhz Wishbone master freq.
   CLKGEN : process
   begin
      wb_clk_o <= '0';
      wait for 15.15 ns;
      wb_clk_o <= '1';
      wait for 15.15 ns;
   end process CLKGEN;
   
end behav;



