#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
#
#  Codezero -- a microkernel for embedded systems.
#
#  Copyright © 2009  B Labs Ltd
#
import os, sys, shelve, string
from os.path import join

PROJRELROOT = '../../'

SCRIPTROOT = os.path.abspath(os.path.dirname("."))
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), PROJRELROOT)))

from config.projpaths import *
from config.configuration import *
from config.lib import *

LINUX_KERNEL_BUILDDIR = join(BUILDDIR, os.path.relpath(LINUX_KERNELDIR, PROJROOT))

# Create linux kernel build directory path as:
# conts/linux -> build/cont[0-9]/linux
def source_to_builddir(srcdir, id):
    cont_builddir = \
        os.path.relpath(srcdir, \
                        PROJROOT).replace("conts", \
                                          "cont" + str(id))
    return join(BUILDDIR, cont_builddir)

class LinuxUpdateKernel:

    def __init__(self, container):
        # List for setting/unsetting .config params of linux
        self.config_param_list = \
            (['PCI', 'SET'],['AEABI', 'SET'],
            ['SCSI', 'SET'],['BLK_DEV_SD', 'SET'],
            ['SYM53C8XX_2', 'SET'],['INPUT_EVDEV', 'SET'],
            ['INOTIFY', 'SET'],['DEBUG_INFO', 'SET'],
            ['USB_SUPPORT', 'UNSET'],['SOUND', 'UNSET'],)

        # List of CPUIDs, to be used by linux based on codezero config
        self.cpuid_list = (['ARM926', '0x41069265'],
                           ['CORTEXA8', '0x410fc080'],
                           ['ARM11MPCORE', '0x410fb022'],
                           ['CORTEXA9', '0x410fc090'])
        # List of ARCHIDs, to be used by linux based on codezero config
        self.archid_list = (['PB926', '0x183'],
                            ['EB', '0x33B'],
                            ['PB11MPCORE', '0x3D4'],
                            ['BEAGLE', '0x60A'],
                            ['PBA9', '0x76D'],
                            ['PBA8', '0x769'])

        # Path of system_macros header file
        self.system_macros_h_out = \
            join(LINUX_KERNELDIR,
                'arch/codezero/include/virtualization/system_macros.h')
        self.system_macros_h_in = \
            join(LINUX_KERNELDIR,
                'arch/codezero/include/virtualization/system_macros.h.in')

        #Path for kernel_param file
        self.kernel_param_out = \
            join(LINUX_KERNELDIR, 'arch/codezero/include/virtualization/kernel_param')
        self.kernel_param_in = \
                join(LINUX_KERNELDIR, 'arch/codezero/include/virtualization/kernel_param.in')

    # Replace line(having input_pattern) in filename with new_data
    def replace_line(self, filename, input_pattern, new_data, prev_line):
        with open(filename, 'r+') as f:
            flag = 0
            temp = 0
            x = re.compile(input_pattern)
            for line in f:
                if '' != prev_line:
                    if temp == prev_line and re.match(x, line):
                        flag = 1
                        break
                    temp = line
                else:
                    if re.match(x, line):
                        flag = 1
                        break

            if flag == 0:
                #print 'Warning: No match found for the parameter'
                return
            else:
                # Prevent recompilation in case kernel parameter is same
                if new_data != line:
                    f.seek(0)
                    l = f.read()

                    # Need to truncate file because, size of contents to be
                    # written may be less than the size of original file.
                    f.seek(0)
                    f.truncate(0)

                    # Write back to file
                    f.write(l.replace(line, new_data))

    # Update kernel parameters
    def update_kernel_params(self, config, container):
        # Update PAGE_OFFSET
        # FIXME: Find a way to add this in system_macros.h or kernel_param
        # issue is we have to update this in KCONFIG file which cannot
        # have dependency on other files.
        file = join(LINUX_KERNELDIR, 'arch/codezero/Kconfig')
        param = str(conv_hex(container.linux_page_offset))
        new_data = ('\t' + 'default ' + param + '\n')
        data_to_replace = "(\t)(default )"
        prev_line = ('\t'+'default 0x80000000 if VMSPLIT_2G' + '\n')
        self.replace_line(file, data_to_replace, new_data, prev_line)

    # Update ARCHID, CPUID and ATAGS ADDRESS
        for cpu_type, cpu_id in self.cpuid_list:
            if cpu_type == config.cpu.upper():
                cpuid = cpu_id
                break
        for arch_type, arch_id in self.archid_list:
            if arch_type == config.platform.upper():
                archid = arch_id
                break

        # Create system_macros header
        with open(self.system_macros_h_out, 'w+') as output:
            with open(self.system_macros_h_in, 'r') as input:
                output.write(input.read() % \
                    {'cpuid'        : cpuid, \
                     'archid'       : archid, \
                     'atags'        : str(conv_hex(container.linux_page_offset + 0x100)), \
                     'ztextaddr'    : str(conv_hex(container.linux_phys_offset)), \
                     'phys_offset'  : str(conv_hex(container.linux_phys_offset)), \
                     'page_offset'  : str(conv_hex(container.linux_page_offset)), \
                     'zreladdr'     : str(conv_hex(container.linux_zreladdr))})

        with open(self.kernel_param_out, 'w+') as output:
            with open(self.kernel_param_in, 'r') as input:
                output.write(input.read() % \
                      {'ztextaddr'    : str(conv_hex(container.linux_phys_offset)), \
                       'phys_offset'  : str(conv_hex(container.linux_phys_offset)), \
                       'page_offset'  : str(conv_hex(container.linux_page_offset)), \
                       'zreladdr'     : str(conv_hex(container.linux_zreladdr))})

    def modify_kernel_config(self, linux_builddir):
        file = join(linux_builddir, '.config')
        for param_name, param_value in self.config_param_list:
            param = 'CONFIG_' + param_name
            prev_line = ''
            if param_value == 'SET':
                data_to_replace = ('# ' + param)
                new_data = (param + '=y' + '\n')
            else:
                data_to_replace = param
                new_data = ('# ' + param + ' is not set' + '\n')

        self.replace_line(file, data_to_replace, new_data, prev_line)

