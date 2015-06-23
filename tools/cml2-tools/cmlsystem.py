"""
cmlsystem.py -- CML2 configurator front-end support

by Eric S. Raymond, <esr@thyrsus.com>

Mode-independent code for front ends.  This supplies one big class that you
initialize by loading a compiled rulebase.  The class provides functions for
doing tests and manipulations on the rulebase, and for writing out
configuration files.
"""

import os, sys, re
import cml

_eng = {
    "ABOUT":"About to write %s=%s (type %s)",
    "BADEQUALS":"bad token `%s' while expecting '='.",
    "BADVERSION":"Compiler/configurator version mismatch (%s/%s), recompile the rulebase please.\n",
    "BADTOKEN":"unrecognized name `%s' while expecting known symbol.",
    "BADTRIT":"Boolean symbol %s cannot have value m.",
    "BINDING":"    %sBinding from constraint: %s=%s (source %s)",
    "CHECKDONE":"    ...menu %s check done",
    "CHECKING":"    Checking menu %s...",
    "COMMIT":"    Committing new bindings.",
    "CONSTRAINT":"    Value %s for %s failed constraint %s",
    "DERIVED":"Cannot set derived symbol %s",
    "EXCLUDED":"    %s value %s excluded by %s",
    "FAILREQ":"    Failed constraint %s",
    #"FORBIDDEN":"%s=%s would violate %s",
    "FROZEN":" (frozen)",
    "HELPFLAG":"Help-required flag is %s",
    "INCONST":"Symbol %s forced to n during recovery attempt.\n",
    "INVISANC":"    %s not visible, ancestor %s false",
    "INVISANC2":"    %s not visible, ancestor %s invisible",
    "INVISHELP":"    %s not visible, no help",
    "INVISME":"    %s not visible, %s guard %s is false",
    "INVISSTART":"    is_visible(%s) called",
    "INVISUP":"    %s not visible, upward visibility",
    "MODULESN":"All M-valued symbols will be forced to Y.",
    "MODULESM":"All tristate symbols will default to M.",
    "MODULESY":"Tristate symbols won't default to M.",
    "NOHELP":"    %s not visible, it has no help",
    "NOTSAVED": "(not saveable) ",
    "NOVISIBLE":"No visible items at %s",
    "OLDVAL": "    %sOld value of %s is %s", 
    "RADIOINVIS":"    Query of choices menu %s elided, button pressed",
    "READING":"Reading configuration from %s",
    "RECOVERY":"Attempting recovery from invalid configuration:",
    "RECOVEROK":"Recovery OK.",
    "REDUNDANT":"    %sRedundant assignment forced by %s", 
    "RENAME":"Attempt to rename %s to %s failed.",
    "ROLLBACK":"    Rolling back new bindings: ",
    "SAVEEND":"#\n# That's all, folks!\n",
    "SETFAILED":"%sAttempt to set frozen symbol %s failed",
    "SETTING":"%s=%s",
    "SHAUTOGEN":"#\n# Automatically generated, don't edit\n#\n",
    "SHDERIVED":"#\n# Derived symbols\n#\n",
    "SIDEEFFECT":" (deduced from %s)",
    "SUBINVIS":"    %s not visible, all subqueries invisible.",
    "TRIGGER":"    Set of %s = %s triggered by guard %s",
    "TRITFLAG":"Trit flag is now %s",
    "TRITSOFF":"    %s not visible, trits are suppressed",
    "TYPEUNKNOWN":"Node %s unknown value type: %s %s",
    "UNCHANGED":"    %sSymbol %s unchanged",
    "UNCOMMIT": "#\n# Uncommitted bindings\n#\n",
    "UNLOAD1":"File load violated these constraints:",
    "UNLOAD2":"Undoing file loads, recovery failed these constraints:",
    #"UNSATISFIABLE":"Ruleset found unsatisfiable while setting %s",
    "UNSAVEABLE":"%s is not saveable",
    "USERSETTING":"User action on %s.",
    "VALIDRANGE":"    Valid range of %s is %s",
    "VALUNKNOWN":"Node %s %s has unknown value: %s",
    "VISIBLE":"    Query of %s *not* elided",
}

