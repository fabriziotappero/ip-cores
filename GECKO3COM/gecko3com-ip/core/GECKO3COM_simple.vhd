--  GECKO3COM IP Core
--
--  Copyright (C) 2009 by
--   ___    ___   _   _
--  (  _ \ (  __)( ) ( )
--  | (_) )| (   | |_| |   Bern University of Applied Sciences
--  |  _ < |  _) |  _  |   School of Engineering and
--  | (_) )| |   | | | |   Information Technology
--  (____/ (_)   (_) (_)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details. 
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--  URL to the project description: 
--    http://labs.ti.bfh.ch/gecko/wiki/systems/gecko3com/start
--------------------------------------------------------------------------------
--
--  Author:  Christoph Zimmermann
--  Date of creation:  16:52:52 01/28/2010 
--  Description:
--   	This is the top module for the GECKO3com simple IP core.
--   	Not the one for Xilinx EDK (with PLB bus), for processor less designs.
--
--      This core provides a simple FIFO and register interface to the
--      USB data transfer capabilities of the GECKO3COM/GECKO3main system.
--
--      Look at GECKO3COM_simple.vhd for an example how to use it.
--
--  Target Devices:	Xilinx FPGA's Spartan3 and up or Virtex4 and up.
--  Tool versions: 	11.1
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.GECKO3COM_defines.all;


entity GECKO3COM_simple is
  generic (
    BUSWIDTH : integer := 32);          -- vector size of the FIFO databusses
  port (
    i_nReset : in std_logic;
    i_sysclk : in std_logic;            -- FPGA System CLK

    i_receive_fifo_rd_en     : in  std_logic;
    o_receive_fifo_empty     : out std_logic;
    o_receive_fifo_data      : out std_logic_vector(BUSWIDTH-1 downto 0);
    o_receive_transfersize   : out std_logic_vector(31 downto 0);
    o_receive_end_of_message : out std_logic;
    o_receive_newdata        : out std_logic;

    i_send_fifo_wr_en      : in  std_logic;
    o_send_fifo_full       : out std_logic;
    i_send_fifo_data       : in  std_logic_vector(BUSWIDTH-1 downto 0);
    i_send_transfersize    : in  std_logic_vector(31 downto 0);
    i_send_transfersize_en : in  std_logic;
    i_send_have_more_data  : in  std_logic;
    o_send_data_request    : out std_logic;
    o_send_finished        : out std_logic;

    o_rx : out std_logic;               -- receiving data signalisation
    o_tx : out std_logic;               -- transmitting data signalisation

    -- Interface signals to the EZ-USB FX2
    i_IFCLK    : in    std_logic;  -- GPIF CLK (GPIF is Master and provides the clock)
    i_WRU      : in    std_logic;       -- write from GPIF
    i_RDYU     : in    std_logic;       -- GPIF is ready
    o_WRX      : out   std_logic;       -- To write to GPIF
    o_RDYX     : out   std_logic;       -- IP Core is ready
    b_gpif_bus : inout std_logic_vector(SIZE_DBUS_GPIF-1 downto 0)  -- bidirect data bus
    );
end GECKO3COM_simple;


architecture Behavioral of GECKO3COM_simple is

  -----------------------------------------------------------------------------
  -- COMPONENTS
  -----------------------------------------------------------------------------

  component gpif_com
    port (
      i_nReset   : in    std_logic;
      i_SYSCLK   : in    std_logic;
      o_ABORT    : out   std_logic;
      o_RX       : out   std_logic;
      o_TX       : out   std_logic;
      i_RD_EN    : in    std_logic;
      o_EMPTY    : out   std_logic;
      o_RX_DATA  : out   std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
      i_EOM      : in    std_logic;
      i_WR_EN    : in    std_logic;
      o_FULL     : out   std_logic;
      i_TX_DATA  : in    std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
      i_IFCLK    : in    std_logic;
      i_WRU      : in    std_logic;
      i_RDYU     : in    std_logic;
      o_WRX      : out   std_logic;
      o_RDYX     : out   std_logic;
      b_gpif_bus : inout std_logic_vector(SIZE_DBUS_GPIF-1 downto 0));
  end component;

  component GECKO3COM_simple_datapath
    generic (
      BUSWIDTH : integer);
    port (
      i_nReset                     : in  std_logic;
      i_sysclk                     : in  std_logic;
      i_rx_data                    : in  std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
      o_tx_data                    : out std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
      i_receive_fifo_rd_en         : in  std_logic;
      i_receive_fifo_wr_en         : in  std_logic;
      o_receive_fifo_empty         : out std_logic;
      o_receive_fifo_full          : out std_logic;
      o_receive_fifo_data          : out std_logic_vector(BUSWIDTH-1 downto 0);
      i_receive_fifo_reset         : in  std_logic;
      o_receive_transfersize       : out std_logic_vector(31 downto 0);
      i_receive_transfersize_en    : in  std_logic_vector((32/SIZE_DBUS_GPIF)-1 downto 0);
      o_receive_transfersize_lsb   : out std_logic;
      i_receive_counter_load       : in  std_logic;
      i_receive_counter_en         : in  std_logic;
      o_receive_counter_zero       : out std_logic;
      o_dev_dep_msg_out            : out std_logic;
      o_request_dev_dep_msg_in     : out std_logic;
      i_btag_reg_en                : in  std_logic;
      i_nbtag_reg_en               : in  std_logic;
      o_btag_correct               : out std_logic;
      o_eom_bit_detected           : out std_logic;
      i_send_fifo_rd_en            : in  std_logic;
      i_send_fifo_wr_en            : in  std_logic;
      o_send_fifo_empty            : out std_logic;
      o_send_fifo_full             : out std_logic;
      i_send_fifo_data             : in  std_logic_vector(BUSWIDTH-1 downto 0);
      i_send_fifo_reset            : in  std_logic;
      i_send_transfersize          : in  std_logic_vector(31 downto 0);
      i_send_transfersize_en       : in  std_logic;
      i_send_have_more_data        : in  std_logic;
      i_send_counter_load          : in  std_logic;
      i_send_counter_en            : in  std_logic;
      o_send_counter_zero          : out std_logic;
      i_send_mux_sel               : in  std_logic_vector(2 downto 0);
      i_receive_newdata_set        : in  std_logic;
      o_receive_newdata            : out std_logic;
      i_receive_end_of_message_set : in  std_logic;
      o_receive_end_of_message     : out std_logic;
      i_send_data_request_set      : in  std_logic;
      o_send_data_request          : out std_logic);
  end component;

  component GECKO3COM_simple_fsm
    port (
      i_nReset                     : in  std_logic;
      i_sysclk                     : in  std_logic;
      o_receive_fifo_wr_en         : out std_logic;
      i_receive_fifo_full          : in  std_logic;
      o_receive_fifo_reset         : out std_logic;
      o_receive_transfersize_en    : out std_logic_vector((32/SIZE_DBUS_GPIF)-1 downto 0);
      i_receive_transfersize_lsb   : in  std_logic;
      o_receive_counter_load       : out std_logic;
      o_receive_counter_en         : out std_logic;
      i_receive_counter_zero       : in  std_logic;
      i_dev_dep_msg_out            : in  std_logic;
      i_request_dev_dep_msg_in     : in  std_logic;
      o_btag_reg_en                : out std_logic;
      o_nbtag_reg_en               : out std_logic;
      i_btag_correct               : in  std_logic;
      i_eom_bit_detected           : in  std_logic;
      i_send_transfersize_en       : in  std_logic;
      o_send_fifo_rd_en            : out std_logic;
      i_send_fifo_empty            : in  std_logic;
      o_send_fifo_reset            : out std_logic;
      o_send_counter_load          : out std_logic;
      o_send_counter_en            : out std_logic;
      i_send_counter_zero          : in  std_logic;
      o_send_mux_sel               : out std_logic_vector(2 downto 0);
      o_send_finished              : out std_logic;
      o_receive_newdata_set        : out std_logic;
      o_receive_end_of_message_set : out std_logic;
      o_send_data_request_set      : out std_logic;
      i_gpif_rx                    : in  std_logic;
      i_gpif_rx_empty              : in  std_logic;
      o_gpif_rx_rd_en              : out std_logic;
      i_gpif_tx                    : in  std_logic;
      i_gpif_tx_full               : in  std_logic;
      o_gpif_tx_wr_en              : out std_logic;
      i_gpif_abort                 : in  std_logic;       
      o_gpif_eom                   : out std_logic);
  end component;

  -----------------------------------------------------------------------------
  -- interconection signals
  -----------------------------------------------------------------------------

  -- gpif_com internal signals
  signal s_gpif_abort           : std_logic;
  signal s_gpif_rx_rd_en        : std_logic;
  signal s_gpif_rx_empty        : std_logic;
  signal s_gpif_rx_data         : std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
  signal s_gpif_rx              : std_logic;
  signal s_gpif_eom             : std_logic;
  signal s_gpif_tx_wr_en        : std_logic;
  signal s_gpif_tx_full         : std_logic;
  signal s_gpif_tx_data         : std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
  signal s_gpif_tx              : std_logic;

  -- GECKO3COM_simple_datapath internal signals
  signal s_receive_fifo_wr_en      : std_logic;
  signal s_receive_fifo_empty      : std_logic;
  signal s_receive_fifo_full       : std_logic;
  signal s_receive_fifo_reset      : std_logic;
  signal s_receive_transfersize_en : std_logic_vector((32/SIZE_DBUS_GPIF)-1 downto 0);
  signal s_receive_transfersize_lsb: std_logic;
  signal s_receive_counter_load    : std_logic;
  signal s_receive_counter_en      : std_logic;
  signal s_receive_counter_zero    : std_logic;
  
  signal s_dev_dep_msg_out         : std_logic;
  signal s_request_dev_dep_msg_in  : std_logic;
  signal s_btag_reg_en             : std_logic;
  signal s_nbtag_reg_en            : std_logic;
  signal s_btag_correct            : std_logic;
  signal s_eom_bit_detected        : std_logic;
  
  signal s_send_fifo_rd_en         : std_logic;
  signal s_send_fifo_empty         : std_logic;
  signal s_send_fifo_reset         : std_logic;
  signal s_send_counter_load       : std_logic;
  signal s_send_counter_en         : std_logic;
  signal s_send_counter_zero       : std_logic;
  signal s_send_mux_sel            : std_logic_vector(2 downto 0);

  signal s_receive_newdata_set        : std_logic;
  signal s_receive_end_of_message_set : std_logic;
  signal s_send_data_request_set      : std_logic;
  
begin  -- behaviour

  GPIF_INTERFACE: gpif_com
    port map (
      i_nReset   => i_nReset,
      i_SYSCLK   => i_sysclk,
      o_ABORT    => s_gpif_abort,
      o_RX       => s_gpif_rx,
      o_TX       => s_gpif_tx,
      i_RD_EN    => s_gpif_rx_rd_en,
      o_EMPTY    => s_gpif_rx_empty,
      o_RX_DATA  => s_gpif_rx_data,
      i_EOM      => s_gpif_eom,
      i_WR_EN    => s_gpif_tx_wr_en,
      o_FULL     => s_gpif_tx_full,
      i_TX_DATA  => s_gpif_tx_data,
      i_IFCLK    => i_IFCLK,
      i_WRU      => i_WRU,
      i_RDYU     => i_RDYU,
      o_WRX      => o_WRX,
      o_RDYX     => o_RDYX,
      b_gpif_bus => b_gpif_bus);

  o_rx <= s_gpif_rx;
  o_tx <= s_gpif_tx;

  GECKO3COM_simple_datapath_1 : GECKO3COM_simple_datapath
    generic map (
      BUSWIDTH => BUSWIDTH)
    port map (
      i_nReset                     => i_nReset,
      i_sysclk                     => i_sysclk,
      i_rx_data                    => s_gpif_rx_data,
      o_tx_data                    => s_gpif_tx_data,
      i_receive_fifo_rd_en         => i_receive_fifo_rd_en,
      i_receive_fifo_wr_en         => s_receive_fifo_wr_en,
      o_receive_fifo_empty         => s_receive_fifo_empty,
      o_receive_fifo_full          => s_receive_fifo_full,
      o_receive_fifo_data          => o_receive_fifo_data,
      i_receive_fifo_reset         => s_receive_fifo_reset,
      o_receive_transfersize       => o_receive_transfersize,
      i_receive_transfersize_en    => s_receive_transfersize_en,
      o_receive_transfersize_lsb   => s_receive_transfersize_lsb,
      i_receive_counter_load       => s_receive_counter_load,
      i_receive_counter_en         => s_receive_counter_en,
      o_receive_counter_zero       => s_receive_counter_zero,
      o_dev_dep_msg_out            => s_dev_dep_msg_out,
      o_request_dev_dep_msg_in     => s_request_dev_dep_msg_in,
      i_btag_reg_en                => s_btag_reg_en,
      i_nbtag_reg_en               => s_nbtag_reg_en,
      o_btag_correct               => s_btag_correct,
      o_eom_bit_detected           => s_eom_bit_detected,
      i_send_fifo_rd_en            => s_send_fifo_rd_en,
      i_send_fifo_wr_en            => i_send_fifo_wr_en,
      o_send_fifo_empty            => s_send_fifo_empty,
      o_send_fifo_full             => o_send_fifo_full,
      i_send_fifo_data             => i_send_fifo_data,
      i_send_fifo_reset            => s_send_fifo_reset,
      i_send_transfersize          => i_send_transfersize,
      i_send_transfersize_en       => i_send_transfersize_en,
      i_send_have_more_data        => i_send_have_more_data,
      i_send_counter_load          => s_send_counter_load,
      i_send_counter_en            => s_send_counter_en,
      o_send_counter_zero          => s_send_counter_zero,
      i_send_mux_sel               => s_send_mux_sel,
      i_receive_newdata_set        => s_receive_newdata_set,
      o_receive_newdata            => o_receive_newdata,
      i_receive_end_of_message_set => s_receive_end_of_message_set,
      o_receive_end_of_message     => o_receive_end_of_message,
      i_send_data_request_set      => s_send_data_request_set,
      o_send_data_request          => o_send_data_request);

    o_receive_fifo_empty <= s_receive_fifo_empty;

  GECKO3COM_simple_fsm_1: GECKO3COM_simple_fsm
    port map (
      i_nReset                     => i_nReset,
      i_sysclk                     => i_sysclk,
      o_receive_fifo_wr_en         => s_receive_fifo_wr_en,
      i_receive_fifo_full          => s_receive_fifo_full,
      o_receive_fifo_reset         => s_receive_fifo_reset,
      o_receive_transfersize_en    => s_receive_transfersize_en,
      i_receive_transfersize_lsb   => s_receive_transfersize_lsb,
      o_receive_counter_load       => s_receive_counter_load,
      o_receive_counter_en         => s_receive_counter_en,
      i_receive_counter_zero       => s_receive_counter_zero,
      i_dev_dep_msg_out            => s_dev_dep_msg_out,
      i_request_dev_dep_msg_in     => s_request_dev_dep_msg_in,
      o_btag_reg_en                => s_btag_reg_en,
      o_nbtag_reg_en               => s_nbtag_reg_en,
      i_btag_correct               => s_btag_correct,
      i_eom_bit_detected           => s_eom_bit_detected,
      i_send_transfersize_en       => i_send_transfersize_en,
      o_send_fifo_rd_en            => s_send_fifo_rd_en,
      i_send_fifo_empty            => s_send_fifo_empty,
      o_send_fifo_reset            => s_send_fifo_reset,
      o_send_counter_load          => s_send_counter_load,
      o_send_counter_en            => s_send_counter_en,
      i_send_counter_zero          => s_send_counter_zero,
      o_send_mux_sel               => s_send_mux_sel,
      o_send_finished              => o_send_finished,
      o_receive_newdata_set        => s_receive_newdata_set,
      o_receive_end_of_message_set => s_receive_end_of_message_set,
      o_send_data_request_set      => s_send_data_request_set,
      i_gpif_rx                    => s_gpif_rx,
      i_gpif_rx_empty              => s_gpif_rx_empty,
      o_gpif_rx_rd_en              => s_gpif_rx_rd_en,
      i_gpif_tx                    => s_gpif_tx,
      i_gpif_tx_full               => s_gpif_tx_full,
      o_gpif_tx_wr_en              => s_gpif_tx_wr_en,
      i_gpif_abort                 => s_gpif_abort,
      o_gpif_eom                   => s_gpif_eom);
  
end Behavioral;

