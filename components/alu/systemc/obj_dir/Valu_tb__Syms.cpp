// Verilated -*- C++ -*-

#include "Valu_tb__Syms.h"
#include "Valu_tb.h"
#include "Valu_tb_alu_tb.h"

// FUNCTIONS
Valu_tb__Syms::Valu_tb__Syms(Valu_tb* topp, const char* namep)
	// Setup locals
	: __Vm_namep(namep)
	, __Vm_activity(false)
	, __Vm_didInit(false)
	// Setup submodule names
	, TOP__v                         (Verilated::catName(topp->name(),".v"))
{
    // Pointer to top level
    TOPp = topp;
    // Setup each module's pointers to their submodules
    TOPp->v                         = &TOP__v;
    // Setup each module's pointer back to symbol table (for public functions)
    TOPp->__Vconfigure(this, true);
    TOP__v.__Vconfigure(this, true);
}

