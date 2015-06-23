#!/usr/bin/python

import os,sys
from stat import *

filelist = ["lcfg.v","tv80_alu.v","tv80_core.v",
            "tv80_mcode.v","tv80_reg.v","tv80s.v",
            "lcfg_cfgo_regs.v","lcfg_memctl.v",
            "lcfg_cfgo_driver.v","behave1p_mem.v"]
basepath = "../../rtl"
command = "verilator --sc --trace -O3"

def walktree (top, target):
    found = ""
    for f in os.listdir(top):
        pathname = os.path.join(top, f)
        mode = os.stat(pathname)[ST_MODE]
        if S_ISDIR(mode):
            found = walktree (pathname, target)
            if (found != ''): return found
        elif S_ISREG(mode):
            if os.path.basename(f) == target:
                return pathname
        else:
            print "Skipping %s" % pathname
    return ""

def run_verilator ():
    expfilelist = map(lambda x:walktree(basepath,x), filelist)
    cmd = command + " " + " ".join(expfilelist)
    print "Executing",cmd
    os.system (cmd)
    print "Removing old object files"
    os.system ("rm -f obj_dir/*.o")


run_verilator()



