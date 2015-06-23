#!/usr/bin/env python
#
# cmlconfigure.py -- CML2 configurator front ends
# by Eric S. Raymond, <esr@thyrsus.com>
#
# Here is the actual code for the configurator front ends.
#
import sys

if sys.version[0] < '2':
    print "Python 2.0 or later is required for this program."
    raise SystemExit, 1

import os, string, getopt, cmd, re, time
import cml, cmlsystem, webbrowser

# Globals
debug = list = 0
force_batch = force_tty = force_curses = force_x = force_q = force_debugger = None
readlog = proflog = None
banner = ""

configuration = None
current_node = None
helpwin = None

# User-visible strings in the configurator.  Separated out in order to
# support internationalization.
_eng = {
    "ABORTED":"Configurator aborted.",
    "ANCESTORBUTTON":"Show ancestors of...",
    "BACKBUTTON":"Back",
    "BADBOOL":"Bad value for boolean or trit.",
    "BADOPTION":"cmlconfigure: unknown option on command line.\n",
    "BADREQUIRE":"Some requirements are violated: ",
    "BADVERIFY":"ERROR===>Expected <%s>=<%s>, instead of <%s>",
    "BOOLEAN":"`y' and `n' can only be applied to booleans or tristates",
    "CANCEL":"Cancel",
    "CANNOTSET":"    Can't assign this value for bool or trit symbol.",
    "CANTGO":"Cannot go to that symbol (it's probably derived).",
    "CCAPHELP":"C -- show constraints (all, or including specified symbol)",
    "CHARINVAL":"Invalid character in numeric field",
    "CHELP":"c -- clear the configuration",
    "CMDHELP":"Command summary",
    "COMPILEOK": "Compilation OK.",
    "COMPILEFAIL": "Compilation failed.",
    "CONFIRM":"Confirmation",
    "CONSTRAINTS":"Constraints:",
    "CURSQUERY":"Type '?' for help",
    "CURSESSET":"Curses mode set symbol %s to value %s",
    "DEBUG": "Debugging %s ruleset.", 
    "DEFAULT":"Default: ",
    "DEPENDENTBUTTON":"Show dependents of...",
    "DERIVED":"Symbol %s is derived and cannot be set.",
    "DONE":"Done",
    "EDITING":"Editing %s",
    "EFFECTS":"Side effects:",
    "EMPTYSEARCH":"You must enter a regular expression to search for",
    "SUPPRESSBUTTON":"Suppress",
    "SUPPRESSOFF":"Suppression turned off",
    "SUPPRESSON":"Suppression turned on",
    "ECAPHELP": "E -- dump the state of the binding history",
    "EHELP": "e -- examine specified symbol",
    "EXIT":"Exit",
    "EXITCONFIRM":"[Press q to exit, any other key to continue]",
    "FHELP": "f -- freeze specified symbol",
    "FIELDEDIT":"Field Editor help",
    "FILEBUTTON":"File",
    "FREEZEBUTTON":"Freeze", 
    "FREEZE":"Freeze all symbols with a user-supplied value?", 
    "FREEZELABEL":"(FROZEN)",
    "FROZEN":"This symbol has been frozen and cannot be modified.",
    "GHELP":"g -- go to a named symbol or menu (follow g with the label)",
    "GO":"Go",
    "GOBUTTON":"Go to...",
    "GOTOBYNAME":"Go to symbol by name: ",
    "GPROMPT":"Symbol to set or edit: ",
    "HELPBANNER": "Press ? for help on current symbol, h for command help",
    "HELPBUTTON":"Help",
    "HELPFOR":"Help for %s",
    "HSEARCHBUTTON":"Search help text...",
    "ICAPHELP":"I -- read in and freeze a configuration (follow I with the filename)",
    "IHELP":"i -- read in a configuration (follow i with the filename)",
    "INCCHANGES":"%d change(s) from %s",
    "INFO":"Information",
    "INVISIBLE":"Symbol is invisible",
    "INVISILOCK":" and invisibility is locked.",
    "INVISINONE":"Symbol is invisible (no visibility predicate).",
    "INVISOUT":"Symbol %s is currently invisible and will not be saved out.",
    "LOADFILE":"Load configuration from: ", 
    "LOADBUTTON":"Load...", 
    "LOADFAIL":"Loading '%s' failed, continuing...",
    "LOADFREEZE":"Load frozen configuration from: ", 
    "MDISABLED":"Module-valued symbols are not enabled",
    "MHELP":"m -- set the value of the selected symbol to m",
    "MNOTVALID":"   m is not a valid value for %s",
    "MORE":"(More lines omitted...)",
    "NAVBUTTON":"Navigation",
    "NEW":"(NEW)",
    "NHELP":"n -- set the value of the selected symbol to n",
    "NNOTVALID":"   n is not a valid value for %s",
    "NOANCEST":"No ancestors.",
    "NOCMDLINE":"%s is the wrong type to be set from the command line",
    "NOCURSES":"Your Python seems to be lacking curses support.",
    "NODEPS":"No dependents.",
    "NOFILE":"cmlconfigure: '%s' does not exist or is unreadable.",
    "NOHELP":"No help available for %s",
    "NOMATCHES":"No matches.",
    "NOMENU":"Symbol %s is not in a menu.",
    "NONEXIST":"No such symbol or menu as %s.",
    "NOPOP":"Can't pop back further",
    "NOSAVEP":"No save predicate",
    "NOSUCHAS":"No such symbol as",
    "NOSYMBOL":"No symbol is currently selected.",
    "NOTKINTER":"Can't find tkinter support, falling back to curses mode...",
    "NOTSAVED":"Configuration not saved",
    "NOVISIBLE":"No visible items on starting menu.",
    "OK":"Operation complete",
    "OUTOFBOUNDS":"%s no good; legal values are in %s",
    "PAGEPROMPT":"[Press Enter to continue] ",
    "PARAMS":"    Config = %s, prefix = %s",
    "PDHELP":"p -- print the configuration",
    "PHELP":"p -- back up to previous symbol",
    "POSTMORTEM":"The ruleset was inconsistent.",
    "PRESSANY":"[Press any key to continue]",
    "PROBLEM":"Problem",
    "QHELP":"q -- quit, discarding changes",
    "QUITBUTTON":"Quit",
    "QUITCONFIRM":"Really exit without saving?",
    "RADIOBAD":"    That's not a valid selection.",
    "DISCRETEVALS":"%s may have these values:\n",
    "REALLY":"Really exit without saving?",
    "ROLLBACK":"%s=%s would have violated these requirements:",
    "SAVEABLE":"Symbol is saveable.",
    "SAVEAS":"Save As...",
    "SAVEBUTTON":"Save & Exit",
    "SAVECONFIRM":"Save confirmation",
    "SAVEEND":"Done",
    "SAVEFILE":"Save configuration to: ",
    "SAVESTART":"Saving %s",
    "SAVING":"Saving...",
    "SEARCHBUTTON":"Search symbols...",
    "SEARCHFAIL":"No matches.",
    "SEARCHINVAL":"Invalid Regular Expression:",
    "SEARCHHELP":"Search help text for: ",
    "SEARCHSYMBOLS":"Search symbols for regular expression: ",
    "SETCOUNT":"Symbol has been set %d time(s)",
    "SHELP":"s -- save the configuration (follow with a filename)",
    "SHOW_ANC":"Show ancestors of symbol: ",
    "SHOW_DEP":"Show dependents of symbol: ",
    "SIDEEFFECTS":"Side Effects",
    "SIDEFROM":"Side effects from %s:",
    "SKIPCALLED":"    Skip-to-query called from %s",
    "SKIPEXIT":"    Skip-to-query arrived at %s",
    "SYMUNKNOWN":"cmlconfigure: unknown symbol %s\n",
    "TERMNOTSET":"TERM is not set.",
    "TERMTOOSMALL":"Your terminal is too small to support curses mode.",
    "TOOLONG":"String is too long to edit.  Use cmlconfigure -t.", 
    "TRIT":"`m' can only be applied to tristates",
    "TTYQUERY":"Type '?' at any prompt for help, 'h' for command help.",
    "TTYSUMMARY":"		     Command summary:",
    "UHELP":"u -- toggle interactive flag.",
    "UNSUPPRESSBUTTON":"Unsuppress",
    "UNKNOWN":"Unknown command %s -- type `h' for a command summary",
    "UPBUTTON":"Up",
    "UNSAVEABLE":"Symbol is unsaveable.",
    "VCAPHELP":"V -- verify that a symbol has a given value",
    "VERBOSITY": "Verbosity level is %d",
    "VERSION":", version %s.",
    "VHELP": "v -- increase the verbosity level, or set to numeric argument",
    "VISIBLE":"Symbol is visible",
    "VISIBILITY":"Visibility: ",
    "WARNING":"Warning",
    "WELCOME":"Welcome to the %s",
    "XHELP":"x -- exit, saving the configuration",
    "YHELP":"y -- set the value of the selected symbol to y",
    "YNOTVALID":"   y is not a valid value for %s",

    "TTYHELP":"""
Type '?' to see help text associated with the current symbol.
Typing Return accepts the default for the query.

Each prompt consists of a label, followed by a colon, followed by prompt text,
followed by a value and a bracketed range indication.  The brackets indicate
whether the symbol is bool [] modular <> or integer/string ().  The current
value in the brackets may be blank (indicating bool or trit n), 'M' (indicating
trit m) or an integer or string literal. If `?' follows, it means help is
available for this symbol.
""",
    "CURSHELP":"""\
Use up- and down-arrows to change the current selection.  Use spacebar or Enter
to enter a selected sub-menu, or to toggle the value of a selected boolean
symbol, or to cycle through the possible y/m/n values of a selected tristate
symbol, or to begin editing the value of a symbol that has string or decimal
or hexadecimal type.  Use left-arrow to back out of a menu.

'y', 'm', and 'n' set boolean or trit symbols to the corresponding values.

When you are editing a symbol value, the highlight on its value field will be
switched off.  A subset of Emacs's default key bindings is available to edit
the field; to see details, enter such a field (by typing a space with the
symbol selected) and press your tab key.  Other characters will usually be
inserted at the cursor location.  Press up-arrow or down-arrow or Enter to
stop editing a field.

Type `x' to save configuration and exit, `q' to exit without saving, `s' to
save the configuration to a named file, and `i' to read in a configuration by
filename.  -I reads in a configuration and freezes the variables.

Type '?' to see any help text associated with the current symbol.  Type 'h'
to see this command summary again.  Some expert commands are documented
in separate help; press TAB from this help screen to see it.\
""",
    "EDITHELP":"""\
Numbers and short strings can be edited in their display fields near the
left edge of the screen.  To edit longer strings, enter a right arrow at the
left edge of the display field.  This will pop up a wide window in which you
can edit the value.  The field editor supports a subset of Emacs's default
key bindings.

    Ctrl-A      Go to left edge of window.
    Ctrl-B      Cursor left, wrapping to previous line if appropriate.
    Ctrl-D      Delete character under cursor.
    Ctrl-E      Go to right edge (nospaces off) or end of line (nospaces on).
    Ctrl-F      Cursor right, wrapping to next line when appropriate.
    Ctrl-H      Delete character backward.
    Ctrl-J      Terminate if the window is 1 line, otherwise insert newline.
    Ctrl-K      If line is blank, delete it, otherwise clear to end of line.
    Ctrl-L      Refresh screen
    Ctrl-N      Cursor down; move down one line.
    Ctrl-O      Insert a blank line at cursor location.
    Ctrl-P      Cursor up; move up one line.
    KEY_LEFT = Ctrl-B, KEY_RIGHT = Ctrl-F, KEY_UP = Ctrl-P, KEY_DOWN = Ctrl-N
    KEY_BACKSPACE = Ctrl-h

To leave the field editor, press Enter or carriage return, or use the up and
down arrows. Ctrl-g leaves the field editor ant revers to the unedited value.\
""",
    "EXPERTHELP":"""\
Here are the expert commands:

/ -- Search for symbols matching a given regular expression in either
     the symbol name or prompt text.

g -- Go to symbol. Go directly to symbol. Do not pass go, do not collect $200.
     If the target symbol is suppressed, clear the suppression flag.

i -- Load a configuration.  Set all the variables in the given config file.

I -- Load a configuration.  Set all the variables in the config file,
     then freeze them so they can't be overridden.

e -- Examine the value of the named symbol.

S -- Toggle the suppression flag (normally on).  When the suppression flag
     is off, invisible symbols are not skipped.

Type 'h' to see the help for ordinary commands.
""",
    "TKCMDHELP":"""\
The main window is a configuration menu browser. It presents you with a menu of
symbols and sub-menu buttons.  If there is help available for a symbol or menu,
there will be an active `Help' button off to the right.  In the help window,
URLS are live; clicking on them will launch a browser.

You can set boolean or tristate symbols simply by clicking on the appropriate
value.  You can change the values of numeric and string symbols by editing
their fill-in fields.

In the file menu, the `Load' command allows you to load a configuration file.
Values in the configuration file are set as though the user had selected them.

In the file menu, the `Freeze' command freezes all symbols that have
been set by user actions (including loading configuration files) so they
won't be queried again and cannot subsequently be overridden.

In the File menu, the `Save' command saves the configuration file to the
location specified by configurator command-line options).  The `Save As...'
command saves the defconfig file (only) to a named location.

The Back command in the Navigation menu (and the toolbar button) returns you to
the menu visited before this one.  When you back out of a sub-menu, the label
on its button is highlighted in blue.

The Go command in the Navigation menu moves you to a named menu, or to the
menu containing a named symbol.  After a `Go' command the target is
highlighted blue.

The Search command in the Navigation menu matches a given regular expression
against the names and prompt text of all configuration symbols. It generates
a menu that includes all hits, and turns off the elisions flag.

The Suppress/Unsuppress command in the Navigation toggles whether suppressed
symbols are visible or not.  Normally, suppressed symbols are invisible and the
menu entry reads `Unsuppress'.  The suppression flag may also be cleared by
using the `Go' command to visit a suppressed symbol, or by doing a Search.
""",
    "CLIHELP":"""\

Usage: clmlconfigure.py [-tcxqbs] [-[Dd] sym] [-[Ii] file]
                        [-B banner] [-o output] [-v]

-t            force tty (line-oriented) mode
-c            force curses (screen-oriented) mode
-x            force default X mode
-q            force expermintal tree-widget-based X interface
-b            batch mode (process command-line options only).
-s            debugger mode

-d sym[=val]  set a symbol
-D sym[=val]  set and freeze a symbol
-i            include a config file
-I            include a config file, frozen

-B banner     set banner string
-o file       write config to specified file
-v            increment debug level

""",
}

# Eventually, do more intelligent selection using LOCALE
lang = _eng

# Shared code

def cgenvalue(symbol):
    "Generate an appropriate prompt for the given symbol."
    value = symbol.eval()
    if symbol.type in ("bool", "trit"):
        if symbol.type == "trit" and configuration.trits_enabled:
            format = "<%s>"
        else:
            format = "[%s]"
        if value == cml.y:
            return format % "Y"
        elif value == cml.m:
            return format % "m"
        elif value == cml.n:
            return format % " "
    elif symbol.type == "choices":
        if symbol.menuvalue:
            return symbol.menuvalue.prompt
        elif symbol.default:
            return symbol.default.prompt
        else:
            return "??"
    elif symbol.type == "message":
        return ""
    elif symbol.type == "menu":
        return "-->"		# Effective only in menuconfig
    elif symbol.type in ("decimal", "string"):
        return str(value)
    elif symbol.type == "hexadecimal":
        return "0x%x" % value
    else:
        return "??"

