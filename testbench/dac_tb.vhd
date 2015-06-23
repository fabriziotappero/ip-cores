-----------------------------------------------------------------------------------------
-- Engineer: Armandas Jarušauskas (jarusauskas@gmail.com www.armandas.lt)
-- 
-- Create date: 2010-08-03
-- Design name: Testbench for LTC2624 Quad 12 Bit DAC Controller 
-----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity dac_tb is
end dac_tb;

architecture behaviour of dac_tb is
    constant T: time := 20 ns;
    signal clk, reset: std_logic;

    signal mosi, sck, cs, ready: std_logic;
    signal data, old_data: std_logic_vector(31 downto 0);
begin

    -- clock generator
    process
    begin
        clk <= '1';
        wait for T / 2;
        clk <= '0';
        wait for T / 2;
    end process;

    -- initial reset
    reset <= '1', '0' after T / 2;

    testbench:
    process
        variable value: std_logic_vector(11 downto 0);
        variable addr: std_logic_vector(3 downto 0);
        variable command: std_logic_vector(3 downto 0);
    begin
        value := "010000000000";
        addr := "0010";
        command := "0011";
        
        data <= "00000000" & command & addr & value & "0000";
        old_data <= "00000000" & command & addr & value & "0000";


        -- testing bit order in the 32-bit word
        for i in 31 downto 0 loop
            wait until rising_edge(sck);

            assert mosi = data(i)
                report "Bit mismatch! (Order)"
                severity error;
        end loop;

        -- testing data latching
        for i in 31 downto 0 loop
            wait until rising_edge(sck);

            if i = 24 then
                data <= "10010101110101101010101110100110"; --(others => '1');
            end if;

            assert mosi = old_data(i)
                report "Bit mismatch! (Latching)"
                severity error;
        end loop;

        -- what's happening after that?
        for i in 63 downto 0 loop
            wait until rising_edge(sck);
        end loop;

        -- end of simulation
        assert false
            report "Simulation completed."
            severity failure;
    end process;

    uut: entity work.dac_control
    port map(
        clk => clk,
        rst => reset,
        dac_mosi => mosi,
        dac_sck => sck,
        dac_cs => cs,
        rdy => ready,
        dac_data => data
    );

end behaviour;
