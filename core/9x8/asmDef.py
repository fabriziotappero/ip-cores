################################################################################
#
# Copyright 2012, Sinclair R.F., Inc.
#
# Collection of utilities for the assembler.
#
################################################################################

import os
import re

class AsmException(Exception):
  """
  Exception class for the assembler.\n
  This allows the top-level module to capture error messages other than internal
  errors and program bugs so that users see a single-line error relevant to
  their code rather than the usual Python mess.
  """
  def __init__(self,message):
    self.msg = message;
  def __str__(self):
    return self.msg;

class FileBodyIterator:
  """
  Iterator for files that returns bodies of lines of the file.\n
  The directive must be the first non-white spaces on a line.\n
  The iterator outputs a list whos first element is the line number for the
  first line of the block and whose subsequent elements are the lines with the
  content of the block.\n
  The iterator handles the ".include" directive.
  """

  def __init__(self, fps, ad):
    """
    Initialize the iterator.\n
    fps         list of file pointers from the argument line
    ad          asmDef_9x8 object (required to identify the directives)
    """
    # Do sanity check on arguments.
    if ad.IsDirective(".include"):
      raise Exception('Program Bug:  The ".include" directive is defined by FileBodyIterator');
    # Initialize the raw processing states
    self.ixConstants = 0;
    self.fpPending = list(fps);
    self.ad = ad;
    self.current = list();
    self.pending = list();
    # Initialize the include search paths
    self.searchPaths = list();
    self.searchPaths.append('.');
    # Prepare the file parsing
    self.included = list();
    for fp in self.fpPending:
      if fp.name in self.included:
        raise AsmException('Input file %s listed more than once' % fp.name);
      self.included.append(fp.name);
    self.fpStack = list();
    self.fpStack.append(dict(fp=self.fpPending.pop(0), line=0));
    self.pendingInclude = None;

  def __iter__(self):
    """
    Required function for an iterable object.
    """
    return self;

  def next(self):
    """
    Return the next directive body from the iterator.\n
    The body is a list with the following content:
      the name of the file
      the line number for the first line of the body
      the body consisting of lines from the source file\n
    The body contains comment lines preceding the directive, the line with the
    directive, and optional lines following the directive up to the optional
    comments preceding the next directive.
    """
    # Discard the body emitted by the previous call.
    self.current = self.pending;
    self.pending = list();
    # If the current body is an include directive, then process it immediately.
    if self.current and re.match(r'\s*\.include\b',self.current[-1]):
      return self.current;
    # Loop until all of the files have been processed
    while self.fpStack or self.fpPending or self.pendingInclude:
      # Indicate when a new file is started.
      if 'started' not in self.fpStack[-1]:
        if  not self.current:
          self.fpStack[-1]['started'] = True;
          self.current.append(self.fpStack[-1]['fp'].name);
          self.current.append(0);
        return self.current;
      # Ensure the bodies in closed files are all emitted before continuing to
      # the next/enclosing file.
      if 'closed' in self.fpStack[-1]:
        # Provide end-of-file indication if there is not a pending body fragment.
        if not self.current:
          self.current.append(self.fpStack[-1]['fp'].name);
          self.current.append(-1);
          self.fpStack.pop();
        return self.current;
      # Handle a queued ".include" directive.
      if self.pendingInclude:
        # Don't open the include file until all previous content has been emitted.
        if self.current:
          return self.current;
        self.included.append(self.pendingInclude);
        fp_pending = None;
        for path in self.searchPaths:
          fullInclude = os.path.join(path,self.pendingInclude);
          if os.path.exists(fullInclude):
            fp_pending = open('%s/%s' % (path,self.pendingInclude),'rt');
            break;
        else:
          raise AsmException('%s not found' % self.pendingInclude);
        self.fpStack.append(dict(fp=fp_pending, line=0));
        self.pendingInclude = None;
        # Provide start-of-file indication.
        self.fpStack[-1]['started'] = True;
        self.current.append(fp_pending.name);
        self.current.append(0);
        return self.current;
      # Get the next file to process if fpStack is empty.
      if not self.fpStack:
        self.fpStack.append(dict(fp=self.fpPending.pop(0), line=0));
      # Process/continue processing the top file.
      fp = self.fpStack[-1];
      for line in fp['fp']:
        fp['line'] += 1;
        # Handle single-line directives.
        if re.match(r'\s*\.(IFDEF|IFNDEF|ELSE|ENDIF|include)\b',line):
          if not self.pending:
            self.pending.append(fp['fp'].name);
            self.pending.append(fp['line']);
          self.pending.append(line);
          if not self.current:
            self.current = self.pending;
            self.pending = list();
          return self.current;
        # Append empty and comment lines to the pending block.
        if re.match(r'\s*(;|$)', line):
          if not self.pending:
            self.pending.append(fp['fp'].name);
            self.pending.append(fp['line']);
          self.pending.append(line);
          continue;
        # See if the line starts with a directive.
        tokens = re.findall(r'\s*(\S+)',line);
        if self.ad.IsDirective(tokens[0]):
          if not self.pending:
            self.pending.append(fp['fp'].name);
            self.pending.append(fp['line']);
          self.pending.append(line);
          if self.current:
            return self.current;
          self.current = self.pending;
          self.pending = list();
          continue;
        # Otherwise, this line belongs to the body of the preceding directive.
        if not self.pending:
          self.pending.append(fp['fp'].name);
          self.pending.append(fp['line']);
        if not self.current:
          self.current += self.pending[0:2];
        self.current += self.pending[2:];
        self.current.append(line);
        self.pending = list();
      # Past the last line of the current file -- close it.
      self.fpStack[-1]['fp'].close();
      self.fpStack[-1]['closed'] = True;
      # Prepare to emit pending bodies if any.
      if not self.current:
        self.current = self.pending;
        self.pending = list();
    raise StopIteration;

  def AddSearchPath(self,path):
    """
    Use by the top level assembler to add search paths for opening included
    files.
    """
    self.searchPaths.append(path);

  def Include(self,filename):
    self.pendingInclude = filename;

