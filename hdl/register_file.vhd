-- This file is part of ARM4U CPU
-- 
-- This is a creation of the Laboratory of Processor Architecture
-- of Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )
--
-- register_file.vhd  --  Describes the register file of the processor
--                        Normally the synthesis tool should automatically infer
--                        a 32x32 SRAM unit to store the registers
--
-- Written By -  Jonathan Masur and Xavier Jimenez (2013)
--
-- This program is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the
-- Free Software Foundation; either version 2, or (at your option) any
-- later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- In other words, you are welcome to use, share and improve this program.
-- You are forbidden to forbid anyone else to use, share and improve
-- what you give them.   Help stamp out software-hoarding!

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity register_file is
    port(
        clk    : in std_logic;
        aa     : in  std_logic_vector( 4 downto 0);
        ab     : in  std_logic_vector( 4 downto 0);
		ac     : in  std_logic_vector( 4 downto 0);
        aw     : in  std_logic_vector( 4 downto 0);
        wren   : in  std_logic;
		rd_clken : in std_logic := '1';
        wrdata : in  std_logic_vector(31 downto 0);
        a      : out std_logic_vector(31 downto 0);
        b      : out std_logic_vector(31 downto 0);
		c      : out std_logic_vector(31 downto 0)
    );
end register_file;

architecture synth of register_file is
    type reg_type is array (0 to 31) of std_logic_vector(31 downto 0);
    signal reg_array : reg_type := (others=>(others=>'0'));
	signal aal, abl, acl : std_logic_vector(4 downto 0);
begin

process(clk) is
	variable aav, abv, acv : std_logic_vector(4 downto 0);
begin
    if(rising_edge(clk))then
		if rd_clken = '1'
		then
			aav := aa;
			abv := ab;
			acv := ac;
		else
			aav := aal;
			abv := abl;
			acv := acl;
		end if;

		a <= reg_array(conv_integer(aav));
		b <= reg_array(conv_integer(abv));
		c <= reg_array(conv_integer(acv));
		
		aal <= aav;
		abl <= abv;
		acl <= acv;

        if(wren='1')then
            reg_array(conv_integer(aw)) <= wrdata;
        end if;
    end if;
end process;

end synth;