def cgenprompt(symbol, novice=1):
    "Decorate a symbol prompt string according to its warndepend conditions."
    res = ""
    for warndepend in symbol.warnings:
        if novice:
            res += warndepend.name + ", "
        else:
            res += warndepend.name[0] + ", "
    if symbol.warnings:
        res = " (" + res[:-2] + ")"
    return symbol.prompt + res

def interactively_visible(symbol):
    "Should a symbol be visible interactively?"
    return configuration.is_visible(symbol) and not symbol.frozen()

# Line-oriented interface

class tty_style_base(cmd.Cmd):
    "A class for browsing a CML2 menu subtree with line-oriented commands."

    def set_symbol(self, symbol, value, freeze=0):
        "Set the value of a symbol -- line-oriented error messages."
        if symbol.is_numeric() and symbol.range:
            if not configuration.range_check(symbol, value):
                print lang["OUTOFBOUNDS"] % (value, symbol.range,)
                return
	(ok, effects, violations) = configuration.set_symbol(symbol, value, freeze)
        if effects:
            print lang["EFFECTS"]
            sys.stdout.write(string.join(effects, "\n") + "\n\n")
        if ok:
            if not interactively_visible(symbol):
                print lang["INVISOUT"] % symbol.name
        else:
	    print lang["ROLLBACK"] % (symbol.name, value)
            sys.stdout.write(string.join(map(repr, violations), "\n") + "\n")

    def page(self, text):
        text = string.split(text, "\n")
        pagedepth = os.environ.get("LINES")
        if pagedepth:
            pagedepth = int(pagedepth)
        else:
            pagedepth = 24
        base = 0
        try:
            while base < len(text):
                for i in range(base, base+pagedepth):
                    if i >= len(text):
                        break;
                    print text[i]
                base = base + pagedepth
                raw_input(lang["PAGEPROMPT"])
        except KeyboardInterrupt:
            print ""

    def __init__(self, config, mybanner):
        cmd.Cmd.__init__(self)
	self.config = config
        if mybanner and configuration.banner.find("%s") > -1:
            self.banner = configuration.banner % mybanner
        elif mybanner:
            self.banner = mybanner
        else:
            self.banner = configuration.banner
	self.current = configuration.start;

    def do_g(self, line):
	if configuration.dictionary.has_key(line):
	    self.current = configuration.dictionary[line]
            configuration.visit(self.current)
            if not interactively_visible(self.current) and not self.current.frozen():
                print lang["SUPPRESSOFF"]
                self.suppressions = 0
	    if self.current.type in ("menu", "message"):
		self.skip_to_query(configuration.next_node, 1)
	else:
	    print lang["NONEXIST"] % line
    def do_i(self, line):
        file = string.strip(line)
        try:
            (changes, errors) = configuration.load(file, freeze=0)
        except IOError:
            print lang["LOADFAIL"] % file
        else:
            if errors:
                print errors
            print lang["INCCHANGES"] % (changes,file)
            if configuration.side_effects:
                sys.stdout.write(string.join(configuration.side_effects, "\n") + "\n")
    def do_I(self, line):
        file = string.strip(line)
        try:
            (changes, errors) = configuration.load(file, freeze=1)
        except IOError:
            print lang["LOADFAIL"] % file
        else:
            if errors:
                print errors
            print lang["INCCHANGES"] % (changes,file)
            if configuration.side_effects:
                sys.stdout.write(string.join(configuration.side_effects, "\n") + "\n")
    def do_y(self, line):
        if not line:
            target = self.current
        else: 
            # Undocumented feature -- "y FOO" sets FOO to y.
            line = string.strip(line)
            if not configuration.dictionary.has_key(line):
                print lang["NONEXIST"] % line
                return
            else:
                target = configuration.dictionary[line]
	if not target.type in ("trit", "bool"):
	    print lang["YNOTVALID"] % (target.name)
	else:
	    self.set_symbol(target, cml.y)
	return None
    def do_Y(self, line):
        self.do_y(line)
    def do_m(self, line):
        if not line:
            target = self.current
        else:
            # Undocumented feature -- "m FOO" sets FOO to m.
            line = string.strip(line)
            if not configuration.dictionary.has_key(line):
                print lang["NONEXIST"] % line
                return
            else:
                target = configuration.dictionary[line]
	if not target.type == "trit":
	    print lang["MNOTVALID"] % (target.name)
        elif not configuration.trits_enabled:
	    print lang["MNOTVALID"] % (target.name)
	else:
	    self.set_symbol(target, cml.m)
	return None
    def do_M(self, line):
        self.do_m(line)
    def do_n(self, line):
        if not line:
            target = self.current
        else:
            # Undocumented feature -- "n FOO" sets FOO to n.
            line = string.strip(line)
            if not configuration.dictionary.has_key(line):
                print lang["NONEXIST"] % line
                return
            else:
                target = configuration.dictionary[line]
	if not target.type in ("trit", "bool"):
	    print lang["NNOTVALID"] % (target.name)
	else:
	    self.set_symbol(target, cml.n)
	return None
    def do_N(self, line):
        self.do_n(line)
    def do_s(self, line):
	file = string.strip(line)
        failure = configuration.save(file, cml.Baton(lang["SAVESTART"] % file, lang["SAVEEND"]))
        if failure:
            print failure
    def do_x(self, dummy):
	# Terminate this cmd instance, saving configuration
        self.do_s(config)
	return 1
    def do_C(self, line):
        # Show constraints (all, or all including specified symbol).
        filter = None
        if line:
            line = line.strip()
            if configuration.dictionary.has_key(line):
                filter = configuration.dictionary[line]
        for i in range(len(configuration.constraints)):
            constraint = configuration.constraints[i].predicate
            reduced = configuration.reduced[i]
            if reduced in (cml.n, cml.m, cml.y):
                continue
            if filter and filter not in cml.flatten_expr(constraint):
                continue
            if constraint == reduced:
                print cml.display_expression(reduced)[1:-1]
            else:
                print "%s -> %s" % (constraint,cml.display_expression(reduced)[1:-1])
        return 0
    def do_q(self, line):
	# Terminate this cmd instance, not saving configuration
	raise SystemExit, 1

    def do_v(self, line):
	# Set the debug flag
        if not line:
            configuration.debug += 1
        else:
            configuration.debug = int(line)
        print lang["VERBOSITY"] % configuration.debug
	return 0
    def do_e(self, line):
	# Examine the state of a given symbol
	symbol = string.strip(line)
	if configuration.dictionary.has_key(symbol):
	    entry = configuration.dictionary[symbol]
	    print entry
            if entry.constraints:
                print lang["CONSTRAINTS"]
                for wff in entry.constraints:
                    print cml.display_expression(wff)
            if interactively_visible(entry):
                print lang["VISIBLE"]
            elif entry.visibility is None:
                print lang["INVISINONE"]
            elif configuration.eval_frozen(entry.visibility):
                print lang["INVISIBLE"] + lang["INVISILOCK"]
            else:
                print lang["INVISIBLE"]
            if entry.saveability == None:
                print lang["NOSAVEP"]
            if configuration.saveable(entry):
                print lang["SAVEABLE"]
            else:
                print lang["UNSAVEABLE"]
            if entry.setcount:
                print lang["SETCOUNT"] % entry.setcount
	else:
	    print lang["NOSUCHAS"], symbol 
	return 0
    def do_E(self, dummy):
        # Dump the state of the bindings stack
        print configuration.binddump()
        return 0
    def do_S(self, dummy):
        # Toggle the suppressions flag
        configuration.suppressions = not configuration.suppressions
        if configuration.suppressions:
            print lang["SUPPRESSON"]
        else:
            print lang["SUPPRESSOFF"]
	return 0
    def help_e(self):
	print lang["EHELP"]
    def help_E(self):
	print lang["ECAPHELP"]
    def help_g(self):
	print lang["GHELP"]
    def help_i(self):
	print lang["IHELP"]
    def help_I(self):
	print lang["ICAPHELP"]
    def help_y(self):
	print lang["YHELP"]
    def help_m(self):
	print lang["MHELP"]
    def help_n(self):
	print lang["NHELP"]
    def help_s(self):
	print lang["SHELP"]
    def help_q(self):
	print lang["QHELP"]
    def help_v(self):
	print lang["VHELP"]
    def help_x(self):
	print lang["XHELP"]
    def do_help(self, line):
        line = line.strip()
        if configuration.dictionary.has_key(line):
            target = configuration.dictionary[line]
        else:
            target = self.current
        help = target.help()
	if help:
	    self.page(help)
	else:
	    print lang["NOHELP"] % (self.current.name,)

class tty_style_menu(tty_style_base):
    "Interface for configuring with line-oriented commands."
    def skip_to_query(self, function, showbase=0):
        configuration.debug_emit(2, lang["SKIPCALLED"] % (self.current.name,))
        if showbase:
	    if self.current.type == "menu":
		self.menu_banner(self.current)
                configuration.visit(self.current)
	while 1:
	    self.current = function(self.current)
            if self.current == configuration.start:
                break;
            elif self.current.is_symbol() and self.current.frozen():
                # sys.stdout.write(self.generate_prompt(self.current) + lang["FREEZELABEL"] + "\n")
                continue
	    elif not interactively_visible(self.current):
		continue
	    elif self.current.type in ("menu", "choices"):
		self.menu_banner(self.current)
                configuration.visit(self.current)
	    if not self.current.type in ("message", "menu"):
		break;
        configuration.debug_emit(2, lang["SKIPEXIT"] % (self.current.name,))
        if self.current == configuration.start:
            self.do_s(config)
            raise SystemExit

    def menu_banner(self, menu):
        sys.stdout.write("*\n* %s: %s\n*\n" % (menu.name, menu.prompt))

    def generate_prompt(self, symbol):
	leader = "   " * symbol.depth
        genpart = cgenvalue(symbol)
        if symbol.help and not symbol.frozen():
            havehelp = "?"
        else:
            havehelp = ""
        if configuration.is_new(symbol):
            genpart += " " + lang["NEW"]
	if symbol.type in ("bool", "trit"):
	    return leader+"%s: %s %s%s: " % (symbol.name, cgenprompt(symbol), genpart, havehelp)
        elif symbol.enum:
            dflt = cml.evaluate(symbol, debug)
            if symbol.frozen():
                p = ""
            else:
                p = leader + lang["DISCRETEVALS"]  % (cgenprompt(symbol),)
            selected = ""
            for (label, value) in symbol.range:
                if value == dflt:
                    selected = "(" + label + ")"
            if not symbol.frozen():
                p = p + leader + "%2d: %s\n" % (value, label)
	    return p + leader + "%s: %s %s%s: " % (symbol.name, cgenprompt(symbol),selected, havehelp)

	elif symbol.type in ("decimal", "hexadecimal", "string"):
            dflt = cml.evaluate(symbol, debug)
	    return leader + "%s: %s (%s)%s: "  % (symbol.name, cgenprompt(symbol), cgenvalue(symbol), havehelp)
	elif symbol.type == "choices":
            if symbol.frozen():
                p = ""
            else:
                p = leader + lang["DISCRETEVALS"]  % (cgenprompt(symbol))
            index = 0
            selected= ""
            for v in symbol.items:
                index = index + 1
                if not symbol.frozen():
                    p = p + leader + "%2d: %s%s%s\n" % (index, v.name, " " * (32 - len(v.name)), v.prompt)
                if v.eval():
                    selected = v.name
	    return p + leader + "%s: %s (%s)%s: " % (symbol.name, cgenprompt(symbol),selected, havehelp)

    def __init__(self, config=None, mybanner=""):
        tty_style_base.__init__(self, config=config, mybanner=mybanner)
        self.skip_to_query(configuration.next_node, 1)
        # This handles the case that all variables were frozen.
        self.prompt = self.generate_prompt(self.current)

    def do_p(self, dummy):
        self.skip_to_query(configuration.previous_node)
	return None

    def do_y(self, line):
        tty_style_base.do_y(self, line)
        if not line:
            self.skip_to_query(configuration.next_node)
    def do_m(self, line):
        tty_style_base.do_m(self, line)
        if not line:
            self.skip_to_query(configuration.next_node)
    def do_n(self, line):
        tty_style_base.do_n(self, line)
        if not line:
            self.skip_to_query(configuration.next_node)

    def do_h(self, dummy):
        self.page(string.join(map(lambda x: lang[x],
                                  ("TTYSUMMARY",
                                   "GHELP", "IHELP", "ICAPHELP", "YHELP",
                                   "MHELP", "NHELP", "PHELP", "SHELP",
                                   "QHELP", "XHELP", "TTYHELP")), "\n"))
    def default(self, line):
        v = string.strip(line)
	if self.current.type == 'choices':
	    try:
		ind = string.atoi(v)
	    except ValueError:
		ind = -1
	    if ind <= 0 or ind > len(self.current.items):
		print lang["RADIOBAD"]
	    else:
		# print lang["TTYSETTING"] % (`self.current.items[ind - 1]`)
		self.set_symbol(self.current.items[ind - 1], cml.y)
		self.skip_to_query(configuration.next_node)
        elif self.current.type in ("bool", "trit"):
	    print lang["CANNOTSET"]
	else:
	    self.set_symbol(self.current, v)
	    self.skip_to_query(configuration.next_node)
	return None

    def emptyline(self):
        if self.current and self.current.type == "choices":
            if self.current.default:
                # print lang["TTYSETTING"] % (`self.current.default`)
                self.set_symbol(self.current.default, cml.y)
        self.skip_to_query(configuration.next_node)
	return 0

    def help_p(self):
	print lang["PHELP"]

    def postcmd(self, stop, dummy):
	if stop:
	    return stop
        self.prompt = self.generate_prompt(self.current)
	return None

class debugger_style_menu(tty_style_base):
    "Ruleset-debugger class."
    def __init__(self, config=None, mybanner=""):
        tty_style_base.__init__(self, config=config, mybanner=mybanner)
        configuration.debug += 1
        self.prompt = "> "

    def do_l(self, line):
        import cmlcompile
        newsystem = cmlcompile.compile(debug=0, arguments=None, profile=0, endtok=line)
        if newsystem:
            global configuration
            configuration = cmlsystem.CMLSystem(newsystem)
            print lang["COMPILEOK"]
        else:
            print lang["COMPILEFAIL"]
        return 0

    def do_V(self,line):
        print "V",line
        for setting in line.split():
            symbol,expected=setting.split('=')
            if not configuration.dictionary.has_key(symbol):
                sys.stderr.write((lang["NONEXIST"] % symbol) + "\n")
                print lang["NONEXIST"] % line
                continue
            dictsym = configuration.dictionary[symbol]
            dictval = cml.evaluate(dictsym)
            if dictval != \
               configuration.value_from_string(dictsym,expected):
                errstr = lang["BADVERIFY"] % (symbol,expected,dictval)
                print errstr
                sys.stderr.write(errstr + '\n')
        return 0
        
    def do_y(self, line):
        print line + "=y"
        if not line:
            print lang["NOSYMBOL"]
        else:
            tty_style_base.do_y(self, line)
            if configuration.debug:
                print configuration.binddump()
    def do_m(self, line):
        print line + "=m"
        if not line:
            print lang["NOSYMBOL"]
        else:
            tty_style_base.do_m(self, line)
            if configuration.debug:
                print configuration.binddump()
    def do_n(self, line):
        print line + "=n"
        if not line:
            print lang["NOSYMBOL"]
        else:
            tty_style_base.do_n(self, line)
            if configuration.debug:
                print configuration.binddump()

    def do_f(self, line):
        print "f", line
        line = line.strip()
        if not line:
            print lang["NOSYMBOL"]
        elif not configuration.dictionary.has_key(line):
            print lang["NONEXIST"] % line
        else:
            configuration.dictionary[line].freeze()
        return None

    def do_c(self, line):
        print "c", line
        configuration.clear()
	return None

    def do_p(self, line):
        print "p", line
        configuration.save(sys.stdout, baton=None, all=1)
	return None

    def do_u(self, line):
        print "u", line
        configuration.interactive = not configuration.interactive
	return None

    def do_h(self, line):
        print string.join(map(lambda x: lang[x],
                              ("TTYSUMMARY",
                               "YHELP", "MHELP", "NHELP", "PDHELP",
                               "FHELP", "CHELP",
                               "EHELP", "ECAPHELP", "CCAPHELP",
                               "IHELP", "ICAPHELP", "SHELP", "UHELP",
                               "QHELP", "XHELP", "VCAPHELP", "VHELP")), "\n")

    def default(self, line):
        if line.strip()[0] == "#":
            print line
        else:
            print "?"
        return 0

    def emptyline(self):
        print ""
	return 0

    def do_help(self, line):
        if not line:
            self.do_h(line)
        else:
            tty_style_base.do_help(self, line)
        return None

    def help_f(self):
	print lang["FHELP"]

    def help_c(self):
	print lang["CHELP"]

    def help_V(self):
	print lang["VCAPHELP"]

    def help_p(self):
	print lang["PDHELP"]

    def do_EOF(self, line):
        print ""
        self.do_q(line)
        return 1

