--------------------------------------------------------------------------------
-- mips_shifter.vhdl -- combinational barrel shifter 
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
use ieee.std_logic_signed.all;

entity mips_shifter is
    port(
        -- data input
        d               : in  std_logic_vector(31 downto 0);
        -- shift amount
        a               : in  std_logic_vector(4 downto 0);
        -- shift function: {0=sll,1=sla(unused),2=srl,3=sra}
        fn              : in  std_logic_vector(1 downto 0);
        -- shift result
        r               : out std_logic_vector(31 downto 0)
    );
end;

architecture small of mips_shifter is

signal i_rev, o_rev :       std_logic_vector(31 downto 0);

signal ext :                std_logic_vector(31 downto 0);
type t_s is array(0 to 5) of std_logic_vector(31 downto 0);
signal s :                  t_s;

begin
    -- The barrel shifter needs to shift left and right. This would usually 
    -- require two parallel barrel shifters (left and right) and an output mux
    -- stage. Instead, we're gonna use a single left shifter, with two 
    -- conditional bit-reversal stages at input and output. 
    -- This will increase the LUT depth (and thus the delay) by 1 LUT row but 
    -- we'll cut the area by 4/11 more or less (depends on how many dedicated 
    -- muxes vs. LUTs the synth will use).
    -- The barrel shifter can account for as much as 1/4 of the CPU area 
    -- (excluding mult/div unit) so it makes sense to be cheap here if what we 
    -- want is a small core.
    -- NOTE: this logic may or may not be in the critical delay path of the
    -- core, depending on the cache implementation. See your synthesis report.
    
    -- Reverse input when shifting right
    input_reversed:
    for i in 0 to 31 generate
    begin
        i_rev(i) <= d(31-i);
    end generate input_reversed;
    s(5) <= i_rev when fn(1)='1' else d;
    
    -- Sign extension / zero extension
    ext <= (others => d(31)) when fn(0)='1' else (others => '0');
    
    -- Build left barrel shifter in 5 binary stages as usual
    shifter_stages:
    for i in 0 to 4 generate
    begin
        with a(i) select s(i) <=
            s(i+1)(31-2**i downto 0) & ext(2**i-1 downto 0) when '1',
            s(i+1)                                          when others;
    end generate shifter_stages;

    -- Reverse output when shifting right
    output_reversal:
    for i in 0 to 31 generate
    begin
        o_rev(i) <= s(0)(31-i);
    end generate output_reversal;
    r <= o_rev when fn(1)='1' else s(0);

end architecture small;
