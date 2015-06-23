----------------------------------------------------------------------
----                                                              ----
---- WISHBONE I2S Interface IP Core                               ----
----                                                              ----
---- This file is part of the I2S Interface project               ----
---- http://www.opencores.org/cores/i2s_interface/                ----
----                                                              ----
---- Description                                                  ----
---- I2S receiver. Top level entity for the receiver core,        ----
---- slave mode.                                                  ----
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
-- Revision 1.2  2004/08/06 18:55:43  gedra
-- De-linting.
--
-- Revision 1.1  2004/08/04 14:29:50  gedra
-- Receiver top level, slave mode.
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use work.rx_i2s_pack.all;

entity rx_i2s_tops is
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
      i2s_sd_i  : in  std_logic;        -- I2S data input
      i2s_sck_i : in  std_logic;        -- I2S clock input
      i2s_ws_i  : in  std_logic;        -- I2S word select input
      wb_ack_o  : out std_logic;
      wb_dat_o  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
      rx_int_o  : out std_logic);       -- Interrupt line
end rx_i2s_tops;

architecture rtl of rx_i2s_tops is

   signal data_out, version_dout             : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal version_rd                         : std_logic;
   signal config_rd, config_wr, status_rd    : std_logic;
   signal config_dout, status_dout           : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal config_bits                        : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal intmask_bits, intmask_dout         : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal intmask_rd, intmask_wr             : std_logic;
   signal intstat_events                     : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal intstat_dout                       : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal intstat_rd, intstat_wr             : std_logic;
   signal evt_hsbf, evt_lsbf                 : std_logic;
   signal mem_wr, mem_rd                     : std_logic;
   signal sbuf_rd_adr, sbuf_wr_adr           : std_logic_vector(ADDR_WIDTH - 2 downto 0);
   signal sbuf_dout, sbuf_din, zeros         : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal conf_res                           : std_logic_vector(5 downto 0);
   signal conf_ratio                         : std_logic_vector(7 downto 0);
   signal conf_rswap, conf_rinten, conf_rxen : std_logic;
   signal zero                               : std_logic;
   
begin

-- Data bus or'ing 
   data_out <= version_dout or config_dout or intmask_dout or intstat_dout
               when wb_adr_i(ADDR_WIDTH - 1) = '0' else sbuf_dout;

-- Wishbone bus cycle decoder
   WB : rx_i2s_wbd
      generic map (
         DATA_WIDTH => DATA_WIDTH,
         ADDR_WIDTH => ADDR_WIDTH)
      port map (
         wb_clk_i   => wb_clk_i,
         wb_rst_i   => wb_rst_i,
         wb_sel_i   => wb_sel_i,
         wb_stb_i   => wb_stb_i,
         wb_we_i    => wb_we_i,
         wb_cyc_i   => wb_cyc_i,
         wb_bte_i   => wb_bte_i,
         wb_cti_i   => wb_cti_i,
         wb_adr_i   => wb_adr_i,
         data_out   => data_out,
         wb_ack_o   => wb_ack_o,
         wb_dat_o   => wb_dat_o,
         version_rd => version_rd,
         config_rd  => config_rd,
         config_wr  => config_wr,
         intmask_rd => intmask_rd,
         intmask_wr => intmask_wr,
         intstat_rd => intstat_rd,
         intstat_wr => intstat_wr,
         mem_rd     => mem_rd,
         mem_addr   => sbuf_rd_adr);

-- TxVersion - Version register
   VER : i2s_version
      generic map (
         DATA_WIDTH => DATA_WIDTH,
         ADDR_WIDTH => ADDR_WIDTH,
         IS_MASTER  => 0)
      port map (
         ver_rd   => version_rd,
         ver_dout => version_dout);

-- TxConfig - Configuration register
   CG32 : if DATA_WIDTH = 32 generate
      CONF : gen_control_reg
         generic map (
            DATA_WIDTH      => 32,
            ACTIVE_BIT_MASK => "11100000111111111111110000000000")
         port map (
            clk       => wb_clk_i,
            rst       => wb_rst_i,
            ctrl_wr   => config_wr,
            ctrl_rd   => config_rd,
            ctrl_din  => wb_dat_i,
            ctrl_dout => config_dout,
            ctrl_bits => config_bits);
      conf_res(5 downto 0) <= config_bits(21 downto 16);
   end generate CG32;
   CG16 : if DATA_WIDTH = 16 generate
      CONF : gen_control_reg
         generic map (
            DATA_WIDTH      => 16,
            ACTIVE_BIT_MASK => "1110000011111111")
         port map (
            clk       => wb_clk_i,
            rst       => wb_rst_i,
            ctrl_wr   => config_wr,
            ctrl_rd   => config_rd,
            ctrl_din  => wb_dat_i,
            ctrl_dout => config_dout,
            ctrl_bits => config_bits);
      conf_res(5 downto 0) <= "010000";  -- 16bit only
   end generate CG16;
   conf_ratio(7 downto 0) <= config_bits(15 downto 8);
   conf_rswap             <= config_bits(2);
   conf_rinten            <= config_bits(1);
   conf_rxen              <= config_bits(0);

-- TxIntMask - interrupt mask register
   IM32 : if DATA_WIDTH = 32 generate
      IMASK : gen_control_reg
         generic map (
            DATA_WIDTH      => 32,
            ACTIVE_BIT_MASK => "11000000000000000000000000000000")
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
            ACTIVE_BIT_MASK => "1100000000000000")
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
         evt_en   => conf_rinten,
         evt_irq  => rx_int_o);
   intstat_events(0)                       <= evt_lsbf;  -- lower sample buffer empty
   intstat_events(1)                       <= evt_hsbf;  -- higher sampel buffer empty
   intstat_events(DATA_WIDTH - 1 downto 2) <= (others => '0');

-- Sample buffer memory
   MEM : dpram
      generic map (
         DATA_WIDTH => DATA_WIDTH,
         RAM_WIDTH  => ADDR_WIDTH - 1)
      port map (
         clk     => wb_clk_i,
         rst     => wb_rst_i,
         din     => sbuf_din,
         wr_en   => mem_wr,
         rd_en   => mem_rd,
         wr_addr => sbuf_wr_adr,
         rd_addr => sbuf_rd_adr,
         dout    => sbuf_dout);

-- Receive decoder
   zero  <= '0';
   zeros <= (others => '0');

   DEC : i2s_codec
      generic map (DATA_WIDTH  => DATA_WIDTH,
                   ADDR_WIDTH  => ADDR_WIDTH,
                   IS_MASTER   => 0,
                   IS_RECEIVER => 1)
      port map (
         wb_clk_i     => wb_clk_i,
         conf_res     => conf_res,
         conf_ratio   => conf_ratio,
         conf_swap    => conf_rswap,
         conf_en      => conf_rxen,
         i2s_sd_i     => i2s_sd_i,
         i2s_sck_i    => i2s_sck_i,
         i2s_ws_i     => i2s_ws_i,
         sample_dat_i => zeros,
         sample_dat_o => sbuf_din,
         mem_rdwr     => mem_wr,
         sample_addr  => sbuf_wr_adr,
         evt_hsbf     => evt_hsbf,
         evt_lsbf     => evt_lsbf,
         i2s_sd_o     => open,
         i2s_sck_o    => open,
         i2s_ws_o     => open);   

end rtl;