# Curses interface

class MenuBrowser:
    "Support abstract browser operations on a stack of indexable objects."
    def __init__(self, mydebug=0, errout=sys.stderr):
        self.page_stack = []
        self.selection_stack = []
        self.viewbase_stack = []
        self.viewport_height = 0
        self.debug = mydebug
        self.errout = errout

    def match(self, a, b):
        "Browseable-object comparison."
        return a == b

    def push(self, browseable, selected=None):
        "Push a browseable object onto the location stack."
        if self.debug:
            self.errout.write("MenuBrowser.push(): pushing %s=@%d, selection=%s\n" % (browseable, id(browseable), `selected`))
        selnum = 0
        if selected == None:
            if self.debug:
                self.errout.write("MenuBrowser.push(): selection defaulted\n")
        else:
            for i in range(len(browseable)):
                selnum = len(browseable) - i - 1
                if self.match(browseable[selnum], selected):
                     break
            if self.debug:
                self.errout.write("MenuBrowser.push(): selection set to %d\n" % (selnum))
        self.page_stack.append(browseable)
        self.selection_stack.append(selnum)
        self.viewbase_stack.append(selnum - selnum % self.viewport_height)
        if self.debug:
            object = self.page_stack[-1]
            selection = self.selection_stack[-1]
            viewbase = self.viewbase_stack[-1]
            self.errout.write("MenuBrowser.push(): pushed %s=@%d->%d, selection=%d, viewbase=%d\n" % (object, id(object), len(self.page_stack), selection, viewbase))

    def pop(self):
        "Pop a browseable object off the location stack."
        if not self.page_stack:
            if self.debug:
                self.errout.write("MenuBrowser.pop(): stack empty\n")
            return None
        else:
            item = self.page_stack[-1]
            self.page_stack = self.page_stack[:-1]
            self.selection_stack = self.selection_stack[:-1]
            self.viewbase_stack = self.viewbase_stack[:-1]
            if self.debug:
                if len(self.page_stack) == 0:
                    self.errout.write("MenuBrowser.pop(): stack is empty.")
                else:
                    self.errout.write("MenuBrowser.pop(): new level %d, object=@%d, selection=%d, viewbase=%d\n" % (len(self.page_stack), id(self.page_stack[-1]), self.selection_stack[-1], self.viewbase_stack[-1]))
            return item

    def stackdepth(self):
        "Return the current stack depth."
        return len(self.page_stack)

    def list(self):
        "Return all elements of the current object that ought to be visible."
        if not self.page_stack:
            return None
        object = self.page_stack[-1]
        viewbase = self.viewbase_stack[-1]

        if self.debug:
            self.errout.write("MenuBrowser.list(): stack level %d. object @%d, listing %s\n" % (len(self.page_stack)-1, id(object), object[viewbase:viewbase+self.viewport_height]))

        # This requires a slice method
        return object[viewbase:viewbase+self.viewport_height]

    def top(self):
        "Return the top-of-stack menu"
        if self.debug >= 2:
            self.errout.write("MenuBrowser.top(): level=%d, @%d\n" % (len(self.page_stack)-1,id(self.page_stack[-1])))
        return self.page_stack[-1]

    def selected(self):
        "Return the currently selected element in the top menu."
        object = self.page_stack[-1]
        selection = self.selection_stack[-1]
        if self.debug:
            self.errout.write("MenuBrowser.selected(): at %d, object=@%d, %s\n" % (len(self.page_stack)-1, id(object), self.selection_stack[-1]))
        return object[selection]

    def viewbase(self):
        "Return the viewport base of the current menu."
        object = self.page_stack[-1]
        base = self.viewbase_stack[-1]
        if self.debug:
            self.errout.write("MenuBrowser.viewbase(): at level=%d, object=@%d, %d\n" % (len(self.page_stack)-1, id(object), base,))
        return base

    def thumb(self):
        "Return top and bottom boundaries of a thumb scaled to the viewport."
        object = self.page_stack[-1]
        windowscale = float(self.viewport_height) / float(len(object))
        thumb_top = self.viewbase() * windowscale
        thumb_bottom = thumb_top + windowscale * self.viewport_height - 1
        return (thumb_top, thumb_bottom)

    def move(self, delta=1, wrap=0):
        "Move the selection on the current item downward."
        if delta == 0:
            return
        object = self.page_stack[-1]
        oldloc = self.selection_stack[-1]

        # Change the selection.  Requires a length method
        if oldloc + delta in range(len(object)):
            newloc = oldloc + delta
        elif wrap:
            newloc = (oldloc + delta) % len(object)
        elif delta > 0:
            newloc = len(object) - 1
        else:
            newloc = 0
        return self.goto(newloc)

    def goto(self, newloc):
        "Move the selection to the menu item with the given number."
        oldloc = self.selection_stack[-1]
        self.selection_stack[-1] = newloc
        # When the selection is moved out of the viewport, move the viewbase
        # just part enough to track it.
        oldbase = self.viewbase_stack[-1]
        if newloc in range(oldbase, oldbase + self.viewport_height):
            pass
        elif newloc < oldbase:
            self.viewbase_stack[-1] = newloc
        else:
            self.scroll(newloc - (oldbase + self.viewport_height) + 1)
        if self.debug:
            self.errout.write("MenuBrowser.down(): at level=%d, object=@%d, old selection=%d, new selection = %d, new base = %d\n" % (len(self.page_stack)-1, id(self.page_stack[-1]), oldloc, newloc, self.viewbase_stack[-1]))
        return (oldloc != newloc)

    def scroll(self, delta=1, wrap=0):
        "Scroll the viewport up or down in the current option."
        object = self.page_stack[-1]
        if not wrap:
            oldbase = self.viewbase_stack[-1]
            if delta > 0 and oldbase+delta > len(object)-self.viewport_height:
                return
            elif delta < 0 and oldbase + delta < 0:
                return
        self.viewbase_stack[-1] = (self.viewbase_stack[-1] + delta) % len(object)

    def dump(self):
        "Dump the whole stack of objects."
        self.errout.write("Viewport height: %d\n" % (self.viewport_height,))
        for i in range(len(self.page_stack)):
            self.errout.write("Page: %d\n" % (i,))
            self.errout.write("Selection: %d\n" % (self.selection_stack[i],))
            self.errout.write(`self.page_stack[i]` + "\n");

    def next(self, wrap=0):
        return self.move(1, wrap)

    def previous(self, wrap=0):
        return self.move(-1, wrap)

    def page_down(self):
        return self.move(2*self.viewport_height-1)

    def page_up(self):
        return self.move(-(2*self.viewport_height-1))

class PopupBaton:
    "A popup window with a twirly-baton."
    def __init__(self, startmsg, master):
        self.subwin = master.window.subwin(3, len(startmsg)+3,
                           (master.lines-3)/2,
                           (master.columns-len(startmsg)-3)/2)
        self.subwin.clear()
        self.subwin.box()
        self.subwin.addstr(1,1, startmsg)
        self.subwin.refresh()
        self.count = 0

    def twirl(self, ch=None):
        if ch:
            self.subwin.addch(ch)
        else:
            self.subwin.addch("-/|\\"[self.count % 4])
            self.subwin.addch("\010")
        self.subwin.refresh()
        self.count = self.count + 1

    def end(self, msg=None):
        pass

class WindowBaton:
    "Put a twirly-baton at the upper right corner to indicate activity."
    def __init__(self, master):
        self.master = master
        self.count = 0

    def twirl(self, ch=None):
        if ch:
            self.master.window.addch(0, self.master.columns-1, ch)
        else:
            self.master.window.addch(0, self.master.columns-1, "-/|\\"[self.count % 4])
            self.master.window.addch("\010")
        self.master.window.refresh()
        self.count = self.count + 1

    def end(self, dummy=None):
        self.master.window.addch(0, self.master.columns-1, " ")
        self.master.window.refresh()
        pass

