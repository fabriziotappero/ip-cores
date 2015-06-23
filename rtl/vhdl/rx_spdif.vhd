----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- SPDIF receiver. Top level entity for the receiver core.      ----
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
-- Revision 1.6  2004/07/20 17:41:25  gedra
-- Cleaned up synthesis warnings.
--
-- Revision 1.5  2004/07/19 16:58:37  gedra
-- Fixed bug.
--
-- Revision 1.4  2004/07/12 17:06:41  gedra
-- Fixed bug with lock event generation.
--
-- Revision 1.3  2004/07/11 16:19:50  gedra
-- Bug-fix.
--
-- Revision 1.2  2004/06/27 16:16:55  gedra
-- Signal renaming and bug fix.
--
-- Revision 1.1  2004/06/26 14:13:56  gedra
-- Top level entity for receiver.
--
--

library IEEE;
use IEEE.std_logic_1164.all;
use work.rx_package.all;

entity rx_spdif is
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
end rx_spdif;

architecture rtl of rx_spdif is

   signal data_out, ver_dout                          : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal ver_rd, conf_chas, conf_valid               : std_logic;
   signal conf_rxen, conf_sample, evt_en              : std_logic;
   signal conf_blken, conf_valen, conf_useren         : std_logic;
   signal conf_paren, config_rd, config_wr            : std_logic;
   signal conf_mode                                   : std_logic_vector(3 downto 0);
   signal conf_bits, conf_dout                        : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal status_rd, istat_parityb                    : std_logic;
   signal stat_dout                                   : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal imask_bits, imask_dout                      : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal imask_rd, imask_wr, conf_staten             : std_logic;
   signal istat_dout, istat_events                    : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal istat_rd, istat_wr, istat_lock              : std_logic;
   signal istat_lsbf, istat_hsbf, istat_paritya       : std_logic;
   signal istat_cap                                   : std_logic_vector(7 downto 0);
   signal ch_st_cap_rd, ch_st_cap_wr, ch_st_data_rd   : std_logic_vector(7 downto 0);
   signal cap_dout                                    : bus_array;
   signal ch_data, ud_a_en, ud_b_en, cs_a_en, cs_b_en : std_logic;
   signal mem_rd, sample_wr                           : std_logic;
   signal sample_din, sample_dout                     : std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal sbuf_wr_adr, sbuf_rd_adr                    : std_logic_vector(ADDR_WIDTH - 2 downto 0);
   signal lock, rx_frame_start                        : std_logic;
   signal rx_data, rx_data_en, rx_block_start         : std_logic;
   signal rx_channel_a, rx_error, lock_evt            : std_logic;

begin

-- Data bus or'ing 
   DB16 : if DATA_WIDTH = 16 generate
      data_out <= ver_dout or conf_dout or stat_dout or imask_dout or istat_dout
                  when wb_adr_i(ADDR_WIDTH - 1) = '0' else sample_dout;
   end generate DB16;
   DB32 : if DATA_WIDTH = 32 generate
      data_out <= ver_dout or conf_dout or stat_dout or imask_dout or istat_dout or
                  cap_dout(1) or cap_dout(2) or cap_dout(3) or cap_dout(4) or
                  cap_dout(5) or cap_dout(6) or cap_dout(7) or cap_dout(0) when
                  wb_adr_i(ADDR_WIDTH - 1) = '0' else sample_dout;
   end generate DB32;

-- Wishbone bus cycle decoder
   WB : rx_wb_decoder
      generic map (
         DATA_WIDTH => DATA_WIDTH,
         ADDR_WIDTH => ADDR_WIDTH)
      port map (
         wb_clk_i      => wb_clk_i,
         wb_rst_i      => wb_rst_i,
         wb_sel_i      => wb_sel_i,
         wb_stb_i      => wb_stb_i,
         wb_we_i       => wb_we_i,
         wb_cyc_i      => wb_cyc_i,
         wb_bte_i      => wb_bte_i,
         wb_cti_i      => wb_cti_i,
         wb_adr_i      => wb_adr_i,
         data_out      => data_out,
         wb_ack_o      => wb_ack_o,
         wb_dat_o      => wb_dat_o,
         version_rd    => ver_rd,
         config_rd     => config_rd,
         config_wr     => config_wr,
         status_rd     => status_rd,
         intmask_rd    => imask_rd,
         intmask_wr    => imask_wr,
         intstat_rd    => istat_rd,
         intstat_wr    => istat_wr,
         mem_rd        => mem_rd,
         mem_addr      => sbuf_rd_adr,
         ch_st_cap_rd  => ch_st_cap_rd,
         ch_st_cap_wr  => ch_st_cap_wr,
         ch_st_data_rd => ch_st_data_rd);

