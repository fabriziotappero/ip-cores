// Verilated -*- SystemC -*-
#include "Valu_tb_alu_tb.h"    // For This
#include "Valu_tb__Syms.h"

//--------------------
// STATIC VARIABLES


//--------------------

VL_CTOR_IMP(Valu_tb_alu_tb) {
    // Reset internal values
    // Reset structure values
    systemc_clk = VL_RAND_RESET_I(1);
    clk = VL_RAND_RESET_I(1);
    A = VL_RAND_RESET_I(8);
    B = VL_RAND_RESET_I(8);
    S = VL_RAND_RESET_I(4);
    Y = VL_RAND_RESET_I(8);
    CLR = VL_RAND_RESET_I(1);
    C = VL_RAND_RESET_I(1);
    V = VL_RAND_RESET_I(1);
    Z = VL_RAND_RESET_I(1);
    last_CLR = VL_RAND_RESET_I(1);
    A_u = VL_RAND_RESET_I(8);
    B_u = VL_RAND_RESET_I(8);
    Y_u = VL_RAND_RESET_I(8);
    finished = VL_RAND_RESET_I(1);
    started = VL_RAND_RESET_I(1);
    infile = VL_RAND_RESET_I(32);
    success = VL_RAND_RESET_I(32);
    outfile = VL_RAND_RESET_I(32);
    count = VL_RAND_RESET_I(32);
    cc = VL_RAND_RESET_I(1);
    vv = VL_RAND_RESET_I(1);
    zz = VL_RAND_RESET_I(1);
    clrc = VL_RAND_RESET_I(1);
    space = VL_RAND_RESET_I(1);
    aa = VL_RAND_RESET_I(8);
    bb = VL_RAND_RESET_I(8);
    yy = VL_RAND_RESET_I(8);
    ss = VL_RAND_RESET_I(32);
    last_ss = VL_RAND_RESET_I(32);
    random_mode = VL_RAND_RESET_I(1);
    random_count = VL_RAND_RESET_I(32);
    random_number = VL_RAND_RESET_I(32);
    errors_found = VL_RAND_RESET_I(32);
    { int __Vi0=0; for (; __Vi0<16; ++__Vi0) {
	    opcode_list[__Vi0] = VL_RAND_RESET_I(32);
    }}
    result = VL_RAND_RESET_I(8);
    result_u = VL_RAND_RESET_I(8);
    op1 = VL_RAND_RESET_I(8);
    op2 = VL_RAND_RESET_I(8);
    check_here = VL_RAND_RESET_I(1);
    this_record__DOT__A = VL_RAND_RESET_I(8);
    this_record__DOT__B = VL_RAND_RESET_I(8);
    this_record__DOT__S = VL_RAND_RESET_I(32);
    this_record__DOT__Y = VL_RAND_RESET_I(8);
    this_record_reg__DOT__A = VL_RAND_RESET_I(8);
    this_record_reg__DOT__B = VL_RAND_RESET_I(8);
    this_record_reg__DOT__S = VL_RAND_RESET_I(32);
    this_record_reg__DOT__Y = VL_RAND_RESET_I(8);
    next_record__DOT__A = VL_RAND_RESET_I(8);
    next_record__DOT__B = VL_RAND_RESET_I(8);
    next_record__DOT__S = VL_RAND_RESET_I(32);
    next_record__DOT__Y = VL_RAND_RESET_I(8);
    alu_inst0__DOT__A = VL_RAND_RESET_I(8);
    alu_inst0__DOT__B = VL_RAND_RESET_I(8);
    alu_inst0__DOT__S = VL_RAND_RESET_I(4);
    alu_inst0__DOT__Y = VL_RAND_RESET_I(8);
    alu_inst0__DOT__CLR = VL_RAND_RESET_I(1);
    alu_inst0__DOT__CLK = VL_RAND_RESET_I(1);
    alu_inst0__DOT__C = VL_RAND_RESET_I(1);
    alu_inst0__DOT__V = VL_RAND_RESET_I(1);
    alu_inst0__DOT__Z = VL_RAND_RESET_I(1);
    alu_inst0__DOT__add_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__inc_A = VL_RAND_RESET_I(1);
    alu_inst0__DOT__inc_B = VL_RAND_RESET_I(1);
    alu_inst0__DOT__sub_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__cmp_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__sl_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__sr_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__clr_ALL = VL_RAND_RESET_I(1);
    alu_inst0__DOT__dec_A = VL_RAND_RESET_I(1);
    alu_inst0__DOT__dec_B = VL_RAND_RESET_I(1);
    alu_inst0__DOT__mul_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__cpl_A = VL_RAND_RESET_I(1);
    alu_inst0__DOT__and_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__or_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__xor_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__cpl_B = VL_RAND_RESET_I(1);
    alu_inst0__DOT__clr_Z = VL_RAND_RESET_I(1);
    alu_inst0__DOT__clr_V = VL_RAND_RESET_I(1);
    alu_inst0__DOT__clr_C = VL_RAND_RESET_I(1);
    alu_inst0__DOT__reset = VL_RAND_RESET_I(1);
    alu_inst0__DOT__load_inputs = VL_RAND_RESET_I(1);
    alu_inst0__DOT__load_outputs = VL_RAND_RESET_I(1);
    alu_inst0__DOT__VERSION = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__add_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__inc_A = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__inc_B = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__sub_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__cmp_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__sl_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__sr_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__clr = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__dec_A = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__dec_B = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__mul_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__cpl_A = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__and_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__or_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__xor_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__cpl_B = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__clr_Z = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__clr_V = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__clr_C = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__load_inputs = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__load_outputs = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__opcode = VL_RAND_RESET_I(4);
    alu_inst0__DOT__controller__DOT__reset = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__clk = VL_RAND_RESET_I(1);
    alu_inst0__DOT__controller__DOT__this_opcode = VL_RAND_RESET_I(4);
    alu_inst0__DOT__controller__DOT__next_opcode = VL_RAND_RESET_I(4);
    VL_RAND_RESET_W(65538,alu_inst0__DOT__controller__DOT__opcode_sel);
    alu_inst0__DOT__datapath__DOT__A = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__B = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__Y = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__add_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__inc_A = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__inc_B = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__sub_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__cmp_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__sl_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__sr_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__clr = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__dec_A = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__dec_B = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__mul_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__cpl_A = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__and_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__or_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__xor_AB = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__cpl_B = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__clr_Z = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__clr_V = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__clr_C = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__C = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__V = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__Z = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__load_inputs = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__load_outputs = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__reset = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__clk = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__adder_in_a = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__adder_in_b = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__adder_out = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__shifter_inA = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__shifter_inB = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__shifter_out = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__shifter_carry = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__shifter_direction = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__carry_in = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__carry = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__adderORsel = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__adderXORsel = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__carry_out = VL_RAND_RESET_I(9);
    alu_inst0__DOT__datapath__DOT__AandB = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__AxorB = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__AorB = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__logic0 = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__logic1 = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__Areg = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__Breg = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__Yreg = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__Zreg = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__Creg = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__Vreg = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__alu_out = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__adder__DOT__x = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__adder__DOT__y = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__adder__DOT__carry_in = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__adder__DOT__ORsel = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__adder__DOT__XORsel = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__adder__DOT__xor_result = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__adder__DOT__or_result = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__adder__DOT__and_result = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__adder__DOT__carry_out = VL_RAND_RESET_I(9);
    alu_inst0__DOT__datapath__DOT__adder__DOT__z = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__adder__DOT__XandY = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__adder__DOT__XorY = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__adder__DOT__i = VL_RAND_RESET_I(32);
    alu_inst0__DOT__datapath__DOT__shifter__DOT__x = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__shifter__DOT__y = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__shifter__DOT__z = VL_RAND_RESET_I(8);
    alu_inst0__DOT__datapath__DOT__shifter__DOT__c = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__shifter__DOT__clk = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__shifter__DOT__direction = VL_RAND_RESET_I(1);
    alu_inst0__DOT__datapath__DOT__shifter__DOT__y_tmp = VL_RAND_RESET_I(8);
    __Vfunc_randomit__0__out = VL_RAND_RESET_I(32);
    __Vfunc_randomit__1__out = VL_RAND_RESET_I(32);
    __Vfunc_randomit__2__out = VL_RAND_RESET_I(32);
    __Vfunc_get_random_opcode__3__out = VL_RAND_RESET_I(32);
    __Vfunc_get_random_opcode__3__tmp = VL_RAND_RESET_I(32);
    __Vfunc_randomit__4__out = VL_RAND_RESET_I(32);
    __Vfunc_randomit__5__out = VL_RAND_RESET_I(32);
    __Vfunc_string2opcode__6__out = VL_RAND_RESET_I(4);
    __Vfunc_string2opcode__6__s = VL_RAND_RESET_I(32);
    __Vfunc_string2opcode__6__opcode = VL_RAND_RESET_I(4);
    __Vfunc_bas__7__out = VL_RAND_RESET_I(8);
    __Vfunc_bas__7__a1 = VL_RAND_RESET_I(8);
    __Vfunc_bas__7__shift_size = VL_RAND_RESET_I(8);
    __Vfunc_bas__7__direction = VL_RAND_RESET_I(1);
    __Vfunc_bas__7__tmp = VL_RAND_RESET_I(8);
    __Vfunc_bas__7__tmp2 = VL_RAND_RESET_I(32);
    __Vfunc_bas__8__out = VL_RAND_RESET_I(8);
    __Vfunc_bas__8__a1 = VL_RAND_RESET_I(8);
    __Vfunc_bas__8__shift_size = VL_RAND_RESET_I(8);
    __Vfunc_bas__8__direction = VL_RAND_RESET_I(1);
    __Vfunc_bas__8__tmp = VL_RAND_RESET_I(8);
    __Vfunc_bas__8__tmp2 = VL_RAND_RESET_I(32);
    __Vdly__this_record_reg__DOT__A = VL_RAND_RESET_I(8);
    __Vdly__this_record_reg__DOT__B = VL_RAND_RESET_I(8);
    __Vdly__this_record_reg__DOT__S = VL_RAND_RESET_I(32);
    __Vdly__this_record_reg__DOT__Y = VL_RAND_RESET_I(8);
    __Vdly__this_record__DOT__A = VL_RAND_RESET_I(8);
    __Vdly__this_record__DOT__B = VL_RAND_RESET_I(8);
    __Vdly__this_record__DOT__S = VL_RAND_RESET_I(32);
    
    //*** Below code from `systemc in Verilog file
//#line 508 "alu_tb.v"

   vsc = new verilog_sc();	
    //*** Above code from `systemc in Verilog file
    
}

