<' 
import fsm_components;

unit fsm_mon_u {
	addr       : in simple_port of uint(bits:13);
	--keep addr.declared_range() == "[12:0]";
	mem_rw     : in simple_port of bit;
	data_out   : in simple_port of byte;
	alu_opcode : in simple_port of valid_opcodes;
	alu_a      : in simple_port of byte;
	alu_enable : in simple_port of bit;

	event main_clk;

	on main_clk {
		agent.chk.compare(addr$, mem_rw$, data_out$, alu_opcode$, alu_a$, alu_enable$);
	};
};
'>
