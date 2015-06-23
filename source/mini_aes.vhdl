-- ------------------------------------------------------------------------
-- Copyright (C) 2005 Arif Endro Nugroho
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY ARIF ENDRO NUGROHO "AS IS" AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL ARIF ENDRO NUGROHO BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
-- ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
-- 
-- End Of License.
-- ------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mini_aes is
  port (
    clock  : in  std_logic;
    clear  : in  std_logic;
    load_i : in  std_logic;
    enc    : in  std_logic;             -- active low (e.g. 0 = encrypt, 1 = decrypt)
    key_i  : in  std_logic_vector (7 downto 0);
    data_i : in  std_logic_vector (7 downto 0);
    data_o : out std_logic_vector (7 downto 0);
    done_o : out std_logic
    );
end mini_aes;

architecture data_flow of mini_aes is

  component io_interface
    port (
      clock      : in  std_logic;
      clear      : in  std_logic;
      load_i     : in  std_logic;
      load_i_int : out std_logic;
      data_i     : in  std_logic_vector (7 downto 0);
      key_i      : in  std_logic_vector (7 downto 0);
      data_o     : out std_logic_vector (7 downto 0);
      data_o_int : in  std_logic_vector (127 downto 000);
      data_i_int : out std_logic_vector (127 downto 000);
      key_i_int  : out std_logic_vector (127 downto 000);
      done_o_int : in  std_logic;
      done_o     : out std_logic
      );
  end component;

  component bram_block_a
    port (
      clk_a_i     : in  std_logic;
      en_a_i      : in  std_logic;
      we_a_i      : in  std_logic;
      di_a_i      : in  std_logic_vector (07 downto 00);
      addr_a_1_i  : in  std_logic_vector (08 downto 00);
      addr_a_2_i  : in  std_logic_vector (08 downto 00);
      do_a_1_o    : out std_logic_vector (07 downto 00);
      do_a_2_o    : out std_logic_vector (07 downto 00)
      );
  end component;
--
  component bram_block_b
    port (
      clk_b_i     : in  std_logic;
      we_b_i      : in  std_logic;
      en_b_i      : in  std_logic;
      di_b_i      : in  std_logic_vector (07 downto 00);
      addr_b_1_i  : in  std_logic_vector (08 downto 00);
      addr_b_2_i  : in  std_logic_vector (08 downto 00);
      do_b_1_o    : out std_logic_vector (07 downto 00);
      do_b_2_o    : out std_logic_vector (07 downto 00)
      );
  end component;
--
  component mix_column
    port (
      s0          : in  std_logic_vector (07 downto 00);
      s1          : in  std_logic_vector (07 downto 00);
      s2          : in  std_logic_vector (07 downto 00);
      s3          : in  std_logic_vector (07 downto 00);
      mix_col     : out std_logic_vector (31 downto 00);
      inv_mix_col : out std_logic_vector (31 downto 00)
      );
  end component;
--
  component key_scheduler
    port (
      clock       : in  std_logic;
      load        : in  std_logic;
      key_i       : in  std_logic_vector (127 downto 000);
      key_o       : out std_logic_vector (031 downto 000);
      done        : out std_logic
      );
  end component;
--
  component counter2bit
    port (
      clock       : in  std_logic;
      clear       : in  std_logic;
      count       : out std_logic_vector (1 downto 0)
      );
  end component;
--
  component folded_register
    port (
      clk_i       : in  std_logic;
      enc_i       : in  std_logic;
      load_i      : in  std_logic;
      data_i      : in  std_logic_vector (127 downto 000);
      key_i       : in  std_logic_vector (127 downto 000);
      di_0_i      : in  std_logic_vector (007 downto 000);
      di_1_i      : in  std_logic_vector (007 downto 000);
      di_2_i      : in  std_logic_vector (007 downto 000);
      di_3_i      : in  std_logic_vector (007 downto 000);
      do_0_o      : out std_logic_vector (007 downto 000);
      do_1_o      : out std_logic_vector (007 downto 000);
      do_2_o      : out std_logic_vector (007 downto 000);
      do_3_o      : out std_logic_vector (007 downto 000)
      );
  end component;

  type state        is array (03 downto 00) of std_logic_vector (07 downto 00);
  type allround     is array (43 downto 00) of std_logic_vector (31 downto 00);
  type partialround is array (03 downto 00) of std_logic_vector (31 downto 00);
  signal   input            : state                             := ( X"00", X"00", X"00", X"00");
  signal   key_o_srl1_p     : partialround                      :=
    (
      X"00000000", X"00000000", X"00000000", X"00000000"
      );
  signal   key_o_srl2_p     : partialround                      :=
    (
      X"00000000", X"00000000", X"00000000", X"00000000"
      );
  signal   key_o_srl3_p     : partialround                      :=
    (
      X"00000000", X"00000000", X"00000000", X"00000000"
      );
  signal   key_o_srl4_p     : partialround                      :=
    (
      X"00000000", X"00000000", X"00000000", X"00000000"
      );
  signal   key_o_srl1       : allround                          :=
    (
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000"
      );
  signal   key_o_srl2       : allround                          :=
    (
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000"
      );
  signal   key_o_srl3       : allround                          :=
    (
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000",
      X"00000000", X"00000000", X"00000000", X"00000000"
      );
