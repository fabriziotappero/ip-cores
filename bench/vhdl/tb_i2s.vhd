----------------------------------------------------------------------
----                                                              ----
---- WISHBONE I2S Interface IP Core                               ----
----                                                              ----
---- This file is part of the I2S Interface project               ----
---- http://www.opencores.org/cores/i2s_interface/                ----
----                                                              ----
---- Description                                                  ----
---- I2S top level test bench. Two transmitters and two receivers ----
---- are instantiated, one each in slave and master mode.         ----
---- Test result is displayed in the log window, there should     ----
---- be no errors.                                                ----
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
---- and/or modify it under the terms of the GNU General          ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.0 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU General Public License for more details.----
----                                                              ----
---- You should have received a copy of the GNU General           ----
---- Public License along with this source; if not, download it   ----
---- from http://www.gnu.org/licenses/gpl.txt                     ----
----                                                              ----
----------------------------------------------------------------------
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
-- Revision 1.2  2004/08/07 12:33:29  gedra
-- De-linted.
--
-- Revision 1.1  2004/08/04 14:31:02  gedra
-- Top level test bench.
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wb_tb_pack.all;

entity tb_i2s is

end tb_i2s;

architecture behav of tb_i2s is

   component tx_i2s_topm
      generic (DATA_WIDTH : integer range 16 to 32;
               ADDR_WIDTH : integer range 5 to 32);
      port (
         -- Wishbone interface
         wb_clk_i  : in  std_logic;
         wb_rst_i  : in  std_logic;
         wb_sel_i  : in  std_logic;
         wb_stb_i  : in  std_logic;
         wb_we_i   : in  std_logic;
         wb_cyc_i  : in  std_logic;
         wb_bte_i  : in  std_logic_vector(1 downto 0);
         wb_cti_i  : in  std_logic_vector(2 downto 0);
         wb_adr_i  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
         wb_dat_i  : in  std_logic_vector(DATA_WIDTH -1 downto 0);
         wb_ack_o  : out std_logic;
         wb_dat_o  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
         -- Interrupt line
         tx_int_o  : out std_logic;
         -- I2S signals
         i2s_sd_o  : out std_logic;
         i2s_sck_o : out std_logic;
         i2s_ws_o  : out std_logic);
   end component;

   component tx_i2s_tops
      generic (DATA_WIDTH : integer range 16 to 32;
               ADDR_WIDTH : integer range 5 to 32);
      port (
         wb_clk_i  : in  std_logic;
         wb_rst_i  : in  std_logic;
         wb_sel_i  : in  std_logic;
         wb_stb_i  : in  std_logic;
         wb_we_i   : in  std_logic;
         wb_cyc_i  : in  std_logic;
         wb_bte_i  : in  std_logic_vector(1 downto 0);
         wb_cti_i  : in  std_logic_vector(2 downto 0);
         wb_adr_i  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
         wb_dat_i  : in  std_logic_vector(DATA_WIDTH -1 downto 0);
         i2s_sck_i : in  std_logic;
         i2s_ws_i  : in  std_logic;
         wb_ack_o  : out std_logic;
         wb_dat_o  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
         tx_int_o  : out std_logic;
         i2s_sd_o  : out std_logic);
   end component;

   component rx_i2s_topm
      generic (DATA_WIDTH : integer range 16 to 32;
               ADDR_WIDTH : integer range 5 to 32);
      port (
         wb_clk_i  : in  std_logic;
         wb_rst_i  : in  std_logic;
         wb_sel_i  : in  std_logic;
         wb_stb_i  : in  std_logic;
         wb_we_i   : in  std_logic;
         wb_cyc_i  : in  std_logic;
         wb_bte_i  : in  std_logic_vector(1 downto 0);
         wb_cti_i  : in  std_logic_vector(2 downto 0);
         wb_adr_i  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
         wb_dat_i  : in  std_logic_vector(DATA_WIDTH -1 downto 0);
         i2s_sd_i  : in  std_logic;     -- I2S data input
         wb_ack_o  : out std_logic;
         wb_dat_o  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
         rx_int_o  : out std_logic;     -- Interrupt line
         i2s_sck_o : out std_logic;     -- I2S clock out
         i2s_ws_o  : out std_logic);    -- I2S word select out
   end component;

   component rx_i2s_tops
      generic (DATA_WIDTH : integer range 16 to 32;
               ADDR_WIDTH : integer range 5 to 32);
      port (
         wb_clk_i  : in  std_logic;
         wb_rst_i  : in  std_logic;
         wb_sel_i  : in  std_logic;
         wb_stb_i  : in  std_logic;
         wb_we_i   : in  std_logic;
         wb_cyc_i  : in  std_logic;
         wb_bte_i  : in  std_logic_vector(1 downto 0);
         wb_cti_i  : in  std_logic_vector(2 downto 0);
         wb_adr_i  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
         wb_dat_i  : in  std_logic_vector(DATA_WIDTH -1 downto 0);
         i2s_sd_i  : in  std_logic;     -- I2S data input
         i2s_sck_i : in  std_logic;     -- I2S clock input
         i2s_ws_i  : in  std_logic;     -- I2S word select input
         wb_ack_o  : out std_logic;
         wb_dat_o  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
         rx_int_o  : out std_logic);    -- Interrupt line
   end component;

   signal wb_clk_o, wb_rst_o, wb_sel_o, wb_stb_o, wb_we_o        : std_logic;
   signal wb_cyc_o, wb_ack_i, rx1_int_o                          : std_logic;
   signal tx_int_o, tx1_ack, rx1_ack, tx2_ack, rx2_ack           : std_logic;
   signal rx2_int_o, tx1_int_o, tx2_int_o                        : std_logic;
   signal wb_bte_o                                               : std_logic_vector(1 downto 0);
   signal wb_cti_o                                               : std_logic_vector(2 downto 0);
   signal wb_adr_o                                               : std_logic_vector(15 downto 0);
   signal wb_dat_i, wb_dat_o, rx1_dat_i                          : std_logic_vector(31 downto 0);
   signal tx1_dat_i, rx2_dat_i, tx2_dat_i                        : std_logic_vector(31 downto 0);
   signal wb_stb_32bit_rx1, wb_stb_32bit_tx1                     : std_logic;
   signal wb_stb_32bit_rx2, wb_stb_32bit_tx2                     : std_logic;
   signal i2s_sd1, i2s_sd2, i2s_sck1, i2s_sck2, i2s_ws1, i2s_ws2 : std_logic;
   -- register address definitions
   constant RX1_VERSION                                          : natural := 16#1000#;
   constant RX1_CONFIG                                           : natural := 16#1001#;
   constant RX1_INTMASK                                          : natural := 16#1002#;
   constant RX1_INTSTAT                                          : natural := 16#1003#;
   constant RX1_BUF_BASE                                         : natural := 16#1020#;
   constant TX1_VERSION                                          : natural := 16#2000#;
   constant TX1_CONFIG                                           : natural := 16#2001#;
   constant TX1_INTMASK                                          : natural := 16#2002#;
   constant TX1_INTSTAT                                          : natural := 16#2003#;
   constant TX1_BUF_BASE                                         : natural := 16#2020#;
   constant RX2_VERSION                                          : natural := 16#3000#;
   constant RX2_CONFIG                                           : natural := 16#3001#;
   constant RX2_INTMASK                                          : natural := 16#3002#;
   constant RX2_INTSTAT                                          : natural := 16#3003#;
   constant RX2_BUF_BASE                                         : natural := 16#3020#;
   constant TX2_VERSION                                          : natural := 16#4000#;
   constant TX2_CONFIG                                           : natural := 16#4001#;
   constant TX2_INTMASK                                          : natural := 16#4002#;
   constant TX2_INTSTAT                                          : natural := 16#4003#;
   constant TX2_BUF_BASE                                         : natural := 16#4020#;
   