-- Version register
   VER : rx_ver_reg
      generic map (
         DATA_WIDTH    => DATA_WIDTH,
         ADDR_WIDTH    => ADDR_WIDTH,
         CH_ST_CAPTURE => CH_ST_CAPTURE)
      port map (
         ver_rd   => ver_rd,
         ver_dout => ver_dout);

-- Configuration register
   CG32 : if DATA_WIDTH = 32 generate
      CONF : gen_control_reg
         generic map (
            DATA_WIDTH      => 32,
            ACTIVE_BIT_MASK => "11111100000000001111111100000000")
         port map (
            clk       => wb_clk_i,
            rst       => wb_rst_i,
            ctrl_wr   => config_wr,
            ctrl_rd   => config_rd,
            ctrl_din  => wb_dat_i,
            ctrl_dout => conf_dout,
            ctrl_bits => conf_bits);
      conf_mode(3 downto 0) <= conf_bits(23 downto 20);
      conf_paren            <= conf_bits(19);
      conf_staten           <= conf_bits(18);
      conf_useren           <= conf_bits(17);
      conf_valen            <= conf_bits(16);
   end generate CG32;

   CG16 : if DATA_WIDTH = 16 generate
      CONF : gen_control_reg
         generic map (
            DATA_WIDTH      => 16,
            ACTIVE_BIT_MASK => "1111110000000000")
         port map (
            clk       => wb_clk_i,
            rst       => wb_rst_i,
            ctrl_wr   => config_wr,
            ctrl_rd   => config_rd,
            ctrl_din  => wb_dat_i,
            ctrl_dout => conf_dout,
            ctrl_bits => conf_bits);
      conf_mode(3 downto 0) <= "0000";
      conf_paren            <= '0';
      conf_staten           <= '0';
      conf_useren           <= '0';
      conf_valen            <= '0';
   end generate CG16;

   conf_blken  <= conf_bits(5);
   conf_valid  <= conf_bits(4);
   conf_chas   <= conf_bits(3);
   evt_en      <= conf_bits(2);
   conf_sample <= conf_bits(1);
   conf_rxen   <= conf_bits(0);

-- status register
   STAT : rx_status_reg
      generic map (
         DATA_WIDTH => DATA_WIDTH)
      port map (
         wb_clk_i       => wb_clk_i,
         status_rd      => status_rd,
         lock           => lock,
         chas           => conf_chas,
         rx_block_start => rx_block_start,
         ch_data        => rx_data,
         cs_a_en        => cs_a_en,
         cs_b_en        => cs_b_en,
         status_dout    => stat_dout); 

-- interrupt mask register
   IM32 : if DATA_WIDTH = 32 generate
      IMASK : gen_control_reg
         generic map (
            DATA_WIDTH      => 32,
            ACTIVE_BIT_MASK => "11111000000000001111111100000000")
         port map (
            clk       => wb_clk_i,
            rst       => wb_rst_i,
            ctrl_wr   => imask_wr,
            ctrl_rd   => imask_rd,
            ctrl_din  => wb_dat_i,
            ctrl_dout => imask_dout,
            ctrl_bits => imask_bits);
   end generate IM32;

   IM16 : if DATA_WIDTH = 16 generate
      IMASK : gen_control_reg
         generic map (
            DATA_WIDTH      => 16,
            ACTIVE_BIT_MASK => "1111100000000000")
         port map (
            clk       => wb_clk_i,
            rst       => wb_rst_i,
            ctrl_wr   => imask_wr,
            ctrl_rd   => imask_rd,
            ctrl_din  => wb_dat_i,
            ctrl_dout => imask_dout,
            ctrl_bits => imask_bits);
   end generate IM16;

