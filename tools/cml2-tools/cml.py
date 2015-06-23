"""
cml.py -- types for communication between CML2 compiler and configurators.
"""
import sys, os, time

version="2.3.0"

class trit:
    "A boolean or trit value"
    type = "trit"
    def __init__(self, value):
        if isinstance(value, trit):
            value = value.value
        self.value = value
    def __repr__(self):
        return "nmy"[self.value]
    def __nonzero__(self):
        return self.value
    def __hash__(self):
        return self.value	# This magic needed to make trits valid dictionary keys
    def __long__(self):
        return self.value != 0
    def __cmp__(self, other):
        if not isinstance(other, trit):
            if other is None:
                return 1               # any trit > None
            else:                       # Standard no-__cmp__ behavior=20
                if id(self) < id(other):
                    return -1
                elif id(self) > id(other):
                    return 1
                else:
                    return 0
        else:
            diff = self.value - other.value
            if diff == 0:
                return 0
            else:
                return diff / abs(diff)
    def __and__(self, other):
        return trit(min(self.value, other.value))
    def __or__(self, other):
        return trit(max(self.value, other.value))
    def eval(self):
        return self

# Trit value constants
y = trit(2)
m = trit(1)
n = trit(0)

# This describes a configuration symbol...

class ConfigSymbol:
    "Compiled information about a menu or configuration symbol"
    def __init__(self, name, type=None, default=None, prompt=None, file=None, lineno=None):
        # Name, location, type, default.
        self.name = name
        self.file = file	# Definition location source file
        self.lineno = lineno	# Definition location source line
        self.type = type	# Type of symbol
        self.range = None	# Range tuple
        self.enum = None
        self.discrete = None
        self.helptext = None	# Help reference
        self.default = default	# Value to use if none has been set.
        # Hierarchy location
        self.ancestors = []	# Ancestors of symbol (as set up by {})
        self.dependents = []	# Dependents of symbol (as set up by {})
        self.choicegroup = []	# Other symbols in a choicegroup.
        self.menu = None	# Unique parent menu of this symbol
        self.depth = 0		# Nesting depth in its subtree
        # Auxiliary information
        self.prompt = prompt	# Associated question string
        self.properties = {}	# Associated properties
        self.warnings = []	# Attached warndepend conditions
        self.visibility = None	# Visibility predicate for symbol 
        self.saveability = None	# Saveability predicate for symbol
        self.items = []		# Menus only -- associated symbols
        # Compiler never touches these
        self.visits = 0   	# Number of visits so far
        self.setcount = 0       # Should this symbol be written?
        self.included = 0       # Seen in an inclusion?
        self.inspected = 0      # Track menu inspections
        self.iced = 0		# Is this frozen?

    # Compute the value of a symbol 
    def eval(self, debug=0):
        "Value of symbol; passes back None if the symbol is unset."
        if self.default is not None:
            result = evaluate(self.default, debug)
            # Handle casting.  This can matter in derivations
            if self.type == "bool":
                if isinstance(result, trit):
                    result = trit(y.value * (result != n))
                elif type(result) == type(0):
                    result = trit(y.value * (result != 0))
            elif self.type in ("decimal", "hexadecimal"):
                if isinstance(result, trit):
                    result = (result != n)
            if debug > 3:
                sys.stderr.write("...eval(%s)->%s (through default %s)\n" % \
                                 (`self`, result, self.default))
            return result
        else:
            if debug > 2:
                sys.stderr.write("...eval(%s)->None (default empty)\n" % \
                                 (`self`))
            return None

    # Access to help.
    #
    # This is the only place in the front end that knows about the CML1
    # helpfile conventions.
    def help(self):
        "Is there help for the given symbol?"
        if self.helptext:
            return self.helptext
        # Next five lines implement the CML1 convention for choices help;
        # attach it to the first alternative.  But they check for help
        # attached to the symbol itself first.
        if self.menu and self.menu.type == "choices":
            self = self.menu
        if self.type == "choices" and not self.helptext:
            self = self.items[0]
        return self.helptext

    def ancestor_of(self, entry):
        "Test transitive completion of dependency."
        # We don't also check visibility, because visibility guards can have
        # disjunctions and it would be wrong to propagate up both branches.
        if entry.menu:
            searchpath = entry.ancestors + [entry.menu]
        else:
            searchpath = entry.ancestors
        if self in searchpath:
            return 1
        for x in searchpath:
            if self.ancestor_of(x):
                return 1
        return 0

    # Predicates
    def is_derived(self):
        "Is this a derived symbol?"
        return self.prompt is None
    def is_logical(self):
        "Is this a logical symbol?"
        return self.type in ("bool", "trit")
    def is_numeric(self):
        "Is this a numeric symbol?"
        return self.type in ("decimal", "hexadecimal")
    def is_symbol(self):
        "Is this a real symbol? (not a menu, not a choices, not a message)"
        return self.type in ("bool","trit", "decimal","hexadecimal", "string")

    # Property functions
    def hasprop(self, prop):
        return self.properties.has_key(prop)
    def setprop(self, prop, val=1):
        self.properties[prop] = val
    def delprop(self, prop):
        del self.properties[prop]
    def showprops(self,):
        return ", ".join(self.properties.keys())

    def __repr__(self):
        # So the right thing happens when we print symbols in expressions
        return self.name
    def dump(self):
        if self.prompt:
            res = "'%s'" % self.prompt
        else:
            res = "derived"
        res += ", type %s," % self.type
        if self.range:
            res = res + " range %s," % (self.range,)
        if self.menu:
            res = res + " in %s," % (self.menu.name,)
        if self.ancestors:
            res = res + " under %s," % (self.ancestors,)
        if self.dependents:
            res = res + " over %s," % (self.dependents,)
        if self.choicegroup:
            res = res + " choicegroup %s," % (self.choicegroup,)
        if self.visibility is not None:
            res = res + " visibility %s," % (display_expression(self.visibility),)
        if self.saveability is not None:
            res = res + " saveability %s," % (display_expression(self.saveability),)
        if self.default is not None:
            res = res + " default %s," % (`self.default`,)
        if self.items:
            res = res + " items %s," % (self.items,)
        if self.properties:
            res = res + " props=%s," % (self.showprops(),)
        if self.file and self.lineno is not None:
            res = res + " where=%s:%d," % (self.file, self.lineno)
        return res
    def __str__(self):
        # Note that requirements are not shown
        res = "%s={" % (self.name)
        res = res + self.dump()
        return res[:-1] + "}"

