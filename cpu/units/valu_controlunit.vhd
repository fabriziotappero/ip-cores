------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      valu_controlunit
--
-- PURPOSE:     common controlunit of the
--              vector alus
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;


entity valu_controlunit is
    port(   
        clk:                in std_logic;
        valu_go:            in std_logic;
        valuop:             in std_logic_vector(3 downto 0);
        vwidth:             in std_logic_vector(1 downto 0);
        source_sel:         out std_logic_vector(1 downto 0);
        carry_sel:          out std_logic_vector(1 downto 0);
        mult_source_sel:    out std_logic_vector(1 downto 0); 
        mult_dest_sel:      out std_logic_vector(1 downto 0); 
        reg_input_sel:      out std_logic;                 
        load_lsr:           out std_logic;
        load_other:         out std_logic;
        out_valid:          out std_logic
    );
end;

architecture rtl of valu_controlunit is 
    type statetype is (waiting, vlsr, vlsr64, vother, vother64, vmult8, vmult16);
    signal state : statetype := waiting;
    signal nextstate : statetype := waiting;
    
    signal counter: unsigned(1 downto 0) := "00";
    signal inc, reset: std_logic;
begin
    
    -- counter
    process
        variable x : unsigned(1 downto 0);
    begin
        wait until clk ='1' and clk'event;
        if reset = '1' then
            counter <= (others => '0');
        else
            if inc = '1' then
                x := unsigned(counter);
                counter <= counter + 1;
            end if;
        end if;
     end process;
     
    
    -- state register
    process
    begin
        wait until clk ='1' and clk'event;
        state <= nextstate;
     end process;
    
    -- state transitions
    process (state, valu_go, valuop, vwidth, counter)
        variable lsr_result: unsigned(8 downto 0);
    begin
        -- avoid latches
        out_valid <= '0';
         
        reset <= '0';
        inc <= '0';
        
        load_lsr <= '0';
        load_other <= '0';
        
        mult_source_sel <= "00";
        mult_dest_sel <= "00";
        reg_input_sel <= '0';
        
        case state is 
            -- waiting for go command from vector controlunit
            when waiting =>
                out_valid <= '1';
                reset <= '1';
                nextstate <= waiting;
                
                if valu_go = '1' then
                    case valuop is
                        when "1110" =>
                            nextstate <= vlsr;
                        
                        when "1011" =>
                            if vwidth(0) = '0' then
                                nextstate <= vmult8;
                            else
                                nextstate <= vmult16;
                            end if;
                        
                        when others =>
                            nextstate <= vother;
                    end case;
                else
                    nextstate <= waiting;
                end if;
            
            -- normal alu commands
            when vother =>
                inc <= '1';
                load_other <= '1';
                
                if counter = 3 then
                    if vwidth = "11" then
                        nextstate <= vother64;
                    else
                        nextstate <= waiting;
                    end if;
                else
                    nextstate <= vother;
                end if;
            
            -- normal alu commands 64 bit
            when vother64 =>
                inc <= '1';
                load_other <= '1';
                
                if counter = 3 then
                    nextstate <= waiting;
                else
                    nextstate <= vother64;
                end if;
            
            -- vector shift right command
            when vlsr =>
                inc <= '1';
                load_lsr <= '1';
                
                if counter = 3 then
                    if vwidth = "11" then
                        nextstate <= vlsr64;
                    else
                        nextstate <= waiting;
                    end if;
                else
                    nextstate <= vlsr;
                end if;
            
            -- vector shift right command 64 bit
            when vlsr64 =>
                inc <= '1';
                load_lsr <= '1';
                
                if counter = 3 then
                    nextstate <= waiting;
                else
                    nextstate <= vlsr64;
                end if;
            
            -- multiplication with 8 bit
            when vmult8 =>
                inc <= '1';
                load_other <= '1';
                
                reg_input_sel <= '1';
                
                case counter is
                    when "00" =>
                        mult_source_sel <= "00";
                        mult_dest_sel <= "00";
                        nextstate <= vmult8;
                    when "01" =>
                        mult_source_sel <= "00";
                        mult_dest_sel <= "01";
                        nextstate <= vmult8;
                    when "10" =>
                        mult_source_sel <= "01";
                        mult_dest_sel <= "00";
                        nextstate <= vmult8;
                    when "11" =>
                        mult_source_sel <= "01";
                        mult_dest_sel <= "01";
                        nextstate <= waiting;
                    when others =>
                        nextstate <= waiting;
                end case;

            -- multiplication with 16 bit
            when vmult16 =>
                inc <= '1';
                load_other <= '1';
                
                mult_source_sel <= "10";
                mult_dest_sel <= std_logic_vector(counter);
                reg_input_sel <= '1';
                
                if counter = 3 then
                    nextstate <= waiting;
                else
                    nextstate <= vmult16;
                end if;   
        end case;
    end process;
    
    source_sel <= "00" when ( (counter = 0 and valuop /= "1110") or (counter = 3 and valuop = "1110") ) else
                  "01" when ( (counter = 1 and valuop /= "1110") or (counter = 2 and valuop = "1110") ) else
                  "10" when ( (counter = 2 and valuop /= "1110") or (counter = 1 and valuop = "1110") ) else
                  "11";

    
    carry_sel <= "00"  when (vwidth = "11" and counter = 0) else                    -- 64 bit
                 "01"  when (vwidth(1) = '1' and counter /= 0) else                 -- 32 and 64 bit
                 "01"  when (vwidth = "01" and (counter = 1 or counter = 3)) else   -- 16 bit
                 "10";                                                              -- 8 bit

   
end rtl;
