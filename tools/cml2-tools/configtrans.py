#!/usr/bin/env python
"""
configtrans.py -- translate between CML1 and CML2 config formats.

This handles the impedance mismatch between CML2's explicit NAME=VALUE
output format and the formats expected by the Linux build machinery.

Note: it also makes backups whenever it touches a file.

configtrans.py -h includeout -s configout cml2file
configtrans.py -t <newconfig >oldconfig
"""
import sys, os, getopt, re

def linetrans(hook, instream, outstream, trailer=None):
    "Line-by-line translation between streams."
    if not hasattr(instream, "readline"):
        instream = open(instream, "r")
    if not hasattr(outstream, "readline"):
        outstream = open(outstream, "w")
    while 1:
        line = instream.readline()
        if not line:
            break
        new = hook(line)
        if new:
            outstream.write(new)
    instream.close()
    if trailer:
        outstream.write(trailer)
    outstream.close()

def write_include(line):
    "Transform a SYMBOL=VALUE line to CML1 include format."
    if line.find("PRIVATE") > -1 or line[:2] == "$$":
        return ""
    match = isnotset.match(line)
    if match:
        return "#undef  %s\n" % match.group(1)
    if line == "#\n":
        return None
    elif line[0] == "#":
        return "/* " + line[1:].strip() + " */\n"
    eq = line.find("=")
    if eq == -1:
        return line
    else:
        line = line.split('#')[0]
        symbol = line[:eq]
        value = line[eq+1 :].strip()
    if value == 'y':
        return "#define %s 1\n" % symbol
    elif value == 'm':
        return "#undef %s\n#define %s_MODULE 1\n" % (symbol, symbol)
    elif value == 'n':
        return "#undef  %s\n" % symbol
    else:
        return "#define %s %s\n" % (symbol, value)

def write_defconfig(line):
    "Transform a SYMBOL=VALUE line to CML1 defconfig format."
    if line[:2] == "$$":
        return ""
    eq = line.find("=")
    if eq == -1:
        return line
    else:
        line = line.split('#')[0]
        line = line.strip()
        if len(line) == 0 or line[-1] != "\n":
            line += "\n"
        symbol = line[:eq]
        value = line[eq+1:].strip()
    if value == 'n':
        return "# %s is not set\n" % symbol
    else:
        return line

def revert(line):
    "Translate a CML1 defconfig file to CML2 format."
    match = isnotset.match(line)
    if match:
        return "%s=n\n" % match.group(1)
    else:
        return line

if __name__ == '__main__':
    isnotset = re.compile("^# (.*) is not set")
    include = defconfig = translate = None
    (options, arguments) = getopt.getopt(sys.argv[1:], "h:s:t")
    for (switch, val) in options:
	if switch == '-h':
	    includefile = val
            try:
                os.rename(val, val + ".old")
            except OSError:
                pass
	elif switch == '-s':
	    defconfig = val
            try:
                os.rename(val, val + ".old")
            except OSError:
                pass
	elif switch == '-t':
            translate = 1
    if len(arguments) > 0:
        try:
            if includefile:
                linetrans(write_include, arguments[0], includefile, "#define AUTOCONF_INCLUDED\n")
            if defconfig:
                linetrans(write_defconfig, arguments[0], defconfig)
        except IOError, args:
            sys.stderr.write("configtrans: " + args[1] + "\n");
            raise SystemExit, 1
    elif translate:
        linetrans(revert, sys.stdin, sys.stdout)
    else:
        print "usage: configtrans.py -t [-h includefile] [-s defconfig] file"
        raise SystemExit, 1

# That's all, folks!

