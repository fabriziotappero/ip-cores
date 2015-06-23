#include "flag_interr.h"

void flag_interr::do_fsm_ctrl()
{
	switch(current_state) {
		
		case Idle:
		{
			if(interrupt_in.read() == true)
			{
				next_state = State1;
				interrupt_out = false;
			}
			else  
			{
				next_state = Idle;
				interrupt_out = false;
			}
		}
		break;
		
		case State1://STAGE1
		{
			next_state = Idle;
			interrupt_out = true;
		
		}
		break;
		
		
		
			
		default: 
		{
			next_state = Idle;
			interrupt_out = false;
		}
		break;
	}
} 

void flag_interr::do_fsm_update()
{
	if(reset.read() == true)
	{
		current_state = Idle;
		next_state = Idle;
	}
	else 
		current_state = next_state;
}
