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
--      This is the top module for the GECKO3com simple IP core.
--      Not the one for Xilinx EDK (with PLB bus), for processor less designs.
--
--      This core provides a simple FIFO and register interface to the
--      USB data transfer capabilities of the GECKO3COM/GECKO3main system.
--
--      Look at GECKO3COM_simple_test.vhd for an example how to use it.
--
--  Target Devices:     general
--  Tool versions:      11.1
--  Dependencies:       Xilinx FPGA's Spartan3 and up or Virtex4 and up.
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use work.GECKO3COM_defines.all;


entity GECKO3COM_simple_datapath is

  generic (
    BUSWIDTH : integer := 16);

  port (
    i_nReset  : in  std_logic;
    i_sysclk  : in  std_logic;
    i_rx_data : in  std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
    o_tx_data : out std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);

    i_receive_fifo_rd_en       : in  std_logic;
    i_receive_fifo_wr_en       : in  std_logic;
    o_receive_fifo_empty       : out std_logic;
    o_receive_fifo_full        : out std_logic;
    o_receive_fifo_data        : out std_logic_vector(BUSWIDTH-1 downto 0);
    i_receive_fifo_reset       : in  std_logic;
    o_receive_transfersize     : out std_logic_vector(31 downto 0);
    i_receive_transfersize_en  : in  std_logic_vector((32/SIZE_DBUS_GPIF)-1 downto 0);
    o_receive_transfersize_lsb : out std_logic;
    i_receive_counter_load     : in  std_logic;
    i_receive_counter_en       : in  std_logic;
    o_receive_counter_zero     : out std_logic;
    o_dev_dep_msg_out          : out std_logic;
    o_request_dev_dep_msg_in   : out std_logic;
    i_btag_reg_en              : in  std_logic;
    i_nbtag_reg_en             : in  std_logic;
    o_btag_correct             : out std_logic;
    o_eom_bit_detected         : out std_logic;

    i_send_fifo_rd_en      : in  std_logic;
    i_send_fifo_wr_en      : in  std_logic;
    o_send_fifo_empty      : out std_logic;
    o_send_fifo_full       : out std_logic;
    i_send_fifo_data       : in  std_logic_vector(BUSWIDTH-1 downto 0);
    i_send_fifo_reset      : in  std_logic;
    i_send_transfersize    : in  std_logic_vector(31 downto 0);
    i_send_transfersize_en : in  std_logic;
    i_send_have_more_data  : in  std_logic;
    i_send_counter_load    : in  std_logic;
    i_send_counter_en      : in  std_logic;
    o_send_counter_zero    : out std_logic;
    i_send_mux_sel         : in  std_logic_vector(2 downto 0);

    i_receive_newdata_set        : in  std_logic;
    o_receive_newdata            : out std_logic;
    i_receive_end_of_message_set : in  std_logic;
    o_receive_end_of_message     : out std_logic;
    i_send_data_request_set      : in  std_logic;
    o_send_data_request          : out std_logic);

end GECKO3COM_simple_datapath;

architecture behaviour of GECKO3COM_simple_datapath is

  -----------------------------------------------------------------------------
  -- COMPONENTS
  -----------------------------------------------------------------------------

  component receive_fifo
    generic (
      BUSWIDTH : integer);
    port (
      i_din   : in  std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
      i_clk   : in  std_logic;
      i_rd_en : in  std_logic;
      i_rst   : in  std_logic;
      i_wr_en : in  std_logic;
      o_dout  : out std_logic_vector(BUSWIDTH-1 downto 0);
      o_empty : out std_logic;
      o_full  : out std_logic);
  end component;

  component send_fifo
    generic (
      BUSWIDTH : integer);
    port (
      i_din   : in  std_logic_vector(BUSWIDTH-1 downto 0);
      i_clk   : in  std_logic;
      i_rd_en : in  std_logic;
      i_rst   : in  std_logic;
      i_wr_en : in  std_logic;
      o_dout  : out std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
      o_empty : out std_logic;
      o_full  : out std_logic);
  end component;


  -----------------------------------------------------------------------------
  -- interconection signals
  -----------------------------------------------------------------------------

  signal s_receive_transfersize  : std_logic_vector(31 downto 0);
  signal s_send_transfersize_reg : std_logic_vector(31 downto 0);

  signal s_receive_transfersize_count : std_logic_vector(30 downto 0);
  signal s_send_transfersize_count    : std_logic_vector(30 downto 0);

  signal s_receive_fifo_empty : std_logic;

  signal s_send_fifo_data     : std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
  signal s_btag, s_nbtag, s_msg_id : std_logic_vector(7 downto 0);

