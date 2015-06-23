<' 
import fsm_components.e;

unit fsm_bfm_u {
	reset_n    : out simple_port of bit;
	alu_result : out simple_port of byte;
	alu_status : out simple_port of byte;
	data_in    : out simple_port of byte;
	alu_x      : out simple_port of byte;
	alu_y      : out simple_port of byte;

	reset_needed : bool;
	keep reset_needed == TRUE;

	event done;
	event main_clk;

	mem : list of valid_opcodes;
	keep mem.size() == 8192;
	
	!i : uint(bits:13);
	keep i == 0;
	
	on main_clk {
		var data : fsm_input_s;
		var last_X : byte;
		var last_Y : byte;
		gen data;

		while (reset_needed) {
			gen data;
	
			if (data.reset_n == 0) {
				reset_needed = FALSE;
			};
		};

		reset_n$    = data.reset_n;
		alu_result$ = data.alu_result;
		alu_status$ = data.alu_status;
		data_in$    = mem[i].as_a(byte);
		data.data_in = mem[i].as_a(byte);
		alu_x$ = data.alu_x;
		alu_y$ = data.alu_y;
		
		if (data.reset_n == 1) {
			i = i + 1;
		}
		else {
			i = 0;
		};

		agent.chk.store(data);
		emit done;
	};
};
'>
