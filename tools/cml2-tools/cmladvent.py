#!/usr/bin/env python
#
# cmladvent.py -- CML2 configurator adventure-game front end
# by Eric S. Raymond, <esr@thyrsus.com>
#
# This illustrates how easy it is to wrap a front end around cmlsystem.
# Purely in the interests of science, of course...
#
import sys

if sys.version[0] < '2':
    print "Python 2.0 or later is required for this program."
    sys.exit(0)

import os, string, getopt, cmd, time, whrandom, random
import cml, cmlsystem

# Globals
debug = 0
proflog = partialsave = None
banner = ""
gruestate = darkturns = 0
lanternloc = None
configfile = None
configuration = None

directions = ('n','e','s','w','ne','sw','se','nw','dn','up')

# User-visible strings in the configurator.  Separated out in order to
# support internationalization.
_eng = {
    # Strings used in the command help -- these should align
    "LHELP":"look [target] -- look here or at target (direction or option).",
    "NHELP":"nearby        -- list nearby rooms (useful with go)",
    "GHELP":"go            -- go to a named menu (follow with the label).",
    "IHELP":"inventory     -- show which options you have picked up.",
    "THELP":"take [module] -- set options, follow with option names.",
    "SETHELP":"set           -- set numeric or string; follow with symbol and value.",
    "DHELP":"drop          -- unset options, follow with option names or `all'.",
    "LDHELP":"load          -- read in a configuration (follow with the filename).",
    "SHELP":"save          -- save the configuration (follow with a filename).",
    "XYZZY":"xyzzy         -- toggle suppression flag.",
    "QHELP":"quit          -- quit, discarding changes.",
    "XHELP":"exit          -- exit, saving the configuration.",
    # Grue/lantern messages
    "BRASSOFF":"A brass lantern (unlit).",
    "BRASSON":"A brass lantern (lit).",
    "DARK":"It is very dark.  If you continue, you are likely to be eaten by a grue.",
    "EATEN":"*CHOMP*!  You have been eaten by a slavering grue.  Game over.",
    "GLOW":"The lantern radiates a mellow golden light.",
    "LANTERN":"lantern",
    "LANTERNDROP":"Lantern: dropped.",
    "LANTERNTAKE":"Lantern: taken.",
    "LONGLANTERN":"A brass lantern is here.",
    "LANTERNHELP":"""
You see a brass lantern with a ring-shaped handle, hooded and paned with
clear glass.  A toggle on the lamp connects to a firestriker inside it.
On the bottom is stamped a maker's mark that reads:

       Another fine product of FrobozzCo.
     Made in Plumbat, Great Underground Empire
""",
    # Other strings
    "ABORTED":"Configurator aborted.",
    "BADOPTION":"cmladvent: unknown option on command line.\n",
    "BOOLEAN":"`y' and `n' can only be applied to booleans or tristates",
    "CANNOTSET":"    Can't assign this value for bool or trit symbol.",
    "CONSTRAINTS":"Constraints:",
    "DEFAULT":"Default: ",
    "DERIVED":"Symbol %s is derived and cannot be set.",
    "DIRHELP":"You can move in compass directions n,e,w,s,ne,nw,se,sw, up, or dn for down.",
    "DONE":"Done",
    "DROPPED":"%s: dropped.",
    "EFFECTS":"Side effects:",
    "EH?":"Eh?",
    "EXIT":"Exit",
    "EXITS":"Passages exit up, %s.",
    "EXTRAROOMS":"Other nearby rooms are: %s.",
    "GOODBYE":"You emerge, blinking, into the daylight.",
    "INROOM":"In %s room.",
    "INVISIBLE":"Symbol is invisible",
    "ISHERE":"There is an option named %s here.",
    "LOADFAIL":"Loading '%s' failed, continuing...",
    "MDISABLED":"Module-valued symbols are not enabled",
    "MNOTVALID":"   m is not a valid value for %s",
    "NEW":"(NEW)",
    "NNOTVALID":"   n is not a valid value for %s",
    "NOANCEST":"No ancestors.",
    "NOBUTTON":"I don't see button %s here.",
    "NOCMDLINE":"%s is the wrong type to be set from the command line",
    "NODEPS":"No dependents.",
    "NODIR":"You see nothing special in that direction.",
    "NOFILE":"cmlconfigure: '%s' does not exist or is unreadable.",
    "NOHAVE":"You don't have %s.",
    "NOHELP":"No help available for %s",
    "NOHERE":"I see no `%s' here.",
    "NOMATCHES":"No matches.",
    "NONEXIST":"No such location.",
    "NOSUCHAS":"No such thing as",
    "NOTSAVED":"Configuration not saved",
    "NOWAY":"You can't go in that direction from here.",
    "OUTOFBOUNDS":"Legal values are in %s",
    "PARAMS":"    Config = %s, prefix = %s",
    "PASSAGEALL":"Passages lead off in all directions.",
    "PASSAGEUP":"A passage leads upwards.",
    "PHELP":"press         -- press a button (follow with the button name).",
    "POSTMORTEM":"The ruleset was inconsistent.  A state dump is in the file `post.mortem'.",
    "REALLY":"Really exit without saving?",
    "ROLLBACK":"%s=%s would have violated these requirements:",
    "ROOMBANNER":"The %s room.  A sign reads `%s'.",
    "SAVEAS":"Save As...",
    "SAVEEND":"Done",
    "SAVESTART":"Saving %s",
    "SAVING":"Saving...",
    "SHOW_ANC":"Show ancestors of symbol: ",
    "SHOW_DEP":"Show dependents of symbol: ",
    "SIDEEFFECTS":"Side Effects",
    "SIDEFROM":"Side effects from %s:",
    "SUPPRESSOFF":"Suppression turned off.",
    "SUPPRESSON":"Suppression turned on.",
    "SYMUNKNOWN":"cmlconfigure: unknown symbol %s\n",
    "TAKEN":"%s: taken.",
    "TRIT":"`m' can only be applied to tristates",
    "TRYPRESS":"That doesn't work.  You might try pressing another button.",
    "TWISTY":"You are in a maze of twisty little %s menus, all different.",
    "USESET":"What?  Configure %s with your bare hands?",
    "VALUE":"Value of %s is %s.",
    "VISIBLE":"Symbol is visible.",
    "VISIBILITY":"Visibility: ",
    "WALLCHOICE":"There is a row of buttons on the wall of this room. They read:",
    "WALLDEFAULT":"The button marked %s is pressed.",
    "WELCOME":"Welcome to CML2 Adventure, version %s.",
    # General help
    "GENHELP":"""Welcome to the adventure configurator.  For a command summary, type `commands'.
In general, a three-letter abbreviation of any command word is sufficient
to identify it to the parser.

This interface emulates the style of classic text adventure games such as
Colossal Cave Adventure and Zork.  Configuration menus are rooms, and
configuration options are objects that can be taken and dropped (except
for choice/radiobutton symbols, which become buttons on various room walls).
Objects and rooms may silently appear and disappear as visibilities
change.

Have fun, and beware of the lurking grue!
"""
}

