
library ieee;
use ieee.std_logic_1164.all;

package nand_stuff is
	-- Clock cycle length in ns
	-- IMPORTANT!!! The 'clock_cycle' is configured for 400MHz, change it appropriately!
	constant clock_cycle	: real := 2.5;
	
	-- NAND delays
	constant	t_cls			: integer := integer(10.0 / clock_cycle) - 1;
	constant	t_clh			: integer := integer(5.0 / clock_cycle) - 1;
	constant	t_cs			: integer := integer(20.0 / clock_cycle) - 1;
	constant t_ch			: integer := integer(5.0 / clock_cycle) - 1;
	constant	t_wp			: integer := integer(12.0 / clock_cycle) - 1;
	constant t_als			: integer := integer(10.0 / clock_cycle) - 1;
	constant t_alh			: integer := integer(5.0 / clock_cycle) - 1;
	constant t_ds			: integer := integer(10.0 / clock_cycle) - 1;
	constant t_dh			: integer := integer(5.0 / clock_cycle) - 1;
	constant t_wc			: integer := integer(25.0 / clock_cycle) - 1;
	constant t_wh			: integer := integer(10.0 / clock_cycle) - 1;
	constant	t_cea			: integer := integer(25.0 / clock_cycle) - 1;
	constant t_rea			: integer := integer(2.5 / clock_cycle) - 1;
	constant t_rp			: integer := integer(12.0 / clock_cycle) - 1;
	constant	t_reh			: integer := integer(10.0 / clock_cycle) - 1;
	constant t_rst			: integer := integer(100000.0 / clock_cycle) - 1;
	constant t_wb			: integer := integer(100.0 / clock_cycle) - 1;	

	-- NAND OPS Selector
	constant NAND_SEL_CMD	:	std_logic_vector(3 downto 0)	:= "0001";
	constant NAND_SEL_ADDR	:	std_logic_vector(3 downto 0)	:= "0010";
	constant NAND_SEL_WRITE	:	std_logic_vector(3 downto 0)	:= "0100";
	constant NAND_SEL_READ	:	std_logic_vector(3 downto 0)	:= "1000";

end nand_stuff;