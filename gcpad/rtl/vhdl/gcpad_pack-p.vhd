-------------------------------------------------------------------------------
--
-- GCpad controller core
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- $Id: gcpad_pack-p.vhd 41 2009-04-01 19:58:04Z arniml $
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package gcpad_pack is

  subtype analog_axis_t is std_logic_vector(7 downto 0);
  constant num_buttons_c : natural := 64;
  subtype buttons_t is std_logic_vector(num_buttons_c-1 downto 0);

  function "=" (a : in std_logic; b : in integer) return boolean;

  -----------------------------------------------------------------------------
  -- The button positions inside a gc packet
  -----------------------------------------------------------------------------
  -- byte 7 -------------------------------------------------------------------
  constant pos_errstat_c  : natural := 63;
  constant pos_errlatch_c : natural := 62;
  constant pos_unknown1_c : natural := 61;
  constant pos_start_c    : natural := 60;
  constant pos_y_c        : natural := 59;
  constant pos_x_c        : natural := 58;
  constant pos_b_c        : natural := 57;
  constant pos_a_c        : natural := 56;
  -- byte 6 -------------------------------------------------------------------
  constant pos_unknown2_c : natural := 55;
  constant pos_tl_c       : natural := 54;
  constant pos_tr_c       : natural := 53;
  constant pos_z_c        : natural := 52;
  constant pos_up_c       : natural := 51;
  constant pos_down_c     : natural := 50;
  constant pos_right_c    : natural := 49;
  constant pos_left_c     : natural := 48;
  -- byte 5 -------------------------------------------------------------------
  constant joy_x_high_c   : natural := 47;
  constant joy_x_low_c    : natural := 40;
  -- byte 4 -------------------------------------------------------------------
  constant joy_y_high_c   : natural := 39;
  constant joy_y_low_c    : natural := 32;
  -- byte 3 -------------------------------------------------------------------
  constant c_x_high_c     : natural := 31;
  constant c_x_low_c      : natural := 24;
  -- byte 2 -------------------------------------------------------------------
  constant c_y_high_c     : natural := 23;
  constant c_y_low_c      : natural := 16;
  -- byte 1 -------------------------------------------------------------------
  constant l_high_c       : natural := 15;
  constant l_low_c        : natural :=  8;
  -- byte 0 -------------------------------------------------------------------
  constant r_high_c       : natural :=  7;
  constant r_low_c        : natural :=  0;

end gcpad_pack;


package body gcpad_pack is

  -----------------------------------------------------------------------------
  -- Function =
  --
  -- Compares a std_logic with an integer.
  --
  function "=" (a : in std_logic; b : in integer) return boolean is
    variable result_v : boolean;
  begin
    result_v := false;

    case a is
      when '0' =>
        if b = 0 then
          result_v := true;
        end if;

      when '1' =>
        if b = 1 then
          result_v := true;
        end if;

      when others =>
        null;

    end case;

    return result_v;
  end;
  --
  -----------------------------------------------------------------------------

end gcpad_pack;