grafitti = (
    'N tensvggb ernqf: "Gur Jhzchf jnf urer.  Nera\'g lbh tynq ur\'f abg urer abj?"',
    'N tensvggb ernqf: "Uryyb, fnvybe!"',
    'N tensvggb ernqf: "Sebqb yvirf!"',
    'N tensvggb ernqf: "Guvf fcnpr sbe erag."',
    'N tensvggb ernqf: "Guvf Jnl gb gur Rterff..."',
    # Bofpher Pbybffny Pnir Nqiragher ersreraprf ortva urer.
    'Ba bar jnyy vf n tynff-sebagrq obk ubyqvat na nkr.\aBa gur tynff vf jevggra: "OERNX TYNFF VA PNFR BS QJNEIRF"',
    'N tensvggb ernqf: "Srr svr sbr sbb!',
    # Bofpher Mbex ersreraprf ortva urer.
    'N tensvggb ernqf: "Ragunevba gur Jvfr fyrcg urer."', 
    'N tensvggb ernqf: "N mbexzvq fnirq vf n mbexzvq rnearq."',
    'Bar jnyy qvfcynlf n sbezny cbegenvg bs W. Cvrecbag Syngurnq.',
    'Bar jnyy qvfcynlf n qhfgl cbegenvg bs gur Rzcrebe Zhzob VV.',
    'Bar jnyy qvfcynlf n cvpgher bs gur terng tenabyn fzrygref bs Cyhzong.',
    'Bar jnyy qvfcynlf n gnpxl oynpx-iryirg cnvagvat bs n tbyqra-sheerq zvak jvgu uhtr rlrf.',
    # Bofpher Q&Q ersreraprf ortva urer
    'N tensvggb ernqf: "Vg pbhyq bayl or orggre ng Pnfgyr Terlunjx"',
    'N tensvggb ernqf: "Cnenylfvf vf va gur rlr bs gur orubyqre"',
    # Bofpher wbxr sbe QrPnzc/Cengg snaf
    'N tensvggb ernqf: "Lativ vf n ybhfr!"',
    # Abg-fb-bofpher Yvahk ersreraprf ortva urer.
    'Ba bar jnyy vf n cubgbtencu bs Yvahf Gbeinyqf, qevaxvat Thvaarff.',
    'N jnyy oenpxrg ubyqf n qvfpneqrq cnve bs Nyna Pbk\'f fhatynffrf.  Oebamrq.',
    'Ba bar jnyy vf n cbegenvg bs EZF va shyy Fg. Vtahpvhf qent.',
    'Ba bar jnyy vf n cvpgher bs Yneel Jnyy ubyqvat n ynetr chzcxva.',
    'Ba bar jnyy vf jung nccrnef gb or n cubgbtencu bs Thvqb\'f gvzr znpuvar.',
    'Gur sybbe vf yvggrerq jvgu fcrag .45 furyyf. Revp Enlzbaq zhfg unir orra urer.',
    )