begin

   wb_ack_i <= rx1_ack or tx1_ack or rx2_ack or tx2_ack;
   wb_dat_i <= rx1_dat_i when wb_stb_32bit_rx1 = '1'
               else tx1_dat_i when wb_stb_32bit_tx1 = '1'
               else rx2_dat_i when wb_stb_32bit_rx2 = '1'
               else tx2_dat_i when wb_stb_32bit_tx2 = '1'
               else (others => '0');

-- I2S transmitter 1, slave mode
   ITX32S : tx_i2s_tops
      generic map (DATA_WIDTH => 32,
                   ADDR_WIDTH => 6)
      port map (
         -- Wishbone interface
         wb_clk_i  => wb_clk_o,
         wb_rst_i  => wb_rst_o,
         wb_sel_i  => wb_sel_o,
         wb_stb_i  => wb_stb_32bit_tx1,
         wb_we_i   => wb_we_o,
         wb_cyc_i  => wb_cyc_o,
         wb_bte_i  => wb_bte_o,
         wb_cti_i  => wb_cti_o,
         wb_adr_i  => wb_adr_o(5 downto 0),
         wb_dat_i  => wb_dat_o(31 downto 0),
         wb_ack_o  => tx1_ack,
         wb_dat_o  => tx1_dat_i,
         tx_int_o  => tx1_int_o,
         i2s_sd_o  => i2s_sd1,
         i2s_sck_i => i2s_sck1,
         i2s_ws_i  => i2s_ws1);

