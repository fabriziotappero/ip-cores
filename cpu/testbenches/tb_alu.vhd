------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_alu
--
-- PURPOSE:     testbench of scalar alu entity
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_alu is
end tb_alu;

architecture testbench of tb_alu is 
    component alu
        port(   
            a_in:       in std_logic_vector(31 downto 0);
            b_in:       in std_logic_vector(31 downto 0);
            carry_in:   in std_logic;
            aluop:      in std_logic_vector(3 downto 0);
            op_select:  in std_logic;
            zero_out:   out std_logic;
            carry_out:  out std_logic;
            alu_out:    out std_logic_vector(31 downto 0)
        );
    end component;
    
    for impl: alu use entity work.alu(rtl);
    
    signal a_in:       std_logic_vector(31 downto 0);
    signal b_in:       std_logic_vector(31 downto 0);
    signal carry_in:   std_logic;
    signal aluop:     std_logic_vector(3 downto 0);
    signal op_select:  std_logic := '0';
    signal carry_out:  std_logic;
    signal zero_out:   std_logic;
    signal alu_out:    std_logic_vector(31 downto 0);
    
    constant period	: time := 2ns;
    
    begin
        impl: alu 
            port map (
                a_in => a_in, b_in => b_in, carry_in => carry_in, aluop =>
                aluop, op_select => op_select, carry_out => carry_out,
                zero_out => zero_out, alu_out => alu_out);
    
    process
    begin
            
            wait for 100ns;
            
            -- ###############################################################
            
            -- add 1: zero_out clear, carry_out_clear
            a_in <= "10010000001000010000000001010101";
            b_in <= "01000010000000000001000100000010";
            carry_in <= '0';
            aluop <= "0000";
            
            wait for period;
            
            assert alu_out = "11010010001000010001000101010111" 
                report "add 1 : alu_out"
                severity Error;
            
            assert carry_out = '0'
                report "add 1 : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "add 1 : zero_out"
                severity Error;
					 
			-- add 2: zero_out set, carry_out clear
            a_in <= "00000000000000000000000000000000";
            b_in <= "00000000000000000000000000000000";
            carry_in <= '0';
            aluop <= "0000";
            
            wait for period;
            
            assert alu_out = "00000000000000000000000000000000" 
                report "add 2 : alu_out"
                severity Error;
            
            assert carry_out = '0'
                report "add 2 : carry_out"
                severity Error;
                
            assert zero_out = '1'
                report "add 2 : zero_out"
                severity Error;
					 
				
			-- add 3: zero_out clear, carry_out set
            a_in <= "11111111111111111111111111111111";
            b_in <= "11111111111111111111111111111111";
            carry_in <= '0';
            aluop <= "0000";
            
            wait for period;
            
            assert alu_out = "11111111111111111111111111111110" 
                report "add 3 : alu_out"
                severity Error;
            
            assert carry_out = '1'
                report "add 3 : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "add 3 : zero_out"
                severity Error;
            
            -- ###############################################################
            
            -- adc 1: carry_in set, zero_out clear, carry_out_clear
            a_in <= "00000000000000000000000000000100";
            b_in <= "00000000000000000000000000000010";
            carry_in <= '1';
            aluop <= "0001";
            
            wait for period;
            
            assert alu_out = "00000000000000000000000000000111" 
                report "adc 1 : alu_out"
                severity Error;
            
            assert carry_out = '0'
                report "adc 1 : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "adc 1 : zero_out"
                severity Error;
                
            -- adc 2: carry_in clear, zero_out clear, carry_out_clear
            a_in <= "00000000000000000000000000000100";
            b_in <= "00000000000000000000000000000010";
            carry_in <= '0';
            aluop <= "0001";
            
            wait for period;
            
            assert alu_out = "00000000000000000000000000000110" 
                report "adc 2 : alu_out"
                severity Error;
            
            assert carry_out = '0'
                report "adc 2 : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "adc 2 : zero_out"
                severity Error;
                
            -- ###############################################################    
                
            -- sub 1: result positive, zero_out clear, carry_out clear
            a_in <= "00000000000000000000000010101011";
            b_in <= "00000000000000000000000010100010";
            carry_in <= '0';
            aluop <= "0010";
            
            wait for period;
            
            assert alu_out = "00000000000000000000000000001001" 
                report "sub 1 : alu_out"
                severity Error;
            
            assert carry_out = '0'
                report "sub 1 : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "sub 1 : zero_out"
                severity Error; 

            
            -- sub 2: result negative, zero_out clear, carry_out set
            a_in <= "00000000000000000000000000000000";
            b_in <= "00000000000000000000000000000001";
            carry_in <= '0';
            aluop <= "0010";
            
            wait for period;
            
            assert alu_out = "11111111111111111111111111111111" 
                report "sub 2 : alu_out"
                severity Error;
            
            assert carry_out = '1'
                report "sub 2 : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "sub 2 : zero_out"
                severity Error;    
            
            -- ###############################################################    
                
            -- sbc 1: carry_in set, result positive, zero_out clear, carry_out clear
            a_in <= "00000000000000000000000010101011";
            b_in <= "00000000000000000000000010100010";
            carry_in <= '1';
            aluop <= "0011";
            
            wait for period;
            
            assert alu_out = "00000000000000000000000000001000" 
                report "sub 1 : alu_out"
                severity Error;
            
            assert carry_out = '0'
                report "sub 1 : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "sub 1 : zero_out"
                severity Error;

            -- sbc 2: carry_in clear, result positive, zero_out clear, carry_out clear
            a_in <= "00000000000000000000000010101011";
            b_in <= "00000000000000000000000010100010";
            carry_in <= '0';
            aluop <= "0011";
            
            wait for period;
            
            assert alu_out = "00000000000000000000000000001001" 
                report "sub 2 : alu_out"
                severity Error;
            
            assert carry_out = '0'
                report "sub 2 : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "sub2 : zero_out"
                severity Error;      

            -- ###############################################################    
                
            -- inc: 
            a_in <= "00000000000000000000000000000011";
            b_in <= "00000000000000000000000000000000";
            carry_in <= '0';
            aluop <= "0100";
            
            wait for period;
            
            assert alu_out = "00000000000000000000000000000100" 
                report "inc : alu_out"
                severity Error;
            
            assert carry_out = '0'
                report "inc : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "inc : zero_out"
                severity Error;
                
            -- ###############################################################    
                
            -- dec: 
            a_in <= "00000000000000000000000000000011";
            b_in <= "00000000000000000000000000000000";
            carry_in <= '0';
            aluop <= "0110";
            
            wait for period;
            
            assert alu_out = "00000000000000000000000000000010" 
                report "dec : alu_out"
                severity Error;
            
            assert carry_out = '0'
                report "dec : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "dec : zero_out"
                severity Error;

                
            -- ############################################################### 
            
            -- and: 
            a_in <= "11010000000000000000000000001011";
            b_in <= "10110000000000000000000000001101";
            carry_in <= '0';
            aluop <= "1000";
            
            wait for period;
            
            assert alu_out = "10010000000000000000000000001001" 
                report "and : alu_out"
                severity Error;
            
            assert carry_out = '0'
                report "and : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "and : zero_out"
                severity Error; 
            
            -- ############################################################### 
            
            -- or: 
            a_in <= "11010000000000000000000000001011";
            b_in <= "10110000000000000000000000001101";
            carry_in <= '0';
            aluop <= "1001";
            
            wait for period;
            
            assert alu_out = "11110000000000000000000000001111" 
                report "or : alu_out"
                severity Error;
            
            assert carry_out = '0'
                report "or : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "or : zero_out"
                severity Error; 
                
            -- ############################################################### 
            
            -- xor: 
            a_in <= "11010000000000000000000000001011";
            b_in <= "10110000000000000000000000001101";
            carry_in <= '0';
            aluop <= "1010";
            
            wait for period;
            
            assert alu_out = "01100000000000000000000000000110" 
                report "xor : alu_out"
                severity Error;
            
            assert carry_out = '0'
                report "xor : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "xor : zero_out"
                severity Error;
                
            -- ############################################################### 
            
            -- lsl: 
            a_in <= "11000000000000000000000000000011";
            b_in <= "00000000000000000000000000000000";
            carry_in <= '0';
            aluop <= "1100";
            
            wait for period;
            
            assert alu_out = "10000000000000000000000000000110" 
                report "lsl : alu_out"
                severity Error;
            
            assert carry_out = '1'
                report "lsl : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "lsl : zero_out"
                severity Error;
                
            -- ############################################################### 
                        
            -- lsr: 
            a_in <= "11000000000000000000000000000011";
            b_in <= "00000000000000000000000000000000";
            carry_in <= '0';
            aluop <= "1110";
            
            wait for period;
            
            assert alu_out = "01100000000000000000000000000001" 
                report "lsr : alu_out"
                severity Error;
            
            assert carry_out = '1'
                report "lsr : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "lsr : zero_out"
                severity Error;
                
                
            -- ############################################################### 
            
            -- rol: carry_in set
            a_in <= "11000000000000000000000000000011";
            b_in <= "00000000000000000000000000000000";
            carry_in <= '1';
            aluop <= "1101";
            
            wait for period;
            
            assert alu_out = "10000000000000000000000000000111" 
                report "rol : alu_out"
                severity Error;
            
            assert carry_out = '1'
                report "rol : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "rol : zero_out"
                severity Error;
                
            -- ############################################################### 
                        
            -- ror: carry_in set
            a_in <= "11000000000000000000000000000011";
            b_in <= "00000000000000000000000000000000";
            carry_in <= '1';
            aluop <= "1111";
            
            wait for period;
            
            assert alu_out = "11100000000000000000000000000001" 
                report "ror : alu_out"
                severity Error;
            
            assert carry_out = '1'
                report "ror : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "ror : zero_out"
                severity Error;
                
                
            -- ############################################################### 
           
            op_select <= '1';
                
            -- add:
            a_in <= "11000000000000000000000000000011";
            b_in <= "00000000000000000000000000000000";
            carry_in <= '0';
            aluop <= "1111";
            
            wait for period;
            
            assert alu_out = "11000000000000000000000000000011" 
                report "ror : alu_out"
                severity Error;
            
            assert carry_out = '0'
                report "ror : carry_out"
                severity Error;
                
            assert zero_out = '0'
                report "ror : zero_out"
                severity Error;
					 
			wait;
				
    end process;
    
end;