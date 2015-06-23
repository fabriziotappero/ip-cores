#!/usr/bin/env python
"""
Compiler for CML2

by Eric S. Raymond, <esr@thyrsus.com>
"""
import sys

if sys.version[0] < '2':
    print "Python 2.0 or later is required for this program."
    sys.exit(0)

import string, os, getopt, shlex, cPickle, cml, cStringIO

# Globals
rulebase = None
compstate = None

# User-visible strings. Separated out in order to
# support internationalization.

_eng = {
    "CLIHELP":"""\

Usage: clmlcompile.py [-o output] [-P] [-v]

-o file   write the result to a specified file
-P        enable profiling
-v        increment debug level

""",
}

# Eventually, do more intelligent selection using LOCALE
lang = _eng

class CompilationState:
    def __init__(self):
        self.debug = 0
        self.errors = 0
        self.bad_symbols = {}
        self.bool_tests = []
        self.warndepend = []
        self.explicit_ancestors = {}
        self.derivations = {}
        self.propnames = {}
        self.dfltsyms = []
        # Used by the menu-declaration parser
        self.condition_stack = []	# Stack of active conditions for {} shorthand
        self.property_stack = []	# Stack of property switches
        self.symbol_list = []		# Result list

# Lexical analysis
_keywords = (
    'alias',		'banner',	'choices',	'choicegroup',
    'condition',	'debug',	'default',	'dependent',
    'derive',		'enum',		'expert',	'explanation',
    'give',		'icon',		'like',		'menu',
    'nohelp',		'on',		'prefix',	'prohibit',
    'property',		'range',	'require',	'save',
    'start',		'suppress',	'symbols',	'text',
    'trits',		'unless',	'warndepend',	'when',
    )
_ternaryops = ('?', ':')
_arithops = ('*', '+', '-')
_boolops = ('and', 'or', 'implies')
_relops = ('==', '!=', '<', '>', '>=', '<=') 
_termops = ('|', '&', '$')		# min, max, similarity
_operators = _termops + _relops + _boolops + _arithops + _ternaryops + ("(", ")")
_tritvals = ("n", "m", "y")
_atoms = ("trit", "string", "decimal", "hexadecimal")
#_suffixes = ("&", "?", "%", "@", "$")

class Token:
    "CML2's internal token type."
    def __init__(self, type, attr=None):
	self.type = type
	self.attr = attr
	if compstate.debug > 1: print "CML token: ", `self`
    def __repr__(self):
        if self.type == "EOF":
            return "EOF"
        elif self.attr is not None:
            return self.type + "=" + `self.attr`
        else:
            return self.type
    def __cmp__(self, other):
        if isinstance(other, Token):
            typecmp = cmp(self.type, other.type)
            if typecmp or not self.attr:
                return typecmp
            else:
                return cmp(self.attr, other.attr)
        else:
            return cmp(self.type, other)
    def __getitem__(self, i):
        raise IndexError

class lexwrapper(shlex.shlex):
    "Lexer subclass that returns Tokens with type-annotation information."
    def __init__(self, stream, endtok=None):
        self.endtok = endtok
        # Strictly a speed hack.
        name = stream.name
	if endtok:
            contents = stream
        else:
            contents = cStringIO.StringIO(stream.read())
            stream.close()
	shlex.shlex.__init__(self, contents, name)

    def lex_token(self):
	# Get a (type, attr) token tuple, handling inclusion  
	raw = self.get_token()
	if type(raw) is not type(""):	# Pushed-back token
	    return raw
	elif not raw or raw == self.endtok:
	    return Token("EOF")
	elif raw[0] in self.quotes:
	    return Token('string', raw[1:-1])
	elif raw in _tritvals:
	    return Token('trit', raw)
	elif len(raw) > 2 and \
		raw[0] == '0' and raw[1] == 'x' and raw[2] in string.hexdigits:
            return Token('hexadecimal', long(raw[2:], 16))
	elif raw[0] in string.digits:
	    return Token('decimal', int(raw))
	elif raw in ('!', '=', '<', '>'):	# Relational tests
	    next = self.get_token()
	    if next == '=':
		return Token(raw+next)
	    else:
		self.push_token(next)
		return Token(raw)
        elif raw == 'text':
            data = ""
            while 1:
                line = self.instream.readline()
                if line == "" or line == ".\n":	# Terminated by dot.
                    break
                if line[0] == '.':
                    line = line[1:]
                data = data + line
            return Token("text", data)
        elif raw == 'icon':
            data = ""
            while 1:
                line = self.instream.readline()
                if line == "" or line == "\n":	# Terminated by blank line
                    break
                data = data + line
            self.push_token(data)
            return Token(raw)
	elif raw in _keywords or raw in _operators:
	    return Token(raw)
        elif compstate.propnames.has_key(raw):
            return Token('property', raw)
	else:
            # Nasty hack alert.  If there is a declared prefix for the
            # rulebase, ignore it as a prefix of names.  This will
            # enable us to be backward-compatible with names like like
            # CONFIG_3C515 that have leading numerics when stripped.
            if rulebase.prefix and raw[:len(rulebase.prefix)] == rulebase.prefix:
                raw = raw[len(rulebase.prefix):]
	    return Token('word', raw)

    def complain(self, str):
	# Report non-fatal parse error; format like C compiler message.
        if not compstate.debug and not compstate.errors:
            sys.stderr.write('\n')
	sys.stderr.write(self.error_leader() + " " + str + "\n")
	compstate.errors = compstate.errors + 1

    def croak(self, str):
	# Report a fatal parse error and die
	self.complain(str)
	sys.exit(1)

    def demand(self, type, attr=None):
	# Require a given token or token type, croak if we don't get it 
	tok = self.lex_token()
	if tok.type == "EOF":
	    self.croak("premature EOF")
	elif attr is not None and tok.attr != attr:
	    self.croak("syntax error, saw `%s' while expecting `%s'" % (tok, attr))
	elif tok.type != type:
	    self.croak("syntax error, expecting token of type `%s' (actually saw %s=%s)" % (type, tok.type, tok.attr))
	else:
	    return tok.attr

    def sourcehook(self, newfile):
	# Override the hook in the shlex class
	try:
	    if newfile[0] == '"':
		newfile = newfile[1:-1]
                # This implements cpp-like semantics for relative-path inclusion.
                if type(self.infile) is type("") and not os.path.isabs(newfile):
                    newfile = os.path.join(os.path.dirname(self.infile), newfile)
	    return (newfile, open(newfile, "r"))
	except IOError:
	    self.complain("I/O error while opening '%s'" % (newfile,))
	    sys.exit(1)
        return None	# Appease pychecker

