--------------------------------------------------------------------------------
-- ETHERLAB - FPGA To C# To LABVIEW Bridge                                    --
--------------------------------------------------------------------------------
-- Copyright (C)2012  Mathias Hörtnagl <mathias.hoertnagl@gmail.com>          --
--                                                                            --
-- This program is free software: you can redistribute it and/or modify       --
-- it under the terms of the GNU General Public License as published by       --
-- the Free Software Foundation, either version 3 of the License, or          --
-- (at your option) any later version.                                        --
--                                                                            --
-- This program is distributed in the hope that it will be useful,            --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of             --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              --
-- GNU General Public License for more details.                               --
--                                                                            --
-- You should have received a copy of the GNU General Public License          --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.      --
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

entity etherlab is
   port(
      clk      : in  std_logic;

      E_COL    : in  std_logic;                       -- Collision Detect.
      E_CRS    : in  std_logic;                       -- Carrier Sense.
      E_MDC    : out std_logic;
      E_MDIO   : in  std_logic;
      E_RX_CLK : in  std_logic;                       -- Receiver Clock.
      E_RX_DV  : in  std_logic;                       -- Received Data Valid.
      E_RXD    : in  std_logic_vector(3 downto 0);    -- Received Nibble.
      E_RX_ER  : in  std_logic;                       -- Received Data Error.
      E_TX_CLK : in  std_logic;                       -- Sender Clock.
      E_TX_EN  : out std_logic;                       -- Sender Enable.
      E_TXD    : out std_logic_vector(3 downto 0);    -- Sent Data.
      E_TX_ER  : out std_logic;                       -- sent Data Error.

      SPI_MISO : in  std_logic;                       -- Serial data in.
      SPI_MOSI : out std_logic;                       -- Serial data out.
      SPI_SCK  : out std_logic;                       -- Serial Interface clock.
      DAC_CS   : out std_logic;                       -- D/A Converter chip sel.
      DAC_CLR  : out std_logic;                       -- D/A Converter reset.

      SF_OE    : out std_logic;                       -- StrataFlash.
      SF_CE    : out std_logic;
      SF_WE    : out std_logic;
      FPGA_INIT_B : out std_logic;
      AD_CONV  : out std_logic;                       -- A/D Converter chip sel.
      SPI_SS_B : out std_logic;
      AMP_CS   : out std_logic;                       -- Pre-Amplifier chip sel.

      DI       : in  std_logic_vector(3 downto 0);    -- 6-pin header J1.
      DO       : out std_logic_vector(3 downto 0);    -- 6-pin header J2.
      SW       : in  std_logic_vector(3 downto 0);    -- SWITCHES.
      BTN      : in  std_logic_vector(3 downto 0);    -- BUTTONS.
      LED      : out std_logic_vector(7 downto 0)     -- LEDs.
   );
end etherlab;

