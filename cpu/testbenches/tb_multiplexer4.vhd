------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_multiplexer4
--
-- PURPOSE:     testbench of multiplexer4 entity
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_multiplexer4 is
end tb_multiplexer4;

architecture testbench of tb_multiplexer4 is 
    component multiplexer4
        generic (
            w : positive
        );
        port (
            selector:    in std_logic_vector(1 downto 0);
            data_in_00:  in std_logic_vector(w-1 downto 0);
            data_in_01:  in std_logic_vector(w-1 downto 0);
            data_in_10:  in std_logic_vector(w-1 downto 0);
            data_in_11:  in std_logic_vector(w-1 downto 0);
            data_out:    out std_logic_vector(w-1 downto 0)
        );
    end component;
    
    for impl: multiplexer4 use entity work.multiplexer4(rtl);
    
    signal selector:    std_logic_vector(1 downto 0) := "00";
    signal data_in_00:  std_logic_vector(31 downto 0) := "10101100101011001010110010101100";
    signal data_in_01:  std_logic_vector(31 downto 0) := "11001001110010011100100111001001";
    signal data_in_10:  std_logic_vector(31 downto 0) := "01100110011001100110011001100110";
    signal data_in_11:  std_logic_vector(31 downto 0) := "11001111110011111100111111001111";
    signal data_out:    std_logic_vector(31 downto 0);
    
    constant period	: time := 2ns;
    
    begin
        impl: multiplexer4 
            generic map (w => 32)
            port map (selector => selector, data_in_00 => data_in_00, data_in_01 => data_in_01,
              data_in_10 => data_in_10, data_in_11 => data_in_11, data_out => data_out); 
    process
    begin
            wait for 100ns;
            
            -- selector = 00
            selector <= "00";
            
            wait for period;
           
            assert data_out = "10101100101011001010110010101100" 
                report "selector=00 : data_out"
                severity Error;
                
            -- selector = 01
            selector <= "01";
            
            wait for period;
            
            assert data_out = "11001001110010011100100111001001" 
                report "selector=01 : data_out"
                severity Error;
                
            -- selector = 10
            selector <= "10";
            
            wait for period;
           
            assert data_out = "01100110011001100110011001100110" 
                report "selector=10 : data_out"
                severity Error;
                
            -- selector = 11
            selector <= "11";
            
            wait for period;
           
            assert data_out = "11001111110011111100111111001111" 
                report "selector=11 : data_out"
                severity Error;
             
            wait;
				
    end process;
    
end;