# Parsing

class ExpressionError:
    "Express a compile-time error."
    def __init__(self, explain):
        self.args = ("expression error " + explain,)

def parse_atom(input):
    if compstate.debug >= 2: print "entering parse_atom..."
    op = input.lex_token()
    if op.type in _atoms:
        if compstate.debug >= 2: print "parse_atom returns", op.attr
        return op
    elif op.type == '(':
        sub = parse_expr_inner(input)
        close = input.lex_token()
        if close != ')':
            raise ExpressionError, "while expecting a close paren"
        else:
            if compstate.debug >= 2: print "parse_atom returns singleton", sub
            return sub
    elif op.type in _keywords:
        raise ExpressionError, "keyword %s while expecting atom" % op.type
    elif op.type == 'word':
        if compstate.debug >= 2: print "parse_atom returns", op.attr
        return op

def parse_term(input):
    if compstate.debug >= 2: print "entering parse_term..."
    left = parse_atom(input)
    op = input.lex_token()
    if op.type not in _termops:
        input.push_token(op)
        if compstate.debug >= 2: print "parse_term returns singleton", left
        return left
    right = parse_term(input)
    expr = (op.type, left, right)
    if compstate.debug >= 2: print "parse_term returns", expr
    return expr

def parse_relational(input):
    if compstate.debug >= 2: print "entering parse_relational..."
    left = parse_term(input)
    op = input.lex_token()
    if op.type not in _relops:
        input.push_token(op)
        if compstate.debug >= 2: print "parse_relational returns singleton", left
        return left
    right = parse_term(input)
    expr = (op.type, left, right)
    if compstate.debug >= 2: print "parse_relational returns", expr
    return(op.type, left, right)

def parse_assertion(input):
    if compstate.debug >= 2: print "entering parse_assertion..."
    negate = input.lex_token()
    if negate.type == 'not':
        return ('not', parse_relational(input))
    input.push_token(negate)
    return parse_relational(input)

def parse_conjunct(input):
    if compstate.debug >= 2: print "entering parse_conjunct..."
    left = parse_assertion(input)
    op = input.lex_token()
    if op.type !=  'and': 
        input.push_token(op)
        if compstate.debug >= 2: print "parse_conjunct returns singleton", left
        return left
    else:
        expr = ('and', left, parse_conjunct(input))
        if compstate.debug >= 2: print "parse_conjunct returns", expr
        return expr

def parse_disjunct(input):
    if compstate.debug >= 2: print "entering parse_disjunct..."
    left = parse_conjunct(input)
    op = input.lex_token()
    if op.type != 'or':
        input.push_token(op)
        if compstate.debug >= 2: print "parse_disjunct returns singleton", left
        return left
    else:
        expr = ('or', left, parse_disjunct(input))
        if compstate.debug >= 2: print "parse_disjunct returns", expr
        return expr

def parse_factor(input):
    if compstate.debug >= 2:
        print "entering parse_factor..."
    left = parse_disjunct(input)
    op = input.lex_token()
    if op.type != 'implies':
        input.push_token(op)
        if compstate.debug >= 2: print "parse_factor returns singleton", left
        return left
    else:
        expr = ('implies', left, parse_disjunct(input))
        if compstate.debug >= 2: print "parse_factor returns", expr
        return expr

def parse_summand(input):
    if compstate.debug >= 2: print "entering parse_summand..."
    left = parse_factor(input)
    op = input.lex_token()
    if op.type != '*':
        input.push_token(op)
        if compstate.debug >= 2: print "parse_summand returns singleton", left
        return left
    else:
        expr = ('*', left, parse_expr_inner(input))
        if compstate.debug >= 2: print "parse_summand returns", expr
        return expr

def parse_ternary(input):
    if compstate.debug >= 2: print "entering parse_ternary..."
    guard = parse_summand(input)
    op = input.lex_token()
    if op.type != '?':
        input.push_token(op)
        if compstate.debug >= 2: print "parse_ternary returns singleton", guard
        return guard
    else:
        trueval = parse_summand(input)
        op = input.lex_token()
        if op.type != ':':
            raise ExpressionError("while expecting : in ternary")
        falseval = parse_summand(input)
        expr = ('?', guard, trueval, falseval)
        if compstate.debug >= 2: print "parse_ternary returns", expr
        return expr

def parse_expr_inner(input):
    if compstate.debug >= 2: print "entering parse_inner_expr..."
    left = parse_ternary(input)
    op = input.lex_token()
    if op.type not in ('+', '-'):
        input.push_token(op)
        if compstate.debug >= 2: print "parse_expr_inner returns singleton", left
        return left
    else:
        expr = (op.type, left, parse_expr_inner(input))
        if compstate.debug >= 2: print "parse_expr_inner returns", expr
        return expr

def parse_expr(input):
    "Parse an expression."
    try:
        exp = parse_expr_inner(input)
        return exp
    except ExpressionError, exp:
        input.croak(exp.args[0])
        return None