-- interrupt status register
   ISTAT : gen_event_reg
      generic map (
         DATA_WIDTH => DATA_WIDTH)
      port map (
         clk      => wb_clk_i,
         rst      => wb_rst_i,
         evt_wr   => istat_wr,
         evt_rd   => istat_rd,
         evt_din  => wb_dat_i,
         evt_dout => istat_dout,
         event    => istat_events,
         evt_mask => imask_bits,
         evt_en   => evt_en,
         evt_irq  => rx_int_o);

   istat_events(0)           <= lock_evt;
   istat_events(1)           <= istat_lsbf;
   istat_events(2)           <= istat_hsbf;
   istat_events(3)           <= istat_paritya;
   istat_events(4)           <= istat_parityb;
   istat_events(15 downto 5) <= (others => '0');

   IS32 : if DATA_WIDTH = 32 generate
      istat_events(23 downto 16) <= istat_cap(7 downto 0);
      istat_events(31 downto 24) <= (others => '0');
   end generate IS32;

-- capture registers
   GCAP : if DATA_WIDTH = 32 and CH_ST_CAPTURE > 0 generate
      CAPR : for k in 0 to CH_ST_CAPTURE - 1 generate
         CHST : rx_cap_reg
            port map (
               clk            => wb_clk_i,
               rst            => wb_rst_i,
               cap_ctrl_wr    => ch_st_cap_wr(k),
               cap_ctrl_rd    => ch_st_cap_rd(k),
               cap_data_rd    => ch_st_data_rd(k),
               cap_din        => wb_dat_i,
               cap_dout       => cap_dout(k),
               cap_evt        => istat_cap(k),
               rx_block_start => rx_block_start,
               ch_data        => rx_data,
               ud_a_en        => ud_a_en,
               ud_b_en        => ud_b_en,
               cs_a_en        => cs_a_en,
               cs_b_en        => cs_b_en);
      end generate CAPR;

      -- unused capture registers set to zero
      UCAPR : if CH_ST_CAPTURE < 8 generate
         UC : for k in CH_ST_CAPTURE to 7 generate
            cap_dout(k) <= (others => '0');
         end generate UC;
      end generate UCAPR;
   end generate GCAP;

-- Sample buffer memory
   MEM : dpram
      generic map (
         DATA_WIDTH => DATA_WIDTH,
         RAM_WIDTH  => ADDR_WIDTH - 1)
      port map (
         clk     => wb_clk_i,
         rst     => wb_rst_i,
         din     => sample_din,
         wr_en   => sample_wr,
         rd_en   => mem_rd,
         wr_addr => sbuf_wr_adr,
         rd_addr => sbuf_rd_adr,
         dout    => sample_dout);

-- phase decoder
   PDET : rx_phase_det
      generic map (
         WISHBONE_FREQ => WISHBONE_FREQ)  -- WishBone frequency in MHz
      port map (
         wb_clk_i       => wb_clk_i,
         rxen           => conf_rxen,
         spdif          => spdif_rx_i,
         lock           => lock,
         lock_evt       => lock_evt,
         rx_data        => rx_data,
         rx_data_en     => rx_data_en,
         rx_block_start => rx_block_start,
         rx_frame_start => rx_frame_start,
         rx_channel_a   => rx_channel_a,
         rx_error       => rx_error,
         ud_a_en        => ud_a_en,
         ud_b_en        => ud_b_en,
         cs_a_en        => cs_a_en,
         cs_b_en        => cs_b_en);  

-- frame decoder
   FDEC : rx_decode
      generic map (
         DATA_WIDTH => DATA_WIDTH,
         ADDR_WIDTH => ADDR_WIDTH)
      port map (
         wb_clk_i       => wb_clk_i,
         conf_rxen      => conf_rxen,
         conf_sample    => conf_sample,
         conf_valid     => conf_valid,
         conf_mode      => conf_mode,
         conf_blken     => conf_blken,
         conf_valen     => conf_valen,
         conf_useren    => conf_useren,
         conf_staten    => conf_staten,
         conf_paren     => conf_paren,
         lock           => lock,
         rx_data        => rx_data,
         rx_data_en     => rx_data_en,
         rx_block_start => rx_block_start,
         rx_frame_start => rx_frame_start,
         rx_channel_a   => rx_channel_a,
         wr_en          => sample_wr,
         wr_addr        => sbuf_wr_adr,
         wr_data        => sample_din,
         stat_paritya   => istat_paritya,
         stat_parityb   => istat_parityb,
         stat_lsbf      => istat_lsbf,
         stat_hsbf      => istat_hsbf);

end rtl;

