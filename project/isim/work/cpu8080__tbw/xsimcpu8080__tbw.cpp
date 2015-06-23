#include "isim/work/cpu8080__tbw/cpu8080__tbw.h"
#include "isim/work/glbl/glbl.h"
static const char * HSimCopyRightNotice = "Copyright 2004-2005, Xilinx Inc. All rights reserved.";
#include "C:/Xilinx/vhdl/hdp/nt/ieee/std_logic_1164/std_logic_1164.h"
#include "C:/Xilinx/vhdl/hdp/nt/ieee/numeric_std/numeric_std.h"
#include "isim/work/common/common.h"
#include "isim/unisim.auxlib/vcomponents/vcomponents.h"


#include "work/cpu8080__tbw/cpu8080__tbw.h"
static HSim__s6* IF0(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMcpu8080__tbw(label); 
    return blk;
}


#include "work/chrrom/chrrom.h"
static HSim__s6* IF1(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMchrrom(label); 
    return blk;
}


#include "work/alu/alu.h"
static HSim__s6* IF2(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMalu(label); 
    return blk;
}


#include "work/selectone/selectone.h"
static HSim__s6* IF3(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMselectone(label); 
    return blk;
}


#include "work/scnromu/scnromu.h"
static HSim__s6* IF4(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMscnromu(label); 
    return blk;
}


#include "work/scnrom/scnrom.h"
static HSim__s6* IF5(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMscnrom(label); 
    return blk;
}


#include "work/chrmemmap/chrmemmap.h"
static HSim__s6* IF6(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMchrmemmap(label); 
    return blk;
}


#include "work/terminal/terminal.h"
static HSim__s6* IF7(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMterminal(label); 
    return blk;
}


#include "work/select/select.h"
static HSim__s6* IF8(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMselect(label); 
    return blk;
}


#include "work/rom/rom.h"
static HSim__s6* IF9(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMrom(label); 
    return blk;
}


#include "work/ram/ram.h"
static HSim__s6* IF10(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMram(label); 
    return blk;
}


#include "work/intcontrol/intcontrol.h"
static HSim__s6* IF11(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMintcontrol(label); 
    return blk;
}


#include "work/cpu8080/cpu8080.h"
static HSim__s6* IF12(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMcpu8080(label); 
    return blk;
}


#include "work/testbench/testbench.h"
static HSim__s6* IF13(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMtestbench(label); 
    return blk;
}


#include "work/glbl/glbl.h"
static HSim__s6* IF14(HSim__s6 *Arch,const char* label,int nGenerics, 
va_list vap)
{
    HSim__s6 *blk = new workMglbl(label); 
    return blk;
}


static HSim__s6* IF15(HSim__s6 *Arch,const char* label,int nGenerics,va_list vap)
{
    extern HSim__s6* createWork_vga_vga_arch(const char*);
    HSim__s6 *blk = createWork_vga_vga_arch(label);
    return blk;
}


static HSim__s6* IF16(HSim__s6 *Arch,const char* label,int nGenerics,va_list vap)
{
    extern HSim__s6* createWork_ps2_kbd_arch(const char*);
    HSim__s6 *blk = createWork_ps2_kbd_arch(label);
    return blk;
}


static HSim__s6* IF17(HSim__s6 *Arch,const char* label,int nGenerics,va_list vap)
{
    extern HSim__s6* createWork_vga_vga_arch(const char*);
    HSim__s6 *blk = createWork_vga_vga_arch(label);
    return blk;
}


static HSim__s6* IF18(HSim__s6 *Arch,const char* label,int nGenerics,va_list vap)
{
    extern HSim__s6* createWork_ps2_kbd_arch(const char*);
    HSim__s6 *blk = createWork_ps2_kbd_arch(label);
    return blk;
}

class _top : public HSim__s6 {
public:
    _top() : HSim__s6(false, "_top", "_top", 0, 0, HSim::VerilogModule) {}
    HSimConfigDecl * topModuleInstantiate() {
        HSimConfigDecl * cfgvh = 0;
        cfgvh = new HSimConfigDecl("default");
        (*cfgvh).addVlogModule("cpu8080_tbw", (HSimInstFactoryPtr)IF0);
        (*cfgvh).addVlogModule("chrrom", (HSimInstFactoryPtr)IF1);
        (*cfgvh).addVlogModule("alu", (HSimInstFactoryPtr)IF2);
        (*cfgvh).addVlogModule("selectone", (HSimInstFactoryPtr)IF3);
        (*cfgvh).addVlogModule("scnromu", (HSimInstFactoryPtr)IF4);
        (*cfgvh).addVlogModule("scnrom", (HSimInstFactoryPtr)IF5);
        (*cfgvh).addVlogModule("chrmemmap", (HSimInstFactoryPtr)IF6);
        (*cfgvh).addVlogModule("terminal", (HSimInstFactoryPtr)IF7);
        (*cfgvh).addVlogModule("select", (HSimInstFactoryPtr)IF8);
        (*cfgvh).addVlogModule("rom", (HSimInstFactoryPtr)IF9);
        (*cfgvh).addVlogModule("ram", (HSimInstFactoryPtr)IF10);
        (*cfgvh).addVlogModule("intcontrol", (HSimInstFactoryPtr)IF11);
        (*cfgvh).addVlogModule("cpu8080", (HSimInstFactoryPtr)IF12);
        (*cfgvh).addVlogModule("testbench", (HSimInstFactoryPtr)IF13);
        (*cfgvh).addVlogModule("glbl", (HSimInstFactoryPtr)IF14);
        (*cfgvh).addVlogModule("vga/vga_arch", (HSimInstFactoryPtr)IF15, true);
        (*cfgvh).addVlogModule("ps2_kbd/arch", (HSimInstFactoryPtr)IF16, true);
        (*cfgvh).addVlogModule("vga", (HSimInstFactoryPtr)IF17, true);
        (*cfgvh).addVlogModule("ps2_kbd", (HSimInstFactoryPtr)IF18, true);
        HSim__s5 * topvl = 0;
        topvl = new workMcpu8080__tbw("cpu8080_tbw");
        topvl->moduleInstantiate(cfgvh);
        addChild(topvl);
        topvl = new workMglbl("glbl");
        topvl->moduleInstantiate(cfgvh);
        addChild(topvl);
        return cfgvh;
}
};

main(int argc, char **argv) {
  HSimDesign::initDesign();
  globalKernel->getOptions(argc,argv);
  HSim__s6 * _top_i = 0;
  try {
    IeeeStd_logic_1164=new Ieee_std_logic_1164("Std_logic_1164");
    IeeeNumeric_std=new Ieee_numeric_std("Numeric_std");
    WorkCommon=new Work_common("Common");
    UnisimVcomponents=new Unisim_vcomponents("Vcomponents");
    HSimConfigDecl *cfg;
 _top_i = new _top();
  cfg =  _top_i->topModuleInstantiate();
    return globalKernel->runTcl(cfg, _top_i, "_top", argc, argv);
  }
  catch (HSimError& msg){
    try {
      globalKernel->error(msg.ErrMsg);
      return 1;
    }
    catch(...) {}
      return 1;
  }
  catch (...){
    globalKernel->fatalError();
    return 1;
  }
}
