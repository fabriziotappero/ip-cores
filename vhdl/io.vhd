--------------------------------------------------------------------------------
-- ETHERLAB - FPGA To C# To LABVIEW Bridge                                    --
--------------------------------------------------------------------------------
-- REFERNCES                                                                  --
--  [1] LTC2604/LTC2614/LTC2624 Quad 16-Bit Rail-to-Rail DACs                 --
--  [2] Xilinx UG230                                                          --
--  [3] LTC6912 Dual Programmable Gain Amplifiers                             --
--  [4] LTC1407/LTC1407A Serial 12-Bit/14-Bit, 3Msps ADCs                     --
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

entity io is
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
end io;

architecture rtl of io is

   -----------------------------------------------------------------------------
   -- SETTING:                                                                --
   --  + FREQ: Clock frequency. Usually 50 MHz.                               --
   --  + PULSE_WIDTH: Time between two EtherLab transmissions.                --   
   -----------------------------------------------------------------------------
   constant FREQ        : natural := 50;     -- [MHz] Frequency.
   constant PULSE_WIDTH : natural := 100;    -- [msec] Time between two sends.
   
   constant CYCLES_PER_MSEC : natural := 1000000/FREQ;
   
   type state_t is (Idle, Ready, AnalogOut, Send);

   type reg_t is record
      s    : state_t;
      chnl : std_logic_vector(7 downto 0);      -- Channel latch.
      ao   : std_logic_vector(23 downto 4);     -- Analog out register.
      do   : std_logic_vector(3 downto 0);      -- Digital out register.
      led  : std_logic_vector(7 downto 0);      -- LED register.
      c    : natural range 0 to 23;
   end record;
   
   type snd_state_t is (Idle, Pulse, Transmit);
   
   type snd_t is record
      s : snd_state_t;
      d : data_t;                                  -- EtherLab data struct.
      q : natural range 0 to CYCLES_PER_MSEC-1;    -- Milliseconds counter.
      p : natural range 0 to PULSE_WIDTH-1;        -- Pulse counter.
   end record;
   
   signal r, rin : reg_t := reg_t'(Idle, x"00", x"00000", x"0", x"00", 0);  
   signal s, sin : snd_t := snd_t'(Idle, (others => (others => '0')), 0,0);
