library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fp_generic.all;
use work.fpmult_stageN_comp.all;

entity fpmult_stageN is
	generic(
		N:integer
	);
	port(
		clk:in std_logic;
		d:in fpmult_stageN_in_type;
		q:out fpmult_stageN_out_type
	);
end;

architecture twoproc of fpmult_stageN is
	type reg_type is record
		a:fp_type;
		b:fp_type;

		p_sign:fp_sign_type;
		p_exp:fp_exp_type;
		p_mantissa:fp_long_mantissa_type;
	end record;
	signal r,rin:reg_type;
begin
	comb:process(d,r)
		variable v:reg_type;
	begin
		-- sample register outputs
		v:=r;

		-- overload
		v.a:=d.a;
		v.b:=d.b;

		v.p_sign:=d.p_sign;
		v.p_exp:=d.p_exp;
		if fp_mantissa(d.b)(N)='1' then
			v.p_mantissa:=(resize(fp_mantissa(d.a),48) sll N) + d.p_mantissa;
		else
			v.p_mantissa:=d.p_mantissa;
		end if;

		-- drive register inputs
		rin<=v;

		-- drive outputs
		q.a<=r.a;
		q.b<=r.b;

		q.p_sign<=r.p_sign;
		q.p_exp<=r.p_exp;
		q.p_mantissa<=r.p_mantissa;
	end process;
	
	seq:process(clk,rin)
	begin
		if rising_edge(clk) then
			r<=rin;
		end if;
	end process;
end;