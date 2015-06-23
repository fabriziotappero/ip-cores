------------------------------------------------------------------
-- PROJECT:     HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_flag
--
-- PURPOSE:     testbench of flag entity
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_flag is
end tb_flag;

architecture testbench of tb_flag is 
    component flag
        port(   clk:        in std_logic;
                load:       in std_logic;
                data_in:    in std_logic;
                data_out:   out std_logic
         );
    end component;
    
    for impl: flag use entity work.flag(rtl);
    
    signal clk:        std_logic;
    signal load:       std_logic;
    signal data_in:    std_logic;
    signal data_out:   std_logic;
    
    constant period	: time := 2ns;
    
    begin
        impl: flag port map (clk => clk, load => load, data_in => data_in, data_out => data_out); 
    process
    begin
            wait for 100ns;
            
          
            -- load 1
            data_in <= '1';
            load <= '1';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = '1'
                report "load 1 : data_out"
                severity Error;
                
                
            -- not load
            data_in <= '0';
            load <= '0';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = '1'
                report "not load : data_out"
                severity Error;
                
            
            -- load 2
            data_in <= '0';
            load <= '1';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert data_out = '0'
                report "load 2 : data_out"
                severity Error;
            
            
            wait;
				
    end process;
    
end;