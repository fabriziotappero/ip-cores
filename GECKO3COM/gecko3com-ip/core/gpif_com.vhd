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
--  Author:  Andreas Habegger, Christoph Zimmermann
--  Date of creation: 8. April 2009
--  Description:
--    GECKO3COM defines the communication between the GECKO3main and a USB
--    Master e.g. a computer.
--
--    This file is the top module, it instantiates all required submodules and
--    connects them together.
--
--  Target Devices:     Xilinx Spartan3 FPGA's
--                      (usage of BlockRam in the Datapath)
--  Tool versions:      11.1
--  Dependencies:
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.GECKO3COM_defines.all;


entity gpif_com is
  port (
    -- interface signals to higher level
    i_nReset  : in  std_logic;          -- asynchronous active low reset
    i_SYSCLK  : in  std_logic;          -- FPGA System CLK
    o_ABORT   : out std_logic;          -- Abort detected, you have to flush the data
    o_RX      : out std_logic;          -- controll LED rx
    o_TX      : out std_logic;          -- controll LED tx
    i_RD_EN   : in  std_logic;          -- read enable
    o_EMPTY   : out std_logic;          -- receive fifo empty
    o_RX_DATA : out std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);  -- receive data
    i_EOM     : in  std_logic;
    i_WR_EN   : in  std_logic;          -- write enable
    o_FULL    : out std_logic;          -- send fifo full
    i_TX_DATA : in  std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);  -- send data

    -- GPIF connections, to be connected to FPGA pins
    i_IFCLK    : in    std_logic;       -- GPIF CLK (GPIF is Master and provides the clock)
    i_WRU      : in    std_logic;       -- write from GPIF
    i_RDYU     : in    std_logic;       -- GPIF is ready
    o_WRX      : out   std_logic;       -- To write to GPIF
    o_RDYX     : out   std_logic;       -- IP Core is ready
    b_gpif_bus : inout std_logic_vector(SIZE_DBUS_GPIF-1 downto 0));  -- bidirect data bus
end gpif_com;



architecture structure of gpif_com is
  
  -- interconection signals
  signal s_FIFOrst, s_WRX, s_RDYX         : std_logic;

  signal s_ABORT_FSM, s_ABORT_TMP         : std_logic;
  signal s_RX_FSM, s_RX_TMP               : std_logic;
  signal s_TX_FSM, s_TX_TMP               : std_logic;
  signal s_EOM, s_EOM_TMP, s_EOM_FF       : std_logic;  -- End of message
  signal s_X2U_FULL_IFCLK, s_X2U_FULL_TMP : std_logic;
  
  -- USB to Xilinx (U2X)
  signal s_U2X_WR_EN,
    s_U2X_RD_EN,
    s_U2X_FULL,
    s_U2X_AM_FULL,
    s_U2X_EMPTY,
    s_U2X_AM_EMPTY  : std_logic;
  signal s_U2X_DATA : std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
  
  -- Xilinx to USB (X2U)
  signal s_X2U_WR_EN,
    s_X2U_RD_EN,
    s_X2U_FULL,
    s_X2U_AM_FULL,
    s_X2U_EMPTY,
    s_X2U_AM_EMPTY  : std_logic;
  signal s_X2U_DATA : std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);

  signal s_dbus_out_mux_sel : std_logic;
  
  -----------------------------------------------------------------------------
  -- data bus
  -----------------------------------------------------------------------------

  -- data signals
  signal s_dbus_trans_dir : std_logic;
  signal s_dbus_in        : std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
  signal s_dbus_out       : std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);

  signal s_fifo_out       : std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
  signal s_fifo_old       : std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
  
  -----------------------------------------------------------------------------
  -- COMPONENTS
  -----------------------------------------------------------------------------

  -- FSM GPIF
  component gpif_com_fsm
    port (
      i_nReset           : in  std_logic;
      i_IFCLK            : in  std_logic;
      i_WRU              : in  std_logic;
      i_RDYU             : in  std_logic;
      i_EOM              : in  std_logic;
      i_U2X_FULL         : in  std_logic;
      i_U2X_AM_FULL      : in  std_logic;
      i_X2U_AM_EMPTY     : in  std_logic;
      i_X2U_EMPTY        : in  std_logic;
      o_dbus_out_mux_sel : out std_logic;
      o_bus_trans_dir    : out std_logic;
      o_U2X_WR_EN        : out std_logic;
      o_X2U_RD_EN        : out std_logic;
      o_FIFOrst          : out std_logic;
      o_WRX              : out std_logic;
      o_RDYX             : out std_logic;
      o_ABORT            : out std_logic;
      o_RX               : out std_logic;
      o_TX               : out std_logic);
  end component;

  -- FIFO dualclock to cross the clock domain between the GPIF and the FPGA
  component fifo_dualclock
    port (
      i_din          : IN  std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
      i_rd_clk       : IN  std_logic;
      i_rd_en        : IN  std_logic;
      i_rst          : IN  std_logic;
      i_wr_clk       : IN  std_logic;
      i_wr_en        : IN  std_logic;
      o_almost_empty : OUT std_logic;
      o_almost_full  : OUT std_logic;
      o_dout         : OUT std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
      o_empty        : OUT std_logic;
      o_full         : OUT std_logic);
  end component;

  