-- I2S transmitter 2, master mode
   ITX32M : tx_i2s_topm
      generic map (DATA_WIDTH => 32,
                   ADDR_WIDTH => 6)
      port map (
         -- Wishbone interface
         wb_clk_i  => wb_clk_o,
         wb_rst_i  => wb_rst_o,
         wb_sel_i  => wb_sel_o,
         wb_stb_i  => wb_stb_32bit_tx2,
         wb_we_i   => wb_we_o,
         wb_cyc_i  => wb_cyc_o,
         wb_bte_i  => wb_bte_o,
         wb_cti_i  => wb_cti_o,
         wb_adr_i  => wb_adr_o(5 downto 0),
         wb_dat_i  => wb_dat_o(31 downto 0),
         wb_ack_o  => tx2_ack,
         wb_dat_o  => tx2_dat_i,
         tx_int_o  => tx2_int_o,
         i2s_sd_o  => i2s_sd2,
         i2s_sck_o => i2s_sck2,
         i2s_ws_o  => i2s_ws2);

-- I2S receiver 1, master mode
   IRX32M : rx_i2s_topm
      generic map (DATA_WIDTH => 32,
                   ADDR_WIDTH => 6)
      port map (
         -- Wishbone interface
         wb_clk_i  => wb_clk_o,
         wb_rst_i  => wb_rst_o,
         wb_sel_i  => wb_sel_o,
         wb_stb_i  => wb_stb_32bit_rx1,
         wb_we_i   => wb_we_o,
         wb_cyc_i  => wb_cyc_o,
         wb_bte_i  => wb_bte_o,
         wb_cti_i  => wb_cti_o,
         wb_adr_i  => wb_adr_o(5 downto 0),
         wb_dat_i  => wb_dat_o(31 downto 0),
         i2s_sd_i  => i2s_sd1,
         wb_ack_o  => rx1_ack,
         wb_dat_o  => rx1_dat_i,
         rx_int_o  => rx1_int_o,
         i2s_sck_o => i2s_sck1,
         i2s_ws_o  => i2s_ws1);

-- I2S receiver 2, slave mode
   IRX32S : rx_i2s_tops
      generic map (DATA_WIDTH => 32,
                   ADDR_WIDTH => 6)
      port map (
         -- Wishbone interface
         wb_clk_i  => wb_clk_o,
         wb_rst_i  => wb_rst_o,
         wb_sel_i  => wb_sel_o,
         wb_stb_i  => wb_stb_32bit_rx2,
         wb_we_i   => wb_we_o,
         wb_cyc_i  => wb_cyc_o,
         wb_bte_i  => wb_bte_o,
         wb_cti_i  => wb_cti_o,
         wb_adr_i  => wb_adr_o(5 downto 0),
         wb_dat_i  => wb_dat_o(31 downto 0),
         i2s_sd_i  => i2s_sd2,
         i2s_sck_i => i2s_sck2,
         i2s_ws_i  => i2s_ws2,
         wb_ack_o  => rx2_ack,
         wb_dat_o  => rx2_dat_i,
         rx_int_o  => rx2_int_o);