class LinuxBuilder:

    def __init__(self, pathdict, container):
        self.LINUX_KERNELDIR = pathdict["LINUX_KERNELDIR"]

        # Calculate linux kernel build directory
        self.LINUX_KERNEL_BUILDDIR = \
            source_to_builddir(LINUX_KERNELDIR, container.id)

        self.container = container
        self.kernel_binary_image = \
            join(os.path.relpath(self.LINUX_KERNEL_BUILDDIR, LINUX_KERNELDIR), \
                 "vmlinux")
        self.kernel_image = join(self.LINUX_KERNEL_BUILDDIR, "linux.elf")
        self.kernel_updater = LinuxUpdateKernel(self.container)

        # Default configuration file to use based on selected platform
        self.platform_config_file = (['PB926', 'versatile_defconfig'],
                                     ['BEAGLE', 'omap3_beagle_defconfig'],
                                     ['PBA8', 'realview_defconfig'],
                                     ['PBA9', 'realview-smp_defconfig'],
                                     ['PB11MPCORE', 'realview-smp_defconfig'],)

    def build_linux(self, config):
        print '\nBuilding the linux kernel...'
        os.chdir(self.LINUX_KERNELDIR)
        if not os.path.exists(self.LINUX_KERNEL_BUILDDIR):
            os.makedirs(self.LINUX_KERNEL_BUILDDIR)

        for platform, config_file in self.platform_config_file:
            if platform == config.platform.upper():
                configuration_file = config_file
        os.system("make ARCH=codezero CROSS_COMPILE=" + \
		  config.toolchain_userspace + \
                  " O=" + self.LINUX_KERNEL_BUILDDIR + " " + configuration_file)

        self.kernel_updater.modify_kernel_config(self.LINUX_KERNEL_BUILDDIR)
        self.kernel_updater.update_kernel_params(config, self.container)

        os.system("make ARCH=codezero CROSS_COMPILE=" + \
		  config.toolchain_userspace + \
                  " O=" + self.LINUX_KERNEL_BUILDDIR + " menuconfig")
        os.system("make ARCH=codezero " + \
                  "CROSS_COMPILE=" + config.toolchain_userspace + \
		  " O=" + self.LINUX_KERNEL_BUILDDIR)

        # Generate kernel_image, elf to be used by codezero
        linux_elf_gen_cmd = (config.toolchain_userspace + "objcopy -R .note \
            -R .note.gnu.build-id -R .comment -S --change-addresses " + \
            str(conv_hex(-self.container.linux_page_offset + self.container.linux_phys_offset)) + \
            " " + self.kernel_binary_image + " " + self.kernel_image)

        #print cmd
        os.system(linux_elf_gen_cmd)
        print 'Done...'

    def clean(self):
        print 'Cleaning linux kernel build...'
        if os.path.exists(self.LINUX_KERNEL_BUILDDIR):
            shutil.rmtree(self.LINUX_KERNEL_BUILDDIR)
        print 'Done...'

if __name__ == "__main__":
    # This is only a default test case
    container = Container()
    container.id = 0
    linux_builder = LinuxBuilder(projpaths, container)

    if len(sys.argv) == 1:
        linux_builder.build_linux()
    elif "clean" == sys.argv[1]:
        linux_builder.clean()
    else:
        print " Usage: %s [clean]" % (sys.argv[0])
