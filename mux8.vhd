library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.TinyXconfig.ALL;
--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux8 is
    Port ( ina : in cpuWord;
           inb : in cpuWord;
           inc : in cpuWord;
           ind : in cpuWord;
           ine : in cpuWord;
           inf : in cpuWord;
           ing : in cpuWord;
           inh : in cpuWord;
           mout : out cpuWord;
           sel : in std_logic_vector(2 downto 0));
end mux8;

architecture Behavioral of mux8 is
begin
  mx8: for i in ina'range generate
    mout(i) <= (ina(i) and (not sel(2)) and (not sel(1)) and (not sel(0))) or
               (inb(i) and (not sel(2)) and  not sel(1)  and (    sel(0))) or
               (inc(i) and (not sel(2)) and      sel(1)  and (not sel(0))) or
               (ind(i) and (not sel(2)) and      sel(1)  and      sel(0) ) or
               (ine(i) and      sel(2)  and (not sel(1)) and (not sel(0))) or
               (inf(i) and      sel(2)  and  not sel(1)  and (    sel(0))) or
               (ing(i) and      sel(2)  and      sel(1)  and (not sel(0))) or
               (inh(i) and      sel(2)  and      sel(1)  and      sel(0) );
  end generate;
end Behavioral;