void Valu_tb_alu_tb::__Vconfigure(Valu_tb__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

Valu_tb_alu_tb::~Valu_tb_alu_tb() {
    
    //*** Below code from `systemc in Verilog file
//#line 510 "alu_tb.v"

   delete vsc;	
    //*** Above code from `systemc in Verilog file
    
}

//--------------------
// Internal Methods

void Valu_tb_alu_tb::_initial__TOP__v(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_initial__TOP__v"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // INITIAL at alu_tb.v:107
    vlSymsp->TOP__v.opcode_list[0] = 0x616464;
    vlSymsp->TOP__v.opcode_list[1] = 0x696e6361;
    vlSymsp->TOP__v.opcode_list[9] = 0x696e6362;
    vlSymsp->TOP__v.opcode_list[2] = 0x737562;
    vlSymsp->TOP__v.opcode_list[3] = 0x636d70;
    vlSymsp->TOP__v.opcode_list[4] = 0x61736c;
    vlSymsp->TOP__v.opcode_list[5] = 0x617372;
    vlSymsp->TOP__v.opcode_list[6] = 0x636c72;
    vlSymsp->TOP__v.opcode_list[7] = 0x64656361;
    vlSymsp->TOP__v.opcode_list[8] = 0x64656362;
    vlSymsp->TOP__v.opcode_list[0xa] = 0x6d756c;
    vlSymsp->TOP__v.opcode_list[0xb] = 0x63706c61;
    vlSymsp->TOP__v.opcode_list[0xc] = 0x616e64;
    vlSymsp->TOP__v.opcode_list[0xd] = 0x6f72;
    vlSymsp->TOP__v.opcode_list[0xe] = 0x786f72;
    vlSymsp->TOP__v.opcode_list[0xf] = 0x63706c62;
    // INITIAL at alu_tb.v:150
    VL_WRITEF("START OF VERILOG\n");
    // INITIAL at alu_tb.v:164
    vlSymsp->TOP__v.errors_found = 0;
    // INITIAL at alu_tb.v:183
    vlSymsp->TOP__v.random_count = 0x1f;
    vlSymsp->TOP__v.finished = 0;
    vlSymsp->TOP__v.count = 0;
    vlSymsp->TOP__v.CLR = 1;
    vlSymsp->TOP__v.started = 0;
    VL_WRITEF("Generating %0d random inputs\n",32,vlSymsp->TOP__v.random_count);
    // INITIAL at alu_tb.v:340
    vlSymsp->TOP__v.check_here = 0;
    // INITIAL at /home/leonous/projects/verilog/ecpu/components/alu/rtl/verilog/alu.v:46
    vlSymsp->TOP__v.alu_inst0__DOT__VERSION = 1;
    // INITIAL at /home/leonous/projects/verilog/ecpu/components/alu/rtl/verilog/alu_datapath.v:115
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__logic1 = 1;
    // INITIAL at /home/leonous/projects/verilog/ecpu/components/alu/rtl/verilog/alu_datapath.v:116
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__logic0 = 0;
}

void Valu_tb_alu_tb::_settle__TOP__v__1(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_settle__TOP__v__1"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // ALWAYS at alu_tb.v:157
    VL_WRITEF("SYSTEMC_CLK Time has reached [%0t] \n",
	      64,VL_TIME_Q());
    // ALWAYS at alu_tb.v:151
    VL_WRITEF("Time has reached [%0t] \n",64,VL_TIME_Q());
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__y 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__reset 
	= vlSymsp->TOP__v.alu_inst0__DOT__reset;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__clr_C 
	= vlSymsp->TOP__v.alu_inst0__DOT__clr_C;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__clr_V 
	= vlSymsp->TOP__v.alu_inst0__DOT__clr_V;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__clr_Z 
	= vlSymsp->TOP__v.alu_inst0__DOT__clr_Z;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__reset 
	= vlSymsp->TOP__v.alu_inst0__DOT__reset;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__clr_C 
	= vlSymsp->TOP__v.alu_inst0__DOT__clr_C;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__clr_V 
	= vlSymsp->TOP__v.alu_inst0__DOT__clr_V;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__clr_Z 
	= vlSymsp->TOP__v.alu_inst0__DOT__clr_Z;
}

void Valu_tb_alu_tb::_combo__TOP__v__2(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_combo__TOP__v__2"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__reset 
	= vlSymsp->TOP__v.alu_inst0__DOT__reset;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__reset 
	= vlSymsp->TOP__v.alu_inst0__DOT__reset;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__y 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b;
}

void Valu_tb_alu_tb::_settle__TOP__v__3(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_settle__TOP__v__3"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.clk = (1 & (~ (IData)(vlSymsp->TOP__v.systemc_clk)));
}

void Valu_tb_alu_tb::_combo__TOP__v__4(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_combo__TOP__v__4"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.clk = (1 & (~ (IData)(vlSymsp->TOP__v.systemc_clk)));
    vlSymsp->TOP__v.alu_inst0__DOT__CLK = vlSymsp->TOP__v.clk;
}

void Valu_tb_alu_tb::_settle__TOP__v__5(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_settle__TOP__v__5"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.alu_inst0__DOT__CLK = vlSymsp->TOP__v.clk;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__clk 
	= vlSymsp->TOP__v.alu_inst0__DOT__CLK;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__clk 
	= vlSymsp->TOP__v.alu_inst0__DOT__CLK;
}

void Valu_tb_alu_tb::_sequent__TOP__v__6(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_sequent__TOP__v__6"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.__Vdly__this_record__DOT__S = vlSymsp->TOP__v.this_record__DOT__S;
    vlSymsp->TOP__v.__Vdly__this_record__DOT__B = vlSymsp->TOP__v.this_record__DOT__B;
    vlSymsp->TOP__v.__Vdly__this_record__DOT__A = vlSymsp->TOP__v.this_record__DOT__A;
    vlSymsp->TOP__v.__Vdly__this_record_reg__DOT__Y 
	= vlSymsp->TOP__v.this_record_reg__DOT__Y;
    vlSymsp->TOP__v.__Vdly__this_record_reg__DOT__S 
	= vlSymsp->TOP__v.this_record_reg__DOT__S;
    vlSymsp->TOP__v.__Vdly__this_record_reg__DOT__B 
	= vlSymsp->TOP__v.this_record_reg__DOT__B;
    vlSymsp->TOP__v.__Vdly__this_record_reg__DOT__A 
	= vlSymsp->TOP__v.this_record_reg__DOT__A;
    // ALWAYS at /home/leonous/projects/verilog/ecpu/components/alu/../barrel_shifter/simple/barrel_shifter_simple.temp.v:25
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_out 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_inA;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_carry = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__y_tmp 
	= (7 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_inB));
    while (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__y_tmp) 
	    > 0)) {
	if (vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_direction) {
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_out 
		= ((0x80 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_out) 
			    << 7)) | (0x7f & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_out) 
					      >> 1)));
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_carry 
		= (1 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_out));
	} else {
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_out 
		= ((0xfe & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_out) 
			    << 1)) | (1 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_out) 
					   >> 7)));
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_carry 
		= (1 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_out) 
			>> 6));
	}
	vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__y_tmp 
	    = (0xff & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__y_tmp) 
		       - (IData)(1)));
    }
    // ALWAYS at alu_tb.v:204
    vlSymsp->TOP__v.count = ((IData)(1) + vlSymsp->TOP__v.count);
    vlSymsp->TOP__v.__Vfunc_randomit__0__out = 
    // $c function at alu_tb.v:325
vsc->randomit()    
    ;
    vlSymsp->TOP__v.random_number = vlSymsp->TOP__v.__Vfunc_randomit__0__out;
    vlSymsp->TOP__v.aa = (0xff & vlSymsp->TOP__v.random_number);
    vlSymsp->TOP__v.__Vfunc_randomit__1__out = 
    // $c function at alu_tb.v:325
vsc->randomit()    
    ;
    vlSymsp->TOP__v.random_number = vlSymsp->TOP__v.__Vfunc_randomit__1__out;
    vlSymsp->TOP__v.bb = (0xff & vlSymsp->TOP__v.random_number);
    vlSymsp->TOP__v.__Vfunc_randomit__2__out = 
    // $c function at alu_tb.v:325
vsc->randomit()    
    ;
    vlSymsp->TOP__v.random_number = vlSymsp->TOP__v.__Vfunc_randomit__2__out;
    vlSymsp->TOP__v.__Vfunc_randomit__4__out = 
    // $c function at alu_tb.v:325
vsc->randomit()    
    ;
    vlSymsp->TOP__v.__Vfunc_get_random_opcode__3__tmp 
	= vlSymsp->TOP__v.__Vfunc_randomit__4__out;
    vlSymsp->TOP__v.__Vfunc_get_random_opcode__3__out 
	= vlSymsp->TOP__v.opcode_list[(0xf & VL_MODDIVS_III(4,32,32, vlSymsp->TOP__v.__Vfunc_get_random_opcode__3__tmp, (IData)(0xb)))];
    vlSymsp->TOP__v.ss = vlSymsp->TOP__v.__Vfunc_get_random_opcode__3__out;
    vlSymsp->TOP__v.__Vfunc_randomit__5__out = 
    // $c function at alu_tb.v:325
