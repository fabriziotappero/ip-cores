------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_addressgroup
--
-- PURPOSE:     testbench of addressgroup entity
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_addressgroup is
end tb_addressgroup;

architecture testbench of tb_addressgroup is 
    component addressgroup 
        port(   clk:            in std_logic;  
                address_in:     in std_logic_vector(31 downto 0);
                address_out:    out std_logic_vector(31 downto 0);
                ic_out:         out std_logic_vector(31 downto 0);
                sel_source:     in std_logic; 
                inc:            in std_logic;
                load_ic:        in std_logic;
                reset_ic:       in std_logic
         );
    end component;
    
    for impl: addressgroup use entity work.addressgroup(rtl);
    
    signal clk:            std_logic;
    signal address_in:     std_logic_vector(31 downto 0);
    signal address_out:    std_logic_vector(31 downto 0);
    signal ic_out:         std_logic_vector(31 downto 0);
    signal sel_source:     std_logic; 
    signal inc:            std_logic;
    signal load_ic:        std_logic;
    signal reset_ic:       std_logic := '0';
        
    constant period	: time := 2ns;
    
    begin
        impl: addressgroup port map (clk => clk, address_in => address_in, address_out => address_out,
            ic_out => ic_out, sel_source => sel_source, inc => inc, load_ic => load_ic, reset_ic => reset_ic); 
    process
    begin
            wait for 100ns;
            
            -- 1: load ic, use ic
            address_in <= "11010011110100111101001111010011";
            load_ic <= '1';
            inc <= '0';
            sel_source <= '0';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert ic_out = "11010011110100111101001111010011"
                report "1 : ic_out"
                severity Error;
                
            assert address_out = "11010011110100111101001111010011"
                report "1 : address_out"
                severity Error;
                
            -- 2: dont load ic, use address
            address_in <= "00011110000111100001111000011110";
            load_ic <= '0';
            inc <= '0';
            sel_source <= '1';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert ic_out = "11010011110100111101001111010011"
                report "2 : ic_out"
                severity Error;
                
            assert address_out = "00011110000111100001111000011110"
                report "2 : address_out"
                severity Error;
                
            -- 3: inc ic, use ic
            address_in <= "00011110000111100001111000011110";
            load_ic <= '0';
            inc <= '1';
            sel_source <= '0';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert ic_out = "11010011110100111101001111010100"
                report "3 : ic_out"
                severity Error;
                
            assert address_out = "11010011110100111101001111010100"
                report "3 : address_out"
                severity Error;
                
            -- 4: reset
            address_in <= "00011110000111100001111000011110";
            load_ic <= '0';
            inc <= '0';
            sel_source <= '1';
            reset_ic <= '1';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert ic_out = "00000000000000000000000000000000"
                report "4 : ic_out"
                severity Error;
                
            assert address_out = "00011110000111100001111000011110"
                report "4 : address_out"
                severity Error;
            
            
            wait;
    end process;
end;