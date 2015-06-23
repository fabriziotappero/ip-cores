library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity qamdecoder is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    Iin    : in  std_logic;
    Qin    : in  std_logic;
    output : out std_logic_vector(1 downto 0));
end qamdecoder;

architecture qamdecoder of qamdecoder is

begin
  process(clk, rst)

--                Q
--        o       |       o 
--        01      |       00
--                |
--        ----------------- I
--                |
--        11      |       10
--        o       |        o

  begin
    if rst = '1' then
      output <= (others => '0');
    elsif clk'event and clk = '1' then
       output <= Qin&Iin;
    end if;
  end process;
end qamdecoder;
