//fsm.cpp
#include "fsm.h"
void fsm::update_state()
{
	
	if (reset.read() == true)
		current_state = IDLE;
	else
		current_state = next_state;
}

void fsm::do_logic()
{
	sc_lv<6> func = id_ex_alu_function.read();
	sc_lv<6> opcode = id_ex_alu_opcode.read();
	
	switch(current_state) {
		case IDLE:
		{
		if(((func == FUNC_MULT) || (func == FUNC_MULTU)) && (opcode == OP_RFORMAT))
			{
				ready.write(false);
				hold_pipe.write(true);
				next_state = STAGE1;
				cout << " STARTING MULTIPLY" << endl;
			}  
			else  
			{		
				ready.write(false);
				hold_pipe.write(false);
				next_state = IDLE;
			}
		}
		break;

		case STAGE1:
		{   
		   #if(DEPTH_MULT_PIPE == 1)
			ready.write(true);
			hold_pipe.write(false);
			next_state = IDLE;
		   #else
			ready.write(false);
			hold_pipe.write(true);
			next_state = STAGE2;
		   #endif
		}
		break;
		
		case STAGE2:
		{
		   #if(DEPTH_MULT_PIPE == 2)
			ready.write(true);
			hold_pipe.write(false);
			next_state = IDLE;
		   #else
			ready.write(false);
			hold_pipe.write(true);
			next_state = STAGE3;
		   #endif
		}
		break;
		
		case STAGE3:
		{
		  #if(DEPTH_MULT_PIPE == 3)
			ready.write(true);
			hold_pipe.write(false);
			next_state = IDLE;
		   #else
			ready.write(false);
			hold_pipe.write(true);
			next_state = STAGE4;
		   #endif	
		}
		break;
		
		case STAGE4:
		{
		  #if(DEPTH_MULT_PIPE == 4)
			ready.write(true);
			hold_pipe.write(false);
			next_state = IDLE;
		   #else
			ready.write(false);
			hold_pipe.write(false);
			cout << " ERROR: PIPELINE DEPTH OUT OF RANGE" << endl;
			next_state = IDLE;
		   #endif	
		}
		break;
			
		default: 
		{
			ready.write(false);
			hold_pipe.write(false);
			next_state = IDLE;
		}
		break;
	}
} 
