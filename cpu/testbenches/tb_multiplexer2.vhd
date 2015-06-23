------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_multiplexer2
--
-- PURPOSE:     testbench of multiplexer2 entity
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_multiplexer2 is
end tb_multiplexer2;

architecture testbench of tb_multiplexer2 is 
    component multiplexer2
        generic (
            w : positive
        );
        port(
            selector:   in std_logic;
            data_in_0:  in std_logic_vector(w-1 downto 0);
            data_in_1:  in std_logic_vector(w-1 downto 0);
            data_out:   out std_logic_vector(w-1 downto 0)
        );
    end component;
    
    for impl: multiplexer2 use entity work.multiplexer2(rtl);
    
    signal selector:   std_logic := '0';
    signal data_in_0:  std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal data_in_1:  std_logic_vector(31 downto 0) := "00000000000000000000000000000001";

    signal data_out:    std_logic_vector(31 downto 0);
    
    constant period	: time := 2ns;
    
    begin
        impl: multiplexer2 
            generic map (w => 32) 
            port map (selector => selector, data_in_0 => data_in_0, data_in_1 => data_in_1,
              data_out => data_out); 
    process
    begin
            wait for 100ns;
            
            -- selector = 0
            selector <= '0';
            
            wait for period;
           
            assert data_out = "00000000000000000000000000000000" 
                report "selector=0 : data_out"
                severity Error;
                
            -- selector = 1
            selector <= '1';
            
            wait for period;
            
            assert data_out = "00000000000000000000000000000001" 
                report "selector=1 : data_out"
                severity Error;

            wait;
				
    end process;
    
end;