def make_dependent(guard, symbol):
    "Create a dependency lnk, indirecting properly through menus."
    if compstate.debug > 0:
        print "Making %s dependent on %s" % (symbol.name, guard.name)
    # If symbol is a menu, we'd really like to create a dependency link
    # for each of its children.  But they won't be defined at this point
    # if the reference is forward.
    if guard not in symbol.ancestors:
        symbol.ancestors.append(guard)
    if symbol not in guard.dependents:
        guard.dependents.append(symbol)

def intern_symbol(input, name=None, oktypes=None, record=0):
    "Attempt to read and intern a symbol."
    if name is None:
        tok = input.lex_token()
        if tok.type == "word":
            name = tok.attr
        else:
            input.push_token(tok)
            return None
    # If symbol is a constant just pass it through.
    if name == "y":
        return cml.y
    elif name == "m":
        return cml.m
    elif name == "n":
        return cml.n
    # If we have not seen the symbol before, create an entry for it.
    if not rulebase.dictionary.has_key(name):
        ref = rulebase.dictionary[name] = cml.ConfigSymbol(name,
                                            None, None, None,
                                            input.infile,
                                            input.lineno)
        compstate.explicit_ancestors[ref] = []
    else:
        ref = rulebase.dictionary[name]
        if ref.type and oktypes is not None and ref.type not in oktypes:
            input.complain('incompatible previous declaration of %s as %s (see "%s", %d)' % (name, ref.type, ref.file, ref.lineno))
        if record:
            if record:
                ref.file = input.infile
                ref.lineno = input.lineno
            else:
                input.complain('duplicate symbol %s (see "%s", line %d)'
                               % (name, ref.file, ref.lineno))
    return ref

def intern_symbol_list(input, record=0):
    "Get a list of symbols (terminate on keyword)."
    list = []
    while 1:
        symbol = intern_symbol(input, None, None, record)
        if symbol == None:
            break
        else:
            list.append(symbol)
    if not list:
	input.complain("syntax error, expected a nonempty word list")
    return list

