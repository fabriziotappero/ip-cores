--
--
--  This file is a part of JOP, the Java Optimized Processor
--
--  Copyright (C) 2001-2008, Martin Schoeberl (martin@jopdesign.com)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--


--
--	shift.vhd
--
--	barrel shifter
--	
--	resources on ACEX1K
--
--	
--		227 LCs
--
--	2001-05-14	first version
--


library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;


entity shift is

generic (
	width		: integer := 32		-- one data word
);

port (
	din			: in std_logic_vector(width-1 downto 0);
	off			: in std_logic_vector(4 downto 0);
	shtyp		: in std_logic_vector(1 downto 0);
	dout		: out std_logic_vector(width-1 downto 0)
);
end shift;


architecture rtl of shift is

--
--	Signals
--
	signal zero32			: std_logic_vector(width-1 downto 0);


begin

	zero32 <= (others => '0');

process(din, off, shtyp, zero32)

	variable shiftin : std_logic_vector(63 downto 0);
	variable shiftcnt : std_logic_vector(4 downto 0);

begin

	shiftin := zero32 & din;
	shiftcnt := off;

	if shtyp="01" then	-- sll
		shiftin(31 downto 0) := zero32;
		shiftin(63 downto 31) := '0' & din;
		shiftcnt := not shiftcnt;
	elsif shtyp="10" then	-- sra
		if din(31) = '1' then
			shiftin(63 downto 32) := (others => '1');
		else
			shiftin(63 downto 32) := zero32;
		end if;
	end if;

--
--	00	ushr
--	01	shl
--	10	shr
--	11	not used!
--
--	das geht aber nicht!!! TODO schaun warum
--
--	if shtyp(0)='1' then	-- sll
--		shiftin := din & zero32;
--		shiftcnt := not off;
--	else				-- sr
--		shiftin(31 downto 0) := din;
--		shiftcnt := off;
--
--		if shtyp(1)='1' and din(31) = '1' then		-- sra
--			shiftin(63 downto 32) := (others => '1');
--		else
--			shiftin(63 downto 32) := zero32;
--		end if;
--	end if;

	if shiftcnt (4) = '1' then
		shiftin(47 downto 0) := shiftin(63 downto 16);
	end if;
	if shiftcnt (3) = '1' then
		shiftin(39 downto 0) := shiftin(47 downto 8);
	end if;
	if shiftcnt (2) = '1' then
		shiftin(35 downto 0) := shiftin(39 downto 4);
	end if;
	if shiftcnt (1) = '1' then
		shiftin(33 downto 0) := shiftin(35 downto 2);
	end if;
	if shiftcnt (0) = '1' then
		shiftin(31 downto 0) := shiftin(32 downto 1);
	end if;

	dout <= shiftin(31 downto 0);

end process;

end rtl;