vsc->randomit()    
    ;
    vlSymsp->TOP__v.random_number = vlSymsp->TOP__v.__Vfunc_randomit__5__out;
    vlSymsp->TOP__v.clrc = 0;
    vlSymsp->TOP__v.random_count = (vlSymsp->TOP__v.random_count 
				    - (IData)(1));
    if (VL_UNLIKELY((1 == vlSymsp->TOP__v.count))) {
	VL_WRITEF("**** Start of Test ****\n");
    }
    vlSymsp->TOP__v.A = vlSymsp->TOP__v.aa;
    vlSymsp->TOP__v.B = vlSymsp->TOP__v.bb;
    vlSymsp->TOP__v.__Vfunc_string2opcode__6__s = vlSymsp->TOP__v.ss;
    if ((vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
	 == vlSymsp->TOP__v.opcode_list[0])) {
	vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 0;
    } else {
	if ((vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
	     == vlSymsp->TOP__v.opcode_list[1])) {
	    vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 1;
	} else {
	    if ((vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
		 == vlSymsp->TOP__v.opcode_list[9])) {
		vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 9;
	    } else {
		if ((vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
		     == vlSymsp->TOP__v.opcode_list
		     [2])) {
		    vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 2;
		} else {
		    if ((vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
			 == vlSymsp->TOP__v.opcode_list
			 [3])) {
			vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 3;
		    } else {
			if ((vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
			     == vlSymsp->TOP__v.opcode_list
			     [4])) {
			    vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 4;
			} else {
			    if ((vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
				 == vlSymsp->TOP__v.opcode_list
				 [5])) {
				vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 5;
			    } else {
				if ((vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
				     == vlSymsp->TOP__v.opcode_list
				     [6])) {
				    vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 6;
				} else {
				    if ((vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
					 == vlSymsp->TOP__v.opcode_list
					 [7])) {
					vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 7;
				    } else {
					if ((vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
					     == vlSymsp->TOP__v.opcode_list
					     [8])) {
					    vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 8;
					} else {
					    if ((vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
						 == 
						 vlSymsp->TOP__v.opcode_list
						 [0xa])) {
						vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 0xa;
					    } else {
						if (
						    (vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
						     == 
						     vlSymsp->TOP__v.opcode_list
						     [0xb])) {
						    vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 0xb;
						} else {
						    if (
							(vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
							 == 
							 vlSymsp->TOP__v.opcode_list
							 [0xc])) {
							vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 0xc;
						    } else {
							if (
							    (vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
							     == 
							     vlSymsp->TOP__v.opcode_list
							     [0xd])) {
							    vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 0xd;
							} else {
							    if (
								(vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
								 == 
								 vlSymsp->TOP__v.opcode_list
								 [0xe])) {
								vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 0xe;
							    } else {
								if (
								    (vlSymsp->TOP__v.__Vfunc_string2opcode__6__s 
								     == 
								     vlSymsp->TOP__v.opcode_list
								     [0xf])) {
								    vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode = 0xf;
								}
							    }
							}
						    }
						}
					    }
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }
    vlSymsp->TOP__v.__Vfunc_string2opcode__6__out = vlSymsp->TOP__v.__Vfunc_string2opcode__6__opcode;
    vlSymsp->TOP__v.S = vlSymsp->TOP__v.__Vfunc_string2opcode__6__out;
    vlSymsp->TOP__v.CLR = vlSymsp->TOP__v.clrc;
    vlSymsp->TOP__v.next_record__DOT__A = vlSymsp->TOP__v.aa;
    vlSymsp->TOP__v.next_record__DOT__B = vlSymsp->TOP__v.bb;
    vlSymsp->TOP__v.next_record__DOT__S = vlSymsp->TOP__v.ss;
    if ((1 & ((~ (IData)(vlSymsp->TOP__v.CLR)) & (~ (IData)(vlSymsp->TOP__v.started))))) {
	if (VL_GTS_III(1,32,32, vlSymsp->TOP__v.count, 3)) {
	    vlSymsp->TOP__v.started = 1;
	}
    }
    if (VL_LTES_III(1,32,32, vlSymsp->TOP__v.random_count, 0)) {
	vlSymsp->TOP__v.finished = 1;
    }
    // ALWAYS at alu_tb.v:342
    vlSymsp->TOP__v.__Vdly__this_record_reg__DOT__A 
	= vlSymsp->TOP__v.next_record__DOT__A;
    vlSymsp->TOP__v.__Vdly__this_record_reg__DOT__B 
	= vlSymsp->TOP__v.next_record__DOT__B;
    vlSymsp->TOP__v.__Vdly__this_record_reg__DOT__S 
	= vlSymsp->TOP__v.next_record__DOT__S;
    vlSymsp->TOP__v.__Vdly__this_record_reg__DOT__Y 
	= vlSymsp->TOP__v.next_record__DOT__Y;
    vlSymsp->TOP__v.__Vdly__this_record__DOT__A = vlSymsp->TOP__v.this_record_reg__DOT__A;
    vlSymsp->TOP__v.__Vdly__this_record__DOT__B = vlSymsp->TOP__v.this_record_reg__DOT__B;
    vlSymsp->TOP__v.__Vdly__this_record__DOT__S = vlSymsp->TOP__v.this_record_reg__DOT__S;
    vlSymsp->TOP__v.this_record__DOT__Y = vlSymsp->TOP__v.this_record_reg__DOT__Y;
    if (((IData)(vlSymsp->TOP__v.started) & (~ (IData)(vlSymsp->TOP__v.CLR)))) {
	vlSymsp->TOP__v.op1 = vlSymsp->TOP__v.this_record__DOT__A;
	vlSymsp->TOP__v.op2 = vlSymsp->TOP__v.this_record__DOT__B;
	if ((vlSymsp->TOP__v.this_record__DOT__S == 
	     vlSymsp->TOP__v.opcode_list[0])) {
	    vlSymsp->TOP__v.result = (0xff & ((IData)(vlSymsp->TOP__v.op1) 
					      + (IData)(vlSymsp->TOP__v.op2)));
	} else {
	    if ((vlSymsp->TOP__v.this_record__DOT__S 
		 == vlSymsp->TOP__v.opcode_list[1])) {
		vlSymsp->TOP__v.result = (0xff & ((IData)(1) 
						  + (IData)(vlSymsp->TOP__v.op1)));
	    } else {
		if ((vlSymsp->TOP__v.this_record__DOT__S 
		     == vlSymsp->TOP__v.opcode_list
		     [9])) {
		    vlSymsp->TOP__v.result = (0xff 
					      & ((IData)(1) 
						 + (IData)(vlSymsp->TOP__v.op2)));
		} else {
		    if ((vlSymsp->TOP__v.this_record__DOT__S 
			 == vlSymsp->TOP__v.opcode_list
			 [2])) {
			vlSymsp->TOP__v.result = (0xff 
						  & ((IData)(vlSymsp->TOP__v.op1) 
						     - (IData)(vlSymsp->TOP__v.op2)));
		    } else {
			if ((vlSymsp->TOP__v.this_record__DOT__S 
			     == vlSymsp->TOP__v.opcode_list
			     [3])) {
			    vlSymsp->TOP__v.result 
				= vlSymsp->TOP__v.Y;
			} else {
			    if ((vlSymsp->TOP__v.this_record__DOT__S 
				 == vlSymsp->TOP__v.opcode_list
				 [4])) {
				// Function: bas at alu_tb.v:375
				vlSymsp->TOP__v.__Vfunc_bas__7__direction = 0;
				vlSymsp->TOP__v.__Vfunc_bas__7__shift_size 
				    = vlSymsp->TOP__v.op2;
				vlSymsp->TOP__v.__Vfunc_bas__7__a1 
				    = vlSymsp->TOP__v.op1;
				vlSymsp->TOP__v.__Vfunc_bas__7__tmp 
				    = vlSymsp->TOP__v.__Vfunc_bas__7__a1;
				vlSymsp->TOP__v.__Vfunc_bas__7__tmp2 
				    = (7 & (IData)(vlSymsp->TOP__v.__Vfunc_bas__7__shift_size));
				while (VL_GTS_III(1,32,32, vlSymsp->TOP__v.__Vfunc_bas__7__tmp2, 0)) {
				    vlSymsp->TOP__v.__Vfunc_bas__7__tmp 
					= ((IData)(vlSymsp->TOP__v.__Vfunc_bas__7__direction)
					    ? ((0x80 
						& ((IData)(vlSymsp->TOP__v.__Vfunc_bas__7__tmp) 
						   << 7)) 
					       | (0x7f 
						  & ((IData)(vlSymsp->TOP__v.__Vfunc_bas__7__tmp) 
						     >> 1)))
					    : ((0xfe 
						& ((IData)(vlSymsp->TOP__v.__Vfunc_bas__7__tmp) 
						   << 1)) 
					       | (1 
						  & ((IData)(vlSymsp->TOP__v.__Vfunc_bas__7__tmp) 
						     >> 7))));
				    vlSymsp->TOP__v.__Vfunc_bas__7__tmp2 
					= (vlSymsp->TOP__v.__Vfunc_bas__7__tmp2 
					   - (IData)(1));
				}
				vlSymsp->TOP__v.__Vfunc_bas__7__out 
				    = vlSymsp->TOP__v.__Vfunc_bas__7__tmp;
				vlSymsp->TOP__v.result 
				    = vlSymsp->TOP__v.__Vfunc_bas__7__out;
			    } else {
				if ((vlSymsp->TOP__v.this_record__DOT__S 
				     == vlSymsp->TOP__v.opcode_list
				     [5])) {
				    // Function: bas at alu_tb.v:376
				    vlSymsp->TOP__v.__Vfunc_bas__8__direction = 1;
				    vlSymsp->TOP__v.__Vfunc_bas__8__shift_size 
					= vlSymsp->TOP__v.op2;
				    vlSymsp->TOP__v.__Vfunc_bas__8__a1 
					= vlSymsp->TOP__v.op1;
				    vlSymsp->TOP__v.__Vfunc_bas__8__tmp 
					= vlSymsp->TOP__v.__Vfunc_bas__8__a1;
				    vlSymsp->TOP__v.__Vfunc_bas__8__tmp2 
					= (7 & (IData)(vlSymsp->TOP__v.__Vfunc_bas__8__shift_size));
				    while (VL_GTS_III(1,32,32, vlSymsp->TOP__v.__Vfunc_bas__8__tmp2, 0)) {
					vlSymsp->TOP__v.__Vfunc_bas__8__tmp 
					    = ((IData)(vlSymsp->TOP__v.__Vfunc_bas__8__direction)
					        ? (
						   (0x80 
						    & ((IData)(vlSymsp->TOP__v.__Vfunc_bas__8__tmp) 
						       << 7)) 
						   | (0x7f 
						      & ((IData)(vlSymsp->TOP__v.__Vfunc_bas__8__tmp) 
							 >> 1)))
					        : (
						   (0xfe 
						    & ((IData)(vlSymsp->TOP__v.__Vfunc_bas__8__tmp) 
						       << 1)) 
						   | (1 
						      & ((IData)(vlSymsp->TOP__v.__Vfunc_bas__8__tmp) 
							 >> 7))));
					vlSymsp->TOP__v.__Vfunc_bas__8__tmp2 
					    = (vlSymsp->TOP__v.__Vfunc_bas__8__tmp2 
					       - (IData)(1));
				    }
				    vlSymsp->TOP__v.__Vfunc_bas__8__out 
					= vlSymsp->TOP__v.__Vfunc_bas__8__tmp;
				    vlSymsp->TOP__v.result 
					= vlSymsp->TOP__v.__Vfunc_bas__8__out;
				} else {
				    if ((vlSymsp->TOP__v.this_record__DOT__S 
					 == vlSymsp->TOP__v.opcode_list
					 [6])) {
					vlSymsp->TOP__v.result 
					    = (0xff 
					       & (((IData)(vlSymsp->TOP__v.op1) 
						   == (IData)(vlSymsp->TOP__v.op2))
						   ? 0
						   : 
						  VL_EXTENDS_II(32,8, (IData)(vlSymsp->TOP__v.Y))));
				    } else {
					if ((vlSymsp->TOP__v.this_record__DOT__S 
					     == vlSymsp->TOP__v.opcode_list
					     [7])) {
					    vlSymsp->TOP__v.result 
						= (0xff 
						   & ((IData)(vlSymsp->TOP__v.op1) 
						      - (IData)(1)));
					} else {
					    if ((vlSymsp->TOP__v.this_record__DOT__S 
						 == 
						 vlSymsp->TOP__v.opcode_list
						 [8])) {
						vlSymsp->TOP__v.result 
						    = 
						    (0xff 
						     & ((IData)(vlSymsp->TOP__v.op2) 
							- (IData)(1)));
					    } else {
						if (
						    (vlSymsp->TOP__v.this_record__DOT__S 
						     == 
						     vlSymsp->TOP__v.opcode_list
						     [0xa])) {
						    vlSymsp->TOP__v.result 
							= vlSymsp->TOP__v.Y;
						} else {
						    if (
							(vlSymsp->TOP__v.this_record__DOT__S 
							 == 
							 vlSymsp->TOP__v.opcode_list
							 [0xb])) {
							vlSymsp->TOP__v.result 
							    = 
							    (0xff 
							     & (~ (IData)(vlSymsp->TOP__v.op1)));
						    } else {
							if (
							    (vlSymsp->TOP__v.this_record__DOT__S 
							     == 
							     vlSymsp->TOP__v.opcode_list
							     [0xc])) {
							    vlSymsp->TOP__v.result 
								= 
								((IData)(vlSymsp->TOP__v.op1) 
								 & (IData)(vlSymsp->TOP__v.op2));
							} else {
							    if (
								(vlSymsp->TOP__v.this_record__DOT__S 
								 == 
								 vlSymsp->TOP__v.opcode_list
								 [0xd])) {
								vlSymsp->TOP__v.result 
								    = 
								    ((IData)(vlSymsp->TOP__v.op1) 
								     | (IData)(vlSymsp->TOP__v.op2));
							    } else {
								if (
								    (vlSymsp->TOP__v.this_record__DOT__S 
								     == 
								     vlSymsp->TOP__v.opcode_list
								     [0xe])) {
								    vlSymsp->TOP__v.result 
									= 
									((IData)(vlSymsp->TOP__v.op1) 
									 ^ (IData)(vlSymsp->TOP__v.op2));
								} else {
								    if (
									(vlSymsp->TOP__v.this_record__DOT__S 
									 == 
									 vlSymsp->TOP__v.opcode_list
									 [0xf])) {
									vlSymsp->TOP__v.result 
									    = 
									    (0xff 
									     & (~ (IData)(vlSymsp->TOP__v.op2)));
								    }
								}
							    }
							}
						    }
						}
					    }
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
	if (((0x636c72 == vlSymsp->TOP__v.last_ss) 
	     | (IData)(vlSymsp->TOP__v.last_CLR))) {
	    vlSymsp->TOP__v.result = vlSymsp->TOP__v.Y;
	}
	vlSymsp->TOP__v.last_ss = vlSymsp->TOP__v.this_record__DOT__S;
	vlSymsp->TOP__v.A_u = vlSymsp->TOP__v.this_record__DOT__A;
	vlSymsp->TOP__v.B_u = vlSymsp->TOP__v.this_record__DOT__B;
	vlSymsp->TOP__v.Y_u = vlSymsp->TOP__v.Y;
	vlSymsp->TOP__v.result_u = vlSymsp->TOP__v.result;
	vlSymsp->TOP__v.check_here = (1 & (~ (IData)(vlSymsp->TOP__v.check_here)));
	if (((IData)(vlSymsp->TOP__v.Y) != (IData)(vlSymsp->TOP__v.result))) {
	    VL_WRITEF("[%0t ps] A:%x[u%3u] S:%s[%b] B:%x[u%3u] = Y:%x [u%3u]  expected %x [u%3u] -- ERROR Output Y is wrong\n",
		      64,VL_TIME_Q(),8,(IData)(vlSymsp->TOP__v.this_record__DOT__A),
		      8,vlSymsp->TOP__v.A_u,32,vlSymsp->TOP__v.this_record__DOT__S,
		      4,(IData)(vlSymsp->TOP__v.S),
		      8,vlSymsp->TOP__v.this_record__DOT__B,
		      8,(IData)(vlSymsp->TOP__v.B_u),
		      8,vlSymsp->TOP__v.Y,8,(IData)(vlSymsp->TOP__v.Y_u),
		      8,vlSymsp->TOP__v.result,8,(IData)(vlSymsp->TOP__v.result_u));
	    vlSymsp->TOP__v.errors_found = ((IData)(1) 
					    + vlSymsp->TOP__v.errors_found);
	} else {
	    VL_WRITEF("[%0t ps] A:%x[u%x] S:%s[%b] B:%x[u%x] = Y:%x [u%x]  expected %x [u%x]\n",
		      64,VL_TIME_Q(),8,(IData)(vlSymsp->TOP__v.this_record__DOT__A),
		      8,vlSymsp->TOP__v.A_u,32,vlSymsp->TOP__v.this_record__DOT__S,
		      4,(IData)(vlSymsp->TOP__v.S),
		      8,vlSymsp->TOP__v.this_record__DOT__B,
		      8,(IData)(vlSymsp->TOP__v.B_u),
		      8,vlSymsp->TOP__v.Y,8,(IData)(vlSymsp->TOP__v.Y_u),
		      8,vlSymsp->TOP__v.result,8,(IData)(vlSymsp->TOP__v.result_u));
	}
    }
    vlSymsp->TOP__v.last_CLR = vlSymsp->TOP__v.CLR;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__z 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_out;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__c 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_carry;
    vlSymsp->TOP__v.alu_inst0__DOT__CLR = vlSymsp->TOP__v.CLR;
    vlSymsp->TOP__v.alu_inst0__DOT__S = vlSymsp->TOP__v.S;
    vlSymsp->TOP__v.alu_inst0__DOT__A = vlSymsp->TOP__v.A;
    vlSymsp->TOP__v.alu_inst0__DOT__B = vlSymsp->TOP__v.B;
    vlSymsp->TOP__v.this_record__DOT__S = vlSymsp->TOP__v.__Vdly__this_record__DOT__S;
    vlSymsp->TOP__v.this_record__DOT__B = vlSymsp->TOP__v.__Vdly__this_record__DOT__B;
    vlSymsp->TOP__v.this_record_reg__DOT__Y = vlSymsp->TOP__v.__Vdly__this_record_reg__DOT__Y;
    vlSymsp->TOP__v.this_record_reg__DOT__S = vlSymsp->TOP__v.__Vdly__this_record_reg__DOT__S;
    vlSymsp->TOP__v.this_record__DOT__A = vlSymsp->TOP__v.__Vdly__this_record__DOT__A;
    vlSymsp->TOP__v.this_record_reg__DOT__A = vlSymsp->TOP__v.__Vdly__this_record_reg__DOT__A;
    vlSymsp->TOP__v.this_record_reg__DOT__B = vlSymsp->TOP__v.__Vdly__this_record_reg__DOT__B;
}

void Valu_tb_alu_tb::_sequent__TOP__v__7(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_sequent__TOP__v__7"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // ALWAYS at /home/leonous/projects/verilog/ecpu/components/alu/rtl/verilog/alu_datapath.v:183
    if (vlSymsp->TOP__v.alu_inst0__DOT__reset) {
	vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Areg = 0;
	vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Breg = 0;
	vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Yreg = 0;
	vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Zreg = 1;
	vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Creg = 0;
	vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Vreg = 0;
    } else {
	if (vlSymsp->TOP__v.alu_inst0__DOT__load_inputs) {
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Areg 
		= vlSymsp->TOP__v.A;
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Breg 
		= vlSymsp->TOP__v.B;
	}
	if (vlSymsp->TOP__v.alu_inst0__DOT__load_outputs) {
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Yreg 
		= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__alu_out;
	}
	if (vlSymsp->TOP__v.alu_inst0__DOT__clr_ALL) {
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Areg = 0;
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Breg = 0;
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Yreg = 0;
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Creg = 0;
	}
	if (vlSymsp->TOP__v.alu_inst0__DOT__clr_Z) {
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Zreg = 0;
	}
	if (vlSymsp->TOP__v.alu_inst0__DOT__clr_C) {
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Creg = 0;
	}
	if (vlSymsp->TOP__v.alu_inst0__DOT__clr_V) {
	    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Vreg = 0;
	}
	vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Zreg 
	    = (0 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__alu_out));
	vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Creg 
	    = vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry;
    }
    // ALWAYS at /home/leonous/projects/verilog/ecpu/components/alu/rtl/verilog/alu_controller.v:101
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode 
	= ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__reset)
	    ? 6 : (IData)(vlSymsp->TOP__v.S));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_inB 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Breg;
    vlSymsp->TOP__v.V = vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Vreg;
    vlSymsp->TOP__v.C = vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Creg;
    vlSymsp->TOP__v.Z = vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Zreg;
    vlSymsp->TOP__v.Y = vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Yreg;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_inA 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Areg;
    // ALWAYS at /home/leonous/projects/verilog/ecpu/components/alu/rtl/verilog/alu_controller.v:111
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x80] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x81] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x82] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x83] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x84] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x85] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x86] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x87] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x88] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x89] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x8a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x8b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x8c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x8d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x8e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x8f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x90] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x91] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x92] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x93] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x94] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x95] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x96] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x97] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x98] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x99] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x9a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x9b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x9c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x9d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x9e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x9f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xaa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xaf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xbb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xbc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xbd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xbe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xbf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xcb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xcc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xcd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xcf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xda] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xdb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xdc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xdd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xde] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xdf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xeb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xfa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xfb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xfc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xfd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xfe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x100] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x101] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x102] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x103] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x104] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x105] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x106] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x107] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x108] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x109] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x110] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x111] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x112] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x113] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x114] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x115] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x116] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x117] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x118] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x119] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x120] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x121] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x122] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x123] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x124] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x125] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x126] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x127] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x128] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x129] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x130] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x131] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x132] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x133] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x134] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x135] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x136] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x137] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x138] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x139] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x140] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x141] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x142] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x143] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x144] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x145] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x146] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x147] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x148] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x149] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x150] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x151] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x152] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x153] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x154] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x155] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x156] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x157] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x158] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x159] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x160] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x161] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x162] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x163] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x164] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x165] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x166] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x167] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x168] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x169] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x170] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x171] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x172] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x173] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x174] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x175] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x176] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x177] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x178] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x179] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x180] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x181] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x182] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x183] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x184] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x185] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x186] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x187] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x188] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x189] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x190] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x191] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x192] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x193] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x194] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x195] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x196] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x197] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x198] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x199] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x200] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x201] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x202] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x203] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x204] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x205] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x206] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x207] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x208] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x209] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x210] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x211] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x212] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x213] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x214] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x215] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x216] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x217] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x218] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x219] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x220] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x221] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x222] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x223] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x224] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x225] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x226] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x227] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x228] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x229] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x230] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x231] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x232] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x233] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x234] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x235] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x236] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x237] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x238] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x239] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x240] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x241] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x242] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x243] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x244] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x245] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x246] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x247] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x248] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x249] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x250] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x251] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x252] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x253] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x254] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x255] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x256] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x257] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x258] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x259] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x260] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x261] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x262] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x263] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x264] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x265] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x266] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x267] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x268] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x269] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x270] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x271] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x272] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x273] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x274] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x275] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x276] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x277] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x278] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x279] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x280] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x281] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x282] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x283] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x284] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x285] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x286] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x287] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x288] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x289] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x290] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x291] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x292] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x293] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x294] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x295] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x296] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x297] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x298] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x299] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x300] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x301] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x302] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x303] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x304] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x305] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x306] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x307] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x308] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x309] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x310] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x311] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x312] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x313] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x314] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x315] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x316] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x317] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x318] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x319] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x320] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x321] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x322] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x323] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x324] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x325] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x326] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x327] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x328] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x329] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x330] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x331] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x332] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x333] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x334] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x335] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x336] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x337] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x338] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x339] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x340] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x341] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x342] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x343] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x344] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x345] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x346] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x347] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x348] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x349] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x350] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x351] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x352] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x353] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x354] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x355] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x356] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x357] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x358] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x359] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x360] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x361] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x362] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x363] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x364] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x365] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x366] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x367] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x368] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x369] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x370] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x371] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x372] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x373] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x374] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x375] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x376] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x377] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x378] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x379] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x380] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x381] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x382] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x383] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x384] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x385] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x386] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x387] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x388] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x389] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x390] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x391] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x392] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x393] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x394] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x395] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x396] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x397] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x398] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x399] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x400] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x401] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x402] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x403] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x404] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x405] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x406] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x407] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x408] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x409] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x410] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x411] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x412] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x413] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x414] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x415] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x416] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x417] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x418] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x419] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x420] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x421] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x422] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x423] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x424] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x425] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x426] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x427] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x428] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x429] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x430] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x431] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x432] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x433] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x434] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x435] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x436] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x437] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x438] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x439] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x440] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x441] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x442] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x443] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x444] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x445] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x446] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x447] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x448] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x449] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x450] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x451] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x452] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x453] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x454] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x455] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x456] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x457] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x458] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x459] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x460] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x461] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x462] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x463] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x464] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x465] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x466] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x467] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x468] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x469] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x470] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x471] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x472] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x473] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x474] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x475] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x476] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x477] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x478] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x479] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x480] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x481] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x482] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x483] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x484] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x485] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x486] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x487] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x488] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x489] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x490] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x491] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x492] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x493] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x494] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x495] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x496] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x497] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x498] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x499] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x500] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x501] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x502] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x503] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x504] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x505] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x506] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x507] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x508] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x509] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x510] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x511] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x512] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x513] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x514] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x515] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x516] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x517] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x518] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x519] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x520] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x521] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x522] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x523] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x524] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x525] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x526] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x527] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x528] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x529] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x530] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x531] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x532] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x533] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x534] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x535] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x536] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x537] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x538] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x539] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x540] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x541] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x542] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x543] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x544] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x545] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x546] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x547] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x548] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x549] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x550] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x551] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x552] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x553] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x554] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x555] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x556] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x557] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x558] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x559] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x560] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x561] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x562] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x563] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x564] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x565] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x566] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x567] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x568] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x569] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x570] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x571] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x572] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x573] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x574] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x575] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x576] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x577] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x578] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x579] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x580] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x581] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x582] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x583] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x584] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x585] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x586] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x587] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x588] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x589] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x590] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x591] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x592] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x593] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x594] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x595] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x596] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x597] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x598] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x599] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x600] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x601] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x602] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x603] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x604] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x605] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x606] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x607] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x608] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x609] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x610] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x611] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x612] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x613] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x614] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x615] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x616] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x617] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x618] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x619] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x620] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x621] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x622] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x623] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x624] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x625] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x626] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x627] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x628] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x629] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x630] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x631] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x632] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x633] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x634] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x635] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x636] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x637] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x638] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x639] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x640] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x641] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x642] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x643] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x644] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x645] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x646] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x647] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x648] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x649] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x650] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x651] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x652] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x653] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x654] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x655] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x656] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x657] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x658] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x659] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x660] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x661] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x662] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x663] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x664] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x665] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x666] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x667] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x668] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x669] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x670] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x671] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x672] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x673] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x674] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x675] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x676] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x677] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x678] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x679] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x680] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x681] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x682] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x683] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x684] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x685] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x686] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x687] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x688] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x689] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x690] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x691] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x692] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x693] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x694] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x695] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x696] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x697] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x698] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x699] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x700] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x701] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x702] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x703] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x704] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x705] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x706] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x707] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x708] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x709] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x710] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x711] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x712] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x713] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x714] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x715] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x716] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x717] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x718] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x719] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x720] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x721] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x722] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x723] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x724] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x725] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x726] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x727] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x728] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x729] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x730] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x731] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x732] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x733] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x734] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x735] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x736] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x737] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x738] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x739] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x740] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x741] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x742] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x743] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x744] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x745] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x746] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x747] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x748] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x749] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x750] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x751] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x752] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x753] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x754] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x755] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x756] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x757] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x758] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x759] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x760] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x761] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x762] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x763] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x764] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x765] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x766] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x767] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x768] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x769] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x770] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x771] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x772] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x773] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x774] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x775] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x776] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x777] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x778] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x779] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x780] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x781] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x782] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x783] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x784] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x785] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x786] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x787] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x788] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x789] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x790] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x791] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x792] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x793] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x794] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x795] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x796] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x797] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x798] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x799] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x800] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 0;
    if (((((((((6 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode)) 
	       | (0 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	      | (1 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	     | (9 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	    | (7 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	   | (8 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	  | (2 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	 | (3 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode)))) {
	if ((6 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
	    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
		= (0x40 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
	} else {
	    if ((0 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
		vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
		    = (1 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
		vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
		vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
	    } else {
		if ((1 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
		    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
			= (2 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
		    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
		    vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
		} else {
		    if ((9 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
			vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
			    = (0x200 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
			vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
			vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
		    } else {
			if ((7 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
			    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
				= (0x80 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
			    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
			    vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
			} else {
			    if ((8 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
				vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
				    = (0x100 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
				vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
				vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
			    } else {
				if ((2 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
				    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
					= (4 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
				    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
				    vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
				} else {
				    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
					= (8 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
				    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
				}
			    }
			}
		    }
		}
	    }
	}
    } else {
	if (((((((((0xc == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode)) 
		   | (0xd == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
		  | (0xe == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
		 | (0xa == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
		| (0xb == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	       | (0xf == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	      | (4 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	     | (5 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode)))) {
	    if ((0xc == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
		vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
		    = (0x1000 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
		vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
		vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
	    } else {
		if ((0xd == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
		    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
			= (0x2000 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
		    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
		    vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
		} else {
		    if ((0xe == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
			vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
			    = (0x4000 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
			vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
			vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
		    } else {
			if ((0xa == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
			    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
				= (0x400 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
			    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
			    vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
			} else {
			    if ((0xb == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
				vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
				    = (0x800 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
				vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
				vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
			    } else {
				if ((0xf == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
				    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
					= (0x8000 | 
					   vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
				    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
				    vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
				} else {
				    if ((4 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
					vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
					    = (0x10 
					       | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
					vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
					vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
				    } else {
					vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
					    = (0x20 
					       | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
					vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
					vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
				    }
				}
			    }
			}
		    }
		}
	    }
	} else {
	    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__next_opcode 
		= vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode;
	}
    }
}

void Valu_tb_alu_tb::_combo__TOP__v__8(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_combo__TOP__v__8"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__clk 
	= vlSymsp->TOP__v.alu_inst0__DOT__CLK;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__clk 
	= vlSymsp->TOP__v.alu_inst0__DOT__CLK;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__clk 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__clk;
}

void Valu_tb_alu_tb::_settle__TOP__v__9(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_settle__TOP__v__9"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__z 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_out;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__c 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_carry;
    vlSymsp->TOP__v.alu_inst0__DOT__CLR = vlSymsp->TOP__v.CLR;
    vlSymsp->TOP__v.alu_inst0__DOT__S = vlSymsp->TOP__v.S;
    vlSymsp->TOP__v.alu_inst0__DOT__A = vlSymsp->TOP__v.A;
    vlSymsp->TOP__v.alu_inst0__DOT__B = vlSymsp->TOP__v.B;
    vlSymsp->TOP__v.alu_inst0__DOT__reset = vlSymsp->TOP__v.CLR;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_inB 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Breg;
    vlSymsp->TOP__v.V = vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Vreg;
    vlSymsp->TOP__v.C = vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Creg;
    vlSymsp->TOP__v.Z = vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Zreg;
    vlSymsp->TOP__v.Y = vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Yreg;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_inA 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Areg;
    // ALWAYS at /home/leonous/projects/verilog/ecpu/components/alu/rtl/verilog/alu_controller.v:111
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x80] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x81] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x82] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x83] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x84] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x85] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x86] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x87] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x88] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x89] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x8a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x8b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x8c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x8d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x8e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x8f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x90] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x91] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x92] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x93] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x94] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x95] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x96] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x97] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x98] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x99] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x9a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x9b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x9c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x9d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x9e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x9f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xa9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xaa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xaf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xb9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xbb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xbc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xbd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xbe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xbf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xc9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xcb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xcc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xcd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xcf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xd9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xda] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xdb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xdc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xdd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xde] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xdf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xe9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xeb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xf9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xfa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xfb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xfc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xfd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xfe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0xff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x100] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x101] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x102] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x103] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x104] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x105] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x106] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x107] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x108] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x109] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x10f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x110] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x111] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x112] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x113] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x114] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x115] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x116] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x117] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x118] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x119] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x11f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x120] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x121] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x122] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x123] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x124] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x125] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x126] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x127] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x128] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x129] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x12f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x130] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x131] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x132] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x133] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x134] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x135] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x136] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x137] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x138] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x139] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x13f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x140] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x141] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x142] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x143] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x144] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x145] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x146] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x147] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x148] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x149] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x14f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x150] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x151] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x152] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x153] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x154] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x155] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x156] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x157] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x158] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x159] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x15f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x160] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x161] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x162] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x163] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x164] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x165] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x166] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x167] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x168] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x169] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x16f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x170] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x171] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x172] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x173] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x174] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x175] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x176] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x177] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x178] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x179] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x17f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x180] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x181] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x182] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x183] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x184] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x185] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x186] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x187] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x188] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x189] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x18f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x190] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x191] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x192] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x193] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x194] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x195] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x196] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x197] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x198] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x199] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x19f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x1ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x200] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x201] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x202] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x203] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x204] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x205] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x206] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x207] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x208] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x209] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x20f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x210] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x211] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x212] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x213] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x214] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x215] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x216] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x217] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x218] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x219] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x21f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x220] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x221] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x222] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x223] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x224] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x225] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x226] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x227] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x228] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x229] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x22f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x230] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x231] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x232] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x233] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x234] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x235] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x236] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x237] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x238] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x239] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x23f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x240] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x241] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x242] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x243] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x244] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x245] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x246] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x247] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x248] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x249] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x24f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x250] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x251] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x252] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x253] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x254] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x255] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x256] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x257] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x258] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x259] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x25f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x260] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x261] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x262] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x263] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x264] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x265] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x266] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x267] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x268] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x269] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x26f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x270] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x271] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x272] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x273] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x274] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x275] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x276] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x277] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x278] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x279] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x27f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x280] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x281] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x282] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x283] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x284] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x285] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x286] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x287] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x288] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x289] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x28f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x290] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x291] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x292] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x293] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x294] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x295] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x296] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x297] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x298] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x299] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x29f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x2ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x300] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x301] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x302] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x303] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x304] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x305] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x306] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x307] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x308] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x309] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x30f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x310] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x311] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x312] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x313] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x314] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x315] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x316] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x317] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x318] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x319] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x31f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x320] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x321] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x322] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x323] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x324] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x325] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x326] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x327] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x328] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x329] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x32f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x330] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x331] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x332] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x333] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x334] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x335] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x336] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x337] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x338] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x339] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x33f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x340] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x341] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x342] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x343] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x344] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x345] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x346] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x347] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x348] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x349] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x34f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x350] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x351] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x352] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x353] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x354] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x355] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x356] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x357] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x358] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x359] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x35f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x360] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x361] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x362] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x363] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x364] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x365] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x366] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x367] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x368] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x369] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x36f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x370] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x371] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x372] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x373] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x374] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x375] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x376] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x377] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x378] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x379] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x37f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x380] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x381] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x382] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x383] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x384] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x385] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x386] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x387] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x388] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x389] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x38f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x390] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x391] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x392] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x393] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x394] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x395] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x396] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x397] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x398] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x399] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x39f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x3ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x400] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x401] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x402] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x403] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x404] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x405] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x406] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x407] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x408] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x409] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x40f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x410] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x411] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x412] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x413] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x414] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x415] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x416] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x417] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x418] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x419] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x41f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x420] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x421] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x422] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x423] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x424] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x425] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x426] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x427] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x428] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x429] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x42f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x430] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x431] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x432] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x433] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x434] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x435] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x436] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x437] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x438] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x439] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x43f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x440] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x441] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x442] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x443] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x444] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x445] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x446] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x447] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x448] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x449] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x44f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x450] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x451] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x452] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x453] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x454] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x455] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x456] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x457] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x458] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x459] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x45f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x460] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x461] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x462] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x463] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x464] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x465] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x466] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x467] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x468] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x469] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x46f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x470] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x471] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x472] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x473] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x474] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x475] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x476] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x477] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x478] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x479] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x47f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x480] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x481] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x482] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x483] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x484] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x485] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x486] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x487] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x488] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x489] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x48f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x490] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x491] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x492] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x493] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x494] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x495] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x496] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x497] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x498] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x499] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x49f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x4ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x500] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x501] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x502] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x503] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x504] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x505] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x506] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x507] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x508] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x509] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x50f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x510] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x511] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x512] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x513] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x514] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x515] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x516] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x517] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x518] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x519] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x51f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x520] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x521] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x522] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x523] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x524] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x525] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x526] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x527] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x528] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x529] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x52f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x530] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x531] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x532] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x533] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x534] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x535] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x536] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x537] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x538] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x539] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x53f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x540] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x541] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x542] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x543] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x544] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x545] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x546] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x547] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x548] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x549] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x54f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x550] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x551] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x552] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x553] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x554] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x555] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x556] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x557] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x558] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x559] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x55f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x560] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x561] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x562] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x563] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x564] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x565] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x566] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x567] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x568] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x569] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x56f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x570] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x571] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x572] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x573] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x574] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x575] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x576] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x577] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x578] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x579] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x57f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x580] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x581] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x582] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x583] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x584] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x585] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x586] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x587] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x588] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x589] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x58f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x590] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x591] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x592] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x593] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x594] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x595] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x596] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x597] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x598] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x599] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x59f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x5ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x600] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x601] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x602] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x603] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x604] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x605] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x606] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x607] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x608] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x609] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x60f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x610] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x611] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x612] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x613] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x614] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x615] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x616] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x617] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x618] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x619] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x61f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x620] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x621] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x622] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x623] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x624] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x625] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x626] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x627] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x628] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x629] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x62f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x630] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x631] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x632] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x633] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x634] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x635] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x636] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x637] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x638] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x639] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x63f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x640] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x641] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x642] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x643] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x644] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x645] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x646] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x647] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x648] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x649] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x64f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x650] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x651] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x652] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x653] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x654] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x655] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x656] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x657] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x658] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x659] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x65f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x660] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x661] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x662] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x663] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x664] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x665] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x666] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x667] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x668] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x669] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x66f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x670] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x671] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x672] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x673] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x674] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x675] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x676] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x677] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x678] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x679] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x67f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x680] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x681] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x682] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x683] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x684] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x685] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x686] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x687] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x688] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x689] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x68f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x690] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x691] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x692] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x693] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x694] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x695] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x696] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x697] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x698] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x699] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x69f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x6ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x700] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x701] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x702] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x703] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x704] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x705] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x706] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x707] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x708] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x709] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x70f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x710] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x711] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x712] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x713] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x714] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x715] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x716] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x717] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x718] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x719] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x71f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x720] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x721] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x722] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x723] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x724] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x725] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x726] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x727] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x728] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x729] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x72f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x730] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x731] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x732] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x733] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x734] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x735] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x736] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x737] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x738] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x739] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x73f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x740] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x741] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x742] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x743] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x744] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x745] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x746] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x747] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x748] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x749] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x74f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x750] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x751] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x752] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x753] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x754] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x755] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x756] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x757] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x758] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x759] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x75f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x760] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x761] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x762] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x763] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x764] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x765] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x766] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x767] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x768] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x769] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x76f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x770] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x771] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x772] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x773] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x774] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x775] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x776] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x777] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x778] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x779] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x77f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x780] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x781] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x782] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x783] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x784] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x785] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x786] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x787] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x788] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x789] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x78f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x790] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x791] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x792] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x793] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x794] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x795] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x796] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x797] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x798] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x799] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79a] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79b] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79c] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79d] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79e] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x79f] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7a9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7aa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ab] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ac] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ad] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ae] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7af] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7b9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ba] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7bb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7bc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7bd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7be] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7bf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7c9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ca] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7cb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7cc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7cd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ce] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7cf] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7d9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7da] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7db] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7dc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7dd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7de] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7df] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7e9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ea] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7eb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ec] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ed] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ee] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ef] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f0] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f1] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f2] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f3] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f4] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f5] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f6] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f7] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f8] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7f9] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7fa] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7fb] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7fc] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7fd] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7fe] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x7ff] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0x800] = 0;
    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 0;
    if (((((((((6 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode)) 
	       | (0 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	      | (1 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	     | (9 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	    | (7 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	   | (8 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	  | (2 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	 | (3 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode)))) {
	if ((6 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
	    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
		= (0x40 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
	} else {
	    if ((0 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
		vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
		    = (1 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
		vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
		vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
	    } else {
		if ((1 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
		    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
			= (2 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
		    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
		    vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
		} else {
		    if ((9 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
			vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
			    = (0x200 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
			vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
			vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
		    } else {
			if ((7 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
			    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
				= (0x80 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
			    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
			    vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
			} else {
			    if ((8 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
				vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
				    = (0x100 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
				vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
				vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
			    } else {
				if ((2 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
				    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
					= (4 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
				    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
				    vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
				} else {
				    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
					= (8 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
				    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
				}
			    }
			}
		    }
		}
	    }
	}
    } else {
	if (((((((((0xc == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode)) 
		   | (0xd == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
		  | (0xe == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
		 | (0xa == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
		| (0xb == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	       | (0xf == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	      | (4 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) 
	     | (5 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode)))) {
	    if ((0xc == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
		vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
		    = (0x1000 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
		vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
		vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
	    } else {
		if ((0xd == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
		    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
			= (0x2000 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
		    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
		    vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
		} else {
		    if ((0xe == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
			vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
			    = (0x4000 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
			vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
			vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
		    } else {
			if ((0xa == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
			    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
				= (0x400 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
			    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
			    vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
			} else {
			    if ((0xb == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
				vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
				    = (0x800 | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
				vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
				vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
			    } else {
				if ((0xf == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
				    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
					= (0x8000 | 
					   vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
				    vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
				    vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
				} else {
				    if ((4 == (IData)(vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode))) {
					vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
					    = (0x10 
					       | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
					vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
					vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
				    } else {
					vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
					    = (0x20 
					       | vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
					vlSymsp->TOP__v.alu_inst0__DOT__load_inputs = 1;
					vlSymsp->TOP__v.alu_inst0__DOT__load_outputs = 1;
				    }
				}
			    }
			}
		    }
		}
	    }
	} else {
	    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__next_opcode 
		= vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__this_opcode;
	}
    }
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__clk 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__clk;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode 
	= vlSymsp->TOP__v.alu_inst0__DOT__S;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__A 
	= vlSymsp->TOP__v.alu_inst0__DOT__A;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__B 
	= vlSymsp->TOP__v.alu_inst0__DOT__B;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__y 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_inB;
    vlSymsp->TOP__v.alu_inst0__DOT__V = vlSymsp->TOP__v.V;
    vlSymsp->TOP__v.alu_inst0__DOT__C = vlSymsp->TOP__v.C;
    vlSymsp->TOP__v.alu_inst0__DOT__Z = vlSymsp->TOP__v.Z;
    vlSymsp->TOP__v.alu_inst0__DOT__Y = vlSymsp->TOP__v.Y;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__x 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_inA;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__load_inputs 
	= vlSymsp->TOP__v.alu_inst0__DOT__load_inputs;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__load_inputs 
	= vlSymsp->TOP__v.alu_inst0__DOT__load_inputs;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__load_outputs 
	= vlSymsp->TOP__v.alu_inst0__DOT__load_outputs;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__load_outputs 
	= vlSymsp->TOP__v.alu_inst0__DOT__load_outputs;
    vlSymsp->TOP__v.alu_inst0__DOT__mul_AB = (1 & (
						   vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						   >> 0xa));
    vlSymsp->TOP__v.alu_inst0__DOT__dec_A = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 7));
    vlSymsp->TOP__v.alu_inst0__DOT__clr_ALL = (1 & 
					       (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						>> 6));
    vlSymsp->TOP__v.alu_inst0__DOT__add_AB = (1 & vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
    vlSymsp->TOP__v.alu_inst0__DOT__and_AB = (1 & (
						   vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						   >> 0xc));
    vlSymsp->TOP__v.alu_inst0__DOT__sl_AB = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 4));
    vlSymsp->TOP__v.alu_inst0__DOT__sr_AB = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 5));
    vlSymsp->TOP__v.alu_inst0__DOT__cmp_AB = (1 & (
						   vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						   >> 3));
    vlSymsp->TOP__v.alu_inst0__DOT__sub_AB = (1 & (
						   vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						   >> 2));
    vlSymsp->TOP__v.alu_inst0__DOT__inc_A = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 1));
    vlSymsp->TOP__v.alu_inst0__DOT__xor_AB = (1 & (
						   vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						   >> 0xe));
    vlSymsp->TOP__v.alu_inst0__DOT__or_AB = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 0xd));
    vlSymsp->TOP__v.alu_inst0__DOT__dec_B = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 8));
    vlSymsp->TOP__v.alu_inst0__DOT__cpl_A = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 0xb));
    vlSymsp->TOP__v.alu_inst0__DOT__cpl_B = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 0xf));
    vlSymsp->TOP__v.alu_inst0__DOT__inc_B = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 9));
}

void Valu_tb_alu_tb::_sequent__TOP__v__10(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_sequent__TOP__v__10"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // ALWAYS at alu_tb.v:167
    if (VL_UNLIKELY(vlSymsp->TOP__v.finished)) {
	if (VL_GTS_III(1,32,32, vlSymsp->TOP__v.errors_found, 0)) {
	    VL_WRITEF("Test FAILED with %11d ERRORs [%0t] \n",
		      32,vlSymsp->TOP__v.errors_found,
		      64,VL_TIME_Q());
	} else {
	    VL_WRITEF("Test PASSED \n");
	}
	vl_finish("alu_tb.v",177,"");
    }
}

void Valu_tb_alu_tb::_sequent__TOP__v__11(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_sequent__TOP__v__11"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.alu_inst0__DOT__reset = vlSymsp->TOP__v.CLR;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode 
	= vlSymsp->TOP__v.alu_inst0__DOT__S;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__A 
	= vlSymsp->TOP__v.alu_inst0__DOT__A;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__B 
	= vlSymsp->TOP__v.alu_inst0__DOT__B;
}

void Valu_tb_alu_tb::_sequent__TOP__v__12(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_sequent__TOP__v__12"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__y 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_inB;
    vlSymsp->TOP__v.alu_inst0__DOT__V = vlSymsp->TOP__v.V;
    vlSymsp->TOP__v.alu_inst0__DOT__C = vlSymsp->TOP__v.C;
    vlSymsp->TOP__v.alu_inst0__DOT__Z = vlSymsp->TOP__v.Z;
    vlSymsp->TOP__v.alu_inst0__DOT__Y = vlSymsp->TOP__v.Y;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__x 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_inA;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__load_inputs 
	= vlSymsp->TOP__v.alu_inst0__DOT__load_inputs;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__load_inputs 
	= vlSymsp->TOP__v.alu_inst0__DOT__load_inputs;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__load_outputs 
	= vlSymsp->TOP__v.alu_inst0__DOT__load_outputs;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__load_outputs 
	= vlSymsp->TOP__v.alu_inst0__DOT__load_outputs;
    vlSymsp->TOP__v.alu_inst0__DOT__mul_AB = (1 & (
						   vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						   >> 0xa));
    vlSymsp->TOP__v.alu_inst0__DOT__dec_A = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 7));
    vlSymsp->TOP__v.alu_inst0__DOT__clr_ALL = (1 & 
					       (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						>> 6));
    vlSymsp->TOP__v.alu_inst0__DOT__add_AB = (1 & vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0]);
    vlSymsp->TOP__v.alu_inst0__DOT__sl_AB = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 4));
    vlSymsp->TOP__v.alu_inst0__DOT__and_AB = (1 & (
						   vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						   >> 0xc));
    vlSymsp->TOP__v.alu_inst0__DOT__sr_AB = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 5));
    vlSymsp->TOP__v.alu_inst0__DOT__cmp_AB = (1 & (
						   vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						   >> 3));
    vlSymsp->TOP__v.alu_inst0__DOT__inc_A = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 1));
    vlSymsp->TOP__v.alu_inst0__DOT__sub_AB = (1 & (
						   vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						   >> 2));
    vlSymsp->TOP__v.alu_inst0__DOT__xor_AB = (1 & (
						   vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						   >> 0xe));
    vlSymsp->TOP__v.alu_inst0__DOT__or_AB = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 0xd));
    vlSymsp->TOP__v.alu_inst0__DOT__dec_B = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 8));
    vlSymsp->TOP__v.alu_inst0__DOT__cpl_A = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 0xb));
    vlSymsp->TOP__v.alu_inst0__DOT__cpl_B = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 0xf));
    vlSymsp->TOP__v.alu_inst0__DOT__inc_B = (1 & (vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__opcode_sel[0] 
						  >> 9));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__V 
	= vlSymsp->TOP__v.alu_inst0__DOT__V;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__C 
	= vlSymsp->TOP__v.alu_inst0__DOT__C;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Z 
	= vlSymsp->TOP__v.alu_inst0__DOT__Z;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Y 
	= vlSymsp->TOP__v.alu_inst0__DOT__Y;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__mul_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__mul_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__mul_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__mul_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__dec_A 
	= vlSymsp->TOP__v.alu_inst0__DOT__dec_A;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__dec_A 
	= vlSymsp->TOP__v.alu_inst0__DOT__dec_A;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__clr 
	= vlSymsp->TOP__v.alu_inst0__DOT__clr_ALL;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__clr 
	= vlSymsp->TOP__v.alu_inst0__DOT__clr_ALL;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__add_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__add_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__add_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__add_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__sl_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__sl_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__sl_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__sl_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__and_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__and_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__and_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__and_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__sr_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__sr_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__sr_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__sr_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_direction 
	= (1 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__sr_AB)
		 ? 1 : 0));
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__cmp_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__cmp_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__cmp_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__cmp_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__inc_A 
	= vlSymsp->TOP__v.alu_inst0__DOT__inc_A;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__inc_A 
	= vlSymsp->TOP__v.alu_inst0__DOT__inc_A;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__sub_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__sub_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__sub_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__sub_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__xor_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__xor_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__xor_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__xor_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel 
	= (1 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__xor_AB) 
		 | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cmp_AB))
		 ? 0 : 1));
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__or_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__or_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__or_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__or_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel 
	= (1 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__or_AB)
		 ? 1 : 0));
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__dec_B 
	= vlSymsp->TOP__v.alu_inst0__DOT__dec_B;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__dec_B 
	= vlSymsp->TOP__v.alu_inst0__DOT__dec_B;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__cpl_A 
	= vlSymsp->TOP__v.alu_inst0__DOT__cpl_A;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__cpl_A 
	= vlSymsp->TOP__v.alu_inst0__DOT__cpl_A;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__cpl_B 
	= vlSymsp->TOP__v.alu_inst0__DOT__cpl_B;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__cpl_B 
	= vlSymsp->TOP__v.alu_inst0__DOT__cpl_B;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__inc_B 
	= vlSymsp->TOP__v.alu_inst0__DOT__inc_B;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__inc_B 
	= vlSymsp->TOP__v.alu_inst0__DOT__inc_B;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_in 
	= (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__sub_AB) 
	    | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__inc_A)) 
	   | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__inc_B));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_a 
	= (0xff & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_B)
		    ? 0 : ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_A)
			    ? (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Areg))
			    : ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__inc_B)
			        ? 0 : ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__dec_B)
				        ? 0xff : (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Areg))))));
}