grafittishuffle = []
grafitticount = 0

# Eventually, do more intelligent selection using LOCALE
lang = _eng

def roll(n):
    "Return a random number in the range 0..n-1."
    return random.randrange(n)

def shuffle(size):
    "Generate a random permutation of 0...(size - 1)."
    shuffle = range(size)
    for i in range(1, size+1):
	j = random.randrange(i)
	holder = shuffle[i - 1]
	shuffle[i - 1] = shuffle[j]
	shuffle[j] = holder
    return shuffle

def rot13(str):
    res = ""
    for c in str:
        if c in string.uppercase:
            res += chr(ord('A') + ((ord(c)-ord('A')) + 13) % 26) 
        elif c in string.lowercase:
            res += chr(ord('a') + ((ord(c)-ord('a')) + 13) % 26) 
        else:
            res += c
    return res

def newroom(room):
    # There is a chance of grafitti
    global grafitticount, grafittishuffle
    if grafitticount < len(grafitti):
        if not hasattr(room, "visits") and roll(3) == 0:
            room.grafitti = grafitti[grafittishuffle[grafitticount]]
            grafitticount += 1
    # State machine for lantern and grue
    global lanternloc, gruestate, darkturns
    if gruestate == 0:		# Initial state
        if not hasattr(room, "visits") and roll(4) == 0:
            gruestate += 1
            lanternloc = room
    elif gruestate == 1:	# Lantern has been placed
        if roll(4) == 0:
            gruestate += 1
    elif gruestate == 2:	# It's dark now
        darkturns += 1
        if darkturns > 2 and roll(4) == 0:
            print lang["EATEN"]
            raise SystemExit

