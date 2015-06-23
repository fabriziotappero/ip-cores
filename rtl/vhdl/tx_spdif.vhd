----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- SPDIF transmitter. Top level entity for the transmitter      ----
---- core.                                                        ----
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
-- Revision 1.3  2005/03/27 14:03:58  gedra
-- Fix: Could not read TxChStat register.
--
-- Revision 1.2  2004/07/20 17:41:25  gedra
-- Cleaned up synthesis warnings.
--
-- Revision 1.1  2004/07/19 17:00:38  gedra
-- SPDIF transmitter top level.
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use work.tx_package.all;

entity tx_spdif is
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
end tx_spdif;

architecture rtl of tx_spdif is

   signal data_out, version_dout                                : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal version_rd                                            : std_logic;
   signal config_rd, config_wr, status_rd                       : std_logic;
   signal config_dout, status_dout                              : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal config_bits                                           : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal intmask_bits, intmask_dout                            : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal intmask_rd, intmask_wr                                : std_logic;
   signal intstat_dout, intstat_events                          : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal intstat_rd, intstat_wr                                : std_logic;
   signal evt_hsbf, evt_lsbf                                    : std_logic;
   signal evt_hcsbf, evt_lcsbf                                  : std_logic;
   signal chstat_dout, chstat_bits                              : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal chstat_rd, chstat_wr                                  : std_logic;
   signal chstat_freq                                           : std_logic_vector(1 downto 0);
   signal chstat_gstat, chstat_preem, chstat_copy, chstat_audio : std_logic;
   signal mem_wr, mem_rd, ch_status_wr, user_data_wr            : std_logic;
   signal sample_addr                                           : std_logic_vector(ADDR_WIDTH - 2 downto 0);
   signal sample_data                                           : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal conf_mode                                             : std_logic_vector(3 downto 0);
   signal conf_ratio                                            : std_logic_vector(7 downto 0);
   signal conf_udaten, conf_chsten                              : std_logic_vector(1 downto 0);
   signal conf_tinten, conf_txdata, conf_txen                   : std_logic;
   signal user_data_a, user_data_b                              : std_logic_vector(191 downto 0);
   signal ch_stat_a, ch_stat_b                                  : std_logic_vector(191 downto 0);

begin

-- Data bus or'ing 
   data_out <= version_dout or config_dout or intmask_dout or intstat_dout
               or chstat_dout
               when wb_adr_i(ADDR_WIDTH - 1) = '0' else (others => '0');

-- Wishbone bus cycle decoder
   WB : tx_wb_decoder
      generic map (
         DATA_WIDTH => DATA_WIDTH,
         ADDR_WIDTH => ADDR_WIDTH)
      port map (
         wb_clk_i     => wb_clk_i,
         wb_rst_i     => wb_rst_i,
         wb_sel_i     => wb_sel_i,
         wb_stb_i     => wb_stb_i,
         wb_we_i      => wb_we_i,
         wb_cyc_i     => wb_cyc_i,
         wb_bte_i     => wb_bte_i,
         wb_cti_i     => wb_cti_i,
         wb_adr_i     => wb_adr_i,
         data_out     => data_out,
         wb_ack_o     => wb_ack_o,
         wb_dat_o     => wb_dat_o,
         version_rd   => version_rd,
         config_rd    => config_rd,
         config_wr    => config_wr,
         chstat_rd    => chstat_rd,
         chstat_wr    => chstat_wr,
         intmask_rd   => intmask_rd,
         intmask_wr   => intmask_wr,
         intstat_rd   => intstat_rd,
         intstat_wr   => intstat_wr,
         mem_wr       => mem_wr,
         user_data_wr => user_data_wr,
         ch_status_wr => ch_status_wr);

-- TxVersion - Version register
   VER : tx_ver_reg
      generic map (
         DATA_WIDTH    => DATA_WIDTH,
         ADDR_WIDTH    => ADDR_WIDTH,
         USER_DATA_BUF => USER_DATA_BUF,
         CH_STAT_BUF   => CH_STAT_BUF)
      port map (
         ver_rd   => version_rd,
         ver_dout => version_dout);

