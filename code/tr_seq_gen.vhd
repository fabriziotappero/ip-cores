library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tr_seq_gen is
    Port ( clock : in std_logic;
           reset : in std_logic;
           data_out : out std_logic_vector(7 downto 0));
end tr_seq_gen;

architecture Behavioral of tr_seq_gen is

begin


end Behavioral;
