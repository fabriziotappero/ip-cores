<'
import fsm_components;

unit fsm_env_u {
	agent: fsm_agent_u is instance;
	sync : fsm_sync_u  is instance;

	keep agent.env == me;
};

extend fsm_agent_u {
	env: fsm_env_u;
	event main_clk is only @env.sync.clk$;
};

extend sys {
	env: fsm_env_u is instance;
	keep env.hdl_path() == "~/t6507lp_fsm_wrapper";
};
'>
