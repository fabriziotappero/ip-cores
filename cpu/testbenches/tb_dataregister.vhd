------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_dataregister
--
-- PURPOSE:     testbench of dataregister entity
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_dataregister is
end tb_dataregister;

architecture testbench of tb_dataregister is 
    component dataregister
        port(   clk:        in std_logic;
                load:       in std_logic;
                data_in:    in std_logic_vector(31 downto 0);
                data_out:   out std_logic_vector(31 downto 0)
            );
    end component;
    
    for impl: dataregister use entity work.dataregister(rtl);
    
    signal clk:        std_logic;
    signal load:       std_logic;
    signal data_in:    std_logic_vector(31 downto 0);
    signal data_out:   std_logic_vector(31 downto 0);
    
    constant period	: time := 2ns;
    
    begin
        impl: dataregister port map (clk => clk, load => load, data_in => data_in,
                                     data_out => data_out); 
    process
    begin
            wait for 100ns;
            
             -- load 1
            data_in <= "11101110111011101110111011101110";
            load <= '1';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = "11101110111011101110111011101110" 
                report "load 1 : data_out"
                severity Error;
                
            
            -- load = 'Z'
            data_in <= "00000000000000000000000000000001";
            load <= 'Z';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = "11101110111011101110111011101110" 
                report "load=z : data_out"
                severity Error;
                
            
            -- not load
            data_in <= "11111111111111111111111111111111";
            load <= '0';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = "11101110111011101110111011101110" 
                report "not load: data_out"
                severity Error;
                
                
            -- load 2
            data_in <= "10101010101010101010101010101010";
            load <= '1';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = "10101010101010101010101010101010" 
                report "load 2 : data_out"
                severity Error;
            
            wait;
				
    end process;
    
end;