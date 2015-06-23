------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_demultiplexer
--
-- PURPOSE:     testbench of demultiplexer entity
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_demultiplexer1x4 is
end tb_demultiplexer1x4;

architecture testbench of tb_demultiplexer1x4 is 
    component demultiplexer1x4
        port(   selector:       in std_logic_vector(1 downto 0);
                data_in:        in std_logic;
                data_out_00:    out std_logic;
                data_out_01:    out std_logic;
                data_out_10:    out std_logic;
                data_out_11:    out std_logic
            );
    end component;
    
    for impl: demultiplexer1x4 use entity work.demultiplexer1x4(rtl);
    
    signal selector:       std_logic_vector(1 downto 0) := "00";
    signal data_in:        std_logic := '1';
    signal data_out_00:    std_logic;
    signal data_out_01:    std_logic;
    signal data_out_10:    std_logic;
    signal data_out_11:    std_logic;
    
    constant period	: time := 2ns;
    
    begin
        impl: demultiplexer1x4 port map (selector => selector, data_in => data_in, data_out_00 => data_out_00,
              data_out_01 => data_out_01, data_out_10 => data_out_10, data_out_11 => data_out_11); 
    process
    begin
            wait for 100ns;
            
            -- selector = 00
            selector <= "00";
            
            wait for period;
           
            assert data_out_00 = '1' 
                report "selector=00 : data_out_00"
                severity Error;
                
            assert data_out_01 = '0' 
                report "selector=00 : data_out_01"
                severity Error;
                
            assert data_out_10 = '0' 
                report "selector=00 : data_out_10"
                severity Error;
                
            assert data_out_11 = '0' 
                report "selector=00 : data_out_11"
                severity Error;
                
            
            -- selector = 01
            selector <= "01";
            
            wait for period;
           
            assert data_out_00 = '0' 
                report "selector=01 : data_out_00"
                severity Error;
                
            assert data_out_01 = '1' 
                report "selector=01 : data_out_01"
                severity Error;
                
            assert data_out_10 = '0' 
                report "selector=01 : data_out_10"
                severity Error;
                
            assert data_out_11 = '0' 
                report "selector=01 : data_out_11"
                severity Error;
            
        -- selector = 10
            selector <= "10";
            
            wait for period;
           
            assert data_out_00 = '0' 
                report "selector=10 : data_out_00"
                severity Error;
                
            assert data_out_01 = '0' 
                report "selector=10 : data_out_01"
                severity Error;
                
            assert data_out_10 = '1' 
                report "selector=10 : data_out_10"
                severity Error;
                
            assert data_out_11 = '0' 
                report "selector=10 : data_out_11"
                severity Error;

           
           -- selector = 11
            selector <= "11";
            
            wait for period;
           
            assert data_out_00 = '0' 
                report "selector=11 : data_out_00"
                severity Error;
                
            assert data_out_01 = '0' 
                report "selector=11 : data_out_01"
                severity Error;
                
            assert data_out_10 = '0' 
                report "selector=11 : data_out_10"
                severity Error;
                
            assert data_out_11 = '1' 
                report "selector=11 : data_out_11"
                severity Error;
            

            wait;
				
    end process;
    
end;