-- TxConfig - Configuration register
   CG32 : if DATA_WIDTH = 32 generate
      CONF : gen_control_reg
         generic map (
            DATA_WIDTH      => 32,
            ACTIVE_BIT_MASK => "11101111111111110000111100000000")
         port map (
            clk       => wb_clk_i,
            rst       => wb_rst_i,
            ctrl_wr   => config_wr,
            ctrl_rd   => config_rd,
            ctrl_din  => wb_dat_i,
            ctrl_dout => config_dout,
            ctrl_bits => config_bits);
      conf_mode(3 downto 0) <= config_bits(23 downto 20);
   end generate CG32;
   CG16 : if DATA_WIDTH = 16 generate
      CONF : gen_control_reg
         generic map (
            DATA_WIDTH      => 16,
            ACTIVE_BIT_MASK => "1110111111111111")
         port map (
            clk       => wb_clk_i,
            rst       => wb_rst_i,
            ctrl_wr   => config_wr,
            ctrl_rd   => config_rd,
            ctrl_din  => wb_dat_i,
            ctrl_dout => config_dout,
            ctrl_bits => config_bits);
      conf_mode(3 downto 0) <= "0000";  -- 16bit only
   end generate CG16;
   conf_ratio(7 downto 0) <= config_bits(15 downto 8);
   UD : if USER_DATA_BUF = 1 generate
      conf_udaten(1 downto 0) <= config_bits(7 downto 6);
   end generate UD;
   NUD : if USER_DATA_BUF = 0 generate
      conf_udaten(1 downto 0) <= "00";
   end generate NUD;
   CS : if CH_STAT_BUF = 1 generate
      conf_chsten(1 downto 0) <= config_bits(5 downto 4);
   end generate CS;
   NCS : if CH_STAT_BUF = 0 generate
      conf_chsten(1 downto 0) <= "00";
   end generate NCS;
   conf_tinten <= config_bits(2);
   conf_txdata <= config_bits(1);
   conf_txen   <= config_bits(0);

-- TxChStat - channel status control register
   CS32 : if DATA_WIDTH = 32 generate
      CHST : gen_control_reg
         generic map (
            DATA_WIDTH      => 32,
            ACTIVE_BIT_MASK => "11111111000000000000000000000000")
         port map (
            clk       => wb_clk_i,
            rst       => wb_rst_i,
            ctrl_wr   => chstat_wr,
            ctrl_rd   => chstat_rd,
            ctrl_din  => wb_dat_i,
            ctrl_dout => chstat_dout,
            ctrl_bits => chstat_bits);
   end generate CS32;
   CS16 : if DATA_WIDTH = 16 generate
      CHST : gen_control_reg
         generic map (
            DATA_WIDTH      => 16,
            ACTIVE_BIT_MASK => "1111111100000000")
         port map (
            clk       => wb_clk_i,
            rst       => wb_rst_i,
            ctrl_wr   => chstat_wr,
            ctrl_rd   => chstat_rd,
            ctrl_din  => wb_dat_i,
            ctrl_dout => chstat_dout,
            ctrl_bits => chstat_bits);
   end generate CS16;
   chstat_freq(1 downto 0) <= chstat_bits(7 downto 6);
   chstat_gstat            <= chstat_bits(3);
   chstat_preem            <= chstat_bits(2);
   chstat_copy             <= chstat_bits(1);
   chstat_audio            <= chstat_bits(0);

-- TxIntMask - interrupt mask register
   IM32 : if DATA_WIDTH = 32 generate
      IMASK : gen_control_reg
         generic map (
            DATA_WIDTH      => 32,
            ACTIVE_BIT_MASK => "01111000000000000000000000000000")
         port map (
            clk       => wb_clk_i,
            rst       => wb_rst_i,
            ctrl_wr   => intmask_wr,
            ctrl_rd   => intmask_rd,
            ctrl_din  => wb_dat_i,
            ctrl_dout => intmask_dout,
            ctrl_bits => intmask_bits);
   end generate IM32;
   IM16 : if DATA_WIDTH = 16 generate
      IMASK : gen_control_reg
         generic map (
            DATA_WIDTH      => 16,
            ACTIVE_BIT_MASK => "0111100000000000")
         port map (
            clk       => wb_clk_i,
            rst       => wb_rst_i,
            ctrl_wr   => intmask_wr,
            ctrl_rd   => intmask_rd,
            ctrl_din  => wb_dat_i,
            ctrl_dout => intmask_dout,
            ctrl_bits => intmask_bits);
   end generate IM16;

