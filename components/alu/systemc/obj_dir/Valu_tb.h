// Verilated -*- SystemC -*-
#ifndef _Valu_tb_H_
#define _Valu_tb_H_

#include "systemc.h"
#include "verilated.h"
#include "Valu_tb__Inlines.h"
class Valu_tb__Syms;
class Valu_tb_alu_tb;

//----------

SC_MODULE(Valu_tb) {
  public:
    // CELLS
    Valu_tb_alu_tb*    	v;
    
    // PORTS
    sc_in<bool>	systemc_clk;
    
    // LOCAL SIGNALS
    
    // LOCAL VARIABLES
    VL_SIG8(__Vcellinp__v__systemc_clk,0,0);
    VL_SIG8(__VinpClk__TOP__v__clk,0,0);
    VL_SIG8(__VinpClk__TOP__v__alu_inst0__DOT__reset,0,0);
    VL_SIG8(__VinpClk__TOP__v__finished,0,0);
    VL_SIG8(__Vclklast__TOP____VinpClk__TOP__v__clk,0,0);
    VL_SIG8(__Vclklast__TOP____VinpClk__TOP__v__alu_inst0__DOT__reset,0,0);
    VL_SIG8(__Vclklast__TOP____VinpClk__TOP__v__finished,0,0);
    VL_SIG8(__Vchglast__TOP__v__clk,0,0);
    VL_SIG8(__Vchglast__TOP__v__finished,0,0);
    VL_SIG8(__Vchglast__TOP__v__alu_inst0__DOT__reset,0,0);
    VL_SIG8(__Vchglast__TOP__v__alu_inst0__DOT__datapath__DOT__adder_in_b,7,0);
    VL_SIG8(__Vchglast__TOP__v__alu_inst0__DOT__datapath__DOT__carry,0,0);
    
    // INTERNAL VARIABLES
    char	__VpadToAlign28[4];
    Valu_tb__Syms*	__VlSymsp;		// Symbol table
    
    // PARAMETERS
    
    // METHODS
  private:
    Valu_tb& operator= (const Valu_tb&);	///< Copying not allowed
    Valu_tb(const Valu_tb&);	///< Copying not allowed
  public:
    SC_CTOR(Valu_tb);
    virtual ~Valu_tb();
    void	__Vconfigure(Valu_tb__Syms* symsp, bool first);
    
    // Sensitivity blocks
    void	final();	///< Function to call when simulation completed
  private:
    void	eval();	///< Main function to call from calling app when inputs change
    static void _eval_initial_loop(Valu_tb__Syms* __restrict vlSymsp);
    static bool	_change_request(Valu_tb__Syms* __restrict vlSymsp);
  public:
    static void	_combo__TOP__2(Valu_tb__Syms* __restrict vlSymsp);
    static void	_eval(Valu_tb__Syms* __restrict vlSymsp);
    static void	_eval_initial(Valu_tb__Syms* __restrict vlSymsp);
    static void	_eval_settle(Valu_tb__Syms* __restrict vlSymsp);
    static void	_settle__TOP__1(Valu_tb__Syms* __restrict vlSymsp);
    static void	_settle__TOP__3(Valu_tb__Syms* __restrict vlSymsp);
} VL_ATTR_ALIGNED(64);

#endif  /*guard*/
