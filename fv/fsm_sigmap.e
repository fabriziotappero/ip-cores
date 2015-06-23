<'
unit fsm_signal_map_u {
	reset_n : out simple_port of bit is instance;
	keep bind(reset_n, external);
	keep reset_n.hdl_path() == "reset_n";

	alu_result : out simple_port of byte is instance;
	keep bind(alu_result, external);
	keep alu_result.hdl_path() == "alu_result";

	alu_status : out simple_port of byte is instance;
	keep bind(alu_status, external);
	keep alu_status.hdl_path() == "alu_status";

	data_in : out simple_port of byte is instance;
	keep bind(data_in, external);
	keep data_in.hdl_path() == "data_in";

	alu_x : out simple_port of byte is instance;
	keep bind(alu_x, external);
	keep alu_x.hdl_path() == "alu_x";

	alu_y : out simple_port of byte is instance;
	keep bind(alu_y, external);
	keep alu_y.hdl_path() == "alu_y";

	addr : in simple_port of uint(bits:13) is instance;
	keep bind(addr, external);
	keep addr.hdl_path() == "address";
	
	data_out : in simple_port of byte is instance;
	keep bind(data_out, external);
	keep data_out.hdl_path() == "data_out";
	
	alu_opcode : in simple_port of valid_opcodes is instance;
	keep bind(alu_opcode, external);
	keep alu_opcode.hdl_path() == "alu_opcode";

	alu_a : in simple_port of byte is instance;
	keep bind(alu_a, external);
	keep alu_a.hdl_path() == "alu_a";
	
	mem_rw : in simple_port of bit is instance;
	keep bind(mem_rw, external);
	keep mem_rw.hdl_path() == "mem_rw";

	alu_enable : in simple_port of bit is instance;
	keep bind(alu_enable, external);
	keep alu_enable.hdl_path() == "alu_enable";
};
'>
