// Verilated -*- C++ -*-
#ifndef _Valu_tb__Syms_H_
#define _Valu_tb__Syms_H_


// INCLUDE MODULE CLASSES
#include "Valu_tb.h"
#include "Valu_tb_alu_tb.h"

// SYMS CLASS
class Valu_tb__Syms {
  public:
    
    // LOCAL STATE
    const char* __Vm_namep;
    bool	__Vm_activity;		///< Used by trace routines to determine change occurred
    bool	__Vm_didInit;
    char	__VpadToAlign10[6];
    
    // SUBCELL STATE
    Valu_tb*                       TOPp;
    Valu_tb_alu_tb                 TOP__v;
    
    // COVERAGE
    
    // CREATORS
    Valu_tb__Syms(Valu_tb* topp, const char* namep);
    ~Valu_tb__Syms() {};
    
    // METHODS
    inline const char* name() { return __Vm_namep; }
    inline bool getClearActivity() { bool r=__Vm_activity; __Vm_activity=false; return r;}
    
} VL_ATTR_ALIGNED(64);
#endif  /*guard*/
