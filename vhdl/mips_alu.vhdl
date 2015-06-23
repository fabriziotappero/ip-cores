--------------------------------------------------------------------------------
-- mips_alu.vhdl -- integer arithmetic ALU, excluding mult/div functionality.
--
--------------------------------------------------------------------------------
-- Copyright (C) 2011 Jose A. Ruiz
--                                                              
-- This source file may be used and distributed without         
-- restriction provided that this copyright statement is not    
-- removed from the file and that any derivative work contains  
-- the original copyright notice and the associated disclaimer. 
--                                                              
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--                                                              
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--                                                              
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.opencores.org/lgpl.shtml
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.mips_pkg.all;

entity mips_alu is
    port(
        clk             : in std_logic;
        reset           : in std_logic;
        
        -- function selection
        ac              : in t_alu_control;
        -- comparison result flags
        flags           : out t_alu_flags;        
        -- data inputs
        inp1            : in std_logic_vector(31 downto 0);
        inp2            : in std_logic_vector(31 downto 0);
        -- data result output
        outp            : out std_logic_vector(31 downto 0)
    );
end;

architecture rtl of mips_alu is

subtype t_eword is std_logic_vector(32 downto 0);

signal inp2_neg :           t_word;
signal alu_eop1, alu_eop2 : t_eword;
signal sex1, sex2 :         std_logic;
signal alu_arith :          t_eword;
signal alu_shift :          t_word;
signal alu_logic_shift :    t_word;
signal alu_logic :          t_word;

signal less_than_zero :     std_logic;
signal final_mux_sel :      std_logic_vector(1 downto 0);
signal alu_temp :           t_word;



begin


with ac.neg_sel select inp2_neg <= 
    not inp2                        when "01",      -- nor, sub, etc.
    inp2(15 downto 0) & X"0000"     when "10",      -- lhi
    X"00000000"                     when "11",      -- zero
    inp2                            when others;    -- straight

sex1 <= inp1(31) when ac.arith_unsigned='0' else '0';
alu_eop1 <= sex1 & inp1;
sex2 <= inp2_neg(31) when (ac.arith_unsigned='0' or ac.use_slt='1') else '0';
alu_eop2 <= sex2 & inp2_neg;
alu_arith <= alu_eop1 + alu_eop2 + ac.cy_in;

with ac.logic_sel select alu_logic <= 
    inp1 and inp2_neg       when "00",
    inp1 or  inp2_neg       when "01",
    inp1 xor inp2_neg       when "10",
             inp2_neg       when others;

shifter : entity work.mips_shifter
    port map (
        d   => inp2,
        a   => ac.shift_amount,
        fn  => ac.shift_sel,
        r   => alu_shift
    );


with ac.use_logic select alu_logic_shift <= 
    alu_logic           when "01",
    not alu_logic       when "11",  -- used only by NOR instruction
    alu_shift           when others;


final_mux_sel(0) <= ac.use_arith when ac.use_slt='0' else less_than_zero;
final_mux_sel(1) <= ac.use_slt;
 
with final_mux_sel select alu_temp <= 
    alu_arith(31 downto 0)  when "01",
    alu_logic_shift         when "00",
    X"00000001"             when "11",
    X"00000000"             when others;

less_than_zero <= alu_arith(32);

flags.inp1_lt_zero <= inp1(31);
flags.inp1_lt_inp2 <= less_than_zero;
flags.inp1_eq_inp2 <= '1' when alu_arith(31 downto 0)=X"00000000" else '0';
flags.inp1_eq_zero <= '1' when inp1(31 downto 0)=X"00000000" else '0'; -- FIXME simplify

outp <= alu_temp;

end; --architecture rtl
