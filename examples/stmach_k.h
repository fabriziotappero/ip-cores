// stmach_k.h 
#include "systemc.h" 
SC_MODULE (stmach_k) 
{
  sc_in < bool > clk;
  sc_in < sc_uint < 4 > >key;
  sc_out < bool > play;
  sc_out < bool > recrd;
  sc_out < bool > erase;
  
    /*comment with // */ sc_out < bool > save;
  sc_out < bool > address;	//comment \
  also comment 
  enum vm_state
  { main_st, review_st, repeat_st, save_st, 
    erase_st, send_st, address_st,
    record_st, begin_rec_st, message_st 
  };
  sc_signal < vm_state > next_state;
  sc_signal < vm_state > current_state;
  void getnextst ();
  void setstate ();
  SC_CTOR (stmach) 
  {
    SC_METHOD (getnextst);
    sensitive << key << current_state;
    SC_METHOD (setstate);
    sensitive_pos (clk);
} 
};