void Valu_tb_alu_tb::_settle__TOP__v__13(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_settle__TOP__v__13"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__V 
	= vlSymsp->TOP__v.alu_inst0__DOT__V;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__C 
	= vlSymsp->TOP__v.alu_inst0__DOT__C;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Z 
	= vlSymsp->TOP__v.alu_inst0__DOT__Z;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Y 
	= vlSymsp->TOP__v.alu_inst0__DOT__Y;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__mul_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__mul_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__mul_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__mul_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__dec_A 
	= vlSymsp->TOP__v.alu_inst0__DOT__dec_A;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__dec_A 
	= vlSymsp->TOP__v.alu_inst0__DOT__dec_A;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__clr 
	= vlSymsp->TOP__v.alu_inst0__DOT__clr_ALL;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__clr 
	= vlSymsp->TOP__v.alu_inst0__DOT__clr_ALL;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__add_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__add_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__add_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__add_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__sl_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__sl_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__sl_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__sl_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__and_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__and_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__and_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__and_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__sr_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__sr_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__sr_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__sr_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_direction 
	= (1 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__sr_AB)
		 ? 1 : 0));
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__cmp_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__cmp_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__cmp_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__cmp_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__inc_A 
	= vlSymsp->TOP__v.alu_inst0__DOT__inc_A;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__inc_A 
	= vlSymsp->TOP__v.alu_inst0__DOT__inc_A;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__sub_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__sub_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__sub_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__sub_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__xor_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__xor_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__xor_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__xor_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel 
	= (1 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__xor_AB) 
		 | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cmp_AB))
		 ? 0 : 1));
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__or_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__or_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__or_AB 
	= vlSymsp->TOP__v.alu_inst0__DOT__or_AB;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel 
	= (1 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__or_AB)
		 ? 1 : 0));
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__dec_B 
	= vlSymsp->TOP__v.alu_inst0__DOT__dec_B;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__dec_B 
	= vlSymsp->TOP__v.alu_inst0__DOT__dec_B;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__cpl_A 
	= vlSymsp->TOP__v.alu_inst0__DOT__cpl_A;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__cpl_A 
	= vlSymsp->TOP__v.alu_inst0__DOT__cpl_A;
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__cpl_B 
	= vlSymsp->TOP__v.alu_inst0__DOT__cpl_B;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__cpl_B 
	= vlSymsp->TOP__v.alu_inst0__DOT__cpl_B;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b 
	= (0xff & ((1 & ((((~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__sub_AB)) 
			   & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__inc_A))) 
			  & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_A))) 
			 & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_B))))
		    ? ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__dec_A)
		        ? 0xff : (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Breg))
		    : ((((IData)(vlSymsp->TOP__v.alu_inst0__DOT__sub_AB) 
			 & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__inc_A))) 
			| (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_B))
		        ? (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Breg))
		        : ((((~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__sub_AB)) 
			     & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__inc_A)) 
			    & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_B)))
			    ? 0 : ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_A)
				    ? 0 : (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b))))));
    vlSymsp->TOP__v.alu_inst0__DOT__controller__DOT__inc_B 
	= vlSymsp->TOP__v.alu_inst0__DOT__inc_B;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__inc_B 
	= vlSymsp->TOP__v.alu_inst0__DOT__inc_B;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_in 
	= (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__sub_AB) 
	    | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__inc_A)) 
	   | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__inc_B));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_a 
	= (0xff & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_B)
		    ? 0 : ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_A)
			    ? (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Areg))
			    : ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__inc_B)
			        ? 0 : ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__dec_B)
				        ? 0xff : (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Areg))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__direction 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_direction;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XORsel 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__ORsel 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__carry_in 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_in;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__x 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_a;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY 
	= ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_a) 
	   ^ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY 
	= ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_a) 
	   & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY 
	= ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_a) 
	   | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b));
}

