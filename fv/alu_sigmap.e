alu_sig_map.e;
<'
unit alu_signal_map_u {
	reset_n : out simple_port of bool is instance;
	keep bind(reset_n, external);
	keep reset_n.hdl_path() == "reset_n";

	alu_enable : out simple_port of bool is instance;
	keep bind(alu_enable, external);
	keep alu_enable.hdl_path() == "alu_enable";

	alu_opcode : out simple_port of byte is instance;
	keep bind(alu_opcode, external);
	keep alu_opcode.hdl_path() == "alu_opcode";

	alu_a : out simple_port of byte is instance;
	keep bind(alu_a, external);
	keep alu_a.hdl_path() == "alu_a";

	alu_result : in simple_port of byte is instance;
	keep bind(alu_result, external);
	keep alu_result.hdl_path() == "alu_result";

	alu_status : in simple_port of byte is instance;
	keep bind(alu_status, external);
	keep alu_status.hdl_path() == "alu_status";

	alu_x : in simple_port of byte is instance;
	keep bind(alu_x, external);
	keep alu_x.hdl_path() == "alu_x";

	alu_y : in simple_port of byte is instance;
	keep bind(alu_y, external);
	keep alu_y.hdl_path() == "alu_y";
};
'>
