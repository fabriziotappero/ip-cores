// Verilated -*- SystemC -*-
#ifndef _Valu_tb_alu_tb_H_
#define _Valu_tb_alu_tb_H_

#include "systemc.h"
#include "verilated.h"
#include "Valu_tb__Inlines.h"
class Valu_tb__Syms;

//----------


//*** Below code from `systemc in Verilog file
//#line 504 "alu_tb.v"

#include "verilog_sc.h"	
//*** Above code from `systemc in Verilog file

VL_MODULE(Valu_tb_alu_tb) {
  public:
    // CELLS
    
    // PORTS
    VL_IN8(systemc_clk,0,0);
    char	__VpadToAlign1[3];
    
    // LOCAL SIGNALS
    VL_SIG8(clk,0,0);
    VL_SIG8(finished,0,0);
    VL_SIG8(alu_inst0__DOT__reset,0,0);
    VL_SIG8(A,7,0);
    VL_SIG8(B,7,0);
    VL_SIG8(S,3,0);
    VL_SIG8(Y,7,0);
    VL_SIG8(CLR,0,0);
    VL_SIG8(C,0,0);
    VL_SIG8(V,0,0);
    VL_SIG8(Z,0,0);
    VL_SIG8(last_CLR,0,0);
    VL_SIG8(A_u,7,0);
    VL_SIG8(B_u,7,0);
    VL_SIG8(Y_u,7,0);
    VL_SIG8(started,0,0);
    VL_SIG8(cc,0,0);
    VL_SIG8(vv,0,0);
    VL_SIG8(zz,0,0);
    VL_SIG8(clrc,0,0);
    VL_SIG8(space,0,0);
    VL_SIG8(aa,7,0);
    VL_SIG8(bb,7,0);
    VL_SIG8(yy,7,0);
    VL_SIG8(random_mode,0,0);
    VL_SIG8(result,7,0);
    VL_SIG8(result_u,7,0);
    VL_SIG8(op1,7,0);
    VL_SIG8(op2,7,0);
    VL_SIG8(check_here,0,0);
    VL_SIG8(this_record__DOT__A,7,0);
    VL_SIG8(this_record__DOT__B,7,0);
    VL_SIG8(this_record__DOT__Y,7,0);
    VL_SIG8(this_record_reg__DOT__A,7,0);
    VL_SIG8(this_record_reg__DOT__B,7,0);
    VL_SIG8(this_record_reg__DOT__Y,7,0);
    VL_SIG8(next_record__DOT__A,7,0);
    VL_SIG8(next_record__DOT__B,7,0);
    VL_SIG8(next_record__DOT__Y,7,0);
    VL_SIG8(alu_inst0__DOT__A,7,0);
    VL_SIG8(alu_inst0__DOT__B,7,0);
    VL_SIG8(alu_inst0__DOT__S,3,0);
    VL_SIG8(alu_inst0__DOT__Y,7,0);
    VL_SIG8(alu_inst0__DOT__CLR,0,0);
    VL_SIG8(alu_inst0__DOT__CLK,0,0);
    VL_SIG8(alu_inst0__DOT__C,0,0);
    VL_SIG8(alu_inst0__DOT__V,0,0);
    VL_SIG8(alu_inst0__DOT__Z,0,0);
    VL_SIG8(alu_inst0__DOT__add_AB,0,0);
    VL_SIG8(alu_inst0__DOT__inc_A,0,0);
    VL_SIG8(alu_inst0__DOT__inc_B,0,0);
    VL_SIG8(alu_inst0__DOT__sub_AB,0,0);
    VL_SIG8(alu_inst0__DOT__cmp_AB,0,0);
    VL_SIG8(alu_inst0__DOT__sl_AB,0,0);
    VL_SIG8(alu_inst0__DOT__sr_AB,0,0);
    VL_SIG8(alu_inst0__DOT__clr_ALL,0,0);
    VL_SIG8(alu_inst0__DOT__dec_A,0,0);
    VL_SIG8(alu_inst0__DOT__dec_B,0,0);
    VL_SIG8(alu_inst0__DOT__mul_AB,0,0);
    VL_SIG8(alu_inst0__DOT__cpl_A,0,0);
    VL_SIG8(alu_inst0__DOT__and_AB,0,0);
    VL_SIG8(alu_inst0__DOT__or_AB,0,0);
    VL_SIG8(alu_inst0__DOT__xor_AB,0,0);
    VL_SIG8(alu_inst0__DOT__cpl_B,0,0);
    VL_SIG8(alu_inst0__DOT__clr_Z,0,0);
    VL_SIG8(alu_inst0__DOT__clr_V,0,0);
    VL_SIG8(alu_inst0__DOT__clr_C,0,0);
    VL_SIG8(alu_inst0__DOT__load_inputs,0,0);
    VL_SIG8(alu_inst0__DOT__load_outputs,0,0);
    VL_SIG8(alu_inst0__DOT__VERSION,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__add_AB,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__inc_A,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__inc_B,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__sub_AB,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__cmp_AB,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__sl_AB,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__sr_AB,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__clr,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__dec_A,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__dec_B,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__mul_AB,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__cpl_A,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__and_AB,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__or_AB,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__xor_AB,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__cpl_B,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__clr_Z,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__clr_V,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__clr_C,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__load_inputs,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__load_outputs,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__opcode,3,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__reset,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__clk,0,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__this_opcode,3,0);
    VL_SIG8(alu_inst0__DOT__controller__DOT__next_opcode,3,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__A,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__B,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__Y,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__add_AB,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__inc_A,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__inc_B,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__sub_AB,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__cmp_AB,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__sl_AB,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__sr_AB,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__clr,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__dec_A,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__dec_B,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__mul_AB,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__cpl_A,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__and_AB,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__or_AB,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__xor_AB,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__cpl_B,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__clr_Z,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__clr_V,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__clr_C,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__C,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__V,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__Z,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__load_inputs,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__load_outputs,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__reset,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__clk,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder_in_a,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder_in_b,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder_out,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__shifter_inA,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__shifter_inB,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__shifter_out,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__shifter_carry,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__shifter_direction,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__carry_in,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__carry,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adderORsel,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adderXORsel,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__AandB,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__AxorB,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__AorB,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__logic0,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__logic1,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__Areg,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__Breg,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__Yreg,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__Zreg,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__Creg,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__Vreg,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__alu_out,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder__DOT__x,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder__DOT__y,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder__DOT__carry_in,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder__DOT__ORsel,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder__DOT__XORsel,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder__DOT__xor_result,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder__DOT__or_result,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder__DOT__and_result,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder__DOT__z,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder__DOT__XandY,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__adder__DOT__XorY,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__shifter__DOT__x,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__shifter__DOT__y,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__shifter__DOT__z,7,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__shifter__DOT__c,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__shifter__DOT__clk,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__shifter__DOT__direction,0,0);
    VL_SIG8(alu_inst0__DOT__datapath__DOT__shifter__DOT__y_tmp,7,0);
    VL_SIG16(alu_inst0__DOT__datapath__DOT__carry_out,8,0);
    VL_SIG16(alu_inst0__DOT__datapath__DOT__adder__DOT__carry_out,8,0);
    VL_SIG(infile,31,0);
    VL_SIG(success,31,0);
    VL_SIG(outfile,31,0);
    VL_SIG(count,31,0);
    VL_SIG(ss,31,0);
    VL_SIG(last_ss,31,0);
    VL_SIG(random_count,31,0);
    VL_SIG(random_number,31,0);
    VL_SIG(errors_found,31,0);
    VL_SIG(this_record__DOT__S,31,0);
    VL_SIG(this_record_reg__DOT__S,31,0);
    VL_SIG(next_record__DOT__S,31,0);
    VL_SIG(alu_inst0__DOT__datapath__DOT__adder__DOT__i,31,0);
    VL_SIGW(alu_inst0__DOT__controller__DOT__opcode_sel,65537,0,2049);
    char	__VpadToAlign236[4];
    VL_SIG(opcode_list[16],32,1);
    
    // LOCAL VARIABLES
    VL_SIG8(__Vfunc_string2opcode__6__out,3,0);
    VL_SIG8(__Vfunc_string2opcode__6__opcode,3,0);
    VL_SIG8(__Vfunc_bas__7__out,7,0);
    VL_SIG8(__Vfunc_bas__7__a1,7,0);
    VL_SIG8(__Vfunc_bas__7__shift_size,7,0);
    VL_SIG8(__Vfunc_bas__7__direction,0,0);
    VL_SIG8(__Vfunc_bas__7__tmp,7,0);
    VL_SIG8(__Vfunc_bas__8__out,7,0);
    VL_SIG8(__Vfunc_bas__8__a1,7,0);
    VL_SIG8(__Vfunc_bas__8__shift_size,7,0);
    VL_SIG8(__Vfunc_bas__8__direction,0,0);
    VL_SIG8(__Vfunc_bas__8__tmp,7,0);
    VL_SIG8(__Vdly__this_record_reg__DOT__A,7,0);
    VL_SIG8(__Vdly__this_record_reg__DOT__B,7,0);
    VL_SIG8(__Vdly__this_record_reg__DOT__Y,7,0);
    VL_SIG8(__Vdly__this_record__DOT__A,7,0);
    VL_SIG8(__Vdly__this_record__DOT__B,7,0);
    char	__VpadToAlign325[3];
    VL_SIG(__Vfunc_randomit__0__out,31,0);
    VL_SIG(__Vfunc_randomit__1__out,31,0);
    VL_SIG(__Vfunc_randomit__2__out,31,0);
    VL_SIG(__Vfunc_get_random_opcode__3__out,32,1);
    VL_SIG(__Vfunc_get_random_opcode__3__tmp,31,0);
    VL_SIG(__Vfunc_randomit__4__out,31,0);
    VL_SIG(__Vfunc_randomit__5__out,31,0);
    VL_SIG(__Vfunc_string2opcode__6__s,31,0);
    VL_SIG(__Vfunc_bas__7__tmp2,31,0);
    VL_SIG(__Vfunc_bas__8__tmp2,31,0);
    VL_SIG(__Vdly__this_record_reg__DOT__S,31,0);
    VL_SIG(__Vdly__this_record__DOT__S,31,0);
    
    // INTERNAL VARIABLES
  private:
    char	__VpadToAlign380[4];
    Valu_tb__Syms*	__VlSymsp;		// Symbol table
  public:
    
    // PARAMETERS
    enum _IDataDWIDTH { DWIDTH = 8};
    enum _IDataOPWIDTH { OPWIDTH = 4};
    enum _IDatathis_record__DOT__DWIDTH { this_record__DOT__DWIDTH = 8};
    enum _IDatathis_record__DOT__OPWIDTH { this_record__DOT__OPWIDTH = 4};
    enum _IDatathis_record_reg__DOT__DWIDTH { this_record_reg__DOT__DWIDTH = 8};
    enum _IDatathis_record_reg__DOT__OPWIDTH { this_record_reg__DOT__OPWIDTH = 4};
    enum _IDatanext_record__DOT__DWIDTH { next_record__DOT__DWIDTH = 8};
    enum _IDatanext_record__DOT__OPWIDTH { next_record__DOT__OPWIDTH = 4};
    enum _IDataalu_inst0__DOT__DWIDTH { alu_inst0__DOT__DWIDTH = 8};
    enum _IDataalu_inst0__DOT__OPWIDTH { alu_inst0__DOT__OPWIDTH = 4};
    enum _IDataalu_inst0__DOT__controller__DOT__OPWIDTH { alu_inst0__DOT__controller__DOT__OPWIDTH = 4};
    enum _IDataalu_inst0__DOT__controller__DOT__OPBITS { alu_inst0__DOT__controller__DOT__OPBITS = 0x10};
    enum _IDataalu_inst0__DOT__datapath__DOT__ALU_WIDTH { alu_inst0__DOT__datapath__DOT__ALU_WIDTH = 8};
    enum _IDataalu_inst0__DOT__datapath__DOT__adder__DOT__ADDER_WIDTH { alu_inst0__DOT__datapath__DOT__adder__DOT__ADDER_WIDTH = 8};
    enum _IDataalu_inst0__DOT__datapath__DOT__shifter__DOT__DWIDTH { alu_inst0__DOT__datapath__DOT__shifter__DOT__DWIDTH = 8};
    
    // METHODS
  private:
    Valu_tb_alu_tb& operator= (const Valu_tb_alu_tb&);	///< Copying not allowed
    Valu_tb_alu_tb(const Valu_tb_alu_tb&);	///< Copying not allowed
  public:
    VL_CTOR(Valu_tb_alu_tb);
    ~Valu_tb_alu_tb();
    void	__Vconfigure(Valu_tb__Syms* symsp, bool first);
    
    //*** Below code from `systemc in Verilog file
//#line 506 "alu_tb.v"

   verilog_sc* vsc;	
    //*** Above code from `systemc in Verilog file
    
    
    // Sensitivity blocks
    static void	_combo__TOP__v__14(Valu_tb__Syms* __restrict vlSymsp);
    static void	_combo__TOP__v__17(Valu_tb__Syms* __restrict vlSymsp);
    static void	_combo__TOP__v__2(Valu_tb__Syms* __restrict vlSymsp);
    static void	_combo__TOP__v__4(Valu_tb__Syms* __restrict vlSymsp);
    static void	_combo__TOP__v__8(Valu_tb__Syms* __restrict vlSymsp);
    static void	_initial__TOP__v(Valu_tb__Syms* __restrict vlSymsp);
    static void	_sequent__TOP__v__10(Valu_tb__Syms* __restrict vlSymsp);
    static void	_sequent__TOP__v__11(Valu_tb__Syms* __restrict vlSymsp);
    static void	_sequent__TOP__v__12(Valu_tb__Syms* __restrict vlSymsp);
    static void	_sequent__TOP__v__15(Valu_tb__Syms* __restrict vlSymsp);
    void	_sequent__TOP__v__6(Valu_tb__Syms* __restrict vlSymsp);
    static void	_sequent__TOP__v__7(Valu_tb__Syms* __restrict vlSymsp);
    static void	_settle__TOP__v__1(Valu_tb__Syms* __restrict vlSymsp);
    static void	_settle__TOP__v__13(Valu_tb__Syms* __restrict vlSymsp);
    static void	_settle__TOP__v__16(Valu_tb__Syms* __restrict vlSymsp);
    static void	_settle__TOP__v__3(Valu_tb__Syms* __restrict vlSymsp);
    static void	_settle__TOP__v__5(Valu_tb__Syms* __restrict vlSymsp);
    static void	_settle__TOP__v__9(Valu_tb__Syms* __restrict vlSymsp);
} VL_ATTR_ALIGNED(64);

#endif  /*guard*/
