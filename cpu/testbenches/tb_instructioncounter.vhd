------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_addressgroup
--
-- PURPOSE:     testbench of instruction counter entity
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_instructioncounter is
end tb_instructioncounter;

architecture testbench of tb_instructioncounter is 
    component instructioncounter
        port(   clk:        in std_logic;
                load:       in std_logic;
                inc:        in std_logic;
                reset:      in std_logic;
                data_in:    in std_logic_vector(31 downto 0);
                data_out:   out std_logic_vector(31 downto 0)
            );
    end component;
    
    for impl: instructioncounter use entity work.instructioncounter(rtl);
    
    signal clk:        std_logic;
    signal load:       std_logic;
    signal inc:        std_logic;
    signal reset:      std_logic := '0';
    signal data_in:    std_logic_vector(31 downto 0);
    signal data_out:   std_logic_vector(31 downto 0);
    
    constant period	: time := 2ns;
    
    begin
        impl: instructioncounter port map (clk => clk, load => load, inc => inc, reset => reset, 
                                           data_in => data_in, data_out => data_out); 
    process
    begin
            wait for 100ns;
            
            -- load 1
            data_in <= "11001100110011001100110011001100";
            load <= '1';
            inc <= '0';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = "11001100110011001100110011001100" 
                report "load 1 : data_out"
                severity Error;
                
            
            -- load = inc = 0
            data_in <= "01010101010101010101010101010101";
            load <= '0';
            inc <= '0';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = "11001100110011001100110011001100" 
                report "load=inc=0: data_out"
                severity Error;
                
                
            -- load 2
            data_in <= "10101010101010101010101010101010";
            load <= '1';
            inc <= '0';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = "10101010101010101010101010101010" 
                report "load 2 : data_out"
                severity Error;
                
                
            -- load = inc = 1
            data_in <= "01110001011100010111000101110001";
            load <= '1';
            inc <= '1';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = "10101010101010101010101010101010" 
                report "load=inc=1 : data_out"
                severity Error;
                
            
            -- load 3
            data_in <= "11111111111111111111111111111110";
            load <= '1';
            inc <= '0';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = "11111111111111111111111111111110" 
                report "load 3 : data_out"
                severity Error;
            
            -- inc
            data_in <= "10101010101010101010101010101010";
            load <= '0';
            inc <= '1';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = "11111111111111111111111111111111" 
                report "inc : data_out"
                severity Error;
                
                
            -- inc overflow
            data_in <= "10101010101010101010101010101010";
            load <= '0';
            inc <= '1';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = "00000000000000000000000000000000" 
                report "inc overflow: data_out"
                severity Error;
                
            
            -- reset
            data_in <= "10101010101010101010101010101010";
            load <= '1';
            inc <= '0';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            reset <= '1';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = "00000000000000000000000000000000" 
                report "reset: data_out"
                severity Error;
                
            wait;
				
    end process;
    
end;