class curses_style_menu:
    "Command interpreter for line-oriented configurator."
    input_nmatch = re.compile(r">>>.*\(([0-9]+)\)$")
    valwidth = 32	# This is a constant

    def __init__(self, stdscr, config, mybanner):
        if mybanner and configuration.banner.find("%s") > -1:
            self.banner = configuration.banner % mybanner
        elif mybanner:
            self.banner = mybanner
        else:
            self.banner = configuration.banner
        self.input_queue = []
        self.menus = self.values = self.textbox = None
        self.window = stdscr
        self.msgbuf = ""
        self.lastmenu = None

        menudebug = 0
        if configuration.debug > 1:
            menudebug = configuration.debug - 2
        self.menus = MenuBrowser(menudebug,configuration.errout)

        (self.lines, self.columns) = self.window.getmaxyx()
        if self.lines < 9 or self.columns < 60:
            raise "TERMTOOSMALL"
        self.menus.viewport_height = self.lines-2 + (not configuration.expert_tie or cml.evaluate(configuration.expert_tie) != cml.n)
        if curses.has_colors():
            #curses.init_pair(curses.COLOR_CYAN, curses.COLOR_WHITE, curses.COLOR_BLACK)
            #curses.init_pair(curses.COLOR_GREEN, curses.COLOR_WHITE, curses.COLOR_BLACK)
            curses.init_pair(curses.COLOR_CYAN, curses.COLOR_BLACK, curses.COLOR_WHITE)
            curses.init_pair(curses.COLOR_GREEN, curses.COLOR_BLACK, curses.COLOR_WHITE)
        self.window.clear()
        self.window.scrollok(0)
        self.window.idlok(1)
        stdscr.bkgd(' ', curses.color_pair(curses.COLOR_CYAN))
        # Most of the work gets done here
        self.interact(config)

    # Input (with logging support)

    def getch(self, win):
        if not readlog:
            try:
                ch = win.getch()
            except KeyboardInterrupt:
                curses.endwin()
                raise
        else:
            time.sleep(1)
            if self.input_queue:
                ch = self.input_queue[0]
                self.input_queue = self.input_queue[1:]
            while 1:
                line = readlog.readline()
                if line == "":
                    ch = -1
                    break
                m =  curses_style_menu.input_nmatch.match(line)
                if m:
                    ch = string.atoi(m.group(1))
                    break
        if configuration.debug:
            configuration.debug_emit(1, ">>> '%s' (%d)"% (curses.keyname(ch), ch))
        return ch

    def ungetch(self, c):
        if readlog:
            self.input_queue = c + self.input_queue
        else:
            curses.ungetch(c)

    # Notification

    def help_popup(self, instructions, msglist, beep=1):
        "Pop up a help message."
        if configuration.debug:
            configuration.errout.write("***" + lang[instructions] + "\n")
            configuration.errout.write(string.join(msglist, "\n"))
        msgwidth = 0
        pad = 2		# constant, must be >= 1
        msgparts = []
        for line in msglist:
            unemitted = line
            ww = self.columns - pad
            while unemitted:
                msgparts.append(unemitted[:ww])
                unemitted = unemitted[ww:]
        if len(msgparts) > self.lines - pad*2 - 1:
            msgparts = msgparts[:self.lines - pad*2 - 2] + [lang["MORE"]]
        for msg in msgparts:
            if len(msg) > msgwidth:
                msgwidth = len(msg)
        msgwidth = min(self.columns - pad*2, msgwidth)
        start_x = (self.columns - msgwidth) / 2
        start_y = (self.lines - len(msgparts)) / 2
        leave = lang[instructions]
        msgwidth = max(msgwidth, len(leave))
        subwin = self.window.subwin(len(msgparts)+1+pad*2, msgwidth+pad*2,
                               start_y-pad, start_x-pad)
        subwin.clear()
        for i in range(len(msgparts)):
            subwin.addstr(pad+i, pad + int((msgwidth-len(msgparts[i]))/2),
                          msgparts[i], curses.A_BOLD)
        subwin.addstr(pad*2+len(msgparts)-1, pad+int((msgwidth-len(leave))/2),
                      leave)
        subwin.box()
        if beep:
            curses.beep()
        self.window.noutrefresh()
        subwin.noutrefresh()
        curses.doupdate()
        value = self.getch(self.window)
        subwin.clear()
        subwin.noutrefresh()
        self.window.noutrefresh()
        curses.doupdate()
        return value

    def query_popup(self, prompt, initval=None):
        "Pop up a window to accept a string."
        maxsymwidth = self.columns - len(prompt) - 10
        if initval and len(initval) > maxsymwidth:
            self.help_popup("PRESSANY", (lang["TOOLONG"],), beep=1) 
            return initval
        gwinwidth = (len(prompt) + maxsymwidth)
        start_y = self.lines/2-3
        start_x = (self.columns - gwinwidth)/2
        subwin = self.window.subwin(3, 2+gwinwidth, start_y-1, start_x-1)
        subwin.clear()
        subwin.box()
        self.window.addstr(start_y, start_x, prompt, curses.A_BOLD)
        self.window.refresh()
        subwin.refresh()
        subsubwin = subwin.subwin(1,maxsymwidth,start_y,start_x+len(prompt))
        if initval:
            subsubwin.addstr(0, 0, initval[:maxsymwidth-1])
            subsubwin.touchwin()
        configuration.debug_emit(1, "+++ %s"% (prompt,))
        textbox = curses.textpad.Textbox(subsubwin)
        popupval = textbox.edit()
        self.window.touchwin()
        if initval and textbox.lastcmd == curses.ascii.BEL:
            return initval
        else:
            return popupval

    # Symbol state changes

    def set_symbol(self, sym, val, freeze=0):
        "Try to set a symbol, display constraints in a popup if it fails."
        configuration.debug_emit(1, lang["CURSESSET"] % (sym.name, val))
        (ok, effects, violations) = configuration.set_symbol(sym, val, freeze)
        if ok:
            if not interactively_visible(sym):
                self.help_popup("PRESSANY", [lang["INVISOUT"] % sym.name], beep=1)
        else:
            effects.append("\n")
            self.help_popup("PRESSANY",
                       effects + [lang["BADREQUIRE"]] + map(repr, violations), beep=1)

    # User interaction

    def in_menu(self):
        "Return 1 if we're in a symbol menu, 0 otherwise"
        return isinstance(self.menus.selected(), cml.ConfigSymbol)

    def recompute(self, here):
        "Recompute the visible-members set for the given menu."
        # First, make sure any choices menus immediately
        # below this one get their defaults asserted.  Has
        # to be done here because the visibility of stuff
        # in a menu may depend on a choice submenu before
        # it, so we need the default value to be hardened,
        map(configuration.visit, here.items)
        # Now compute visibilities.
        visible = filter(lambda x, m=here: hasattr(m, 'nosuppressions') or interactively_visible(x), here.items)
        lookingat = self.menus.selected()
        if lookingat in visible:
            selected = self.menus.selected()
            self.menus.pop()
            self.menus.push(visible, selected)
            self.seek_mutable(1)
        else:
            if configuration.suppressions:
                configuration.debug_emit(1, lang["SUPPRESSOFF"])
                configuration.suppressions = 0
                self.help_popup("PRESSANY", (lang["SUPPRESSOFF"],), beep=1) 
            selected = self.menus.selected()
            self.menus.pop()
            self.menus.push(here.items, selected)
        # We've recomputed the top-of-stack item,
        # so we must regenerate all associated prompts.
        self.values = map(cgenvalue, self.menus.top())

    def redisplay(self, repaint):
        "Repaint the screen."
        sel_symbol = current_line = None
        if self.banner and self.in_menu():
            title = self.msgbuf + (" " * (self.columns - len(self.msgbuf) - len(self.banner) -1)) + self.banner
        else:
            title = (" " * ((self.columns-len(self.msgbuf)) / 2)) + self.msgbuf
        self.menus.viewport_height = self.lines-2 + (not configuration.expert_tie or cml.evaluate(configuration.expert_tie) != cml.n)
        self.window.move(0, 0)
        self.window.clrtoeol()
        self.window.addstr(title, curses.A_BOLD)

        (thumb_top, thumb_bottom) = self.menus.thumb()

        # Display the current band of entries 
        screenlines = self.menus.list()
        if self.in_menu():
            screenvals = self.values[self.menus.viewbase():self.menus.viewbase()+self.menus.viewport_height]
            configuration.debug_emit(1, "screenvals: " + `screenvals`)
        else:
            current_prompt = None

        # To change the number of lines on the screen that this paints,
        # change the initialization of the viewport_height member.
        for i in range(self.menus.viewport_height):
            self.window.move(i+1, 0)
            self.window.clrtoeol()
            if len(self.menus.top()) <= self.menus.viewport_height:
                thumb = None
            elif i <= thumb_bottom and i >= thumb_top:
                thumb = curses.ACS_CKBOARD
            else:
                thumb = curses.ACS_VLINE
            if i < len(screenlines):
                child = screenlines[i]
                if type(child) is type(""):
                    self.window.addstr(i+1, 0, child) 
                elif child.type == "message":
                    self.window.addstr(i+1, 0, child.prompt + " ") 
                    self.window.hline(i+1, len(child.prompt) + 2,
                                 curses.ACS_HLINE, self.columns-len(child.prompt)-3)
                else:
                    if child == self.menus.selected():
                        lpointer = ">"
                        rpointer = "<"
                        highlight = curses.A_REVERSE
                        current_line = i
                        current_prompt = screenvals[i]
                        sel_symbol = child
                    else:
                        lpointer = rpointer = " "
                        highlight = curses.A_NORMAL
                        if curses.has_colors():
                            if child.frozen():
                                highlight=curses.color_pair(curses.COLOR_CYAN)
                            #elif child.inspected:
                            #    highlight=curses.color_pair(curses.COLOR_GREEN)
                            elif child.setcount or child.included:
                                highlight=curses.color_pair(curses.COLOR_GREEN)
                    # OK, now assemble the rest of the line
                    leftpart = ("  " * child.depth) + cgenprompt(child, not configuration.expert_tie or not cml.evaluate(configuration.expert_tie))
                    if configuration.is_new(child):
                        leftpart = leftpart + " " + lang["NEW"]
                    if child.frozen():
                        leftpart = leftpart + " " + lang["FREEZELABEL"]
                    if child.help():
                        helpflag = "?"
                    else:
                        helpflag = ""
                    rightpart = "=" + child.name + helpflag
                    # Now make sure the information will fit in the line
                    fixedlen = 1+curses_style_menu.valwidth+1+len(rightpart)+(thumb!=None) + 1
                    leftpart = leftpart[:self.columns-fixedlen]
                    filler = " " * (self.columns - len(leftpart) - fixedlen)
                    line = leftpart + filler + rightpart
                    # Write it
                    self.window.move(i+1, 0)
                    self.window.addstr(lpointer)
                    if "edit" in repaint and child == self.menus.selected():
                        self.window.move(i+1, curses_style_menu.valwidth+2)
                        self.window.attron(highlight)
                    else:
                        self.window.attron(highlight)
                        valstring = screenvals[i][:curses_style_menu.valwidth]
                        self.window.addstr(valstring + (" " * (curses_style_menu.valwidth - len(valstring))) + " ")
                    self.window.addstr(line)
                    self.window.attroff(highlight)

                    # Ignore error from writing to last cell of
                    # last line; the old curses module in 1.5.2
                    # doesn't like this.  The try/catch around the
                    # thumb write does the same thing.
                    try:
                        self.window.addstr(rpointer)
                    except:
                        pass
            if thumb:
                try:
                    self.window.addch(i+1, self.columns-1, thumb)
                except:
                    pass
        if not configuration.expert_tie or not cml.evaluate(configuration.expert_tie):
            self.window.move(self.lines-1, 0)
            self.window.clrtoeol()
            helpbanner = lang["HELPBANNER"]
            title = " " * ((self.columns - len(helpbanner))/2) + helpbanner
            self.window.addstr(title, curses.A_BOLD)

        if type(self.menus.selected()) is not type(""):
            self.window.move(current_line + 1, 0)
        if "main" in repaint or "edithelp" in repaint:
            self.window.noutrefresh()
        if "edit" in repaint:
            self.textbox.win.touchwin()
            self.textbox.win.noutrefresh()
        curses.doupdate()
        return (current_line, current_prompt, sel_symbol)

    def accept_field(self, selected, value, oldval):
        "Process the contents of a field edit."
        base = 0
        if selected.type == "hexadecimal":
            base = 16
            if oldval[:2] != "0x":
                value = "0x" + value
        value = string.strip(value)
        if selected.is_numeric():
            value = int(value, base)
            if not configuration.range_check(selected, value):
                self.help_popup("PRESSANY",
                       (lang["OUTOFBOUNDS"] % (value, selected.range,),))
                return
        self.set_symbol(selected, value)

    def symbol_menu_command(self, cmd, operand):
        "Handle commands that don't directly hack the screen or exit."
        recompute = 0
        if cmd == curses.KEY_LEFT:
            if self.menus.stackdepth() <= 1:
                self.msgbuf = lang["NOPOP"]
            else:
                self.menus.pop()
                self.lastmenu = self.menus.selected()
                recompute = 1
        elif cmd == ord('y'):
            if not self.in_menu():
                self.help_popup("PRESSANY", (lang["NOSYMBOL"],))
            elif operand.type in ("bool", "trit"):
                self.set_symbol(operand, cml.y)
            else:
                self.help_popup("PRESSANY", (lang["BOOLEAN"],))
            recompute = 1
            if operand.menu.type != "choices":
                self.ungetch(curses.KEY_DOWN)
        elif cmd == ord('m'):
            if not self.in_menu():
                self.help_popup("PRESSANY", (lang["NOSYMBOL"],))
            elif not configuration.trits_enabled:
                self.help_popup("PRESSANY", (lang["MDISABLED"],))
            elif operand.type == "trit":
                self.set_symbol(operand, cml.m)
            elif operand.type == "bool":
                self.set_symbol(operand, cml.y)	# Shortcut from old menuconfig
            else:
                self.help_popup("PRESSANY", (lang["TRIT"],))
            recompute = 1
            if operand.menu.type != "choices":
                self.ungetch(curses.KEY_DOWN)
        elif cmd == ord('n'):
            if not self.in_menu():
                self.help_popup("PRESSANY", (lang["NOSYMBOL"],))
            elif operand.type in ("bool", "trit") and \
            				operand.menu.type != "choices":
                self.set_symbol(operand, cml.n)
            else:
                self.help_popup("PRESSANY", (lang["BOOLEAN"],))
            recompute = 1
            if operand.menu.type != "choices":
                self.ungetch(curses.KEY_DOWN)
        elif cmd == ord('i'):
            file = self.query_popup(lang["LOADFILE"])
            try:
                (changes, errors) = configuration.load(file, freeze=0)
            except:
                self.help_popup("PRESSANY", [lang["LOADFAIL"] % file])
            else:
                if errors:
                    self.help_popup("PRESSANY", (errors,))
                else:
                    # Note, we don't try to display side effects here.
                    # From a file include, there are very likely to
                    # be more of them than can fit in a popup. 
                    self.help_popup("PRESSANY",
                               [lang["INCCHANGES"]%(changes,file)], beep=0)
                recompute = 1
        elif cmd == ord('I'):
            file = self.query_popup(lang["LOADFILE"])
            try:
                (changes, errors) = configuration.load(file, freeze=0)
            except:
                self.help_popup("PRESSANY", [lang["LOADFAIL"] % file])
            else:
                if errors:
                    self.help_popup("PRESSANY", (errors,))
                else:
                    # Note, we don't try to display side effects here.
                    # From a file include, there are very likely to
                    # be more of them than can fit in a popup. 
                    self.help_popup("PRESSANY",
                               [lang["INCCHANGES"]%(changes,file)], beep=0)
                recompute = 1
        elif cmd == ord('S'):
            configuration.suppressions = not configuration.suppressions
            recompute = 1
        elif cmd == ord('/'):
            pattern = self.query_popup(lang["SEARCHSYMBOLS"])
            if pattern:
		try:
		    hits = configuration.symbolsearch(pattern)
		except re.error, detail:
		    self.help_popup("PRESSANY",
                                    (lang["SEARCHINVAL"], str(detail)))
		else:
		    configuration.debug_emit(1, "hits: " + str(hits)) 
		    if len(hits.items):
			self.menus.push(hits.items)
		    else:
			self.help_popup("PRESSANY", (lang["SEARCHFAIL"],))
            recompute = 1
        elif cmd == ord('s'):
            failure = configuration.save(config,
                                         PopupBaton(lang["SAVING"], self))
            if failure:
                self.help_popup("PRESSANY", [failure])
        else:
            self.help_popup("PRESSANY",
                            (lang["UNKNOWN"]%(curses.keyname(cmd)),))
        return recompute

    def seek_mutable(self, direction, movefirst=0):
        if movefirst:
            self.menus.move(delta=direction, wrap=1)
        while self.menus.selected().type =="message" \
              or self.menus.selected().frozen():
            self.menus.move(delta=direction, wrap=1)

    def interact(self, config):
        "Configuration through a curses-based UI"
        self.menus.push(configuration.start.items)
        while not interactively_visible(self.menus.selected()):
            if not self.menus.move(1):
                self.help_popup("PRESSANY", (lang["NOVISIBLE"],), beep=1)
                raise SystemExit, 1
        recompute = 1
        repaint = ["main"]
        #curses.ungetch(curses.ascii.TAB)		# Get to a help screen.
        while 1:
            if isinstance(self.menus.selected(), cml.ConfigSymbol):
                # In theory we could optimize this by only computing
                # visibilities for children we have space to display,
                # but never mind.  We'll settle for recomputing only
                # when a variable changes value.
                here = self.menus.selected().menu
                configuration.visit(here)
                if recompute:
                    self.recompute(here)
                    recompute = 0
                # Clear the decks, issue the current menu title 
                self.msgbuf = here.prompt
                sel_symbol = None

            # Repaint the screen
            (current_line,current_prompt,sel_symbol) = self.redisplay(repaint)
            newval = current_prompt

            # OK, here is the command interpretation
            if "edit" in repaint:
                cmd = self.getch(self.textbox.win)
            else:
                cmd = self.getch(self.window)

            if "edithelp" in repaint:
                repaint = ["main", "edit"]
                self.textbox.win.move(oldy, oldx)
                self.menus.pop()
                continue
            elif "edit" in repaint:
                if cmd in (curses.KEY_DOWN, curses.KEY_UP, curses.KEY_ENTER,
                           curses.ascii.NL, curses.ascii.CR, curses.ascii.BEL,
                           ord(curses.ascii.ctrl('p')), ord(curses.ascii.ctrl('n'))):
                    if cmd != curses.ascii.BEL:
                        newval = self.textbox.gather()
                        self.accept_field(sel_symbol,
                                      newval,
                                      current_prompt)
                    # allow window to be deallocated
                    self.textbox = None
                    recompute = 1
                    repaint = ["main"]
                    self.msgbuf = ""
                    if cmd in (curses.KEY_DOWN, curses.KEY_UP):
                        self.ungetch(cmd)
                elif curses.ascii.isprint(cmd):
                    if sel_symbol.type == "decimal" and not curses.ascii.isdigit(cmd):
                        curses.beep()
                    elif sel_symbol.type == "hexadecimal" and not curses.ascii.isxdigit(cmd):
                        curses.beep()
                    else:
                        self.textbox.do_command(cmd)
                elif cmd == curses.ascii.TAB:
                    self.msgbuf = lang["FIELDEDIT"]
                    self.menus.push(string.split(lang["EDITHELP"], "\n"))
                    (oldy, oldx) = self.textbox.win.getyx()
                    repaint = ["edithelp"]
                    continue
                elif cmd == curses.KEY_RIGHT and self.textbox.win.getyx()[1]>=curses_style_menu.valwidth:
                    oldval = newval
                    newval = self.query_popup(sel_symbol.name+": ", oldval)
                    if newval:
                        self.accept_field(sel_symbol, newval, oldval)
                        self.textbox.win.clear()
                        self.textbox.win.addstr(0, 0, newval[0:curses_style_menu.valwidth])
                        recompute = 1
                    self.textbox = None
                    repaint = ["main"]
                else:
                    self.textbox.do_command(cmd)
            else:
                if cmd == curses.ascii.FF:
                    self.window.touchwin()
                    self.window.refresh()
                elif cmd == curses.KEY_RESIZE or cmd == -1:
                    # Second test works around a bug in the old curses module
                    # it gives back a -1 on resizes instead of KEY_RESIZE.
                    (self.lines, self.columns) = self.window.getmaxyx()
                    self.menus.viewport_height = self.lines-1
                    recompute = 1
                elif cmd in (curses.ascii.TAB, ord('h')):
                    if self.in_menu():
                        self.menus.push(string.split(lang["CURSHELP"], "\n"))
                        self.msgbuf = lang["WELCOME"] % (configuration.banner) \
                            + lang["VERSION"] % (cml.version,) \
                            + " " + lang["CURSQUERY"]
                        self.helpmode = 1
                    elif self.helpmode == 1:
                        self.menus.pop()
                        self.menus.push(string.split(lang["EXPERTHELP"], "\n"))
                        self.msgbuf = lang["CMDHELP"]
                        self.helpmode = 2
                    else:
                        self.menus.pop()
                        recompute = 1
                elif cmd == ord('e'):
                    if not self.in_menu():
                        self.help_popup("PRESSANY", (lang["NOSYMBOL"],))
                    else:
                        self.help_popup("PRESSANY", (str(sel_symbol),), beep=0)
                elif cmd == ord('g'):
                    symname = self.query_popup(lang["GPROMPT"])
                    if not configuration.dictionary.has_key(symname):
                        self.help_popup("PRESSANY", (lang["NONEXIST"] % symname,))
                    else:
                        entry = configuration.dictionary[symname]
                        if entry.type in ("menu", "choices"):
                            self.menus.push(entry.items)
                            recompute = 1
                        elif entry.type == "message" or not entry.menu:
                            self.help_popup("PRESSANY", (lang["CANTGO"],))
                        else:
                            self.menus.push(entry.menu.items, entry)
                            recompute = 1
                elif cmd == ord('?'):
                    if not self.in_menu():
                        self.help_popup("PRESSANY", (lang["NOSYMBOL"],))
                    else:
                        help = sel_symbol.help()
                        if help:
                            self.msgbuf = lang["HELPFOR"] % (sel_symbol.name,)
                            self.menus.push(string.split(help, "\n"))
                        else:
                            self.help_popup("PRESSANY",
                                       (lang["NOHELP"] % (sel_symbol.name,),))
                elif cmd in (curses.KEY_DOWN, curses.ascii.ctrl('n')):
                    if not self.in_menu():
                        self.menus.scroll(1)
                    else:
                        self.seek_mutable(1, 1)
                elif cmd == curses.KEY_UP:
                    if not self.in_menu():
                        self.menus.scroll(-1)
                    else:
                        self.seek_mutable(-1, 1)
                elif cmd in (curses.KEY_NPAGE, curses.ascii.ctrl('p')):
                    if self.in_menu():
                        self.menus.page_down()
                        notlast = (self.menus.selected() != self.menus.list()[-1])
                        self.seek_mutable(notlast)
                elif cmd == curses.KEY_PPAGE:
                    if self.in_menu():
                        self.menus.page_up()
                        notlast = (self.menus.selected() != self.menus.list()[-1])
                        self.seek_mutable(notlast)
                elif cmd == curses.KEY_HOME:
                    if self.in_menu():
                        self.menus.goto(0)
                        self.seek_mutable(0)
                elif cmd == curses.KEY_END:
                    if self.in_menu():
                        self.menus.goto(len(self.menus.list())-1)
                        self.seek_mutable(0)
                # This guard intercepts all other commands in helpmode
                elif not self.in_menu():
                    if self.menus.stackdepth() == 1:
                        here = configuration.start.items[0]
                        while not interactively_visible(here):
                            here = configuration.next_node(here)
                        self.menus.push(here.menu.items, here)
                    else:
                        self.menus.pop()
                # Following commands are not executed in helpmode
                elif cmd == ord('x'):
                    failure = configuration.save(config,
                                  PopupBaton(lang["SAVING"], self))
                    if failure:
                        self.help_popup("PRESSANY", [failure])
                    break
                elif cmd == ord('q'):
                    if configuration.commits == 0:
                        break
                    cmd = self.help_popup("EXITCONFIRM", (lang["REALLY"],), beep=0)
                    if cmd == ord('q'):
                        raise SystemExit, 1
                elif cmd in (curses.KEY_ENTER,ord(' '),ord('\r'),ord('\n'),curses.KEY_RIGHT) :
                    # Operate on the current object
                    if sel_symbol.type == "message":
                        curses.beep()
                    elif sel_symbol.type in ("menu", "choices"):
                        self.menus.push(sel_symbol.items)
                        sel_symbol.inspected += 1
                        while not interactively_visible(self.menus.selected()) or self.menus.selected().type == "message":
                            if not self.menus.move(1, 0):
                                break
                    elif here.type == "choices" and sel_symbol.eval():
                        pass
                    elif cmd == curses.KEY_RIGHT:
                        pass
                    elif sel_symbol.type == "bool" or (sel_symbol.type == "trit" and not configuration.trits_enabled):
                        if sel_symbol.eval() == cml.y:
                            toggled = cml.n
                        else:
                            toggled = cml.y
                        self.set_symbol(sel_symbol, toggled)
                    elif sel_symbol.type == "trit":
                        if sel_symbol.eval() == cml.y:
                            toggled = cml.n
                        elif sel_symbol.eval() == cml.m:
                            toggled = cml.y
                        else:
                            toggled = cml.m
                        self.set_symbol(sel_symbol, toggled)
                    else:
                        win =  curses.newwin(1, curses_style_menu.valwidth+1, current_line+1, 1)
                        self.textbox = curses.textpad.Textbox(win)
                        self.textbox.win.addstr(0, 0, current_prompt[:curses_style_menu.valwidth])
                        newval = current_prompt
                        self.textbox.win.move(0, 0)
                        self.msgbuf = lang["EDITING"] % (sel_symbol.name[:self.columns-1],)
                        repaint = ["main", "edit"]
                    recompute = 1
                else:
                    recompute = self.symbol_menu_command(cmd, sel_symbol)

