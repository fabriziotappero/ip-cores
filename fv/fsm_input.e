<'
import fsm_components.e;
type fsm_input_t  : [ RESET, INSTRUCTIONS ];
			
struct fsm_input_s {
	input_kind : fsm_input_t;
	reset_n    : bit;
	alu_result : byte;
	alu_status : byte;
	data_in    : byte;
	alu_x      : byte;
	alu_y      : byte;

	keep soft input_kind == select {
			99: INSTRUCTIONS;
			1 : RESET;
		};	
	
	when RESET'input_kind fsm_input_s {
		keep reset_n == 0;
	};
	
	when INSTRUCTIONS'input_kind fsm_input_s {
		keep reset_n == 1;
	};
	
--	event T1_cover_event;
--	cover T1_cover_event is {
--		item input_kind using no_collect=TRUE, ignore = (input_kind == ENABLED_RAND || input_kind == DISABLED_RAND);
--		item alu_opcode using num_of_buckets=256, radix=HEX, no_collect=TRUE;
--		cross input_kind, alu_opcode;
--		//item alu_a;
--	};
};

'>
