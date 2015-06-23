library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fp_generic.all;
use work.fpmult_stageN_comp.all;

package fpmult_stage23_comp is
	alias fpmult_stage23_in_type is fpmult_stageN_out_type;

	type fpmult_stage23_out_type is record
		p:fp_type;
	end record;

	component fpmult_stage23 is
		port(
			clk:in std_logic;
			d:in fpmult_stage23_in_type;
			q:out fpmult_stage23_out_type
		);
	end component;
end package;