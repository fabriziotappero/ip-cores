// Verilated -*- SystemC -*-
#include "Valu_tb.h"           // For This
#include "Valu_tb__Syms.h"

//--------------------
// STATIC VARIABLES


//--------------------

VL_SC_CTOR_IMP(Valu_tb)
#if (SYSTEMC_VERSION>20011000)
    : systemc_clk("systemc_clk")
#endif
 {
    Valu_tb__Syms* __restrict vlSymsp = __VlSymsp = new Valu_tb__Syms(this, name());
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    VL_CELL (v, Valu_tb_alu_tb);
    // Sensitivities on all clocks and combo inputs
    SC_METHOD(eval);
    sensitive << systemc_clk;
    
    // Reset internal values
    
    // Reset structure values
    __Vcellinp__v__systemc_clk = VL_RAND_RESET_I(1);
    __VinpClk__TOP__v__clk = VL_RAND_RESET_I(1);
    __VinpClk__TOP__v__alu_inst0__DOT__reset = VL_RAND_RESET_I(1);
    __VinpClk__TOP__v__finished = VL_RAND_RESET_I(1);
    __Vclklast__TOP____VinpClk__TOP__v__clk = VL_RAND_RESET_I(1);
    __Vclklast__TOP____VinpClk__TOP__v__alu_inst0__DOT__reset = VL_RAND_RESET_I(1);
    __Vclklast__TOP____VinpClk__TOP__v__finished = VL_RAND_RESET_I(1);
    __Vchglast__TOP__v__clk = VL_RAND_RESET_I(1);
    __Vchglast__TOP__v__finished = VL_RAND_RESET_I(1);
    __Vchglast__TOP__v__alu_inst0__DOT__reset = VL_RAND_RESET_I(1);
    __Vchglast__TOP__v__alu_inst0__DOT__datapath__DOT__adder_in_b = VL_RAND_RESET_I(8);
    __Vchglast__TOP__v__alu_inst0__DOT__datapath__DOT__carry = VL_RAND_RESET_I(1);
}

