-------------------------------------------------------------------------------
--
-- Filename:      testbench.vhd
-- Author:        David Sala
-- Description:   Divider Testbench
-- Comment:
--
-- Version history:
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_signed.ALL;

-------------------------------------------------------------------------------
-- ENTITY
-------------------------------------------------------------------------------
entity testbench is
end testbench;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture behavioral of testbench is



component serial_divide_uu
  generic ( M_PP : integer := 16;           -- Size of dividend
            N_PP : integer := 8;            -- Size of divisor
            R_PP : integer := 0;            -- Size of remainder
            S_PP : integer := 0;            -- Skip this many bits (known leading zeros)
            HELD_OUTPUT_PP : integer := 0); -- Set to 1 if stable output should be held
                                            -- from previous operation, during current
                                            -- operation.  Using this option will increase
                                            -- the resource utilization (costs extra
                                            -- d-flip-flops.)
    port(   clk_i      : in  std_logic;
            clk_en_i   : in  std_logic;
            rst_i      : in  std_logic;
            divide_i   : in  std_logic;
            dividend_i : in  std_logic_vector(M_PP-1 downto 0);
            divisor_i  : in  std_logic_vector(N_PP-1 downto 0);
            quotient_o : out std_logic_vector(M_PP+R_PP-S_PP-1 downto 0);
            done_o     : out std_logic
    );
end component;



signal     clk_i      : std_logic;
signal     clk_en_i   : std_logic;
signal     rst_i      : std_logic;
signal     divide_i   : std_logic;
signal     dividend_i : std_logic_vector(20 downto 0);
signal     divisor_i  : std_logic_vector(20 downto 0);
signal     quotient_o : std_logic_vector(20 downto 0);
signal     done_o     : std_logic;

signal     expected : std_logic_vector(20 downto 0);



begin

I_serial_divide_uu: serial_divide_uu
  generic map ( M_PP => 21,
                N_PP => 21,
                R_PP => 0,
                S_PP => 0,
                HELD_OUTPUT_PP => 1)
    port map ( clk_i      => clk_i,
               clk_en_i   => clk_en_i,
               rst_i      => rst_i,
               divide_i   => divide_i,
               dividend_i => dividend_i,
               divisor_i  => divisor_i,
               quotient_o => quotient_o,
               done_o     => done_o );

clk_en_i <='1';

stim_gen: process
begin

	dividend_i <= "000000011100000110100"; -- 14388;
	divisor_i  <= "000000000000000000000"; -- 64
     expected <= "000000000000011100000"; -- 224;
	wait for 10000 ns;
	dividend_i <= "000000010111111101111"; -- 12271;
	divisor_i <= "000000000000001111101"; -- 125;
        expected <= "000000000000001100010"; -- 98;
	wait for 10000 ns;
	dividend_i <= "000000011100000110100"; -- 14388;
	divisor_i <= "000000000000010111010"; -- 186;
        expected <= "000000000000001001101"; -- 77;
	wait for 10000 ns;
	dividend_i <= "101100100010001111100"; -- 1459324;
	divisor_i <=  "000010100111001110101"; -- 85621;
      expected <= "000000000000000010001"; -- 17;
	wait for 10000 ns;
	dividend_i <= "000000011100000110100"; -- 14388;
	divisor_i <= "000000000000010111010"; -- 186;
        expected <= "000000000000001001101"; -- 77;
	wait for 100 ns;
	wait;
end process;


stim_gen2: process
begin
    divide_i <= '0';
	wait for 100 ns;
    divide_i <= '1';
	wait for 100 ns;
    divide_i <= '0';
	wait for 10000 ns;
    divide_i <= '1';
	wait for 100 ns;
    divide_i <= '0';
	wait for 10000 ns;
    divide_i <= '1';
	wait for 100 ns;
    divide_i <= '0';
	wait for 10000 ns;
    divide_i <= '1';
	wait for 100 ns;
    divide_i <= '0';
	wait;
end process;


res_gen: process
begin
  rst_i <= '1';
  wait for 10 ns;
  rst_i <= '0';
  wait;
end process res_gen;

clk_gen: process
begin
	clk_i <= '0';
	wait for 50 ns;
	clk_i <= '1';
	wait for 50 ns;
end process;

end behavioral;
