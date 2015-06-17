#!/usr/bin/env python
#-*- coding:utf-8 -*-
#
'''
This is a one-file python script that analyze the content of a local folder
name ./cores and upload its content to git hub

This script is to be used with opencores_scraper.py for the purpose of getting
all opencores.org code and upload it to a github account

The Python libraries needed for this script can be installed with the command:

    sudo pip install tarfile
'''
#
# HOW TO USE THIS SCRIPT
#
# 1) install python and its dependencies
# 2) configure the git address _github_addr
# 3) run this script with the command:  ./local2git.py
#

_github_addr = 'https://github.com/fabriziotappero/ip-cores.git'

import sys, os, shutil, glob
import tarfile
from distutils.dir_util import copy_tree

prj_categ = next(os.walk('./cores'))[1]
prjs = []
empty_prjs = 0
for x in prj_categ:
    _path = './cores/' + x
    for y in next(os.walk(_path))[1]: #get only projects with a tar.gz file in it(not empty)
        z = os.listdir(_path + "/" + y)
        for elem in z:
            if elem.endswith(".tar.gz"):
                prjs.append([[x],[y]])
                break

# no prjs stores both categories and projects
print "Number of local non empty projects: ", len(prjs)

_txt = '''
## VHDL/Verilog IP CORES

The following branch contains the following VHDL/VERILOG IP Code.

Project name: %s

Project category: %s

Project branch: %s

This whole github repository contains approximately **4.5GB of free and open source
IP cores**. To download only this project you can use the git command:

**git clone -b %s --single-branch https://github.com/fabriziotappero/ip-cores.git**

### License

This code was taken "as is" from the website opencores.org.
The copyright owner of this IP code is the original author of the code. For
more information have a look at index.html or at the website opencores.org

This code is free software; you can redistribute it and/or modify it under the
terms of the http://www.gnu.org/licenses/gpl.html (GNU General Public License)
as published by the Free Software Foundation; either version 2 of the License,
or (at your option) any later version.

This code is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A	PARTICULAR PURPOSE. See the GNU General Public License for
more details.
'''

for _ind,x in enumerate(prjs):
    prj_cat = x[0][0]
    prj_name = x[1][0]
    prj_branch = str(_ind) + "_" + prj_name
    _dir = os.path.join('cores', prj_cat, prj_name)
    _ind +=1
    for _fl in os.listdir(_dir):
        if _fl.endswith('.tar.gz'):
            prj_real_name = _fl[: -7]
            print "From:", _dir, "\nUnzipping:", _fl, "\n"
            tfile = tarfile.open(os.path.join(_dir, _fl), 'r:gz')
            tfile.extractall(os.path.join(_dir, 'tmp'))
            tfile.close()
            if os.path.exists(os.path.join(_dir, 'src')):
                shutil.rmtree(os.path.join(_dir, 'src'))

            # copy all svn trunk in fresh src folder. If trunk does not exist
            # copy the whole thing.
            if os.path.isdir(os.path.join(_dir, 'tmp', _fl[: -7], 'trunk')):
                copy_tree(os.path.join(_dir, 'tmp', _fl[: -7], 'trunk'), os.path.join(_dir, 'src'))
            if os.path.isdir(os.path.join(_dir, 'tmp', _fl[: -7], 'web_uploads')):
                copy_tree(os.path.join(_dir, 'tmp', _fl[: -7], 'web_uploads'), os.path.join(_dir, 'src'))

            #elif os.path.isdir(os.path.join(_dir, 'tmp', _fl[: -7])):
            #    shutil.copytree(os.path.join(_dir, 'tmp', _fl[: -7]), os.path.join(_dir, 'src'))

            if os.path.isdir(_dir):
                with open(os.path.join(_dir,'README.md'), 'w') as _file:
                    _file.write(_txt % (prj_name, prj_cat, prj_branch, prj_branch))

            # just in case you unzipped a zip file(one zip inside another)
            for x in glob.glob(os.path.join(_dir, 'src', '*')):
                if x.endswith('.tar.gz') or x.endswith('.tgz'):
                    tfile = tarfile.open(x, 'r:gz')
                    tfile.extractall(os.path.join(_dir, 'src'))
                    tfile.close()
                    os.remove(x)

            # deleted not needed files
            if os.path.isfile(os.path.join(_dir, _fl)):
                if False:
                    os.remove(os.path.join(_dir, _fl))# remove tar.gz file
            if os.path.isdir(os.path.join(_dir, 'tmp')):
                shutil.rmtree(os.path.join(_dir, 'tmp'))# remove original unzipped folder
