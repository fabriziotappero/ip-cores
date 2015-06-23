----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- SPDIF transmitter signal encoder. Reads out samples from the ----
---- sample buffer, assembles frames and subframes and encodes    ----
---- serial data as bi-phase mark code.                           ----
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
-- Revision 1.2  2005/03/27 14:02:51  gedra
-- evt_hsbf and evt_lsbf signals stayed high too long
--
-- Revision 1.1  2004/07/19 16:59:08  gedra
-- Transmitter SPDIF encoder.
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_encoder is
   generic (DATA_WIDTH : integer range 16 to 32;
            ADDR_WIDTH : integer range 8 to 64); 
   port (
      wb_clk_i     : in  std_logic;     -- clock
      conf_mode    : in  std_logic_vector(3 downto 0);    -- sample format
      conf_ratio   : in  std_logic_vector(7 downto 0);    -- clock divider
      conf_udaten  : in  std_logic_vector(1 downto 0);    -- user data control
      conf_chsten  : in  std_logic_vector(1 downto 0);    -- ch. status control
      conf_txdata  : in  std_logic;     -- sample data enable
      conf_txen    : in  std_logic;     -- spdif signal enable
      user_data_a  : in  std_logic_vector(191 downto 0);  -- ch. a user data
      user_data_b  : in  std_logic_vector(191 downto 0);  -- ch. b user data
      ch_stat_a    : in  std_logic_vector(191 downto 0);  -- ch. a status
      ch_stat_b    : in  std_logic_vector(191 downto 0);  -- ch. b status
      chstat_freq  : in  std_logic_vector(1 downto 0);    -- sample freq.
      chstat_gstat : in  std_logic;     -- generation status
      chstat_preem : in  std_logic;     -- preemphasis status
      chstat_copy  : in  std_logic;     -- copyright bit
      chstat_audio : in  std_logic;     -- data format
      sample_data  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);  -- audio data
      mem_rd       : out std_logic;     -- sample buffer read
      sample_addr  : out std_logic_vector(ADDR_WIDTH - 2 downto 0);  -- address
      evt_lcsbf    : out std_logic;     -- lower ch.st./user data buf empty 
      evt_hcsbf    : out std_logic;     -- higher ch.st/user data buf empty 
      evt_hsbf     : out std_logic;     -- higher sample buf empty event
      evt_lsbf     : out std_logic;     -- lower sample buf empty event
      spdif_tx_o   : out std_logic);
end tx_encoder;

architecture rtl of tx_encoder is

   signal spdif_clk_en, spdif_out            : std_logic;
   signal clk_cnt                            : integer range 0 to 511;
   type buf_states is (IDLE, READ_CHA, READ_CHB, CHA_RDY, CHB_RDY);
   signal bufctrl                            : buf_states;
   signal adr_cnt                            : integer range 0 to 2**(ADDR_WIDTH - 1) - 1;
   signal cha_samp_ack, chb_samp_ack         : std_logic;
   type frame_states is (IDLE, BLOCK_START, CHANNEL_A, CHANNEL_B);
   signal framest                            : frame_states;
   signal frame_cnt                          : integer range 0 to 191;
   signal bit_cnt, par_cnt                   : integer range 0 to 31;
   signal inv_preamble, toggle, valid        : std_logic;
   signal def_user_data, def_ch_status       : std_logic_vector(191 downto 0);
   signal active_user_data, active_ch_status : std_logic_vector(191 downto 0);
   signal audio                              : std_logic_vector(23 downto 0);
   signal par_vector                         : std_logic_vector(26 downto 0);
   signal send_audio, imem_rd                : std_logic;

   constant X_PREAMBLE : std_logic_vector(0 to 7) := "11100010";
   constant Y_PREAMBLE : std_logic_vector(0 to 7) := "11100100";
   constant Z_PREAMBLE : std_logic_vector(0 to 7) := "11101000";

   function encode_bit (
      signal bit_cnt    : integer;          -- sub-frame bit position
      signal valid      : std_logic;        -- validity bit
      signal frame_cnt  : integer;          -- frame counter
      signal par_cnt    : integer;          -- parity counter
      signal user_data  : std_logic_vector(191 downto 0);
      signal ch_status  : std_logic_vector(191 downto 0);
      signal audio      : std_logic_vector(23 downto 0);
      signal toggle     : std_logic;
      signal prev_spdif : std_logic)        -- prev. value of spdif signal
      return std_logic is
      variable spdif, next_bit : std_logic;
   begin
      if bit_cnt > 3 and bit_cnt < 28 then  -- audio part
         next_bit := audio(bit_cnt - 4);
      elsif bit_cnt = 28 then               -- validity bit
         next_bit := valid;
      elsif bit_cnt = 29 then               -- user data
         next_bit := user_data(frame_cnt);
      elsif bit_cnt = 30 then
         next_bit := ch_status(frame_cnt);  -- channel status
      elsif bit_cnt = 31 then
         if par_cnt mod 2 = 1 then
            next_bit := '1';
         else
            next_bit := '0';
         end if;
      end if;
      -- bi-phase mark encoding:
      if next_bit = '0' then
         if toggle = '0' then
            spdif := not prev_spdif;
         else
            spdif := prev_spdif;
         end if;
      else
         spdif := not prev_spdif;
      end if;
      return(spdif);
   end encode_bit;
   
