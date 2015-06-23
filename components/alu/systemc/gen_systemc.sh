cat <<EOF >sc_main.cpp
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

     while (!Verilated::gotFinish()) { sc_start(1, SC_NS); }
     exit(0);
  }
EOF
cat <<EOF >verilog_sc.h
#include <cstdlib>
class verilog_sc {
public:
    // CONSTRUCTORS
    verilog_sc() {}
    ~verilog_sc() {}
    // METHODS
    // This function will be called from a instance created in Verilog
    inline uint32_t randomit() {
     return random() % (1 << 16);
    }
};
EOF

EXTRA_OPTS=$*

 verilator -sc \
-I$ALU_RTL \
-I/usr/local/scv/include \
-I/usr/local/scv/lib-linux \
-y $ALU_COMPONENTS/adder \
-v $ALU_COMPONENTS/barrel_shifter/simple/barrel_shifter_simple.temp.v \
-y $ALU_RTL \
-Wno-COMBDLY \
-Wno-UNOPTFLAT \
-Wno-WIDTH \
-Wno-STMTDLY \
$EXTRA_OPTS \
./alu_tb.v  \
--public \
--exe \
sc_main.cpp &> log
mv sc_main.cpp verilog_sc.h obj_dir/.
