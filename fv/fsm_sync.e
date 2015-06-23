<'
unit fsm_sync_u {
	clk: in event_port is instance;
	keep bind(clk, external);
	keep clk.hdl_path() == "clk";
	keep clk.edge() == fall;
};
'>