begin

-- SPDIF clock enable generation. The clock is a fraction of the Wishbone bus
-- clock, determined by the conf_ratio value.
   CGEN : process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if conf_txen = '0' then        -- transmitter disabled
            spdif_clk_en <= '0';
            clk_cnt      <= 0;
         else                           -- transmitter enabled
            if clk_cnt < to_integer(unsigned(conf_ratio)) then  -- <= ?
               clk_cnt      <= clk_cnt + 1;
               spdif_clk_en <= '0';
            else
               clk_cnt      <= 0;
               spdif_clk_en <= '1';
            end if;
         end if;
      end if;
   end process CGEN;

-- Sample memory read process. Enabled by the conf_txdata bit.
-- Buffer address is reset when disabled. Also generates events for
-- lower and upper buffer empty conditions
   sample_addr <= std_logic_vector(to_unsigned(adr_cnt, ADDR_WIDTH - 1));
   mem_rd      <= imem_rd;

   SRD : process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if conf_txdata = '0' then
            bufctrl  <= IDLE;
            imem_rd  <= '0';
            adr_cnt  <= 0;
            evt_lsbf <= '0';
            evt_hsbf <= '0';
         else
            case bufctrl is
               when IDLE =>
                  adr_cnt <= 0;
                  imem_rd <= '0';
                  if conf_txdata = '1' then
                     bufctrl <= READ_CHA;
                     imem_rd <= '1';
                  end if;
               when READ_CHA =>
                  imem_rd <= '0';
                  adr_cnt <= (adr_cnt + 1) mod 2**(ADDR_WIDTH - 1);
                  bufctrl <= CHA_RDY;
               when CHA_RDY =>
                  if cha_samp_ack = '1' then
                     imem_rd <= '1';
                     bufctrl <= READ_CHB;
                  end if;
               when READ_CHB =>
                  imem_rd <= '0';
                  adr_cnt <= (adr_cnt + 1) mod 2**(ADDR_WIDTH - 1);
                  bufctrl <= CHB_RDY;
               when CHB_RDY =>
                  if chb_samp_ack = '1' then
                     imem_rd <= '1';
                     bufctrl <= READ_CHA;
                  end if;
               when others =>
                  bufctrl <= IDLE;
            end case;
            -- generate lower/upper buffer empty events
            if imem_rd = '1' then
               if adr_cnt = 2**(ADDR_WIDTH - 2) - 1 then
                  evt_lsbf <= '1';
               end if;
               if adr_cnt = 2**(ADDR_WIDTH - 1) - 1 then
                  evt_hsbf <= '1';
               end if;
            else
               evt_lsbf <= '0';
               evt_hsbf <= '0';
            end if;
         end if;
      end if;
   end process SRD;

