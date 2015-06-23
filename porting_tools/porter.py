#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
#
# Top-level clean script for Codezero
#
# Cleans the Codezero environment
#

import ConfigParser
import string
import re
import os
import shutil
import fnmatch


# project root path
c0root = '..'

# read configuration file
conf = ConfigParser.ConfigParser()
conf.read("port.cfg")

arch = conf.get("Architecture", "ARCH")
prefix = conf.get("Compiler", "TOOLCHAIN_PREFIX")
march = conf.get("Compiler", "MARCH_FLAG")


########################
# change configure.py
########################
print "\n### Changing configure.py..."

confpy_in = open(c0root + "/configure.py", 'r').readlines()
confpy_out = open(c0root + "/configure.py", 'w')

for line in confpy_in:
    if re.match(".*options.arch = \"arm\"", line):
        line = line.replace("arm", arch)

    confpy_out.write(line)

confpy_out.close()

print "### OK"


########################
# create cml2 ruleset
#######################
print "\n### Creating " + arch + ".ruleset"

ruleset_path = c0root + "/config/cml/"
arm_ruleset = open(ruleset_path + "arm.ruleset", 'rU')
arch_ruleset = open(ruleset_path + arch + ".ruleset", 'w')

for line in arm_ruleset:
    line = line.replace("ARM", arch.upper())
    line = line.replace("arm", arch)
    if re.match("default TOOLCHAIN_USERSPACE from", line):
        line = "default TOOLCHAIN_USERSPACE from '" + prefix + "'\n"
    if re.match("default TOOLCHAIN_KERNEL from", line):
        line = "default TOOLCHAIN_KERNEL from '" + prefix + "'\n"

    arch_ruleset.write(line)

arm_ruleset.close()
arch_ruleset.close()

print "### OK"


########################
# remove march flag
########################

def remove_march(scon_file):
    scon_file_in = open(scon_file, 'r').readlines()

    scon_file_out = open(scon_file, 'w')

    for line in scon_file_in:
        if re.search(", '-march=' \+ gcc_arch_flag", line):
            line = line.replace(", '-march=' + gcc_arch_flag", "")
        elif re.search("'-march=' \+ gcc_arch_flag,", line):
            line = line.replace("'-march=' + gcc_arch_flag,", "")

        scon_file_out.write(line)

    scon_file_out.close()

# ENDF remove_march()

if (march == 'N'):
    print "\n### Removing -march flag from SConscript files..."

    for top, dirs, filenames in os.walk(c0root):
        for filename in filenames:
            if re.match("SConstruct[.*]?", filename):
                scon_file = os.path.join(top, filename)
                print "Processing", scon_file
                remove_march(scon_file)

print "### OK"


###########################
# Hide all assebly files
###########################
print "\n### Renaming <name>.S files to <name>.S.ARM (to remove them from the compilation)..."

for top, dirs, filenames in os.walk(c0root):
    for file in filenames:
        if fnmatch.fnmatch(file, '*.S'):
            S_path = os.path.join(top, file)
            print "Renaming file", S_path
            os.rename(S_path, S_path + ".ARM")

print "### OK"


########################
# Create <arch> dirs
########################
print "\n### Adding missing <arch> directories (by copying existing arm and arch-arm dirs)..."

for top, dirs, filenames in os.walk(c0root):
    for dir in dirs:
        if re.match("(arch-)?arm", dir):
            arm_dir = os.path.join(top, dir)
            arch_dir = arm_dir.replace("arm", arch)
            #print "Copying", arm_dir,"to", arch_dir, "..."
            #shutil.copytree(arm_dir, arch_dir)
            print arch_dir

print "### OK"


########################
# Fix broken symlinks
########################
print "\n### Fixing broken symlinks (possibly produced by moving arm dirs to <arch> dirs)..."

for top, dirs, filenames in os.walk(c0root):
    for file in filenames:
        symlink_path = os.path.join(top, file)
        if os.path.islink(symlink_path) and not os.path.exists(symlink_path):
            symlink_source = os.readlink(symlink_path)
            if re.search("arm", symlink_source):
                fixed_symlink_source = symlink_source.replace("arm", arch)
                print "Fixing", symlink_path, "to point to", fixed_symlink_source
                os.unlink(symlink_path)
                os.symlink(fixed_symlink_source, symlink_path)

print "### OK"

"""
#######################################
# Hard coded stuff in main SConstruct
######################################


#create_kernel_linker = Command(join(builddir, 'include/l4/arch/arm/linker.lds'), \
#                               join(PROJROOT, 'include/l4/arch/arm/linker.lds.in'), \
#                               generate_kernel_linker_script)

"""


