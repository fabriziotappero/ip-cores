------------------------------------------------------------------
-- PROJECT:     HiCoVec (highly configurable vector processor)
--
-- ENTITY:      vector_slice
--
-- PURPOSE:     slice of the vector executionunit
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

entity vector_slice is
    generic (
        slicenr : natural := 0
    );
    port (   
        -- clock
        clk:                in std_logic;  
        
        -- data inputs
        memory_in:          in std_logic_vector(31 downto 0);
        scalar_in:          in std_logic_vector(31 downto 0);
        shuffle_in:         in std_logic_vector(31 downto 0);
        carry_in:           in std_logic;
        rshift_in:          in std_logic;
        
        -- data outputs
        v_out:              out std_logic_vector(31 downto 0);
        w_out:              out std_logic_vector(31 downto 0);
        carry_out:          out std_logic;
        
        -- control signals
        rrrr:               in std_logic_vector(7 downto 0);
        vvvv:               in std_logic_vector(7 downto 0);
        wwww:               in std_logic_vector(3 downto 0);
        k_in:               in std_logic_vector(31 downto 0);
        load_r:             in std_logic;
        cc9:                in std_logic_vector(1 downto 0);
        c12:                in std_logic;
        
        -- valu control signals
        valuop:             in std_logic_vector(3 downto 0);
        source_sel:         in std_logic_vector(1 downto 0);
        carry_sel:          in std_logic_vector(1 downto 0);
        mult_source_sel:    in std_logic_vector(1 downto 0); -- *
        mult_dest_sel:      in std_logic_vector(1 downto 0); -- *
        reg_input_sel:      in std_logic;                    -- *
        load_lsr:           in std_logic;
        load_other:         in std_logic
    );
end vector_slice;

architecture rtl of vector_slice is 
    component multiplexer4
        generic (
            w : positive
        );
        port (
            selector:    in std_logic_vector(1 downto 0);
            data_in_00:  in std_logic_vector(w-1 downto 0);
            data_in_01:  in std_logic_vector(w-1 downto 0);
            data_in_10:  in std_logic_vector(w-1 downto 0);
            data_in_11:  in std_logic_vector(w-1 downto 0);
            data_out:    out std_logic_vector(w-1 downto 0)
        );
    end component;
    
    
    component vector_alu_32
        port(   
            clk:                in std_logic;
            v_in:               in std_logic_vector(31 downto 0);
            w_in:               in std_logic_vector(31 downto 0);
            carry_in:           in std_logic;
            rshift_in:          in std_logic;
            carry_out:          out std_logic;
            valu_out:           out std_logic_vector(31 downto 0);
            valuop:             in std_logic_vector(3 downto 0);
            source_sel:         in std_logic_vector(1 downto 0);
            carry_sel:          in std_logic_vector(1 downto 0);
            mult_source_sel:    in std_logic_vector(1 downto 0); 
            mult_dest_sel:      in std_logic_vector(1 downto 0); 
            reg_input_sel:      in std_logic;                   
            load_lsr:           in std_logic;
            load_other:         in std_logic
        );
    end component;
    
    component vector_register
        generic (
            n : integer range 1 to 256;
            slicenr : natural
        );
                
        port (   
            clk:            in  std_logic;
            r_in:           in  std_logic_vector(31 downto 0);
            v_out:          out std_logic_vector(31 downto 0);
            w_out:          out std_logic_vector(31 downto 0);
            load_r:         in  std_logic;
            load_select:    in  std_logic;
            k_in:           in  std_logic_vector(31 downto 0);       
            select_v:       in  std_logic_vector(7 downto 0);
            select_w:       in  std_logic_vector(3 downto 0);
            select_r:       in  std_logic_vector(7 downto 0)
        );
    end component;
    
    for vreg_input_mux: multiplexer4 use entity work.multiplexer4(rtl);
    for valu:           vector_alu_32 use entity work.vector_alu_32(rtl);
    for vreg:           vector_register use entity work.vector_register(rtl);

    signal v:                   std_logic_vector(31 downto 0);
    signal w:                   std_logic_vector(31 downto 0);
    signal r:                   std_logic_vector(31 downto 0);
    signal valu_result:         std_logic_vector(31 downto 0);
    
begin
    v_out <= v;
    w_out <= w;
    
    vreg_input_mux: multiplexer4 
            generic map (w => 32)
            port map (
                selector => cc9,
                data_in_00 => valu_result,
                data_in_01 => scalar_in,
                data_in_10 => memory_in,
                data_in_11 => shuffle_in,
                data_out => r
            ); 
         
     vreg: vector_register 
            generic map (
                n => n,
                slicenr => slicenr
            )
            port map (
                clk => clk,
                r_in => r,
                v_out => v,
                w_out => w,
                load_r => load_r,
                load_select => c12,
                k_in => k_in,
                select_v => vvvv,
                select_w => wwww,
                select_r => rrrr
            ); 
            
         valu: vector_alu_32
            port map (
                clk => clk,
                v_in => v,
                w_in => w,
                carry_in => carry_in,
                rshift_in => rshift_in,
                carry_out => carry_out,
                valu_out => valu_result,
                valuop => valuop,
                source_sel => source_sel,
                carry_sel => carry_sel,
                mult_source_sel => mult_source_sel,
                mult_dest_sel => mult_dest_sel,
                reg_input_sel => reg_input_sel,
                load_lsr => load_lsr,
                load_other => load_other
            );

end rtl;