begin

  -----------------------------------------------------------------------------
  -- Port map
  -----------------------------------------------------------------------------

  F_IN : fifo_dualclock
    port map (
      i_din          => s_dbus_in,
      i_rd_clk       => i_SYSCLK,
      i_rd_en        => s_U2X_RD_EN,
      i_rst          => s_FIFOrst,
      i_wr_clk       => i_IFCLK ,
      i_wr_en        => s_U2X_WR_EN,
      o_almost_empty => s_U2X_AM_EMPTY,
      o_almost_full  => s_U2X_AM_FULL,
      o_dout         => s_U2X_DATA,
      o_empty        => s_U2X_EMPTY,
      o_full         => s_U2X_FULL
      );


  F_OUT : fifo_dualclock
    port map (
      i_din          => s_X2U_DATA,
      i_rd_clk       => i_IFCLK,
      i_rd_en        => s_X2U_RD_EN,
      i_rst          => s_FIFOrst,
      i_wr_clk       => i_SYSCLK,
      i_wr_en        => s_X2U_WR_EN,
      o_almost_empty => s_X2U_AM_EMPTY,
      o_almost_full  => s_X2U_AM_FULL,
      o_dout         => s_fifo_out,
      o_empty        => s_X2U_EMPTY,
      o_full         => s_X2U_FULL
      );


  FSM_GPIF : gpif_com_fsm
    port map (
      i_nReset           => i_nReset,
      i_IFCLK            => i_IFCLK,
      i_WRU              => i_WRU,
      i_RDYU             => i_RDYU,
      --i_EOM            => s_EOM,
      i_EOM              => s_EOM_FF,
      i_U2X_FULL         => s_U2X_FULL,
      i_U2X_AM_FULL      => s_U2X_AM_FULL,
      i_X2U_AM_EMPTY     => s_X2U_AM_EMPTY,
      i_X2U_EMPTY        => s_X2U_EMPTY,
      o_U2X_WR_EN        => s_U2X_WR_EN,
      o_X2U_RD_EN        => s_X2U_RD_EN,
      o_dbus_out_mux_sel => s_dbus_out_mux_sel,
      o_FIFOrst          => s_FIFOrst,
      o_bus_trans_dir    => s_dbus_trans_dir,
      o_WRX              => s_WRX,
      o_RDYX             => s_RDYX,
      o_ABORT            => s_ABORT_FSM,
      o_RX               => s_RX_FSM,
      o_TX               => s_TX_FSM
      );


  
  s_U2X_RD_EN  <= i_RD_EN;
  o_EMPTY   <= s_U2X_EMPTY;
  o_RX_DATA <= s_U2X_DATA;

  s_X2U_WR_EN <= i_WR_EN;
  o_FULL    <= s_X2U_FULL;
  s_X2U_DATA <= i_TX_DATA;

  o_WRX <= s_WRX;
  o_RDYX <= s_RDYX;

  -- Double buffer the ABORT, RX and TX signal to avoid metastability
  double_buf_sig : process (i_SYSCLK, i_nReset)
  begin
    if i_nReset = '0' then
      o_ABORT     <= '0';
      s_ABORT_TMP <= '0';
      o_TX        <= '0';
      s_TX_TMP    <= '0';
      o_RX        <= '0';
      s_RX_TMP    <= '0';
    elsif rising_edge(i_SYSCLK) then
      o_ABORT     <= s_ABORT_TMP;
      s_ABORT_TMP <= s_ABORT_FSM;
      o_TX        <= s_TX_TMP;
      s_TX_TMP    <= s_TX_FSM;
      o_RX        <= s_RX_TMP;
      s_RX_TMP    <= s_RX_FSM;
    end if;
  end process double_buf_sig;

  -- Double buffer the s_EOM and s_X2U_FULL_IFCLK signal to avoid metastability
  double_buf_ifclk : process (i_IFCLK, i_nReset)
  begin
    if i_nReset = '0' then
      s_EOM <= '0';
    elsif rising_edge(i_IFCLK) then
      s_EOM     <= s_EOM_TMP;
      s_EOM_TMP <= i_EOM;
    end if;
  end process double_buf_ifclk;

  --purpose: EOM bit flip-flop
  --type   : sequential
  --inputs : i_IFCLK, i_nReset, s_EOM, s_X2U_EMPTY
  --outputs: s_EOM_FF
  EOM_FF: process (i_IFCLK, i_nReset)
  begin  -- process EOM_FF
    if i_nReset = '0' then                -- asynchronous reset (active low)
      s_EOM_FF <= '0';
    elsif i_IFCLK'event and i_IFCLK = '1' then  -- rising clock edge
      if s_EOM = '1' then
        s_EOM_FF <= '1';
      end if;
      if s_X2U_EMPTY = '1' and s_TX_FSM = '0' then
        s_EOM_FF <= '0';
      end if;
    end if;
  end process EOM_FF;
  
  -----------------------------------------------------------------------------
  -- Data bus access
  -----------------------------------------------------------------------------

  -- purpose: to handle the access on the bidirectional bus
  -- type   : combinational
  -- inputs : s_bus_trans_dir
  -- outputs: 
  bus_access : process (s_dbus_trans_dir, s_dbus_out)
  begin  -- process bus_access
    if s_dbus_trans_dir = '1' then
      b_gpif_bus <= s_dbus_out;
    else
      b_gpif_bus <= (others => 'Z');
    end if;
  end process bus_access;

  -- buffer the gpif bus input signals to avoid that the last word in the
  -- usb to xilinx transfer is read twice.
  buf_input : process (i_IFCLK)
  begin
    if rising_edge(i_IFCLK) then
      s_dbus_in <= b_gpif_bus;

      if s_X2U_RD_EN = '1' then
        s_fifo_old <= s_fifo_out; 
      end if;
    end if;
  end process buf_input;

  -- purpose: multiplexer to select two older copies of fifo data
  -- type   : combinational
  -- inputs : s_dbus_out_mux_sel, s_fifo_old, s_fifo_out
  -- outputs: s_dbus_out
  dbus_out_mux: process (s_dbus_out_mux_sel, s_fifo_old, s_fifo_out)
  begin  -- process dbus_out_mux
    case s_dbus_out_mux_sel is
      when '0' => s_dbus_out <= s_fifo_out;
      when '1' => s_dbus_out <= s_fifo_old;
      when others => s_dbus_out <= s_fifo_out;
    end case;
  end process dbus_out_mux;
  
end structure;
