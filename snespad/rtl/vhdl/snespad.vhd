-------------------------------------------------------------------------------
--
-- SNESpad controller core
--
-- $Id: snespad.vhd 41 2009-04-01 19:58:04Z arniml $
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

entity snespad is

  generic (
    -- number of pads connected to this core
    num_pads_g       :     natural := 1;
    -- active level of reset_i
    reset_level_g    :     natural := 0;
    -- active level of the button outputs
    button_level_g   :     natural := 0;
    -- number of clk_i periods during 6us
    clocks_per_6us_g :     natural := 6
  );
  port (
    -- System Interface -------------------------------------------------------
    clk_i            : in  std_logic;
    reset_i          : in  std_logic;
    -- Gamepad Interface ------------------------------------------------------
    pad_clk_o        : out std_logic;
    pad_latch_o      : out std_logic;
    pad_data_i       : in  std_logic_vector(num_pads_g-1 downto 0);
    -- Buttons Interface ------------------------------------------------------
    but_a_o          : out std_logic_vector(num_pads_g-1 downto 0);
    but_b_o          : out std_logic_vector(num_pads_g-1 downto 0);
    but_x_o          : out std_logic_vector(num_pads_g-1 downto 0);
    but_y_o          : out std_logic_vector(num_pads_g-1 downto 0);
    but_start_o      : out std_logic_vector(num_pads_g-1 downto 0);
    but_sel_o        : out std_logic_vector(num_pads_g-1 downto 0);
    but_tl_o         : out std_logic_vector(num_pads_g-1 downto 0);
    but_tr_o         : out std_logic_vector(num_pads_g-1 downto 0);
    but_up_o         : out std_logic_vector(num_pads_g-1 downto 0);
    but_down_o       : out std_logic_vector(num_pads_g-1 downto 0);
    but_left_o       : out std_logic_vector(num_pads_g-1 downto 0);
    but_right_o      : out std_logic_vector(num_pads_g-1 downto 0)
  );

end snespad;


architecture struct of snespad is

  component snespad_ctrl
    generic (
      reset_level_g    :     natural := 0;
      clocks_per_6us_g :     natural := 6
    );
    port (
      clk_i            : in  std_logic;
      reset_i          : in  std_logic;
      clk_en_o         : out boolean;
      shift_buttons_o  : out boolean;
      save_buttons_o   : out boolean;
      pad_clk_o        : out std_logic;
      pad_latch_o      : out std_logic
    );
  end component snespad_ctrl;

  component snespad_pad
    generic (
      reset_level_g   :     natural := 0;
      button_level_g  :     natural := 0
    );
    port (
      clk_i           : in  std_logic;
      reset_i         : in  std_logic;
      clk_en_i        : in  boolean;
      shift_buttons_i : in  boolean;
      save_buttons_i  : in  boolean;
      pad_data_i      : in  std_logic;
      but_a_o         : out std_logic;
      but_b_o         : out std_logic;
      but_x_o         : out std_logic;
      but_y_o         : out std_logic;
      but_start_o     : out std_logic;
      but_sel_o       : out std_logic;
      but_tl_o        : out std_logic;
      but_tr_o        : out std_logic;
      but_up_o        : out std_logic;
      but_down_o      : out std_logic;
      but_left_o      : out std_logic;
      but_right_o     : out std_logic
    );
  end component snespad_pad;


  signal clk_en_s : boolean;
  signal shift_buttons_s : boolean;
  signal save_buttons_s : boolean;

begin

  ctrl_b : snespad_ctrl
    generic map (
      reset_level_g    => reset_level_g,
      clocks_per_6us_g => clocks_per_6us_g
    )
    port map (
      clk_i            => clk_i,
      reset_i          => reset_i,
      clk_en_o         => clk_en_s,
      shift_buttons_o  => shift_buttons_s,
      save_buttons_o   => save_buttons_s,
      pad_clk_o        => pad_clk_o,
      pad_latch_o      => pad_latch_o
    );


  pads: for i in 0 to num_pads_g-1 generate
    pad_b : snespad_pad
      generic map (
        reset_level_g   => reset_level_g,
        button_level_g  => button_level_g
      )
      port map (
        clk_i           => clk_i,
        reset_i         => reset_i,
        clk_en_i        => clk_en_s,
        shift_buttons_i => shift_buttons_s,
        save_buttons_i  => save_buttons_s,
        pad_data_i      => pad_data_i(i),
        but_a_o         => but_a_o(i),
        but_b_o         => but_b_o(i),
        but_x_o         => but_x_o(i),
        but_y_o         => but_y_o(i),
        but_start_o     => but_start_o(i),
        but_sel_o       => but_sel_o(i),
        but_tl_o        => but_tl_o(i),
        but_tr_o        => but_tr_o(i),
        but_up_o        => but_up_o(i),
        but_down_o      => but_down_o(i),
        but_left_o      => but_left_o(i),
        but_right_o     => but_right_o(i)
      );
  end generate;

end struct;
