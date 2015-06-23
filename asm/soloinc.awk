#!/usr/bin/gawk
#/**********************************************************************
#axasm Copyright 2006, 2007, 2008, 2009 
#by Al Williams (alw@al-williams.com).
#
#
#This file is part of axasm.
#
#axasm is free software: you can redistribute it and/or modify it
#under the terms of the GNU General Public Licenses as published
#by the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#axasm is distributed in the hope that it will be useful, but
#WITHOUT ANY WARRANTY: without even the implied warranty of 
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with axasm (see LICENSE.TXT). 
#If not, see http://www.gnu.org/licenses/.
#
#If a non-GPL license is desired, contact the author.
#
#This is the assembler include file expander
#
#***********************************************************************/
# find the path
function pathto(file,    i, t, junk)
{
    if (index(file, "/") != 0)
        return file

    for (i = 1; i <= ndirs; i++) {
        t = (pathlist[i] "/" file)
        if ((getline junk < t) > 0) {
            # found it
            close(t)
            return t
        }
    }
    return ""
}

BEGIN {
    path = ENVIRON["AWKPATH"]
    ndirs = split(path, pathlist, ":")
    for (i = 1; i <= ndirs; i++) {
        if (pathlist[i] == "")
            pathlist[i] = "."
    }


# keep a stack of files
    stackptr = 0
    oldsp=-1
    input[stackptr] = ARGV[1] # ARGV[1] is first file
    linect[stackptr]=1;
    for (; stackptr >= 0; stackptr--) {
	if (oldsp!=stackptr) { 
	    print "#line " linect[stackptr] " \"" input[stackptr] "\"";
	    oldsp=stackptr;
	}
# copy file while handling includes
        while ((getline < input[stackptr]) > 0) {
            if (tolower($1) != "##include") {
                print
                continue
            }
            fpath = pathto($2)
            if (fpath == "") {
                printf("include:%s:%d: cannot find %s\n", \
                    input[stackptr], FNR, $2) > "/dev/stderr"
                continue
            }

                processed[fpath] = input[stackptr]
                input[++stackptr] = fpath
		linect[stackptr]=1;
        }
        close(input[stackptr])
    }
}

