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

class RootfsBuilder:

    def __init__(self, pathdict, container):
        self.LINUX_ROOTFSDIR = pathdict["LINUX_ROOTFSDIR"]
        self.LINUX_ROOTFS_BUILDDIR = \
            source_to_builddir(self.LINUX_ROOTFSDIR, container.id)

        self.rootfs_lds_in = join(self.LINUX_ROOTFSDIR, "rootfs.lds.in")
        self.rootfs_lds_out = join(self.LINUX_ROOTFS_BUILDDIR, "rootfs.lds")

        self.rootfs_h_in = join(self.LINUX_ROOTFSDIR, "rootfs.h.in")
        self.rootfs_h_out = join(self.LINUX_ROOTFS_BUILDDIR, "rootfs.h")

        self.rootfs_elf_out = join(self.LINUX_ROOTFS_BUILDDIR, "rootfs.elf")
        self.cont_id = container.id

    def build_rootfs(self, config):
        print 'Building the root filesystem...'
        # IO files from this build
        os.chdir(LINUX_ROOTFSDIR)
        if not os.path.exists(self.LINUX_ROOTFS_BUILDDIR):
            os.makedirs(self.LINUX_ROOTFS_BUILDDIR)

        with open(self.rootfs_h_out, 'w+') as output:
            with open(self.rootfs_h_in, 'r') as input:
                output.write(input.read() % {'cn' : self.cont_id})

        os.system(config.toolchain_userspace + "cpp -I%s -P %s > %s" % \
                  (self.LINUX_ROOTFS_BUILDDIR, self.rootfs_lds_in, \
                   self.rootfs_lds_out))
        os.system(config.toolchain_userspace + "gcc " + \
                  "-nostdlib -o %s -T%s rootfs.S" % (self.rootfs_elf_out, \
                                                     self.rootfs_lds_out))
        print "Done..."

    def clean(self):
        print 'Cleaning the built root filesystem...'
        if os.path.exists(self.LINUX_ROOTFS_BUILDDIR):
            shutil.rmtree(self.LINUX_ROOTFS_BUILDDIR)
        print 'Done...'

if __name__ == "__main__":
    # This is only a default test case
    container = Container()
    container.id = 0
    rootfs_builder = RootfsBuilder(projpaths, container)

    if len(sys.argv) == 1:
        rootfs_builder.build_rootfs()
    elif "clean" == sys.argv[1]:
        rootfs_builder.clean()
    else:
        print " Usage: %s [clean]" % (sys.argv[0])