def visit(room, level=0):
    "Visit a room, and describe at any of four verbosity levels."
    # 0 = quiet, 1 = name only, 2 = name + help,
    # 3 = name + help + exits, 4 = name + help + exits + contents
    configuration.visit(room)
    # Compute visible exits
    room.exits = filter(lambda x: x.type in ("menu", "choices"), room.items)
    room.exits = filter(configuration.is_visible, room.exits)
    # This way of assigning directions has the defect that they may
    # change as submenus become visible/invisible.  Unfortunately,
    # the alternative is not being able to assign directions at all
    # for long menus.
    room.directions = {}
    for (dir,other) in zip(directions[:-1], room.exits):
        room.directions[dir] = other
    if level == 0:
        return
    elif level == 1:
        print lang["INROOM"] % room.name
    else:
        print lang["ROOMBANNER"] % (room.name, room.prompt)
        # Only display room exits at level 3 or up
        if level >= 3:
            if len(room.exits) > 9:
                print lang["PASSAGEALL"]
            elif room.exits:
                print lang["EXITS"] % ", ".join(room.directions.keys())
            elif room != configuration.start:
                print lang["PASSAGEUP"]
            print
        # Display help at level 2 or up
        help = room.help()
        if help:
            sys.stdout.write(help)
        # Display grafitti at level 2 or up.
        if hasattr(room, "grafitti"):
            print rot13(room.grafitti) + "\n"
    # Only display other contents of room at level 4 or up
    if level >= 4:
        if room.type == "choices":
            print lang["WALLCHOICE"]
            print ", ".join(map(lambda x:x.name, room.items))
            print lang["WALLDEFAULT"] % room.menuvalue.name
        else:
            for symbol in room.items:
                if symbol.is_symbol() and configuration.is_visible(symbol) and not symbol.eval():
                    print lang["ISHERE"] % symbol.name
    # Some things are always shown
    if lanternloc == room:
        print lang["LONGLANTERN"]
    if gruestate == 2:
        print lang["DARK"]

def inventory():
    # Write mutable symbols, including defaulted modular symbols.
    configuration.module_suppress = 0
    if lanternloc == 'user':
        if gruestate == 3:
            print lang["BRASSON"]
        else:
            print lang["BRASSOFF"]
    __inventory_recurse(configuration.start)
    if configuration.trit_tie:
        configuration.module_suppress = (configuration.trit_tie.eval() == cml.m)
    # Write all derived symbols
    #config_sh.write(configuration.lang["SHDERIVED"])
    #for entry in configuration.dictionary.values():
    #    if entry.is_derived():
    #        __inventory_recurse(entry, config_sh)

def __inventory_recurse(node):
    if not configuration.saveable(node):
        return
    elif node.items:
        for child in node.items:
            __inventory_recurse(child)
    elif node.type != 'message':
        symname = configuration.prefix + node.name
        value = node.eval(configuration.debug)
        if not value or not node.setcount:
            return
        try:
            if node.type == "decimal":
                sys.stdout.write("%s=%d\n" % (symname, value))
            elif node.type == "hexadecimal":
                sys.stdout.write("%s=0x%x\n" % (symname, value))
            elif node.type == "string":
                sys.stdout.write("%s=\"%s\"\n" % (symname, value))
            elif node.type in ("bool", "trit"):
                sys.stdout.write("%s=%s\n" % (symname, `value`))
        except:
            (errtype, errval, errtrace) = sys.exc_info() 
            print "Internal error %s while writing %s." % (errtype, node)
            raise SystemExit, 1