-- State machine that generates sub-frames and blocks
   spdif_tx_o <= spdif_out;

   FRST : process (wb_clk_i)
   begin
      if rising_edge(wb_clk_i) then
         if conf_txen = '0' then
            framest      <= IDLE;
            frame_cnt    <= 0;
            bit_cnt      <= 0;
            spdif_out    <= '0';
            inv_preamble <= '0';
            toggle       <= '0';
            valid        <= '1';
            send_audio   <= '0';
            cha_samp_ack <= '0';
            chb_samp_ack <= '0';
            evt_lcsbf    <= '0';
            evt_hcsbf    <= '0';
         else
            if spdif_clk_en = '1' then  -- SPDIF clock is twice the bit rate
               case framest is
                  when IDLE =>
                     bit_cnt      <= 0;
                     frame_cnt    <= 0;
                     inv_preamble <= '0';
                     toggle       <= '0';
                     framest      <= BLOCK_START;
                  when BLOCK_START =>   -- Start of channels status block/Ch. A
                     evt_lcsbf    <= '0';
                     evt_hcsbf    <= '0';
                     chb_samp_ack <= '0';
                     toggle       <= not toggle;  -- Each bit uses two clock enables,
                     if toggle = '1' then         -- counted by the toggle bit.
                        if bit_cnt < 31 then
                           bit_cnt <= bit_cnt + 1;
                        else
                           bit_cnt <= 0;
                           if send_audio = '1' then
                              cha_samp_ack <= '1';
                           end if;
                           framest <= CHANNEL_B;
                        end if;
                     end if;
                     -- Block start uses preamble Z.
                     if bit_cnt < 4 then
                        if toggle = '0' then
                           spdif_out <= Z_PREAMBLE(2 * bit_cnt) xor inv_preamble;
                        else
                           spdif_out <= Z_PREAMBLE(2 * bit_cnt + 1) xor inv_preamble;
                        end if;
                        par_cnt <= 0;
                     elsif bit_cnt > 3 and bit_cnt <= 31 then
                        spdif_out <= encode_bit(bit_cnt, valid, frame_cnt,
                                                par_cnt, active_user_data,
                                                active_ch_status,
                                                audio, toggle, spdif_out);
                        if bit_cnt = 31 then
                           inv_preamble <= encode_bit(bit_cnt, valid, frame_cnt,
                                                      par_cnt, active_user_data,
                                                      active_ch_status,
                                                      audio, toggle, spdif_out);
                        end if;
                        if toggle = '0' then
                           if bit_cnt > 3 and bit_cnt < 31 and
                              par_vector(bit_cnt - 4) = '1' then
                              par_cnt <= par_cnt + 1;
                           end if;
                        end if;
                     end if;
                  when CHANNEL_A =>     -- Sub-frame: channel A.
                     evt_lcsbf    <= '0';
                     evt_hcsbf    <= '0';
                     chb_samp_ack <= '0';
                     toggle       <= not toggle;
                     if toggle = '1' then
                        if bit_cnt < 31 then
                           bit_cnt <= bit_cnt + 1;
                        else
                           bit_cnt <= 0;
                           if spdif_out = '1' then
                              inv_preamble <= '1';
                           else
                              inv_preamble <= '0';
                           end if;
                           if send_audio = '1' then
                              cha_samp_ack <= '1';
                           end if;
                           framest <= CHANNEL_B;
                        end if;
                     end if;
                     -- Channel A uses preable X.
                     if bit_cnt < 4 then
                        if toggle = '0' then
                           spdif_out <= X_PREAMBLE(2 * bit_cnt) xor inv_preamble;
                        else
                           spdif_out <= X_PREAMBLE(2 * bit_cnt + 1) xor inv_preamble;
                        end if;
                        par_cnt <= 0;
                     elsif bit_cnt > 3 and bit_cnt <= 31 then
                        spdif_out <= encode_bit(bit_cnt, valid, frame_cnt,
                                                par_cnt, active_user_data,
                                                active_ch_status,
                                                audio, toggle, spdif_out);
                        if bit_cnt = 31 then
                           inv_preamble <= encode_bit(bit_cnt, valid, frame_cnt,
                                                      par_cnt, active_user_data,
                                                      active_ch_status,
                                                      audio, toggle, spdif_out);
                        end if;
                        if toggle = '0' then
                           if bit_cnt > 3 and bit_cnt < 31 and
                              par_vector(bit_cnt - 4) = '1' then
                              par_cnt <= par_cnt + 1;
                           end if;
                        end if;
                     end if;
                  when CHANNEL_B =>     -- Sub-frame: channel B.
                     cha_samp_ack <= '0';
                     toggle       <= not toggle;
                     if toggle = '1' then
                        if bit_cnt < 31 then
                           bit_cnt <= bit_cnt + 1;
                        else
                           bit_cnt <= 0;
                           valid   <= not conf_txdata;
                           if spdif_out = '1' then
                              inv_preamble <= '1';
                           else
                              inv_preamble <= '0';
                           end if;
                           send_audio <= conf_txdata;  -- 1 if audio samples sohuld be sent
                           if send_audio = '1' then
                              chb_samp_ack <= '1';
                           end if;
                           if frame_cnt < 191 then  -- One block is 192 frames
                              frame_cnt <= frame_cnt + 1;
                              if frame_cnt = 96 then
                                 evt_lcsbf <= '1';
                              end if;
                              framest <= CHANNEL_A;
                           else
                              frame_cnt <= 0;
                              evt_hcsbf <= '1';
                              framest   <= BLOCK_START;
                           end if;
                        end if;
                     end if;
                     -- Channel B uses preable Y.
                     if bit_cnt < 4 then
                        if toggle = '0' then
                           spdif_out <= Y_PREAMBLE(2 * bit_cnt) xor inv_preamble;
                        else
                           spdif_out <= Y_PREAMBLE(2 * bit_cnt + 1) xor inv_preamble;
                        end if;
                        par_cnt <= 0;
                     elsif bit_cnt > 3 and bit_cnt <= 31 then
                        spdif_out <= encode_bit(bit_cnt, valid, frame_cnt,
                                                par_cnt, active_user_data,
                                                active_ch_status,
                                                audio, toggle, spdif_out);
                        if bit_cnt = 31 then
                           inv_preamble <= encode_bit(bit_cnt, valid, frame_cnt,
                                                      par_cnt, active_user_data,
                                                      active_ch_status,
                                                      audio, toggle, spdif_out);
                        end if;
                        if toggle = '0' then
                           if bit_cnt > 3 and bit_cnt < 31 and
                              par_vector(bit_cnt - 4) = '1' then
                              par_cnt <= par_cnt + 1;
                           end if;
                        end if;
                     end if;
                  when others =>
                     framest <= IDLE;
               end case;
            end if;
         end if;
      end if;
   end process FRST;

