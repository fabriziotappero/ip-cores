// stmach_k.cpp 
#include "stmach.h" 
void stmach_k::getnextst() 
{ 
  play.write(false); 
  recrd.write(false); 
  erase.write(false); 
  save.write(false); 
  address.write(false); 
  switch (current_state.read()) { 
    case main_st: 
      if (key.read() == 1) { 
	next_state.write(review_st); 
      } else { 
	if (key.read() == 2) { 
	  next_state.write(send_st); 
	} else { 
	  next_state.write(main_st); 
	} 
      } 
      break;
   
    case record_st: 
      if (key.read() == 5) { 
	next_state.write(begin_rec_st); 
      } else { 
	next_state.write(record_st); 
      } 
      break;
   
    case begin_rec_st: 
      //comment over here
      recrd.write(true);
      next_state.write(message_st); 
      break;
   
    case message_st: //comment over here
      recrd.write(true); 
      if (key.read() == 6) { 
	next_state.write(send_st); 
      } else { 
	next_state.write(message_st); 
      } 
      break;

    default:
      next_state.write(main_st);
      break;
  } // end switch 
} // end method 

void stmach::setstate() 
{ 
  current_state.write(next_state); 
}
