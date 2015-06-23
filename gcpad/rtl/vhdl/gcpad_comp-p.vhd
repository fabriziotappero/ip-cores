-------------------------------------------------------------------------------
--
-- GCpad controller core
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- $Id: gcpad_comp-p.vhd 41 2009-04-01 19:58:04Z arniml $
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package gcpad_comp is

  component gcpad_basic
    generic (
      reset_level_g    :       integer := 0;
      clocks_per_1us_g :       integer := 2
    );
    port (
      clk_i            : in    std_logic;
      reset_i          : in    std_logic;
      pad_request_i    : in    std_logic;
      pad_avail_o      : out   std_logic;
      pad_data_io      : inout std_logic;
      but_a_o          : out   std_logic;
      but_b_o          : out   std_logic;
      but_x_o          : out   std_logic;
      but_y_o          : out   std_logic;
      but_z_o          : out   std_logic;
      but_start_o      : out   std_logic;
      but_tl_o         : out   std_logic;
      but_tr_o         : out   std_logic;
      but_left_o       : out   std_logic;
      but_right_o      : out   std_logic;
      but_up_o         : out   std_logic;
      but_down_o       : out   std_logic;
      ana_joy_x_o      : out   std_logic_vector(7 downto 0);
      ana_joy_y_o      : out   std_logic_vector(7 downto 0);
      ana_c_x_o        : out   std_logic_vector(7 downto 0);
      ana_c_y_o        : out   std_logic_vector(7 downto 0);
      ana_l_o          : out   std_logic_vector(7 downto 0);
      ana_r_o          : out   std_logic_vector(7 downto 0)
    );
  end component;

  component gcpad_full
    generic (
      reset_level_g    :       integer := 0;
      clocks_per_1us_g :       integer := 2
    );
    port (
      clk_i            : in    std_logic;
      reset_i          : in    std_logic;
      pad_request_i    : in    std_logic;
      pad_avail_o      : out   std_logic;
      pad_timeout_o    : out   std_logic;
      tx_size_i        : in    std_logic_vector( 1 downto 0);
      tx_command_i     : in    std_logic_vector(23 downto 0);
      rx_size_i        : in    std_logic_vector( 3 downto 0);
      rx_data_o        : out   std_logic_vector(63 downto 0);
      pad_data_io      : inout std_logic
    );
  end component;


end gcpad_comp;
