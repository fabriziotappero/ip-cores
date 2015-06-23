------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      cpu
--
-- PURPOSE:     connects components of the
--              scalar unit and the vector unit
--              
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.cfg.all;
use work.datatypes.all;

entity cpu is
    port(
        clk: in std_logic;
        reset: in std_logic;
        
        dbg_a: out std_logic_vector(31 downto 0);
        dbg_x: out std_logic_vector(31 downto 0);
        dbg_y: out std_logic_vector(31 downto 0);
        dbg_ir: out std_logic_vector(31 downto 0);
        dbg_ic: out std_logic_vector(31 downto 0);
        dbg_carry: out std_logic;
        dbg_zero: out std_logic;
        dbg_ir_ready: out std_logic;
        dbg_halted: out std_logic;
        
        mem_data_in: in std_logic_vector(31 downto 0);
        mem_data_out: out std_logic_vector(31 downto 0);
        mem_vdata_in: in vectordata_type;
        mem_vdata_out: out vectordata_type;
        mem_address: out std_logic_vector(31 downto 0);
        mem_access: out std_logic_vector(2 downto 0);
        mem_ready: in std_logic
     );
end cpu;

architecture rtl of cpu is 
    component controlunit
        port(   
            clk:            in std_logic;                       
            ir:             in std_logic_vector(31 downto 0);   
            reset_cpu:      in std_logic;                       
            zero:           in std_logic;                       
            carry:          in std_logic;                    
            ready:          in std_logic;                      
            access_type:    out std_logic_vector(2 downto 0);  
            c0:             out std_logic;                      
            c1:             out std_logic;                      
            cc2:            out std_logic_vector(1 downto 0);                      
            cc4:            out std_logic_vector(1 downto 0);   
            cc5:            out std_logic_vector(1 downto 0);   
            c6:             out std_logic;                      
            c7:             out std_logic;                      
            c8:             out std_logic;                      
            load_ir:        out std_logic;                      
            inc_ic:         out std_logic;                      
            load_ic:        out std_logic;                                        
            load_c:         out std_logic;                      
            load_z:         out std_logic;                      
            ir_ready:       out std_logic; 
            s_ready:        out std_logic; 
            s_fetched:      out std_logic; 
            v_ready:        in std_logic; 
            v_fetched:      in std_logic; 
            v_done:         in std_logic;
            halted:         out std_logic
        );
    end component;

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
    
    component addressgroup 
        port(   
            clk:            in std_logic;  
            address_in:     in std_logic_vector(31 downto 0);
            address_out:    out std_logic_vector(31 downto 0);
            ic_out:         out std_logic_vector(31 downto 0);
            sel_source:     in std_logic; 
            inc:            in std_logic;
            load_ic:        in std_logic;
            reset_ic:       in std_logic
         );
    end component;
    
    component registergroup
        port(   
            clk:            in std_logic;
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
    
    component flaggroup
        port(   
            clk:    in std_logic;
            c_in:   in std_logic;
            z_in:   in std_logic;
            c_out:  out std_logic;
            z_out:  out std_logic;
            load_c: in std_logic;
            load_z: in std_logic;
            sel_c:  in std_logic_vector(1 downto 0);
            sel_z:  in std_logic_vector(1 downto 0)
        );
    end component;
    
    component vector_controlunit
        port(   
            clk:            in std_logic;  
            ir:             in std_logic_vector(31 downto 0);
            load_r:         out std_logic;
            cc9:            out std_logic_vector(1 downto 0);
            c10:            out std_logic;
            c11:            out std_logic;
            c12:            out std_logic;
            cc13:           out std_logic_vector(1 downto 0);
            valu_go:        out std_logic;
            shuffle_go:     out std_logic;
            out_valid:      in std_logic;
            shuffle_valid:  in std_logic;
            ir_ready:       in std_logic;
            s_ready:        in std_logic;
            s_fetched:      in std_logic;
            v_ready:        out std_logic;
            v_fetched:      out std_logic;
            v_done:         out std_logic
        );
    end component;
    
    component vector_executionunit
        port (   
            clk:        in std_logic;  
            memory_in:  in vectordata_type;
            scalar_in:  in std_logic_vector(31 downto 0);
            memory_out: out vectordata_type;
            scalar_out: out std_logic_vector(31 downto 0);
            out_valid:  out std_logic;
            shuffle_valid: out std_logic;
            rrrr:       in std_logic_vector(3 downto 0);
            vvvv:       in std_logic_vector(3 downto 0);
            wwww:       in std_logic_vector(3 downto 0);
            k_in:       in std_logic_vector(31 downto 0);
            vn:         in std_logic_vector(7 downto 0); 
            valuop:     in std_logic_vector(3 downto 0);
            vwidth:     in std_logic_vector(1 downto 0);
            load_r:     in std_logic;
            cc9:        in std_logic_vector(1 downto 0);
            c10:        in std_logic;
            c11:        in std_logic;
            c12:        in std_logic;
            cc13:       in std_logic_vector(1 downto 0);
            valu_go:    in std_logic;
            shuffle_go: in std_logic
        );
    end component;

    for controlunit_impl:           controlunit             use entity work.controlunit(rtl);
    for aluinputgroup_impl:         aluinputgroup           use entity work.aluinputgroup(rtl);
    for alu_impl:                   alu                     use entity work.alu(rtl);
    for addressgroup_impl:          addressgroup            use entity work.addressgroup(rtl);
    for registergroup_impl:         registergroup           use entity work.registergroup(rtl);
    for flaggroup_impl:             flaggroup               use entity work.flaggroup(rtl);
    for vector_controlunit_impl:    vector_controlunit      use entity work.vector_controlunit(rtl);
    for vector_executionunit_impl:  vector_executionunit    use entity work.vector_executionunit(rtl);
    
    -- controlunit signals
    signal ir:              std_logic_vector(31 downto 0);  
    signal zero:            std_logic;                      
    signal carry:           std_logic;                      
    signal c0:              std_logic;                      
    signal c1:              std_logic;                      
    signal cc2:             std_logic_vector(1 downto 0);                      
    signal cc4:             std_logic_vector(1 downto 0);   
    signal cc5:             std_logic_vector(1 downto 0);   
    signal c6:              std_logic;                      
    signal c7:              std_logic;                      
    signal c8:              std_logic;                      
    signal load_ir:         std_logic;                      
    signal inc_ic:          std_logic;                      
    signal load_ic:         std_logic;                                          
    signal load_c:          std_logic;                      
    signal load_z:          std_logic;                      
    signal ir_ready:        std_logic;
    signal s_ready:         std_logic;                      
    signal s_fetched:       std_logic;                      
    signal v_ready:         std_logic;                    
    signal v_fetched:       std_logic;                    
    signal v_done:          std_logic; 
    
    -- aluinputgroup
    signal x:               std_logic_vector(31 downto 0);
    signal y:               std_logic_vector(31 downto 0);
    signal a:               std_logic_vector(31 downto 0);
    signal k_out:           std_logic_vector(31 downto 0); 
    signal vector_out:      std_logic_vector(31 downto 0); 
    signal alu_input_a:     std_logic_vector(31 downto 0);
    signal alu_input_b:     std_logic_vector(31 downto 0);
    
    -- alu signals
    signal aluop:           std_logic_vector(3 downto 0) ;
    signal zero_out:        std_logic;
    signal carry_out:       std_logic;
    signal alu_out:         std_logic_vector(31 downto 0);
    
    -- address group signals
    signal ic:              std_logic_vector(31 downto 0);
    
    -- register group signals
    signal vector_in:      std_logic_vector(31 downto 0);
    
    -- signals from instruction
    signal ss:              std_logic_vector(1 downto 0);
    signal dd:              std_logic_vector(1 downto 0);
    signal tt:              std_logic_vector(1 downto 0);
    
    -- vector_controlunit signals 
    signal load_r:          std_logic;
    signal cc9:             std_logic_vector(1 downto 0);
    signal c10:             std_logic;
    signal c11:             std_logic;
    signal c12:             std_logic;
    signal cc13:            std_logic_vector(1 downto 0);
    signal valu_go:         std_logic;
    signal out_valid:       std_logic;
    signal shuffle_go:      std_logic;
    signal shuffle_valid:   std_logic;
    
    -- vector_executionunit signals
    signal rrrr:            std_logic_vector(3 downto 0);
    signal vvvv:            std_logic_vector(3 downto 0);
    signal wwww:            std_logic_vector(3 downto 0);
    signal vn:              std_logic_vector(7 downto 0); 
    signal valuop:          std_logic_vector(3 downto 0);
    signal vwidth:          std_logic_vector(1 downto 0);
     
begin
  
    controlunit_impl: controlunit 
        port map (
            clk => clk, ir => ir, reset_cpu => reset, zero => zero, carry => carry, ready => mem_ready,
            access_type => mem_access, c0 => c0, c1 => c1, cc2 => cc2, cc4 => cc4, cc5 => cc5,
            c6 => c6, c7 => c7, c8 => c8, load_ir => load_ir, inc_ic => inc_ic, load_ic => load_ic,
            load_c => load_c, load_z => load_z, ir_ready => ir_ready, s_ready =>
            s_ready, s_fetched => s_fetched,v_ready => v_ready, v_fetched => v_fetched, v_done => v_done,
            halted => dbg_halted
        ); 
            
    aluinputgroup_impl: aluinputgroup 
        port map (
            clk => clk, memory_in => mem_data_in, x_in => x, y_in => y, a_in => a, ir_out => ir, k_out => k_out,
            vector_out => vector_out, a_out => alu_input_a, b_out => alu_input_b, sel_a => ss, sel_b => tt,
            sel_source_a => c8, sel_source_b => c0, load_ir => load_ir 
        );
        
    alu_impl: alu 
        port map (
            a_in => alu_input_a, b_in => alu_input_b, carry_in => carry, aluop => aluop, 
            op_select => c7, carry_out => carry_out, zero_out => zero_out, alu_out => alu_out
        );
        
    addressgroup_impl: addressgroup 
        port map (
            clk => clk, address_in => alu_out, address_out => mem_address, ic_out => ic, sel_source => c1, 
            inc => inc_ic, load_ic => load_ic, reset_ic => reset
        ); 
        
    registergroup_impl: registergroup 
        port map (
            clk => clk, result_in => alu_out, vector_in => vector_in,
            ic_in => ic, enable_in => c6,  x_out => x, y_out => y, a_out => a,
            sel_source => cc2, sel_dest => dd
        ); 
        
    flaggroup_impl: flaggroup 
        port map (
            clk => clk, c_in => carry_out, z_in => zero_out, c_out => carry,
            z_out => zero, load_c => load_c, load_z => load_z, sel_c => cc5, sel_z => cc4
        ); 
    
    vector_controlunit_impl: vector_controlunit
        port map (
            clk => clk, ir => ir, load_r => load_r, cc9 => cc9, c10 => c10, c11 => c11,
            c12 => c12, cc13 => cc13, valu_go => valu_go, shuffle_go => shuffle_go, out_valid => out_valid,
            shuffle_valid => shuffle_valid, ir_ready => ir_ready, s_ready => s_ready, s_fetched => s_fetched,
            v_ready => v_ready, v_fetched => v_fetched, v_done => v_done
        );
        
    vector_executionunit_impl: vector_executionunit
        port map (
            clk => clk, memory_in => mem_vdata_in, scalar_in => vector_out, memory_out => mem_vdata_out,
            scalar_out => vector_in, out_valid => out_valid, shuffle_valid => shuffle_valid, rrrr => rrrr,
            vvvv => vvvv, wwww => wwww, k_in => k_out, vn => vn, valuop => valuop, vwidth => vwidth,
            load_r => load_r, cc9 => cc9, c10 => c10, c11 => c11, c12 => c12, cc13 => cc13, valu_go => valu_go,
            shuffle_go => shuffle_go
        );

    -- from ir derived signals
    dd <= ir (25 downto 24);
    ss <= ir (23 downto 22);
    tt <= ir (21 downto 20);
    aluop <= ir (29 downto 26);
    rrrr <= ir (11 downto 8);
    vvvv <= ir (7 downto 4);
    wwww <= ir (3 downto 0);
    vn <= ir (27 downto 20);
    valuop <= ir (15 downto 12);
    vwidth <= ir (17 downto 16);

    -- memory interfaces signals
    mem_data_out <= a;
    
    -- debugging signals
    dbg_a <= a;
    dbg_x <= x;
    dbg_y <= y;
    dbg_ir <= ir;
    dbg_ic <= ic;
    dbg_carry <= carry;
    dbg_zero <= zero;
    dbg_ir_ready <= ir_ready;
   
end;