class advent_menu(cmd.Cmd):
    "Adventure-game interface class."

    def set_symbol(self, symbol, value, freeze=0):
        "Set the value of a symbol -- line-oriented error messages."
        if symbol.is_numeric() and symbol.range:
            if not configuration.range_check(symbol, value):
                print lang["OUTOFBOUNDS"] % (symbol.range,)
                return 0
	(ok, effects, violations) = configuration.set_symbol(symbol, value, freeze)
        if effects:
            print lang["EFFECTS"]
            sys.stdout.write(string.join(effects, "\n") + "\n\n")
        if not ok:
	    print lang["ROLLBACK"] % (symbol.name, value)
            sys.stdout.write(string.join(violations, "\n") + "\n")
        return ok

    def __init__(self, myconfigfile=None, mybanner=""):
        cmd.Cmd.__init__(self)
	self.configfile = myconfigfile
        if mybanner and configuration.banner.find("%s") > -1:
            self.banner = configuration.banner % mybanner
        elif banner:
            self.banner = mybanner
        else:
            self.banner = configuration.banner
	self.current = configuration.start;
        self.prompt = "> "
        print lang["TWISTY"]%(configuration.banner,)
        self.last = None
        visit(configuration.start, 4)

    def do_look(self, line):
        if not line:			# Look at where we are
            visit(self.current, 4)
        elif line == "up":		# Look up
            if self.current == configuration.start:
                print lang["NODIR"]
            else:
                visit(self.current.menu, 2)
        elif line in directions:	# Look in a direction
            if line in self.current.directions.keys():
                visit(self.current.directions[line], 2)
            else:
                print lang["NODIR"]
        # Look at an option
        elif line in map(lambda x: x.name, filter(lambda x: x.is_logical(), self.current.items)):
            symbol = configuration.dictionary[line]
            print lang["VALUE"] % (line, symbol.eval())
            help = symbol.help()
            if help:
                sys.stdout.write(help)
        else:
            print lang["NOHERE"] % line
    do_loo = do_look

    def do_nearby(self, dummy):
        if self.current != configuration.start:
            print lang["ROOMBANNER"] % (self.current.menu.name, self.current.menu.prompt)
        for (dir, symbol) in self.current.directions.items():
            if symbol.type in ("menu", "choices") and configuration.is_visible(symbol):
                print ("%-2s: " % dir) + lang["ROOMBANNER"] % (symbol.name, symbol.prompt)
        if len(self.current.exits) > len(directions):
            print lang["EXTRAROOMS"] % ", ".join(map(lambda x: x.name, self.current.exits[9:]))
        print
    do_nea = do_nearby

    def do_go(self, symname):
        if not symname:
            print lang["EH?"]
            return
        symbol = configuration.dictionary.get(symname)
	if symbol and symbol.type in ("menu", "choices"):
	    self.current = symbol
            if not configuration.is_visible(self.current) and not self.current.frozen():
                print lang["SUPPRESSOFF"]
                self.suppressions = 0
	else:
	    print lang["NONEXIST"]

    def do_dir(self, dir):
        to = self.current.directions.get(dir)
        if to:
            self.current = to
        else:
            print lang["NOWAY"]
    def do_n(self, dummy): self.do_dir('n')
    def do_e(self, dummy): self.do_dir('e')
    def do_w(self, dummy): self.do_dir('w')
    def do_s(self, dummy): self.do_dir('s')
    def do_ne(self, dummy): self.do_dir('ne')
    def do_nw(self, dummy): self.do_dir('nw')
    def do_se(self, dummy): self.do_dir('se')
    def do_sw(self, dummy): self.do_dir('sw')
    def do_u(self, dummy): self.do_up(dummy)
    def do_d(self, dummy): self.do_dir('dn')

    def do_up(self, dummy):
        if self.current == configuration.start:
            print lang["GOODBYE"]
            raise SystemExit
        else:
            self.current = self.current.menu

    def do_inventory(self, dummy):
        inventory()
    do_inv = do_inventory
    do_i = do_inventory

    def do_drop(self, line):
        global lanternloc, gruestate
        if not line:
            print lang["EH?"]
            return
        words = line.lower().split()
        if words == ["all"] and self.current.type != "choices":
            words = map(lambda x:x.name, filter(lambda x:x.is_logical() and configuration.is_visible(x) and not x.eval(), self.current.items))
            if lanternloc == 'user':
                words.append(lang["LANTERN"])
        for thing in words:
            if thing == lang["LANTERN"]:
                lanternloc = self.current
                gruestate = 1
                print lang["LANTERNDROP"]
            else:
                symbolname = thing.upper()
                symbol = configuration.dictionary.get(symbolname)
                if not symbol:
                    print lang["NOSUCHAS"], symbolname
                    continue
                elif not symbol.eval():
                    print lang["NOHAVE"] % symbolname
                    continue
                elif symbol.menu.type == "choices":
                    if symbol.menu != self.current:
                        print lang["NOBUTTON"] % symbolname
                    else:
                        print lang["TRYPRESS"]
                    return
                elif symbol.is_logical():
                    ok = self.set_symbol(symbol, cml.n)
                elif symbol.is_numeric():
                    ok = self.set_symbol(symbol, 0)
                elif symbol.type == "string":
                    ok = self.set_symbol(symbol, "")
                if ok:
                    print lang["DROPPED"] % symbol.name
    do_dro = do_drop

    def do_take(self, line):
        global lanternloc
        if not line:
            print lang["EH?"]
            return
        words = line.lower().split()
        if words == ["all"] and self.current.type != "choices":
            words = map(lambda x:x.name, filter(lambda x:x.is_logical() and configuration.is_visible(x) and not x.eval(), self.current.items))
            if lanternloc == self.current:
                words.append(lang["LANTERN"])
        if ("module" in words):
            tritval = cml.m
            words.remove("module")
        else:
            tritval = cml.y
        for thing in words:
            if thing == lang["LANTERN"]:
                lanternloc = 'user'
                print lang["LANTERNTAKE"]
            else:
                symbolname = thing.upper()
                symbol = configuration.dictionary.get(symbolname)
                if not symbol:
                    print lang["NOSUCHAS"], symbolname
                elif symbol.menu != self.current:
                    print lang["NOHERE"] % symbol.name
                elif symbol.is_logical():
                    if self.set_symbol(symbol, tritval):
                        print lang["TAKEN"] % symbol.name
                else:
                    print lang["USESET"] % symbol.name
    do_tak = do_take

    def do_press(self, line):
        if not line:
            print lang["EH?"]
        else:
            symbol = configuration.dictionary.get(line)
            if not symbol or symbol.menu != self.current:
                print lang["NOHERE"] % line
            else:
                self.set_symbol(symbol, cml.y)
    do_pus = do_push = do_pre = do_press 

    def do_light(self, dummy):
        global gruestate
        if lanternloc == 'user':
            print lang["GLOW"]
            gruestate = 3
        else:
            print lang["NOHERE"] % lang["LANTERN"]
    do_lig = do_light

    def do_set(self, line):
        symbol = None
        try:
            (symname, value) = line.split()
            symbol = configuration.dictionary[symname]
        except:
            print lang["EH?"]
        if not symbol:
            print lang["NOSUCHAS"], symbol.name
        elif symbol.menu != self.current:
            print lang["NOHERE"] % symbol.name
        elif symbol.menu.type == "choices" or symbol.is_logical():
            print lang["CANTDO"]
        elif symbol.is_numeric():
            self.set_symbol(symbol, int(value))
        elif symbol.type == "string":
            self.set_symbol(symbol, value)

    def do_xyzzy(self,  dummy):
        # Toggle the suppressions flag
        configuration.suppressions = not configuration.suppressions
        if configuration.suppressions:
            print lang["SUPPRESSON"]
        else:
            print lang["SUPPRESSOFF"]
	return 0

    def do_load(self, line):
        if not line:
            print lang["EH?"]
            return
        file = string.strip(line)
        if file.find(' ') > -1:
            (file, option) = file.split(' ')
        try:
            (changes, errors) = configuration.load(file, freeze=(option == "frozen"))
        except IOError:
            print lang["LOADFAIL"] % file
        else:
            if errors:
                print errors
            print lang["INCCHANGES"] % (changes,file)
            if configuration.side_effects:
                sys.stdout.write(string.join(configuration.side_effects, "\n") + "\n")
    do_loa = do_load

    def do_save(self, line):
        if not line:
            print lang["EH?"]
            return
	file = string.strip(line)
        failure = configuration.save(file, cml.Baton(lang["SAVESTART"] % file, lang["SAVEEND"]))
        if failure:
            print failure
    do_sav = do_save

    def do_exit(self, dummy):
	# Terminate this cmd instance, saving configuration
        self.do_s(configfile)
	return 1
    do_exi = do_exit

    def do_quit(self, line):
	# Terminate this cmd instance, not saving configuration
	return 1
    do_qui = do_quit

    # Debugging commands -- not documented
    def do_verbose(self, line):
	# Set the debug flag
        if not line:
            configuration.debug += 1
        else:
            configuration.debug = int(line)
	return 0
    do_ver = do_verbose
    
    def do_examine(self, line):
	# Examine the state of a given symbol
	symbol = string.strip(line)
	if configuration.dictionary.has_key(symbol):
	    entry = configuration.dictionary[symbol]
	    print entry
            if entry.constraints:
                print lang["CONSTRAINTS"]
                for wff in entry.constraints:
                    print cml.display_expression(wff)
            if configuration.is_visible(entry):
                print lang["VISIBLE"]
            else:
                print lang["INVISIBLE"]
	    help = entry.help()
	    if help:
		print help
            else:
		print lang["NOHELP"] % (entry.name,)
        elif symbol == "lantern":
            if lanternloc == "user" or lanternloc == self.current:
                print lang["LANTERNHELP"]
            else:
                print lang["NOHERE"] % lang["LANTERN"]
	else:
	    print lang["NOSUCHAS"], symbol 
	return 0
    do_exa = do_examine

    def emptyline(self):
	return 0
    def do_commands(self, dummy):
        print string.join(map(lambda x: lang[x],
                                  ("LHELP", "NHELP", "GHELP", "IHELP",
                                   "DHELP", "THELP", "PHELP", "SETHELP",
                                   "LDHELP", "SHELP", "XYZZY",
                                   "QHELP", "XHELP", "DIRHELP")),
                              "\n")
    def help_look(self):
	print lang["LHELP"]
    help_loo = help_look
    def help_nearby(self):
	print lang["NHELP"]
    help_nea = help_nearby
    def help_go(self):
	print lang["GHELP"]
    def help_inventory(self):
	print lang["IHELP"]
    help_inv = help_inventory
    def help_drop(self):
	print lang["DHELP"]
    help_dro = help_drop
    def help_take(self):
	print lang["THELP"]
    help_tak = help_take
    def help_press(self):
	print lang["PHELP"]
    help_pus = help_push = help_pre = help_press
    def help_set(self):
	print lang["SETHELP"]
    def help_xyzzy(self):
        print lang["XYZZY"]
    def help_load(self):
	print lang["LDHELP"]
    help_loa = help_load
    def help_save(self):
	print lang["SHELP"]
    help_sav = help_save
    def help_quit(self):
	print lang["QHELP"]
    help_qui = help_quit
    def help_exit(self):
	print lang["XHELP"]
    help_exi = help_exit
    def do_help(self, dummy):
        print lang["GENHELP"]
    def postcmd(self, stop, dummy):
	if stop:
	    return stop
        if self.current != self.last:
            newroom(self.current)
            visit(self.current, 4 - 3 * (self.current.visits > 1))
            self.last = self.current
	return None

