library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.TinyXconfig.ALL;
--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux2 is
    Port ( ina : in cpuWord;
           inb : in cpuWord;
           mout : out cpuWord;
           sel : in std_logic);
end mux2;

architecture Behavioral of mux2 is
begin
  mx2: for i in ina'range generate
    mout(i) <= (ina(i) and (not sel)) or (inb(i) and sel);
  end generate;
end Behavioral;

