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
--  Author: Christoph Zimmermann
--  Date of creation: 8. April 2009
--  Description:
--    First test scenario for the GECKO3com IP core. 
--    This module (to be implemented as top module) is used to test the
--    low-level communication between the GPIF from the EZ-USB and the FPGA.
--    For this, it instantiates the the gpif_com module, reads all the 
--    received data from the FIFO (and puts them to nowhere) and writes a pre
--    defined USB TMC response packet to the send FIFO.
--
--    If you would like to change the USB TMC response, you have to change the 
--    ROM content in this file (don't forget to adjust the the transfer size 
--    field AND the counter limit).
--
--  Target Devices:     Xilinx Spartan3 FPGA's (usage of BlockRam in the
--                      Datapath)
--  Tool versions:      11.1
--  Dependencies:
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.GECKO3COM_defines.all;

entity gpif_com_test is
  port (
    i_nReset   : in    std_logic;
    i_IFCLK    : in    std_logic;       -- GPIF CLK (GPIF is Master and provides the clock)
    i_SYSCLK   : in    std_logic;       -- FPGA System CLK
    i_WRU      : in    std_logic;       -- write from GPIF
    i_RDYU     : in    std_logic;       -- GPIF is ready
    o_WRX      : out   std_logic;       -- To write to GPIF
    o_RDYX     : out   std_logic;       -- IP Core is ready
    b_gpif_bus : inout std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);  -- bidirect data bus
    o_LEDrx    : out   std_logic;       -- controll LED rx
    o_LEDtx    : out   std_logic;       -- controll LED tx
    o_LEDrun   : out   std_logic;       -- controll LED running signalisation
    o_dummy    : out   std_logic        -- dummy output for RX data consumer
    );
end gpif_com_test;



architecture behaviour of gpif_com_test is


  -----------------------------------------------------------------------------
  -- controll bus
  -----------------------------------------------------------------------------
  signal s_EMPTY, s_FULL : std_logic;
  signal s_RX_DATA : std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
  signal s_RD_EN, s_WR_EN, s_EOM : std_logic;
  signal s_TX_DATA : std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);

  signal s_ABORT, s_ABORT_TMP : std_logic;
  
  signal s_RX_DATA_TMP : std_logic_vector(SIZE_DBUS_GPIF-1 downto 0);
  signal s_EMPTY_TMP, s_FULL_TMP : std_logic;
  
  signal s_rom_adress : std_logic_vector(4 downto 0);


  ----------------------------------------------------------------------------- 
  --     COMPONENTS  
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

  component message_rom
    port (
      A : in  std_logic_vector(4 downto 0);
      D : out std_logic_vector(15 downto 0));
  end component;

begin  -- behaviour

  GPIF_INTERFACE: gpif_com
    port map (
      i_nReset   => i_nReset,
      i_SYSCLK   => i_SYSCLK,
      o_ABORT    => s_ABORT,
      o_RX       => o_LEDrx,
      o_TX       => o_LEDtx,
      i_RD_EN    => s_RD_EN,
      o_EMPTY    => s_EMPTY,
      o_RX_DATA  => s_RX_DATA,
      i_EOM      => s_EOM,
      i_WR_EN    => s_WR_EN,
      o_FULL     => s_FULL,
      i_TX_DATA  => s_TX_DATA,
      --i_IFCLK    => i_SYSCLK,
      i_IFCLK    => i_IFCLK,
      i_WRU      => i_WRU,
      i_RDYU     => i_RDYU,
      o_WRX      => o_WRX,
      o_RDYX     => o_RDYX,
      b_gpif_bus => b_gpif_bus);


  
  o_LEDrun <= '1';


  -----------------------------------------------------------------------------
  --     RX DATA CONSUMER WITH THROTLING  
  -----------------------------------------------------------------------------

  -- purpose: activates the read enable signal of the receive FIFO as slow as
  -- you want.
  -- type   : sequential
  -- inputs : i_SYSCLK
  -- outputs: s_RX_DATA_TMP
  rx_throtling: process (i_SYSCLK, i_nReset)
    -- counter variable
    variable v_rx_throtle_count : std_logic_vector(6 downto 0);  
  begin
    if i_nReset = '0' then
      v_rx_throtle_count := (others => '0');
      s_RD_EN <= '0';
    elsif i_SYSCLK = '1' and i_SYSCLK'event then
      if v_rx_throtle_count >= 0 and s_EMPTY = '0' then
        s_RD_EN <= '1';
        v_rx_throtle_count := (others => '0');
      else
        v_rx_throtle_count := v_rx_throtle_count + 1;
        s_RD_EN <= '0';
      end if;
    end if;
  end process rx_throtling;

  -- purpose: reads the receive data from the GPIF interface
  -- type   : sequential
  -- inputs : i_SYSCLK
  -- outputs: s_RX_DATA_TMP
  rx_consumer: process (i_SYSCLK)
  begin  -- process rx_consumer
    if i_SYSCLK = '1' and i_SYSCLK'event then
      s_RX_DATA_TMP <= s_RX_DATA;
      s_EMPTY_TMP <= s_EMPTY;
      s_FULL_TMP <= s_FULL;
      s_ABORT_TMP <= s_ABORT;
    end if;
  end process rx_consumer;


  -- dummy logic to "use" these signals and avoid that they are removed by
  -- the optimizer
  process(s_RX_DATA_TMP, s_EMPTY_TMP, s_FULL_TMP, s_ABORT_TMP)
    variable result : std_logic := '0';
  begin
    result := '0';
    for i in s_RX_DATA_TMP'range loop
      result := result or s_RX_DATA_TMP(i);
    end loop;
    o_dummy <= result or s_EMPTY_TMP or s_FULL_TMP or s_ABORT_TMP;
  end process;

  -----------------------------------------------------------------------------
  --     RESPONSE MESSAGE GENERATOR  
  -----------------------------------------------------------------------------
  
  message_rom_1: message_rom
    port map (
      A => s_rom_adress,
      D => s_TX_DATA);
  
  -- purpose: counts up the rom adress lines to read out the response message
  -- type   : sequential
  -- inputs : i_SYSCLK
  -- outputs: s_RX_DATA_TMP
  rom_adress_counter: process (i_SYSCLK, i_nReset)
  begin
    if i_nReset = '0' then
      s_rom_adress <= (others => '0');
      s_WR_EN <= '0';
      --s_WR_EN <= '0';
    elsif i_SYSCLK = '1' and i_SYSCLK'event then
      if s_rom_adress = 24 then
        s_rom_adress <= s_rom_adress + 1;
        s_WR_EN <= '0';
        s_EOM <= '1';
      elsif s_rom_adress >= 24 then
        s_rom_adress <= s_rom_adress;
        s_WR_EN <= '0';
        s_EOM <= '0';
      else
        if s_FULL ='0' then
          s_rom_adress <= s_rom_adress + 1;
          s_WR_EN <= '1'; 
        end if;
        s_EOM <= '0';
      end if;
    end if;
  end process rom_adress_counter;
  
end behaviour;
