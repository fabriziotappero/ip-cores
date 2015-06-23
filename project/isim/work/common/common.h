////////////////////////////////////////////////////////////////////////////////
//   ____  ____   
//  /   /\/   /  
// /___/  \  /   
// \   \   \/  
//  \   \        Copyright (c) 2003-2004 Xilinx, Inc.
//  /   /        All Right Reserved. 
// /---/   /\     
// \   \  /  \  
//  \___\/\___\
////////////////////////////////////////////////////////////////////////////////

#ifndef H_Work_common_H
#define H_Work_common_H

#ifdef __MINGW32__
#include "xsimMinGW.h"
#else
#include "xsim.h"
#endif


#include "ieee/numeric_std/numeric_std.h"
#include "ieee/std_logic_1164/std_logic_1164.h"

class Work_common: public HSim__s6 {
public:
HSim__s4 Ea;
HSim__s4 Ec;
HSim__s4 Ee;
HSim__s4 Eg;
HSim__s4 Ei;
HSim__s4 Ek;
/* subprogram name boolean2stdlogic */
char Gu(const char Eq);
/* subprogram name log2 */
int GB(const int Ey);

public:

public:
  Work_common(const HSimString &name);
  ~Work_common();
};

extern Work_common *WorkCommon;

#endif