begin  -- behaviour

  receive_fifo_1 : receive_fifo
    generic map (
      BUSWIDTH => BUSWIDTH)
    port map (
      i_din   => i_rx_data,
      i_clk   => i_sysclk,
      i_rd_en => i_receive_fifo_rd_en,
      i_rst   => i_receive_fifo_reset,
      i_wr_en => i_receive_fifo_wr_en,
      o_dout  => o_receive_fifo_data,
      o_empty => s_receive_fifo_empty,
      o_full  => o_receive_fifo_full);

  send_fifo_1 : send_fifo
    generic map (
      BUSWIDTH => BUSWIDTH)
    port map (
      i_din   => i_send_fifo_data,
      i_clk   => i_sysclk,
      i_rd_en => i_send_fifo_rd_en,
      i_rst   => i_send_fifo_reset,
      i_wr_en => i_send_fifo_wr_en,
      o_dout  => s_send_fifo_data,
      o_empty => o_send_fifo_empty,
      o_full  => o_send_fifo_full);


  o_receive_fifo_empty <= s_receive_fifo_empty;

  -- purpose: process to fill the 32 bit receive_transfersize register with 8
  --          or 16 bit wide input data.
  -- type   : sequential
  -- inputs : i_sysclk, i_nReset, i_rx_data, i_receive_transfersize_en
  receive_transfersize : process (i_sysclk, i_nReset)
  begin  -- process registers
    if i_nReset = '0' then              -- asynchronous reset (active low)
      s_receive_transfersize <= (others => '0');
    elsif i_sysclk'event and i_sysclk = '1' then  -- rising clock edge
      if i_receive_transfersize_en(0) = '1' then
        s_receive_transfersize(15 downto 0) <= i_rx_data;
      end if;
      if i_receive_transfersize_en(1) = '1' then
        s_receive_transfersize(31 downto 16) <= i_rx_data;
      end if;
    end if;
  end process receive_transfersize;

  o_receive_transfersize <= s_receive_transfersize;
  o_receive_transfersize_lsb <= s_receive_transfersize(0);


  -- purpose: 32 bit send_transfersize register
  -- type   : sequential
  -- inputs : i_sysclk, i_nReset, i_send_transfersize, i_receive_transfersize_en
  send_transfersize : process (i_sysclk, i_nReset)
  begin  -- process registers
    if i_nReset = '0' then              -- asynchronous reset (active low)
      s_send_transfersize_reg <= (others => '0');
    elsif i_sysclk'event and i_sysclk = '1' then  -- rising clock edge
      if i_send_transfersize_en = '1' then
        s_send_transfersize_reg <= i_send_transfersize;
      end if;
    end if;
  end process send_transfersize;


  -- purpose: down counter for the receive transfer size
  -- type   : sequential
  -- inputs : i_sysclk, i_nReset, s_reveive_transfersize,
  --          i_receive_transfersize_en
  -- outputs: s_receive_transfersize_count
  receive_counter : process (i_sysclk, i_nReset)
  begin  -- process receive_counter
    if i_nReset = '0' then              -- asynchronous reset (active low)
      s_receive_transfersize_count <= (others => '0');
    elsif i_sysclk'event and i_sysclk = '1' then  -- rising clock edge
      if i_receive_counter_load = '1' then
        s_receive_transfersize_count <= s_receive_transfersize(31 downto 1);
      elsif i_receive_counter_en = '1' then
        s_receive_transfersize_count <= s_receive_transfersize_count - 1;
      else
        s_receive_transfersize_count <= s_receive_transfersize_count;
      end if;
    end if;
  end process receive_counter;

  o_receive_counter_zero <=
    '1' when s_receive_transfersize_count = "000000000000000000000000000000"
    else '0';


  -- purpose: down counter for the send transfer size
  -- type   : sequential
  -- inputs : i_sysclk, i_nReset, s_send_transfersize_reg,
  --          i_send_transfersize_en
  -- outputs: s_send_transfersize_count
  send_counter : process (i_sysclk, i_nReset)
  begin  -- process send_counter
    if i_nReset = '0' then              -- asynchronous reset (active low)
      s_send_transfersize_count <= (others => '0');
    elsif i_sysclk'event and i_sysclk = '1' then  -- rising clock edge
      if i_send_counter_load = '1' then
        s_send_transfersize_count <= s_send_transfersize_reg(31 downto 1);
      elsif i_send_counter_en = '1' then
        s_send_transfersize_count <= s_send_transfersize_count - 1;
      else
        s_send_transfersize_count <= s_send_transfersize_count;
      end if;
    end if;
  end process send_counter;

  o_send_counter_zero <=
    '1' when s_send_transfersize_count = "000000000000000000000000000000"
    else '0';


  -- purpose: registers to store the btag and inverse btag
  -- type   : sequential
  -- inputs : i_sysclk, i_nReset, i_btag_reg_en, i_nbtag_reg_en
  --          i_rx_data
  -- outputs: s_btag, s_nbtag
  btag_register : process (i_sysclk, i_nReset)
  begin  -- process btag_register
    if i_nReset = '0' then              -- asynchronous reset (active low)
      s_btag   <= (others => '0');
      s_msg_id <= (others => '0');
      s_nbtag  <= (others => '0');
    elsif i_sysclk'event and i_sysclk = '1' then  -- rising clock edge
      if i_btag_reg_en = '1' then
        s_btag   <= i_rx_data(15 downto 8);
        s_msg_id <= i_rx_data(7 downto 0);
      end if;
      if i_nbtag_reg_en = '1' then
        s_nbtag <= i_rx_data(7 downto 0);
      end if;
    end if;
  end process btag_register;

  o_btag_correct <=
    '1' when s_btag = not s_nbtag else
    '0';

  
  o_dev_dep_msg_out <=
    '1' when s_msg_id(7 downto 0) = x"01" else
    '0';

  o_request_dev_dep_msg_in <=
    '1' when s_msg_id(7 downto 0) = x"02" else
    '0';

  o_eom_bit_detected <=
    '1' when i_rx_data(7 downto 0) = b"00000001" else
    '0';


  -- purpose: mulitiplexer to construct the tmc header structure
  -- type   : combinational
  -- inputs : i_send_mux_sel, i_send_have_more_data, s_btag, s_nbtag,
  --          s_send_fifo_data, s_send_transfersize_reg
  -- outputs: o_tx_data
  tx_data_mux : process (i_send_mux_sel, i_send_have_more_data, s_btag,
                         s_msg_id, s_nbtag, s_send_fifo_data,
                         s_send_transfersize_reg)
  begin  -- process tx_data_mux
    case i_send_mux_sel is
      when "000"  => o_tx_data <= s_btag & s_msg_id; -- MsgID and stored bTag
      when "001"  => o_tx_data <= x"00" & s_nbtag; -- inverted bTag and Reserved
      when "010"  => o_tx_data <= s_send_transfersize_reg(15 downto 0);
      when "011"  => o_tx_data <= s_send_transfersize_reg(31 downto 16);
                    --TransferAttributes EOM bit:
      when "100"  => o_tx_data <= b"000000000000000" & not i_send_have_more_data;
      when "101"  => o_tx_data <= x"0000";  -- Header byte 10 and 11, Reserved
      when "110"  => o_tx_data <= s_send_fifo_data;  -- message data
      when others => o_tx_data <= s_btag & s_msg_id; -- MsgID and stored bTag
    end case;
  end process tx_data_mux;


  -- purpose: set and reset behavour for the status flags
  -- type   : sequential
  -- inputs : i_sysclk, i_nReset, i_receive_newdata_set,
  --          i_receive_end_of_message_set, s_send_data_request_set,
  --          i_receive_fifo_rd_en, s_receive_fifo_empty, i_send_fifo_wr_en
  -- outputs: o_receive_newdata, o_receive_end_of_message, o_send_data_request
  gecko3com_simple_flags : process (i_sysclk, i_nReset)
    variable v_receive_fifo_empty_old : std_logic;
  begin  -- process gecko3com_simple_flags
    if i_nReset = '0' then              -- asynchronous reset (active low)
      o_receive_newdata        <= '0';
      o_receive_end_of_message <= '0';
      o_send_data_request      <= '0';
      v_receive_fifo_empty_old := '0';
    elsif i_sysclk'event and i_sysclk = '1' then  -- rising clock edge
      if i_receive_newdata_set = '1' then
        o_receive_newdata <= '1';
      end if;
      if i_receive_fifo_rd_en = '1' then
        o_receive_newdata <= '0';
      end if;

      if i_receive_end_of_message_set = '1' then
        o_receive_end_of_message <= '1';
      end if;
      if s_receive_fifo_empty = '1' and v_receive_fifo_empty_old = '0' then
        o_receive_end_of_message <= '0';
      end if;
      v_receive_fifo_empty_old := s_receive_fifo_empty;

      if i_send_data_request_set = '1' then
        o_send_data_request <= '1';
      end if;
      if i_send_fifo_wr_en = '1' then
        o_send_data_request <= '0';
      end if;
    end if;
  end process gecko3com_simple_flags;

  
end behaviour;
