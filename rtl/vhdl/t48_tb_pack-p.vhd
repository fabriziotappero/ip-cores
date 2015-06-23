-------------------------------------------------------------------------------
--
-- $Id: t48_tb_pack-p.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package t48_tb_pack is

  -- Instruction strobe visibility
  signal tb_istrobe_s : std_logic;

  -- Accumulator visibilty
  signal tb_accu_s : std_logic_vector(7 downto 0);

end t48_tb_pack;