void Valu_tb::__Vconfigure(Valu_tb__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

Valu_tb::~Valu_tb() {
    delete __VlSymsp; __VlSymsp=NULL;
}

//--------------------


void Valu_tb::eval() {
    Valu_tb__Syms* __restrict vlSymsp = this->__VlSymsp; // Setup global symbol table
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    VL_DEBUG_IF(cout<<"\n----TOP Evaluate Valu_tb::eval"<<endl; );
    int __VclockLoop = 0;
    IData __Vchange=1;
    while (VL_LIKELY(__Vchange)) {
	VL_DEBUG_IF(cout<<" Clock loop"<<endl;);
	vlSymsp->__Vm_activity = true;
	_eval(vlSymsp);
	__Vchange = _change_request(vlSymsp);
	if (++__VclockLoop > 100) vl_fatal(__FILE__,__LINE__,__FILE__,"Verilated model didn't converge");
    }
}

void Valu_tb::_eval_initial_loop(Valu_tb__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    vlSymsp->__Vm_activity = true;
    int __VclockLoop = 0;
    IData __Vchange=1;
    while (VL_LIKELY(__Vchange)) {
	_eval_settle(vlSymsp);
	_eval(vlSymsp);
	__Vchange = _change_request(vlSymsp);
	if (++__VclockLoop > 100) vl_fatal(__FILE__,__LINE__,__FILE__,"Verilated model didn't DC converge");
    }
}

//--------------------
// Internal Methods

void Valu_tb::_settle__TOP__1(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"    Valu_tb::_settle__TOP__1"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    VL_ASSIGN_IS(1,vlTOPp->__Vcellinp__v__systemc_clk, vlTOPp->systemc_clk);
}

void Valu_tb::_combo__TOP__2(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"    Valu_tb::_combo__TOP__2"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    VL_ASSIGN_IS(1,vlTOPp->__Vcellinp__v__systemc_clk, vlTOPp->systemc_clk);
    vlSymsp->TOP__v.systemc_clk = vlTOPp->__Vcellinp__v__systemc_clk;
}

void Valu_tb::_settle__TOP__3(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"    Valu_tb::_settle__TOP__3"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.systemc_clk = vlTOPp->__Vcellinp__v__systemc_clk;
}

void Valu_tb::_eval(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"    Valu_tb::_eval"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v._combo__TOP__v__2(vlSymsp);
    vlTOPp->_combo__TOP__2(vlSymsp);
    vlSymsp->TOP__v._combo__TOP__v__4(vlSymsp);
    if (((~ (IData)(vlTOPp->__VinpClk__TOP__v__clk)) 
	 & (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__v__clk))) {
	vlSymsp->TOP__v._sequent__TOP__v__6(vlSymsp);
    }
    if ((((IData)(vlTOPp->__VinpClk__TOP__v__alu_inst0__DOT__reset) 
	  & (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__v__alu_inst0__DOT__reset))) 
	 | ((IData)(vlTOPp->__VinpClk__TOP__v__clk) 
	    & (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__v__clk))))) {
	vlSymsp->TOP__v._sequent__TOP__v__7(vlSymsp);
    }
    vlSymsp->TOP__v._combo__TOP__v__8(vlSymsp);
    if ((((IData)(vlTOPp->__VinpClk__TOP__v__clk) & 
	  (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__v__clk))) 
	 | ((IData)(vlTOPp->__VinpClk__TOP__v__finished) 
	    & (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__v__finished))))) {
	vlSymsp->TOP__v._sequent__TOP__v__10(vlSymsp);
    }
    if (((~ (IData)(vlTOPp->__VinpClk__TOP__v__clk)) 
	 & (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__v__clk))) {
	vlSymsp->TOP__v._sequent__TOP__v__11(vlSymsp);
    }
    if ((((IData)(vlTOPp->__VinpClk__TOP__v__alu_inst0__DOT__reset) 
	  & (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__v__alu_inst0__DOT__reset))) 
	 | ((IData)(vlTOPp->__VinpClk__TOP__v__clk) 
	    & (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__v__clk))))) {
	vlSymsp->TOP__v._sequent__TOP__v__12(vlSymsp);
    }
    vlSymsp->TOP__v._combo__TOP__v__14(vlSymsp);
    if ((((IData)(vlTOPp->__VinpClk__TOP__v__alu_inst0__DOT__reset) 
	  & (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__v__alu_inst0__DOT__reset))) 
	 | ((IData)(vlTOPp->__VinpClk__TOP__v__clk) 
	    & (~ (IData)(vlTOPp->__Vclklast__TOP____VinpClk__TOP__v__clk))))) {
	vlSymsp->TOP__v._sequent__TOP__v__15(vlSymsp);
    }
    vlSymsp->TOP__v._combo__TOP__v__17(vlSymsp);
    // Final
    vlTOPp->__Vclklast__TOP____VinpClk__TOP__v__clk 
	= vlTOPp->__VinpClk__TOP__v__clk;
    vlTOPp->__Vclklast__TOP____VinpClk__TOP__v__alu_inst0__DOT__reset 
	= vlTOPp->__VinpClk__TOP__v__alu_inst0__DOT__reset;
    vlTOPp->__Vclklast__TOP____VinpClk__TOP__v__finished 
	= vlTOPp->__VinpClk__TOP__v__finished;
    vlTOPp->__VinpClk__TOP__v__clk = vlSymsp->TOP__v.clk;
    vlTOPp->__VinpClk__TOP__v__alu_inst0__DOT__reset 
	= vlSymsp->TOP__v.alu_inst0__DOT__reset;
    vlTOPp->__VinpClk__TOP__v__finished = vlSymsp->TOP__v.finished;
}

void Valu_tb::_eval_initial(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"    Valu_tb::_eval_initial"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v._initial__TOP__v(vlSymsp);
}

