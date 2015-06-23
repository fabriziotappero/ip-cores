----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- SPDIF transmitter: Wishbone bus cycle decoder.               ----
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
-- Revision 1.4  2005/03/27 14:05:22  gedra
-- Fix: Include MSB of address bus in register strobe generation
--
-- Revision 1.3  2004/07/17 17:20:50  gedra
-- Changed address of channel status buffers.
--
-- Revision 1.2  2004/07/14 17:59:28  gedra
-- Changed write signal for status buffers.
--
-- Revision 1.1  2004/07/13 18:29:50  gedra
-- Transmitter Wishbone bus cycle decoder.
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_wb_decoder is
   generic (DATA_WIDTH : integer;
            ADDR_WIDTH : integer);
   port (
      wb_clk_i     : in  std_logic;     -- wishbone clock
      wb_rst_i     : in  std_logic;     -- reset signal
      wb_sel_i     : in  std_logic;     -- select input
      wb_stb_i     : in  std_logic;     -- strobe input
      wb_we_i      : in  std_logic;     -- write enable
      wb_cyc_i     : in  std_logic;     -- cycle input
      wb_bte_i     : in  std_logic_vector(1 downto 0);  -- burts type extension
      wb_cti_i     : in  std_logic_vector(2 downto 0);  -- cycle type identifier
      wb_adr_i     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);  -- address
      data_out     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- internal bus
      wb_ack_o     : out std_logic;     -- acknowledge
      wb_dat_o     : out std_logic_vector(DATA_WIDTH - 1 downto 0);  -- data out
      version_rd   : out std_logic;     -- Version register read 
      config_rd    : out std_logic;     -- Config register read
      config_wr    : out std_logic;     -- Config register write
      chstat_rd    : out std_logic;     -- Channel Status register read
      chstat_wr    : out std_logic;     -- Channel Status register write
      intmask_rd   : out std_logic;     -- Interrupt mask register read
      intmask_wr   : out std_logic;     -- Interrupt mask register write
      intstat_rd   : out std_logic;     -- Interrupt status register read
      intstat_wr   : out std_logic;     -- Interrupt status register read
      mem_wr       : out std_logic;     -- Sample memory write
      user_data_wr : out std_logic;     -- User data write
      ch_status_wr : out std_logic);    -- Ch. status write
end tx_wb_decoder;

architecture rtl of tx_wb_decoder is
   
   constant REG_TXVERSION : std_logic_vector(6 downto 0) := "0000000";
   constant REG_TXCONFIG  : std_logic_vector(6 downto 0) := "0000001";
   constant REG_TXCHSTAT  : std_logic_vector(6 downto 0) := "0000010";
   constant REG_TXINTMASK : std_logic_vector(6 downto 0) := "0000011";
   constant REG_TXINTSTAT : std_logic_vector(6 downto 0) := "0000100";
   signal iack, iwr, ird  : std_logic;
   signal acnt            : integer range 0 to 2**(ADDR_WIDTH - 1) - 1;
   --signal all_ones : std_logic_vector(ADDR_WIDTH - 1 downto 0);
   signal rdout           : std_logic_vector(DATA_WIDTH - 1 downto 0);
   
begin

   wb_ack_o <= iack;

-- acknowledge generation
   ACK : process (wb_clk_i, wb_rst_i)
   begin
      if wb_rst_i = '1' then
         iack <= '0';
      elsif rising_edge(wb_clk_i) then
         if wb_cyc_i = '1' and wb_sel_i = '1' and wb_stb_i = '1' then
            case wb_cti_i is
               when "010" =>            -- incrementing burst
                  case wb_bte_i is      -- burst extension
                     when "00" =>       -- linear burst
                        iack <= '1';
                     when others =>  -- all other treated assert classic cycle
                        iack <= not iack;
                  end case;
               when "111" =>            -- end of burst
                  iack <= not iack;
               when others =>        -- all other treated assert classic cycle 
                  iack <= not iack;
            end case;
         else
            iack <= '0';
         end if;
      end if;
   end process ACK;

