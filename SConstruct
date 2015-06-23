# -*- mode: python; coding: utf-8; -*-
#
#  Codezero -- Virtualization microkernel for embedded systems.
#
#  Copyright © 2009  B Labs Ltd
#
import os, shelve
import configure
from configure import *
from os.path import *

config = configuration_retrieve()
arch = config.arch
subarch = config.subarch
platform = config.platform
gcc_arch_flag = config.gcc_arch_flag
all_syms = config.all
builddir='build/codezero/'


# Generate kernel linker script at runtime using template file.
def generate_kernel_linker_script(target, source, env):
    linker_in = source[0]
    linker_out = target[0]

    cmd = config.toolchain_kernel + "cpp -D__CPP__ " + \
          "-I%s -imacros l4/macros.h -imacros %s -imacros %s -C -P %s -o %s" % \
                ('include', 'l4/platform/'+ platform + '/offsets.h', \
                 'l4/glue/' + arch + '/memlayout.h', linker_in, linker_out)
    os.system(cmd)

create_kernel_linker = Command(join(builddir, 'include/l4/arch/arm/linker.lds'), \
                               join(PROJROOT, 'include/l4/arch/arm/linker.lds.in'), \
                               generate_kernel_linker_script)

'''
# Generate linker file with physical addresses,
# to be used for debug purpose only
def generate_kernel_phys_linker_script(target, source, env):
    phys_linker_in = source[0]
    phys_linker_out = target[0]

    cmd = config.toolchain_kernel + "cpp -D__CPP__ " + \
          "-I%s -imacros l4/macros.h -imacros %s -imacros %s -C -P %s -o %s" % \
                ('include', 'l4/platform/'+ platform + '/offsets.h', \
                 'l4/glue/' + arch + '/memlayout.h', phys_linker_in, phys_linker_out)
    os.system(cmd)

create_kernel_phys_linker = Command(join(builddir, 'include/physlink.lds'), \
                               join(PROJROOT, 'include/l4/arch/arm/linker.lds.in'), \
                               generate_kernel_phys_linker_script)
'''

env = Environment(CC = config.toolchain_kernel + 'gcc',
		  AR = config.toolchain_kernel + 'ar',
		  RANLIB = config.toolchain_kernel + 'ranlib',
		  # We don't use -nostdinc because sometimes we need standard headers,
		  # such as stdarg.h e.g. for variable args, as in printk().
		  CCFLAGS = ['-g', '-nostdlib', '-ffreestanding', '-std=gnu99', '-Wall', \
		  	     '-Werror'],
		  LINKFLAGS = ['-nostdlib', '-T' + join(builddir, 'include/l4/arch/arm/linker.lds')],
		  ASFLAGS = ['-D__ASSEMBLY__'],
		  PROGSUFFIX = '.elf',			# The suffix to use for final executable
		  ENV = {'PATH' : os.environ['PATH']},	# Inherit shell path
		  LIBS = 'gcc',				# libgcc.a - This is required for division routines.
		  CPPPATH = ["#include"],
		  CPPFLAGS = '-include l4/config.h -include l4/macros.h -include l4/types.h -D__KERNEL__')

objects = []

objects += SConscript('src/generic/SConscript',
                      exports = {'symbols' : all_syms, 'env' : env},
                      duplicate=0, build_dir=builddir + 'generic')

objects += SConscript('src/glue/' + arch + '/SConscript',
                      exports = {'symbols' : all_syms, 'env' : env},
                      duplicate=0, build_dir=builddir + 'glue' + '/' + arch)

objects += SConscript('src/arch/' + arch + '/SConscript',
                      exports = {'symbols' : all_syms, 'env' : env},
                      duplicate=0, build_dir=builddir + 'arch/' + arch)

objects += SConscript('src/arch/' + arch + '/' + subarch + '/SConscript',
                      exports = {'symbols' : all_syms, 'env' : env},
                      duplicate=0, build_dir=builddir + 'arch/' + arch + '/' + subarch)

objects += SConscript('src/lib/SConscript',
                      exports = {'symbols' : all_syms, 'env' : env},
                      duplicate=0, build_dir=builddir + 'lib')

objects += SConscript('src/api/SConscript',
                      exports = {'symbols' : all_syms, 'env' : env},
                      duplicate=0, build_dir=builddir + 'api')

objects += SConscript('src/drivers/SConscript',
                      exports = {'symbols' : all_syms, 'env' : env, 'platform' : platform,'bdir' : 'driver/'},
                      duplicate=0, build_dir=builddir)

objects += SConscript('src/platform/' + platform + '/SConscript',
                      exports = {'symbols' : all_syms, 'env' : env,'platform' : platform}, duplicate=0,
                      build_dir=builddir + 'platform' + '/' +platform)

kernel_elf = env.Program(BUILDDIR + '/kernel.elf', objects)
#env_phys = env.Clone()
#env_phys.Replace(LINKFLAGS = ['-nostdlib', '-T' + join(builddir, 'include/physlink.lds')])
#env_phys.Program(BUILDDIR + '/kernel_phys.elf', objects)

Alias('kernel', kernel_elf)
Depends(kernel_elf, objects)
Depends(objects, create_kernel_linker)
#Depends(objects, create_kernel_phys_linker)
Depends(objects, 'include/l4/config.h')

