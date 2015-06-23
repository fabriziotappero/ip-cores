<'
import alu_components;
unit alu_env_u {
	agent: alu_agent_u is instance;
	sync: alu_sync_u is instance;

	keep agent.env == me;
};

extend alu_agent_u {
	env: alu_env_u;
	event main_clk is only @env.sync.clk$;
};

extend sys {
	env: alu_env_u is instance;
	keep env.hdl_path() == "~/t6507lp_alu_wrapper";
};
'>