-- Audio data latching
   DA32 : if DATA_WIDTH = 32 generate
      ALAT : process (wb_clk_i)
      begin
         if rising_edge(wb_clk_i) then
            if send_audio = '0' then
               audio(23 downto 0) <= (others => '0');
            else
               case to_integer(unsigned(conf_mode)) is
                  when 0 =>             -- 16 bit audio
                     audio(23 downto 8) <= sample_data(15 downto 0);
                     audio(7 downto 0)  <= (others => '0');
                  when 1 =>             -- 17 bit audio
                     audio(23 downto 7) <= sample_data(16 downto 0);
                     audio(6 downto 0)  <= (others => '0');
                  when 2 =>             -- 18 bit audio
                     audio(23 downto 6) <= sample_data(17 downto 0);
                     audio(5 downto 0)  <= (others => '0');
                  when 3 =>             -- 19 bit audio
                     audio(23 downto 5) <= sample_data(18 downto 0);
                     audio(4 downto 0)  <= (others => '0');
                  when 4 =>             -- 20 bit audio
                     audio(23 downto 4) <= sample_data(19 downto 0);
                     audio(3 downto 0)  <= (others => '0');
                  when 5 =>             -- 21 bit audio
                     audio(23 downto 3) <= sample_data(20 downto 0);
                     audio(2 downto 0)  <= (others => '0');
                  when 6 =>             -- 22 bit audio
                     audio(23 downto 2) <= sample_data(21 downto 0);
                     audio(1 downto 0)  <= (others => '0');
                  when 7 =>             -- 23 bit audio
                     audio(23 downto 1) <= sample_data(22 downto 0);
                     audio(0)           <= '0';
                  when 8 =>             -- 24 bit audio
                     audio(23 downto 0) <= sample_data(23 downto 0);
                  when others =>        -- unsupported modes
                     audio(23 downto 0) <= (others => '0');
               end case;
            end if;
         end if;
      end process ALAT;
   end generate DA32;

   DA16 : if DATA_WIDTH = 16 generate
      ALAT : process (wb_clk_i)
      begin
         if rising_edge(wb_clk_i) then
            if send_audio = '0' then
               audio(23 downto 0) <= (others => '0');
            else
               audio(23 downto 8) <= sample_data(15 downto 0);
               audio(7 downto 0)  <= (others => '0');
            end if;
         end if;
      end process ALAT;
   end generate DA16;

-- Parity vector. These bits are counted to generate even parity
   par_vector(23 downto 0) <= audio(23 downto 0);
   par_vector(24)          <= valid;
   par_vector(25)          <= active_user_data(frame_cnt);
   par_vector(26)          <= active_ch_status(frame_cnt);

-- Channel status and user datat to be used if buffers are disabled.
-- User data is then all zero, while channel status bits are taken from
-- register TxChStat.
   def_user_data(191 downto 0) <= (others => '0');
   def_ch_status(0)            <= '0';           -- consumer mode
   def_ch_status(1)            <= chstat_audio;  -- audio bit
   def_ch_status(2)            <= chstat_copy;   -- copy right
   def_ch_status(5 downto 3)   <= "000" when chstat_preem = '0'
                                else "001";      -- pre-emphasis
   def_ch_status(7 downto 6)   <= "00";
   def_ch_status(14 downto 8)  <= (others => '0');
   def_ch_status(15)           <= chstat_gstat;  -- generation status
   def_ch_status(23 downto 16) <= (others => '0');
   def_ch_status(27 downto 24) <= "0000" when chstat_freq = "00" else
                                  "0010" when chstat_freq = "01" else
                                  "0011" when chstat_freq = "10" else
                                  "0001";
   def_ch_status(191 downto 28) <= (others => '0');

-- Generate channel status vector based on configuration register setting.
   active_ch_status <= ch_stat_a when conf_chsten = "01" else
                       ch_stat_a when conf_chsten = "10" and framest = CHANNEL_A else
                       ch_stat_b when conf_chsten = "10" and framest = CHANNEL_B else
                       def_ch_status;

-- Generate user data vector based on configuration register setting.
   active_user_data <= user_data_a when conf_udaten = "01" else
                       user_data_a when conf_udaten = "10" and framest = CHANNEL_A else
                       user_data_b when conf_udaten = "10" and framest = CHANNEL_B else
                       def_user_data;
   
end rtl;
