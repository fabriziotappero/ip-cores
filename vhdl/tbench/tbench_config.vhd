library ieee;
use ieee.std_logic_1164.all;
use work.tbench_comp.all;

entity tbench_config is
end tbench_config;

architecture behav of tbench_config is
    signal i       : tbench_gen_typ_in;
    signal o       : tbench_gen_typ_out;
begin  
  tb0: tbench_gen port map (i,o);
end behav;



