#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
import os, sys, shelve, shutil, re
from projpaths import *
from lib import *
from caps import *


class Container:
    def __init__(self, id):
        self.dirname = None
        self.name = None
        self.type = None
        self.id = id
        self.pager_lma = 0
        self.pager_vma = 0
        self.pager_size = 0
        self.pager_rw_section_start = 0
        self.pager_rw_section_end = 0
        self.pager_rx_section_start = 0
        self.pager_rx_section_end = 0
        self.pager_task_region_start = 0
        self.pager_task_region_end = 0
        self.pager_shm_region_start = 0
        self.pager_shm_region_end = 0
        self.pager_utcb_region_start = 0
        self.pager_utcb_region_end = 0
        self.linux_zreladdr = 0
        self.linux_page_offset = 0
        self.linux_phys_offset = 0
        self.linux_rootfs_address = 0
        self.physmem = {}
        self.physmem["START"] = {}
        self.physmem["END"] = {}
        self.virtmem = {}
        self.virtmem["START"] = {}
        self.virtmem["END"] = {}
        self.caps = {}
        self.virt_regions = 0
        self.phys_regions = 0

    def print_self(self):
        print '\nContainer %d' % self.id
        print 'Container type: %s' % self.type
        print 'Container Name: %s' % self.name
        print 'Container Pager lma: %s' % conv_hex(self.pager_lma)
        print 'Container Pager vma: %s' % conv_hex(self.pager_vma)
        print 'Container Pager shm region start: %s' % conv_hex(self.pager_shm_region_start)
        print 'Container Pager shm region end: %s' % conv_hex(self.pager_shm_region_end)
        print 'Container Pager task region start: %s' % conv_hex(self.pager_task_region_start)
        print 'Container Pager task region end: %s' % conv_hex(self.pager_task_region_end)
        print 'Container Pager utcb region start: %s' % conv_hex(self.pager_utcb_region_start)
        print 'Container Pager utcb region end: %s' % conv_hex(self.pager_utcb_region_end)
        print 'Container Virtual regions: %s' % self.virt_regions
        print 'Container Physical regions: %s' % self.phys_regions
        print 'Container Capabilities: %s' % self.caps
        print '\n'

