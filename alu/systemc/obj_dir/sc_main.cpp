  #include "scv.h"
  #include "Valu_tb.h"
  #include "Valu_tb_alu_tb.h"
  int sc_main(int argc, char **argv) {
     
     sc_clock clk ("clk",10, 0.5, 3, true);
     sc_uint<16> anint;
     scv_smart_ptr<int> aptr ("aptr");
     aptr->keep_only(0, ((1<<16)-1));
     aptr->next();
     Valu_tb* top;
     top = new Valu_tb("top");   // SP_CELL (top, Vour);
     cout << "anint = " << anint<<endl;          
     cout << "A=" << top->v->A << endl;
     cout << "Aptr=" << *aptr << endl;
     top->systemc_clk(clk);  
              
  // Create trace file
  sc_trace_file *tf = sc_create_vcd_trace_file("tracefile");
  // Trace signals
  sc_trace(tf, top->systemc_clk, "top_systemc_clk");
  sc_trace(tf, top->v->A, "top_v_A");
  sc_trace(tf, top->v->B, "top_v_B");
  sc_trace(tf, top->v->Y, "top_v_Y");
  sc_trace(tf, top->v->S, "top_v_S");
  sc_trace(tf, top->v->clk, "top_v_clk");
  sc_trace(tf, top->v->C, "top_v_C");
  sc_trace(tf, top->v->V, "top_v_V");
  sc_trace(tf, top->v->Z, "top_v_Z");

     while (!Verilated::gotFinish()) { sc_start(1, SC_NS); }
     exit(0);
  }
