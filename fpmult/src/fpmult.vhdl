library ieee;
use ieee.std_logic_1164.all;
use work.fpmult_comp.all;
use work.fpmult_stage_pre_comp.all;
use work.fpmult_stage0_comp.all;
use work.fpmult_stageN_comp.all;
use work.fpmult_stage23_comp.all;

entity fpmult is
	port(
		clk:in std_logic;
		d:in fpmult_in_type;
		q:out fpmult_out_type
	);
end;

architecture structural of fpmult is
	signal fpmult_stage_pre_in:fpmult_stage_pre_in_type;
	signal fpmult_stage_pre_out:fpmult_stage_pre_out_type;
	signal fpmult_stage0_in:fpmult_stage0_in_type;
	signal fpmult_stage0_out:fpmult_stage0_out_type;
	signal fpmult_stage23_in:fpmult_stage23_in_type;
	signal fpmult_stage23_out:fpmult_stage23_out_type;
	type fpmult_stageN_in_array_type is array(23 downto 1) of fpmult_stageN_in_type;
	type fpmult_stageN_out_array_type is array(22 downto 1) of fpmult_stageN_out_type;
	signal fpmult_stageN_in_array:fpmult_stageN_in_array_type;
	signal fpmult_stageN_out_array:fpmult_stageN_out_array_type;
begin
	fpmult_stage_pre_in.a<=d.a;
	fpmult_stage_pre_in.b<=d.b;

	stage_pre:fpmult_stage_pre port map(clk,fpmult_stage_pre_in,fpmult_stage_pre_out);

	fpmult_stage0_in.a<=fpmult_stage_pre_out.a;
	fpmult_stage0_in.b<=fpmult_stage_pre_out.b;

	stage0:fpmult_stage0 port map(clk,fpmult_stage0_in,fpmult_stage0_out);

	fpmult_stageN_in_array(1)<=fpmult_stage0_out;
	
	pipeline:for N in 22 downto 1 generate
		stageN:fpmult_stageN generic map(N) port map(clk,fpmult_stageN_in_array(N),fpmult_stageN_out_array(N));
		fpmult_stageN_in_array(N+1)<=fpmult_stageN_out_array(N);
	end generate pipeline;

	fpmult_stage23_in<=fpmult_stageN_out_array(22);

	stage23:fpmult_stage23 port map(clk,fpmult_stage23_in,fpmult_stage23_out);

	q.p<=fpmult_stage23_out.p;
end;
