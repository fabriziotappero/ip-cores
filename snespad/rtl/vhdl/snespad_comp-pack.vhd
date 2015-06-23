-------------------------------------------------------------------------------
--
-- SNESpad controller core
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- $Id: snespad_comp-pack.vhd 41 2009-04-01 19:58:04Z arniml $
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package snespad_comp is

  component snespad
    generic (
      num_pads_g       :     natural := 1;
      reset_level_g    :     natural := 0;
      button_level_g   :     natural := 0;
      clocks_per_6us_g :     natural := 6
    );
    port (
      clk_i            : in  std_logic;
      reset_i          : in  std_logic;
      pad_clk_o        : out std_logic;
      pad_latch_o      : out std_logic;
      pad_data_i       : in  std_logic_vector(num_pads_g-1 downto 0);
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
  end component snespad;

end snespad_comp;
