------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      vector_alu_32
--
-- PURPOSE:     32 bit vector alu
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

use work.cfg.all;

entity vector_alu_32 is
    port(   
        -- clock
        clk:                in std_logic;
        
        -- data in
        v_in:               in std_logic_vector(31 downto 0);
        w_in:               in std_logic_vector(31 downto 0);
        carry_in:           in std_logic;
        rshift_in:          in std_logic;
        
        -- data out
        carry_out:          out std_logic;
        valu_out:           out std_logic_vector(31 downto 0);
        
        -- control signals
        valuop:             in std_logic_vector(3 downto 0);
        source_sel:         in std_logic_vector(1 downto 0);
        carry_sel:          in std_logic_vector(1 downto 0);
        mult_source_sel:    in std_logic_vector(1 downto 0); -- *
        mult_dest_sel:      in std_logic_vector(1 downto 0); -- *
        reg_input_sel:      in std_logic;                    -- *
        load_lsr:           in std_logic;
        load_other:         in std_logic
    );
end;


architecture rtl of vector_alu_32 is 

    signal carry, rshift: std_logic;
    
    signal left : unsigned(8 downto 0);         -- left operand
    signal right : unsigned(8 downto 0);        -- right operand
    signal valu_res: unsigned(8 downto 0);      -- result (mult_res8 or valu_res)
    
    signal mult_right: unsigned(15 downto 0);   -- right multiplication operand
    signal mult_left:  unsigned(15 downto 0);   -- left multiplication operand
    signal mult_res32: unsigned(31 downto 0);   -- multiplication result 
    signal mult_res8:  unsigned(7 downto 0);    -- shift value for result shift register (multiplication)
    
    signal output: unsigned(32 downto 0);       -- result shift register
    signal input : unsigned (8 downto 0);       -- shift value for result shift register (other operations)
    
    
begin
    carry <= carry_in when (carry_sel = "00") else
             output(32) when (carry_sel = "01") else
             '0';
             
    rshift <= rshift_in when (carry_sel = "00") else
             output(32) when (carry_sel = "01") else
             '0';
    
    left <= unsigned('0' & v_in(7 downto 0)) when (source_sel) = "00" else
            unsigned('0' & v_in(15 downto 8)) when (source_sel) = "01" else
            unsigned('0' & v_in(23 downto 16)) when (source_sel) = "10" else
            unsigned('0' & v_in(31 downto 24));
            
    right <= unsigned('0' & w_in(7 downto 0)) when (source_sel) = "00" else
             unsigned('0' & w_in(15 downto 8)) when (source_sel) = "01" else
             unsigned('0' & w_in(23 downto 16)) when (source_sel) = "10" else
             unsigned('0' & w_in(31 downto 24));
    
    -- execute all other operations       
    valu_res <= left + right + carry when (valuop = "0000") else
             left - right - carry when (valuop = "0010") else
             left(7 downto 0) & carry when (valuop = "1100") else
             left(0) & rshift & left(7 downto 1) when (valuop = "1110") else
             unsigned( std_logic_vector(left) and std_logic_vector(right)) when (valuop = "1000") else
             unsigned( std_logic_vector(left) or std_logic_vector(right)) when (valuop = "1001") else
             unsigned( std_logic_vector(left) xor std_logic_vector(right));
             
    mult_gen: if use_vector_mult generate
        -- operands for multiplication
        mult_left <=  unsigned("00000000" & v_in(7 downto 0)) when mult_source_sel = "00" else
                      unsigned("00000000" & v_in(23 downto 16)) when mult_source_sel = "01" else
                      unsigned(v_in(15 downto 0));
                      
        mult_right <= unsigned("00000000" & w_in(7 downto 0)) when mult_source_sel = "00" else
                      unsigned("00000000" & w_in(23 downto 16)) when mult_source_sel = "01" else
                      unsigned(w_in(15 downto 0));
        
        -- execute multiplication
        mult_res32 <= mult_left * mult_right;
        
        mult_res8 <= mult_res32(7 downto 0) when mult_dest_sel = "00" else
                     mult_res32(15 downto 8) when mult_dest_sel = "01" else
                     mult_res32(23 downto 16) when mult_dest_sel = "10" else
                     mult_res32(31 downto 24);
        
              
    end generate;
    
    not_mult_gen: if not use_vector_mult generate
        mult_res8 <= "00000000";
    end generate;
    
    -- use result from other operation or multiplication?
    input <= valu_res when reg_input_sel = '0' else "0" & mult_res8; 
             
    -- output register
    process
    begin
        wait until clk ='1' and clk'event;
        if load_other = '1' then
            -- shift from right to left
            output(32 downto 24) <= input(8 downto 0);
            output(23 downto 0) <= output(31 downto 8);
        else
            if load_lsr = '1' then
                -- shift from left to right
                output(7 downto 0) <= input(7 downto 0);
                output(32) <= input(8);
                output(31 downto 8) <= output(23 downto 0);
            else
                output <= output;
            end if;
        end if;
     end process;
 
    valu_out <= std_logic_vector(output(31 downto 0));
    carry_out <= output(32);
    
end rtl;