class configuration:

    def __init__(self):
        # Mapping between cpu and gcc flags for it.
        # Optimized solution to derive gcc arch flag from cpu
        # gcc flag here is "-march"
        #                          cpu          -march flag
        self.arch_to_gcc_flag = (['ARM926',       'armv5'],
                                 ['ARM1136',      'armv6'],
                                 ['ARM11MPCORE',  'armv6k'],
                                 ['CORTEXA8',     'armv7-a'],
                                 ['CORTEXA9',     'armv7-a'])
        self.arch = None
        self.subarch = None
        self.platform = None
        self.cpu = None
        self.gcc_arch_flag = None
        self.toolchain_userspace = None
	self.toolchain_kernel = None
        self.all = []
        self.smp = False
        self.ncpu = 0
        self.containers = []
        self.ncontainers = 0

    # Get all name value symbols
    def get_all(self, name, val):
        self.all.append([name, val])

    # Convert line to name value pair, if possible
    def line_to_name_value(self, line):
        parts = line.split()
        if len(parts) > 0:
            if parts[0] == "#define":
                return parts[1], parts[2]
        return None

    # Check if SMP enable, and get NCPU if SMP
    def get_ncpu(self, name, value):
        if name[:len("CONFIG_SMP")] == "CONFIG_SMP":
            self.smp = bool(value)
        if name[:len("CONFIG_NCPU")] == "CONFIG_NCPU":
            self.ncpu = int(value)

    # Extract architecture from a name value pair
    def get_arch(self, name, val):
        if name[:len("CONFIG_ARCH_")] == "CONFIG_ARCH_":
            parts = name.split("_", 3)
            self.arch = parts[2].lower()

    # Extract subarch from a name value pair
    def get_subarch(self, name, val):
        if name[:len("CONFIG_SUBARCH_")] == "CONFIG_SUBARCH_":
            parts = name.split("_", 3)
            self.subarch = parts[2].lower()

    # Extract platform from a name value pair
    def get_platform(self, name, val):
        if name[:len("CONFIG_PLATFORM_")] == "CONFIG_PLATFORM_":
            parts = name.split("_", 3)
            self.platform = parts[2].lower()

    # Extract cpu from a name value pair
    def get_cpu(self, name, val):
        if name[:len("CONFIG_CPU_")] == "CONFIG_CPU_":
            parts = name.split("_", 3)
            self.cpu = parts[2].lower()

            # derive gcc "-march" flag
            for cputype, archflag in self.arch_to_gcc_flag:
                if cputype == parts[2]:
                    self.gcc_arch_flag = archflag

    # Extract kernel space toolchain from a name value pair
    def get_toolchain(self, name, val):
        if name[:len("CONFIG_TOOLCHAIN_USERSPACE")] == \
			"CONFIG_TOOLCHAIN_USERSPACE":
            parts = val.split("\"", 2)
            self.toolchain_userspace = parts[1]

	if name[:len("CONFIG_TOOLCHAIN_KERNEL")] == \
			"CONFIG_TOOLCHAIN_KERNEL":
		parts = val.split("\"", 2)
		self.toolchain_kernel = parts[1]


    # Extract number of containers
    def get_ncontainers(self, name, val):
        if name[:len("CONFIG_CONTAINERS")] == "CONFIG_CONTAINERS":
            self.ncontainers = int(val)

    # TODO: Carry this over to Container() as static method???
    def get_container_parameter(self, id, param, val):
        if param[:len("PAGER_LMA")] == "PAGER_LMA":
            self.containers[id].pager_lma = int(val, 0)
        elif param[:len("PAGER_VMA")] == "PAGER_VMA":
            self.containers[id].pager_vma = int(val, 0)
        elif param[:len("PAGER_UTCB_START")] == "PAGER_UTCB_START":
            self.containers[id].pager_utcb_region_start = int(val, 0)
        elif param[:len("PAGER_UTCB_END")] == "PAGER_UTCB_END":
            self.containers[id].pager_utcb_region_end = int(val, 0)
        elif param[:len("PAGER_SHM_START")] == "PAGER_SHM_START":
            self.containers[id].pager_shm_region_start = int(val, 0)
        elif param[:len("PAGER_SHM_END")] == "PAGER_SHM_END":
            self.containers[id].pager_shm_region_end = int(val, 0)
        elif param[:len("PAGER_TASK_START")] == "PAGER_TASK_START":
            self.containers[id].pager_task_region_start = int(val, 0)
        elif param[:len("PAGER_TASK_END")] == "PAGER_TASK_END":
            self.containers[id].pager_task_region_end = int(val, 0)
        elif param[:len("LINUX_PAGE_OFFSET")] == "LINUX_PAGE_OFFSET":
            self.containers[id].linux_page_offset = int(val, 0)
            self.containers[id].pager_vma += int(val, 0)
        elif param[:len("LINUX_PHYS_OFFSET")] == "LINUX_PHYS_OFFSET":
            self.containers[id].linux_phys_offset = int(val, 0)
            self.containers[id].pager_lma += int(val, 0)
        elif param[:len("LINUX_ZRELADDR")] == "LINUX_ZRELADDR":
            self.containers[id].linux_zreladdr = int(val, 0)
        elif param[:len("LINUX_ROOTFS_ADDRESS")] == "LINUX_ROOTFS_ADDRESS":
            self.containers[id].linux_rootfs_address += int(val, 0)
        elif re.match(r"(VIRT|PHYS){1}([0-9]){1}(_){1}(START|END){1}", param):
            matchobj = re.match(r"(VIRT|PHYS){1}([0-9]){1}(_){1}(START|END){1}", param)
            virtphys, regionidstr, discard1, startend = matchobj.groups()
            regionid = int(regionidstr)
            if virtphys == "VIRT":
                self.containers[id].virtmem[startend][regionid] = val
                if regionid + 1 > self.containers[id].virt_regions:
                    self.containers[id].virt_regions = regionid + 1
            if virtphys == "PHYS":
                self.containers[id].physmem[startend][regionid] = val
                if regionid + 1 > self.containers[id].phys_regions:
                    self.containers[id].phys_regions = regionid + 1
        elif param[:len("OPT_NAME")] == "OPT_NAME":
            name = val[1:-1].lower()
            self.containers[id].name = name
        elif param[:len("BAREMETAL_PROJ_")] == "BAREMETAL_PROJ_":
            param1 = param.split("_", 2)
            self.containers[id].dirname = param1[2].lower()
        elif param[:len("CAP_")] == "CAP_":
            prefix, param_rest = param.split('_', 1)
            prepare_capability(self.containers[id], param_rest, val)
        else:
            param1, param2 = param.split("_", 1)
            if param1 == "TYPE":
                if param2 == "LINUX":
                    self.containers[id].type = "linux"
                elif param2 == "POSIX":
                    self.containers[id].type = "posix"
                elif param2 == "BAREMETAL":
                    self.containers[id].type = "baremetal"
    # Extract parameters for containers
    def get_container_parameters(self, name, val):
        matchobj = re.match(r"(CONFIG_CONT){1}([0-9]){1}(\w+)", name)
        if not matchobj:
            return None

        prefix, idstr, param = matchobj.groups()
        id = int(idstr)

        # Create and add new container if this id was not seen
        self.check_add_container(id)

        # Get rid of '_' in front
        param = param[1:]

        # Check and store info on this parameter
        self.get_container_parameter(id, param, val)
        #self.containers_print(self.containers)

    # Used for sorting container members,
    # with this we are sure containers are sorted by id value
    @staticmethod
    def compare_containers(cont, cont2):
        if cont.id < cont2.id:
            return -1
        if cont.id == cont2.id:
            print "compare_containers: Error, containers have same id."
            exit(1)
        if cont.id > cont2.id:
            return 1

    def check_add_container(self, id):
        for cont in self.containers:
            if id == cont.id:
                return

        # If symbol to describe number of containers
        # Has already been visited, use that number
        # as an extra checking.
        if self.ncontainers > 0:
            # Sometimes unwanted symbols slip through
            if id >= self.ncontainers:
                return

        container = Container(id)
        self.containers.append(container)

        # Make sure elements in order for indexed accessing
        self.containers.sort(self.compare_containers)

    def config_print(self):
        print 'Configuration\n'
        print '-------------\n'
        print 'Arch: %s, %s' % (self.arch, self.subarch)
        print 'Platform: %s' % self.platform
        print 'Symbols:\n %s' % self.all
        print 'Containers: %d' % self.ncontainers
        self.containers_print()

    def containers_print(self):
        for c in self.containers:
            c.print_self()

def configuration_save(config):
    if not os.path.exists(CONFIG_SHELVE_DIR):
        os.mkdir(CONFIG_SHELVE_DIR)

    config_shelve = shelve.open(CONFIG_SHELVE)
    config_shelve["configuration"] = config

    config_shelve["arch"] = config.arch
    config_shelve["subarch"] = config.subarch
    config_shelve["platform"] = config.platform
    config_shelve["cpu"] = config.cpu
    config_shelve["all_symbols"] = config.all
    config_shelve.close()

def configuration_retrieve():
    # Get configuration information
    config_shelve = shelve.open(CONFIG_SHELVE)
    config = config_shelve["configuration"]
    return config
