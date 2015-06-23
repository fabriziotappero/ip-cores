#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
#
# Top-level build script for Codezero
#
# Configures the Codezero environment, builds the kernel and userspace
# libraries, builds and packs all containers and builds the final loader
# image that contains all images.
#
import os, sys, shelve, shutil
from os.path import join
from config.projpaths import *
from config.configuration import *
from config.config_check import *
from scripts.qemu import qemu_cmdline
from scripts.conts import containers
from configure import *

def main():
    opts, args = build_parse_options()
    #
    # Configure
    #
    configure_system(opts, args)

    #
    # Check for sanity of containers
    #
    sanity_check_conts()

    #
    # Build userspace libraries
    #
    print "\nBuilding userspace libraries..."
    ret = os.system('scons -f SConstruct.userlibs')
    if(ret):
	print "Build failed \n"
	sys.exit(1)

    #
    # Build containers
    #
    print "\nBuilding containers..."
    containers.build_all_containers()

    #
    # Generate cinfo
    #
    generate_cinfo()

    #
    # Build the kernel
    #
    print "\nBuilding the kernel..."
    os.chdir(PROJROOT)
    ret = os.system("scons")
    if(ret):
	print "Build failed \n"
	sys.exit(1)

    #
    # Build libs and loader
    #
    os.chdir(PROJROOT)
    print "\nBuilding the loader and packing..."
    ret = os.system("scons -f SConstruct.loader")
    if(ret):
	print "Build failed \n"
	sys.exit(1)

    #
    # Build qemu-insight-script
    #
    print "\nBuilding qemu-insight-script.."
    qemu_cmdline.build_qemu_cmdline_script()
    #build_qemu_cmdline_script()

    print "\nBuild complete."

    print "\nRun qemu with following command: ./tools/run-qemu-insight\n"

if __name__ == "__main__":
    main()