# Rulebase loading and option processing

def load_system(cmd_options, cmd_arguments):
    "Read in the rulebase and handle command-line arguments."
    global debug, configfile, configuration
    debug = 0;
    configfile = None

    if not cmd_arguments:
        rulebase = "rules.out"
    else:
        rulebase = cmd_arguments[0]
    try:
	open(rulebase, 'rb')
    except IOError:
        print lang["NOFILE"] % (rulebase,)
        raise SystemExit
    configuration = cmlsystem.CMLSystem(rulebase)

    process_options(configuration, cmd_options)

    configuration.debug_emit(1, lang["PARAMS"] % (configfile,configuration.prefix))

    # Perhaps the user needs modules enabled initially
    if configuration.trit_tie and cml.evaluate(configuration.trit_tie):
        configuration.trits_enabled = 1

    # Don't count all these automatically generated settings
    # for purposes of figuring out whether we should confirm a quit.
    configuration.commits = 0

    return configuration

def process_include(myconfiguration, file, freeze):
    "Process a -i or -I inclusion option."
    # Failure to find an include file is non-fatal
    try:
        (changes, errors) = myconfiguration.load(file, freeze)
    except IOError:
        print lang["LOADFAIL"] % file
        return
    if errors:
        print errors
    elif myconfiguration.side_effects:
        print lang["SIDEFROM"] % file
        sys.stdout.write(string.join(myconfiguration.side_effects, "\n") + "\n")

