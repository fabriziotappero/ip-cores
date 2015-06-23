#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
#
# Script to add/remove project to baremetal
# menu of main screen
#
# This script should be called from project root directory
#
import os, sys, shutil, re

PROJRELROOT = '../../'
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), PROJRELROOT)))

from optparse import OptionParser
from os.path import join
from shutil import copytree
from config.projpaths import *

def parse_cmdline_options():
    usage = "usage: %prog [options] arg"
    parser = OptionParser(usage)

    parser.add_option("-a", "--add", action = "store_true", default = False,
            dest = "addproject", help = "Add new project to baremetal projects")
    parser.add_option("-d", "--del", action = "store_true", default = False,
            dest = "delproject", help = "Delete existing project from baremetal projects")
    parser.add_option("-i", "--desc", type = "string", dest = "projdesc",
            help = "Description of new project to be added")
    parser.add_option("-s", "--src", type = "string", dest = "srcpath",
            help = "With -a, Source directory for new project to be added \
                            With -d, Source directory of baremetal project to be deleted")

    (options, args) = parser.parse_args()

    # Sanity checks
    if (not options.addproject and not options.delproject) or \
            (options.addproject and options.delproject):
        parser.error("Only one of -a or -d needed, use -h argument for help")
        exit()

    if options.addproject:
        add_del = 1
        if not options.projdesc or not options.srcpath:
            parser.error("--desc or --src missing, use -h argument for help")
            exit()

    if options.delproject:
        add_del = 0
        if options.projdesc or not options.srcpath:
            parser.error("--desc provided or --src missing with -d, use -h argument for help")
            exit()

    return options.projdesc, options.srcpath, add_del

def container_cml_templ_del_symbl(projname):
    cont_templ = "config/cml/container_ruleset.template"
    sym = "CONT%(cn)d_BAREMETAL_PROJ_" + projname.upper()

    buffer = ""
    with open(cont_templ, 'r') as fin:
        exist = False
        # Prepare buffer for new cont_templ with new project symbols added
        for line in fin:
            parts = line.split()

            # Find out where baremetal symbols start in cont_templ
            if len(parts) > 1 and parts[0] == sym:
                exist = True
                continue
            elif len(parts) == 1 and parts[0] == sym:
                continue

            buffer += line
        if exist == False:
            print "Baremetal project named " + projname + " does not exist"
            exit()

    # Write new cont_templ
    with open(cont_templ, 'w+') as fout:
        fout.write(buffer)


def container_cml_templ_add_symbl(projdesc, projname):
    cont_templ = "config/cml/container_ruleset.template"

    pattern = re.compile("(CONT\%\(cn\)d_BAREMETAL_PROJ_)(.*)")
    baremetal_name_templ = "CONT%(cn)d_BAREMETAL_PROJ_"
    new_sym = baremetal_name_templ + projname.upper()

    buffer = ""
    with open(cont_templ, 'r') as fin:
        baremetal_sym_found = False
        last_baremetal_proj = ""

        # Prepare buffer for new cont_templ with new project symbols added
        for line in fin:
            parts = line.split()

            # Find out where baremetal symbols start in cont_templ
            if len(parts) > 1 and re.match(pattern, parts[0]):
                baremetal_sym_found = True

                # Find the name of last baremetal project already present in list
                last_baremetal_proj = parts[0][len(baremetal_name_templ):]

            # We are done with baremetal symbols, add new symbol to buffer
            elif baremetal_sym_found == True:
                baremetal_sym_found = False
                sym_def = new_sym + "\t\'" + projdesc + "\'\n"
                buffer += sym_def

            # Search for baremetal menu and add new project symbol
            elif len(parts) == 1 and \
                    parts[0] == baremetal_name_templ + last_baremetal_proj:
                sym_reference = "\t" + new_sym + "\n"
                line += sym_reference

            buffer += line

    # Write new cont_templ
    with open(cont_templ, 'w+') as fout:
        fout.write(buffer)

def add_project(projdesc, srcdir, projname):
    container_cml_templ_add_symbl(projdesc, projname)

    baremetal_dir = "conts/baremetal"
    dest_dir = join(baremetal_dir, projname)

    print "Copying source files from " + srcdir + " to " + dest_dir
    shutil.copytree(srcdir, dest_dir)
    print "Done, New baremetal project " + projname + \
          " is ready to be used."

def del_project(srcdir, projname):
    container_cml_templ_del_symbl(projname)

    baremetal_dir = "conts/baremetal"
    src_dir = join(baremetal_dir, projname)

    print "Deleting source files from " + src_dir
    shutil.rmtree(src_dir, "ignore_errors")
    print "Done.."

def main():
    projdesc, srcdir, add_del = parse_cmdline_options()

    # Get the base directory
    projpath, projname = os.path.split(srcdir)

    # Python's basename() doesnot work fine if path ends with /,
    # so we need to manually correct this
    if projname == "":
        projpath, projname = os.path.split(projpath)

    if add_del == 1:
        add_project(projdesc, srcdir, projname)
    else:
        del_project(srcdir, projname)

    # Delete the config.cml file, so that user can see new projects
    os.system("rm -f " + CML2_CONFIG_FILE)

if __name__ == "__main__":
    main()