################################################################################
#
# Parse strings into the desired types.
#
################################################################################

def ParseNumber(inString):
  """
  Test for recognized integer values and return the value if recognized,
  otherwise return None.
  """
  # look for single-digit 0
  if inString == '0':
    return 0;
  # look for a binary value
  a = re.match(r'0b[01_]+$',inString);
  if a:
    b = re.sub(r'_','',a.group(0)[2:]);
    return int(b,2);
  # look for an octal value
  a = re.match(r'0[0-7_]+$',inString);
  if a:
    return int(a.group(0)[1:],8);
  # look for decimal value
  a = re.match(r'[+\-]?[1-9_]\d*$',inString);
  if a:
    return int(a.group(0),10);
  # look for a hex value
  a = re.match(r'0x[0-9A-Fa-f_]+$',inString);
  if a:
    return int(a.group(0)[2:],16);
  # Everything else is an error
  return None;

def ParseChar(inchar):
  """
  Parse single characters including escaped characters.  Return the character
  value and the number of characters in the input string matched.
  """
  if re.match(r'\\[0-7]{3}',inchar):
    return (int(inchar[1:4],8),4,);
  elif re.match(r'\\[0-7]{2}',inchar):
    return (int(inchar[1:3],8),3,);
  elif re.match(r'\\[0-7]{1}',inchar):
    return (int(inchar[1],8),2,);
  elif re.match(r'\\[xX][0-9A-Fa-f]{2}',inchar):
    return (int(inchar[2:4],16),4,);
  elif re.match(r'\\[xX][0-9A-Fa-f]{1}',inchar):
    return (int(inchar[2],16),3,);
  elif re.match(r'\\.',inchar):
    if inchar[1] == 'a':        # bell ==> control-G
      return (7,2,);
    elif inchar[1] == 'b':      # backspace ==> control-H
      return (8,2,);
    elif inchar[1] == 'f':      # form feed ==> control-L
      return (12,2,);
    elif inchar[1] == 'n':      # line feed ==> control-J
      return (10,2,);
    elif inchar[1] == 'r':      # carriage return ==> control-M
      return (13,2,);
    elif inchar[1] == 't':      # horizontal tab ==> control-I
      return (9,2,);
    else:                       # unrecognized escaped character ==> return that character
      return (ord(inchar[1]),2,);
  else:
    return (ord(inchar[0]),1,);