--
  signal   counter          : std_logic_vector (01 downto 00)     := "00";
  signal   inner_round      : std_logic                           := '0';
  signal   key_counter_up   : integer range 0 to 43;
  signal   key_counter_down : integer range 0 to 43;
  signal   done             : std_logic                           := '0';
  signal   done_decrypt     : std_logic                           := '0';
  signal   counter1bit      : std_logic                           := '0';
  signal   done_o_int       : std_logic                           := '0';
  signal   data_i_int       : std_logic_vector (127 downto 000)   := ( X"00000000_00000000_00000000_00000000" );
  signal   data_o_int       : std_logic_vector (127 downto 000)   := ( X"00000000_00000000_00000000_00000000" );
  signal   key_i_int        : std_logic_vector (127 downto 000)   := ( X"00000000_00000000_00000000_00000000" );
  signal   load             : std_logic                           := '0';
  signal   load_io          : std_logic                           := '0';
  signal   di_0_i           : std_logic_vector (007 downto 000);
  signal   di_1_i           : std_logic_vector (007 downto 000);
  signal   di_2_i           : std_logic_vector (007 downto 000);
  signal   di_3_i           : std_logic_vector (007 downto 000);
  signal   do_0_o           : std_logic_vector (007 downto 000);
  signal   do_1_o           : std_logic_vector (007 downto 000);
  signal   do_2_o           : std_logic_vector (007 downto 000);
  signal   do_3_o           : std_logic_vector (007 downto 000);
  signal   current_key      : std_logic_vector (031 downto 000)   := ( X"0000_0000");
  signal   output_o         : std_logic_vector (031 downto 000)   := ( X"00000000" );
  signal   output           : std_logic_vector (031 downto 000)   := ( X"00000000" );
  signal   key_o            : std_logic_vector (031 downto 000)   := ( X"00000000" );
  signal   fifo16x8         : std_logic_vector (127 downto 000)   := ( X"00000000_00000000_00000000_00000000" );
  signal   fifo16x8i        : std_logic_vector (127 downto 000)   := ( X"00000000_00000000_00000000_00000000" );
  signal   fifo16x8o        : std_logic_vector (127 downto 000)   := ( X"00000000_00000000_00000000_00000000" );
  signal   key_b            : std_logic_vector (127 downto 000)   := ( X"00000000_00000000_00000000_00000000" );
  constant GND              : std_logic                           := '0';
  constant VCC              : std_logic                           := '1';

  signal   mixcol_s0_i      : std_logic_vector (007 downto 000)   := B"0000_0000";
  signal   mixcol_s1_i      : std_logic_vector (007 downto 000)   := B"0000_0000";
  signal   mixcol_s2_i      : std_logic_vector (007 downto 000)   := B"0000_0000";
  signal   mixcol_s3_i      : std_logic_vector (007 downto 000)   := B"0000_0000";
  signal   mixcol_o         : std_logic_vector (031 downto 000)   := ( X"00000000" );
  signal   inv_mixcol_o     : std_logic_vector (031 downto 000)   := ( X"00000000" );
--
  signal   en_a_i           : std_logic;
  signal   en_b_i           : std_logic;
  signal   clk_a_i          : std_logic;
  signal   clk_b_i          : std_logic;
  signal   we_a_i           : std_logic;
  signal   we_b_i           : std_logic;
  signal   di_a_i           : std_logic_vector (07 downto 00)   := B"0000_0000";
  signal   di_b_i           : std_logic_vector (07 downto 00)   := B"0000_0000";
  signal   addr_a_1_i       : std_logic_vector (08 downto 00)   := B"0_0000_0000";
  signal   addr_a_2_i       : std_logic_vector (08 downto 00)   := B"0_0000_0000";
  signal   addr_b_1_i       : std_logic_vector (08 downto 00)   := B"0_0000_0000";
  signal   addr_b_2_i       : std_logic_vector (08 downto 00)   := B"0_0000_0000";
  signal   do_a_1_o         : std_logic_vector (07 downto 00);
  signal   do_a_2_o         : std_logic_vector (07 downto 00);
  signal   do_b_1_o         : std_logic_vector (07 downto 00);
  signal   do_b_2_o         : std_logic_vector (07 downto 00);

