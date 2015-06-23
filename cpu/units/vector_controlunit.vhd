------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      vector_controlunit
--
-- PURPOSE:     controlunit for vector unit
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

entity vector_controlunit is
    port(   
        -- clock
        clk:            in std_logic;                       -- clock signal
        
        -- instruction in
        ir:             in std_logic_vector(31 downto 0);   -- instruction
        
        -- control signals out
        load_r:         out std_logic;
        cc9:            out std_logic_vector(1 downto 0);
        c10:            out std_logic;
        c11:            out std_logic;
        c12:            out std_logic;
        cc13:           out std_logic_vector(1 downto 0);
        valu_go:        out std_logic;
        shuffle_go:     out std_logic;
        
        -- control signals in
        out_valid:      in  std_logic;
        shuffle_valid:  in  std_logic;
        
        -- communication with scalar unit
        ir_ready:       in std_logic;                       -- next instruction has been loaded into ir
        s_ready:        in std_logic;                       -- data from scalar unit or mi is ready
        s_fetched:      in std_logic;                       -- signal for vector unit to continue

        v_ready:        out std_logic;                      -- data for scalar unit or mi is ready
        v_fetched:      out std_logic;                      -- signal for scalar unit to continue
        v_done:         out std_logic                       -- vector unit completed command
    );
end vector_controlunit;

architecture rtl of vector_controlunit is   
    type statetype is (wfi, decode_wait, vmovrv, vmovrrn, vmovrnv, valu1, valu2, valu3, vld, vtos,
                       movrts, mova, shuffle1, shuffle2, shuffle3, vmol, vmor);
        
    signal state : statetype := wfi;
    signal nextstate : statetype := wfi;

begin

    -- state register
    process
    begin
        wait until clk='1' and clk'event;
        state <= nextstate;
    
    end process;
    
    -- state transitions
    process (state, ir, ir_ready, s_ready, s_fetched, out_valid, shuffle_valid)
    begin
        -- avoid latches
        load_r      <= '0';
        cc9         <= "00";  
        c10         <= '0';
        c11         <= '0';
        c12         <= '0';
        cc13        <= "00";
        v_ready     <= '0';
        v_fetched   <= '0';
        v_done      <= '0';
        valu_go     <= '0';
        shuffle_go  <= '0';
        
        nextstate   <= wfi;
         
        case state is
            
            -- WAIT FOR INSTRUCTION STATE --
            when wfi =>
                 if ir_ready = '1' then
                    nextstate <= decode_wait;
                else
                    v_done <= '1';
                    nextstate <= wfi;
                end if;
            
            -- DECODE AND WAIT STATE --
            when decode_wait =>
                case ir(19 downto 18) is
                    when "00" =>                               
                        if ir(17) = '0' then                        -- vnop
                            nextstate <= wfi;
                        else
                            case ir(15 downto 12) is
                                when "0001" =>                      -- vmov r,v
                                    nextstate <= vmovrv;
                                
                                when "0010" =>                      -- vmov r, R<n>
                                    nextstate <= vmovrrn;
                                    
                                when "0011" =>                      -- vmov R<n>, v
                                    nextstate <= vmovrnv;
                                
                                when "1000" =>                      -- vmol r,v
                                    nextstate <= vmol;
                                    
                                when "1100" =>                      -- vmor r,v
                                    nextstate <= vmor;  
                                    
                                when others =>                      -- error => ignore command
                                    nextstate <= wfi;
                            end case;
                         end if;

                    when "01" =>                                -- valu
                        nextstate <= valu1;
                        
                    when "10" =>                                -- vld/vst/move
                        case ir(15 downto 12) is
                            when "0010" =>                      -- vld
                                if s_ready = '1' then
                                    nextstate <= vld;
                                else
                                    nextstate <= decode_wait;
                                end if;
                                
                            when "0011" | "0101" =>             -- vst, mov d, v(t)
                                nextstate <= vtos;
                            
                            when "0100" =>                      -- mov r(t), s
                                if s_ready = '1' then
                                    nextstate <= movrts;
                                else
                                    nextstate <= decode_wait;
                                end if;
                            
                            when "0110" =>                      -- mova
                                if s_ready = '1' then
                                    nextstate <= mova;
                                else
                                    nextstate <= decode_wait;
                                end if;
                            
                            when others =>                      -- error => ignore command
                                nextstate <= wfi;
                        end case;
                    
                    when "11" =>                                -- shuffle
                        if use_shuffle then
                            nextstate <= shuffle1;
                        else
                            nextstate <= wfi;
                        end if;
                    when others =>                              -- error
                        nextstate <= wfi;
                end case;
            
            -- VMOL R,V STATE --
            when vmol =>
                cc13 <= "10";
                cc9 <= "11";
                load_r <= '1';
                nextstate <= wfi;
            
            -- VMOR R,V STATE --
            when vmor =>
                cc13 <= "11";
                cc9 <= "11";
                load_r <= '1';
                nextstate <= wfi;
            
            -- VMOV R,V STATE --
            when vmovrv =>
                cc13 <= "01";
                cc9 <= "11";
                load_r <= '1';
                nextstate <= wfi;
                
            -- VMOV R,R<N> STATE --
            when vmovrrn =>
                cc13 <= "01";
                cc9 <= "11";
                c11 <= '1';
                load_r <= '1';
                nextstate <= wfi;
                
            -- VMOV R<N>,V STATE --
            when vmovrnv =>
                cc13 <= "01";
                cc9 <= "11";
                c10 <= '1';
                load_r <= '1';
                nextstate <= wfi;
            
            -- VALU COMMAND STATE --
            when valu1 =>
                valu_go <= '1';
                nextstate <= valu2;
            
            when valu2 =>
                if out_valid = '0' then
                    nextstate <= valu2;
                else
                    nextstate <= valu3;
                end if;
            
            when valu3 =>
                load_r <= '1';
                nextstate <= wfi;
            
            -- VLD STATE --
            when vld =>
                cc9 <= "10";
                load_r <= '1';
                v_fetched <= '1';
                nextstate <= wfi;
                
            -- VECTOR TO SCALAR STATE --
            when vtos =>
                v_ready <= '1';
                
                if s_fetched = '1' then
                    nextstate <= wfi;
                else
                    nextstate <= vtos;
                end if;
                
            -- MOV R(T),S STATE --
            when movrts =>
                cc9 <= "01";
                c12 <= '1';
                load_r <= '1';
                v_fetched <= '1';
                nextstate <= wfi;  
                
            -- MOVA STATE --
            when mova =>
                cc9 <= "01";
                load_r <= '1';
                v_fetched <= '1';
                nextstate <= wfi;   

            -- SHUFFLE STATES
            when shuffle1 =>
                shuffle_go <= '1';
                nextstate <= shuffle2;
            
            when shuffle2 =>
                if shuffle_valid = '0' then
                    nextstate <= shuffle2;
                else
                    nextstate <= shuffle3;
                end if;
            
            when shuffle3 =>
                cc9 <= "11";
                load_r <= '1';
                nextstate <= wfi;                
        
        end case;
	end process;
end rtl;

