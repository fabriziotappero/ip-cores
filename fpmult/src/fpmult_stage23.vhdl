library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fp_generic.all;
use work.fpmult_stage23_comp.all;

entity fpmult_stage23 is
	port(
		clk:in std_logic;
		d:in fpmult_stage23_in_type;
		q:out fpmult_stage23_out_type
	);
end;

architecture twoproc of fpmult_stage23 is
	type reg_type is record
		p_sign:fp_sign_type;
		p_exp:fp_exp_type;
		p_mantissa:unsigned(47 downto 0);
	end record;
	signal r,rin:reg_type;
begin
	comb:process(d,r)
		variable v:reg_type;
	begin
		-- sample register outputs
		v:=r;

		-- overload
		v.p_sign:=d.p_sign;
		v.p_exp:=d.p_exp;
		v.p_mantissa:=(resize(fp_mantissa(d.a),48) sll 23) + d.p_mantissa;

		-- Shift down if product >= 2.0
		if(v.p_mantissa(47)='1')then
			v.p_mantissa:=v.p_mantissa srl 1;
			v.p_exp:=v.p_exp+1;
		end if;

		-- Round mantissa
		if(v.p_mantissa(22)='1')then
			v.p_mantissa:=v.p_mantissa+(to_unsigned(1,48) sll 23);
		end if;

		-- drive register inputs
		rin<=v;

		-- drive outputs
		q.p<=std_logic_vector(r.p_sign&r.p_exp&r.p_mantissa(45 downto 23));
	end process;
	
	seq:process(clk,rin)
	begin
		if rising_edge(clk) then
			r<=rin;
		end if;
	end process;
end;