void Valu_tb_alu_tb::_combo__TOP__v__14(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_combo__TOP__v__14"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b 
	= (0xff & ((1 & ((((~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__sub_AB)) 
			   & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__inc_A))) 
			  & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_A))) 
			 & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_B))))
		    ? ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__dec_A)
		        ? 0xff : (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Breg))
		    : ((((IData)(vlSymsp->TOP__v.alu_inst0__DOT__sub_AB) 
			 & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__inc_A))) 
			| (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_B))
		        ? (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__Breg))
		        : ((((~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__sub_AB)) 
			     & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__inc_A)) 
			    & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_B)))
			    ? 0 : ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_A)
				    ? 0 : (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY 
	= ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_a) 
	   ^ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY 
	= ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_a) 
	   & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY 
	= ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_a) 
	   | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_b));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__xor_result 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__and_result 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__or_result 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY;
    // ALWAYS at /home/leonous/projects/verilog/ecpu/components/alu/../adder/alu_adder.v:54
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1fe & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_in));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xfe & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (1 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY) 
		   ^ ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
		      & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1fd & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (2 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		    | (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
			| (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel)) 
		       & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY))) 
		   << 1)));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 1;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xfd & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (2 & ((0xfffffffe & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		   ^ (0xfffffffe & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				    & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
				       << 1))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1fb & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (4 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		    << 1) | (((0xfffffffc & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
					     << 1)) 
			      | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				 << 2)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					   << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 2;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xfb & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (4 & ((0xfffffffc & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		   ^ (0xfffffffc & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				    & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
				       << 2))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1f7 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (8 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		    << 1) | (((0xfffffff8 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
					     << 1)) 
			      | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				 << 3)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					   << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 3;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xf7 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (8 & ((0xfffffff8 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		   ^ (0xfffffff8 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				    & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
				       << 3))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1ef & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (0x10 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		       << 1) | (((0xfffffff0 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
						<< 1)) 
				 | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				    << 4)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					      << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 4;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xef & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (0x10 & ((0xfffffff0 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		      ^ (0xfffffff0 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				       & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
					  << 4))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1df & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (0x20 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		       << 1) | (((0xffffffe0 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
						<< 1)) 
				 | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				    << 5)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					      << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 5;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xdf & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (0x20 & ((0xffffffe0 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		      ^ (0xffffffe0 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				       & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
					  << 5))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1bf & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (0x40 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		       << 1) | (((0xffffffc0 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
						<< 1)) 
				 | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				    << 6)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					      << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 6;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xbf & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (0x40 & ((0xffffffc0 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		      ^ (0xffffffc0 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				       & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
					  << 6))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x17f & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (0x80 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		       << 1) | (((0xffffff80 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
						<< 1)) 
				 | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				    << 7)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					      << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 7;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0x7f & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (0x80 & ((0xffffff80 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		      ^ (0xffffff80 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				       & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
					  << 7))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0xff & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (0x100 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
			<< 1) | (((0xffffff00 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
						 << 1)) 
				  | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				     << 8)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					       << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 8;
}

void Valu_tb_alu_tb::_sequent__TOP__v__15(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_sequent__TOP__v__15"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter__DOT__direction 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_direction;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XORsel 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__ORsel 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__carry_in 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_in;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__x 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_in_a;
}

void Valu_tb_alu_tb::_settle__TOP__v__16(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_settle__TOP__v__16"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__xor_result 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__and_result 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__or_result 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY;
    // ALWAYS at /home/leonous/projects/verilog/ecpu/components/alu/../adder/alu_adder.v:54
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1fe & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_in));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xfe & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (1 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY) 
		   ^ ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
		      & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1fd & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (2 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		    | (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
			| (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel)) 
		       & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY))) 
		   << 1)));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 1;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xfd & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (2 & ((0xfffffffe & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		   ^ (0xfffffffe & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				    & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
				       << 1))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1fb & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (4 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		    << 1) | (((0xfffffffc & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
					     << 1)) 
			      | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				 << 2)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					   << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 2;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xfb & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (4 & ((0xfffffffc & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		   ^ (0xfffffffc & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				    & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
				       << 2))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1f7 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (8 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		    << 1) | (((0xfffffff8 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
					     << 1)) 
			      | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				 << 3)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					   << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 3;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xf7 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (8 & ((0xfffffff8 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		   ^ (0xfffffff8 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				    & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
				       << 3))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1ef & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (0x10 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		       << 1) | (((0xfffffff0 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
						<< 1)) 
				 | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				    << 4)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					      << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 4;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xef & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (0x10 & ((0xfffffff0 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		      ^ (0xfffffff0 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				       & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
					  << 4))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1df & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (0x20 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		       << 1) | (((0xffffffe0 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
						<< 1)) 
				 | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				    << 5)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					      << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 5;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xdf & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (0x20 & ((0xffffffe0 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		      ^ (0xffffffe0 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				       & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
					  << 5))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x1bf & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (0x40 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		       << 1) | (((0xffffffc0 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
						<< 1)) 
				 | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				    << 6)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					      << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 6;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0xbf & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (0x40 & ((0xffffffc0 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		      ^ (0xffffffc0 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				       & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
					  << 6))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0x17f & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (0x80 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
		       << 1) | (((0xffffff80 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
						<< 1)) 
				 | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				    << 7)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					      << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 7;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out 
	= ((0x7f & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out)) 
	   | (0x80 & ((0xffffff80 & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XxorY)) 
		      ^ (0xffffff80 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
				       & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderXORsel) 
					  << 7))))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out 
	= ((0xff & (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out)) 
	   | (0x100 & (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XandY) 
			<< 1) | (((0xffffff00 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
						 << 1)) 
				  | ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adderORsel) 
				     << 8)) & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__XorY) 
					       << 1)))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__i = 8;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__z 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__alu_out 
	= (0xff & ((((IData)(vlSymsp->TOP__v.alu_inst0__DOT__and_AB) 
		     | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__or_AB)) 
		    & ((~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__sl_AB)) 
		       & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__sr_AB))))
		    ? ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
		       >> 1) : (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__sl_AB) 
				 | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__sr_AB))
				 ? (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_out)
				 : (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__carry_out 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry 
	= (1 & (((((((IData)(vlSymsp->TOP__v.alu_inst0__DOT__add_AB) 
		     & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__and_AB))) 
		    & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__or_AB))) 
		   & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__xor_AB))) 
		  & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_B))) 
		 & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__clr_ALL)))
		 ? (1 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
			 >> 8)) : ((((((IData)(vlSymsp->TOP__v.alu_inst0__DOT__and_AB) 
				       | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__or_AB)) 
				      | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__xor_AB)) 
				     | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_B)) 
				    | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__clr_ALL))
				    ? 0 : (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__sl_AB) 
					    | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__sr_AB))
					    ? (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_carry)
					    : (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry)))));
}

