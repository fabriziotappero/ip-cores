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

#ifndef H_Work_ps2_kbd_pckg_H
#define H_Work_ps2_kbd_pckg_H

#ifdef __MINGW32__
#include "xsimMinGW.h"
#else
#include "xsim.h"
#endif


#include "ieee/numeric_std/numeric_std.h"
#include "ieee/std_logic_1164/std_logic_1164.h"

class Work_ps2_kbd_pckg: public HSim__s6 {
public:
  Work_ps2_kbd_pckg(const HSimString &name);
  ~Work_ps2_kbd_pckg();
};

extern Work_ps2_kbd_pckg *WorkPs2_kbd_pckg;

#endif