def parse(input, baton):
    # Parse an entire CML program
    input.source = "source"
    if compstate.debug > 2:
    	print "Calling parse()"
    	input.debug = 1
    while 1:
        if not compstate.debug and not compstate.errors:
            baton.twirl()
	leader = input.lex_token()
	if compstate.debug > 1: print "Parsing declaration beginning with %s..." % (leader,)
        # Language constructs begin here 
	if leader.type == "EOF":
	    break
	elif leader.type == "start":
	    rulebase.start = input.lex_token().attr
	elif leader.type in ("menus", "explanations"):
            input.complain("menus and explanations declarations are "
                           "obsolete, replace these keywords with `symbols'")
	elif leader.type == "symbols":
	    while 1:
                ref = intern_symbol(input, None, None, record=1)
                if ref == None:
                    break
                ref.prompt = input.demand("string")

                # These symbols may be followed by optional help text
                tok = input.lex_token()
                if tok.type == "text":
                    rulebase.dictionary[ref.name].helptext = tok.attr
                elif tok.type == "like":
                    target = input.lex_token()
                    if not rulebase.dictionary.has_key(target.attr):
                        input.complain("unknown 'like' symbol %s" % target.attr)
                    elif not rulebase.dictionary[target.attr].help():
                        input.complain("'like' symbol %s has no help" % target.attr)
                    else:
                        rulebase.dictionary[ref.name].helptext = rulebase.dictionary[target.attr].help()
                else:
                    input.push_token(tok)
	    if compstate.debug:
                print "%d symbols read" % (len(rulebase.dictionary),)
	elif leader.type in ("unless", "when"):
	    guard = parse_expr(input)
            maybe = input.lex_token()
            if maybe == "suppress":
                if leader.type == "when":
                    guard = ("==", guard, cml.n)
                dependent = input.lex_token()
                make_dep = 0
                if dependent.type == "dependent":
                    make_dep = 1
                else:
                    input.push_token(dependent)
                list = intern_symbol_list(input)
                list.reverse()
                for symbol in list:
                    if make_dep:
                        traverse_make_dep(symbol, guard, input)
                    # Add it to ordinary visibility constraints
                    if symbol.visibility:
                        symbol.visibility = ('and', guard, symbol.visibility)
                    else:
                        symbol.visibility = guard
            elif maybe == "save":
                if leader.type == "unless":
                    guard = ("==", guard, cml.n)
                list = intern_symbol_list(input)
                list.reverse()
                for symbol in list:
                    if symbol.saveability:
                        symbol.saveability = ('and', guard, symbol.saveability)
                    else:
                        symbol.saveability = guard
                    # This is a kluge.  It relies on the fact that symbols
                    # explicitly set are always saved.
                    while symbol.menu:
                        symbol.menu.setcount = 1
                        symbol = symbol.menu
            else:
                input.complain("expected `suppress' or `save'")
            compstate.bool_tests.append((guard, input.infile, input.lineno))
	elif leader.type == "menu":
	    menusym = intern_symbol(input, None, ('bool', 'menu', 'choices'), record=1)
            menusym.type = "menu"
	    list = parse_symbol_tree(input)
            #print "Adding %s to %s" % (list, menusym.name)
            # Add and validate items
            menusym.items += list
            for symbol in list:
                if symbol.menu:
                    input.complain("symbol %s in %s occurs in another menu (%s)"
				       % (symbol.name, menusym.name, symbol.menu.name))
                else:
                    symbol.menu = menusym
	elif leader.type == "choices":
	    menusym = intern_symbol(input, None, ('bool', 'menu', 'choices'), record=1)
            menusym.type = "choices"
            list = parse_symbol_tree(input)
            for symbol in list:
                symbol.type = "bool"
                symbol.choicegroup = filter(lambda x, s=symbol: x != s, list)
            dflt = input.lex_token()
            if dflt.type != 'default':
                default = list[0].name
                input.push_token(dflt)
            else:
                default = intern_symbol(input, None, None, record=1)
	    if default not in list:
		input.complain("default %s must be in the menu" % (`default`,))
	    else:
		menusym.default = default
                menusym.items = list
                for symbol in list:
                    if symbol.menu:
                        input.complain("symbol %s occurs in another menu (%s)"
                                       % (symbol.name, symbol.menu.name))
                    else:
                        symbol.menu = menusym
	elif leader.type == "choicegroup":
	    group = intern_symbol_list(input)
            for symbol in group:
                symbol.choicegroup = filter(lambda x, s=symbol: x != s, group)
	elif leader.type == "derive":
            symbol = intern_symbol(input)
	    input.demand("word", "from")
            symbol.default = parse_expr(input)
            compstate.derivations[symbol] = 1
	elif leader.type in ("require", "prohibit"):
            expr = parse_expr(input)
            if leader.type == "prohibit":
                expr = ('==', expr, cml.n)
            next = input.lex_token()
            if next.type != 'explanation':
                input.push_token(next)
                msg = None
            else:
                expl = input.lex_token()
                if expl.type != 'word':
                    input.complain("while expecting a word of explanation, I see %s" % (`expl`,))
                    continue
                entry = intern_symbol(input, expl.attr)
                if entry.type:
                    input.complain("expecting an explanation symbol here")
                else:
                    entry.type = "explanation"
                msg = entry.prompt
	    rulebase.constraints.append(cml.Requirement(expr, msg, input.infile, input.lineno))	    
	    compstate.bool_tests.append((expr, input.infile, input.lineno))
	elif leader.type == "default":
	    symbol = input.demand("word")
	    input.demand("word", "from")
	    expr = parse_expr(input)
            entry = intern_symbol(input, symbol)
	    if entry.default: 
		input.complain("%s already has a default" % (symbol,))
	    else:
		entry.default = expr
            next = input.lex_token()
            if next.type == "range":
                entry.range = []
                while 1:
                    low = input.lex_token()
                    if low.type in _keywords:
                        input.push_token(low)
                        break
                    elif low.type in ("decimal", "hexadecimal"):
                        low = low.attr
                    else:
                        input.complain("bad token %s where range literal expected" % (low.attr))
                    rangesep = input.lex_token()
                    if rangesep.type in _keywords:
                        entry.range.append(low)
                        input.push_token(rangesep)
                        break
                    elif rangesep.type in ("decimal", "hexadecimal"):
                        entry.range.append(low)
                        input.push_token(rangesep)
                        continue
                    elif rangesep.type == '-':
                        high = input.lex_token()
                        if high.type in ("decimal", "hexadecimal"):
                            high = high.attr
                            entry.range.append((low, high))
                            continue
                        else:
                            input.croak("malformed range")
                            break
            elif next.type == "enum":
                entry.range = []
                entry.enum = 1
                while 1:
                    name = input.lex_token()
                    if name.type in _keywords:
                        input.push_token(name)
                        break
                    elif name.type != 'word':
                        input.complain("bad token %s where enum name expected" % (name.attr))
                        continue
                    ename = intern_symbol(input, name.attr, None, record=1)
                    ename.type = "message"
                    input.demand('=')
                    value = input.lex_token()
                    if value.type in ("decimal", "hexadecimal"):
                        value = value.attr
                        entry.range.append((ename.name, value))
                        continue
                    else:
                        input.croak("malformed enum")
            else:
                input.push_token(next)
                continue
	elif leader.type == 'give':
	    list = intern_symbol_list(input)
            input.demand('property')
            label = input.lex_token()
            for symbol in list:
                symbol.setprop(label.attr)
	elif leader.type == 'debug':
            compstate.debug = input.lex_token().attr
	elif leader.type == 'prefix':
            rulebase.prefix = input.lex_token().attr
	elif leader.type == 'banner':
            entry = intern_symbol(input, None, record=1)
            entry.type = "message"
            rulebase.banner = entry
        elif leader.type == 'icon':
            if rulebase.icon:
                input.complain("multiple icon declarations")
            rulebase.icon = input.lex_token().attr
        elif leader.type == 'condition':
            flag  = input.lex_token()
            input.demand("on")
            val = None
            switch = input.lex_token()
            if switch.type in ("decimal", "hexadecimal"):
                val = int(switch.attr)
            elif switch.type == "string":
                val = switch.attr
            elif switch.type == "trit":
                val = resolve(switch)	# No flag is module-valued yet
            entry = intern_symbol(input, switch.attr)
            # Someday is today
            if flag == "trits":
                if val is not None:
                    rulebase.trit_tie = val
                else:
                    rulebase.trit_tie = entry
            elif flag == "nohelp":
                if val is not None:
                    rulebase.help_tie = val
                else:
                    rulebase.help_tie = entry
            elif flag == "expert":
                if val is not None:
                    rulebase.expert_tie = val
                else:
                    rulebase.expert_tie = entry
            else:
                input.complain("unknown flag %s in condition statement" % (flag,))
        elif leader.type == 'warndepend':
	    iffy = intern_symbol_list(input)
            for symbol in iffy:
                compstate.warndepend.append(symbol)
        elif leader.type == 'property':
            propname = input.lex_token()
            if propname.type in _keywords:
                input.croak("malformed property declaration")
            compstate.propnames[propname.attr] = propname.attr
            maybe = input.lex_token()
            if maybe.type == 'alias':
                while 1:
                    alias = input.lex_token()
                    if alias.type != 'word':
                        input.push_token(alias)
                        break
                    compstate.propnames[alias.attr] = propname.attr
	else:
	    input.croak("syntax error, unknown statement %s" % (leader,))

# Mwnu list parsing

