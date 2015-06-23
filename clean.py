#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
#
# Top-level clean script for Codezero
#
# Cleans the Codezero environment
#
import os, sys, shelve, shutil

# clean the kernel
print "\n### Cleaning the kernel..."
os.system("scons -c")

# clean user libraries
print "\n### Cleaning user libs"
os.system("scons -f SConstruct.userlibs -c")

# clean the loader (the packer around kernel.elf)
print "\n### Cleaning loader..."
os.system("scons -f SConstruct.loader -c")

# rem build dir
print "\n### Removing build dir..."
if os.path.exists("build"):
    shutil.rmtree("build")