# Tkinter interface

# This is wrapped in try/expect in case the Tkinter import fails.
# We need the import here because these classes have Frame as a parent.
try:
    from Tkinter import *
    from tree import *

    class ValidatedField(Frame):
        "Accept a string, decimal or hex value in a labeled field."
        def __init__(self, master, symbol, prompt, variable, hook):
            Frame.__init__(self, master)
            self.symbol = symbol
            self.hook = hook
            self.fieldval = variable
            self.L = Label(self, text=prompt, anchor=W)
            self.L.pack(side=LEFT)
            self.E = Entry(self, textvar=self.fieldval)
            self.E.pack({'side':'left', 'expand':YES, 'fill':X})
            self.E.bind('<Return>', self.handlePost)
            self.E.bind('<Enter>', self.handleEnter)
            self.fieldval.set(str(cml.evaluate(symbol))) 
            self.errorwin = None
        def handleEnter(self, dummy):
            self.E.bind('<Leave>', self.handlePost)
        def handlePost(self, event):
            if self.errorwin:
                return
            self.E.bind('<Leave>', lambda e: None)
            result = string.strip(self.fieldval.get())
            if self.symbol.type == "decimal":
                if not re.compile("[" + string.digits +"]+$").match(result):
                    self.error_popup(title=lang["PROBLEM"],
                            banner=self.symbol.name,
                            text=lang["CHARINVAL"])
                    return
            elif self.symbol.type == "hexadecimal":
                if not re.compile("(0x)?["+string.hexdigits+"]+$").match(result):
                    self.error_popup(title=lang["PROBLEM"],
                            banner=self.symbol.name,
                            text=lang["CHARINVAL"])
                    return
            apply(self.hook, (self.symbol, result))
        def error_popup(self, title, mybanner, text):
            self.errorwin = Toplevel()
            self.errorwin.title(title) 
            self.errorwin.iconname(title)
            Label(self.errorwin, text=mybanner).pack()
            Label(self.errorwin, text=text).pack()
            Button(self.errorwin, text=lang["DONE"],
                   command=lambda x=self.errorwin: Widget.destroy(x), bd=2).pack()


    class PromptGo(Frame):
        "Accept a string value in a browser-like prompt window."
        def __init__(self, master, label, command):
            Frame.__init__(self, master)
            # We really want to do this to make the window appear
            # within the workframe:
            #self.promptframe = Frame(master)
            # Unfortunately, the scroll function in the canvas seems
            # to get confused when we try this
            self.promptframe = Frame(Toplevel())
            self.promptframe.master.bind('<Destroy>', self.handleDestroy);
            self.fieldval = StringVar(self.promptframe)
            self.promptframe.L = Label(self.promptframe,
                                   text=lang[label], anchor=W)
            self.promptframe.L.pack(side=LEFT)
            self.promptframe.E = Entry(self.promptframe, textvar=self.fieldval)
            self.promptframe.E.pack({'side':'left', 'expand':YES, 'fill':X})
            self.promptframe.E.bind('<Return>', self.dispatch)
            self.promptframe.E.focus_set()
            self.command = command
            Button(self.promptframe, text=lang["GO"],
                   command=self.dispatch, bd=2).pack()
            self.promptframe.pack()
            # Scroll to top of canvas and refresh/resize
            self.master.menuframe.resetscroll()
            self.master.refresh()
        def dispatch(self, dummy=None):
            apply(self.command, (self.fieldval.get(),))
            # if PromptGo is implemented as top level widget this is not
            # sufficient:
            #self.promptframe.destroy()
            # instead the top level widget must be destroyed
            self.promptframe.master.destroy()
        def handleDestroy(self, dummy=None):
            apply(self.command, (None,))


    class ScrolledFrame(Frame):
        "A Frame object with a scrollbar on the right."
        def __init__(self, master, **kw):
            apply(Frame.__init__, (self, master), kw)

            self.scrollbar = Scrollbar(self, orient=VERTICAL)
            self.canvas = Canvas(self, yscrollcommand=self.scrollbar.set)
            self.scrollbar.config(command=self.canvas.yview)
            self.scrollbar.pack(fill=Y, side=RIGHT)
            self.canvas.pack(side=LEFT, fill=BOTH, expand=YES)

            # create the inner frame
            self.inner = Frame(self.canvas)

            # track changes to its size
            self.inner.bind('<Configure>', self.__configure)

            # place the frame inside the canvas
            # (this also runs the __configure method)
            self.canvas.create_window(0, 0, window=self.inner, anchor=NW)

        def showscroll(self, flag):
            if flag:
                self.canvas.pack_forget()
                self.scrollbar.pack(fill=Y, side=RIGHT)
                self.canvas.pack(side=LEFT, fill=BOTH, expand=YES)
            else:
                self.scrollbar.pack_forget()

        def resetscroll(self, loc=0.0):
            self.canvas.yview("moveto", loc)

        def __configure(self, dummy):
            # update the scrollbars to match the size of the inner frame
            size = self.inner.winfo_reqwidth(), self.inner.winfo_reqheight()
            self.canvas.config(scrollregion="0 0 %s %s" % size)

    class ScrolledText(Frame):
        def __init__(self,parent=None,text=None,file=None,height=10,**kw):
            apply(Frame.__init__,(self,parent),kw)
            self.makewidgets(height)
            self.settext(text,file)
        def makewidgets(self,ht):
            sbar=Scrollbar(self)
            text=Text(self,relief=SUNKEN,height=ht)
            sbar.config(command=text.yview)
            text.config(yscrollcommand=sbar.set)
            sbar.pack(side=RIGHT,fill=Y)
            text.pack(side=LEFT,expand=YES,fill=BOTH)
            self.text=text
        def settext(self, text=None,file=None):
            if file:
                text=open(file,'r').read()
            elif text:
                self.text.delete('1.0',END)
                self.text.insert('1.0',text)
            else:
                text='None'
                self.text.delete('1.0',END)

    # Routine to get contents of subtree.  Supply this for a different
    # type of app argument is the node object being expanded should return
    # list of 4-tuples in the form: (label, unique identifier, closed
    # icon, open icon) where:
    #    label             - the name to be displayed
    #    unique identifier - an internal fully unique name
    #    closed icon       - PhotoImage of closed item
    #    open icon         - PhotoImage of open item, or None if not openable
    def my_get_contents(node):
        menus=[]
        options=[]
        cmlnode=node.id 	
        for child in cmlnode.items:
            if interactively_visible(child):
                if child.type =="menu" and cmlnode.items :
                    menus.append((child.prompt, child, shut_icon, open_icon))
                else:
                    options.append((child.prompt, child, file_icon, None))	
        menus.sort()
        options.sort()
        return options+menus 

    class myTree(Tree):
        def __init__(self,master,**kw):
            apply(Tree.__init__,(self,master),kw)
    
        def update_node(self,node=None):
            if node==None:
                node=self.pos
            if node.id.type in ("trit","bool"):
                if node.id.yes=="yes" and node.id.eval()==cml.n:
                    node.id.yes="no"
                    x1,y1=self.coords(node.symbol)
                    self.delete(node.symbol)
                    node.symbol=self.create_image(x1,y1,image=no_icon)
                elif node.id.yes=="no" and \
                    (node.id.eval()==cml.y or node.id.eval()==cml.m):
                    node.id.yes="yes"
                    x1,y1=self.coords(node.symbol)
                    self.delete(node.symbol)
                    node.symbol=self.create_image(x1,y1,image=yes_icon)
        def update_tree(self):
            #old cursor position
            oldpos=self.pos.full_id()
            #get expanded node list    
            n=self.root.expanded()    
            #redraw whole tree again
            self.root.toggle_state(0)
            for j in n:
                self.root.expand(j)
            self.move_cursor(self.root.expand(oldpos[1:]))

    def makehelpwin(title, mybanner, text):
        # help message window with a self-destruct button
        makehelpwin = Toplevel()
        makehelpwin.title(title) 
        makehelpwin.iconname(title)
        if mybanner:
            Label(makehelpwin, text=mybanner).pack()
        textframe = Frame(makehelpwin)
        scroll = Scrollbar(textframe)
        makehelpwin.textwidget = Text(textframe, setgrid=TRUE)
        textframe.pack(side=TOP, expand=YES, fill=BOTH)
        makehelpwin.textwidget.config(yscrollcommand=scroll.set)
        makehelpwin.textwidget.pack(side=LEFT, expand=YES, fill=BOTH)
        scroll.config(command=makehelpwin.textwidget.yview)
        scroll.pack(side=RIGHT, fill=BOTH)
        Button(makehelpwin, text=lang["DONE"], 
               command=lambda x=makehelpwin: x.destroy(), bd=2).pack()
        makehelpwin.textwidget.tag_config('url', foreground='blue', underline=YES)
        makehelpwin.textwidget.tag_bind('url', '<Button-1>', launch_browser)
        makehelpwin.textwidget.tag_bind('url', '<Enter>', lambda event, x=makehelpwin.textwidget: x.config(cursor='hand2'))
        makehelpwin.textwidget.tag_bind('url', '<Leave>', lambda event, x=makehelpwin.textwidget: x.config(cursor='xterm'))
        tag_urls(makehelpwin.textwidget, text)
        makehelpwin.textwidget.config(state=DISABLED)	# prevent editing
        makehelpwin.lift()

    def tag_urls(textwidget, text):
        getURL = re.compile('((?:http|ftp|mailto|file)://[-.~/_?=#%\w]+\w)')
        textlist = getURL.split(text)
        for n in range(len(textlist)):
            if n % 2 == 1:
                textwidget.insert(END, textlist[n], ('url', textlist[n]))
            else:
                textwidget.insert(END, textlist[n])

    def launch_browser(event):
        url = event.widget.tag_names(CURRENT)[1]
        webbrowser.open(url)
        
    def make_icon_window(base, image):
        try:
            # Some older pythons will error out on this
            icon_image = PhotoImage(data=image)
            icon_window = Toplevel()
            Label(icon_window, image=icon_image, bg='black').pack()
            base.master.iconwindow(icon_window)
            # Avoid TkInter brain death. PhotoImage objects go out of
            # scope when the enclosing function returns.  Therefore
            # we have to explicitly link them to something.
            base.keepalive.append(icon_image)
        except:
            pass


    def get_contents(node):
        global open_icon, shut_icon, file_icon, yes_icon, no_icon
        open_icon=PhotoImage(
            data='R0lGODlhEAANAKIAAAAAAMDAwICAgP//////ADAwMAAAAAAA' \
                'ACH5BAEAAAEALAAAAAAQAA0AAAM6GCrM+jCIQamIbw6ybXNSx3GVB' \
                'YRiygnA534Eq5UlO8jUqLYsquuy0+SXap1CxBHr+HoBjoGndDpNAAA7')
        shut_icon=PhotoImage(
            data='R0lGODlhDwANAKIAAAAAAMDAwICAgP//////ADAwMAAAAAAA' \
                'ACH5BAEAAAEALAAAAAAPAA0AAAMyGCHM+lAMMoeAT9Jtm5NDKI4Wo' \
                'FXcJphhipanq7Kvu8b1dLc5tcuom2foAQQAyKRSmQAAOw==')
        file_icon=PhotoImage(
            data='R0lGODlhCwAOAJEAAAAAAICAgP///8DAwCH5BAEAAAMALAAA' \
                'AAALAA4AAAIphA+jA+JuVgtUtMQePJlWCgSN9oSTV5lkKQpo2q5W+' \
                'wbzuJrIHgw1WgAAOw==')
        yes_icon=PhotoImage(
            data='R0lGODlhCwAOAMIAAAAAAP////4AAHZ2dv///////////////' \
                'yH5BAEKAAQALAAAAAALAA4AAAMuCLpATiBIqV6cITaI8+LCFGZ' \
                'DNAYjUKIitY5CuqKhfLWkiatXfPKM4IAwKBqPCQA7')
        no_icon=PhotoImage(
            data='R0lGODlhCwAOAMIAAAAAAP///3Z2dik8/////////////////' \
                'yH5BAEKAAQALAAAAAALAA4AAAMtCLpATiBIqV6cITaI8+IdJUR' \
                'DMJQiiaLAaE6si76ZDKc03V7hzvwCgmBILCYAADs=')
        
        # menus=[]
        options=[]
        cmlnode=node.id     
        for child in cmlnode.items:
           if interactively_visible(child):
               if child.type =="menu" and cmlnode.items :
                   # menus.append((child.prompt, child, shut_icon, open_icon))
                   options.append((child.prompt, child, shut_icon, open_icon))
               else:
                   if child.type in ("trit","bool") and \
                       (child.eval() == cml.y or child.eval() ==cml.m):
                       options.append((child.prompt, child, yes_icon, None))
                       child.yes="yes"    
                   elif child.type in ("trit","bool") and \
                       child.eval() == cml.n:
                       options.append((child.prompt, child, no_icon, None))
                       child.yes="no"
                   else:
                       options.append((child.prompt, child, file_icon, None))
                    
    #    menus.sort()
    #    options.sort()
    
        #return options+menus
        return options

    class ConfigMenu(Frame):
        "Generic X front end for configurator."
        def __init__(self, menu, config, mybanner):
            Frame.__init__(self, master=None)
            self.config = config
            announce = configuration.banner + lang["VERSION"] % cml.version
            if mybanner and announce.find("%s") > -1:
                announce %= mybanner
            self.master.title(announce)
            self.master.iconname(announce)
            self.master.resizable(FALSE, TRUE)
            Pack.config(self, fill=BOTH, expand=YES)
            self.keepalive = []	# Use this to anchor the PhotoImage object
            if configuration.icon:
                make_icon_window(self, configuration.icon)
            ## Test icon display with the following:
            # icon_image = PhotoImage(data=configuration.icon)
            # Label(self, image=icon_image).pack(side=TOP, pady=10)
            # self.keepalive.append(icon_image)
            self.header = Frame(self)
            self.header.pack(side=TOP, fill=X)
                             
            self.menubar = Frame(self.header, relief=RAISED, bd=2)
            self.menubar.pack(side=TOP, fill=X, expand=YES)
            self.filemenu = self.makeMenu(lang["FILEBUTTON"],
                                          (("LOADBUTTON", self.load),
                                           ("FREEZEBUTTON", self.freeze),
                                           ("SAVEBUTTON", self.save),
                                           ("SAVEAS", self.save_as),
                                           ("QUITBUTTON", self.leave),
                                           ))
            self.navmenu = self.makeMenu(lang["NAVBUTTON"],
                                          (("BACKBUTTON", self.pop),
                                           ("UPBUTTON", self.up),
                                           ("GOBUTTON", self.goto),
                                           ("SEARCHBUTTON", self.symbolsearch),
                                           ("HSEARCHBUTTON", self.helpsearch),
                                           ("UNSUPPRESSBUTTON",self.toggle_suppress),
                                           ("ANCESTORBUTTON",self.show_ancestors),
                                           ("DEPENDENTBUTTON",self.show_dependents),
                                           ))
            self.helpmenu = self.makeMenu(lang["HELPBUTTON"],
                                          (("HELPBUTTON", self.cmdhelp),))
            self.menulabel=Label(self.menubar)
            self.menulabel.pack(side=RIGHT)

            self.toolbar = Frame(self.header, relief=RAISED, bd=2)
            self.backbutton = Button(self.toolbar, text=lang["BACKBUTTON"],
                          command=self.pop)
            self.backbutton.pack(side=LEFT)
            self.helpbutton = Button(self.toolbar, text=lang["HELPBUTTON"],
                          command=lambda self=self: self.help(self.menustack[-1]))
            self.helpbutton.pack(side=RIGHT)

            self.workframe = None

        def makeMenu(self, label, ops):
            mbutton = Menubutton(self.menubar, text=label, underline=0)
            mbutton.pack(side=LEFT)
            dropdown = Menu(mbutton)
            for (legend, function) in ops:
                dropdown.add_command(label=lang[legend], command=function)
            mbutton['menu'] = dropdown
            return dropdown

        def setchoice(self, symbol):
            # Handle a choice-menu selection.
            self.set_symbol(symbol, cml.y)
            self.lastmenu = symbol
        
        # File menu operations

        def enable_file_ops(self, ok):
            if ok:
                self.filemenu.entryconfig(1, state=NORMAL)
                self.filemenu.entryconfig(2, state=NORMAL)
                self.filemenu.entryconfig(3, state=NORMAL)
                self.filemenu.entryconfig(4, state=NORMAL)
                #self.filemenu.entryconfig(5, state=NORMAL)
            else:
                self.filemenu.entryconfig(1, state=DISABLED)
                self.filemenu.entryconfig(2, state=DISABLED)
                self.filemenu.entryconfig(3, state=DISABLED)
                self.filemenu.entryconfig(4, state=DISABLED)
                #self.filemenu.entryconfig(5, state=DISABLED)

        def load(self):
            self.enable_file_ops(0)
            PromptGo(self, "LOADFILE", self.load_internal)
        def load_internal(self, file):
            "Load a configuration file."
            if file:
                try:
                    (changes, errors) = configuration.load(file, freeze=0)
                except IOError:
                    Dialog(self,
                           title = lang["PROBLEM"],
                           text = lang["LOADFAIL"] % file,
                           bitmap = 'error',
                           default = 0,
                           strings = (lang["DONE"],))                
                else:
                    if errors:
                        Dialog(self,
                                 title = lang["PROBLEM"],
                                 text = errors,
                                 bitmap = 'error',
                                 default = 0,
                                 strings = (lang["DONE"],))
                    else:
                        # Note, we don't try to display side effects here.
                        # From a file include, there are very likely to
                        # be more of them than can fit in a popup. 
                        Dialog(self,
                                 title = lang["OK"],
                                 text = lang["INCCHANGES"] % (changes,file),
                                 bitmap = 'hourglass',
                                 default = 0,
                                 strings = (lang["DONE"],))
                        #self.tree.update_tree()
            self.enable_file_ops(1)
        def freeze(self):
            ans = Dialog(self,
                         title = lang["CONFIRM"],
                         text = lang["FREEZE"],
                         bitmap = 'questhead',
                         default = 0,
                         strings = (lang["FREEZEBUTTON"], lang["CANCEL"]))
            if ans.num == 0:
                for key in configuration.dictionary.keys():
                    entry = configuration.dictionary[key]
                    if entry.eval():
                        entry.freeze()

        def save_internal(self, config):
            failure = configuration.save(config)
            if not failure:
                return 1
            else:
                ans = Dialog(self,
                             title = lang["PROBLEM"],
                             text = failure,
                             bitmap = 'error',
                             default = 0,
                             strings = (lang["CANCEL"], lang["DONE"]))
                return ans.num

        def save(self):
            if self.save_internal(self.config):
                self.quit()

        def save_as(self):
            # Disable everything but quit while this is going on
            self.enable_file_ops(0)
            PromptGo(self, "SAVEFILE", self.save_as_internal)
        def save_as_internal(self, file):
            if file:
                self.save_internal(file)
            self.enable_file_ops(1)

        def leave(self):
            if configuration.commits == 0:
                self.quit()
            else:
                ans = Dialog(self,
                         title = lang["QUITCONFIRM"],
                         text = lang["REALLY"],
                         bitmap = 'questhead',
                         default = 0,
                         strings = (lang["EXIT"], lang["CANCEL"]))
                if ans.num == 0:
                    self.quit()
                    raise SystemExit, 1

        # Navigation menu options

        def enable_nav_ops(self, ok):
            if ok:
                self.navmenu.entryconfig(1, state=NORMAL)
                self.navmenu.entryconfig(2, state=NORMAL)
                self.navmenu.entryconfig(3, state=NORMAL)
                self.navmenu.entryconfig(4, state=NORMAL)
                #self.navmenu.entryconfig(5, state=NORMAL)
                self.navmenu.entryconfig(6, state=NORMAL)
                self.navmenu.entryconfig(7, state=NORMAL)
            else:
                self.navmenu.entryconfig(1, state=DISABLED)
                self.navmenu.entryconfig(2, state=DISABLED)
                self.navmenu.entryconfig(3, state=DISABLED)
                self.navmenu.entryconfig(4, state=DISABLED)
                #self.navmenu.entryconfig(5, state=DISABLED)
                self.navmenu.entryconfig(6, state=DISABLED)
                self.navmenu.entryconfig(7, state=DISABLED)

        def up(self):
            here = self.menustack[-1]
            if here.menu:
                self.push(here.menu, here)

        def goto(self):
            self.enable_nav_ops(0)
            PromptGo(self, "GOTOBYNAME", self.goto_internal)
        def goto_internal(self, symname):
            if symname:
                if not configuration.dictionary.has_key(symname):
                    Dialog(self,
                             title = lang["PROBLEM"],
                             text = lang["NONEXIST"] % symname,
                             bitmap = 'error',
                             default = 0,
                             strings = (lang["DONE"],))
                else:
                    symbol = configuration.dictionary[symname]
                    print symbol
                    # We can't go to a symbol in a choices menu directly;
                    # instead we must go to its parent. 
                    if symbol.menu and symbol.menu.type == "choices":
                        symbol = symbol.menu
                    if not configuration.is_mutable(symbol):
                        Dialog(self,
                             title = lang["PROBLEM"],
                             text = lang["FROZEN"],
                             bitmap = 'hourglass',
                             default = 0,
                             strings = (lang["DONE"],))
                    elif not interactively_visible(symbol):
                        configuration.suppressions = 0
                    if symbol.type in ("menu", "choices"):
                        self.push(symbol)
                    elif symbol.menu:
                        self.push(symbol.menu, symbol)
                    else:
                        Dialog(self,
                               title = lang["PROBLEM"],
                               text = (lang["NOMENU"] % (symbol.name)),
                               bitmap = 'error',
                               default = 0,
                               strings = (lang["DONE"],))
            self.enable_nav_ops(1)

        def symbolsearch(self):
            self.enable_nav_ops(0)
            PromptGo(self, "SEARCHSYMBOLS", self.symbolsearch_internal)
        def symbolsearch_internal(self, pattern):
            if not pattern is None:
                if pattern:
                    hits = configuration.symbolsearch(pattern)
                    hits.inspected = 0
                    if hits.items:
                        self.push(hits)
                        print hits
                    else:
                        Dialog(self,
                               title = lang["PROBLEM"],
                               text = lang["NOMATCHES"],
                               bitmap = 'error',
                               default = 0,
                               strings = (lang["DONE"],))
                else:
                    Dialog(self,
                           title = lang["PROBLEM"],
                           text = lang["EMPTYSEARCH"],
                           bitmap = 'error',
                           default = 0,
                           strings = (lang["DONE"],))
            self.enable_nav_ops(1)

        def helpsearch(self):
            self.enable_nav_ops(0)
            PromptGo(self, "SEARCHHELP", self.helpsearch_internal)
        def helpsearch_internal(self, pattern):
            if not pattern is None:
                if pattern:
                    hits = configuration.helpsearch(pattern)
                    hits.inspected = 0
                    if hits.items:
                        self.push(hits)
                    else:
                        Dialog(self,
                               title = lang["PROBLEM"],
                               text = lang["NOMATCHES"],
                               bitmap = 'error',
                               default = 0,
                               strings = (lang["DONE"],))
                else:
                    Dialog(self,
                           title = lang["PROBLEM"],
                           text = lang["EMPTYSEARCH"],
                           bitmap = 'error',
                           default = 0,
                           strings = (lang["DONE"],))
            self.enable_nav_ops(1)

        def show_ancestors(self):
            self.enable_nav_ops(0)
            PromptGo(self, "SHOW_ANC", self.show_ancestors_internal)
        def show_ancestors_internal(self, symname):
            if symname:
                entry = configuration.dictionary.get(symname) 
                if not entry:
                    Dialog(self,
                           title = lang["INFO"],
                           text = lang["NONEXIST"] % symname,
                           bitmap = 'error',
                           default = 0,
                           strings = (lang["DONE"],))
                elif not entry.ancestors:
                    Dialog(self,
                           title = lang["PROBLEM"],
                           text = lang["NOANCEST"],
                           bitmap = 'info',
                           default = 0,
                           strings = (lang["DONE"],))
                else:
                    hits = cml.ConfigSymbol("ancestors", "menu")
                    hits.items = entry.ancestors
                    # Give result a parent only if all members have same parent
                    hits.menu = None
                    hits.inspected = 0
                    for symbol in hits.items:
                        if not interactively_visible(symbol):
                            configuration.suppressions = 0
                        if hits.menu == None:
                            hits.menu = symbol.menu
                        elif symbol.menu != hits.menu:
                            hits.menu = None
                            break
                    self.push(hits)
            self.enable_nav_ops(1)

        def show_dependents(self):
            self.enable_nav_ops(0)
            PromptGo(self, "SHOW_ANC", self.show_dependents_internal)
        def show_dependents_internal(self, symname):
            if symname:
                entry = configuration.dictionary.get(symname) 
                if not entry:
                    Dialog(self,
                           title = lang["INFO"],
                           text = lang["NONEXIST"] % symname,
                           bitmap = 'error',
                           default = 0,
                           strings = (lang["DONE"],))
                elif not entry.dependents:
                    Dialog(self,
                           title = lang["PROBLEM"],
                           text = lang["NODEPS"],
                           bitmap = 'info',
                           default = 0,
                           strings = (lang["DONE"],))
                else:
                    hits = cml.ConfigSymbol("dependents", "menu")
                    hits.items = entry.dependents
                    # Give result a parent only if all members have same parent
                    hits.menu = None
                    hits.inspected = 0
                    for symbol in hits.items:
                        if not interactively_visible(symbol):
                            configuration.suppressions = 0
                        if hits.menu == None:
                            hits.menu = symbol.menu
                        elif symbol.menu != hits.menu:
                            hits.menu = None
                            break
                    self.push(hits)
            self.enable_nav_ops(1)

        def toggle_suppress(self):
            configuration.suppressions = not configuration.suppressions
            if configuration.suppressions:
                self.navmenu.entryconfig(6, label=lang["UNSUPPRESSBUTTON"])
            else:
                self.navmenu.entryconfig(6, label=lang["SUPPRESSBUTTON"])
            self.build()
            self.display()

        # Help menu operations

        def cmdhelp(self):
            makehelpwin(title=lang["HELPBUTTON"],
                    mybanner=lang["HELPFOR"] % (configuration.banner,),
                    text=lang["TKCMDHELP"])

    class ConfigTreeMenu(ConfigMenu):
        "Top-level CML2 configurator object."
        def __init__(self, menu, config, mybanner):
            global helpwin
            Frame.__init__(self, master=None)
            ConfigMenu.__init__(self,menu,config,mybanner)
            self.optionframe=None
            self.tree=None
            self.treewindow=Frame(self)
            self.draw_tree()
            self.treewindow.pack(expand=YES,fill=BOTH,side=LEFT)
        
            #quitbutton=Button(self.master,text='Quit',command=parent.quit)
            #quitbutton.pack(fill=X,side=BOTTOM)
            
            self.navmenu.entryconfig(1, state=DISABLED)
            self.navmenu.entryconfig(2, state=DISABLED)
            self.navmenu.entryconfig(3, state=DISABLED)
            self.navmenu.entryconfig(4, state=DISABLED)
            self.navmenu.entryconfig(5, state=DISABLED)
            self.navmenu.entryconfig(6, state=DISABLED)
            self.navmenu.entryconfig(7, state=DISABLED)
            self.navmenu.entryconfig(8, state=DISABLED)
    
            helpwin=ScrolledText(self.master,text='',height=10) 
            helpwin.pack(fill=X,side=BOTTOM)
        def push(self):
            self.tree.ascend() 
        def pop(self):
            self.tree.descend() 
        def load_internal(self,file):
            ConfigMenu.load_internal(self,file)
            self.tree.update_tree()
        def toggle_init(self,node):
            global current_node
            current_node=node.id
            if current_node.helptext is None:
                helpwin.settext(current_node.prompt)
            else:
                helpwin.settext(current_node.helptext)   
            self.draw_optionframe()

        def draw_optionframe(self):
            global current_node,configuration
            node=current_node
            if self.optionframe:
                Widget.destroy(self.optionframe)            
            if node:
                id=node.name +": "+node.prompt
                if configuration.is_new(node):
                    id += " " + "New"
                self.ties={}
                self.optionframe=Frame(self.master)
                self.optionframe.pack(fill=X,side=TOP)
                if node.type =="choices":
                    new= Menubutton(self.optionframe,relief=RAISED, 
                                    text=node.prompt)
                    cmenu=Menu(new,tearoff=0)
                    self.ties[node.name]=StringVar()     
                    for alt in node.items:
                        cmenu.add_radiobutton(
                            label=alt.name+": "+alt.prompt,
                            variable=self.ties[node.name], value=alt.name,
                            command=lambda self=self, x=alt:self.setchoice(x))
                    new.config(menu=cmenu)
                    new.pack(side=LEFT,anchor=W,fill=X,expand=YES)    
                elif node.type in ("trit","bool"):
                    self.ties[node.name]=IntVar()
                    if configuration.trits_enabled:
                        w=Radiobutton(self.optionframe, text="y",
                                    variable=self.ties[node.name], 
                                    command=lambda x=node, self=self:
                                        self.set_symbol(x,cml.y),
                                    relief=GROOVE,value=cml.y)
                        w.pack(anchor=W,side=LEFT)
                        w=Radiobutton(self.optionframe, text="m",
                                    variable=self.ties[node.name], 
                                    command=lambda x=node, self=self:
                                        self.set_symbol(x,cml.m),
                                    relief=GROOVE,value=cml.m)
                        if node.type== "bool":
                            w.config(state=DISABLED,text="-")
                        w.pack(anchor=W,side=LEFT)
                        w=Radiobutton(self.optionframe, text="n",
                                    variable=self.ties[node.name], 
                                    command=lambda x=node, self=self:
                                        self.set_symbol(x,cml.n),
                                    relief=GROOVE,value=cml.n)
                        w.pack(anchor=W,side=LEFT)
                    else:
                        w=Checkbutton(self.optionframe,relief=GROOVE,
                                    variable=self.ties[node.name],
                                    command=lambda x=node,self=self:self.set_symbol(x,(cml.n,cml.y)[self.ties[x.name].get()]))
                        w.pack(anchor=W,side=LEFT)
                    tw=Label(self.optionframe,text=id,\
                                relief=GROOVE,anchor=W)
                    tw.pack(anchor=E,side=LEFT,fill=X,expand=YES)
                elif node.type == "string":
                    self.ties[node.name]=StringVar()
                    new=ValidatedField(self.optionframe,node,\
                                id,self.ties[node.name],
                                self.set_symbol_simple)
                    new.pack(side=LEFT,anchor=W,fill=X,expand=YES)    
                elif node.type =="decimal":
                    self.ties[node.name]=StringVar()    
                    new=ValidatedField(self.optionframe,node,\
                                id,self.ties[node.name],
                                lambda n,v,s=self:s.set_symbol_simple(n,int(v)))
                    new.pack(side=LEFT,anchor=W,fill=X,expand=YES)    
                elif node.type =="hexadecimal":
                    self.ties[node.name]=StringVar()    
                    new=ValidatedField(self.optionframe,node,\
                                id,self.ties[node.name],
                                lambda n,v,s=self:s.set_symbol_simple(n,int(v,16)))
                    new.pack(side=LEFT,anchor=W,fill=X,expand=YES)    
                else:
                    pass    
        
                #fill in the menu value    
                if self.ties.has_key(node.name):
                    if node.type =="choices":
                        self.ties[node.name].set(node.menuvalue.name)
                    elif node.type in ("string","decimal") or \
                            node.enum:
                        self.ties[node.name].set(str(node.eval()))
                    elif node.type =="hexadecimal":
                        self.ties[node.name].set("0x%x" % node.eval())
                    else:    
                        enumval=node.eval()
                        if not configuration.trits_enabled and \
                            node.is_logical():
                            enumval= min(enumval.value, cml.m.value)
                        self.ties[node.name].set(enumval)
    
        def draw_tree(self):
            global configuration
            self.tree=myTree(self.treewindow, rootname=configuration.start, rootlabel=configuration.start.name, width=298,getcontents=get_contents,toggle_init=self.toggle_init)
            self.tree.pack(fill=BOTH,expand=YES,side=LEFT)
    
    
            sb=Scrollbar(self.treewindow)
            sb.configure(command=self.tree.yview)
            sb.pack(side=RIGHT,fill=Y)
            self.tree.configure(yscrollcommand=sb.set)
    
            self.tree.focus_set()
    
        def setchoice(self, symbol):
            # Handle a choice-menu selection.
            self.set_symbol(symbol, cml.y)
            self.lastmenu = symbol
    
        def set_symbol(self,symbol,value):
            "Set symbol, checking validity"
            global configuration
            #print "set_symbol(%s,%s)" % (symbol.name,value)
            if symbol.is_numeric() and symbol.range:
                if not configuration.range_check(symbol,value):
                    Dialog(self,
                        title=lang["PROBLEM"],
                        text=lang["OUTOFBOUNDS"] % (value, symbol.range,),
                        bitmap='error',
                        default=0,
                        strings=(lang["DONE"],))
                    return
            old_tritflag=configuration.trits_enabled
            self.master.grab_set()
            (ok, effects, violations)=configuration.set_symbol(symbol, value)
            #print ok,effects,violation
            self.master.grab_release()
            if not ok:
                explain =""
                if effects:
                    explain = lang["EFFECTS"] + "\n" \
                            + string.join(effects, "\n") + "\n"
                explain += lang["ROLLBACK"] % (symbol.name, value) + \
                    "\n" + string.join(map(repr, violations), "\n") + "\n"
                Dialog(self, \
                    title = lang["PROBLEM"], \
                    text = explain, \
                    bitmap = 'error', \
                    default = 0, \
                    strings = (lang["DONE"],))
            else:
                #wchkang
                #self.tree.update_node()    
                self.tree.update_tree()    
    
                if old_tritflag != configuration.trits_enabled:
                    pass
                #    self.draw_optionframe()
                if violations:
                    Dialog(self,
                        title = lang["SIDEEFFECTS"],
                        text = string.join(map(repr, violations), "\n"),
                        bitmap = 'info', 
                        default = 0,
                        strings = (lang["DONE"],))
            self.draw_optionframe()
        def set_symbol_simple(self,symbol,value):
            "Simple set-symbol without any screen update, validity checking"
            #print "set_symbol_simple(%s,%s)" % (symbol.name,value)
            self.master.grab_set()
            (ok, effects, violations) = configuration.set_symbol(symbol, value)
            self.master.grab_release()

 
    class ConfigStackMenu(ConfigMenu):
        "Top-level CML2 configurator object."
        def __init__(self, menu, config, mybanner):
            Frame.__init__(self, master=None)
            ConfigMenu.__init__(self, menu, config, mybanner)
            
	    self.menuframe = ScrolledFrame(self)
            self.menuframe.pack(side=BOTTOM, fill=BOTH, expand=YES)
            
            self.menustack = []
            self.locstack = []

            # Time to set up the main menu
            self.lastmenu = None
            self.push(configuration.start)

        # Repainting

        def build(self):
            "Build widgets for all symbols in a menu, but don't pack them."
            if self.workframe:
                Widget.destroy(self.workframe)
            self.workframe = Frame(self.menuframe.inner)
            self.visible = []
            
            menu = self.menustack[-1]
            w = Label(self.workframe,  text=menu.prompt)
            w.pack(side=TOP, fill=X, expand=YES)
            self.menulabel.config(text="(" + menu.name +")")

            self.symbol2widget = {}
            self.ties = {}
            self.textparts = {}
            for node in menu.items:
                id = node.name + ": " + node.prompt
                if configuration.is_new(node):
                    id += " " + lang["NEW"]
                myframe = Frame(self.workframe)
                if node.type == "message":
                    new = Label(myframe, text=node.prompt)
                    self.textparts[node.name] = new 
                elif node.frozen():
                    value =  str(node.eval(debug))
                    new = Label(myframe, text=node.name + ": " + \
                                    node.prompt + " = " + value)
                    self.textparts[node.name] = new 
                    new.config(fg='blue')
                elif node.type == "menu":
                    new = Button(myframe, text=node.prompt,
                                 command=lambda x=self,y=node:x.push(y))
                    self.textparts[node.name] = new
                elif node.type == "choices":
                    new = Menubutton(myframe, relief=RAISED,
                                     text=node.prompt)
                    self.textparts[node.name] = new
                    cmenu = Menu(new, tearoff=0)
                    self.ties[node.name] = StringVar(self.workframe)
                    for alt in node.items:
                        cmenu.add_radiobutton(
                                        label=alt.name+": "+alt.prompt,
                                        variable=self.ties[node.name], value=alt.name,
                                        command=lambda self=self, x=alt:self.setchoice(x))
                        # This is inelegant, but it will get the job done...
                        self.symbol2widget[alt] = new
                    new.config(menu=cmenu)
                elif node.type in  ("trit", "bool"):
                    new = Frame(myframe)
                    self.ties[node.name] = IntVar(self.workframe)
                    if configuration.trits_enabled:
                        w = Radiobutton(new, text="y", relief=GROOVE,
                                    variable=self.ties[node.name], value=cml.y,
                                    command=lambda x=node, self=self: \
                                        self.set_symbol(x, cml.y))
                        w.pack(anchor=W, side=LEFT)
                        w = Radiobutton(new, text="m", relief=GROOVE,
                                        variable=self.ties[node.name], value=cml.m,
                                        command=lambda x=node, self=self: \
                                        self.set_symbol(x, cml.m))
                        if node.type == "bool":
                            w.config(state=DISABLED, text="-")
                        w.pack(anchor=W, side=LEFT)
                        w = Radiobutton(new, text="n", relief=GROOVE,
                                    variable=self.ties[node.name], value=cml.n,
                                    command=lambda x=node, self=self: \
                                        self.set_symbol(x, cml.n))
                        w.pack(anchor=W, side=LEFT)
                    else:
                        w = Checkbutton(new, relief=GROOVE,
                                    variable=self.ties[node.name],
                                    command=lambda x=node, self=self: \
                                        self.set_symbol(x, (cml.n, cml.y)[self.ties[x.name].get()]))
                        w.pack(anchor=W, side=LEFT)
                    tw = Label(new, text=id, relief=GROOVE, anchor=W)
                    tw.pack(anchor=E, side=LEFT, fill=X, expand=YES)
                    self.textparts[node.name] = tw
                elif node.discrete:
                    new = Menubutton(myframe, relief=RAISED,
                                     text=node.name+": "+node.prompt,
                                     anchor=W)
                    self.textparts[node.name] = new
                    cmenu = Menu(new, tearoff=0)
                    self.ties[node.name] = StringVar(self.workframe)
                    for value in node.range:
                        if node.type == "decimal":
                            label=`value`
                        elif node.type == "hexadecimal":
                            label = "0x%x" % value
                        cmenu.add_radiobutton(label=label, value=label,
                                              variable=self.ties[node.name], 
                                              command=lambda self=self, symbol=node, label=label:self.set_symbol(symbol, label))
                    new.config(menu=cmenu)
                elif node.enum:
                    new = Menubutton(myframe, relief=RAISED,
                                     text=node.name+": "+node.prompt,
                                     anchor=W)
                    self.textparts[node.name] = new
                    cmenu = Menu(new, tearoff=0)
                    self.ties[node.name] = StringVar(self.workframe)
                    for (label, value) in node.range:
                        cmenu.add_radiobutton(label=label, value=value,
                                              variable=self.ties[node.name], 
                                              command=lambda self=self, symbol=node, label=label, value=value:self.set_symbol(symbol, value))
                    new.config(menu=cmenu)
                elif node.type == "decimal":
                    self.ties[node.name] = StringVar(self.workframe)
                    new = ValidatedField(myframe, node,
                                         id, self.ties[node.name],
                                         lambda n, v, s=self: s.set_symbol(n, int(v)))
                    self.textparts[node.name] = new.L
                elif node.type == "hexadecimal":
                    self.ties[node.name] = StringVar(self.workframe)
                    new = ValidatedField(myframe, node,
                                         id, self.ties[node.name],
                                         lambda n, v, s=self: s.set_symbol(n, int(v, 16)))
                    self.textparts[node.name] = new.L
                elif node.type == "string":
                    self.ties[node.name] = StringVar(self.workframe)
                    new = ValidatedField(myframe, node,
                                         id, self.ties[node.name],
                                         self.set_symbol)
                    self.textparts[node.name] = new.L
                new.pack(side=LEFT, anchor=W, fill=X, expand=YES)
                if node.type not in ("explanation", "message"):
                    help = Button(myframe, text=lang["HELPBUTTON"],
                                 command=lambda symbol=node, self=self: self.help(symbol))
                    help.pack(side=RIGHT, anchor=E)
                    if not node.help():
                        help.config(state=DISABLED)
                myframe.pack(side=TOP, fill=X, expand=YES)
                self.symbol2widget[node] = myframe

            # This isn't widget layout, it grays out the Back buttons
            if len(self.menustack) <= 1:
                self.backbutton.config(state=DISABLED)
                self.navmenu.entryconfig(1, state=DISABLED)
            else:
                self.backbutton.config(state=NORMAL)
                self.navmenu.entryconfig(1, state=NORMAL)

            # Likewise, this grays out the help button when appropriate.
            here = self.menustack[-1]
            if isinstance(here, cml.ConfigSymbol) and here.help():
                self.helpbutton.config(state=NORMAL)
            else:
                self.helpbutton.config(state=DISABLED)

            # This grays out the "up" button
            if not here.menu:
                self.navmenu.entryconfig(2, state=DISABLED)
            else:
                self.navmenu.entryconfig(2, state=NORMAL)

            # Pan canvas to the top of the widget list
            self.menuframe.resetscroll()

        def refresh(self):
            self.workframe.update()

            # Dynamic resizing.  This code can flake out in some odd
            # ways, notably by where it puts the resized window (this
            # is probably tickling a window-manager bug). We want
            # normal placement somewhere in an unused area of the root
            # window.  What we get too often (at least under
            # Enlightenment) is the window placed where the top of
            # frame isn't visible -- which is annoying, because it
            # makes it hard to move the window to a better spot.
            widgetheight = self.workframe.winfo_reqheight()
            # Allow 50 vertical pixels for window frame cruft.
            maxheight = self.winfo_screenheight() - 50
            oversized = widgetheight > maxheight
            self.menuframe.showscroll(oversized)
            if oversized:
                # This assumes the scrollbar widget will be < 25 pixels wide
                newwidth = self.workframe.winfo_width() + 25
                newheight = maxheight
            else:
                newwidth = self.workframe.winfo_width()
                newheight = widgetheight + \
                	self.menubar.winfo_height()+self.menubar.winfo_height()
            # Following four lines center the window.
            #topx = (self.winfo_screenwidth() - newwidth) / 2
            #topy = (self.winfo_screenheight() - newheight) / 2
            #if topx < 0: topx = 0
            #if topy < 0: topy = 0
            #self.master.geometry("%dx%d+%d+%d"%(newwidth,newheight,topx,topy))
            self.master.geometry("%dx%d" % (newwidth, newheight))
            self.workframe.lift()

        def display(self):
            menu = self.menustack[-1]
            newvisible = filter(lambda x, m=menu: hasattr(m, 'nosuppressions') or interactively_visible(x), menu.items)
            # Insert all widgets that must newly become visible 
            for symbol in menu.items:
                # Color the menu text
                textpart = self.textparts[symbol.name]
                if symbol.type in ("menu", "choices"):
                    if symbol.inspected:
                        textpart.config(fg='dark green')
                    elif not symbol.frozen():
                        textpart.config(fg='black')
                elif symbol.type in ("trit", "bool"):
                    if symbol.setcount or symbol.included:
                        textpart.config(fg='dark green')
                # Fill in the menu value
                if self.ties.has_key(symbol.name):
                    if symbol.type == "choices":
                        self.ties[symbol.name].set(symbol.menuvalue.name)
                    elif symbol.type in ("string", "decimal") or symbol.enum:
                        self.ties[symbol.name].set(str(symbol.eval()))
                    elif symbol.type == "hexadecimal":
                        self.ties[symbol.name].set("0x%x" % symbol.eval())
                    else:
                        enumval = symbol.eval()
                        if not configuration.trits_enabled and symbol.is_logical():
                            enumval = min(enumval.value, cml.m.value)
                        self.ties[symbol.name].set(enumval)
                # Now hack the widget visibilities
                if symbol in newvisible and symbol not in self.visible:
                    argdict = {'anchor':W, 'side':TOP}
                    if self.menustack[-1].type != "choices":
                         argdict['expand'] = YES
                         argdict['fill'] = X
                    # Fiendishly clever hack alert: avoid excessive screen
                    # updating by repacking widgets in place as they pop
                    # in and out of visibility. Look for a first visible symbol
                    # after the current one.  If you find one, use it to
                    # generate a "before" option for packing.  Otherwise,
                    # generate an "after" option that packs after the last
                    # visible item.
                    if self.visible:
                        foundit = 0
                        for anchor in menu.items[menu.items.index(symbol):]:
                            if anchor in self.visible:
                                argdict['before'] = self.symbol2widget[anchor]
                                foundit = 1
                                break
                        if not foundit:
                            argdict['after'] = self.symbol2widget[self.visible[-1]]
                            self.visible.append(symbol)
                    self.symbol2widget[symbol].pack(argdict)
            # We've used all the anchor points, clean up invisible ones
            for symbol in menu.items:
                if symbol not in newvisible:
                    self.symbol2widget[symbol].pack_forget()
                elif symbol.type == "choices":
                    if symbol.menuvalue:
                        self.symbol2widget[symbol].winfo_children()[0].config(text="%s (%s)" % (symbol.prompt, symbol.menuvalue.name))
                elif symbol.discrete:
                    self.symbol2widget[symbol].winfo_children()[0].config(text="%s: %s (%s)" % (symbol.name, symbol.prompt, str(symbol.eval())))
            self.workframe.pack(side=BOTTOM)
            self.toolbar.pack(side=BOTTOM, fill=X, expand=YES)
            self.visible = newvisible

            self.refresh()

        # Operations on symbols and menus

        def set_symbol(self, symbol, value):
            "Set symbol, checking validity."
            #print "set_symbol(%s, %s)" % (symbol.name, value)
            if symbol.is_numeric() and symbol.range:
                if not configuration.range_check(symbol, value):
                    Dialog(self,
                         title = lang["PROBLEM"],
                         text = lang["OUTOFBOUNDS"] % (value, symbol.range,),
                         bitmap = 'error',
                         default = 0,
                         strings = (lang["DONE"],))
                    return
            old_tritflag = configuration.trits_enabled
            # The set_grab() is an attempt to head off race conditions.
            # We don't want the symbol widgets to accept new input
            # events while the side-effects of a symbol set are still
            # being computed.
            self.master.grab_set()
            (ok, effects, violations) = configuration.set_symbol(symbol,value)
            self.master.grab_release()
            if not ok:
                explain = ""
                if effects:
                    explain = lang["EFFECTS"] + "\n" \
                              + string.join(effects, "\n") + "\n"
                explain += lang["ROLLBACK"] % (symbol.name, value) + \
                           "\n" + string.join(map(repr, violations), "\n") + "\n"
                Dialog(self,
                         title = lang["PROBLEM"],
                         text = explain,
                         bitmap = 'error',
                         default = 0,
                         strings = (lang["DONE"],))
            else:
                if old_tritflag != configuration.trits_enabled:
                    self.build()
            self.display()

        def help(self, symbol):
            makehelpwin(title=lang["HELPBUTTON"],
                    mybanner=lang["HELPFOR"] % (symbol.name),
                    text = symbol.help())

        def push(self, menu, highlight=None):
            configuration.visit(menu)
            self.menustack.append(menu)
            self.locstack.append(self.menuframe.canvas.canvasy(0))
            self.build()
            self.lastmenu = highlight
            self.display()
            menu.inspected += 1

        def pop(self):
            if len(self.menustack) > 1:
                from_menu = self.menustack[-1]
                self.menustack = self.menustack[:-1]
                self.build()
                self.lastmenu = from_menu
                self.display()
                from_loc = self.locstack[-1]
                self.locstack = self.locstack[:-1]
                self.menuframe.resetscroll(from_loc)

        def freeze(self):
            "Call the base freeze, then update the display."
            ConfigMenu.freeze(self)
            self.build()
            self.display()

