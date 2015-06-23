#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
#
#  Codezero -- Virtualization microkernel for embedded systems.
#
#  Copyright © 2009  B Labs Ltd
#
import os, sys, shelve, glob
from os.path import join

PROJRELROOT = '../../'

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), PROJRELROOT)))
sys.path.append(os.path.abspath("../"))

SCRIPTROOT = os.path.abspath(os.path.dirname(__file__))

from config.projpaths import *
from config.configuration import *
from config.lib import *

class BaremetalContGenerator:
    def __init__(self):
        self.CONT_SRC_DIR = ''   # Set when container is selected
        self.BAREMETAL_SRC_BASEDIR = join(PROJROOT, 'conts')
        self.BAREMETAL_PROJ_SRC_DIR = join(PROJROOT, 'conts/baremetal')

        self.main_builder_name = 'build.py'
        self.main_configurator_name = 'configure.py'
        self.mailing_list_url = 'http://lists.l4dev.org/mailman/listinfo/codezero-devel'

        self.build_script_in = join(SCRIPTROOT, 'files/SConstruct.in')
        self.build_readme_in = join(SCRIPTROOT, 'files/build.readme.in')
        self.build_desc_in = join(SCRIPTROOT, 'files/container.desc.in')
        self.linker_lds_in = join(SCRIPTROOT, 'files/linker.lds.in')
        self.container_h_in = join(SCRIPTROOT, 'files/container.h.in')

        self.build_script_name = 'SConstruct'
        self.build_readme_name = 'build.readme'
        self.build_desc_name = '.container'
        self.linker_lds_name = 'linker.lds'
        self.container_h_name = 'container.h'

        self.container_h_out = None
        self.build_script_out = None
        self.build_readme_out = None
        self.build_desc_out = None
        self.src_main_out = None

    def create_baremetal_srctree(self, config, cont):
        # First, create the base project directory and sources
        shutil.copytree(join(self.BAREMETAL_PROJ_SRC_DIR, cont.dirname), self.CONT_SRC_DIR)

    def copy_baremetal_build_desc(self, config, cont):
        id_header = '[Container ID]\n'
        type_header = '\n[Container Type]\n'
        name_header = '\n[Container Name]\n'
        pager_lma_header = '\n[Container Pager LMA]\n'
        pager_vma_header = '\n[Container Pager VMA]\n'
        pager_virtmem_header = '\n[Container Virtmem Region %s]\n'
        pager_physmem_header = '\n[Container Physmem Region %s]\n'

        with open(self.build_desc_out, 'w+') as fout:
            fout.write(id_header)
            fout.write('\t' + str(cont.id) + '\n')
            fout.write(type_header)
            fout.write('\t' + cont.type + '\n')
            fout.write(name_header)
            fout.write('\t' + cont.name + '\n')
            fout.write(pager_lma_header)
            fout.write('\t' + conv_hex(cont.pager_lma) + '\n')
            fout.write(pager_vma_header)
            fout.write('\t' + conv_hex(cont.pager_vma) + '\n')
            for ireg in range(cont.virt_regions):
                fout.write(pager_virtmem_header % ireg)
                fout.write('\t' + cont.virtmem["START"][ireg] + ' - ' + cont.virtmem["END"][ireg] + '\n')
            for ireg in range(cont.phys_regions):
                fout.write(pager_physmem_header % ireg)
                fout.write('\t' + cont.physmem["START"][ireg] + ' - ' + cont.physmem["END"][ireg] + '\n')

    def copy_baremetal_build_readme(self, config, cont):
        with open(self.build_readme_in) as fin:
            str = fin.read()
            with open(self.build_readme_out, 'w+') as fout:
                # Make any manipulations here
                fout.write(str % (self.mailing_list_url, \
                                  cont.name, \
                                  self.build_desc_name, \
                                  self.main_builder_name, \
                                  self.main_configurator_name, \
                                  self.main_configurator_name))

    def copy_baremetal_container_h(self, config, cont):
        with open(self.container_h_in) as fin:
            str = fin.read()
            with open(self.container_h_out, 'w+') as fout:
                # Make any manipulations here
                fout.write(str % (cont.name, cont.id, cont.id))

    def create_baremetal_sources(self, config, cont):
        self.create_baremetal_srctree(config, cont)
        self.copy_baremetal_build_readme(config, cont)
        self.copy_baremetal_build_desc(config, cont)
        self.generate_linker_script(config, cont)
        self.copy_baremetal_container_h(config, cont)

    def update_configuration(self, config, cont):
        self.copy_baremetal_build_desc(config, cont)
        self.generate_linker_script(config, cont)
        self.copy_baremetal_container_h(config, cont)

    def check_create_baremetal_sources(self, config):
        for cont in config.containers:
            if cont.type == "baremetal":
                # Determine container directory name.
                self.CONT_SRC_DIR = join(self.BAREMETAL_SRC_BASEDIR, cont.name.lower())
                self.build_readme_out = join(self.CONT_SRC_DIR, self.build_readme_name)
                self.build_desc_out = join(self.CONT_SRC_DIR, self.build_desc_name)
                self.linker_lds_out = join(join(self.CONT_SRC_DIR, 'include'), \
                                           self.linker_lds_name)
                self.container_h_out = join(join(self.CONT_SRC_DIR, 'include'), \
                                            self.container_h_name)

                if not os.path.exists(join(self.BAREMETAL_SRC_BASEDIR, cont.name)):
                    self.create_baremetal_sources(config, cont)
                else:
                    # Don't create new sources but update configuration
                    self.update_configuration(config, cont)

    def generate_linker_script(self, config, cont):
        with open(self.linker_lds_in) as fin:
            str = fin.read()
            with open(self.linker_lds_out, 'w+') as fout:
                fout.write(str % (conv_hex(cont.pager_vma), \
                                  conv_hex(cont.pager_lma)))

    def baremetal_container_generate(self, config):
        self.check_create_baremetal_sources(config)

if __name__ == "__main__":
    config = configuration_retrieve()
    config.config_print()
    baremetal_cont = BaremetalContGenerator()
    baremetal_cont.baremetal_container_generate(config)