class CMLSystem(cml.CMLRulebase):
    "A rulebase, from the point of view of a front end."
    relational_map ={ \
                    "==":"!=", "!=":"==", \
                    ">":"<=", "<=":">", \
                    "<":">=", ">=":"<", \
                    }

    def clear(self):
        "Clear the runtime value state."
        for entry in self.dictionary.values():
            entry.iced = 0		# True if it has been frozen
            if entry.type == "choices":
                entry.menuvalue = entry.default
            else:
                entry.menuvalue = None
            entry.bindingcache = []	# Symbol's value stack
        self.oldbindings = {}
        self.newbindings = {}
        self.chilled = {}
        self.touched = []		# Does it have an uncommitted binding?
        self.changes_to_frozen = []     # Frozen change violations
        self.inclusions = []

    def __init__(self, rules):
        "Make a configuration state object from a compiled rulebase."
        # Interpret a string as the name of a file containing pickled rules.
        if type(rules) == type(""):
            import cPickle
            rules = cPickle.load(open(rules, "rb"))

        # Copy the symbol table.   Since a python object's members are all
        # stored in a single hash table, we can steal its contents and
        # then discard the original object.
        self.__dict__ = rules.__dict__

        self.clear()

        # Enhance the ConfigSymbol methods to deal with the value state.
        if 'oldeval' not in dir(cml.ConfigSymbol):
            cml.ConfigSymbol.oldeval = cml.ConfigSymbol.eval
            def _neweval(symbol, debug=0, self=self):	# Not a method!
                value = self.__bindeval(symbol)
                if value != None:
                    return value
                value = cml.ConfigSymbol.oldeval(symbol, debug)
                if value != None:
                    return value
                elif symbol.type in ("decimal", "hexadecimal"):
                    return 0
                elif symbol.type == "string":
                    return ""
                elif symbol.is_logical():
                    return cml.n
                else:
                    return None	# for menu, choices, and message-valued symbols
            cml.ConfigSymbol.eval = _neweval

            def _newstr(symbol):		# Not a method!
                res = "%s={" % (symbol.name)
                res = res + symbol.dump()
                if symbol.setcount:
                    res = res + " has been set,"
                if symbol.included:
                    res = res + " was loaded,"
                if symbol.frozen():
                    res = res + " frozen,"
                value = symbol.eval()
                if value != None:
                    res = res + " value " + str(value) + "," 
                return res[:-1] + "}"
            cml.ConfigSymbol.__str__ = _newstr

            def _freeze(symbol):
                "Freeze a symbol."
                symbol.iced = 1
                if symbol.menu and symbol.menu.type == "choices":
                    symbol.menu.iced = 1
                    symbol.menu.value = symbol.name
                    for sibling in symbol.menu.items:
                        sibling.iced = 1
            cml.ConfigSymbol.freeze = _freeze

            def _frozen(symbol, self=self):
                "Is the symbol frozen?"
                if symbol.iced or symbol.type == "message":
                    return 1
                if symbol.type in ("menu", "choices"):
                    for item in symbol.items:
                        if self.is_visible(item) and not item.frozen():
                            return 0
                    return 1
                return 0
            cml.ConfigSymbol.frozen = _frozen

        # Extra state for the configuration object
        self.debug = 0			# Initially, no status logging
        self.cdepth = 0			# Constraint recursion xdepth
        self.errout = sys.stderr	# Where to do status logging
        self.suppressions = 1		# Yes, do visibility checks
        self.interactive = 1		# Are we doing a file inclusion?
        self.commits = 0		# Value sets since last save 
        self.lang = _eng		# Someday we'll support more languages.
        self.side_effects = []		# Track side effects
        self.trits_enabled = not self.trit_tie or self.trit_tie.eval()

        if rules.version != cml.version:
            sys.stderr.write(self.lang["BADVERSION"] % (rules.version, cml.version))
            raise SystemExit, 1

    def is_new(self, symbol):
        return self.inclusions and not symbol.included and symbol.is_symbol()

    # Utility code

    def debug_emit(self, threshold, msg):
        "Conditionally emit a debug message to the designated error stream."
        if self.debug >= threshold:
            self.errout.write(msg + "\n")

    # Handling of symbol bindings is encapsulated here.  The semantics
    # we want is for every side-effect to be associated with the
    # symbol whose user-specified change in value triggered it (the
    # primary).  That way, if and when the user changes the primary's
    # value again, we can back out all previous side-effects
    # contingent on that symbol.
    #
    # Essentially what we're doing here is journalling all bindings.
    # It has to be this way, because different values of the same
    # symbol could trigger completely different side effects depending
    # on how the constraints are written.
    #
    class __Binding:
        def __init__(self, symbol, value, link):
            # We don't track a binding's source in the __Binding
            # object itself because they always live in chains hanging
            # off a primary-symbol cell.
            self.symbol = symbol
            self.value = value
            self.link = link	# Next link in the primary's side-effect chain
            self.visible = 1
        def __repr__(self):
            return "%s=%s" % (self.symbol.name, self.value)

    def __bindeval(self, symbol):
        "Get the most recent visible value for symbol off the binding stack."
        #self.debug_emit(2, "    bindeval(%s)" % (symbol.name))
        if not hasattr(symbol, "bindingcache"):
            return None
        for binding in symbol.bindingcache:
            if binding.visible:
                return binding.value
    def __bindmark(self, symbol):
        # Mark it to be written
        menu = symbol
        while menu:
            menu.setcount += 1
            menu = menu.menu
    def __bindsymbol(self, symbol, value, source=None, sort=0, suppress=0):
        "Bind symbol to a given value."
        self.debug_emit(2, "    %sbindsymbol(%s, %s, %s, %s)" % (' '*self.cdepth,symbol.name, value, `source`, sort))
        if not source:
            source = symbol
        # Avoid creating duplicate bindings.
        if self.newbindings.has_key(source):
            bindings = self.newbindings[source]
            while bindings:
                if bindings.symbol == symbol and bindings.value == value:
                    return
                bindings = bindings.link
        # Side-effect tracking.  Note we don't record side effects
        # unless the binding is actually modified.  Otherwise we'd get
        # a huge plethora of mostly redundant side effects on file loads.
        if value != symbol.eval():
            if source == None or source == symbol:
                side = ""
            else:
                side = self.lang["SIDEEFFECT"] % (`source`,)
            side = self.lang["SETTING"] % (symbol.name, value) + side
            if source and source != symbol and not suppress:
                self.side_effects.append(side)
            if symbol == self.trit_tie:
                if value == cml.n:
                    self.side_effects.append(self.lang["MODULESN"])
                elif value == cml.m:
                    self.side_effects.append(self.lang["MODULESM"])
                elif value == cml.y:
                    self.side_effects.append(self.lang["MODULESY"])
            # Debugging support
            if self.debug:
                self.debug_emit(1, "    " + side)
        # Here is the actual binding-stack hack
        newbinding = self.__Binding(symbol,value, self.newbindings.get(source))
        self.newbindings[source] = newbinding
        insertpoint = 0
        if sort != 0:
            # Hide new binding behind any binding with greater (or lesser)
            # value, according to the sort type.
            for i in range(len(symbol.bindingcache)):
                if cmp(symbol.bindingcache[i].value, value) == sort:
                    insertpoint = i + 1
                else:
                    break
        symbol.bindingcache.insert(insertpoint, newbinding)
        self.__bindmark(symbol)

    def __unbindsymbol(self, symbol, context):
        "Remove all bindings of a given symbol from a given context"
        listhead = context.get(symbol)
        if listhead:
            while listhead:
                listhead.symbol.bindingcache.remove(listhead)
                listhead = listhead.link
            del context[symbol]
            if symbol.menu.type == "choices":
                for sibling in symbol.menu.items:
                    if sibling.eval():
                        symbol.menu.menuvalue = sibling
                        break
    def __find_commit_set(self):
        "Find all symbols which need to have their old bindings removed"
        undo = []
        # When we undo side-effects from a choice symbol, all the side-effects
        # from setting its siblings have to be backed out too.
        for primary in self.newbindings.keys():
            if primary.menu.type == "choices":
                undo.extend(primary.menu.items)
            else:
                undo.append(primary)
        return undo
    def __bindcommit(self):
        "Commit all new bindings."
        # This is the magic moment that undoes side-effects
        for symbol in self.__find_commit_set():
            self.__unbindsymbol(symbol, self.oldbindings)
        self.oldbindings.update(self.newbindings)
        self.newbindings.clear()
        self.commits = self.commits + 1
    def __bindreveal(self, primary):
        "Make every old binding of symbol visible."
        bindings = self.oldbindings.get(primary)
        if bindings:
            listhead = bindings
            while listhead:
                listhead.visible = 1
                listhead = listhead.link
    def __bindconceal(self, primary):
        "Temporarily make old bindings hanging on a given primary invisible."
        bindings = self.oldbindings.get(primary)
        if bindings:
            listhead = bindings
            while listhead:
                listhead.visible = 0
                listhead = listhead.link
    def binddump(self, context=None):
        "Dump the state of the bindings stack."
        # Each line consists of a bound symbol and its side effects.
        # Most recent bindings are listed first.
        res = ""
        if context == None:
            context=self.oldbindings
        for (primary, bindings) in context.items():
            res = res + "# %s(%s, touched=%d): " % (primary.name,("inactive","active")[bindings.visible], primary in self.touched)
            while bindings:
                res = res + `bindings` + ", "
                bindings = bindings.link
            res = res[:-2] + "\n"
        return res

    #
    # Loading and saving
    #
    def loadcommit(self, freeze):
        "Attempt to commit the results of a file load."
        errors = ""
        violations = self.sanecheck()
        if not violations:
            self.__commit(freeze)
        else:
            errors += self.lang["UNLOAD1"]+"\n" + "\n".join(map(repr,violations)) + "\n"
            # This is an attempt to recover from inconsistent
            # configurations.  (Unusual case -- typically happens only
            # when a new constraint is added to a rulebase, not in the
            # more common case of new symbols.)  General recovery is
            # very hard, it involves constrained satisfaction problems
            # for which there are not just no good algorithms, there
            # are no clean definitions.  We settle for a simple,
            # stupid hack.  Force all the unfrozen symbols in the
            # violated constraints to n and see what happens.
            nukem = []
            self.debug_emit(1, self.lang["RECOVERY"])
            for i in range(len(self.constraints)):
                if not cml.evaluate(self.reduced[i], self.debug):
                    flattened = cml.flatten_expr(self.constraints[i].predicate)
                    for sym in flattened:
                        if not sym in nukem and not sym.frozen() and sym.is_logical():
                            nukem.append(sym)
            if nukem:
                errors += self.lang["RECOVERY"] + "\n"
                for sym in nukem:
                    errors += self.lang["INCONST"] % (sym.name,)
                    self.__set_symbol_internal(sym, cml.n)
                    self.chilled.clear()
                violations = self.sanecheck()
                if not violations:
                    self.__commit(freeze)
                    errors += self.lang["RECOVEROK"]
                else:
                    self.__rollback()
                    errors += self.lang["UNLOAD2"]+"\n" + "\n".join(map(repr, violations)) + "\n"
        return errors

    def load(self, file, freeze=0):
        "Load bindings from a defconfig-format configuration file."
        import shlex
        stream = shlex.shlex(open(file), file)
        stream.wordchars += "$"
        self.debug_emit(1, self.lang["READING"] % (file,))
        changes = 0
        errors = ""
        stash = self.interactive
        self.interactive = 0
        self.side_effects = []	# Not needed if we're using set_symbol below 
        while 1:
            dobind = 1
            symname = stream.get_token()
            if not symname:
                break
            # Parse directives
            if symname == "$$commit":
                self.loadcommit(0)
                changes = 0
                continue
            elif symname == "$$freeze":
                self.loadcommit(1)
                changes = 0
                continue
            # Now parse ordinary symbol sets
            if len(self.prefix) and symname[0:len(self.prefix)] == self.prefix:
                symname = symname[len(self.prefix):]
            if self.dictionary.has_key(symname):
                symbol = self.dictionary[symname]
            else:
                symbol = None
                errmsg = stream.error_leader()+self.lang["BADTOKEN"]%(symname)
                errors = errors + errmsg + "\n"
                dobind = 0

            sep = stream.get_token()
            if sep != '=':
                errmsg = stream.error_leader()+self.lang["BADEQUALS"]%(sep,)
                errors = errors + errmsg + "\n"
                dobind = 0
            value = stream.get_token()

            # Do this check early to avoid Python errors if the file
            # is malformed.
            if not dobind:
                continue
            
            if value[0] in stream.quotes:
                value = value[1:-1]

            if not symbol:
                continue
            # We can't permit these files to override derivations
            if symbol.is_derived():
                self.debug_emit(2, stream.error_leader()+self.lang["DERIVED"]%(symbol.name,))
                continue

            # Michael Chastain's case -- treat variable as new if
            # value is m but the type has been changed to bool
            if value == 'm' and symbol.type == "bool":
                errmsg = stream.error_leader()+self.lang["BADTRIT"]%(symbol.name,)
                errors = errors + errmsg + "\n"
                continue

            # Note that we've seen this in an inclusion -- it's not new.
            symbol.included = 1

            # If we load a configuration with trit values,
            # force those to be enabled.
            if symbol.type == "trit" and value == "m":
                self.trits_enabled = 1

            # Don't count changes to variables that are already set at the
            # desired value.  Do them, though, so they can be frozen.
            oldval = symbol.eval()
            # Use this for consistency checking by file
            newval = self.value_from_string(symbol,value)
            self.__set_symbol_internal(symbol,
                                       newval)
            self.chilled.clear()
            if newval != oldval:
                changes = changes + 1

        stream.instream.close()
        if changes:
            errors += self.loadcommit(freeze)
        self.inclusions.append(file)
        self.interactive = stash
        return (changes, errors)

    def saveable(self, node, mode="normal"):
        "Should this symbol be visible in the configuration written out?"
        # Fix for loaded symbols from old configuration being written back without visibility check.
        if node.setcount > 0 and self.is_visible(node):
            return 1
        if node.is_derived() and (not node.visibility or cml.evaluate(node.visibility)):
            return 1
        if node.saveability:
            return cml.evaluate(node.saveability)
        if mode == "probe":
            return 0
        if not self.is_visible(node):
            return 0
        return 1

    def save(self, outfile=sys.stdout, baton=None, mode="normal"):
        "Save a configuration to the named output stream or file."
        #print "save(outfile=%s, baton=%s, mode=%s)" % (outfile, baton, mode)
        newbindings = None
        if self.newbindings:
            newbindings = self.newbindings
            self.newbindings = {}
        try:
            if type(outfile) == type(""):
                shelltemp = ".tmpconfig%d.sh" % os.getpid()
                outfp = open(shelltemp, "w")
                outfp.write(self.lang["SHAUTOGEN"])
            else:
                outfp = outfile
            # Write an informative header so we can identify this file.
            if mode != "list":
                try:
                    from time import gmtime, strftime
                    import socket
                    outfp.write("# Generated on: "+socket.gethostname()+"\n")
                    outfp.write("# At: " + strftime("%a, %d %b %Y %H:%M:%S +0000", gmtime()) + "\n")
                    infp = open("/proc/version", "r")
                    outfp.write("# " + infp.read())
                    infp.close()
                except:
                    pass
            # Write mutable symbols, including defaulted modular symbols.
            self.__save_recurse(self.start, outfp, baton, mode)
            # Write all derived symbols
            if mode != "list":
                if filter(lambda x: x.is_derived(), self.dictionary.values()):
                    outfp.write(self.lang["SHDERIVED"])
                for entry in self.dictionary.values():
                    if entry.is_derived():
                        if baton:
                            baton.twirl()
                        self.__save_recurse(entry, outfp, baton, mode)
            # Perhaps this is a crash dump from an inconsistent ruleset?
            if newbindings:
                self.newbindings = newbindings
                outfp.write(self.lang["UNCOMMIT"])
                outfp.write(self.binddump(self.newbindings))
            if mode == "normal":
                outfp.write(self.lang["SAVEEND"])
            if type(outfile) == type(""):
                outfp.close()
                try:
                    os.rename(shelltemp, outfile)
                except OSError:
                    reason  = self.lang["RENAME"] % (shelltemp, outfile,)
                    raise IOError, reason
            self.commits = 0
            if baton:
                baton.end()
            return None
        except IOError, details:
            return details.args[0]

    def save_symbol(self, symbol, shellstream, label=""):
        symname = self.prefix + symbol.name
        value = symbol.eval(self.debug)
        self.debug_emit(2, self.lang["ABOUT"] %(symname,value,type(value)))
        try:
            if symbol.type == "decimal":
                shellstream.write("%s=%d" % (symname, value))
            elif symbol.type == "hexadecimal":
                shellstream.write("%s=0x%x" % (symname, value))
            elif symbol.type == "string":
                shellstream.write("%s=\"%s\"" % (symname, value))
            elif symbol.type in ("bool", "trit"):
                shellstream.write("%s=%s" % (symname, `value`))
            elif value == None and symbol.is_logical():
                shellstream.write("%s=n" % (symname,))
            else:
                raise ValueError, self.lang["VALUNKNOWN"] % (symbol,symbol.type,value)
            if label:
                shellstream.write("\t# " + label)
            shellstream.write("\n")
        except:
            (errtype, errval, errtrace) = sys.exc_info()
            print "Internal error %s while writing %s." % (errtype, symbol)
            raise SystemExit, 1

    def __save_recurse(self, node, shellstream, baton=None, mode="normal"):
        saveable = self.saveable(node, mode)
        if not saveable:
            self.debug_emit(2, self.lang["UNSAVEABLE"] % node.name)
            return
        elif node.items:
            shellstream.write("\n#\n# %s\n#\n" % (node.prompt,))
            # In case this is a choice menu not previously visited.
            self.visit(node)
            for child in node.items:
                self.__save_recurse(child, shellstream, baton, mode)
            shellstream.write("\n")
        elif node.type != 'message':
            label = ""
            if node.properties:
                label += node.showprops()
            if node.properties and mode=="list" and not saveable:
                label += " "
            if mode == "list" and not saveable:
                label += self.lang["NOTSAVED"]
            self.save_symbol(node, shellstream, label)
        if baton:
            baton.twirl()

    # Symbol predicates.

    def is_mutable(self, symbol):
        "Is a term mutable (symbol, not frozen)?"
        return isinstance(symbol, cml.ConfigSymbol) and not symbol.frozen()

    def is_visible(self, query):
        "Should we ask this question?"
        self.debug_emit(2, self.lang["INVISSTART"] % (query.name,))
        # Maybe we're not doing elisions
        if not self.suppressions:
            return 1
        # Maybe it has no help.
        if not self.__help_visible(query):
            self.debug_emit(2, self.lang["INVISHELP"] % (query.name,))
            return 0
        # Check to see if the symbol or any menu in the chain above it
        # is suppressed by a visibility constraint or ancestry.
        if not self.__upward_visible(query):
            self.debug_emit(2, self.lang["INVISUP"] % (query.name,))
            return 0
        # Elide a message if everything between it and the next message
        # is invisible.
        if query.type == "message":
            for i in range(query.menu.items.index(query)+1, len(query.menu.items)):
                if query.menu.items[i].type == "message":
                    break
                elif self.is_visible(query.menu.items[i]):
                    return 1
            return 0
        # Elide a menu if all subqueries are invisible, or a choices if one is.
        if not self.__subqueries_visible(query):
            return 0
        # All tests passed, it's visible
        self.debug_emit(2, self.lang["VISIBLE"] % (query.name))
        return 1

    def is_visible_menus_choices(self, query):
        # Maybe we're not doing elisions
        if not self.suppressions:
            return 1
        # Maybe it has no help.
        if not self.__help_visible(query):
            return 0
        # OK, now check that all ancestors are visible.   
        if not self.__dep_visible(query):
            return 0
        # Elide a menu if all subqueries are invisible, or a choices if one is.
        if not self.__subqueries_visible(query):
            return 0
        # All tests passed, it's visible
        return 1
    #
    # All the properties of visibility are implemented here
    #
    def __help_visible(self, query):
        if query.is_symbol() and not query.help() and self.help_tie and not self.help_tie.eval():
            self.debug_emit(2, self.lang["NOHELP"] % query.name)
            return 0
        return 1

    def __upward_visible(self, query):
        upward = query
        while upward != self.start:
            if upward.visibility != None and not cml.evaluate(upward.visibility):
                self.debug_emit(2, self.lang["INVISME"] % (query.name, upward.name, cml.display_expression(upward.visibility)))
                return 0
            elif not self.__dep_visible(upward):
                return 0
            upward = upward.menu
        return 1

    def __subqueries_visible(self, query):
        if query.items:
            setcount = 0
            if query.type == 'menu' or query.type == 'choices':
                for child in query.items:
                    if child.type != "message":
                        if self.is_visible_menus_choices(child):
                            setcount = 1
                            break
                if setcount == 0:
                    return 0
        return 1

    #
    # All the properties of the dependency relationship are implemented here
    #
    def __dep_value_ok(self, symbol, value):
        "Do ancestry relationships allow given value of given symbol"
        for ancestor in symbol.ancestors:
            v = cml.evaluate(ancestor, self.debug)
            if (symbol.type == "trit" and value > v):
                break
            elif (symbol.type =="bool" and value > (v != cml.n)):
                break
        else:
            return 1	# Tricky use of for-else
        self.debug_emit(2, self.lang["EXCLUDED"] % (`symbol`, `cml.trit(value)`, `ancestor`))
        return 0

    def __dep_visible(self, symbol):
        "Do ancestry relations allow a symbol to be visible?"
        # Note: we don't need to recurse here, assuming dependencies
        # get propagated correctly.
        for super in symbol.ancestors:
            if not cml.evaluate(super):
                self.debug_emit(2,self.lang["INVISANC"]%(symbol.name,super.name))
                return 0
            elif super.visibility and not cml.evaluate(super.visibility):
                self.debug_emit(2,self.lang["INVISANC2"]%(symbol.name,super.name))
                return 0
        return 1

    def __dep_force_ancestors(self, dependent, source, dependvalue, ancestor):
        "Force a symbol's ancestors up, based on the symbol's value."
        self.debug_emit(2, "    dep_force_ancestors(%s, %s, %s, %s)" % (`dependent`, `source`, `dependvalue`, `ancestor`))
        if dependent.is_logical() and ancestor.is_logical():
            anctype = ancestor.type
            if dependvalue > cml.n:
                if dependent.type == anctype:
                    newval = dependvalue
                elif not self.trits_enabled:
                    newval = cml.y;
                elif anctype == "bool":	# dependent is trit
                    newval = cml.y;
                elif anctype == "trit":	# dependent is bool
                    newval = cml.m;
                else:
                    newval = dependvalue
                self.__set_symbol_internal(ancestor, newval, source, sort=1)

        # Recurse upwards, first through ancestors... 
        for upper in ancestor.ancestors:
            self.__dep_force_ancestors(dependent, source, dependvalue, upper)
        # ...and then through the containing menu.
        for upper in ancestor.menu.ancestors:
            self.__dep_force_ancestors(dependent, source, dependvalue, upper)

    def __dep_force_dependents(self, guard, source, guardvalue, dependent):
        "Force a symbol's descendents down, based on the symbol's value."
        self.debug_emit(2, "    dep_force_dependents(%s, %s, %s, %s)" % (`guard`, `source`, `guardvalue`, `dependent`))
        if guard.is_logical() and dependent.is_logical():
            deptype = dependent.type
            depvalue = cml.evaluate(dependent)
            if guardvalue < depvalue:
                if guard.type == deptype:
                    newval = guardvalue
                elif not self.trits_enabled:
                    newval = cml.n
                elif deptype == "trit":		# Ancestor is bool
                    newval = guardvalue
                elif guardvalue == cml.n:	# Ancestor is trit
                    newval = guardvalue
                else:
                    newval = depvalue		# No change
                self.__set_symbol_internal(dependent, newval, source, sort=-1)
        # Recurse downwards...
        if dependent.items:
            for child in dependent.items:
                self.__dep_force_dependents(guard, source, guardvalue, child)
        else:
            for lower in dependent.dependents:
                self.__dep_force_dependents(guard, source, guardvalue, lower)

    #
    # The following methods handle variable bindings
    #
    def __rollback(self):
        "Roll back all new bindings."
        self.debug_emit(1, self.lang["ROLLBACK"] + `self.touched`)
        self.touched = []
        for symbol in self.newbindings.keys():
            self.__unbindsymbol(symbol, self.newbindings)
        self.side_effects = []

    def __commit(self, freeze=0, baton=None):
        "Commit all new bindings."
        if freeze:
            self.debug_emit(1, self.lang["COMMIT"] + self.lang["FROZEN"])
        else:
            self.debug_emit(1, self.lang["COMMIT"])
            if self.trit_tie and self.trit_tie in self.touched:
                self.trits_enabled = cml.evaluate(self.trit_tie)
                self.debug_emit(1, self.lang["TRITFLAG"] % (`cml.trit(self.trits_enabled)`,))
            if self.help_tie and self.help_tie in self.touched:
                self.debug_emit(1, self.lang["HELPFLAG"] % self.help_tie.eval())
        for entry in self.touched:
            if freeze:
                entry.freeze()
        self.touched = []
        if baton:
            baton.twirl("#")
        if freeze:
            # Optimization hack -- undo this if variables can ever be unfrozen.
            # In the meantime, this greatly reduces the amount of expression
            # evaluation needed after variables have been frozen.
            for i in range(len(self.reduced)):
                simplified = self.eval_frozen(self.reduced[i])
                if simplified != None:
                    self.reduced[i] = simplified
            self.optimize_constraint_access()
            if baton:
                baton.twirl("#")
        # Must do this *after* checking freezes
        self.__bindcommit()		# The magic moment
        if baton:
            baton.end()

    def sanecheck(self):
        "Sanity-check a configuration and report on its side effects."
        violations = self.changes_to_frozen
        for i in range(len(self.constraints)):
            if not cml.evaluate(self.reduced[i], self.debug):
                violations.append(self.constraints[i]);
                self.debug_emit(1, self.lang["FAILREQ"]%(self.constraints[i],))
        return violations

    def set_symbol(self, symbol, value, freeze=0):
        "Bind a symbol, tracking side effects."
        self.debug_emit(1, self.lang["USERSETTING"] % (symbol.name,))
        self.side_effects = []
        self.changes_to_frozen = []
        self.__set_symbol_internal(symbol, value)
        self.chilled.clear()
        self.cdepth = 0
        # conceal all the bindings a commit would remove
        # this way, the sane check is checking the final
        # configuration
        commit_set = self.__find_commit_set()
        for symbol in commit_set:
            self.__bindconceal(symbol)
        violations = self.sanecheck()
        if not violations:
            self.__commit(freeze)
            return (1, self.side_effects, [])
        else:
            # make the bindings visible before a rollback
            for symbol in commit_set:
                self.__bindreveal(symbol)
            effects = self.side_effects
            self.__rollback()		# This will clear self.side_effects
            return (0, effects, violations)

    def __set_symbol_internal(self, symbol, value, source=None, sort=0):
        "Recursively bind a symbol, with side effects."
        self.debug_emit(2, "    %sset_symbol_internal(%s, %s, %s, %s)" % (' ' * self.cdepth, symbol.name, value, `source`, sort))
        self.cdepth += 1
        if not source:
            source = symbol
        # The "touched" property marks this symbol changed for freeze purposes.
        # It has to stay on until the next commit.
        self.touched.append(symbol)
        # If it already has the desired value, we're done.
        oldval = cml.evaluate(symbol, self.debug)
        self.debug_emit(2, self.lang["OLDVAL"] % (' '*self.cdepth, symbol.name, oldval))
        if oldval == value:
            self.debug_emit(1, self.lang["UNCHANGED"] % (' '*self.cdepth, symbol.name,))
            # However, mark it set anyway.  This is useful for
            # distinguishing value by default from value by user action.
            self.__bindmark(symbol)
            # If this was a user setting or a frozen symbol.
            # Not actually going through the motions for a frozen
            # symbol is a speed hack.  We know the symbol can't change
            # so there's no reason to keep its binding cache full...
            if symbol == source or symbol.frozen():
                self.cdepth -= 1
                return
        elif symbol.frozen():
            # It's a violation if someone tries to raise the value of a symbol.
            # Log the violation so sanecheck() will cause a rollback
            if value > oldval:
                self.changes_to_frozen.append(  \
                   self.lang["SETFAILED"] % (' '*self.cdepth, symbol.name))
            self.cdepth -= 1
            return
        # Barf on attempt to change the value of a changed value --
        # but only if the attempt comes from a different source,
        # because ancestry forcing will often result in the same symbol
        # being changed multiple times in succession from the same source.
        if self.chilled.has_key(symbol) and self.chilled[symbol] != source:
            self.__bindsymbol(symbol, value, source)	# record for debugging
            raise "UNSATISFIABLE"
        # Membership in chilled means we should treat the binding as frozen for
        # simplification purposes.  It has to be turned off when the current
        # call to set_symbol is done; otherwise side effects from inclusion
        # sequences would collide with each other.
        self.chilled[symbol] = source
        # Here's where the value actually gets set
        self.__bindsymbol(symbol, value, source, sort)
        # Make the side-effects of this symbol's previous bindings
        # temporarily invisible while computing side effects.  This
        # is necessary because things like dependent suppressions
        # need to be calculated according to the effects they would
        # have when the old bindings are removed, as they will be
        # if this change is committed (whew!)
        self.__bindconceal(symbol)
        # If this symbol was in a choice group and is being set true,
        # note this in the menu state
        if symbol.menu and symbol.menu.type == "choices" and value:
            symbol.menu.visits += 1
            symbol.menu.menuvalue = symbol
        # Unset all siblings if we're setting one to a non-n value.
        if value:
            for sibling in symbol.choicegroup:
                self.__set_symbol_internal(sibling, cml.n, source)
        # Other side effects...
        if self.trit_tie and symbol == self.trit_tie and value == cml.n:
            for entry in self.dictionary.values():
                if entry.type == "trit" and not entry.is_derived() and entry.eval() == cml.m:
                    self.__set_symbol_internal(entry, cml.y, source)
        # Now propagate the value change through ancestry chains.
        # Checking the 'sort' argument prevents nasty recursions
        # by suppressing dependent setting if we're setting an
        # ancestor, and vice-versa.
        if symbol.is_logical():
            if value > cml.n and sort != -1:
                for ancestor in symbol.ancestors + symbol.menu.ancestors:
                    self.__dep_force_ancestors(symbol, source, value, ancestor)
            if value < cml.y and sort != 1:
                for dependent in symbol.dependents:
                    self.__dep_force_dependents(symbol,source,value,dependent)
        # Perhaps we can deduce other values through explicit constraints?
        # This is where we'd plug in a full SAT algorithm if we were going
        # to use one.
        if self.interactive and not self.suppressions and symbol.visibility:
            self.__constrain(symbol.visibility, source)
        # Now loop through the constraints associated with this
        # symbol, simplifying out assigned variables and trying to
        # freeze more variables each time.  The outer loop guarantees
        # that as long as the constraints imply at least one more
        # tentative setting, we'll keep going.
        while 1:
            cc = 0
            for wff in symbol.constraints:
                cc += self.__constrain(wff, source)
            if not cc:
                break;
        # OK, now make the old bindings of this symbol visible again
        # (the change we just made might get rolled back later).
        self.__bindreveal(symbol)
        self.cdepth -= 1

    def value_from_string(self, sym, val):
        "Set symbol from string according to the symbol type."
        if sym.is_logical():
            if val == "y":
                val = cml.y
            elif val == "m":
                val = cml.m
            elif val == "n":
                val = cml.n
        elif sym.type == "decimal":
            val = int(val)
        elif sym.type == "hexadecimal":
            val = long(val, 16)
        return val

    def eval_frozen(self, wff):
        "Test whether a given expr is entirely constant, chilled or frozen."
        if isinstance(wff,cml.trit) or type(wff) in (type(0),type(0L),type("")):
            return wff
        elif isinstance(wff, cml.ConfigSymbol):
            if wff.frozen() or self.chilled.has_key(wff):
                return wff.eval()
            elif wff.is_derived():
                return self.eval_frozen(wff.default)
            else:
                return None
        elif wff[0] == 'not':
            below = self.eval_frozen(wff[1])
            if below == None:
                return None
            else:
                return cml.trit(not below)
        elif wff[0] == '?':
            guard = self.eval_frozen(wff[1])
            if guard == None:
                return None
            if guard:
                return self.eval_frozen(wff[2])
            else:
                return self.eval_frozen(wff[3])
        else:
            left = self.eval_frozen(wff[1])
            right = self.eval_frozen(wff[2])
            if left != None and right != None:
                return cml.evaluate((wff[0], left, right))
            elif left == None and right == None:
                return None
            # OK, now the grotty part starts
            elif wff[0] == 'and':
                if left == cml.n or right == cml.n:
                    return cml.n
                elif left in (cml.y, cml.m):
                    return right
                elif right in (cml.y, cml.m):
                    return left
                else:
                    return None
            elif wff[0] == 'or':
                if left in (cml.y, cml.m) or right in (cml.y, cml.m):
                    return cml.y
                elif left == cml.n:
                    return right
                elif right == cml.n:
                    return left
                else:
                    return None
            elif wff[0] == 'implies':
                if left in (cml.y, cml.m):
                    return right
                elif left == cml.n:
                    return cml.y
                elif right == cml.n:
                    return not left
                else:
                    return None
            else:
                return None

    def __constrain(self, wff, source, fixedval=cml.y):
        "Set symbols based on asserted equalities or inequalities."
        self.debug_emit(2, self.lang["BINDING"] % (self.cdepth*' ', cml.display_expression(wff), fixedval, `source`))
        self.cdepth += 1
        ret = self.__inner_constrain(wff, source, fixedval)
        self.cdepth -= 1
        return ret
 
    def __inner_constrain(self, wff, source, fixedval=cml.y):
        if isinstance(wff, cml.ConfigSymbol):
            if wff.is_derived():
                return self.__constrain(wff.default, source, fixedval)
            else:
                oldval = cml.evaluate(wff, self.debug)
                if oldval == fixedval:
                    self.__bindsymbol(wff, fixedval, source)
                    self.debug_emit(2, self.lang["REDUNDANT"] % (' '*self.cdepth,wff.name,))
                    return 0
                else:
                    self.__set_symbol_internal(wff, fixedval, source)
                    return 1
        op = wff[0]
        left = wff[1]
        right = wff[2]
        if op == '?':
            guard = cml.evaluate(left)
            if guard == None:
                return 0
            elif guard:
                return self.__constrain(right, source, fixedval)
            else:
                return self.__constrain(wff[3], source, fixedval)
        elif fixedval == cml.y and op == 'implies':
            if cml.evaluate(left):
                return self.__constrain(right, source, fixedval)
            else:
                return 0
        elif fixedval == cml.y and op == 'and':
            return self.__constrain(left, source, fixedval) + \
                   self.__constrain(right, source, fixedval)
        elif fixedval == cml.n and op == 'or':
            return self.__constrain(left, source, fixedval) + \
                   self.__constrain(right, source, fixedval)
        elif op in CMLSystem.relational_map.keys() \
             and (isinstance(left, cml.trit) or (isinstance(left, cml.ConfigSymbol) and left.is_logical())) \
             and (isinstance(right, cml.trit) or (isinstance(right, cml.ConfigSymbol) and right.is_logical())):
            if fixedval == cml.n:
                op = CMLSystem.relational_map[op]
            # Before we can force a binding, we need exactly one operand
            # to be mutable...
            left_mutable = self.is_mutable(left)
            right_mutable = self.is_mutable(right)
            if left_mutable == right_mutable:
                self.debug_emit(3, "0 or 2 mutables in %s, %s" % (left, right)) 
                return 0
            leftval = cml.evaluate(left)
            rightval = cml.evaluate(right)
            # Now we may have the conditions to force a binding.
            # The bindsymbols in the `redundant' assignments are needed
            # in order to make the backout logic work when a binding is unset.
            if op == '==':
                if left_mutable:
                    return self.__constrain(left, source, rightval)
                elif right_mutable:
                    return self.__constrain(right, source, leftval)
            elif op == '!=':
                if left.type == "bool" and right.type == "bool":
                    if left_mutable:
                        return self.__constrain(left, source, not rightval)
                    elif right_mutable and right.type == "bool":
                        return self.__constrain(right, source, not leftval)
            elif op == '<':
                if leftval < rightval:
                    return 0
                elif left_mutable:
                    return self.__constrain(left, source,
                                            trit(max(0, rightval.value-1)))
                elif right_mutable: 
                    return self.__constrain(right, source,
                                            trit(min(2, leftval.value+1)))
            elif op == '<=':
                if leftval <= rightval:
                    return 0
                elif left_mutable:
                    return self.__constrain(left, source, rightval)
                elif right_mutable: 
                    return self.__constrain(right, source, leftval)
            elif op == '>':
                if leftval > rightval:
                    return 0
                elif left_mutable:
                    return self.__constrain(left, source,
                                            trit(min(2, rightval.value+1)))
                elif right_mutable: 
                    return self.__constrain(right, source,
                                            trit(max(0, leftval.value-1)))
            elif op == '>=':
                if leftval >= rightval:
                    return 0
                elif left_mutable:
                    return self.__constrain(left, source, rightval)
                elif right_mutable: 
                    return self.__constrain(right, source, leftval)
        return 0

    #
    # Navigation helpers 
    #

    def visit(self, entry):
        "Register the fact that we've visited a menu."
        if not entry.menu or not self.is_visible(entry):
            return
        self.debug_emit(2,"Visiting %s (%s) starts" % (entry.name, entry.type))
        entry.visits = entry.visits + 1
        # Set choices defaults -- do it now for the side-effects
        # (If you do it sooner you can get weird constraint failures)
        if entry.visits==1 and entry.type=="choices" and not entry.frozen():
            base = ind = entry.items.index(entry.default)
            try:
                # Starting from the declared default, or the implicit default
                # of first item, seek forward until we find something visible.
                while not self.is_visible(entry.items[ind]):
                    ind += 1
            except IndexError:
                # Kluge -- if we find no visible items, turn off suppressions
                # and drop back to the original default.
                self.debug_emit(1, self.lang["NOVISIBLE"] % (`entry`,))
                ind = base
                self.suppressions = 0
            self.set_symbol(entry.items[ind], cml.y)
        self.debug_emit(2, "Visiting %s (%s) ends" % (entry.name,entry.type))

    def next_node(self, here):
        "Return the next menu or symbol in depth-first order."
        if here.type == 'menu' and not here.default:
            here = here.items[0];
        else:
            while here.menu:
                up = here.menu
                where = up.items.index(here)
                if where >= len(here.menu.items) - 1:
                    here = up
                else:
                    here = up.items[where+1]
                    break
        if here == None:
            here = self.start
        return here

    def previous_node(self, here):
        "Return the previous menu or symbol in depth-first order."
        if here.type == 'menu' and not here.default:
            here = here.items[0];
        else:
            while here.menu:
                up = here.menu
                where = up.items.index(here)
                if where == 0:
                    here = up
                else:
                    here = up.items[where-1]
                    break
        if here == None:
            here = self.start
        return here

    def search(self, pattern, hook):
        "Return a menu composed of symbols matching a given regexp."
        regexp = re.compile(pattern)
        hits = cml.ConfigSymbol("search", "menu")
        for entry in self.dictionary.values():
            if entry.prompt and entry.type != "message":
                text = hook(entry)
                if text == None:
                    continue
                elif regexp.search(text):
                    hits.items.append(entry)
        # Give the result menu a parent only if all members have same parent
        hits.menu = None
        for symbol in hits.items:
            if hits.menu == None:
                hits.menu = symbol.menu
            elif symbol.menu != hits.menu:
                hits.menu = None
                break
        # Sort the results for a nice look
        hits.items.sort()
        hits.nosuppressions = 1
        return hits

    def symbolsearch(self, pattern):
        "Return a menu composed of symbols matching a given regexp."
        return self.search(pattern, lambda x: x.name + x.prompt)

    def helpsearch(self, pattern):
        "Return a menu composed of symbols matching a given regexp."
        return self.search(pattern, lambda x: x.help())

    # Input validation

    def range_check(self, symbol, value):
        "Check whether a value is within a symbol's specified valid range."
        if not symbol.range:
            return 1
        elif symbol.enum:
            for (label, possibility) in symbol.range:
                if value == possibility:
                    return 1
        else:
            for span in symbol.range:
                if type(span) in (type(0), type(0L)):
                    if value == span:
                        return 1
                elif value >= span[0] and value <= span[1]:
                    return 1
        return 0

# End
