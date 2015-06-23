#!/usr/bin/env python

"""compile, build and download the SP605 demo to the SP605 development kit"""

import sys
import os
import shutil

from user_settings import xilinx

current_directory = os.getcwd()
working_directory = "SP605"
shutil.copyfile("xilinx_input/SP605.ucf", os.path.join(working_directory, "SP605.ucf"))
shutil.copyfile("xilinx_input/SP605.prj", os.path.join(working_directory, "SP605.prj"))
shutil.copyfile("xilinx_input/xst_mixed.opt", os.path.join(working_directory, "xst_mixed.opt"))
shutil.copyfile("xilinx_input/balanced.opt", os.path.join(working_directory, "balanced.opt"))
shutil.copyfile("xilinx_input/bitgen.opt", os.path.join(working_directory, "bitgen.opt"))
os.chdir(working_directory)

if "compile" in sys.argv or "all" in sys.argv:
    print "Compiling C files using chips ...."
    retval = os.system("../chips2/c2verilog no_reuse ../source/user_design_sp605.c")
    retval = os.system("../chips2/c2verilog no_reuse ../source/server.c")
    if retval != 0:
        sys.exit(-1)

if "build" in sys.argv or "all" in sys.argv:
    print "Building Demo using Xilinx ise ...."
    retval = os.system("%s/xflow -synth xst_mixed.opt -p XC6Slx45t-fgg484 -implement balanced.opt -config bitgen.opt SP605"%xilinx)
    if retval != 0:
        sys.exit(-1)

if "download" in sys.argv or "all" in sys.argv:
    print "Downloading bit file to development kit ...."
    command_file = open("download.cmd", 'w')
    command_file.write("setmode -bscan\n")
    command_file.write("setCable -p auto\n")
    command_file.write("identify\n")
    command_file.write("assignfile -p 2 -file SP605.bit\n")
    command_file.write("program -p 2\n")
    command_file.write("quit\n")
    command_file.close()
    retval = os.system("%s/impact -batch download.cmd"%xilinx)
    if retval != 0:
        sys.exit(-1)

os.chdir(current_directory)