def ParseString(inString):
  """
  Parse strings recognized by the assembler.\n
  A string consists of the following:
    an optional count/termination character -- one of CNc
    a starting double-quote character
    the body of the string including escape sequences
    a terminating double-quote character
  Errors are indicated by returning the location (an integer) within the string
  where the error occurs.
  """
  # Detect optional count/termination character.
  ix = 1 if inString[0] in 'CNc' else 0;
  # Ensure the required start double quote is preset.
  if inString[ix] != '"' or inString[-1] != '"':
    raise Exception('Program Bug -- missing one or more double quotes around string');
  ix = ix + 1;
  # Convert the characters and escape sequences in the string to a list of their
  # integer values.
  outString = list();
  while ix < len(inString)-1:
    (thisChar,thisLen,) = ParseChar(inString[ix:-1]);
    outString.append(thisChar);
    ix += thisLen;
  # Insert the optional character count or append the optional nul terminating
  # character.
  if inString[0] == 'C':
    outString.insert(0,len(outString));
  elif inString[0] == 'N':
    outString.append(0);
  elif inString[0] == 'c':
    outString.insert(0,len(outString)-1);
  # That's all.
  return outString;

def ParseToken(ad,fl_loc,col,raw,allowed):
  """
  Examine the raw tokens and convert them into dictionary objects consisting of
  the following:
    type        the type of token
    value       the value of the token
                this can be the name of a symbol, a numeric value, a string body, ...
    loc         start location of the token
                this is is required by subsequent stages of the assembler for
                error messages
    argument    optional entry required for macros arguments
    range       optional entry required when a range is provided for a parameter\n
  The token type is compared against the allowed tokens.\n
  Detect syntax errors and display error messages consisting of the error and
  the location within the file where the error occurs.
  """
  flc_loc = fl_loc + ':' + str(col+1);
  # look for instructions
  # Note:  Do this before anything else because instructions can be a
  #        strange mix of symbols.
  if ad.IsInstruction(raw):
    if 'instruction' not in allowed:
      raise AsmException('instruction "%s" not allowed at %s' % (raw,flc_loc));
    return dict(type='instruction', value=raw, loc=flc_loc);
  # look for computation
  a = re.match(r'\${\S+}$',raw);
  if a:
    if 'singlevalue' not in allowed:
      raise AsmException('Computed value not allowed at %s' % flc_loc);
    try:
      tParseNumber = eval(raw[2:-1],ad.SymbolDict());
    except:
      raise AsmException('Malformed computed value at %s: "%s"' % (flc_loc,raw,));
    if type(tParseNumber) != int:
      raise AsmException('Malformed single-byte value at %s' % flc_loc);
    return dict(type='value', value=tParseNumber, loc=flc_loc);
  # look for a repeated single-byte numeric value (N*M where M is the repeat count)
  matchString=r'(0|0b[01_]+|0[0-7]+|[+\-]?[1-9]\d*|0x[0-9A-Fa-f]{1,2})\*([1-9]\d*|C_\w+|\$\{\S+\})$';
  a = re.match(matchString,raw);
  if a:
    if 'multivalue' not in allowed:
      raise AsmException('Multi-byte value not allowed at %s' % flc_loc);
    b = re.findall(matchString,a.group(0));
    if not b:
      raise Exception('Program Bug -- findall failed after match worked');
    b = b[0];
    try:
      tParseNumber = ParseNumber(b[0]);
    except:
      raise AsmException('Malformed multi-byte value at %s' % (fl_loc + ':' + str(col+1)));
    tValue = list();
    fl_loc2 = fl_loc+':'+str(col+1+len(b[0])+1);
    if re.match(r'[1-9]',b[1]):
      repeatCount = int(b[1]);
    elif re.match(r'C_',b[1]):
      if not ad.IsConstant(b[1]):
        raise AsmException('Unrecognized symbol "%s" at %s' % (b[1],fl_loc2,));
      ix = ad.symbols['list'].index(b[1]);
      if len(ad.symbols['body'][ix]) != 1:
        raise asmDef.AsmException('constant can only be one byte at %s' % fl_loc2);
      repeatCount = ad.symbols['body'][ix][0];
    elif re.match(r'\$',b[1]):
      repeatCount = eval(b[1][2:-1],ad.SymbolDict());
    else:
      raise Exception('Program Bug -- unrecognized repeat count');
    if repeatCount <= 0:
      raise AsmException('Repeat count must be positive at %s' % fl_loc2);
    for ix in range(repeatCount):
      tValue.append(tParseNumber);
    return dict(type='value', value=tValue, loc=flc_loc);
  # look for a single-byte numeric value
  a = re.match(r'(0|0b[01_]+|0[0-7]+|[+\-]?[1-9]\d*|0x[0-9A-Fa-f]+)$',raw);
  if a:
    if 'singlevalue' not in allowed:
      raise AsmException('Value not allowed at %s' % flc_loc);
    try:
      tParseNumber = ParseNumber(raw);
    except:
      raise AsmException('Malformed single-byte value at %s' % flc_loc);
    return dict(type='value', value=tParseNumber, loc=flc_loc);
  # capture double-quoted strings
  if re.match(r'[CNc]?"',raw):
    if 'string' not in allowed:
      raise AsmException('String not allowed at %s' % flc_loc);
    parsedString = ParseString(raw);
    if type(parsedString) == int:
      raise AsmException('Malformed string at %s' % (fl_loc + ':' + str(col+parsedString)));
    return dict(type='value', value=parsedString, loc=flc_loc);
  # capture single-quoted character
  if raw[0] == "'":
    if 'singlevalue' not in allowed:
      raise AsmException('Character not allowed at %s' % flc_loc);
    (thisChar,thisLen,) = ParseChar(raw[1:-1]);
    if len(raw) != thisLen+2:
      raise AsmException('Malformed \'.\' in %s' % flc_loc);
    return dict(type='value', value=thisChar, loc=flc_loc);
  # look for directives
  if ad.IsDirective(raw):
    if 'directive' not in allowed:
      raise AsmException('Directive not allowed at %s' % flc_loc);
    return dict(type='directive', value=raw, loc=flc_loc);
  # look for macros
  # Note:  Macro arguments can contain a single layer of macros.
  a = re.match(r'\.[A-Za-z]',raw);
  if a:
    b = re.match(r'\.[^(]+',raw);
    if not ad.IsMacro(b.group(0)):
      raise AsmException('Unrecognized directive or macro at %s:%d' % (fl_loc,col+1,));
    if ('macro' not in allowed) and not ('singlemacro' in allowed and ad.IsSingleMacro(b.group(0))):
      raise AsmException('Macro "%s" not allowed at %s:%d' % (b.group(0),fl_loc,col+1,));
    macroArgs = list();
    if len(b.group(0)) == len(raw):
      pass;
    elif (raw[len(b.group(0))] != '(') or (raw[-1] != ')'):
      raise AsmException('Malformed macro invokaction "%s" at %s:%d' % (raw,fl_loc,col+1,));
    else:
      tcol = len(b.group(0))+1;
      while tcol < len(raw):
        c = re.match(r'[^,(]*(\([^)]*\))?',raw[tcol:-1]);
        macroArgs.append(c.group(0));
        tcol += len(c.group(0))+1;
    nArgs = ad.MacroNumberArgs(b.group(0))
    if len(macroArgs) not in nArgs:
      raise AsmException('Wrong number of arguments to macro "%s" at %s:%d' % (b.group(0),fl_loc,col+1));
    while len(macroArgs) < nArgs[-1]:
      macroArgs.append(ad.MacroDefault(b.group(0),len(macroArgs)));
    outArgs = list();
    tcol = col + len(b.group(0)) + 1;
    for ixArg in range(len(macroArgs)):
      outArgs.append(ParseToken(ad,fl_loc,tcol,macroArgs[ixArg],ad.MacroArgTypes(b.group(0),ixArg)));
      tcol += len(macroArgs[ixArg]) + 1;
    return dict(type='macro', value=b.group(0), loc=fl_loc + ':' + str(col+1), argument=outArgs);
  # look for a label definition
  a = re.match(r':[A-Za-z]\w*$',raw);
  if a:
    if 'label' not in allowed:
      raise AsmException('Label not allowed at %s' % flc_loc);
    return dict(type='label', value=raw[1:], loc=flc_loc);
  # look for parameters with range specification
  a = re.match('[LG]_\w+[[]\d+\+?:\d+]$',raw);
  if a:
    if 'symbol' not in allowed:
      raise AsmException('Symbol not allowed at %s' % flc_loc);
    a = re.findall('([LG]_\w+)([[].*)',raw)[0];
    return dict(type='symbol', value=a[0], loc=flc_loc, range=a[1]);
  # look for symbols
  # Note:  This should be the last check performed as every other kind of
  #        token should be recognizable
  a = re.match(r'[A-Za-z]\w*$',raw);
  if a:
    if 'symbol' not in allowed:
      raise AsmException('Symbol not allowed at %s' % flc_loc);
    return dict(type='symbol', value=a.group(0), loc=flc_loc);
  # anything else is an error
  raise AsmException('Malformed entry at %s:  "%s"' % (flc_loc,raw,));