-- write generation      
   WR : process (wb_clk_i, wb_rst_i)
   begin
      if wb_rst_i = '1' then
         iwr <= '0';
      elsif rising_edge(wb_clk_i) then
         if wb_cyc_i = '1' and wb_sel_i = '1' and wb_stb_i = '1' and
            wb_we_i = '1' then
            case wb_cti_i is
               when "010" =>            -- incrementing burst
                  case wb_bte_i is      -- burst extension
                     when "00" =>       -- linear burst
                        iwr <= '1';
                     when others =>     -- all other treated as classic cycle
                        iwr <= not iwr;
                  end case;
               when "111" =>            -- end of burst
                  iwr <= not iwr;
               when others =>        -- all other treated as classic cycle   
                  iwr <= not iwr;
            end case;
         else
            iwr <= '0';
         end if;
      end if;
   end process WR;

-- read generation
   ird <= '1' when wb_cyc_i = '1' and wb_sel_i = '1' and wb_stb_i = '1' and
          wb_we_i = '0' else '0';

   wb_dat_o <= data_out when wb_adr_i(ADDR_WIDTH - 1) = '1' else rdout;

   DREG : process (wb_clk_i)            -- clock data from registers
   begin
      if rising_edge(wb_clk_i) then
         rdout <= data_out;
      end if;
   end process DREG;

-- read and write strobe generation

   version_rd <= '1' when wb_adr_i(6 downto 0) = REG_TXVERSION and ird = '1'
                 and wb_adr_i(ADDR_WIDTH - 1) = '0' else '0';
   config_rd <= '1' when wb_adr_i(6 downto 0) = REG_TXCONFIG and ird = '1'
                and wb_adr_i(ADDR_WIDTH - 1) = '0' else '0';
   config_wr <= '1' when wb_adr_i(6 downto 0) = REG_TXCONFIG and iwr = '1'
                and wb_adr_i(ADDR_WIDTH - 1) = '0' else '0';
   chstat_rd <= '1' when wb_adr_i(6 downto 0) = REG_TXCHSTAT and ird = '1'
                and wb_adr_i(ADDR_WIDTH - 1) = '0' else '0';
   chstat_wr <= '1' when wb_adr_i(6 downto 0) = REG_TXCHSTAT and iwr = '1'
                and wb_adr_i(ADDR_WIDTH - 1) = '0' else '0';
   intmask_rd <= '1' when wb_adr_i(6 downto 0) = REG_TXINTMASK and ird = '1'
                 and wb_adr_i(ADDR_WIDTH - 1) = '0' else '0';
   intmask_wr <= '1' when wb_adr_i(6 downto 0) = REG_TXINTMASK and iwr = '1'
                 and wb_adr_i(ADDR_WIDTH - 1) = '0' else '0';
   intstat_rd <= '1' when wb_adr_i(6 downto 0) = REG_TXINTSTAT and ird = '1'
                 and wb_adr_i(ADDR_WIDTH - 1) = '0' else '0';
   intstat_wr <= '1' when wb_adr_i(6 downto 0) = REG_TXINTSTAT and iwr = '1'
                 and wb_adr_i(ADDR_WIDTH - 1) = '0' else '0';
   mem_wr <= '1' when wb_adr_i(ADDR_WIDTH - 1) = '1' and iwr = '1' else '0';

-- user data/ch. status register write strobes
   user_data_wr <= '1' when iwr = '1' and
                   to_integer(unsigned(wb_adr_i)) > 31 and
                   to_integer(unsigned(wb_adr_i)) < 56 else '0';
   
   ch_status_wr <= '1' when iwr = '1' and
                   to_integer(unsigned(wb_adr_i)) > 63 and
                   to_integer(unsigned(wb_adr_i)) < 88 else '0';
   
end rtl;
