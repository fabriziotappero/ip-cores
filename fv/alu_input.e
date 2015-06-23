alu_input.e
<'
import alu_components.e;
type alu_input_t: [ENABLED_VALID, DISABLED_VALID, RESET, ENABLED_RAND, DISABLED_RAND];
type alu_test_type: [REGULAR, RAND]; 

struct alu_input_s {
	input_kind : alu_input_t;
	test_kind : alu_test_type;
	reset_n: bool;
	alu_enable: bool;
	alu_opcode: valid_opcodes;
	alu_a: byte;

	keep test_kind == REGULAR;
	
	when REGULAR'test_kind alu_input_s {
		keep soft input_kind == select {
			45: ENABLED_VALID;
			45: DISABLED_VALID;
			10: RESET;
		};
	};

	when ENABLED_VALID'input_kind alu_input_s {
		keep reset_n == TRUE; // remember this is active low 
		keep alu_enable == TRUE;
		keep alu_a in [0..255];
	};

	when DISABLED_VALID'input_kind alu_input_s {
		keep reset_n == TRUE; // remember this is active low 
		keep alu_enable == FALSE;
		keep alu_a in [0..255];
	};

	when RESET'input_kind alu_input_s {
		keep reset_n == FALSE; // remember this is active low 
		keep soft alu_enable == select {
			50: FALSE;
			50: TRUE;
		};
		keep alu_a in [0..255];
		//keep alu_opcode in [0..255];
	};

	event T1_cover_event;
	cover T1_cover_event is {
		item input_kind using no_collect=TRUE, ignore = (input_kind == ENABLED_RAND || input_kind == DISABLED_RAND);
		item alu_opcode using num_of_buckets=256, radix=HEX, no_collect=TRUE;
		cross input_kind, alu_opcode;
		//item alu_a;
	};
};


extend alu_input_s {
	rand_op : byte;

	when RAND'test_kind alu_input_s {
		keep soft input_kind == select {
			45: ENABLED_RAND;
			45: DISABLED_RAND;
			10: RESET;
		};
	};

	when ENABLED_RAND'input_kind alu_input_s {
		keep reset_n == TRUE; // remember this is active low 
		keep alu_enable == TRUE;
		keep alu_a in [0..255];
		keep rand_op in [0..255];
	};

	when DISABLED_RAND'input_kind alu_input_s {
		keep reset_n == TRUE; // remember this is active low 
		keep alu_enable == FALSE;
		keep alu_a in [0..255];
		keep rand_op in [0..255];
	};

	event T2_cover_event;
	cover T2_cover_event is {
		item alu_enable using no_collect=TRUE;
		item rand_op using num_of_buckets=256, radix=HEX, no_collect=TRUE;
		cross alu_enable, rand_op;
	};
};
'>