def process_define(myconfiguration, val, freeze):
    "Process a -d=xxx or -D=xxx option."
    parts = string.split(val, "=")
    sym = parts[0]
    if myconfiguration.dictionary.has_key(sym):
        sym = myconfiguration.dictionary[sym]
    else:
        myconfiguration.errout.write(lang["SYMUNKNOWN"] % (`sym`,))
        sys.exit(1)
    if sym.is_derived():
        myconfiguration.debug_emit(1, lang["DERIVED"] % (`sym`,))
        sys.exit(1)
    elif sym.is_logical():
        if len(parts) == 1:
            val = 'y'
        elif parts[1] == 'y':
            val = 'y'
        elif parts[1] == 'm':
            myconfiguration.trits_enabled = 1
            val = 'm'
        elif parts[1] == 'n':
            val = 'n'
    elif len(parts) == 1:
        print lang["NOCMDLINE"] % (`sym`,)
        sys.exit(1)
    else:
        val = parts[1]
    (ok, effects, violations) = myconfiguration.set_symbol(sym,
                                     myconfiguration.value_from_string(sym, val),
                                     freeze)
    if effects:
        print lang["EFFECTS"]
        sys.stdout.write(string.join(effects, "\n") + "\n\n")
    if not ok:
        print lang["ROLLBACK"] % (sym.name, val)
        sys.stdout.write(string.join(violations,"\n")+"\n")

