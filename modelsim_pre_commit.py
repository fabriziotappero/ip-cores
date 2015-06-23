#!/usr/bin/env python
#
# This script prepares ModelSim *.mpf files for committing to git
#
# Why is this necessary?
#
# ModelSim notoriously shuffles the list of project files that are stored in its
# configuration file (*.mpf) even if no files were added or removed. That results
# in a version system (git, in this case) to always report mpf files as changed
# and needed to be committed even if there has been no _effective_ change to it.
#
# This script sorts the list of project files in a consistent way so no change
# will result in files looking the same way. In addition, the same is done with
# (key value) pairs within each file's line containing properties.
#
# Run this script before committing changes to git and bogus modifications will
# magically dissapear!
#
#-------------------------------------------------------------------------------
#  Copyright (C) 2014  Goran Devic
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the Free
#  Software Foundation; either version 2 of the License, or (at your option)
#  any later version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#-------------------------------------------------------------------------------
import os
import glob

def fixup():
    # Open and read any ModelSim project file (we normally have one per project)
    for file in glob.glob("*.mpf"):
        in_file_section = 0
        # We use the fact that a file property line immediately follows the file name
        current_name = ""
        pf = {}
        with open(file, "r") as f, open(file+".new", "w") as g:
            for line in f:
                if "Project_File_P_" in line:
                    # In addition, sort the "key value" pairs in the property line
                    # since ModelSim randomly shuffles them as well
                    pp = {}
                    prop = line.partition(" = ")[2].split(" ")
                    i = 0
                    while(i<len(prop)):
                        key = prop[i]
                        value = prop[i+1]
                        # A property value that has a space is enclosed in { .. }
                        if "{}" not in value and "{" in value:
                            i = i + 1
                            value = value + " " + prop[i+1]
                        # Another hack: ignore property "last_compile" since it always changes
                        if "last_compile" in key:
                            value = "1"
                        # Another hack: ignore property "ood"
                        if "ood" in key:
                            value = "0"
                        pp[key] = value.strip()
                        i = i + 2
                    sorted_prop = ""
                    for k,v in sorted(pp.items()):
                        sorted_prop = sorted_prop + " {0} {1}".format(k,v)
                    pf[current_name] = sorted_prop.lstrip() + "\n"
                    in_file_section = 1
                    continue
                if "Project_File_" in line:
                    current_name = line.partition(" = ")[2]
                    in_file_section = 1
                    # When we are already at it, make sure project files are relative to the $ROOT
                    if "$ROOT" not in line:
                        g.write("; Warning: Path {0} is not relative to the $ROOT!\n".format(current_name.strip()))
                    continue
                # We are not in the file section any more since we are here
                if in_file_section:
                    # Flush out our file list in a predictable order
                    i = 0
                    for k,v in sorted(pf.items()):
                        g.write("Project_File_{0} = {1}".format(i, k))
                        g.write("Project_File_P_{0} = {1}".format(i, v))
                        i = i + 1
                    in_file_section = 0
                g.write(line)
        # Lastly, replace old mpf file with the new one
        os.remove(file)
        os.rename(file+".new", file)

# Return to our current directory after each module has been visited
abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)

# Visit each ModelSim project directory...
os.chdir("cpu/alu/simulation/modelsim")
fixup()
os.chdir(dname)

os.chdir("cpu/bus/simulation/modelsim")
fixup()
os.chdir(dname)

os.chdir("cpu/control/simulation/modelsim")
fixup()
os.chdir(dname)

os.chdir("cpu/registers/simulation/modelsim")
fixup()
os.chdir(dname)

os.chdir("cpu/toplevel/simulation/modelsim")
fixup()
os.chdir(dname)

os.chdir("host/basic/simulation/modelsim")
fixup()
os.chdir(dname)

os.chdir("host/basic/uart/modelsim")
fixup()
os.chdir(dname)