except ImportError:
    pass

def tkinter_style_menu(config, mybanner):
    ConfigStackMenu(configuration.start, config, mybanner).mainloop()

def tkinter_qplus_style_menu(config, mybanner):
    ConfigTreeMenu(configuration.start, config, mybanner).mainloop()

# Report generator

def menu_tree_list(node, indent):
    "Print a map of a menu subtree."
    totalindent = (indent + 4 * node.depth)
    trailer = (" " * (40 - totalindent - len(node.name))) + `node.prompt`
    print " " * totalindent, node.name, trailer
    if configuration.debug:
	if node.visibility:
	    print " " * 41, lang["VISIBILITY"], cml.display_expression(node.visibility)
	if node.default:
	    print " " * 41, lang["DEFAULT"], cml.display_expression(node.default)
    if node.items:
	for child in node.items:
	    menu_tree_list(child, indent + 4)

# Environment probes

def is_under_X():
    # It would be nice to just check WINDOWID, but some terminal
    # emulators don't set it. One of those is kvt.
    if os.environ.has_key("WINDOWID"):
        return 1
    else:
        import commands
        (status, output) = commands.getstatusoutput("xdpyinfo")
        return status == 0

# Rulebase loading and option processing

def load_system(cmd_options, cmd_arguments):
    "Read in the rulebase and handle command-line arguments."
    global debug, config
    debug = 0;
    config = None

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

    configuration.debug_emit(1, lang["PARAMS"] % (config,configuration.prefix))

    # Perhaps the user needs modules enabled initially
    if configuration.trit_tie and cml.evaluate(configuration.trit_tie):
        configuration.trits_enabled = 1

    # Don't count all these automatically generated settings
    # for purposes of figuring out whether we should confirm a quit.
    configuration.commits = 0

    return configuration

