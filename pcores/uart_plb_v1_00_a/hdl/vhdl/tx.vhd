-- $Id$
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Serial UART transmitter
entity xmt is
    generic (DATA_BITS : integer);
    port (
        clk       : in  std_logic;  -- Clock
        rst       : in  std_logic;  -- Reset
        tick      : in  std_logic;  -- baudrate * 16 tick
        wr        : in  std_logic;  -- write din to transmitter
        din       : in  std_logic_vector(DATA_BITS-1 downto 0);  -- Input data
        sout      : out std_logic;  -- Transmitter serial output
        done      : out std_logic   -- level signal, transmit shift register empty
    );
end xmt;

architecture rtl of xmt is

    signal shift_reg : std_logic_vector(DATA_BITS downto 0) := (others=>'1');
    signal shift_cnt : std_logic_vector(DATA_BITS+1 downto 0) := (others=>'1');
    signal baud_cnt  : std_logic_vector(3 downto 0) := (others=>'0');
    signal baud_tick : std_logic := '0';
    signal sout_s    : std_logic := '1';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                baud_cnt <= (others=>'0');
            elsif (tick = '1') then
                baud_cnt <= baud_cnt + 1;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if (baud_cnt = "1111") and (tick = '1') then
                baud_tick <= '1';
            else
                baud_tick <= '0';
            end if;
        end if;
    end process;

    sout <= sout_s;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sout_s <= '1';
            elsif (baud_tick = '1') then
                sout_s <= shift_reg(0);
            end  if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if wr = '1' then
                shift_reg <= din & '0'; -- add start bit
                shift_cnt <= (others=>'0');
            elsif (baud_tick = '1') then
                shift_reg <= '1' & shift_reg(shift_reg'left downto 1); -- shift out and add stop bits
                shift_cnt <= '1' & shift_cnt(shift_cnt'left downto 1); -- shift out and add done bits
            end if;
        end if;
    end process;

    done <= shift_cnt(0); -- it will be '1' when finished sending

end rtl;

