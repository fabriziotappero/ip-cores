<'
import fsm_components.e;

unit fsm_agent_u {
	smp: fsm_signal_map_u is instance;
	mon: fsm_mon_u        is instance;
	bfm: fsm_bfm_u        is instance;
	chk: fsm_chk_u        is instance;

	event main_clk;

	keep bfm.agent      == me;
	keep bfm.reset_n    == smp.reset_n;
	keep bfm.alu_result == smp.alu_result;
	keep bfm.alu_status == smp.alu_status;
	keep bfm.data_in    == smp.data_in;
	keep bfm.alu_x      == smp.alu_x;
	keep bfm.alu_y      == smp.alu_y;

	keep mon.agent      == me;
	keep mon.addr       == smp.addr;
	keep mon.mem_rw     == smp.mem_rw;
	keep mon.data_out   == smp.data_out;
	keep mon.alu_opcode == smp.alu_opcode;
	keep mon.alu_a      == smp.alu_a;
	keep mon.alu_enable == smp.alu_enable;

	run() is also {
	};
};

extend fsm_bfm_u {
	agent: fsm_agent_u;
	event main_clk is only @agent.main_clk;
};

extend fsm_mon_u {
	agent: fsm_agent_u;
	event main_clk is only @agent.bfm.done;
};


'>
