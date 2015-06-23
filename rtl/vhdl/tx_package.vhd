----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- SPDIF transmitter component package.                         ----
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
-- Revision 1.3  2004/07/19 16:59:31  gedra
-- Added component.
--
-- Revision 1.2  2004/07/14 17:58:49  gedra
-- Added new components.
--
-- Revision 1.1  2004/07/13 18:30:25  gedra
-- Transmitter component declarations.
--
-- 
--

library ieee;
use ieee.std_logic_1164.all;

package tx_package is

-- components used in the transmitter
   
   component gen_control_reg
      generic (DATA_WIDTH      : integer;
               -- note that this vector is (0 to xx), reverse order
               ACTIVE_BIT_MASK : std_logic_vector); 
      port (
         clk       : in  std_logic;     -- clock  
         rst       : in  std_logic;     -- reset
         ctrl_wr   : in  std_logic;     -- control register write       
         ctrl_rd   : in  std_logic;     -- control register read
         ctrl_din  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
         ctrl_dout : out std_logic_vector(DATA_WIDTH - 1 downto 0);
         ctrl_bits : out std_logic_vector(DATA_WIDTH - 1 downto 0)); 
   end component;

   component gen_event_reg
      generic (DATA_WIDTH : integer);
      port (
         clk      : in  std_logic;      -- clock  
         rst      : in  std_logic;      -- reset
         evt_wr   : in  std_logic;      -- event register write  
         evt_rd   : in  std_logic;      -- event register read
         evt_din  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- write data
         event    : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- event vector
         evt_mask : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- irq mask
         evt_en   : in  std_logic;      -- irq enable
         evt_dout : out std_logic_vector(DATA_WIDTH - 1 downto 0);  -- read data
         evt_irq  : out std_logic);     -- interrupt  request
   end component;

   component dpram
      generic (DATA_WIDTH : positive;
               RAM_WIDTH  : positive);
      port (
         clk     : in  std_logic;
         rst     : in  std_logic;       -- reset is optional, not used here
         din     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
         wr_en   : in  std_logic;
         rd_en   : in  std_logic;
         wr_addr : in  std_logic_vector(RAM_WIDTH - 1 downto 0);
         rd_addr : in  std_logic_vector(RAM_WIDTH - 1 downto 0);
         dout    : out std_logic_vector(DATA_WIDTH - 1 downto 0));
   end component;

   component tx_wb_decoder
      generic (DATA_WIDTH : integer;
               ADDR_WIDTH : integer);
      port (
         wb_clk_i     : in  std_logic;  -- wishbone clock
         wb_rst_i     : in  std_logic;  -- reset signal
         wb_sel_i     : in  std_logic;  -- select input
         wb_stb_i     : in  std_logic;  -- strobe input
         wb_we_i      : in  std_logic;  -- write enable
         wb_cyc_i     : in  std_logic;  -- cycle input
         wb_bte_i     : in  std_logic_vector(1 downto 0);  -- burts type extension
         wb_cti_i     : in  std_logic_vector(2 downto 0);  -- cycle type identifier
         wb_adr_i     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);  -- address
         data_out     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- internal bus
         wb_ack_o     : out std_logic;  -- acknowledge
         wb_dat_o     : out std_logic_vector(DATA_WIDTH - 1 downto 0);  -- data out
         version_rd   : out std_logic;  -- Version register read 
         config_rd    : out std_logic;  -- Config register read
         config_wr    : out std_logic;  -- Config register write
         chstat_rd    : out std_logic;  -- Channel Status register read
         chstat_wr    : out std_logic;  -- Channel Status register write
         intmask_rd   : out std_logic;  -- Interrupt mask register read
         intmask_wr   : out std_logic;  -- Interrupt mask register write
         intstat_rd   : out std_logic;  -- Interrupt status register read
         intstat_wr   : out std_logic;  -- Interrupt status register read
         mem_wr       : out std_logic;  -- Sample memory write
         user_data_wr : out std_logic;  -- User data write
         ch_status_wr : out std_logic);                    -- Ch. status write
   end component;

   component tx_ver_reg
      generic (DATA_WIDTH    : integer;
               ADDR_WIDTH    : integer;
               USER_DATA_BUF : integer;
               CH_STAT_BUF   : integer);
      port (
         ver_rd   : in  std_logic;      -- version register read
         ver_dout : out std_logic_vector(DATA_WIDTH - 1 downto 0));
   end component;

   component tx_bitbuf
      generic (ENABLE_BUFFER : integer range 0 to 1);
      port (
         wb_clk_i   : in  std_logic;    -- clock
         wb_rst_i   : in  std_logic;    -- reset
         buf_wr     : in  std_logic;    -- buffer write strobe
         wb_adr_i   : in  std_logic_vector(4 downto 0);   -- address
         wb_dat_i   : in  std_logic_vector(15 downto 0);  -- data
         buf_data_a : out std_logic_vector(191 downto 0);
         buf_data_b : out std_logic_vector(191 downto 0));
   end component;

   component tx_encoder
      generic (DATA_WIDTH : integer range 16 to 32;
               ADDR_WIDTH : integer range 8 to 64); 
      port (
         wb_clk_i     : in  std_logic;  -- clock
         conf_mode    : in  std_logic_vector(3 downto 0);  -- sample format
         conf_ratio   : in  std_logic_vector(7 downto 0);  -- clock divider
         conf_udaten  : in  std_logic_vector(1 downto 0);  -- user data control
         conf_chsten  : in  std_logic_vector(1 downto 0);  -- ch. status control
         conf_txdata  : in  std_logic;  -- sample data enable
         conf_txen    : in  std_logic;  -- spdif signal enable
         user_data_a  : in  std_logic_vector(191 downto 0);  -- ch. a user data
         user_data_b  : in  std_logic_vector(191 downto 0);  -- ch. b user data
         ch_stat_a    : in  std_logic_vector(191 downto 0);  -- ch. a status
         ch_stat_b    : in  std_logic_vector(191 downto 0);  -- ch. b status
         chstat_freq  : in  std_logic_vector(1 downto 0);  -- sample freq.
         chstat_gstat : in  std_logic;  -- generation status
         chstat_preem : in  std_logic;  -- preemphasis status
         chstat_copy  : in  std_logic;  -- copyright bit
         chstat_audio : in  std_logic;  -- data format
         sample_data  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- audio data
         mem_rd       : out std_logic;  -- sample buffer read
         sample_addr  : out std_logic_vector(ADDR_WIDTH - 2 downto 0);  -- address
         evt_lcsbf    : out std_logic;  -- lower ch.st./user data buf empty 
         evt_hcsbf    : out std_logic;  -- higher ch.st/user data buf empty 
         evt_hsbf     : out std_logic;  -- higher sample buf empty event
         evt_lsbf     : out std_logic;  -- lower sample buf empty event
         spdif_tx_o   : out std_logic);
   end component;
   
end tx_package;