################################################################################
#
# Extract the tokens from a block of code.
#
# These blocks of code should be generated by FileBodyIterator.
#
################################################################################

def RawTokens(ad,filename,startLineNumber,lines):
  """
  Extract the list of tokens from the provided list of lines.
  Convert the directive body into a list of individual tokens.\n
  Tokens are directive names, symbol names, values, strings, labels, etc.\n
  The return is a list of the tokens in the sequence they are encountered.  Each
  of these tokens is a dictionary object constructed by ParseToken.
  """
  allowed = [
              'instruction',
              'label',
              'macro',
              'multivalue',
              'singlevalue',
              'string',
              'symbol'
            ];
  ifstack = list();
  tokens = list();
  lineNumber = startLineNumber - 1;
  for line in lines:
    lineNumber = lineNumber + 1;
    fl_loc = '%s:%d' % (filename,lineNumber);
    col = 0;
    spaceFound = True;
    while col < len(line):
      flc_loc = fl_loc + ':' + str(col+1);
      # Identify and then ignore white-space characters.
      if re.match(r'\s',line[col:]):
        spaceFound = True;
        col = col + 1;
        continue;
      # Ensure tokens start on new lines or are separated by spaces.
      if not spaceFound:
        raise AsmException('Missing space in %s:%d' % (fl_loc,col+1));
      spaceFound = False;
      # Ignore comments.
      if line[col] == ';':
        break;
      # Catch N"" string.
      if re.match(r'N""',line[col:]):
        a = re.match(r'N""',line[col:]);
      # Catch strings.
      elif re.match(r'[CNc]?"',line[col:]):
        a = re.match(r'[CNc]?"([^\\"]|\\.)+"',line[col:]);
        if not a:
          raise AsmException('Malformed string at %s' % flc_loc);
      # Catch single-quoted characters
      elif re.match(r'\'',line[col:]):
        a = re.match(r'\'(.|\\.|\\[xX][0-9A-Fa-f]{1,2}|\\[0-7]{1,3})\'',line[col:]);
        if not a:
          raise AsmException('Malformed \'.\' at %s' % flc_loc);
      else:
        # Everything else is a white-space delimited token.
        a = re.match(r'\S+',line[col:]);
      # Get the candidate token.
      candToken = a.group(0);
      # Catch conditional code inclusion constructs before parsing the token
      if candToken == '.else':
        if not ifstack:
          raise AsmException('Unmatched ".else" at %s' % flc_loc);
        ifstack[-1] = not ifstack[-1];
        col += 5;
        continue;
      if candToken == '.endif':
        if not ifstack:
          raise AsmException('Unmatched ".endif" at %s' % flc_loc);
        ifstack.pop();
        col += 6;
        continue;
      elif re.match(r'\.ifdef\(',candToken):
        a = re.findall(r'\.ifdef\((\w+)\)$',candToken);
        if not a:
          raise AsmException('Malformed ".ifdef" at %s' % flc_loc);
        ifstack.append(ad.IsSymbol(a[0]));
        col += 8+len(a[0]);
        continue;
      elif re.match(r'\.ifndef\(',candToken):
        a = re.findall(r'\.ifndef\((\w+)\)$',candToken);
        if not a:
          raise AsmException('Malformed ".ifndef" at %s' % flc_loc);
        ifstack.append(not ad.IsSymbol(a[0]));
        col += 9+len(a[0]);
        continue;
      if ifstack and not ifstack[-1]:
        col += len(candToken);
        continue;
      # Determine which kinds of tokens are allowed at this location in the
      # directive body.
      if not tokens:
        selAllowed = 'directive';
      else:
        selAllowed = allowed;
      # Append the parsed token to the list of tokens.
      tokens.append(ParseToken(ad,fl_loc,col,candToken,selAllowed));
      col += len(candToken);
  if ifstack:
    raise AsmException('%d unmatched conditionals at line %d' % (len(ifstack),lineNumber,));
  return tokens;
