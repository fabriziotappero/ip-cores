-------------------------------------------------------------------------------
--
-- GCpad controller core
--
-- $Id: gcpad_basic.vhd 41 2009-04-01 19:58:04Z arniml $
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

entity gcpad_basic is

  generic (
    -- active level of reset_i
    reset_level_g    :       integer := 0;
    -- number of clk_i periods during 1us
    clocks_per_1us_g :       integer := 2
  );
  port (
    -- System Interface -------------------------------------------------------
    clk_i            : in    std_logic;
    reset_i          : in    std_logic;
    pad_request_i    : in    std_logic;
    pad_avail_o      : out   std_logic;
    -- Gamepad Interface ------------------------------------------------------
    pad_data_io      : inout std_logic;
    -- Buttons Interface ------------------------------------------------------
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

end gcpad_basic;


use work.gcpad_pack.all;

architecture struct of gcpad_basic is

  component gcpad_ctrl
    generic (
      reset_level_g :     integer := 0
    );
    port (
      clk_i         : in  std_logic;
      reset_i       : in  std_logic;
      pad_request_i : in  std_logic;
      pad_avail_o   : out std_logic;
      rx_timeout_o  : out std_logic;
      tx_start_o    : out boolean;
      tx_finished_i : in  boolean;
      rx_en_o       : out boolean;
      rx_done_i     : in  boolean;
      rx_data_ok_i  : in  boolean
    );
  end component;

  component gcpad_tx
    generic (
      reset_level_g    :     natural := 0;
      clocks_per_1us_g :     natural := 2
    );
    port (
      clk_i            : in  std_logic;
      reset_i          : in  std_logic;
      pad_data_o       : out std_logic;
      tx_start_i       : in  boolean;
      tx_finished_o    : out boolean;
      tx_size_i        : in  std_logic_vector( 1 downto 0);
      tx_command_i     : in  std_logic_vector(23 downto 0)
    );
  end component;

  component gcpad_rx
    generic (
      reset_level_g    :     integer := 0;
      clocks_per_1us_g :     integer := 2
    );
    port (
      clk_i            : in  std_logic;
      reset_i          : in  std_logic;
      rx_en_i          : in  boolean;
      rx_done_o        : out boolean;
      rx_data_ok_o     : out boolean;
      rx_size_i        : in  std_logic_vector(3 downto 0);
      pad_data_i       : in  std_logic;
      rx_data_o        : out buttons_t
    );
  end component;


  -----------------------------------------------------------------------------
  -- constants for standard status polling
  constant rx_size_c    : std_logic_vector( 3 downto 0) := "1000";
  signal   rx_size_s    : std_logic_vector( 3 downto 0);
  --
  constant tx_size_c    : std_logic_vector( 1 downto 0) := "11";
  signal   tx_size_s    : std_logic_vector( 1 downto 0);
  --
  constant tx_command_c : std_logic_vector(23 downto 0) := "010000000000001100000010";
  signal   tx_command_s : std_logic_vector(23 downto 0);
  --
  -----------------------------------------------------------------------------

  signal pad_data_tx_s : std_logic;

  signal tx_start_s    : boolean;
  signal tx_finished_s : boolean;

  signal rx_en_s,
         rx_done_s,
         rx_data_ok_s : boolean;

  signal rx_data_s : buttons_t;

begin

  rx_size_s    <= rx_size_c;
  tx_size_s    <= tx_size_c;
  tx_command_s <= tx_command_c;

  ctrl_b : gcpad_ctrl
    generic map (
      reset_level_g => reset_level_g
    )
    port map (
      clk_i         => clk_i,
      reset_i       => reset_i,
      pad_request_i => pad_request_i,
      pad_avail_o   => pad_avail_o,
      rx_timeout_o  => open,
      tx_start_o    => tx_start_s,
      tx_finished_i => tx_finished_s,
      rx_en_o       => rx_en_s,
      rx_done_i     => rx_done_s,
      rx_data_ok_i  => rx_data_ok_s
    );

  tx_b : gcpad_tx
    generic map (
      reset_level_g    => reset_level_g,
      clocks_per_1us_g => clocks_per_1us_g
    )
    port map (
      clk_i            => clk_i,
      reset_i          => reset_i,
      pad_data_o       => pad_data_tx_s,
      tx_start_i       => tx_start_s,
      tx_finished_o    => tx_finished_s,
      tx_size_i        => tx_size_s,
      tx_command_i     => tx_command_s
    );

  rx_b : gcpad_rx
    generic map (
      reset_level_g    => reset_level_g,
      clocks_per_1us_g => clocks_per_1us_g
    )
    port map (
      clk_i            => clk_i,
      reset_i          => reset_i,
      rx_en_i          => rx_en_s,
      rx_done_o        => rx_done_s,
      rx_data_ok_o     => rx_data_ok_s,
      rx_size_i        => rx_size_s,
      pad_data_i       => pad_data_io,
      rx_data_o        => rx_data_s
  );


  -----------------------------------------------------------------------------
  -- Open collector driver to pad data
  -----------------------------------------------------------------------------
  pad_data_io <=   '0'
                 when pad_data_tx_s = '0' else
                   'Z';

  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  but_a_o     <= rx_data_s(pos_a_c);
  but_b_o     <= rx_data_s(pos_b_c);
  but_x_o     <= rx_data_s(pos_x_c);
  but_y_o     <= rx_data_s(pos_y_c);
  but_z_o     <= rx_data_s(pos_z_c);
  but_start_o <= rx_data_s(pos_start_c);
  but_tl_o    <= rx_data_s(pos_tl_c);
  but_tr_o    <= rx_data_s(pos_tr_c);
  but_left_o  <= rx_data_s(pos_left_c);
  but_right_o <= rx_data_s(pos_right_c);
  but_up_o    <= rx_data_s(pos_up_c);
  but_down_o  <= rx_data_s(pos_down_c);
  ana_joy_x_o <= rx_data_s(joy_x_high_c downto joy_x_low_c);
  ana_joy_y_o <= rx_data_s(joy_y_high_c downto joy_y_low_c);
  ana_c_x_o   <= rx_data_s(c_x_high_c   downto c_x_low_c);
  ana_c_y_o   <= rx_data_s(c_y_high_c   downto c_y_low_c);
  ana_l_o     <= rx_data_s(l_high_c     downto l_low_c);
  ana_r_o     <= rx_data_s(r_high_c     downto r_low_c);

end struct;
