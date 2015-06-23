-- Testbench for slib_clock_div
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;

entity tb_slib_clock_div is
end tb_slib_clock_div;

architecture tb of tb_slib_clock_div is
    component slib_clock_div is
        generic (
            RATIO       : integer := 16     -- Clock divider ratio
        );
        port (
            CLK         : in std_logic;     -- Clock
            RST         : in std_logic;     -- Reset
            CE          : in std_logic;     -- Clock enable input
            Q           : out std_logic     -- New clock enable output
        );
    end component;

    -- Signals
    signal clk, rst, q : std_logic;
    constant cycle  : time := 30 ns;
begin
    -- Clock process
    process
    begin
        clk <= '0';
        wait for cycle/2;
        clk <= '1';
        wait for cycle/2;
    end process;

    DUT: slib_clock_div generic map (
                            RATIO => 16
                        ) port map (
                            clk, rst, '1', q
                        );

    -- Test process
    DUTPROC: process
    begin
        rst <= '1';
        wait until falling_edge(CLK); wait for 3*cycle;
        rst <= '0';

        wait for 500*cycle;
    end process;

end tb;

-- Testbench for slib_mv_filter
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;

entity tb_slib_mv_filter is
end tb_slib_mv_filter;

architecture tb of tb_slib_mv_filter is
    component slib_mv_filter is
        generic (
            WIDTH       : natural := 4;
            THRESHOLD   : natural := 10
        );
        port (
            CLK         : in std_logic;                             -- Clock
            RST         : in std_logic;                             -- Reset
            SAMPLE      : in std_logic;                             -- Clock enable for sample process
            CLEAR       : in std_logic;                             -- Reset process
            D           : in std_logic;                             -- Signal input
            Q           : out std_logic                             -- Signal D was at least THRESHOLD samples high
        );
    end component;

    -- Signals
    signal clk, rst, sample, clear, d, q : std_logic;
    constant cycle  : time := 30 ns;
    constant scycle : time := 3000 ns;
begin
    -- Clock process
    process
    begin
        clk <= '0';
        wait for cycle/2;
        clk <= '1';
        wait for cycle/2;
    end process;
    -- Sample clock process
    process
    begin
        sample <= '0';
        wait for scycle/2;
        sample <= '1';
        wait for cycle;
    end process;

    DUT: slib_mv_filter generic map (
                            WIDTH     => 4,
                            THRESHOLD => 10
                        ) port map (
                            clk, rst, sample, clear, d, q
                        );

    -- Test process
    DUTPROC: process
    begin
        rst <= '1'; d <= '0'; clear <= '0';
        wait until falling_edge(CLK); wait for 3*cycle;
        rst <= '0';
        wait for 2*scycle;
        d <= '1';
        wait for 4*scycle;
        d <= '0';
        wait for 2*scycle;
        d <= '1';
        wait for scycle;
        d <= '1';
        wait for 5*scycle;
        clear <= '1';
        wait for cycle;
        clear <= '0';
        wait for 10*scycle;
        d <= '0';


        wait for 500*scycle;
    end process;


end tb;

-- Testbench for slib_shift_reg
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;

entity tb_slib_shift_reg is
end tb_slib_shift_reg;

architecture tb of tb_slib_shift_reg is
    -- Serial shift register
    component slib_shift_reg is
        generic (
        WIDTH : natural := 16            -- Register width
        );
        port (
        CLK         : in std_logic;      -- Clock
        RST         : in std_logic;      -- Reset
        ENABLE      : in std_logic;      -- Enable shift operation
        LOAD        : in std_logic;      -- Load shift register
        DIR         : in std_logic;      -- Shift direction
        MSB_IN      : in std_logic;      -- MSB in
        LSB_IN      : in std_logic;      -- LSB in
        DIN         : in std_logic_vector(WIDTH-1 downto 0);    -- Load shift register input
        DOUT        : out std_logic_vector(WIDTH-1 downto 0)    -- Shift register output
        );
    end component;
    -- Signals
    signal clk, rst, enable, load, dir, msb_in, lsb_in : std_logic;
    signal din, dout : std_logic_vector(15 downto 0);
    constant cycle : time := 30 ns;
begin
    -- Clock process
    process
    begin
        CLK <= '0';
        wait for cycle/2;
        CLK <= '1';
        wait for cycle/2;
    end process;

    DUT: slib_shift_reg port map (
        clk, rst , enable, load, dir,
        msb_in, lsb_in, din, dout);

    -- Test process
    DUTPROC: process
    begin
        rst <= '1'; enable <= '0'; load <= '0'; dir <= '0'; msb_in <= '0';
        lsb_in <= '0'; din <= x"abcd";
        wait until rising_edge(CLK); wait for 3*cycle;
        rst <= '0';
        wait for cycle; load <= '1'; wait for cycle; load <= '0';
        wait for cycle; enable <= '1';
        wait for 4*cycle; dir <= '1';
        wait for 3*cycle; msb_in <= '1';
        wait for 2*cycle; dir <= '0'; lsb_in <= '1';
        wait for 10*cycle; rst <= '0'; wait for cycle; rst <= '1';
        lsb_in <= '0';

        din <= x"0001"; load <= '1'; wait for cycle; load <= '0';

        wait for 500*cycle;
    end process;

end tb;

