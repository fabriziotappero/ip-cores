#!/usr/bin/env python
#
# Merge a Configure.help file into a file of CML2 symbol declarations
#
# The Configure.help file must be argument 1; the partial symbol file
# must be argument 2.
#
# When given the -c option, suppress normal output and instead
# consistency-check the prompts.

import sys, string, re, os, os.path

if sys.version[0] < '2':
    print "Python 2.0 or later is required for this program."
    sys.exit(0)

directory = ""

def extract_dir(line, splitlocs):
    global directory
    # Handle directory directive
    if line[:14] == "#% Directory: ":
        fields = line[14:].strip().split()
        if len(fields) == 1:
            directory = fields[0]
        else:
            splitlocs[fields[0]] = fields[2]
        return 1
    else:
        return 0

def help_scan(file, prefix):
    # This assumes the format of Axel Boldt's Configure.help file
    global directory
    dict = {}
    splitlocs = {}
    stream = open(file)
    name = None
    ringbuffer = [0, 0, 0, 0, 0]
    ringindex = choiceflag = 0
    prompt = ""
    lastline = ""
    start = 0
    while 1:
	line = stream.readline()
        if extract_dir(line, splitlocs):
            continue
        # Now everything else
	if line and line[0] == '#':
            if line.find("Choice:") > -1:
                choiceflag = 1
	    continue
	ringbuffer[ringindex] = here = stream.tell()
	ringindex = (ringindex + 1) % 5
	if line and line[0] in string.whitespace:
	    continue
	if not line or line[0:7] == prefix:
	    if name:
                if dict.has_key(name):
                    sys.stderr.write("Duplicate help text for %s\n" % name)
		dict[name] = (file, start, ringbuffer[(ringindex - 4) % 5], prompt)
                if directory != "UNKNOWN":
                    splitlocs[name] = directory
                directory = "UNKNOWN"
	    if line:
		name = string.strip(line[7:])
		start = here
                if choiceflag:
                    prompt = None	# Disable prompt checking
                else:
                    prompt = lastline.strip()
                choiceflag = 0
	    else:
		break
        lastline = line
    stream.close()
    return (dict, splitlocs)

def fetch_help(symbol, helpdict):
    "Fetch help text associated with given symbol, if any."
    if helpdict.has_key(symbol):
        (file, start, end, prompt) = helpdict[symbol]
        stream = open(file)
        stream.seek(start)
        help = stream.read(end - start)
        # Canonicalize trailing whitespace
        help = help.rstrip() + "\n"
        stream.close()
        return help
    else:
        return None