def get_symbol_declaration(input):
    # First grab a properties prefix
    global compstate
    if compstate.debug >= 2: print "entering get_symbol_declaration..."
    props = []
    propflag = 1
    while 1:
        symbol = input.lex_token()
        if symbol.attr == '~':
            propflag = 0
        elif symbol.type == ':':
            propflag = 1
        elif symbol.type == 'property':
            props.append((propflag, compstate.propnames[symbol.attr]))
        else:
            input.push_token(symbol)
            break
    compstate.property_stack.append(props)
    #if compstate.debug >= 2: print "label list is %s" % props
    # Now, we get either a subtree or a single declaration
    symbol = input.lex_token()
    if symbol.attr == '{':		# Symbol subtree
        if compstate.symbol_list and compstate.symbol_list[0].type == "string":
            input.complain("string symbol is not a legal submenu guard")
        if compstate.symbol_list:
            compstate.condition_stack.append(compstate.symbol_list[-1])
        else:
            compstate.condition_stack.append(None)
        inner_symbol_tree(input)
        compstate.property_stack.pop()
        return 1
    elif symbol.attr == '}':
        if not compstate.condition_stack:
            input.complain("extra }")
        else:
            compstate.condition_stack.pop()
        compstate.property_stack.pop()
        return 0
    elif symbol.type == 'word':		# Declaration
        if compstate.debug >= 2: print "interning %s" % symbol.attr
        entry = intern_symbol(input, symbol.attr, record=1)
        compstate.symbol_list.append(entry)
        entry.depth = len(compstate.condition_stack)
        if compstate.condition_stack and compstate.condition_stack[-1] is not None:
            make_dependent(compstate.condition_stack[-1], entry)
        # Apply properties
        propdict = {}
        for level in compstate.property_stack:
            for (flag, property) in level:
                if flag:
                    propdict[property] = 1
                else:
                    if not propdict.has_key(property):
                        input.complain("property %s can't be removed when it's not present" % property)
                    else:
                        propdict[property] = 0
        for (prop, val) in propdict.items():
            if val == 1 and not entry.hasprop(prop):
                entry.setprop(prop)
            elif val == 0 and entry.hasprop(prop):
                entry.delprop(prop)
        # Read a type suffix if present
        if entry.type not in ("menu", "choices", "explanation", "message"):
            entry.type = "bool"
            symbol = input.lex_token()
            if symbol.type == '?':	# This is also an operator
                entry.type = 'trit'
            elif symbol.attr == '%':
                entry.type = 'decimal'
            elif symbol.attr == '@':
                entry.type = 'hexadecimal'
            elif symbol.type == '$':	# This is also an operator
                entry.type = 'string'
            else:
                input.push_token(symbol)
        compstate.property_stack.pop()
        return 1
    elif symbol.type in _keywords + ("EOF",):
        input.push_token(symbol)
        compstate.property_stack.pop()
        return 0
    else:
        input.complain("unexpected token %s" % symbol)
        compstate.property_stack.pop()
        return 0
    return 1

def inner_symbol_tree(input):
    while get_symbol_declaration(input):
        pass

def parse_symbol_tree(input):
    global compstate
    if compstate.debug >= 2: print "entering parse_symbol_tree..."
    # Get a nonempty list of config symbols and menu ids. 
    # Interpret the {} shorthand if second argument is nonempty
    compstate.condition_stack = []	# Stack of active conditions for {} shorthand
    compstate.property_stack = []
    compstate.symbol_list = []
    inner_symbol_tree(input)
    if not list:
	input.complain("syntax error, expected a nonempty symbol declaration list")
    if compstate.symbol_list[0].depth == 1:
        for symbol in compstate.symbol_list:
            symbol.depth -= 1
    return compstate.symbol_list

def traverse_make_dep(symbol, guard, input):
    "Create the dependency relations implied by a 'suppress depend' guard."
    #print "traverse_make_dep(%s, %s)" % (symbol.name, guard)
    if compstate.derivations.has_key(symbol):
        return  
    elif isinstance(guard, cml.trit) or (isinstance(guard, Token) and guard.attr in ("n", "m", "y")):
        return
    elif isinstance(guard, Token):
        if guard in compstate.explicit_ancestors[symbol]:
            input.complain("%s is already an ancestor of %s"% (guard.attr, symbol.name))
        else:
            compstate.explicit_ancestors[symbol].append(guard)
    elif isinstance(guard, cml.ConfigSymbol):
        if guard in compstate.explicit_ancestors[symbol]:
            input.complain("%s is already an ancestor of %s"% (guard.name, symbol.name))
        else:
            compstate.explicit_ancestors[symbol].append(guard)
    elif guard[0] == 'and' or guard[0] in _relops:
        traverse_make_dep(symbol, guard[1], input)
        traverse_make_dep(symbol, guard[2], input)
    elif guard[0] in _boolops:
        return		# Don't descend into disjunctions
    else:
        input.complain("unexpected operation %s in visibility guard"%guard[0])

# Functions for validating the parse tree

def simple_error(file, line, errmsg):
    if not compstate.debug and not compstate.errors:
        sys.stderr.write('\n')
    sys.stderr.write(error_leader(file, line) + errmsg)
    compstate.errors = compstate.errors + 1

def validate_boolean(expr, file, line, ok=0):
    # Check for ambiguous boolean expr terms.
    #print "validate_boolean(%s, %s, %s, %s)" % (expr, file, line, ok)
    if isinstance(expr, cml.ConfigSymbol):
        if expr.type in ("trit", "decimal", "hexadecimal") and not ok:
            simple_error(file, line, "test of %s is ambiguous\n" % (expr.name,))
    elif type(expr) is type(()):
        validate_boolean(expr[1], file, line, expr[0] in _relops + _termops)
        validate_boolean(expr[2], file, line, expr[0] in _relops + _termops)

