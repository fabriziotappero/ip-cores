------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_registergroup
--
-- PURPOSE:     testbench of registergroup entity
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_registergroup is
end tb_registergroup;

architecture testbench of tb_registergroup is 
    
    component registergroup
        port(   clk:            in std_logic;
                result_in:      in std_logic_vector(31 downto 0);
                vector_in:      in std_logic_vector(31 downto 0);
                ic_in:          in std_logic_vector(31 downto 0);
                enable_in:      in std_logic;
                x_out:          out std_logic_vector(31 downto 0); 
                y_out:          out std_logic_vector(31 downto 0);
                a_out:          out std_logic_vector(31 downto 0);
                sel_source:     in std_logic_vector(1 downto 0); 
                sel_dest:       in std_logic_vector(1 downto 0)
             );   
    end component;
    
    for impl: registergroup  use entity work.registergroup(rtl);
    
    signal clk:            std_logic;
    signal result_in:      std_logic_vector(31 downto 0);
    signal vector_in:      std_logic_vector(31 downto 0);
    signal ic_in:          std_logic_vector(31 downto 0);
    signal enable_in:      std_logic := '1';
    signal x_out:          std_logic_vector(31 downto 0); 
    signal y_out:          std_logic_vector(31 downto 0);
    signal a_out:          std_logic_vector(31 downto 0);
    signal sel_source:     std_logic_vector(1 downto 0); 
    signal sel_dest:       std_logic_vector(1 downto 0);
    
    constant period	: time := 2ns;
    
    begin
        impl: registergroup port map (clk => clk, result_in => result_in, vector_in => vector_in,
            ic_in => ic_in, enable_in => enable_in,  x_out => x_out, y_out => y_out, a_out => a_out,
            sel_source => sel_source, sel_dest => sel_dest); 
    process
    begin
            wait for 100ns;
            
            -- 1: load a from alu, store
            result_in <= "10110011101100111011001110110011";
            sel_source <= "00";
            sel_dest <= "01";
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
               
            assert a_out = "10110011101100111011001110110011"
                report "1 : a_out_out"
                severity Error;
                
            -- 2: load x from vector
            vector_in <= "11100010111000101110001011100010";
            sel_source <= "10";
            sel_dest <= "10";
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert a_out = "10110011101100111011001110110011"
                report "2 : a_out_out"
                severity Error;
                
            assert x_out = "11100010111000101110001011100010"
                report "2 : x_out"
                severity Error;
                
            -- 3: load nothing
            sel_source <= "00";
            sel_dest <= "00";
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
                
            assert a_out = "10110011101100111011001110110011"
                report "3 : a_out_out"
                severity Error;
                
            assert x_out = "11100010111000101110001011100010"
                report "3 : x_out"
                severity Error;
                
            
            -- 4: load y from ic, store ic            
            result_in <= "10110011101100111011001110110011";
            ic_in <= "10010010110110100111010101101101";
            
            sel_source <= "01";
            sel_dest <= "11";
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert a_out = "10110011101100111011001110110011"
                report "4 : a_out_out"
                severity Error;
                
            assert x_out = "11100010111000101110001011100010"
                report "4 : x_out"
                severity Error;
                
            assert y_out = "10010010110110100111010101101101"
                report "4 : y_out"
                severity Error;
                
            -- 5: dont load y from alu (enable clear)           
            result_in <= "11110000111100001111000011110000";
                      
            enable_in <= '0';
            sel_source <= "00";
            sel_dest <= "11";
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert a_out = "10110011101100111011001110110011"
                report "5 : a_out_out"
                severity Error;
                
            assert x_out = "11100010111000101110001011100010"
                report "5 : x_out"
                severity Error;
                
            assert y_out = "10010010110110100111010101101101"
                report "5 : y_out"
                severity Error;
                        
            wait;
    end process;
end;