def merge(helpfile, templatefile):
    "Merge a Configure.help with a symbols file, write to stdout."
    (helpdict, splitlocs) = help_scan(helpfile, "CONFIG_")
    template = open(templatefile, "r")
    promptre = re.compile("(?<=['\"])[^'\"]*(?=['\"])")

    os.system('rm -f `find kernel-tree -name "*symbols.cml"`')

    trim = re.compile("^  ", re.M)
    trailing_comment = re.compile("\s*#[^#']*$")
    outfp = None
    lineno = 0
    while 1:
        lineno += 1
        line = template.readline()
        if not line:
            break
        elif line == "\n":
            continue
        elif line[0] == "#":
            extract_dir(line, splitlocs)
            continue
        # Sanity check
        prompt = promptre.search(line)
        if not prompt:
            sys.stderr.write("Malformed line %s: %s" % (lineno, line))
            raise SystemExit, 1
        # We've hit something that ought to be a symbol line
        fields = line.split()
        symbol = fields[0]
        template_has_text = line.find("text\n") > -1
        if symbol[:7] == "CONFIG_":
            symbol = symbol[7:]
        if checkonly:
            # Consistency-check the prompts
            prompt = prompt.group(0)
            if helpdict.has_key(symbol):
                oldprompt = helpdict[symbol][3]
                if oldprompt == None:
                    continue
                if oldprompt[-15:] == " (EXPERIMENTAL)":
                    oldprompt = oldprompt[:-15]
                if oldprompt[-11:] == " (OBSOLETE)":
                    oldprompt = oldprompt[:-11]
                if oldprompt[-12:] == " (DANGEROUS)":
                    oldprompt = oldprompt[:-12]
                if oldprompt != prompt:
                    sys.stdout.write("%s:\n" % (symbol,))
                    sys.stdout.write("CML1: '" + oldprompt + "'\n")
                    sys.stdout.write("CML2: '" + prompt + "'\n")
            while 1:
                line = template.readline()
                if line == ".\n":
                    break
        else:
            # Now splice in the actual help text
            helptext = fetch_help(symbol, helpdict)
            if helptext and template_has_text:
                print line
                sys.stderr.write("Template already contains help text for %s!\n" % symbol)
                raise SystemExit, 1
        if outfp:
            outfp.close()
        if splitlocs.has_key(symbol):
            dest = splitlocs[symbol]
        else:
             dest = directory
        if dest == "UNKNOWN":
            sys.stderr.write("No directory for %s\n" % symbol)
            sys.exit(1)
        #print "%s -> %s" % (symbol, dest)
        dest = os.path.join("kernel-tree", dest[1:], "symbols.cml")
        exists = os.path.exists(dest)
        if exists:
            outfp = open(dest, "a")
        else:
            outfp = open(dest, "w")
            outfp.write("symbols\n")
        if helptext:
            leader = line.rstrip()
            comment_match = trailing_comment.search(leader)
            if comment_match:
                comment = comment_match.group(0)
                leader = leader[:comment_match.start(0)]
            else:
                comment = ""
            if len(leader) < 68:
                outfp.write(leader + "\ttext")
                if comment:
                    outfp.write("\t" + comment)
                outfp.write("\n")
            else:
                outfp.write(leader + comment + "\ntext\n")
            outfp.write(trim.sub("", helptext) + ".\n")
        elif template_has_text:
            outfp.write(line)
            while 1:
                line = template.readline()
                outfp.write(line)
                if line == ".\n":
                    break
        else:
            outfp.write(line)

def conditionalize(file, optset):
    "Handle conditional inclusions and drop out choice lines."
    import re
    cond = re.compile(r"^#% (\S*) only$")
    infp = open(file)
    if optset:
        sys.stdout.write("## This version generated for " + " with ".join(optset) + "\n")
    while 1:
        import re
        line = infp.readline()
        if not line:
            break
        if line[:9] == "# Choice:":
            continue
        match = cond.match(line)
        if match and match.group(1) not in optset:
            while 1:
                line = infp.readline()
                if not line:
                    break
                if line == "\n":
                    line = infp.readline()
                    break
        if line[:2] == "#%":		# Drop out other directives
            continue
        sys.stdout.write(line)

def dump_symbol(symbol, helpdict):
    "Dump a help entry."
    sys.stdout.write("%s\n" % helpdict[symbol][3])
    sys.stdout.write("CONFIG_%s\n" % symbol)
    sys.stdout.write(fetch_help(symbol, helpdict))
    sys.stdout.write("\n")

if __name__ == "__main__":
    import getopt

    checkonly = sort = 0
    optset = []
    (options, arguments) = getopt.getopt(sys.argv[1:], "D:Ecns")
    for (switch, val) in options:
        if switch == "-D":
            optset.append(val)
        elif switch == '-E':	# Process conditionals
            conditionalize(arguments[0], optset)
            sys.exit(0)
        elif switch == '-c':	# Consistency check
            checkonly = 1
        elif switch == '-n':	# List symbols with no match in second arg
            import cmlsystem
            configuration = cmlsystem.CMLSystem(arguments[1])
            helpdict = help_scan(arguments[0], "CONFIG_")
            keys = helpdict.keys()
            keys.sort()
            for symbol in keys:
                if not configuration.dictionary.get(symbol):
                    dump_symbol(symbol, helpdict)
            sys.exit(0)
        elif switch == '-s':	# Emit sorted version
            helpdict = help_scan(arguments[0], "CONFIG_")
            keys = helpdict.keys()
            keys.sort()
            for symbol in keys:
                dump_symbol(symbol, helpdict)
            sys.exit(0)

    help = arguments[0]
    symbols = arguments[1]
    merge(help, symbols)

# That's all, folks!