-- TxIntStat - interrupt status register
   ISTAT : gen_event_reg
      generic map (
         DATA_WIDTH => DATA_WIDTH)
      port map (
         clk      => wb_clk_i,
         rst      => wb_rst_i,
         evt_wr   => intstat_wr,
         evt_rd   => intstat_rd,
         evt_din  => wb_dat_i,
         evt_dout => intstat_dout,
         event    => intstat_events,
         evt_mask => intmask_bits,
         evt_en   => conf_tinten,
         evt_irq  => tx_int_o);
   intstat_events(0)                       <= '0';
   intstat_events(1)                       <= evt_lsbf;  -- lower sample buffer empty
   intstat_events(2)                       <= evt_hsbf;  -- higher sampel buffer empty
   intstat_events(3)                       <= evt_lcsbf;  -- lower ch.stat/user data buf empty
   intstat_events(4)                       <= evt_hcsbf;  -- higher ch.stat7user data buf empty
   intstat_events(DATA_WIDTH - 1 downto 5) <= (others => '0');

-- Sample buffer memory
   MEM : dpram
      generic map (
         DATA_WIDTH => DATA_WIDTH,
         RAM_WIDTH  => ADDR_WIDTH - 1)
      port map (
         clk     => wb_clk_i,
         rst     => wb_rst_i,
         din     => wb_dat_i(DATA_WIDTH - 1 downto 0),
         wr_en   => mem_wr,
         rd_en   => mem_rd,
         wr_addr => wb_adr_i(ADDR_WIDTH - 2 downto 0),
         rd_addr => sample_addr,
         dout    => sample_data);

-- UserData - byte buffer
   UDB : tx_bitbuf
      generic map (ENABLE_BUFFER => USER_DATA_BUF)
      port map (
         wb_clk_i   => wb_clk_i,
         wb_rst_i   => wb_rst_i,
         buf_wr     => user_data_wr,
         wb_adr_i   => wb_adr_i(4 downto 0),
         wb_dat_i   => wb_dat_i(15 downto 0),
         buf_data_a => user_data_a,
         buf_data_b => user_data_b);

-- ChStat - byte buffer
   CSB : tx_bitbuf
      generic map (ENABLE_BUFFER => CH_STAT_BUF)
      port map (
         wb_clk_i   => wb_clk_i,
         wb_rst_i   => wb_rst_i,
         buf_wr     => ch_status_wr,
         wb_adr_i   => wb_adr_i(4 downto 0),
         wb_dat_i   => wb_dat_i(15 downto 0),
         buf_data_a => ch_stat_a,
         buf_data_b => ch_stat_b);

-- Transmit encoder
   TENC : tx_encoder
      generic map (DATA_WIDTH => DATA_WIDTH,
                   ADDR_WIDTH => ADDR_WIDTH) 
      port map (
         wb_clk_i     => wb_clk_i,
         conf_mode    => conf_mode,     -- sample format
         conf_ratio   => conf_ratio,    -- clock divider
         conf_udaten  => conf_udaten,   -- user data control
         conf_chsten  => conf_chsten,   -- ch. status control
         conf_txdata  => conf_txdata,   -- sample data enable
         conf_txen    => conf_txen,     -- spdif signal enable
         user_data_a  => user_data_a,   -- ch. a user data
         user_data_b  => user_data_b,   -- ch. b user data
         ch_stat_a    => ch_stat_a,     -- ch. a status
         ch_stat_b    => ch_stat_b,     -- ch. b status
         chstat_freq  => chstat_freq,   -- sample freq.
         chstat_gstat => chstat_gstat,  -- generation status
         chstat_preem => chstat_preem,  -- preemphasis status
         chstat_copy  => chstat_copy,   -- copyright bit
         chstat_audio => chstat_audio,  -- data format
         sample_data  => sample_data,   -- audio data
         mem_rd       => mem_rd,        -- sample buffer read
         sample_addr  => sample_addr,   -- address
         evt_lcsbf    => evt_lcsbf,     -- lower ch.st./user data buf empty 
         evt_hcsbf    => evt_hcsbf,     -- higher ch.st/user data buf empty 
         evt_hsbf     => evt_hsbf,      -- higher sample buf empty event
         evt_lsbf     => evt_lsbf,      -- lower sample buf empty event
         spdif_tx_o   => spdif_tx_o);   -- SPDIF output signal

end rtl;