-- Main test process
   MAIN : process
      variable read_32bit : std_logic_vector(31 downto 0);
      variable idx        : integer;

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
         constant ADDRESS : in natural) is
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
      message("Check receiver version registers:");
      wb_check_32(RX1_VERSION, 16#000001b1#);
      wb_check_32(RX2_VERSION, 16#00000191#);
      message("Check transmitter version registers:");
      wb_check_32(TX1_VERSION, 16#00000191#);
      wb_check_32(TX2_VERSION, 16#000001b1#);
      message("Fill up sample buffers with test signal, ");
      message("ramp up in left, ramp down in right:");
      SGEN : for i in 0 to 15 loop
         wb_write_32(TX1_BUF_BASE + 2*i, (32768 + i*497)*256);      -- left
         wb_write_32(TX1_BUF_BASE + 2*i + 1, (32767 - i*497)*256);  -- right
         wb_write_32(TX2_BUF_BASE + 2*i, (32767 - i*497)*16);       -- left
         wb_write_32(TX2_BUF_BASE + 2*i + 1, (32768 + i*497)*16);   --right
      end loop;
      message("*** Test of master TX and slave RX ***");
      message("Enable transmitter 2:");
      wb_write_32(TX2_INTMASK, 16#00000003#);  -- enable interrupts
      wb_write_32(TX2_CONFIG, 16#00140703#);   -- 20bit resolution
      message("Enable recevier 2:");
      wb_write_32(RX2_INTMASK, 16#00000003#);  -- enable interrupts
      wb_write_32(RX2_CONFIG, 16#00180003#);   -- 24bit resolution
      wait_for_event("Wait for transmitter 2 LSBF interrupt", 150 us, tx2_int_o);
      wait for 1 us;
      message("Check for receiver LSBF interrupt:");
      wb_check_32(RX2_INTSTAT, 16#00000001#);
      message("Clear transmitter LSBF interrupt:");
      wb_write_32(TX2_INTSTAT, 16#00000001#);
      wb_check_32(TX2_INTSTAT, 16#00000000#);
      signal_check("tx2_int_o", '0', tx2_int_o);
      message("Clear receiver LSBF interrupt:");
      wb_write_32(RX2_INTSTAT, 16#00000001#);
      wb_check_32(RX2_INTSTAT, 16#00000000#);
      signal_check("rx2_int_o", '0', rx2_int_o);
      message("Check received data, lower sample buffer:");
      wb_read_32(RX2_BUF_BASE);
      -- calculate which index this word was generated with
      idx := (32767 - to_integer(unsigned(read_32bit(31 downto 8)))) / 497;
      -- then check for correct values
      CHKL : for i in 0 to 7 - idx loop
         wb_check_32(RX2_BUF_BASE + 2*i, (32767 - (i+idx)*497)*256);
         wb_check_32(RX2_BUF_BASE + 2*i + 1, (32768 + (i+idx)*497)*256);
      end loop;
      wait_for_event("Wait for transmitter 2 HSBF interrupt", 150 us, tx2_int_o);
      wait for 1 us;
      message("Check for receiver LSBF interrupt:");
      wb_check_32(RX2_INTSTAT, 16#00000002#);
      message("Clear transmitter HSBF interrupt:");
      wb_write_32(TX2_INTSTAT, 16#00000002#);
      wb_check_32(TX2_INTSTAT, 16#00000000#);
      signal_check("tx2_int_o", '0', tx2_int_o);
      message("Clear receiver HSBF interrupt:");
      wb_write_32(RX2_INTSTAT, 16#00000002#);
      wb_check_32(RX2_INTSTAT, 16#00000000#);
      signal_check("rx2_int_o", '0', rx2_int_o);
      message("Check received data, upper sample buffer:");
      CHKH : for i in 8 - idx to 15 - idx loop
         wb_check_32(RX2_BUF_BASE + 2*i, (32767 - (i+idx)*497)*256);
         wb_check_32(RX2_BUF_BASE + 2*i + 1, (32768 + (i+idx)*497)*256);
      end loop;

      message("*** Test of slave TX and master RX ***");
      message("Enable transmitter 1:");
      wb_write_32(TX1_INTMASK, 16#00000003#);  -- enable interrupts
      wb_write_32(TX1_CONFIG, 16#00180007#);   -- 24bit resolution
      message("Enable recevier 1:");
      wb_write_32(RX1_INTMASK, 16#00000003#);  -- enable interrupts
      wb_write_32(RX1_CONFIG, 16#00100707#);   -- 16bit resolution          
      wait_for_event("Wait for transmitter 1 LSBF interrupt", 150 us, tx1_int_o);
      message("Clear LSBF interrupt:");
      wb_write_32(TX1_INTSTAT, 16#00000001#);
      wb_check_32(TX1_INTSTAT, 16#00000000#);
      signal_check("tx1_int_o", '0', tx1_int_o);
      wait_for_event("Wait for recevier 1 LSBF interrupt", 150 us, rx1_int_o);
      message("Clear LSBF interrupt:");
      wb_write_32(RX1_INTSTAT, 16#00000001#);
      wb_check_32(RX1_INTSTAT, 16#00000000#);
      signal_check("rx1_int_o", '0', rx1_int_o);
      message("Check received data (#1), lower sample buffer:");
      wb_read_32(RX1_BUF_BASE);
      -- calculate which index this word was generated with
      idx := (32767 - to_integer(unsigned(read_32bit(15 downto 0)))) / 497;
      -- then check for correct values
      CHKL1 : for i in 0 to 7 - idx loop
         wb_check_32(RX1_BUF_BASE + 2*i, 32768 + (i+idx)*497);
         wb_check_32(RX1_BUF_BASE + 2*i + 1, 32767 - (i+idx)*497);
      end loop;
      wait_for_event("Wait for transmitter 1 HSBF interrupt", 150 us, tx1_int_o);
      message("Clear HSBF interrupt:");
      wb_write_32(TX1_INTSTAT, 16#00000002#);
      wb_check_32(TX1_INTSTAT, 16#00000000#);
      signal_check("tx1_int_o", '0', tx1_int_o);
      wait_for_event("Wait for recevier 1 HSBF interrupt", 150 us, rx1_int_o);
      message("Clear HSBF interrupt:");
      wb_write_32(RX1_INTSTAT, 16#00000002#);
      wb_check_32(RX1_INTSTAT, 16#00000000#);
      signal_check("rx1_int_o", '0', rx1_int_o);
      message("Check received data (#1), higher sample buffer:");
      CHKH1 : for i in 8 - idx to 15 - idx loop
         wb_check_32(RX1_BUF_BASE + 2*i, 32768 + (i+idx)*497);
         wb_check_32(RX1_BUF_BASE + 2*i + 1, 32767 - (i+idx)*497);
      end loop;

      sim_report("");
      report "End of simulation! (ignore this failure)"
         severity failure;
      wait;
   end process MAIN;

-- Bus strobe generator based on address. 32bit recevier mapped to addr. 0x1000
-- 32bit transmitter mapped to address 0x2000
   wb_stb_32bit_rx1 <= '1' when wb_adr_o(15 downto 12) = "0001" else '0';
   wb_stb_32bit_tx1 <= '1' when wb_adr_o(15 downto 12) = "0010" else '0';
   wb_stb_32bit_rx2 <= '1' when wb_adr_o(15 downto 12) = "0011" else '0';
   wb_stb_32bit_tx2 <= '1' when wb_adr_o(15 downto 12) = "0100" else '0';

-- Clock process, 50Mhz Wishbone master freq.
   CLKGEN : process
   begin
      wb_clk_o <= '0';
      wait for 10 ns;
      wb_clk_o <= '1';
      wait for 10 ns;
   end process CLKGEN;
   
end behav;



