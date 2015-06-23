#!/usr/bin/env python
#
# This script reads A-Z80 instruction timing data from a spreadsheet text file
# and generates a Verilog include file defining the control block execution matrix.
# Token keywords in the timing spreadsheet are substituted using a list of keys
# stored in the macros file. See the macro file for the format information.
#
# Input timing file is exported from the Excel file as a TAB-delimited text file.
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
import string
import sys
import csv
import os

# Input file exported from a timing spreadsheet:
fname = "Timings.csv"

# Input file containing macro substitution keys
kname = "timing_macros.i"

# Set this to 1 if you want abbreviated matrix (no-action lines removed)
abbr = 1

# Set this to 1 if you want debug $display() printout on each PLA line
debug = 0

# Print this string in front of every line that starts with "ctl_". This helps
# formatting the output to be more readable.
ctl_prefix = "\n"+" "*19

# Read in the content of the macro substitution file
macros = []
with open(kname, 'r') as f:
    for line in f:
        if len(line.strip())>0 and line[0]!='/':
            # Wrap up non-starting //-style comments into /* ... */ so the
            # line can be concatenated while preserving comments
            if line.find("//")>0:
                macros.append( line.rstrip().replace("//", "/*", 1) + " */" )
            else:
                macros.append(line.rstrip())

# List of errors / keys and macros that did not match. We stash them as we go
# and then print at the end so it is easier to find them
errors = []

# Returns a substitution string given the section name (key) and the macro token
# This is done by simply traversing macro substitution list of lines, finding a
# section that starts with a :key and copying the substitution lines verbatim.
def getSubst(key, token):
    subst = []
    multiline = False
    validset = False
    if key=="Comments":                 # Special case: ignore "Comments" column!
        return ""
    for l in macros:
        if multiline==True:
            # Multiline copies lines until a char at [0] is not a space
            if len(l.strip())==0 or l[0]!=' ':
                return '\n' + "\n".join(subst)
            else:
                subst.append(l)
        lx = l.split(' ')               # Split the string and then ignore (duplicate)
        lx = filter(None, lx)           # spaces in the list left by the split()
        if l.startswith(":"):           # Find and recognize a matching set (key) section
            if validset:                # Error if there is a new section going from the macthing one
                break                   # meaning we did not find our macro in there
            if l[1:]==key:
                validset = True
        elif validset and lx[0]==token:
            if len(lx)==1:
                return ""
            if lx[1]=='\\':             # Multi-line macro state starts with '\' character
                multiline = True
                continue
            lx.pop(0)
            s = " ".join(lx)
            return ' ' + s.strip()
    err = "{0} not in {1}".format(token, key)
    if err not in errors:
        errors.append(err)
    return " --- {0} ?? {1} --- ".format(token, key)

# Read the content of a file and using the csv reader and remove any quotes from the input fields
content = []                            # Content of the spreadsheet timing file
with open(fname, 'rb') as csvFile:
    reader = csv.reader(csvFile, delimiter='\t', quotechar='"')
    for row in reader:
        content.append('\t'.join(row))

# The first line is special: it contains names of sets for our macro substitutions
tkeys = {}                              # Spreadsheet table column keys
tokens = content.pop(0).split('\t')
for col in range(len(tokens)):
    if len(tokens[col])==0:
        continue
    tkeys[col] = tokens[col]

# Process each line separately (stateless processor)
imatrix = []    # Verilog execution matrix code
for line in content:
    col = line.split('\t')              # Split the string into a list of columns
    col_clean = filter(None, col)       # Removed all empty fields (between the separators)
    if len(col_clean)==0:               # Ignore completely empty lines
        continue

    if col_clean[0].startswith('//'):   # Print comment lines
        imatrix.append(col_clean[0])

    if col_clean[0].startswith("#end"): # Print the end of a condition
        imatrix.append("end\n")

    if col_clean[0].startswith('#if'):  # Print the start of a condition
        s = col_clean[0]
        tag = s.find(":")
        condition = s[4:tag]
        imatrix.append("if ({0}) begin".format(condition.strip()))
        if debug and len(s[tag:])>1:    # Print only in debug and there is something to print
            imatrix.append("    $display(\"{0}\");".format(s[4:]))

    # We recognize 2 kinds of timing statements based on the starting characters:
    # "#0"..        common timings using M and T cycles (M being optional)
    # "#always"     timing that does not depend on M and T cycles (ex. ALU operations)
    if col_clean[0].startswith('#0') or col_clean[0].startswith('#always'):
        # M and T states are hard-coded in the table at the index 1 and 2
        if col_clean[0].startswith('#0'):
            if col[1]=='?':     # M is optional, use '?' to skip it
                state = "    if (T{0}) begin ".format(col[2])
            else:
                state = "    if (M{0} && T{1}) begin ".format(col[1], col[2])
        else:
            state = "    begin "

        # Loop over all other columns and perform verbatim substitution
        action = ""
        for i in range(3,len(col)):
            # There may be multiple tokens separated by commas
            tokList = col[i].strip().split(',')
            tokList =  filter(None, tokList)   # Filter out empty lines
            for token in tokList:
                token = token.strip()
                if i in tkeys and len(token)>0:
                    macro = getSubst(tkeys[i], token)
                    if macro.strip().startswith("ctl_"):
                        action += ctl_prefix
                    action += macro
                    if state.find("ERROR")>=0:
                        print "{0} {1}".format(state, action)
                        break

        # Complete and write out a line
        if abbr and len(action)==0:
            continue
        imatrix.append("{0}{1} end".format(state, action))

# Create a file containing the logic matrix code
with open('exec_matrix.vh', 'w') as file:
    file.write("// Automatically generated by genmatrix.py\n")
    # If there were errors, print them first (and output to the console)
    if len(errors)>0:
        for error in errors:
            print error
            file.write(error + "\n")
        file.write("-" * 80 + "\n")
    for item in imatrix:
        file.write("{}\n".format(item))

# Touch a file that includes 'exec_matrix.vh' to ensure it will recompile correctly
os.utime("execute.sv", None)
