--  Copyright (C) 2004-2005 Digish Pandya <digish.pandya@gmail.com>

--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

-- VHDL Test Bench Created from source file data_gen.vhd -- 09:38:13 03/25/2005
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT data_gen
	PORT(
		clock : IN std_logic;
		reset : IN std_logic;          
		xout : OUT std_logic_vector(7 downto 0);
		dxout : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	SIGNAL clock :  std_logic;
	SIGNAL reset :  std_logic;
	SIGNAL xout :  std_logic_vector(7 downto 0);
	SIGNAL dxout :  std_logic_vector(7 downto 0);

	CONSTANT clk_high   : time := 10 ns;
	CONSTANT clk_low    : time := 10 ns;
	CONSTANT clk_period : time := 20 ns;
	CONSTANT clk_hold   : time := 4 ns;


BEGIN

	uut: data_gen PORT MAP(
		clock => clock,
		reset => reset,
		xout => xout,
		dxout => dxout
	);


-- *** Test Bench - User Defined Section ***
   clk_gen: PROCESS
   BEGIN
	    clock <= '1';
	    WAIT FOR clk_high;
	    clock <= '0';
	    WAIT FOR clk_low;

   END PROCESS clk_gen;

   reset_gen: process
   begin
   		reset <= '1';
		wait for clk_period*5;
		reset <= '0';

   wait;
   end process reset_gen;
-- *** End Test Bench - User Defined Section ***

END;