--signal data_i_int : std_logic_vector (127 downto 000) :=
--( X"3243F6A8_885A308D_313198A2_E0370734" );  -- PT 0
--( X"00112233_44556677_8899AABB_CCDDEEFF" );  -- PT 1
--( X"3925841D_02DC09FB_DC118597_196A0B32" );  -- CT 0
--( X"69C4E0D8_6A7B0430_D8CDB780_70B4C55A" );  -- CT 1
--signal key_i : std_logic_vector (127 downto 000) :=
--( X"2B7E1516_28AED2A6_ABF71588_09CF4F3C" );  -- KEY 0
--( X"00010203_04050607_08090A0B_0C0D0E0F" );  -- KEY 1

begin

  clk_a_i <= clock;
  clk_b_i <= clock;
  en_a_i  <= VCC;
  en_b_i  <= VCC;
  we_a_i  <= GND;
  we_b_i  <= GND;

  done_o_int <= done_decrypt;

  my_io : io_interface
    port map (
      clock      => clock,
      clear      => clear,
      load_i     => load_i,
      load_i_int => load_io,
      data_i     => data_i,
      key_i      => key_i,
      data_o     => data_o,
      data_o_int => data_o_int,
      data_i_int => data_i_int,
      key_i_int  => key_i_int,
      done_o_int => done_o_int,
      done_o     => done_o
      );

  sbox1     : bram_block_a
    port map (
      clk_a_i     => clk_a_i,
      en_a_i      => en_a_i,
      we_a_i      => we_a_i,
      di_a_i      => di_a_i,
      addr_a_1_i  => addr_a_1_i,
      addr_a_2_i  => addr_a_2_i,
      do_a_1_o    => do_a_1_o,
      do_a_2_o    => do_a_2_o
      );
--
  sbox2     : bram_block_b
    port map (
      clk_b_i     => clk_b_i,
      we_b_i      => we_b_i,
      en_b_i      => en_b_i,
      di_b_i      => di_b_i,
      addr_b_1_i  => addr_b_1_i,
      addr_b_2_i  => addr_b_2_i,
      do_b_1_o    => do_b_1_o,
      do_b_2_o    => do_b_2_o
      );
--
  mixcol    : mix_column
    port map (
      s0          => mixcol_s0_i,
      s1          => mixcol_s1_i,
      s2          => mixcol_s2_i,
      s3          => mixcol_s3_i,
      mix_col     => mixcol_o,
      inv_mix_col => inv_mixcol_o
      );
--
  key       : key_scheduler
    port map (
      clock       => clock,
      load        => load,
      key_i       => key_i_int,
      key_o       => key_o,
      done        => done
      );
--
  count2bit : counter2bit
    port map (
      clock       => clock,
      clear       => load,
      count       => counter
      );