void Valu_tb::final() {
    VL_DEBUG_IF(cout<<"    Valu_tb::final"<<endl; );
    // Variables
    Valu_tb__Syms* __restrict vlSymsp = this->__VlSymsp;
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Valu_tb::_eval_settle(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"    Valu_tb::_eval_settle"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v._settle__TOP__v__1(vlSymsp);
    vlTOPp->_settle__TOP__1(vlSymsp);
    vlTOPp->_settle__TOP__3(vlSymsp);
    vlSymsp->TOP__v._settle__TOP__v__3(vlSymsp);
    vlSymsp->TOP__v._settle__TOP__v__5(vlSymsp);
    vlSymsp->TOP__v._settle__TOP__v__9(vlSymsp);
    vlSymsp->TOP__v._settle__TOP__v__13(vlSymsp);
    vlSymsp->TOP__v._settle__TOP__v__16(vlSymsp);
}

bool Valu_tb::_change_request(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"    Valu_tb::_change_request"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    IData __req = false;  // Logically a bool
    __req |= ((vlSymsp->TOP__v.clk ^ vlTOPp->__Vchglast__TOP__v__clk)
	 | (vlSymsp->TOP__v.finished ^ vlTOPp->__Vchglast__TOP__v__finished)
	 | (vlSymsp->TOP__v.alu_inst0__DOT__reset ^ vlTOPp->__Vchglast__TOP__v__alu_inst0__DOT__reset)
	 | (vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b ^ vlTOPp->__Vchglast__TOP__v__alu_inst0__DOT__datapath__DOT__adder_in_b)
	 | (vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry ^ vlTOPp->__Vchglast__TOP__v__alu_inst0__DOT__datapath__DOT__carry));
    VL_DEBUG_IF( if(__req && ((vlSymsp->TOP__v.clk ^ vlTOPp->__Vchglast__TOP__v__clk))) cout<<"	CHANGE: alu_tb.v:59: clk"<<endl; );
    VL_DEBUG_IF( if(__req && ((vlSymsp->TOP__v.finished ^ vlTOPp->__Vchglast__TOP__v__finished))) cout<<"	CHANGE: alu_tb.v:81: finished"<<endl; );
    VL_DEBUG_IF( if(__req && ((vlSymsp->TOP__v.alu_inst0__DOT__reset ^ vlTOPp->__Vchglast__TOP__v__alu_inst0__DOT__reset))) cout<<"	CHANGE: /home/leonous/projects/verilog/ecpu/components/alu/rtl/verilog/alu.v:40: alu_inst0.reset"<<endl; );
    VL_DEBUG_IF( if(__req && ((vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b ^ vlTOPp->__Vchglast__TOP__v__alu_inst0__DOT__datapath__DOT__adder_in_b))) cout<<"	CHANGE: /home/leonous/projects/verilog/ecpu/components/alu/rtl/verilog/alu_datapath.v:80: alu_inst0.datapath.adder_in_b"<<endl; );
    VL_DEBUG_IF( if(__req && ((vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry ^ vlTOPp->__Vchglast__TOP__v__alu_inst0__DOT__datapath__DOT__carry))) cout<<"	CHANGE: /home/leonous/projects/verilog/ecpu/components/alu/rtl/verilog/alu_datapath.v:91: alu_inst0.datapath.carry"<<endl; );
    // Final
    vlTOPp->__Vchglast__TOP__v__clk = vlSymsp->TOP__v.clk;
    vlTOPp->__Vchglast__TOP__v__finished = vlSymsp->TOP__v.finished;
    vlTOPp->__Vchglast__TOP__v__alu_inst0__DOT__reset 
	= vlSymsp->TOP__v.alu_inst0__DOT__reset;
    vlTOPp->__Vchglast__TOP__v__alu_inst0__DOT__datapath__DOT__adder_in_b 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b;
    vlTOPp->__Vchglast__TOP__v__alu_inst0__DOT__datapath__DOT__carry 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry;
    return __req;
}
