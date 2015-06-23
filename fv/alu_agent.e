alu_agent.e;
<'
import alu_components.e;

unit alu_agent_u {
	smp: alu_signal_map_u is instance;
	mon: alu_mon_u is instance;
	bfm: alu_bfm_u is instance;
	chk: alu_chk_u is instance;

	event main_clk;	

	keep bfm.agent == me;
	keep bfm.reset_n == smp.reset_n;
	keep bfm.alu_enable == smp.alu_enable;
	keep bfm.alu_opcode == smp.alu_opcode;
	keep bfm.alu_a == smp.alu_a;

	keep mon.agent == me;	
	keep mon.alu_result == smp.alu_result;
	keep mon.alu_status == smp.alu_status;
	keep mon.alu_x == smp.alu_x;
	keep mon.alu_y == smp.alu_y;

	//on main_clk {
		//while TRUE {
			//counter = counter +1;

			//if (counter == 37) {
				//dut_error();
			//}
			//else {
				//out("\n",counter);
			//}
		//}
	//};

	run() is also {
		//start help();
	};
};

extend alu_bfm_u {
	agent: alu_agent_u;
	event main_clk is only @agent.main_clk;
};

extend alu_mon_u {
	agent: alu_agent_u;
	event main_clk is only @agent.bfm.done;
};


'>
