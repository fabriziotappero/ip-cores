--------------------------------------------------------------------------------
-- ETHERLAB - FPGA To C# To LABVIEW Bridge                                    --
--------------------------------------------------------------------------------
-- REFERENCES                                                                 --
--  [1] http://tools.ietf.org/html/rfc2460                                    --
--  [2] https://en.wikipedia.org/wiki/Ethernet_frame                          --
--  [5] http://outputlogic.com/my-stuff/circuit-cellar-january-2010-crc.pdf   --
--  [6] OPB Ethernet Lite Media Access Controller (v1.01b)                    --
--  [7] LAN83C185 - 10/100 Ethernet PHY                                       --
--  [8] Xilinx UG230                                                          --
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

entity mac_rcv is
   port(
      E_RX_CLK : in  std_logic;                      -- Receiver Clock.
      E_RX_DV  : in  std_logic;                      -- Received Data Valid.
      E_RXD    : in  std_logic_vector(3 downto 0);   -- Received Nibble.
      el_chnl  : out std_logic_vector(7 downto 0);   -- EtherLab channels.
      el_data  : out data_t;                         -- EtherLab channel data.
      el_dv    : out std_logic;                      -- EtherLab data valid.
      el_ack   : in  std_logic                       -- Packet reception ACK.
   );
end mac_rcv;

architecture rtl of mac_rcv is
   
   type state_t is (
      Preamble, StartOfFrame,             -- 7 Bytes 0x55, 1 Byte 0x5d.
      MACS,                               -- 12 Byte MAC addresses.
      EtherTypeCheck,                     -- Next Protocol EtherLab?
      Version,                            -- EtherLab - Version.
      Channel,                            -- EtherLab - Channel.
      DataU, DataL,                       -- EtherLab - Channel data.
      Notify                              -- Inform other hardware components.
   );
   
   type rcv_t is record
      s    : state_t;
      chnl : std_logic_vector(7 downto 0);   -- EtherLab channel field.
      d    : data_t;                         -- Channel data.
      c    : natural range 0 to 23;
      a    : natural range 0 to 7;
   end record;

   signal r, rin : rcv_t 
      := rcv_t'(Preamble, x"00", (others => (others => '0')), 0, 0);
begin

   rcv_nsl : process(r, E_RX_DV, E_RXD, el_ack)
   begin

      rin   <= r;
      el_dv <= '0';

      if E_RX_DV = '1' then
         case r.s is

            --------------------------------------------------------------------
            -- Ethernet II - Preamble and Start Of Frame.                     --
            --------------------------------------------------------------------
            when Preamble =>
               if E_RXD = x"5" then
                  if r.c = 14 then
                     rin.c <= 0;
                     rin.s <= StartOfFrame;
                  else
                     rin.c <= r.c + 1;
                  end if;
               else
                  rin.c <= 0;
               end if;

            when StartOfFrame =>
               if E_RXD = x"d" then
                  rin.s <= MACS;
               else
                  rin.s <= Preamble;
               end if;

            --------------------------------------------------------------------
            -- Ethernet II - 12 Byte MAC addresses.                           --
            --------------------------------------------------------------------
            when MACS =>
               if r.c = 23 then
                  rin.c <= 0;
                  rin.s <= EtherTypeCheck;
               else
                  rin.c <= r.c + 1;
               end if;

            --------------------------------------------------------------------
            -- Ethernet II - Next Layer EtherLab?                             --
            --------------------------------------------------------------------
            when EtherTypeCheck =>
               if E_RXD = x"0" then
                  if r.c = 3 then
                     rin.c <= 0;
                     rin.s <= Version;
                  else
                     rin.c <= r.c + 1;
                  end if;
               else
                  rin.c <= 0;
                  rin.s <= Preamble;
               end if;

            --------------------------------------------------------------------
            -- EtherLab - Version                                             --
            --------------------------------------------------------------------
            when Version =>
               if r.c = 1 then
                  rin.c <= 0;
                  rin.s <= Channel;
               else
                  rin.c <= r.c + 1;
               end if;

            --------------------------------------------------------------------
            -- EtherLab - Channel Flags.                                       --
            --------------------------------------------------------------------
            when Channel =>
               rin.chnl(7 downto 0) <= E_RXD & r.chnl(7 downto 4);
               if r.c = 1 then
                  rin.c <= 0;
                  rin.a <= 0;
                  rin.s <= DataU;
               else
                  rin.c <= r.c + 1;
               end if;

            --------------------------------------------------------------------
            -- EtherLab - Data. 8 channels á 16 bit.                          --
            --------------------------------------------------------------------
            when DataU =>
               rin.d(r.a)(15 downto 8) <= E_RXD & r.d(r.a)(15 downto 12);
               if r.c = 1 then
                  rin.c <= 0;
                  rin.s <= DataL;
               else
                  rin.c <= r.c + 1;
               end if;

            when DataL =>
               rin.d(r.a)(7 downto 0) <= E_RXD & r.d(r.a)(7 downto 4);
               if r.c = 1 then
                  rin.c <= 0;
                  if r.a = 7 then
                     rin.a <= 0;
                     rin.s <= Notify;
                  else
                     rin.a <= r.a + 1;
                     rin.s <= DataU;
                  end if;
               else
                  rin.c <= r.c + 1;
               end if;
              
            --------------------------------------------------------------------
            -- Notification                                                   --
            --------------------------------------------------------------------
            when Notify =>
               el_dv <= '1';
               rin.s <= Preamble;

         end case;
      end if;
   end process;

   snd_reg : process(E_RX_CLK)
   begin
      if rising_edge(E_RX_CLK) then
         r <= rin;
      end if;
   end process;
   
   el_chnl <= r.chnl;
   el_data <= r.d;
end rtl;