def validate_expr(expr, file, line):
    # Check for bad type combinations in expressions
    # Return a leaf node type, inaccurate but good enough for
    # consistency checking.
    if isinstance(expr, cml.ConfigSymbol):
        if expr.is_numeric():
            return "integer"
        elif expr.is_logical():
            return "trit"
        else:
            return expr.type
    elif isinstance(expr, cml.trit):
        return "trit"
    elif type(expr) in (type(0), type(0L)):
        return "integer"
    elif type(expr) == type(""):
        return "string"
    elif expr[0] == '?':
        left = validate_expr(expr[2], file, line)
        right = validate_expr(expr[3], file, line)
        if left != right:
            simple_error(file, line, "types %s and %s don't match in ternary expression\n" % (left, right))
        return left
    elif expr[0] in _arithops:
        left = validate_expr(expr[1], file, line)
        if left not in ("integer", "trit"):
            simple_error(file, line, "bad %s left operand for arithmetic operator %s\n" % (left, expr[0]))
        right = validate_expr(expr[2], file, line)
        if right not in ("integer", "trit"):
            simple_error(file, line, "bad %s right operand for arithmetic operator %s\n" % (right, expr[0]))
        return "integer"
    elif expr[0] in _boolops or expr[0] in _termops:
        left = validate_expr(expr[1], file, line)
        if left != "trit":
            simple_error(file, line, "bad %s left operand for trit operator %s\n" % (left, expr[0]))
        right = validate_expr(expr[2], file, line)
        if right != "trit":
            simple_error(file, line, "bad %s right operand for trit operator %s\n" % (right, expr[0]))
        return "trit"
    elif expr[0] in _relops:
        left = validate_expr(expr[1], file, line)
        right = validate_expr(expr[2], file, line)
        if left != right:
            simple_error(file, line, "types %s and %s don't match in %s expression\n" % (expr[0], left, right))
        return "trit"
    else:
        if not compstate.debug and not compstate.errors:
            sys.stderr.write('\n')
        sys.stderr.write(error_leader(file, line) + \
                         "internal error: unexpected node %s in expression\n" % expr[0])
        compstate.errors = compstate.errors + 1

def symbols_by_preorder(node):
    # Get a list of config symbols in natural traverse order
    if node.items:
       sublists = map(symbols_by_preorder, node.items)
       flattened = []
       for m in sublists:
	   flattened = flattened + m
       return flattened
    else:
       return [node.name]

def resolve(exp):
    # Replace symbols in an expr with resolved versions
    if type(exp) is type(()):
	if exp[0] == 'not':
	    return ('not', resolve(exp[1]))
	elif exp[0] == '?':
	    return ('?', resolve(exp[1]), resolve(exp[2]), resolve(exp[3]))
	else:
	    return (exp[0], resolve(exp[1]), resolve(exp[2]))
    elif isinstance(exp, cml.ConfigSymbol):	# Symbol, already resolved
	return exp
    elif isinstance(exp, cml.trit):		# Trit, already resolved
	return exp
    elif type(exp) in (type(0), type("")):	# Constant, already resolved
	return exp
    elif not hasattr(exp, "type"):
	sys.stderr.write("Symbol %s has no type.\n" % (exp,))
	compstate.errors = compstate.errors + 1
	return None
    elif exp.type == 'trit':
        if exp.attr == 'y':
            return cml.y
        elif exp.attr == 'm':
            return cml.m
        elif exp.attr == 'n':
            return cml.n
    elif exp.type in _atoms:
	return exp.attr
    elif rulebase.dictionary.has_key(exp.attr):
	return rulebase.dictionary[exp.attr]
    else:
	compstate.bad_symbols[exp.attr] = 1
	return None

def ancestry_check(symbol, counts):
    # Check for circular ancestry chains
    # print "Checking ancestry of %s: %s" % (symbol, symbol.ancestors)
    counts[symbol] = 1
    for ancestor in symbol.ancestors:
        if counts.has_key(ancestor.name):
            raise NameError, symbol.name + " through " + ancestor.name
        else:
            map(lambda symbol, counts=counts: ancestry_check(symbol, counts), symbol.ancestors)

def circularity_check(name, exp, counts):
    # Recursive circularity check...
    # print "Expression check of %s against %s" % (name, exp)
    if type(exp) is type(()):
        if exp[0] == '?':
	    circularity_check(name, exp[1], counts)
	    circularity_check(name, exp[2], counts)
	    circularity_check(name, exp[3], counts)
	else:
	    circularity_check(name, exp[1], counts)
	    circularity_check(name, exp[2], counts)
    elif isinstance(exp, cml.ConfigSymbol) and name == exp.name:
        raise NameError, name
    elif hasattr(exp, "default"):
	vars = cml.flatten_expr(exp.default)
	# print "Components of %s default: %s" % (exp.name vars) 
	for v in vars:
	    if v.name == name:
		raise NameError, name
	    elif counts.has_key(v.name):
		pass		# Already checked this branch
	    else:
		counts[v.name] = 1
		circularity_check(name, v.name, counts)

def error_leader(file, line):
    return '"%s", line %d:' % (file, line)

def postcomplain(msg):
    if not compstate.debug and not compstate.errors:
        sys.stderr.write('\n')
    sys.stderr.write("cmlcompile: " + msg)
    compstate.errors += 1

# This is the entry point to use if we want the compiler as a function

