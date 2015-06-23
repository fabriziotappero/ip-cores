-------------------------------------------------------------------------------
--
-- Testbench for the
-- SNESpad controller core
--
-- $Id: tb.vhd 41 2009-04-01 19:58:04Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
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
--      http://www.opencores.org/cvsweb.shtml/gamepads/
--
-- The project homepage is located at:
--      http://www.opencores.org/projects.cgi/web/gamepads/overview
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb is

end tb;


use work.snespad_pack.all;
use work.snespad_comp.snespad;

architecture behav of tb is

  constant period_c       : time    := 100 ns;
  constant num_pads_c     : natural := 2;
  constant reset_level_c  : natural := 0;
  constant button_level_c : natural := 0;


  signal clk_s   : std_logic;
  signal reset_s : std_logic;

  signal pad_clk_s   : std_logic;
  signal pad_latch_s : std_logic;
  signal pad_data_s  : std_logic_vector(num_pads_c-1 downto 0);

  type buttons_t is array (11 downto 0) of std_logic_vector(num_pads_c-1 downto 0);
  signal buttons_s : buttons_t;

  signal buttons0_s,
         buttons1_s  : std_logic_vector(11 downto 0);
         

begin

  dut : snespad
    generic map (
      num_pads_g       => 2,
      reset_level_g    => reset_level_c,
      button_level_g   => button_level_c,
      clocks_per_6us_g => 60
    )
    port map (
      clk_i            => clk_s,
      reset_i          => reset_s,
      pad_clk_o        => pad_clk_s,
      pad_latch_o      => pad_latch_s,
      pad_data_i       => pad_data_s,
      but_a_o          => buttons_s(but_pos_a_c),
      but_b_o          => buttons_s(but_pos_b_c),
      but_x_o          => buttons_s(but_pos_x_c),
      but_y_o          => buttons_s(but_pos_y_c),
      but_start_o      => buttons_s(but_pos_start_c),
      but_sel_o        => buttons_s(but_pos_sel_c),
      but_tl_o         => buttons_s(but_pos_tl_c),
      but_tr_o         => buttons_s(but_pos_tr_c),
      but_up_o         => buttons_s(but_pos_up_c),
      but_down_o       => buttons_s(but_pos_down_c),
      but_left_o       => buttons_s(but_pos_left_c),
      but_right_o      => buttons_s(but_pos_right_c)
    );

  buttons: process (buttons_s)
  begin
    for i in 0 to 11 loop
      buttons0_s(i) <= buttons_s(i)(0);
      buttons1_s(i) <= buttons_s(i)(1);
    end loop;
  end process buttons;

  -----------------------------------------------------------------------------
  -- DUT Stimuli
  -----------------------------------------------------------------------------
  stimuli: process

    procedure dispatch(pad : in natural;
                       packet : in std_logic_vector(11 downto 0)) is
    begin

      wait until pad_latch_s = '0';
      for i in 11 downto 0 loop
        wait until pad_clk_s = '0';
        pad_data_s(pad) <= packet(i);
        wait until pad_clk_s = '1';
      end loop;

      wait for period_c;

      assert pad_latch_s = '1'
        report "Latch not deasserted!"
        severity error;

      wait for period_c;
      for i in 11 downto 0 loop
        assert button_active_f(buttons_s(i)(pad), button_level_c) = packet(i)
          report "Mismatch for received vs. sent buttons!"
          severity error;
      end loop;

    end dispatch;

  begin
    pad_data_s <= (others => '1');

    wait until reset_s = '1';
    wait for period_c * 4;

    for pad in 0 to 1 loop
      dispatch(pad, packet => "000000000000");
      dispatch(pad, packet => "111111111111");
      dispatch(pad, packet => "010101010101");
      dispatch(pad, packet => "101010101010");
      dispatch(pad, packet => "100000000000");
      dispatch(pad, packet => "010000000000");
      dispatch(pad, packet => "001000000000");
      dispatch(pad, packet => "000100000000");
      dispatch(pad, packet => "000010000000");
      dispatch(pad, packet => "000001000000");
      dispatch(pad, packet => "000000100000");
      dispatch(pad, packet => "000000010000");
      dispatch(pad, packet => "000000001000");
      dispatch(pad, packet => "000000000100");
      dispatch(pad, packet => "000000000010");
      dispatch(pad, packet => "000000000001");
    end loop;


    wait for period_c * 4;
    assert false
      report "End of simulation reached."
      severity failure;

  end process stimuli;


  -----------------------------------------------------------------------------
  -- Clock Generator
  -----------------------------------------------------------------------------
  clk: process
  begin
    clk_s <= '0';
    wait for period_c / 2;
    clk_s <= '1';
    wait for period_c / 2;
  end process clk;


  -----------------------------------------------------------------------------
  -- Reset Generator
  -----------------------------------------------------------------------------
  reset: process
  begin
    if reset_level_c = 0 then
      reset_s <= '0';
    else
      reset_s <= '1';
    end if;

    wait for period_c * 4 + 10 ns;

    reset_s <= not reset_s;

    wait;
  end process reset;

end behav;
