-- $Id$
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Serial UART receiver
entity rcv is
    generic (DATA_BITS : integer);
    port (
        clk       : in  std_logic;  -- Clock
        rst       : in  std_logic;  -- Reset
        tick      : in  std_logic;  -- baudrate*16 tick
        sin       : in  std_logic;  -- Receiver serial input
        dout      : out std_logic_vector(DATA_BITS-1 downto 0);   -- Output data
        done      : out std_logic   -- Receiver operation finished
    );
end rcv;

architecture rtl of rcv is

    signal shift_reg      : std_logic_vector(DATA_BITS downto 0) := (others=>'1');
    signal shift_cnt      : std_logic_vector(DATA_BITS downto 0) := (others=>'1');
    signal baud_cnt       : std_logic_vector(3 downto 0);
    signal start_bit_cnt  : std_logic_vector(2 downto 0);
    signal start_rcv      : std_logic;
    signal baud_tick      : std_logic;
    signal shift_cnt_0_q  : std_logic;

begin

    dout  <= shift_reg (dout'range);

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                shift_cnt_0_q <= '1';
                done <= '0';
            else
                shift_cnt_0_q <= shift_cnt(0);
                if (shift_cnt(0) = '1') and (shift_cnt_0_q <= '0') then
                    done <= '1';
                else
                    done <= '0';
                end if;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            -- finished recv data and a start-bit comes in
            if (shift_cnt(0) = '1') and (sin = '0') then
                if (tick = '1') then
                    start_bit_cnt <= start_bit_cnt + 1;
                end if;
            else
                start_bit_cnt <= (others=>'0');
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            -- find the middle of start-bit
            if (start_bit_cnt = "111") and (tick = '1') then
                start_rcv <= '1';  -- start receiving data
            else
                start_rcv <= '0';
            end if;
        end if;
    end process;

    -- count baud_tick while receiving data, roll-over when overflowed
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                baud_cnt <= (others=>'0');
            elsif (tick = '1') and (shift_cnt(0) = '0') then
                baud_cnt <= baud_cnt + 1;
            end if;
        end if;
    end process;

    -- generate baudrate tick from counting baud_tick 16 times
    -- to indicate it is time to receive a bit
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

    -- receive a bit
    process(clk)
    begin
        if rising_edge(clk) then
            if (baud_tick = '1') then
                shift_reg <= sin & shift_reg(shift_reg'left downto 1);
            end if;
        end if;
    end process;

    -- count how many bits have been received
    -- shift_cnt(0) will be '1' when all bits are received
    process(clk)
    begin
        if rising_edge(clk) then
            if (start_rcv = '1') then
                shift_cnt <= (others=>'0');
            elsif (baud_tick = '1') then
                shift_cnt <= '1' & shift_cnt(shift_reg'left downto 1);
            end if;
        end if;
    end process;

end rtl;