class Requirement:
    "A requirement, together with a message to be shown if it's violated."
    def __init__(self, wff, message, file, line):
        self.predicate = wff
        self.message = message
        self.file = file
        self.line = line

    def str(self):
        return display_expression(self.predicate)[1:-1]

    def __repr__(self):
        bindings = ""
        for sym in flatten_expr(self.predicate):
            bindings += "%s=%s, " % (sym.name, evaluate(sym))
        bindings = bindings[:-2]
        leader = '"%s", line %d: ' % (self.file, self.line)
        if self.message:
            return leader + self.message + " (" + bindings + ")"
        else:
            return leader + display_expression(self.predicate) + " (" + bindings + ")"

# This describes an entire configuration.

class CMLRulebase:
    "A dictionary of ConfigSymbols and a set of constraints."
    def __init__(self):
        self.version = version
        self.start = None		# Start menu name		
        self.dictionary = {}		# Configuration symbols
        self.prefix = ""		# Prepend this to all symbols
        self.banner = ""		# ID the configuration domain
        self.constraints = []		# All requirements
        self.icon = None		# Icon for this rulebase
        self.trit_tie = None		# Are trits enabled?
        self.help_tie = None		# Help required for visibility?
        self.expert_tie = None		# Expert flag for UI control
        self.reduced = []
    def __repr__(self):
        res = "Start menu = %s\n" % (self.start,)
        for k in self.dictionary.keys():
            res = res + str(self.dictionary[k]) + "\n"
        if self.prefix:
            res = res + "Prefix:" + `self.prefix`
        if self.banner:
            res = res + "Banner:" + `self.banner`
        return res
    def optimize_constraint_access(self):
        "Assign constraints to their associated symbols."
        for entry in self.dictionary.values():
            entry.constraints = []
        for requirement in self.reduced:
            for symbol in flatten_expr(requirement):
                if not requirement in symbol.constraints:
                    symbol.constraints.append(requirement)

# These functions are used by both interpreter and compiler