architecture rtl of etherlab is

   component clock
      port(
         clkin_in        : in  std_logic;
         rst_in          : in  std_logic;
         clkin_ibufg_out : out std_logic;
         clk0_out        : out std_logic;
         clk90_out       : out std_logic
      );
   end component;

   component mac_rcv is
      port(
         E_RX_CLK : in  std_logic;                     -- Receiver Clock.
         E_RX_DV  : in  std_logic;                     -- Received Data Valid.
         E_RXD    : in  std_logic_vector(3 downto 0);  -- Received Nibble.
         el_chnl  : out std_logic_vector(7 downto 0);  -- EtherLab channels.
         el_data  : out data_t;                        -- EtherLab channel data.
         el_dv    : out std_logic;                     -- EtherLab data valid.
         el_ack   : in  std_logic                      -- Packet reception ACK.
      );
   end component;

	component mac_snd is
		port(
         E_TX_CLK : in  std_logic;                       -- Sender Clock.
         E_TX_EN  : out std_logic;                       -- Sender Enable.
         E_TXD    : out std_logic_vector(3 downto 0);    -- Sent Data.
         E_TX_ER  : out std_logic;                       -- Sent Data Error.
         el_chnl  : in  std_logic_vector(7 downto 0);    -- EtherLab channels.
         el_data  : in  data_t;                          -- EtherLab data.
         en       : in  std_logic                        -- User Start Send. 
		);
	end component;
   
   component io is
      port(
         clk         : in  std_logic;
         clk90       : in  std_logic;
      -- EtherLab data received.
         el_chnl     : in  std_logic_vector(7 downto 0);
         el_data     : in  data_t;
         el_dv       : in  std_logic;
         el_ack      : out std_logic;
      -- EtherLab data to send.
         el_snd_chnl : out std_logic_vector(7 downto 0);
         el_snd_data : out data_t;
         el_snd_en   : out std_logic;
      -- DAC/ADC Connections.
         SPI_MISO    : in  std_logic;
         SPI_MOSI    : out std_logic;
         SPI_SCK     : out std_logic;
         DAC_CS      : out std_logic;
         DAC_CLR     : out std_logic;
         AD_CONV     : out std_logic;
         AMP_CS      : out std_logic;
      -- Digital lines.
         DI          : in  std_logic_vector(3 downto 0);
         DO          : out std_logic_vector(3 downto 0);
      -- SWITCHES.
         SW          : in  std_logic_vector(3 downto 0);
      -- BUTTONS.
         BTN         : in  std_logic_vector(3 downto 0);
      -- LEDs.
         LED         : out std_logic_vector(7 downto 0)
      );
   end component;

   signal el_chnl : std_logic_vector(7 downto 0);     -- EtherLab channels.
   signal el_data : data_t;                           -- EtherLab data.
   signal el_dv   : std_logic;                        -- Received data valid.
   signal el_ack  : std_logic;                        -- Packet reception ACK.

   signal el_snd_chnl : std_logic_vector(7 downto 0); -- EtherLab Send channels.
   signal el_snd_data : data_t;                       -- EhterLab Send data.
   signal el_snd_en   : std_logic;                    -- Enable sending.
   
   signal clk90   : std_logic;   -- Clock shiftet 90 degree.
   signal clk0    : std_logic;
begin

   SF_OE       <= '1';        -- Turn off Strata Flash.
   SF_WE       <= '1';
   SF_CE       <= '1';        
   FPGA_INIT_B <= '1';        -- Turn off Platform Flash.    
   SPI_SS_B    <= '1';        -- Turn off Serial Flash.
   
   E_MDC <= '0';

   inst_clock: clock port map(
      clkin_in        => clk,
      rst_in          => '0',
      clkin_ibufg_out => open,
      clk0_out        => clk0,
      clk90_out       => clk90
   );

   mac_receive : mac_rcv port map(
      E_RX_CLK => E_RX_CLK,
      E_RX_DV  => E_RX_DV,
      E_RXD    => E_RXD,
      el_chnl  => el_chnl,
      el_data  => el_data,
      el_dv    => el_dv,
      el_ack   => el_ack
   );
   
	mac_send : mac_snd port map(	
      E_TX_CLK => E_TX_CLK,
      E_TX_EN  => E_TX_EN,
      E_TXD    => E_TXD,
      E_TX_ER  => E_TX_ER,
      en       => el_snd_en,	         
      el_chnl  => el_snd_chnl,
      el_data  => el_snd_data
   );
   
   ioio : io port map(
      clk         => clk0,
      clk90       => clk90,
   -- EtherLab data received.
      el_chnl     => el_chnl,
      el_data     => el_data,
      el_dv       => el_dv,
      el_ack      => el_ack,
   -- EtherLab data to send.
      el_snd_chnl => el_snd_chnl,
      el_snd_data => el_snd_data,
      el_snd_en   => el_snd_en,
   -- DAC/ADC Connections.
      SPI_MISO    => SPI_MISO,
      SPI_MOSI    => SPI_MOSI,
      SPI_SCK     => SPI_SCK,
      DAC_CS      => DAC_CS,
      DAC_CLR     => DAC_CLR,
      AD_CONV     => AD_CONV,
      AMP_CS      => AMP_CS,     
   -- Digital lines.
      DI          => DI,
      DO          => DO,
   -- SWITCHES.
      SW          => SW,
   -- BUTTONS.
      BTN         => BTN,
   -- LEDs.
      LED         => LED
   );
end rtl;