library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fp_generic.all;
use work.fpmult_stage0_comp.all;

package fpmult_stage_pre_comp is
	type fpmult_stage_pre_in_type is record
		a:fp_type;
		b:fp_type;
	end record;

	alias fpmult_stage_pre_out_type is fpmult_stage0_in_type;

	component fpmult_stage_pre is
		port(
			clk:in std_logic;
			d:in fpmult_stage_pre_in_type;
			q:out fpmult_stage_pre_out_type
		);
	end component;
end package;