-------------------------------------------------------------------------------
--
-- Generic testbench elements
--
-- $Id: tb_elems.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006 Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--      http://www.opencores.org/cvsweb.shtml/t400/
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_elems is

  generic (
    period_g  : time := 4.75 us;
    d_width_g : integer := 4;
    g_width_g : integer := 4
  );
  port (
    io_l_i  : in  std_logic_vector(7 downto 0);
    io_d_i  : in  std_logic_vector(d_width_g-1 downto 0);
    io_g_i  : in  std_logic_vector(g_width_g-1 downto 0);
    io_in_o : out std_logic_vector(g_width_g-1 downto 0);
    so_i    : in  std_logic;
    si_o    : out std_logic;
    sk_i    : in  std_logic;
    ck_o    : out std_logic
  );

end tb_elems;


library ieee;
use ieee.numeric_std.all;

architecture behav of tb_elems is

  signal en_ck_s : std_logic;

begin

  en_ck_s   <= 'H';

  -----------------------------------------------------------------------------
  -- Pass/fail catcher
  -----------------------------------------------------------------------------
  pass_fail: process (io_l_i)
    type pass_fail_t is (IDLE,
                         GOT_0, GOT_A, GOT_5);
    variable state_v : pass_fail_t := IDLE;
    variable sig_v   : std_logic_vector(3 downto 0);
  begin
    sig_v := to_X01(io_l_i(7 downto 4));

    case state_v is
      when IDLE =>
        en_ck_s <= 'Z';
        if sig_v = "0000" then
          state_v := GOT_0;
        end if;
      when GOT_0 =>
        if    sig_v = "1010" then
          state_v := GOT_A;
        elsif sig_v /= "0000" then
          state_v := IDLE;
        end if;
      when GOT_A =>
        if    sig_v = "0101" then
          state_v := GOT_5;
        elsif sig_v /= "1010" then
          state_v := IDLE;
        end if;
      when GOT_5 =>
        if    sig_v = "0000" then
          en_ck_s <= '0';
          assert false
            report "Simulation finished with PASS."
            severity note;
        elsif sig_v = "1111" then
          en_ck_s <= '0';
          assert false
            report "Simulation finished with FAIL."
            severity note;
        elsif sig_v /= "0101" then
          state_v := IDLE;
        end if;
    end case;
  end process pass_fail;


  -----------------------------------------------------------------------------
  -- D monitor
  -----------------------------------------------------------------------------
  d_moni: process (io_d_i)
    type d_moni_t is (IDLE,
                      STEP_1, STEP_2,
                      STEP_3, STEP_4);
    variable state_v : d_moni_t := IDLE;
    variable sig_v   : unsigned(3 downto 0);
  begin
    sig_v := (others => '0');
    sig_v(io_d_i'range) := unsigned(to_X01(io_d_i));

    case state_v is
      when IDLE =>
        en_ck_s   <= 'Z';
        if sig_v = 1 then
          state_v := STEP_1;
        end if;
      when STEP_1 =>
        if sig_v = 2 then
          state_v := STEP_2;
        else
          state_v := IDLE;
        end if;
      when STEP_2 =>
        if    sig_v = 4 then
          state_v := STEP_3;
        elsif sig_v /= 0 then
          state_v := IDLE;
        else
          -- sim finished for 2-bit D ports
          en_ck_s <= '0';
          assert false
            report "Simulation finished with PASS (D-Port 2 bit)."
            severity note;
        end if;
      when STEP_3 =>
        if    sig_v = 8 then
          state_v := STEP_4;
        elsif sig_v /= 0 then
          state_v := IDLE;
        else
          -- sim finished for 3-bit D ports
          en_ck_s <= '0';
          assert false
            report "Simulation finished with PASS (D-Port 3 bit)."
            severity note;
        end if;
      when STEP_4 =>
        if sig_v = 15 then
          -- sim finished pass for 4-bit D ports
          en_ck_s <= '0';
          assert false
            report "Simulation finished with PASS (D-Port 4 bit)."
            severity note;
        elsif sig_v = 0 then
          -- sim finished fail for 4-bit D ports
          en_ck_s <= '0';
          assert false
            report "Simulation finished with FAIL (D-Port 4 bit)."
            severity note;
        else
          state_v := IDLE;
        end if;

      when others =>
        null;
    end case;

  end process d_moni;


  -----------------------------------------------------------------------------
  -- G monitor
  -----------------------------------------------------------------------------
  g_moni: process (io_g_i)
    type d_moni_t is (IDLE,
                      STEP_1, STEP_2, STEP_3,
                      STEP_4);
    variable state_v : d_moni_t := IDLE;
    variable sig_v   : unsigned(3 downto 0);
  begin
    sig_v := (others => '0');
    sig_v(io_g_i'range) := unsigned(to_X01(io_g_i));

    case state_v is
      when IDLE =>
        en_ck_s   <= 'Z';
        if sig_v = 1 then
          state_v := STEP_1;
        end if;
      when STEP_1 =>
        if sig_v = 2 then
          state_v := STEP_2;
        else
          state_v := IDLE;
        end if;
      when STEP_2 =>
        if sig_v = 4 then
          state_v := STEP_3;
        else
          state_v := IDLE;
        end if;
      when STEP_3 =>
        if    sig_v = 8 then
          state_v := STEP_4;
        elsif sig_v /= 0 then
          state_v := IDLE;
        else
          -- sim finished for 3-bit G ports
          en_ck_s <= '0';
          assert false
            report "Simulation finished with PASS (G-Port 3 bit)."
            severity note;
        end if;
      when STEP_4 =>
        if sig_v /= 15 then
          state_v := IDLE;
        else
          -- sim finished for 4-bit G ports
          en_ck_s <= '0';
          assert false
            report "Simulation finished with PASS (G-Port 4 bit)."
            severity note;
        end if;

      when others =>
        null;
    end case;

  end process g_moni;


  -- feed back G on IN
  io_in_o <= io_g_i;


  -----------------------------------------------------------------------------
  -- SIO peer
  -----------------------------------------------------------------------------
  sio_peer: process
  begin
    si_o <= '0';

    wait until io_l_i(4) = '0';

    while io_l_i(4) = '0' loop
      si_o <= so_i xor sk_i after 10 us;

      wait until io_l_i'event or so_i'event or sk_i'event;
    end loop;

    -- now feed SO back to SI upon SK edge
    loop
      wait until sk_i'event and sk_i = '1';
      si_o <= so_i after 10 us;
    end loop;

    wait;
  end process sio_peer;


  -----------------------------------------------------------------------------
  -- Clock generator
  -----------------------------------------------------------------------------
  clk: process
  begin
    ck_o <= '0';
    wait for period_g / 2;
    ck_o <= '1';
    wait for period_g / 2;

    if to_X01(en_ck_s) /= '1' then
      wait;
    end if;
  end process clk;

end behav;
