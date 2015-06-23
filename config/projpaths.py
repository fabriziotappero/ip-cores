#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-

import os, sys, shelve, shutil
from os.path import join

# Way to get project root from any script importing this one :-)
PROJROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

BUILDDIR = join(PROJROOT, "build")
TOOLSDIR = join(PROJROOT, "tools")
CML2_CONFIG_SRCDIR = join(PROJROOT, "config/cml")
CML2_CONT_DEFFILE = join(PROJROOT, 'config/cml/container_ruleset.template')
CML2TOOLSDIR = join(TOOLSDIR, "cml2-tools")
CML2_COMPILED_RULES = join(BUILDDIR, "rules.compiled")
CML2_CONFIG_FILE = join(BUILDDIR, "config.cml")
CML2_CONFIG_FILE_SAVED = join(BUILDDIR, "config.cml.saved")
CML2_CONFIG_H = join(BUILDDIR, "config.h")
CML2_AUTOGEN_RULES = join(BUILDDIR, 'config.rules')
CONFIG_H = join("include/l4/config.h")
CONFIG_SHELVE_DIR = join(BUILDDIR, "configdata")
CONFIG_SHELVE_FILENAME = "configuration"
CONFIG_SHELVE = join(CONFIG_SHELVE_DIR, CONFIG_SHELVE_FILENAME)
KERNEL_CINFO_PATH = join(PROJROOT, "src/generic/cinfo.c")
LINUXDIR = join(PROJROOT, 'conts/linux')
LINUX_KERNELDIR = join(LINUXDIR, 'linux-2.6.33')
LINUX_ROOTFSDIR = join(LINUXDIR, 'rootfs')
LINUX_ATAGSDIR = join(LINUXDIR, 'atags')

POSIXDIR = join(PROJROOT, 'conts/posix')
POSIX_BOOTDESCDIR = join(POSIXDIR, 'bootdesc')

projpaths = {   \
    'LINUX_ATAGSDIR'  : LINUX_ATAGSDIR, \
    'LINUX_ROOTFSDIR' : LINUX_ROOTFSDIR, \
    'LINUX_KERNELDIR' : LINUX_KERNELDIR, \
    'LINUXDIR' : LINUXDIR, \
    'BUILDDIR' : BUILDDIR, \
    'POSIXDIR' : POSIXDIR, \
    'POSIX_BOOTDESCDIR' : POSIX_BOOTDESCDIR
}
