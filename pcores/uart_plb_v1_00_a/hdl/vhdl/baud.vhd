-- $Id$
--
-- generates baud-rate * 16 tick
--
-- DLW = round(clk_Hz / (Desired_BaudRate x 16)) - 2
-- For baudrate 115200Hz :
-- 62.5MHz  :  DLW = 0x001F
-- 50.0MHz  :  DLW = 0x0019
--
-- =============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity baudrate is
    port(
        clk   : in  std_logic;
        rst   : in  std_logic;
        dlw   : in  std_logic_vector(15 downto 0);
        tick  : out std_logic
    );
end entity;

architecture rtl of baudrate is

signal tick_s  : std_logic := '0';
signal cnt     : std_logic_vector(dlw'range) := (others => '0'); --X"0020";

begin

    tick <= tick_s;

    process(clk)
    begin
       if rising_edge(clk) then
           if (tick_s = '1') or (rst = '1') then
                cnt <= (others => '0');
            else
                cnt <= cnt + '1';
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if cnt = dlw then
                tick_s <= '1';
            else
                tick_s <= '0';
            end if;
        end if;
    end process;

end rtl;