def process_options(myconfiguration, options):
    # Process command-line options second so they override
    global list, configfile, debug, banner
    configfile = "config.out"
    for (switch, val) in options:
	if switch == '-B':
	    banner = val
	elif switch == '-d':
            process_define(myconfiguration, val, freeze=0)
	elif switch == '-D':
            process_define(myconfiguration, val, freeze=1)
	elif switch == '-i':
            process_include(myconfiguration, val, freeze=0)
	elif switch == '-I':
            process_include(myconfiguration, val, freeze=1)
	elif switch == '-l':
	    list = 1
	elif switch == '-o':
	    configfile = val
	elif switch == '-v':
	    debug = debug + 1
            myconfiguration.debug = myconfiguration.debug + 1
	elif switch == '-S':
	    myconfiguration.suppressions = 0

# Main sequence -- isolated here so we can profile it

def main(options, arguments):
    global configuration
    try:
        myconfiguration = load_system(options, arguments)
    except KeyboardInterrupt:
        raise SystemExit

    # Set seed for random-number functions
    whrandom.seed(int(time.time()) % 256, os.getpid() % 256, 23)
    global grafittishuffle
    grafittishuffle = shuffle(len(grafitti))

    print lang["WELCOME"] % cml.version
    myconfiguration.errout = sys.stdout
    advent_menu(configfile, banner).cmdloop()

if __name__ == '__main__':
    try:
        runopts = "aB:cD:d:h:i:I:lo:P:R:StVvWx"
	(options,arguments) = getopt.getopt(sys.argv[1:], runopts)
        if os.environ.has_key("CML2OPTIONS"):
            (envopts, envargs) = getopt.getopt(
                os.environ["CML2OPTIONS"].split(),
                runopts)
            options = envopts + options
    except:
	print lang["BADOPTION"] 
	sys.exit(1)

    for (switch, val) in options:
        if switch == "-V":
            print "cmladvent", cml.version
            raise SystemExit
	elif switch == '-P':
	    proflog = val
    try:
        import readline
    except:
        pass

    try:
        if proflog:
            import profile, pstats
            profile.run("main(options, arguments)", proflog)
        else:
            main(options, arguments)
    except KeyboardInterrupt:
        #if configuration.commits > 0:
        #    print lang["NOTSAVED"]
        print lang["ABORTED"]
    except "UNSATISFIABLE":
        #configuration.save("post.mortem")
        print lang["POSTMORTEM"]
        raise SystemExit, 1

# That's all, folks!
