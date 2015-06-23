library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.uart_components.UNSIGNED_NUM_BITS;

entity tmo is
    Port ( clk       : in  STD_LOGIC;
           clr       : in  STD_LOGIC;
           tick      : in  STD_LOGIC;
           timeout   : out STD_LOGIC); --pulse signal
end tmo;

architecture Behavioral of tmo is

-- one rcv_tick = 16 baud_tick
-- one bytte = 10 rcv_tick
-- delay 2 bytes
constant CNT_MAX    : integer := 16 * 10 * 2;
signal   cnt        : integer range 0 to 16 * 16 * 2;
signal   time_out_s : std_logic := '0';
signal   time_out_q : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if (clr = '1') then
                cnt <= 0;
            elsif (tick = '1') then
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                time_out_s <= '0';
            elsif (cnt = CNT_MAX) then
                time_out_s <= '1';
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            time_out_q <= time_out_s;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if (time_out_s = '1' and time_out_q = '0') then
                timeout <= '1';
            else
                timeout <= '0';
            end if;
        end if;
    end process;

end Behavioral;

