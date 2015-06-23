library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fp_generic.all;

package fpmult_stageN_comp is
	type fpmult_stageN_in_type is record
		a:fp_type;
		b:fp_type;

		p_sign:fp_sign_type;
		p_exp:fp_exp_type;
		p_mantissa:fp_long_mantissa_type;
	end record;

	alias fpmult_stageN_out_type is fpmult_stageN_in_type;

	component fpmult_stageN is
		generic(
			N:integer
		);
		port(
			clk:in std_logic;
			d:in fpmult_stageN_in_type;
			q:out fpmult_stageN_out_type
		);
	end component;
end package;