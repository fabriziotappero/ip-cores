#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
#
#  Codezero -- a microkernel for embedded systems.
#
#  Copyright © 2009  B Labs Ltd

import os, sys, shelve, shutil
from os.path import join

PROJRELROOT = "../.."
SCRIPTROOT = os.path.abspath(os.path.dirname("."))
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), PROJRELROOT)))

from config.projpaths import *
from config.configuration import *

# Create linux kernel build directory path as:
# conts/linux -> build/cont[0-9]/linux
def source_to_builddir(srcdir, id):
    cont_builddir = \
        os.path.relpath(srcdir, \
                        PROJROOT).replace("conts", \
                                          "cont" + str(id))
    return join(BUILDDIR, cont_builddir)

class AtagsBuilder:

    def __init__(self, pathdict, container):
        self.LINUX_ATAGSDIR = pathdict["LINUX_ATAGSDIR"]
        self.LINUX_ATAGS_BUILDDIR = \
            source_to_builddir(self.LINUX_ATAGSDIR, container.id)

        self.atags_lds_in = join(self.LINUX_ATAGSDIR, "atags.lds.in")
        self.atags_lds_out = join(self.LINUX_ATAGS_BUILDDIR, "atags.lds")

        self.atags_elf_out = join(self.LINUX_ATAGS_BUILDDIR, "atags.elf")

        self.atags_S_in = join(self.LINUX_ATAGSDIR, "atags.S.in")
        self.atags_S_out = join(self.LINUX_ATAGS_BUILDDIR, "atags.S")

        self.atags_c_in = join(self.LINUX_ATAGSDIR, "atags.c.in")
        self.atags_c_out = join(self.LINUX_ATAGS_BUILDDIR, "atags.c")

        self.atags_h_in = join(self.LINUX_ATAGSDIR, "atags.h.in")
        self.atags_h_out = join(self.LINUX_ATAGS_BUILDDIR, "atags.h")

        self.cont_id = container.id
        self.elf_relpath = os.path.relpath(self.atags_elf_out, \
                                           self.LINUX_ATAGSDIR)

    def build_atags(self, config):
        print 'Building Atags for linux kenel...'
        # IO files from this build
        os.chdir(LINUX_ATAGSDIR)
        if not os.path.exists(self.LINUX_ATAGS_BUILDDIR):
            os.makedirs(self.LINUX_ATAGS_BUILDDIR)

        with open(self.atags_S_in, 'r') as input:
            with open(self.atags_S_out, 'w+') as output:
                output.write(input.read() % self.elf_relpath)

        with open(self.atags_h_out, 'w+') as output:
            with open(self.atags_h_in, 'r') as input:
                output.write(input.read() % {'cn' : self.cont_id})

        os.system(config.toolchain_userspace + "cpp -I%s -P %s > %s" % \
                  (self.LINUX_ATAGS_BUILDDIR, self.atags_lds_in, \
                   self.atags_lds_out))

        with open(self.atags_c_out, 'w+') as output:
            with open(self.atags_c_in, 'r') as input:
                output.write(input.read() % {'cn' : self.cont_id})

        os.system(config.toolchain_userspace + "gcc " + \
                  "-g -ffreestanding -std=gnu99 -Wall -Werror " + \
                  "-nostdlib -o %s -T%s %s" % \
                    (self.atags_elf_out, self.atags_lds_out, self.atags_c_out))
        print "Done..."

    def clean(self):
        print 'Cleaning Atags...'
        if os.path.exists(self.LINUX_ATAGS_BUILDDIR):
            shutil.rmtree(self.LINUX_ATAGS_BUILDDIR)
        print 'Done...'

if __name__ == "__main__":
    # This is only a default test case
    container = Container()
    container.id = 0
    atags_builder = AtagsBuilder(projpaths, container)

    if len(sys.argv) == 1:
        atags_builder.build_atags()
    elif "clean" == sys.argv[1]:
        atags_builder.clean()
    else:
        print " Usage: %s [clean]" % (sys.argv[0])
