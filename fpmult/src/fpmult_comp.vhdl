library ieee;
use ieee.std_logic_1164.all;
use work.fp_generic.all;

package fpmult_comp is
	type fpmult_in_type is record
		a:fp_type;
		b:fp_type;
	end record;

	type fpmult_out_type is record
		p:fp_type;
	end record;

	component fpmult is
		port(
			clk:in std_logic;
			d:in fpmult_in_type;
			q:out fpmult_out_type
		);
	end component;
end package;