def evaluate(exp, debug=0):
    "Compute current value of an expression."
    def tritify(x):
        if x:
            return y
        else:
            return n
    if debug > 2:
        sys.stderr.write("evaluate(%s) begins...\n" % (`exp`,))
    if type(exp) is type(()):
        # Ternary operator
        if exp[0] == '?':
            guard = evaluate(exp[1], debug)
            if guard:
                return evaluate(exp[2], debug)
            else:
                return evaluate(exp[3], debug)
        # Logical operations -- always trit-valued
        elif exp[0] == 'not':
            return tritify(not evaluate(exp[1], debug))
        elif exp[0] == 'or':
            return tritify(evaluate(exp[1], debug) or evaluate(exp[2], debug))
        elif exp[0] == 'and':
            return tritify(evaluate(exp[1], debug) and evaluate(exp[2], debug))
        elif exp[0] == 'implies':
            return tritify(not ((evaluate(exp[1], debug) and not evaluate(exp[2], debug))))
        elif exp[0] == '==':
            return tritify(evaluate(exp[1], debug) == evaluate(exp[2], debug))
        elif exp[0] == '!=':
            return tritify(evaluate(exp[1], debug) != evaluate(exp[2], debug))
        elif exp[0] == '<=':
            return tritify(evaluate(exp[1], debug) <= evaluate(exp[2], debug))
        elif exp[0] == '>=':
            return tritify(evaluate(exp[1], debug) >= evaluate(exp[2], debug))
        elif exp[0] == '<':
            return tritify(evaluate(exp[1], debug) < evaluate(exp[2], debug))
        elif exp[0] == '>':
            return tritify(evaluate(exp[1], debug) > evaluate(exp[2], debug))
        # Arithmetic operations -- sometimes trit-valued
        elif exp[0] == '|':
            return evaluate(exp[1], debug) | evaluate(exp[2], debug)
        elif exp[0] == '&':
            return evaluate(exp[1], debug) & evaluate(exp[2], debug)
        elif exp[0] == '$':
            left = evaluate(exp[1])
            right = evaluate(exp[2])
            if left != right:
                return n
            else:
                return left
        elif exp[0] == '+':
            return long(evaluate(exp[1],debug)) + long(evaluate(exp[2],debug))
        elif exp[0] == '-':
            return long(evaluate(exp[1],debug)) - long(evaluate(exp[2],debug))
        elif exp[0] == '*':
            return long(evaluate(exp[1],debug)) * long(evaluate(exp[2],debug))
        else:
            raise SyntaxError, "Unknown operation %s in expression" % (exp[0],)
    elif isinstance(exp, trit) or type(exp) in (type(""), type(0), type(0L)):
        if debug > 2:
            sys.stderr.write("...evaluate(%s) returns itself\n" % (`exp`,))
        return exp
    elif isinstance(exp, ConfigSymbol):
        result = exp.eval(debug)
        if result:
            return result
        else:
            return n
    else:
        raise ValueError,"unknown object %s %s in expression" % (exp,type(exp))

def flatten_expr(node):
    "Flatten an expression -- skips the operators"
    if type(node) is type(()) or type(node) is type([]):
       sublists = map(flatten_expr, node)
       flattened = []
       for item in sublists:
           flattened = flattened + item
       return flattened
    elif isinstance(node, ConfigSymbol):
        if node.is_derived():
            return flatten_expr(node.default)
        else:
            return [node]
    else:
        return []

def display_expression(exp):
    "Display an expression in canonicalized infix form."
    if type(exp) is type(()):
        if exp[0] == "not":
            return "not " + display_expression(exp[1])
        elif exp[0] == '?':
            return "(%s ? %s : %s)" % (display_expression(exp[1]), display_expression(exp[2]), display_expression(exp[3]))
        else:
            return "(%s %s %s)" % (display_expression(exp[1]), exp[0], display_expression(exp[2]))
    elif isinstance(exp, ConfigSymbol):
        return exp.name
    else:
        return `exp`

class Baton:
    "Ship progress indication to stdout."
    def __init__(self, prompt, endmsg=None):
        if os.isatty(1):
            self.stream = sys.stdout
        elif os.isatty(2):
            self.stream = sys.stderr
        else:
            self.stream = None
        if self.stream:
            self.stream.write(prompt + "... \010")
            self.stream.flush()
        self.count = 0
        self.endmsg = endmsg
        self.time = time.time()
        return

    def twirl(self, ch=None):
        if self.stream is None:
            return
        if ch:
            self.stream.write(ch)
        else:
            self.stream.write("-/|\\"[self.count % 4])
            self.stream.write("\010")
        self.count = self.count + 1
        self.stream.flush()
        return

    def end(self, msg=None):
        if msg == None:
            msg = self.endmsg
        if self.stream:
            self.stream.write("...(%2.2f sec) %s.\n" % (time.time() - self.time, msg))
        return

if __name__ == "__main__":
    # Two classes without __cmp__
    class A:
        pass

    class B:
        pass

    a = A()
    b = B()

    t0 = trit(0)
    t1 = trit(1)
    t2 = trit(2)

    if not (t0 < t1 < t2 and t2 > t1 > t0) or t0 == t1 or t0 == t2 or t1 == t2:
        print "trit compare failed"

    if t0 < None:
        print "a trit is less than None?  Comparison failed"

    if None > t0:
        print "None is greater than a trit?  Comparison failed"

    if id(a) > id(b):
        if a < b > a:
            print "a/b comparison failed"
    elif b < a > b:
        print "a/b comparison failed"


    # Simulate standard no-cmp() behavior for non-trits
    if id(a) > id(t0):
        if a < t0:
            print "a/t0 comparison failed (id(a) greater)"
    elif t0 < a:
        print "a/t0 comparison failed"

# cml.py ends here.