void Valu_tb_alu_tb::_combo__TOP__v__17(Valu_tb__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(cout<<"      Valu_tb_alu_tb::_combo__TOP__v__17"<<endl; );
    Valu_tb* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__z 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__alu_out 
	= (0xff & ((((IData)(vlSymsp->TOP__v.alu_inst0__DOT__and_AB) 
		     | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__or_AB)) 
		    & ((~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__sl_AB)) 
		       & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__sr_AB))))
		    ? ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
		       >> 1) : (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__sl_AB) 
				 | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__sr_AB))
				 ? (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_out)
				 : (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder_out))));
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__adder__DOT__carry_out 
	= vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out;
    vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry 
	= (1 & (((((((IData)(vlSymsp->TOP__v.alu_inst0__DOT__add_AB) 
		     & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__and_AB))) 
		    & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__or_AB))) 
		   & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__xor_AB))) 
		  & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_B))) 
		 & (~ (IData)(vlSymsp->TOP__v.alu_inst0__DOT__clr_ALL)))
		 ? (1 & ((IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry_out) 
			 >> 8)) : ((((((IData)(vlSymsp->TOP__v.alu_inst0__DOT__and_AB) 
				       | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__or_AB)) 
				      | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__xor_AB)) 
				     | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__cpl_B)) 
				    | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__clr_ALL))
				    ? 0 : (((IData)(vlSymsp->TOP__v.alu_inst0__DOT__sl_AB) 
					    | (IData)(vlSymsp->TOP__v.alu_inst0__DOT__sr_AB))
					    ? (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__shifter_carry)
					    : (IData)(vlSymsp->TOP__v.alu_inst0__DOT__datapath__DOT__carry)))));
}
