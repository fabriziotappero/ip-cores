------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_aluinputgrp
--
-- PURPOSE:     testbench of aluinputgroup entity
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_aluinputgroup is
end tb_aluinputgroup;

architecture testbench of tb_aluinputgroup is 
    component aluinputgroup
        port(   
                clk:            in std_logic;
                memory_in:      in std_logic_vector(31 downto 0);   
                x_in:           in std_logic_vector(31 downto 0);
                y_in:           in std_logic_vector(31 downto 0);
                a_in:           in std_logic_vector(31 downto 0);
                ir_out:         out std_logic_vector(31 downto 0);
                k_out:          out std_logic_vector(31 downto 0);  
                vector_out:     out std_logic_vector(31 downto 0); 
                a_out:          out std_logic_vector(31 downto 0);
                b_out:          out std_logic_vector(31 downto 0);
                sel_a:          in std_logic_vector(1 downto 0);
                sel_b:          in std_logic_vector(1 downto 0);
                sel_source_a:   in std_logic; 
                sel_source_b:   in std_logic; 
                load_ir:        in std_logic
         );   
    end component;
    
    for impl: aluinputgroup  use entity work.aluinputgroup(rtl);
    
    signal clk:            std_logic;
    signal memory_in:      std_logic_vector(31 downto 0);   -- data from ram
    signal x_in:           std_logic_vector(31 downto 0);
    signal y_in:           std_logic_vector(31 downto 0);
    signal a_in:           std_logic_vector(31 downto 0);
    signal ir_out:         std_logic_vector(31 downto 0);
    signal k_out:          std_logic_vector(31 downto 0);  -- k for vector unit
    signal vector_out:     std_logic_vector(31 downto 0);  -- data for vector unit
    signal a_out:          std_logic_vector(31 downto 0);
    signal b_out:          std_logic_vector(31 downto 0);
    signal sel_a:          std_logic_vector(1 downto 0);
    signal sel_b:          std_logic_vector(1 downto 0);
    signal sel_source_a:   std_logic;                       -- c8
    signal sel_source_b:   std_logic;                       -- c0
    signal load_ir:        std_logic;

    constant period	: time := 2ns;
    
    begin
        impl: aluinputgroup port map (clk => clk, memory_in => memory_in, x_in => x_in, y_in => y_in,
            a_in => a_in, ir_out => ir_out, k_out => k_out,  vector_out => vector_out, a_out => a_out,
            b_out => b_out, sel_a => sel_a, sel_b => sel_b, sel_source_a => sel_source_a, sel_source_b
            => sel_source_b, load_ir => load_ir); 
    process
    begin
            wait for 100ns;
            
            -- 1: load ir, a_out register a, b_out memory, vector_out register a, k_out register x
            memory_in <= "11010011110100111101001111010011";
            a_in <= "01001100010011000100110001001100";
            x_in <= "11001010110010101100101011001010";
            
            load_ir <= '1';
            sel_source_a <= '0';
            sel_source_b <= '1';
            sel_a <= "01";
            sel_b <= "10";
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert ir_out = "11010011110100111101001111010011"
                report "1 : ir_out"
                severity Error;
            
            assert a_out = "01001100010011000100110001001100"
                report "1 : a_out"
                severity Error;
            
            assert b_out = "11010011110100111101001111010011"
                report "1 : b_out"
                severity Error;
                
            assert k_out = "11001010110010101100101011001010"
                report "1 : k_out"
                severity Error;
                
            assert vector_out = "01001100010011000100110001001100"
                report "1 : vector_out"
                severity Error;
                
                
            -- 2: not load ir, a_out register y, b_out n, vector_out y, k_out n
            y_in <= "10011001100110011001100110011001";
            
            load_ir <= '0';
            sel_source_a <= '0';
            sel_source_b <= '0';
            sel_a <= "11";
            sel_b <= "00";
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert ir_out = "11010011110100111101001111010011"
                report "2 : ir_out"
                severity Error;
            
            assert a_out = "10011001100110011001100110011001"
                report "2 : a_out"
                severity Error;
            
            assert b_out = "00000000000000001101001111010011"
                report "2 : b_out"
                severity Error;
            
            assert k_out = "00000000000000001101001111010011"
                report "2 : k_out"
                severity Error;            
            
            assert vector_out = "10011001100110011001100110011001"
                report "2 : vector_out"
                severity Error;
                
                
            -- 3: not load ir, a_out  0, b_out a, vector_out 0, k_out register a
            load_ir <= '0';
            sel_source_a <= '0';
            sel_source_b <= '0';
            sel_a <= "00";
            sel_b <= "01";
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert ir_out = "11010011110100111101001111010011"
                report "3 : ir_out"
                severity Error;
            
            assert a_out = "00000000000000000000000000000000"
                report "3 : a_out"
                severity Error;
            
            assert b_out = "01001100010011000100110001001100"
                report "3 : b_out"
                severity Error;
            
            assert k_out = "01001100010011000100110001001100"
                report "3 : k_out"
                severity Error;   
            
            assert vector_out = "00000000000000000000000000000000"
                report "3 : vector_out"
                severity Error;
                
            -- 4: load ir, a_out register x, b_out select y, vector_out register x, k_out register y
            memory_in <= "01101101011011010110110101101101";
            
            load_ir <= '1';
            sel_source_a <= '0';
            sel_source_b <= '0';
            sel_a <= "10";
            sel_b <= "11";
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert ir_out = "01101101011011010110110101101101"
                report "4 : ir_out"
                severity Error;
            
            assert a_out = "11001010110010101100101011001010"
                report "4 : a_out"
                severity Error;
            
            assert b_out = "10011001100110011001100110011001"
                report "4 : b_out"
                severity Error;
                
             assert k_out = "10011001100110011001100110011001"
                report "4 : k_out"
                severity Error; 
                
            assert vector_out = "11001010110010101100101011001010"
                report "4 : vector_out"
                severity Error;
                
            -- 5: load ir, a_out select 0, b_out register y, vector_out register x, k_out y
            memory_in <= "01101101011011010110110101101101";
            
            load_ir <= '1';
            sel_source_a <= '1';
            sel_source_b <= '0';
            sel_a <= "10";
            sel_b <= "11";
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert ir_out = "01101101011011010110110101101101"
                report "5 : ir_out"
                severity Error;
            
            assert a_out = "00000000000000000000000000000000"
                report "5 : a_out"
                severity Error;
            
            assert b_out = "10011001100110011001100110011001"
                report "5 : b_out"
                severity Error;
               
            assert k_out = "10011001100110011001100110011001"
                report "5 : k_out"
                severity Error;
            
            assert vector_out = "11001010110010101100101011001010"
                report "5 : vector_out"
                severity Error;
            
            wait;
    end process;
end;