--
  foldreg   : folded_register
    port map (
      clk_i       => clock,
      enc_i       => enc,
      load_i      => load,
      data_i      => data_i_int,
      key_i       => key_b,
      di_0_i      => di_0_i,
      di_1_i      => di_1_i,
      di_2_i      => di_2_i,
      di_3_i      => di_3_i,
      do_0_o      => do_0_o,
      do_1_o      => do_1_o,
      do_2_o      => do_2_o,
      do_3_o      => do_3_o
      );

  process(clock, clear)
  begin
    if (clear = '1') then
      load                        <= '1';
    elsif (clock = '1' and clock'event) then
      fifo16x8 (127 downto 000)   <= fifo16x8i (127 downto 000);
      if (done = '1') then
        load                      <= '1';
      else
--      load                      <= '0';
        load                      <= load_io;
      end if;
    end if;
  end process;
--
  process(clear, clock)
  begin
    if (clear = '1') then
      key_o_srl1                  <= (others => (others => '0'));
    elsif (clock = '1' and clock'event) then
      if (inner_round = '1') then
        key_o_srl1 (43 downto 00) <= key_o_srl2 (43 downto 00);
      end if;
    end if;
  end process;
--
  process(clear, clock)
  begin
    if (clear = '1') then
      key_o_srl1_p                <= (others => (others => '0'));
    elsif (clock = '1' and clock'event) then
      key_o_srl1_p (03 downto 00) <= key_o_srl2_p (03 downto 00);
    end if;
  end process;
--
  process(clear, clock)
  begin
    if (clear = '1') then
      key_o_srl3_p                <= (others => (others => '0'));
    elsif (clock = '1' and clock'event) then
      key_o_srl3_p (03 downto 00) <= key_o_srl4_p (03 downto 00);
    end if;
  end process;

  key_o_srl2_p (03 downto 01) <= key_o_srl1_p (02 downto 00);
  key_o_srl2_p (00)           <= key_o;
  key_o_srl4_p (02 downto 00) <= key_o_srl3_p (03 downto 01);
  key_o_srl4_p (03)           <= key_o;
--
  inner_round <= ( counter(1) and counter(0) );
--
  key_o_srl2 (39 downto 00) <= key_o_srl1 (43 downto 04);

  key_o_srl2 (43 downto 40) <= ( key_o_srl4_p (03), key_o_srl4_p (02), key_o_srl4_p (01), key_o_srl4_p (00) ) when ( enc = '0' ) else 
                               ( key_o_srl2_p (03), key_o_srl2_p (02), key_o_srl2_p (01), key_o_srl2_p (00) );

  key_o_srl3 (43 downto 00) <= ( key_o_srl2 (43 downto 04) & 
                                 key_i_int (127 downto 096) & 
                                 key_i_int (095 downto 064) & 
                                 key_i_int (063 downto 032) & 
                                 key_i_int (031 downto 000)
                               ) when (done = '1') else 
                                 key_o_srl3 (43 downto 00);

  fifo16x8o (127 downto 000) <= fifo16x8i (127 downto 000) when (done = '1') else fifo16x8o (127 downto 000);
  fifo16x8i (127 downto 000) <= ( fifo16x8 (095 downto 000) & output_o );

  data_o_int (127 downto 000) <= fifo16x8o (127 downto 000);
--
  input (0)               <= do_0_o;
  input (1)               <= do_1_o;
  input (2)               <= do_2_o;
  input (3)               <= do_3_o;
--
  addr_a_1_i              <= (enc & input(0));
  addr_a_2_i              <= (enc & input(1));
  addr_b_1_i              <= (enc & input(2));
  addr_b_2_i              <= (enc & input(3));
--
  mixcol_s0_i             <= do_a_1_o when (enc = '0') else output (31 downto 24);
  mixcol_s1_i             <= do_a_2_o when (enc = '0') else output (23 downto 16);
  mixcol_s2_i             <= do_b_1_o when (enc = '0') else output (15 downto 08);
  mixcol_s3_i             <= do_b_2_o when (enc = '0') else output (07 downto 00);

  output   <= mixcol_o xor key_o_srl3(key_counter_up) when (enc = '0') else 
              (do_a_1_o & do_a_2_o & do_b_1_o & do_b_2_o) xor key_o_srl3(key_counter_down);

  output_o <= (do_a_1_o & do_a_2_o & do_b_1_o & do_b_2_o) xor key_o_srl3(key_counter_up) when (enc = '0') else 
              (do_a_1_o & do_a_2_o & do_b_1_o & do_b_2_o) xor key_o_srl3(key_counter_down);

  di_0_i                 <= output (31 downto 24)  when (enc = '0') else inv_mixcol_o (31 downto 24);
  di_1_i                 <= output (23 downto 16)  when (enc = '0') else inv_mixcol_o (23 downto 16);
  di_2_i                 <= output (15 downto 08)  when (enc = '0') else inv_mixcol_o (15 downto 08);
  di_3_i                 <= output (07 downto 00)  when (enc = '0') else inv_mixcol_o (07 downto 00);
--
  key_b (127 downto 000) <= key_i_int (127 downto 000) when (enc = '0') else (key_o_srl3 (43) & key_o_srl3 (42) & key_o_srl3 (41) & key_o_srl3 (40));

  current_key <= key_o_srl3(key_counter_down);

  process (clock, load)
  begin
    if (load = '1') then
      key_counter_up     <= 4;
    elsif (clock = '1' and clock'event) then
      if (key_counter_up < 43) then
        key_counter_up   <= key_counter_up + 1;
      else
        key_counter_up   <= 4;
      end if;
    end if;
  end process;
--
  process (clock, load)
  begin
    if (load = '1') then
      key_counter_down   <= 39;
    elsif (clock = '1' and clock'event) then
      if (key_counter_down > 0) then
        key_counter_down <= key_counter_down - 1;
      else
        key_counter_down <= 39;
      end if;
    end if;
  end process;
--
  process(clear, done)
  begin
    if (clear = '1') then
      counter1bit        <= '0';
    elsif (done = '1' and done'event) then
      counter1bit        <= not (counter1bit);
    end if;
  end process;
--
  process (load, counter1bit)
  begin
    if (load = '1') then
      done_decrypt       <= '0';
    elsif (counter1bit = '0' and counter1bit'event) then
      done_decrypt       <= '1';
    end if;
  end process;

end data_flow;