def process_include(configuration, file, freeze):
    "Process a -i or -I inclusion option."
    # Failure to find an include file is non-fatal
    try:
        (changes, errors) = configuration.load(file, freeze)
    except IOError:
        print lang["LOADFAIL"] % file
        return
    if errors:
        print errors
    elif configuration.side_effects:
        print lang["SIDEFROM"] % file
        sys.stdout.write(string.join(configuration.side_effects, "\n") + "\n")

def process_define(configuration, val, freeze):
    "Process a -d=xxx or -D=xxx option."
    parts = string.split(val, "=")
    sym = parts[0]
    if configuration.dictionary.has_key(sym):
        sym = configuration.dictionary[sym]
    else:
        configuration.errout.write(lang["SYMUNKNOWN"] % (`sym`,))
        sys.exit(1)
    if sym.is_derived():
        configuration.debug_emit(1, lang["DERIVED"] % (`sym`,))
        sys.exit(1)
    elif sym.is_logical():
        if len(parts) == 1:
            val = 'y'
        elif parts[1] == 'y':
            val = 'y'
        elif parts[1] == 'm':
            configuration.trits_enabled = 1
            val = 'm'
        elif parts[1] == 'n':
            val = 'n'
        else:
            print lang["BADBOOL"]
            sys.exit(1)
    elif len(parts) == 1:
        print lang["NOCMDLINE"] % (`sym`,)
        sys.exit(1)
    else:
        val = parts[1]
    (ok, effects, violations) = configuration.set_symbol(sym,
                                 configuration.value_from_string(sym, val),
                                 freeze)
    if effects:
        print lang["EFFECTS"]
        sys.stdout.write(string.join(effects,"\n")+"\n")
    if not ok:
        print lang["ROLLBACK"] % (sym.name, val)
        sys.stdout.write("\n".join(map(repr, violations))+"\n")