begin
   
   snd : process(s, SW, BTN)
   begin
      
      sin <= s;
      
      el_snd_en <= '0';                   -- Turn off Ethernet packet sending.
      
      case s.s is
      
         when Idle =>
            if s.q = (CYCLES_PER_MSEC-1) then
               sin.q <= 0;
               if s.p = (PULSE_WIDTH-1) then
                  sin.p <= 0;
                  sin.s <= Pulse;
               else
                  sin.p <= s.p + 1;
               end if;
            else
               sin.q <= s.q + 1;
            end if;
 
         when Pulse =>
            sin.d(CHANNEL_E) <= x"000" & DI;       -- Sample digital input.
            sin.d(CHANNEL_G) <= x"000" & BTN;      -- Sample buttons.
            sin.d(CHANNEL_H) <= x"000" & SW;       -- Sample switches.
            sin.s            <= Transmit; 
            
         when Transmit =>
            el_snd_en <= '1';                      -- Send Ethernet packet.
            sin.s     <= Idle; 
            
      end case; 
   end process;
   
   el_snd_chnl <= "11010000";
   el_snd_data <= s.d;
   
   
   nsl : process(r, el_chnl, el_data, el_dv, clk90, SPI_MISO)

      -- DAC Commands and Addresses.
      constant CMD_UP : std_logic_vector(3 downto 0) := "0011";
      constant ADR_OA : std_logic_vector(3 downto 0) := "0000";
      constant ADR_OB : std_logic_vector(3 downto 0) := "0001";
      constant ADR_OC : std_logic_vector(3 downto 0) := "0010";
      constant ADR_OD : std_logic_vector(3 downto 0) := "0011";
   begin

      rin <= r;

      SPI_MOSI <= r.ao(23);      -- Send always the MSBit of the data register.
      SPI_SCK  <= '0';           -- Pull down SPI clock.
      DAC_CLR  <= '1';           -- Disable D/A Converter.
      DAC_CS   <= '1';
      AD_CONV  <= '0';           -- Disable A/D Converter.
      AMP_CS   <= '1';           -- Disable Pre Amplifier.
      
      el_ack    <= '0';          -- Ethernet receiver data ready ACK.

      case r.s is
         when Idle =>
            if el_dv = '1' then               
               rin.chnl <= el_chnl;
               rin.s <= Ready;
            end if;
         
         -- IMPROVE: Merge Ready and AnalogOut states.
         when Ready =>             
            --------------------------------------------------------------------
            -- LED Control                                                    --
            --------------------------------------------------------------------
            if isSet(r.chnl, CHANNEL_H) then
               rin.led <= el_data(CHANNEL_H)(7 downto 0);
               rin.chnl(CHANNEL_H) <= '0';
            end if;
            --------------------------------------------------------------------
            -- Digital Out Control                                            --
            --------------------------------------------------------------------
            if isSet(r.chnl, CHANNEL_G) then
               rin.do <= el_data(CHANNEL_G)(3 downto 0);
               rin.chnl(CHANNEL_G) <= '0';
            end if;
            --------------------------------------------------------------------
            -- Analog Out Control                                             --
            --------------------------------------------------------------------
            if r.chnl(3 downto 0) /= x"0" then
               rin.s <= AnalogOut;
            else
               rin.s <= Idle; 
            end if;        
          
         -----------------------------------------------------------------------
         -- Analog Out Control                                                --
         -----------------------------------------------------------------------
         -- Send data to DAC. Since all DACs are controlled via a singe serial 
         -- interface, the setting of new data follows the following precedence:
         -- A > B > C > D. Thus if data is ready for analog output A, it will be
         -- sent first. Next is analog output B, then C and finally D. 
         when AnalogOut =>          
            if isSet(r.chnl, CHANNEL_A) then
               rin.ao <= CMD_UP & ADR_OA & el_data(CHANNEL_A)(11 downto 0);
               rin.chnl(CHANNEL_A) <= '0';   -- Clear channel flag.
               rin.s <= Send;
            elsif isSet(r.chnl, CHANNEL_B) then
               rin.ao <= CMD_UP & ADR_OB & el_data(CHANNEL_B)(11 downto 0);
               rin.chnl(CHANNEL_B) <= '0';  
               rin.s <= Send;
            elsif isSet(r.chnl, CHANNEL_C) then
               rin.ao <= CMD_UP & ADR_OC & el_data(CHANNEL_C)(11 downto 0);
               rin.chnl(CHANNEL_C) <= '0'; 
               rin.s <= Send;
            elsif isSet(r.chnl, CHANNEL_D) then          
               rin.ao <= CMD_UP & ADR_OD & el_data(CHANNEL_D)(11 downto 0);
               rin.chnl(CHANNEL_D) <= '0';
               rin.s <= Send;
            else
               rin.s <= Idle;    -- All flags are cleared and DACs are updated.
            end if;
         
         -- To send data at maximum speed, we send clk90, wich is the clock
         -- signal phase shifted by 90 degree. This is necessary to meet the
         -- timing constraints t1 and t2 defined in [1].
         when Send =>
            DAC_CS  <= '0';
            SPI_SCK <= clk90;
            rin.ao  <= r.ao(22 downto 4) & '0';
            if r.c = 23 then
               rin.c <= 0;
               rin.s <= AnalogOut;
            else
               rin.c <= r.c + 1;
               rin.s <= Send;
            end if;
         
         -----------------------------------------------------------------------
         -- TODO: Analog In Control                                           --
         -----------------------------------------------------------------------
         -- Pulse the ADC and capture the data from the last pulse.
         -- when Pulse =>
            -- AD_CONV <= '1';
            -- SPI_SCK <= clk90;
            -- rin.c   <= 0;
            -- rin.d(CHANNEL_E) <= x"000" & DI;       -- Sample digital input.
            -- rin.d(CHANNEL_G) <= x"000" & BTN;      -- Sample buttons.
            -- rin.d(CHANNEL_H) <= x"000" & SW;       -- Sample switches.
            -- rin.s   <= Transmit; --Wait0;
         
         -- when Wait0 =>
            -- SPI_SCK <= clk90;
            -- if r.c = 1 then
               -- rin.c <= 0;
               -- rin.s <= Receive0;
            -- else
               -- rin.c <= r.c + 1;
            -- end if;            
         
         -- when Receive0 =>
            -- SPI_SCK <= clk90;
            -- rin.d(CHANNEL_A) <= r.d(CHANNEL_A)(15 downto 1) & SPI_MISO;
            -- if r.c = 13 then
               -- rin.c <= 0;
               -- rin.s <= Wait1;
            -- else
               -- rin.c <= r.c + 1;
            -- end if;

         -- when Wait1 =>
            -- SPI_SCK <= clk90;
            -- if r.c = 1 then
               -- rin.c <= 0;
               -- rin.s <= Receive1;
            -- else
               -- rin.c <= r.c + 1;
            -- end if;            
         
         -- when Receive1 =>
            -- SPI_SCK <= clk90;
            -- rin.d(CHANNEL_B) <= r.d(CHANNEL_B)(15 downto 1) & SPI_MISO;
            -- if r.c = 13 then
               -- rin.c <= 0;
               -- rin.s <= Transmit;
            -- else
               -- rin.c <= r.c + 1;
            -- end if;
      
      end case;
   end process;
   
   DO  <= r.do;
   LED <= r.led;
   
   reg : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
         s <= sin;
      end if;
   end process;
end rtl;