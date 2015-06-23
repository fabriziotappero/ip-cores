#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
#
#  Codezero -- a microkernel for embedded systems.
#
#  Copyright © 2009  B Labs Ltd
#
import os, sys, shelve, glob
from os.path import join
from tools.pyelf.elfsize import *
from tools.pyelf.elf_section_info import *

PROJRELROOT = '../../'

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), PROJRELROOT)))
sys.path.append(os.path.abspath("../"))

from config.projpaths import *
from config.configuration import *
from scripts.linux.build_linux import *
from scripts.linux.build_rootfs import *
from scripts.linux.build_atags import *
from pack import *
from packall import *

def fill_pager_section_markers(cont, pager_binary):
    cont.pager_rw_section_start, cont.pager_rw_section_end, \
    cont.pager_rx_section_start, cont.pager_rx_section_end = \
        elf_loadable_section_info(join(PROJROOT, pager_binary))

def build_linux_container(config, projpaths, container):
    linux_builder = LinuxBuilder(projpaths, container)
    linux_builder.build_linux(config)

    rootfs_builder = RootfsBuilder(projpaths, container)
    rootfs_builder.build_rootfs(config)
    atags_builder = AtagsBuilder(projpaths, container)
    atags_builder.build_atags(config)

    # Calculate and store size of pager
    pager_binary = \
        join(BUILDDIR, "cont" + str(container.id) +
                        "/linux/linux-2.6.33/linux.elf")
    config.containers[container.id].pager_size = \
            conv_hex(elf_binary_size(pager_binary))

    fill_pager_section_markers(config.containers[container.id], pager_binary)

    linux_container_packer = \
        LinuxContainerPacker(container, linux_builder, \
                             rootfs_builder, atags_builder)
    return linux_container_packer.pack_container(config)

def glob_by_walk(arg, dirname, names):
    ext, imglist = arg
    files = glob.glob(join(dirname, ext))
    imglist.extend(files)

def source_to_builddir(srcdir, id):
    cont_builddir = \
        os.path.relpath(srcdir, \
                        PROJROOT).replace("conts", \
                                          "cont" + str(id))
    return join(BUILDDIR, cont_builddir)

# We simply use SCons to figure all this out from container.id
# This is very similar to examples container builder:
# In fact this notion may become a standard convention for
# calling specific bare containers
def build_posix_container(config, projpaths, container):
    images = []
    cwd = os.getcwd()
    os.chdir(POSIXDIR)
    print '\nBuilding Posix Container %d...' % container.id
    scons_cmd = 'scons ' + 'cont=' + str(container.id)
    #print "Issuing scons command: %s" % scons_cmd
    os.system(scons_cmd)
    builddir = source_to_builddir(POSIXDIR, container.id)
    os.path.walk(builddir, glob_by_walk, ['*.elf', images])

    # Calculate and store size of pager
    pager_binary = join(BUILDDIR,
                        "cont" + str(container.id) + "/posix/mm0/mm0.elf")
    config.containers[container.id].pager_size = \
            conv_hex(elf_binary_size(pager_binary))

    print 'Find markers for ' + pager_binary
    fill_pager_section_markers(config.containers[container.id], pager_binary)

    container_packer = DefaultContainerPacker(container, images)
    return container_packer.pack_container(config)

# This simply calls SCons on a given container, and collects
# all images with .elf extension, instead of using whole classes
# for building and packing.
def build_default_container(config, projpaths, container):
    images = []
    cwd = os.getcwd()
    projdir = join(join(PROJROOT, 'conts'), container.name)
    os.chdir(projdir)
    os.system("scons")
    os.path.walk(projdir, glob_by_walk, ['*.elf', images])

    # Calculate and store size of pager
    pager_binary = join(PROJROOT, "conts/" + container.name + "/main.elf")
    config.containers[container.id].pager_size = \
            conv_hex(elf_binary_size(pager_binary))

    fill_pager_section_markers(config.containers[container.id], pager_binary)

    container_packer = DefaultContainerPacker(container, images)
    return container_packer.pack_container(config)

def build_all_containers():
    config = configuration_retrieve()
    cont_images = []
    for container in config.containers:
        if container.type == 'linux':
            pass
            cont_images.append(build_linux_container(config, projpaths, container))
        elif container.type == 'baremetal':
            cont_images.append(build_default_container(config, projpaths, container))
        elif container.type == 'posix':
            cont_images.append(build_posix_container(config, projpaths, container))
        else:
            print "Error: Don't know how to build " + \
                  "container of type: %s" % (container.type)
            exit(1)
    configuration_save(config)
    all_cont_packer = AllContainerPacker(cont_images, config.containers)

    return all_cont_packer.pack_all(config)

if __name__ == "__main__":
    build_all_containers()