def compile(debug, arguments, profile, endtok=None):
    "Sequence a compilation"
    global rulebase, compstate

    rulebase = cml.CMLRulebase()
    compstate = CompilationState()
    compstate.debug = debug

    if not debug:
        baton = cml.Baton("Compiling rules, please wait")
    else:
        baton = None

    if profile:
        import time 
        now = zerotime = basetime = time.time();

    # Parse everything
    try:
	if not arguments:
	    parse(lexwrapper(sys.stdin, endtok), baton)
	else:
	    for file in arguments:
		parse(lexwrapper(open(file), endtok), baton)
    except IOError, details:
	sys.stderr.write("cmlcompile: I/O error, %s\n" % (details,))
	return None

    if profile:
        now = time.time();
        print "Rule parsing:", now - basetime
        basetime = now
    if not debug and not compstate.errors:
        baton.twirl()

    # Sanity and consistency checks:

    # We need a main menu declaration
    if not rulebase.start:
	postcomplain("missing a start declaration.\n")
	return None
    elif not rulebase.dictionary.has_key(rulebase.start):
	postcomplain("declared start menu '%s' does not exist.\n"%(rulebase.start,))
	return None
    if not debug and not compstate.errors:
        baton.twirl()

    # Check for symbols that have been forward-referenced but not declared
    for ref in rulebase.dictionary.values():
        if not ref.prompt and not compstate.derivations.has_key(ref):
            postcomplain('"%s", line %d: %s in menu %s has no prompt\n' % (ref.file, ref.lineno, ref.name, `ref.menu`))

    # Check that all symbols other than those on the right side of
    # derives are either known or themselves derived.
    for entry in rulebase.dictionary.values():
        if entry.visibility:
            entry.visibility = resolve(entry.visibility)
        if entry.saveability:
            entry.saveability = resolve(entry.saveability)
	if entry.default:
	    entry.default = resolve(entry.default)
    rulebase.constraints = map(lambda x: cml.Requirement(resolve(x.predicate), x.message, x.file, x.line), rulebase.constraints)
    if compstate.bad_symbols:
	postcomplain("%d symbols could not be resolved:\n"%(len(compstate.bad_symbols),))
	sys.stderr.write(`compstate.bad_symbols.keys()` + "\n")
    if not debug and not compstate.errors:
        baton.twirl()

    # Now associate a type with all derived symbols.  Since such symbols
    # are never queried, the only place this is used is in formatting
    # the symbol's appearance in the final configuration file.
    #
    # (The outer loop forces this to keep spinning until it has done all
    # possible deductions, even in the presence of forward declarations.)
    while 1:
        deducecount = 0
        for entry in rulebase.dictionary.values():
            if compstate.derivations.has_key(entry) and not entry.type:
                derived_type = None
                if entry.default == cml.m:
                    derived_type = "trit"
                elif entry.default == cml.n or entry.default == cml.y:
                    derived_type = "bool"
                elif type(entry.default) is type(()):
                    if entry.default[0] in _boolops + _relops:
                        derived_type = "bool"
                    elif entry.default[0] in _termops:
                        derived_type = "trit"
                    elif entry.default[0] in _arithops:
                        derived_type = "decimal"
                    elif entry.default[0] == '?':
                        if isinstance(entry.default[2], cml.ConfigSymbol):
                            derived_type = entry.default[2].type
                        elif isinstance(entry.default[2], cml.trit):
                            derived_type = "trit"
                        elif type(entry.default[2]) in (type(0), type(0L)):
                            derived_type = "decimal"
                        elif type(entry.default[2]) is type(""):
                            derived_type = "string"
                elif type(entry.default) is type(0):
                    derived_type = "decimal"		# Could be hex
                elif type(entry.default) is type(""):
                    derived_type = "string"
                elif isinstance(entry.default, cml.ConfigSymbol):
                    derived_type = entry.default.type
                if derived_type:
                    entry.type = derived_type
                    deducecount = 1
        if not deducecount:
            break

    for entry in rulebase.dictionary.values():
        if compstate.derivations.has_key(entry) and not entry.type:
            postcomplain(error_leader(entry.file, entry.lineno) + \
                             'can\'t deduce type for derived symbol %s from %s\n' % (entry.name, entry.default))
    if not debug and not compstate.errors:
        baton.twirl()

    # Now run our ambiguity check on all unless expressions.
    for (guard, file, line) in compstate.bool_tests:
        validate_boolean(resolve(guard), file, line)
    if not debug and not compstate.errors:
        baton.twirl()

    # Handle explicit dependencies
    for symbol in compstate.explicit_ancestors.keys():
        for guard in compstate.explicit_ancestors[symbol]:
            for guardsymbol in cml.flatten_expr(resolve(guard)):
                make_dependent(guardsymbol, symbol)
    if not debug and not compstate.errors:
        baton.twirl()

    # Check that every symbol in the table (that isn't an unresolved forward
    # reference, we've already detected those) is referenced from a menu
    # exactly once (except explanations).  We checked for multiple
    # inclusions at parse-tree generation time.  Now...
    compstate.bad_symbols = {}
    for entry in rulebase.dictionary.values():
	if entry.prompt and not entry.type:
	    compstate.bad_symbols[entry.name] = 1 
    if compstate.bad_symbols:
	postcomplain("%d symbols have no references"%(len(compstate.bad_symbols),))
        sys.stderr.write("\n" +`compstate.bad_symbols.keys()` + "\n")
    if not debug and not compstate.errors:
        baton.twirl()

    # Check for forward references in visibility constraints.
    # Note: this is *not* a fatal error.
    preorder = symbols_by_preorder(rulebase.dictionary[rulebase.start])
    for i in range(len(preorder)):
	key = preorder[i]
	forwards = []
        for guards in cml.flatten_expr(rulebase.dictionary[key].visibility):
            if guards.name in preorder[i+1:]:
                forwards.append(guards.name)
	if forwards:
	    sym = rulebase.dictionary[key]
            postcomplain('"%s", line %d: %s in %s requires %s forward\n' % (sym.file, sym.lineno, key, sym.menu.name, forwards))
            compstate.errors -= 1
    if not debug and not compstate.errors:
        baton.twirl()

    # Check for circularities in derives and defaults.
    try:
        for entry in rulebase.dictionary.values():
            if entry.default:
                expr_counts = {}
                circularity_check(entry.name, entry.default, expr_counts)
            if entry.visibility:
                expr_counts = {}
                circularity_check(entry.name, entry.visibility, expr_counts)
            if entry.ancestors:
                ancestor_counts = {}
                ancestry_check(entry, ancestor_counts)
    except NameError:
	postcomplain("%s depends on itself\n"%(sys.exc_value,))
    if not debug and not compstate.errors:
        baton.twirl()

    # Various small hacks combined here to save traversal overhead.
    bitch_once = {}
    for entry in rulebase.dictionary.values():
        # Validate choice groups
        for symbol in entry.choicegroup:
            if not symbol.is_logical() and not bitch_once.has_key(symbol):
                postcomplain("Symbol %s in a choicegroup is not logical" % symbol.name)
                bitch_once[symbol] = 1
        # Validate the formulas for boolean derived symbols.
        if compstate.derivations.has_key(entry):
            if entry.menu:
		postcomplain("menu %s contains derived symbol %s\n"%(entry.menu.name, `entry`))
            if entry.type == "bool":
                validate_boolean(entry.default, entry.file, entry.lineno)
            else:
                validate_expr(entry.default, entry.file, entry.lineno)
            continue
        #if not entry.default is None:
        #    validate_expr(entry.default, entry.file, entry.lineno)
        # Give childless menus the `message' type.  This will make
        # it easier for the front end to do special things with these objects.
	if entry.type == 'menu':
	    if not entry.items:
		entry.type = 'message'
            continue
        # Check for type mismatches between symbols and their defaults.
        if entry.is_symbol() and not entry.default is None:
            if type(entry.default) in (type(0L),type(0)) and not entry.is_numeric():
                postcomplain("%s is not of numeric type but has numeric constant default\n" % entry.name)
            elif type(entry.default) == type("") and not entry.type == "string":
                postcomplain("%s is not of string type but has string constant default\n" % entry.name)
        # Symbols with decimal/hexadecimal/string type must have a default.
	if entry.type in ("decimal", "hexadecimal", "string"):
	    if entry.default is None:
		postcomplain("%s needs a default\n"%(`entry`,))
        elif entry.range:
            # This member can be used by front ends to determine whether the
            # entry's value should be queried with a pulldown of its values.
            entry.discrete = not filter(lambda x: type(x) is type(()), entry.range)
	    # This member can be used by front ends to determine whether the
	    # entry's value should be queried with a pulldown of enums.
            entry.enum = type(entry.range[0]) is type(()) \
                         and type(entry.range[0][0]) is type("")
        # Now hack the prompts of anything dependent on a warndepend symbol
        for guard in compstate.warndepend:
            if entry.prompt and guard.ancestor_of(entry):
                entry.warnings.append(guard)
    if not debug and not compstate.errors:
        baton.twirl()

    # Check for constraint violations.  If the defaults set up by the
    # rule file are not consistent, it's not likely the user will make
    # a consistent one.  Don't try this if we've seen syntax
    # compstate.errors, as they tend to produce Nones in expressions
    # that this will barf on.
    if not compstate.errors:
        for wff in rulebase.constraints:
            if not cml.evaluate(wff.predicate, debug):
                postcomplain(error_leader(wff.file, wff.line) + " constraint violation: %s\n" % `wff`)
        if not debug and not compstate.errors:
            baton.twirl()

    # Now integrate the help references
    help_dict = {}
    for key in rulebase.dictionary.keys():
	if help_dict.has_key(key):
	    rulebase.dictionary[key].helptext = help_dict[key]
	    del help_dict[key]
    if debug:
	missing = []
	for entry in rulebase.dictionary.values():
	    if not entry.type in ("message", "menu", "choices", "explanation") and entry.prompt and not entry.help():
		missing.append(entry.name)
	if missing:
	    postcomplain("The following symbols lack help entries: %s\n" % missing)
	orphans = help_dict.keys()
        if orphans:
            postcomplain("The following help entries do not correspond to symbols: %s\n" % orphans)
    if not debug and not compstate.errors:
        baton.end("Done")

    if profile:
        now = time.time();
        print "Sanity checks:", now - basetime
        basetime = now

    # We only need the banner string, not the banner symbol
    if rulebase.banner:
        rulebase.banner = rulebase.banner.prompt

    # Package everything up for pickling
    if compstate.errors:
	postcomplain("rulebase write suppressed due to errors.\n")
	return None
    else:
        rulebase.start = rulebase.dictionary[rulebase.start]
        # Precomputation to speed up the configurator's load time
        rulebase.reduced = map(lambda x: x.predicate, rulebase.constraints)
        rulebase.optimize_constraint_access()
        if debug:
            cc = dc = tc = 0
            for symbol in rulebase.dictionary.values():
                if not compstate.derivations.has_key(entry):
                    tc = tc + 1
                if symbol.dependents:
                    dc = dc + 1
                if symbol.constraints:
                    cc = cc + 1
            print "%d total symbols; %d symbols are involved in constraints; %d in dependencies." % (tc, cc, dc)

        if profile:
            now = time.time();
            print "Total compilation time:", now - zerotime

        # We have a rulebase object.
        return rulebase

if __name__ == '__main__':
    def main(debug, outfile, arguments, profile):
        "Compile and write out a ruebase."
        rulebase = compile(debug, arguments, profile)
        if not rulebase:
            raise SystemExit, 1
        else:
            try:
                if debug: print "cmlcompile: output directed to %s" % (outfile)
                out = open(outfile, "wb")
                cPickle.dump(rulebase, out, 1)
                out.close()
            except:
                postcomplain('couldn\'t open output file "%s"\n' % (outfile,))
                raise SystemExit, 1

    outfile = "rules.out"
    profile = debug = 0
    (options, arguments) = getopt.getopt(sys.argv[1:], "o:Pv", "help")
    for (switch, val) in options:
	if switch == '-o':
	    outfile = val
	elif switch == '-P':
	    profile = 1
	elif switch == '-v':
	    debug = debug + 1
	elif switch == '--help':
	    sys.stdout.write(lang["CLIHELP"])
	    raise SystemExit

    if profile:
        import profile
        profile.run("main(debug, outfile, arguments, profile)")
    else:
        main(debug, outfile, arguments, profile)

# That's all, folks!
