------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_selectunit
--
-- PURPOSE:     testbench of selectunit entity
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.cfg.all;     -- testbench requires k > 7
use work.datatypes.all;

entity tb_selectunit is
end tb_selectunit;



architecture testbench of tb_selectunit is 
    component selectunit
        port (
            data_in :   in  vectordata_type;
            k_in:       in  std_logic_vector(31 downto 0);
            data_out:   out std_logic_vector(31 downto 0)
        );   
    end component;
    
    for impl: selectunit use entity work.selectunit(rtl);
         
    signal data_in:     vectordata_type;
    signal k_in:        std_logic_vector(31 downto 0) := (others => '0');
    signal data_out:    std_logic_vector(31 downto 0);
    
    constant period	: time := 2ns;
    
    begin
        impl: selectunit port map (data_in => data_in, k_in => k_in, data_out => data_out); 
    process
    begin
            wait for 100ns;
            
            assert k > 7
                report "testbench requires k > 7"
                    severity Error;
            
            data_in(0) <= "10101100110111001001111000101111";
            data_in(1) <= "01001011011011101010101101010100";
            data_in(2) <= "11101101110110101011011011101010";
            data_in(3) <= "11001100110011001100110011001101";
            data_in(4) <= "11001011001001100101110010011000";
            data_in(5) <= "10010010100100101001001010010010";
            data_in(6) <= "11111000000111111100000011111000";
            data_in(7) <= "10101010101010101010101010101010";
            
            -- k = 0
            k_in <= "00000000000000000000000000000000";
            
            wait for period;
           
            assert data_out = "10101100110111001001111000101111" 
                report "k=0 : data_out"
                severity Error;
                
           
            -- k = 1
            k_in <= "00000000000000000000000000000001";
            
            wait for period;
           
            assert data_out = "01001011011011101010101101010100" 
                report "k=1 : data_out"
                severity Error;
                
           
            -- k = 2
            k_in <= "00000000000000000000000000000010";
            
            wait for period;
           
            assert data_out = "11101101110110101011011011101010" 
                report "k=2 : data_out"
                severity Error;
                
            -- k = 3
            k_in <= "00000000000000000000000000000011";
            
            wait for period;
           
            assert data_out = "11001100110011001100110011001101" 
                report "k=3 : data_out"
                severity Error;
                
            
            -- k = 4
            k_in <= "00000000000000000000000000000100";
            
            wait for period;
           
            assert data_out = "11001011001001100101110010011000" 
                report "k=4 : data_out"
                severity Error;
                
            
            -- k = 5
            k_in <= "00000000000000000000000000000101";
            
            wait for period;
           
            assert data_out = "10010010100100101001001010010010" 
                report "k=5 : data_out"
                severity Error;
                
            
            -- k = 6
            k_in <= "00000000000000000000000000000110";
            
            wait for period;
           
            assert data_out = "11111000000111111100000011111000" 
                report "k=6 : data_out"
                severity Error;
                
        
            
            -- k = 7
            k_in <= "00000000000000000000000000000111";
            
            wait for period;
           
            assert data_out = "10101010101010101010101010101010" 
                report "k=100000 : data_out"
                severity Error;
                
           
            wait;
				
    end process;
    
end;