-------------------------------------------------------------------------------
--
-- $Id: t400_io_pack-p.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package t400_io_pack is

  function io_out_f(dat : in std_logic;
                    opt : in integer) return std_logic;

  function io_en_f (en  : in std_logic;
                    dat : in std_logic;
                    opt : in integer) return std_logic;

end t400_io_pack;


use work.t400_opt_pack.all;

package body t400_io_pack is

  function io_out_f(dat : in std_logic;
                    opt : in integer) return std_logic is
    variable result_v : std_logic;
  begin
    result_v := '-';

    case opt is
      -- Open drain type output drivers ---------------------------------------
      when t400_opt_out_type_od_c  =>
        result_v := '0';

      -- Push/pull type output drivers ----------------------------------------
      when t400_opt_out_type_std_c |
           t400_opt_out_type_led_c |
           t400_opt_out_type_pp_c  =>
        result_v := dat;

      when others =>
        null;
    end case;

    return result_v;
  end io_out_f;


  function io_en_f (en  : in std_logic;
                    dat : in std_logic;
                    opt : in integer) return std_logic is
    variable result_v : std_logic;
  begin
    result_v := '0';

    case opt is
      -- Open drain type output drivers ---------------------------------------
      when t400_opt_out_type_od_c  =>
        if en = '1' and dat = '0' then
          result_v := '1';
        end if;

      -- Push/pull type output drivers ----------------------------------------
      when t400_opt_out_type_std_c |
           t400_opt_out_type_led_c |
           t400_opt_out_type_pp_c  =>
        result_v := en;

      when others =>
        null;
    end case;

    return result_v;
  end io_en_f;

end t400_io_pack;