def process_options(configuration, options):
    # Process command-line options second so they override
    global list, config
    global force_batch, force_x, force_q, force_tty, force_curses, debug
    global readlog, banner
    config = "config.out"
    for (switch, val) in options:
	if switch == '-b':
	    force_batch = 1
	elif switch == '-B':
	    banner = val
	elif switch == '-d':
            process_define(configuration, val, freeze=0)
	elif switch == '-D':
            process_define(configuration, val, freeze=1)
	elif switch == '-i':
            process_include(configuration, val, freeze=0)
	elif switch == '-I':
            process_include(configuration, val, freeze=1)
	elif switch == '-l':
	    list = 1
	elif switch == '-o':
	    config = val
	elif switch == '-v':
	    debug = debug + 1
            configuration.debug = configuration.debug + 1
	elif switch == '-S':
	    configuration.suppressions = 0
	elif switch == '-R':
	    readlog = open(val, "r")

# Main sequence -- isolated here so we can profile it

def main(options, arguments):
    global force_batch, force_x, force_q, force_curses, force_tty
    global configuration

    try:
        configuration = load_system(options, arguments)
    except KeyboardInterrupt:
        raise SystemExit

    if list:
        try:
            menu_tree_list(configuration.start, 0)
        except EnvironmentError:
            pass	# Don't emit a traceback when we interrupt the listing
	raise SystemExit
    # Perhaps we're in batchmode.  If so, only process options. 
    if force_batch:
        # Have to realize all choices values first...
        for entry in configuration.dictionary.values():
            if entry.type == "choices":
                configuration.visit(entry)
        configuration.save(config)
        return
 
    # Next, try X
    if force_x:
        tkinter_style_menu(config, banner)
        return

    # Next, try Qplus style X
    if force_q:
        tkinter_qplus_style_menu(config, banner)
        return
    
    # Next, try curses
    if force_curses and not force_tty:
        try:
            curses.wrapper(curses_style_menu, config, banner)
            return
        except "TERMTOOSMALL":
            print lang["TERMTOOSMALL"]
            force_tty = 1

    # If both failed, go glass-tty
    if force_debugger:
        print lang["DEBUG"] % configuration.banner
        debugger_style_menu(config, banner).cmdloop()        
    elif force_tty:
        print lang["WELCOME"]%(configuration.banner,) + lang["VERSION"]%(cml.version,)
        configuration.errout = sys.stdout
        print lang["TTYQUERY"]
        tty_style_menu(config, banner).cmdloop()

if __name__ == '__main__':
    try:
        runopts = "bB:cD:d:h:i:I:lo:P:qR:SstVvWx"
	(options,arguments) = getopt.getopt(sys.argv[1:], runopts, "help")
        if os.environ.has_key("CML2OPTIONS"):
            (envopts, envargs) = getopt.getopt(
                os.environ["CML2OPTIONS"].split(),
                runopts)
            options = envopts + options
    except:
	print lang["BADOPTION"]
        print lang["CLIHELP"]
	sys.exit(1)

    for (switch, val) in options:
	if switch == "-b":
	    force_batch = 1
        if switch == "-V":
            print "cmlconfigure", cml.version
            raise SystemExit
	elif switch == '-P':
	    proflog = val
	elif switch == '-x':
	    force_x = 1
	elif switch == '-q':
	    force_q = 1
	elif switch == '-t':
	    force_tty = 1
	elif switch == '-c':
	    force_curses = 1
	elif switch == '-s':
	    force_debugger = force_tty = 1
        elif switch == '--help':
            sys.stdout.write(lang["CLIHELP"])
            raise SystemExit

    # Probe the environment to see if we can use X for the front end.
    if not force_tty and not force_debugger and not force_curses and not force_x and not force_q and not force_batch:
        force_x = force_q = is_under_X()

    # Do we see X capability?
    if force_x or force_q:
        try:
            from Tkinter import *
            from Dialog import *
        except:
            print lang["NOTKINTER"]
	    if not force_batch:
            	time.sleep(5)
            force_curses = 1
            force_x = force_q = 0

    # Probe the environment to see if we can come up in ncurses mode
    if not force_tty and not force_x and not force_q:
	if not os.environ.has_key('TERM'):
	    print lang["TERMNOTSET"]
	    force_tty = 1
	else:
            import traceback
            try:
                import curses, curses.textpad, curses.wrapper
                force_curses = 1
            except:
                ImportError
                print lang["NOCURSES"]
                force_tty = 1

    if force_tty or force_debugger:
        # It's been reported that this import fails under some 1.5.2s.
        # No disaster; it's just a convenience to have command history
        # in the line-oriented mode.
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
        raise SystemExit, 2
    except "UNSATISFIABLE":
        #configuration.save("post.mortem")
        print lang["POSTMORTEM"]
        raise SystemExit, 3

# That's all, folks!
