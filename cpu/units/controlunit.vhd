------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      controlunit
--
-- PURPOSE:     controlunit of scalar unit
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity controlunit is
    port(   
        -- clock
        clk:            in std_logic;                       -- clock signal
        
        -- instruction in
        ir:             in std_logic_vector(31 downto 0);   -- instruction
        
        -- control signals in
        reset_cpu:      in std_logic;                       -- reset signal
        zero:           in std_logic;                       -- zero flag
        carry:          in std_logic;                       -- carry flag
        ready:          in std_logic;                       -- memory interface ready signal
        
        -- control signals out
        access_type:    out std_logic_vector(2 downto 0);   -- memory interface access type (we, oe, cs)
        c0:             out std_logic;                      -- c0 signal
        c1:             out std_logic;                      -- c1 signal
        cc2:            out std_logic_vector(1 downto 0);   -- cc2 signal
        --c3:             out std_logic;                    -- c3 signal => obsolete
        cc4:            out std_logic_vector(1 downto 0);   -- cc4 signal
        cc5:            out std_logic_vector(1 downto 0);   -- cc5 signal
        c6:             out std_logic;                      -- c6 signal
        c7:             out std_logic;                      -- c7 signal
        c8:             out std_logic;                      -- c7 signal
        load_ir:        out std_logic;                      -- instruction register load signal
        inc_ic:         out std_logic;                      -- instruction counter increment signal
        load_ic:        out std_logic;                      -- instruction counter load signal
        load_c:         out std_logic;                      -- carry flag load signal
        load_z:         out std_logic;                      -- zero flag load signal
        
        -- communication with vecor unit
        ir_ready:       out std_logic;                      -- next instruction has been loaded into ir
        s_ready:        out std_logic;                      -- data from scalar unit or mi is ready
        s_fetched:      out std_logic;                      -- signal for vector unit to continue

        v_ready:        in std_logic;                       -- data for scalar unit or mi is ready
        v_fetched:      in std_logic;                       -- signal for scalar unit to continue
        v_done:         in std_logic;                       -- vector unit completed command
        
        halted:         out std_logic                       -- enabled when cpu is in halt state
    );
end controlunit;

architecture rtl of controlunit is   
    type statetype is (if1, if2, decode_wait, ld1, ld2, vld1, vld2, vld3, vld4,
        st1, st2, vst1, vst2, vst3, smv1, smv2, vms1, vms2, nop, jal, jcc, alu, flag, sync, halt,
        mova1, mova2, reset);
        
    signal state : statetype := halt;
    signal nextstate : statetype := halt;

