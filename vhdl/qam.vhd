library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity qam is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    input : in  std_logic_vector(1 downto 0);
    Iout  : out std_logic_vector(11 downto 0);
    Qout  : out std_logic_vector(11 downto 0));
end qam;

architecture qam of qam is

begin

  process (clk, rst)
    constant mais1  : std_logic_vector(11 downto 0) := "001100000000";
    constant menos1 : std_logic_vector(11 downto 0) := "110100000000";
  begin
    if rst = '1' then
      Iout <= (others => '0');
      Qout <= (others => '0');
    elsif clk'event and clk = '1' then
-- 0123.45678901 bits
--      0011.00000000 = +1
--      1101.00000000 = -1

--                Q
--        o       |       o 
--        01      |       00
--                |
--        ----------------- I
--                |
--        11      |       10
--        o       |        o

      case input is
        when "00" =>
          Iout <= mais1;
          Qout <= mais1;
        when "01" =>
          Iout <= menos1;
          Qout <= mais1;
        when "10" =>
          Iout <= mais1;
          Qout <= menos1;
        when others =>
          Iout <= menos1;
          Qout <= menos1;
      end case;
    end if;
  end process;

end qam;