begin

    -- state register
    process
    begin
        wait until clk='1' and clk'event;
        state <= nextstate;
    
    end process;
    
    -- state transitions
    process (state, ready, reset_cpu, ir, carry, zero, v_ready, v_fetched, v_done)
    begin
        -- avoid latches
        access_type <= "000";
        c0          <= '0';
        c1          <= '0';
        cc2         <= "00";
        cc4         <= "00";
        cc5         <= "00";
        c6          <= '0';
        c7          <= '0';
        c8          <= '0';
        load_ir     <= '0';
        inc_ic      <= '0';
        load_ic     <= '0';
        load_c      <= '0';
        load_z      <= '0';
        ir_ready    <= '0';
        s_ready     <= '0';
        s_fetched   <= '0';
        nextstate   <= reset;
        halted <= '0';
         
        if reset_cpu = '1' then
            nextstate <= reset;
        else    
            case state is
                -- RESET STATE --
                when reset => 
                    cc4 <= "10";
                    cc5 <= "10";
                    load_c <= '1';
                    load_z <= '1';
                    nextstate <= if1;                                               
                    
                -- INSTRUCTION FETCH STATE 1 --
                when if1 =>
                    access_type <= "010";
                    nextstate <= if2;
                
                -- INSTRUCTION FETCH STATE 2 --
                when if2 =>
                    access_type <= "010";
                    ir_ready <= '1';
                    load_ir <= '1';
                    
                    if ready = '0' then
                        nextstate <= if2;
                    else
                        nextstate <= decode_wait;
                    end if;
                    
                -- DECODE AND WAIT STATE --
                when decode_wait =>
                    if ir(31 downto 28) = "1000" then       -- ld
                        if ready = '1' then
                            nextstate <= ld1;
                        else
                            nextstate <= decode_wait;
                        end if;
                    
                    elsif ir(31 downto 28) = "1001" then    -- vld
                        if ready = '1' then
                            nextstate <= vld1;
                        else
                            nextstate <= decode_wait;
                        end if;
                    
                    elsif ir(31 downto 28) = "1010" then    -- store
                        if ready = '1' then
                            nextstate <= st1;
                        else
                            nextstate <= decode_wait;
                        end if;
                        
                    elsif ir(31 downto 26) = "101100" then   -- vst
                        if ready = '1' and v_ready = '1' then
                            nextstate <= vst1;
                        else
                            nextstate <= decode_wait;
                        end if;
                    
                    elsif ir(31 downto 26) = "101101" then   -- mova
                        nextstate <= mova1;
                    
                    elsif ir(31 downto 26) = "101110" then   -- mov r(t), s
                        nextstate <= smv1;
                        
                    elsif ir(31 downto 26) = "101111" then   -- mov d, v(t)
                        nextstate <= vms1;
                    
                    else
                        case ir(31 downto 30) is
                            when "00" =>
                                if ir(29) = '0' then                    -- nop
                                    nextstate <= nop;
                                
                                elsif ir(29 downto 27) = "101" then     -- halt
                                    report "HALT";
                                    nextstate <= halt;
                                
                                elsif ir(29 downto 26) = "1000" then    -- jmp, jal
                                    nextstate <= jal;
                                  
                                elsif ir(29 downto 28) = "11" then      -- jcc
                                    nextstate <= jcc;
                                end if;
    
                            when "01" =>                                -- alu cmd
                                nextstate <= alu;
    
                            when "11" =>                                -- set/clear flags
                                nextstate <= flag;
                            
                            when others =>                              -- error
                                nextstate <= halt;
                        end case;
                    end if;
                
                   
                -- LOAD STATE 1 --
                when ld1 =>
                    access_type <= "010";
                    c1 <= '1';
                    c7 <= '1';
                    nextstate <= ld2;
                    
                -- LOAD STATE 2 --
                when ld2 =>
                    access_type <= "010";
                    report "LD";
                    c0 <= '1';
                    c6 <= '1';
                    c7 <= '1';
                    c8 <= '1';
                    load_z <= '1';
                    inc_ic <= '1';
                    
                    if ready = '0' then
                        nextstate <= ld2;
                    else
                        nextstate <= sync;
                    end if;
                
                
                -- VECTOR LOAD STATE 1 --
                when vld1 =>
                    access_type <= "011";
                    c1 <= '1';
                    c7 <= '1';
                    
                    if ready = '1' then
                        nextstate <= vld1;
                    else
                        nextstate <= vld2;
                    end if;
                
                -- VECTOR LOAD STATE 2 --
                when vld2 =>
                    access_type <= "011";
                    c1 <= '1';
                    c7 <= '1';
                    
                    if ready = '1' then
                        nextstate <= vld3;
                    else
                        nextstate <= vld2;
                    end if;
                 
                -- VECTOR LOAD STATE 3 --
                when vld3 =>
                    access_type <= "011";
                    c1 <= '1';
                    c7 <= '1';
                    s_ready <= '1';
                    
                    if v_fetched = '1' then
                        nextstate <= vld4;
                    else
                        nextstate <= vld3;
                    end if;
                    
                -- VECTOR LOAD STATE 4 --
                when vld4 =>
                    report "VLD";
                    inc_ic <= '1';
                    nextstate <= sync;
                    
                -- STORE STATE 1 --
                when  st1 =>
                    access_type <= "100";
                    c1 <= '1';
                    c7 <= '1';
                    inc_ic <= '1';
                    
                    nextstate <= st2;
                    
                -- STORE STATE 2 --
                when  st2 =>
                    access_type <= "100";
                    c1 <= '1';
                    c7 <= '1';
                    
                    if ready = '0' then
                        nextstate <= st2;
                    else
                        nextstate <= sync;
                    end if;
                    
                   
                -- VECTOR STORE STATE 1 --
                when vst1 =>
                    access_type <= "101";
                    c1 <= '1';
                    c7 <= '1';
                    
                    if ready = '1' then
                        nextstate <= vst1;
                    else
                        nextstate <= vst2;
                    end if;
                
                -- VECTOR STORE STATE 2 --
                when vst2 =>
                    access_type <= "101";
                    c1 <= '1';
                    c7 <= '1';
                    
                    if ready = '1' then
                        nextstate <= vst3;
                    else
                        nextstate <= vst2;
                    end if;
                    
                 -- VECTOR STORE STATE 3 --
                when vst3 =>
                    report "VST";
                    s_fetched <= '1';
                    inc_ic <= '1';
                    nextstate <= sync;
                    
                -- SCALAR MOVE TO VECTOR STATE 1 --    
                when smv1 =>
                    s_ready <= '1';
                    
                    if v_fetched = '1' then
                        nextstate <= smv2;
                    else
                        nextstate <= smv1;
                    end if;
                    
                -- SCALAR MOVE TO VECTOR STATE 2 --    
                when smv2 =>
                    report "MOV R(T), S";
                    inc_ic <= '1';
                    nextstate <= sync;
               
               -- MOVA STATE 1 --    
                when mova1 =>
                    s_ready <= '1';
                    
                    if v_fetched = '1' then
                        nextstate <= mova2;
                    else
                        nextstate <= mova1;
                    end if;
                    
                -- MOVA STATE 2 --    
                when mova2 =>
                    report "MOVA";
                    inc_ic <= '1';
                    nextstate <= sync;
   
                -- VECTOR MOVE TO SCALAR STATE  --
                when vms1 =>
                    if v_ready = '1' then
                        nextstate <= vms2;
                    else
                        nextstate <= vms1;
                    end if;
                    
                -- VECTOR MOVE TO SCALAR STATE 2 --
                when vms2 =>
                    report "MOV D, V(T)";
                    cc2 <= "10";
                    c6 <= '1';
                    s_fetched <= '1';
                    inc_ic <= '1';
                    nextstate <= sync;
               
                -- NOP STATE --
                when nop =>
                    report "NOP";
                    inc_ic <= '1';
                    nextstate <= sync;
                    
                -- JUMP AND LINK STATE
                when jal =>
                    report "JMP, JAL";
                    c7 <= '1';
                    load_ic <= '1';
                    cc2 <= "01";
                    c6 <= '1';
                    nextstate <= sync;
                
                -- JUMP CONDITIONAL STATE
                when jcc =>
                    report "JCC";
                    if (ir(27) = '0' and ir(26) = carry) 
                      or (ir(27) = '1' and ir(26) = zero) then
                        c7 <= '1';
                        load_ic <= '1';
                    else
                        inc_ic <= '1';
                    end if;
                    
                    nextstate <= sync;
                
                -- ALU COMMAND STATE --
                when alu =>
                    report "ALU COMMANDS";
                    load_c <= '1';
                    load_z <= '1';
                    c6 <= '1';
                    inc_ic <= '1';
                    nextstate <= sync;
                
                -- SET/CLEAR FLAGS STATE --
                when flag =>
                    report "SET/RESET FLAGS";
                    load_z <= ir(23);
                    load_c <= ir(22);
                    cc4 <= '1' & ir(21);
                    cc5 <= '1' & ir(20);
                    inc_ic <= '1';
                    nextstate <= sync;
                 
                -- SYNC STATE --
                when  sync =>
                    if v_done = '1' then
                        nextstate <= if1;
                    else
                        nextstate <= sync;
                    end if;
                    
                -- HALT STATE --
                when  halt =>
                    report "halted";
                    halted <= '1';
                    nextstate <= halt;
                   
            end case;
        end if;
	end process;
end rtl;

