################################################################################
#
# Copyright 2012-2014, Sinclair R.F., Inc.
#
# Assembly language definitions for SSBCC 9x8.
#
################################################################################

import copy
import os
import re
import string
import sys
import types

import asmDef

class asmDef_9x8:
  """
  Class for core-specific opcodes, macros, etc. for core/9x8.
  """

  ################################################################################
  #
  # External interface to the directives.
  #
  ################################################################################

  def IsDirective(self,name):
    """
    Indicate whether or not the string "name" is a directive.
    """
    return name in self.directives['list'];

  ################################################################################
  #
  # Record symbols
  #
  ################################################################################

  def AddSymbol(self,name,stype,body=None):
    """
    Add the named global symbol to the list of symbols including its mandatory
    type and an optional body.\n
    Note:  Symbols include memory names, variables, constants, defines,
           functions, parameters, inports, outports, ...
    """
    if self.IsSymbol(name):
      raise Exception('Program Bug -- name "%s" already exists is symbols' % name);
    self.symbols['list'].append(name);
    self.symbols['type'].append(stype);
    self.symbols['body'].append(body);

  def IsSymbol(self,name):
    return name in self.symbols['list'];

  def SymbolDict(self):
    """
    Return a dict object usable by the eval function with the currently defines
    symbols for constants, variables, memory lengths, stack lengths, and signal
    lengths.
    """
    t = dict();
    for ixSymbol in range(len(self.symbols['list'])):
      name = self.symbols['list'][ixSymbol];
      stype = self.symbols['type'][ixSymbol];
      if stype == 'constant':
        t[name] = self.symbols['body'][ixSymbol][0];
      elif stype == 'variable':
        t[name] = self.symbols['body'][ixSymbol]['start'];
    sizes=dict();
    for name in self.memoryLength:
      sizes[name] = self.memoryLength[name];
    for name in self.stackLength:
      sizes[name] = self.stackLength[name];
    t['size'] = sizes;
    return t;

  ################################################################################
  #
  # Configure the class for identifying and processing macros.
  #
  ################################################################################

  def AddMacro(self,name,macroLength,args,doc=None):
    """
    Add a macro to the list of recognized macros.
      name              string with the name of the macro
      macroLength       number of instructions the macro expands to
                        Note:  A negative value means that the macro has a
                               variable length (see MacroLength below)
      args              list of the arguments
                        each element of this list is an array of strings specifying the following:
                          1.  If the first element is the empty string, then
                              there is no default value for the argument,
                              otherwise the listed string is the default
                              value of the optional argument.
                          2.  The remaining elements of the list are the types
                              of arguments that can be accepted for the
                              required or optional arguments.
                        Note:  Only the last list in args is allowed to
                               indicate an optional value for that argument.
      doc               doc string for the macro

    Also record the allowed number of allowed arguments to the macro.
    """
    if name in self.macros['list']:
      raise Exception('Program Bug -- name "%s" has already been listed as a macro' % name);
    self.macros['list'].append(name);
    self.macros['length'].append(macroLength);
    self.macros['args'].append(args);
    self.macros['doc'].append(doc)
    # Compute the range of the number of allowed arguments by first counting
    # the number of required arguments and then determining whether or not
    # there is at most one optional argument.
    nRequired = 0;
    while (nRequired < len(args)) and (args[nRequired][0] == ''):
      nRequired = nRequired + 1;
    if nRequired < len(args)-1:
      raise Exception('Program Bug -- Only the last macro argument can be optional');
    self.macros['nArgs'].append(range(nRequired,len(args)+1));

  def AddMacroSearchPath(self,path):
    self.macroSearchPaths.append(path);

  def AddUserMacro(self,macroName,macroSearchPaths=None):
    """
    Add a user-defined macro by processing the associated Python script.
      macroName         name of the macro
                        The associated Python script must be named
                        <macroName>.py and must be in the project directory, an
                        included directory, or must be one of the macros
                        provided in "macros" subdirectory of this directory.
    """
    if not macroSearchPaths:
      macroSearchPaths = self.macroSearchPaths;
    for testPath in macroSearchPaths:
      fullMacro = os.path.join(testPath,'%s.py' % macroName);
      if os.path.isfile(fullMacro):
        break;
    else:
      raise asmDef.AsmException('Definition for macro "%s" not found' % macroName);
    execfile(fullMacro);
    exec('%s(self)' % macroName);
    exec('docString = %s.__doc__' % macroName)
    if docString and not self.macros['doc'][-1]:
      self.macros['doc'][-1] = docString

  def IsBuiltInMacro(self,name):
    """
    Indicate if the macro is built-in to the assembler or is taken from the
    ./macros directory.
    """
    return name in self.macros['builtIn'];

  def IsMacro(self,name):
    """
    Indicate whether or not the string "name" is a recognized macro.
    """
    return name in self.macros['list'];

  def IsSingleMacro(self,name):
    """
    Indicate whether or not the macro is only one instruction long.
    """
    if name not in self.macros['list']:
      raise Exception('Program Bug -- name "%s" is not a macro' % name);
    ix = self.macros['list'].index(name);
    return (self.macros['length'][ix] == 1);

  def MacroArgTypes(self,name,ixArg):
    """
    Return the list of allowed types for the macro name for argument ixArg.
    """
    if name not in self.macros['list']:
      raise Exception('Program Bug -- name "%s" is not a macro' % name);
    ix = self.macros['list'].index(name);
    return self.macros['args'][ix][ixArg][1:];

  def MacroDefault(self,name,ixArg):
    """
    Return the default argument for the macro name for argument ixArg.
    """
    if name not in self.macros['list']:
      raise Exception('Program Bug -- name "%s" is not a macro' % name);
    ix = self.macros['list'].index(name);
    return self.macros['args'][ix][ixArg][0];

  def MacroLength(self,token):
    """
    Return the length of fixed-length macros or compute and return the length
    of variable-length macros.
    """
    if token['value'] not in self.macros['list']:
      raise Exception('Program Bug -- name "%s" is not a macro' % token['value']);
    ix = self.macros['list'].index(token['value']);
    length = self.macros['length'][ix];
    if type(length) == int:
      return length;
    elif type(length) == types.FunctionType:
      return length(self,token['argument']);
    else:
      raise Exception('Program Bug -- Unrecognized variable length macro "%s"' % token['value']);

  def MacroNumberArgs(self,name):
    """
    Return the range of the number of allowed arguments to the named macro.
    """
    if name not in self.macros['list']:
      raise Exception('Program bug -- name "%s" is not a macro' % name);
    ix = self.macros['list'].index(name);
    return self.macros['nArgs'][ix];

  ################################################################################
  #
  # Configure the class for processing instructions.
  #
  ################################################################################

  def AddInstruction(self,name,opcode):
    """
    Add an instruction to the list of recognized instructions.
    """
    self.instructions['list'].append(name);
    self.instructions['opcode'].append(opcode);

  def IsInstruction(self,name):
    """
    Indicate whether or not the argument is an instruction.
    """
    return name in self.instructions['list'];

  def InstructionOpcode(self,name):
    """
    Return the opcode for the specified instruction.
    """
    if not self.IsInstruction(name):
      raise Exception('Program Bug:  "%s" not in instruction list' % name);
    ix = self.instructions['list'].index(name);
    return self.instructions['opcode'][ix];

  ################################################################################
  #
  # Register input and output port names and addresses.
  #
  ################################################################################

  def IsConstant(self,name):
    """
    Indicate whether or not the named symbol is an inport.
    """
    if not self.IsSymbol(name):
      return False;
    ix = self.symbols['list'].index(name);
    return self.symbols['type'][ix] == 'constant';

  def IsInport(self,name):
    """
    Indicate whether or not the named symbol is an inport.
    """
    if not self.IsSymbol(name):
      return False;
    ix = self.symbols['list'].index(name);
    return self.symbols['type'][ix] == 'inport';

  def IsOutport(self,name):
    """
    Indicate whether or not the named symbol is an outport.
    """
    if not self.IsSymbol(name):
      return False;
    ix = self.symbols['list'].index(name);
    return self.symbols['type'][ix] == 'outport';

  def IsOutstrobe(self,name):
    """
    Indicate whether or not the named symbol is a strobe-only outport.
    """
    if not self.IsSymbol(name):
      return False;
    ix = self.symbols['list'].index(name);
    return self.symbols['type'][ix] == 'outstrobe';

  def IsParameter(self,name):
    """
    Indicate whether or not the named symbol is a parameter.
    """
    if not self.IsSymbol(name):
      return False;
    ix = self.symbols['list'].index(name);
    return self.symbols['type'][ix] == 'parameter';

  def InportAddress(self,name):
    """
    Return the address of the named inport.
    """
    if not self.IsInport(name):
      raise Exception('Program Bug -- "%s" is not an inport' % name);
    ix = self.symbols['list'].index(name);
    return self.symbols['body'][ix];

  def OutportAddress(self,name):
    """
    Return the address of the named outport.
    """
    if not self.IsOutport(name) and not self.IsOutstrobe(name):
      raise Exception('Program Bug -- "%s" is not an outport' % name);
    ix = self.symbols['list'].index(name);
    return self.symbols['body'][ix];

  def RegisterInport(self,name,address):
    """
    Add the named inport to the list of recognized symbols and record its
    address as the body of the inport.
    """
    if self.IsSymbol(name):
      raise Exception('Program Bug -- repeated symbol name "%s"' % name);
    self.AddSymbol(name,'inport',address);

  def RegisterOutport(self,name,address):
    """
    Add the named outport to the list of recognized symbols and record its
    address as the body of the outport.
    """
    if self.IsSymbol(name):
      raise Exception('Program Bug -- repeated symbol name "%s"' % name);
    self.AddSymbol(name,'outport',address);

  def RegisterOutstrobe(self,name,address):
    """
    Add the named outport to the list of recognized symbols and record its
    address as the body of the strobe-only outports.
    """
    if self.IsSymbol(name):
      raise Exception('Program Bug -- repeated symbol name "%s"' % name);
    self.AddSymbol(name,'outstrobe',address);

  def RegisterParameterName(self,name):
    """
    Add the named parameter to the list of regognized symbols.\n
    Note:  Parameters do not have a body.
    """
    if self.IsSymbol(name):
      raise Exception('Program Bug -- repeated symbol name "%s"' % name);
    self.AddSymbol(name,'parameter');

  def RegisterMemoryLength(self,name,length):
    """
    Record the length of the specified memory.\n
    Note:  This is used to evaluate "size[name]" in "${...}" expressions.
    """
    self.memoryLength[name] = length;

  def RegisterStackLength(self,name,length):
    """
    Record the length of the specified stack.\n
    Note:  This is used to evaluate "size[name]" in "${...}" expressions.
    """
    self.stackLength[name] = length;

  ################################################################################
  #
  # Check a list of raw tokens to ensure their proper format.
  #
  ################################################################################

  def CheckSymbolToken(self,name,allowableTypes,loc):
    """
    Syntax check for symbols, either by themselves or as a macro argument.\n
    Note:  This is used by CheckRawTokens.
    """
    if not self.IsSymbol(name):
      raise asmDef.AsmException('Undefined symbol "%s" at %s' % (name,loc));
    ixName = self.symbols['list'].index(name);
    if self.symbols['type'][ixName] not in allowableTypes:
      raise asmDef.AsmException('Illegal symbol at %s' % loc);

  def CheckRawTokens(self,rawTokens):
    """
    Syntax check for directive bodies.\n
    Note:  This core-specific method is called by the top-level assembler after
           the RawTokens method.
    """
    # Ensure the first token is a directive.
    firstToken = rawTokens[0];
    if firstToken['type'] != 'directive':
      raise Exception('Program Bug triggered at %s' % firstToken['loc']);
    # Ensure the directive bodies are not too short.
    if (firstToken['value'] in ('.main','.interrupt',)) and not (len(rawTokens) > 1):
      raise asmDef.AsmException('"%s" missing body at %s' % (firstToken['value'],firstToken['loc'],));
    if (firstToken['value'] in ('.define','.macro',)) and not (len(rawTokens) == 2):
      raise asmDef.AsmException('body for "%s" directive must have exactly one argument at %s' % (firstToken['value'],firstToken['loc'],));
    if (firstToken['value'] in ('.constant','.function','.memory','.variable',)) and not (len(rawTokens) >= 3):
      raise asmDef.AsmException('body for "%s" directive too short at %s' % (firstToken['value'],firstToken['loc'],));
    # Ensure no macros and no instructions in non-"functions".
    # Byproduct:  No labels allowed in non-"functions".
    if firstToken['value'] not in ('.function','.interrupt','.main',):
      for token in rawTokens[2:]:
        if (token['type'] == 'macro'):
          raise asmDef.AsmException('Macro not allowed in directive at %s' % token['loc']);
        if token['type'] == 'instruction':
          raise asmDef.AsmException('Instruction not allowed in directive at %s' % token['loc']);
    # Ensure local labels are defined and used.
    labelDefs = list();
    for token in rawTokens:
      if token['type'] == 'label':
        name = token['value'];
        if name in labelDefs:
          raise asmDef.AsmException('Repeated label definition "%s" at %s' % (name,token['loc'],));
        labelDefs.append(name);
    labelsUsed = list();
    for token in rawTokens:
      if (token['type'] == 'macro') and (token['value'] in ('.jump','.jumpc',)):
        target = token['argument'][0]['value'];
        if target not in labelDefs:
          raise asmDef.AsmException('label definition for target missing at %s' % token['loc']);
        labelsUsed.append(target);
    labelsUnused = set(labelDefs) - set(labelsUsed);
    if labelsUnused:
      raise asmDef.AsmException('Unused label(s) %s in body %s' % (labelsUnused,firstToken['loc']));
    # Ensure referenced symbols are already defined (other than labels and
    # function names for call and jump macros).
    checkBody = False;
    if (rawTokens[0]['type'] == 'directive') and (rawTokens[0]['value'] in ('.function','.interrupt','.main',)):
      checkBody = True;
    if checkBody:
      for token in rawTokens[2:]:
        if token['type'] == 'symbol':
          allowableTypes = ('constant','inport','macro','outport','outstrobe','parameter','variable',);
          self.CheckSymbolToken(token['value'],allowableTypes,token['loc']);
        elif token['type'] == 'macro':
          allowableTypes = ('RAM','ROM','constant','inport','outport','outstrobe','parameter','variable',);
          ixFirst = 1 if token['value'] in self.MacrosWithSpecialFirstSymbol else 0;
          for arg in  token['argument'][ixFirst:]:
            if arg['type'] == 'symbol':
              self.CheckSymbolToken(arg['value'],allowableTypes,arg['loc']);
    # Ensure the main body ends in a ".jump".
    lastToken = rawTokens[-1];
    if firstToken['value'] == '.main':
      if (lastToken['type'] != 'macro') or (lastToken['value'] != '.jump'):
        raise asmDef.AsmException('.main body does not end in ".jump" at %s' % lastToken['loc']);
    # Ensure functions and interrupts end in a ".jump" or ".return".
    if firstToken['value'] in ('.function','.interrupt',):
      if (lastToken['type'] != 'macro') or (lastToken['value'] not in ('.jump','.return',)):
        raise asmDef.AsmException('Last entry in ".function" or ".interrupt" must be a ".jump" or ".return" at %s' % lastToken['loc']);

  ################################################################################
  #
  # fill in symbols, etc. in the list of raw tokens.
  #
  ################################################################################

  def ByteList(self,rawTokens,limit=False):
    """
    Return either (1) a list comprised of a single token which may not be a
    byte or (2) a list comprised of multiple tokens, each of which is a single
    byte.\n
    Note:  This is called by FillRawTokens.\n
    Note:  Multi-value lists must be single-byte values (i.e., in the range -128 to 255)
    """
    if len(rawTokens) > 1:
      limit = True;
    values = list();
    for token in rawTokens:
      if token['type'] == 'symbol':
        ix = self.symbols['list'].index(token['value']);
        symbolType = self.symbols['type'][ix];
        if symbolType != 'constant':
          raise asmDef.AsmException('Illegal symbol "%s" at %s' % (token['value'],token['loc'],));
        value = self.symbols['body'][ix];
      elif token['type'] == 'value':
        value = token['value'];
      else:
        raise asmDef.AsmException('Illegal token "%s" with value "%s" at %s' % (token['type'],token['value'],token['loc'],));
      if type(value) == int:
        value = [value];
      else:
        limit = True;
      for v in value:
        if limit and not (-128 <= v < 256):
          raise asmDef.AsmException('Out-of-rarnge value "%d" at %s' % (v,token['loc'],))
        values.append(v);
    return values;

  def ExpandSymbol(self,token,singleValue):
    """
    Convert the token for a symbol into a token for its specific type.
    Optionally ensure constants expand to a single byte.  For parameters,
    ensure that a range is provided.\n
    Note:  Symbols must be defined before the directive bodies in which they
           are used.\n
    Note:  This is called in two spots.  The first is ExpandTokens, where
           isolated symbols are processed, for example to get the value of a
           constant.  The second is in EmitOptArg where symbols in arguments to
           macros are expanded (this allows the macro-specific processing to
           identify labels vs. symbols).
    """
    if not self.IsSymbol(token['value']):
      raise asmDef.AsmException('Symbol "%s" not in symbol list at %s' %(token['value'],token['loc'],));
    ix = self.symbols['list'].index(token['value']);
    symbolType = self.symbols['type'][ix];
    if symbolType == 'RAM':
      return dict(type='RAM', value=token['value'], loc=token['loc']);
    elif symbolType == 'ROM':
      return dict(type='ROM', value=token['value'], loc=token['loc']);
    elif symbolType == 'constant':
      if singleValue:
        thisBody = self.symbols['body'][ix];
        if len(thisBody) != 1:
          raise asmDef.AsmException('Constant "%s" must evaluate to a single byte at %s' % (token['value'],token['loc'],))
        thisBody = thisBody[0];
        if not (-128 <= thisBody < 256):
          raise asmDef.AsmException('Constant "%s" must be a byte value at %s' % (token['value'],token['loc'],));
      return dict(type='constant', value=token['value'], loc=token['loc']);
    elif symbolType == 'inport':
      return dict(type='inport', value=token['value'], loc=token['loc']);
    elif symbolType == 'outport':
      return dict(type='outport', value=token['value'], loc=token['loc']);
    elif symbolType == 'outstrobe':
      return dict(type='outstrobe', value=token['value'], loc=token['loc']);
    elif symbolType == 'parameter':
      if 'range' in token:
        trange = token['range'];
      else:
        trange = '[0+:8]';
      return dict(type='parameter', value=token['value'], range=trange, loc=token['loc']);
    elif symbolType == 'variable':
      return dict(type='variable', value=token['value'], loc=token['loc']);
    else:
      raise Exception('Program Bug -- unrecognized symbol type "%s"' % symbolType);

  def ExpandTokens(self,rawTokens):
    """
    Compute the relative addresses for tokens within function bodies.\n
    The return is a list of the tokens in the function body, each of which has
    a type, value, offset (relative address), and location within the source
    code.  Macro types also have the list of arguments provided to the macro.
    """
    tokens = list();
    offset = 0;
    for token in rawTokens:
      # insert labels
      if token['type'] == 'label':
        tokens.append(dict(type=token['type'], value=token['value'], offset=offset, loc=token['loc']));
        # labels don't change the offset
      # append instructions
      elif token['type'] == 'instruction':
        tokens.append(dict(type=token['type'], value=token['value'], offset=offset, loc=token['loc']));
        offset = offset + 1;
      # append values
      elif token['type'] == 'value':
        if type(token['value']) == int:
          tokens.append(dict(type=token['type'], value=token['value'], offset=offset, loc=token['loc']));
          offset = offset + 1;
        else:
          revTokens = copy.copy(token['value']);
          revTokens.reverse();
          for lToken in revTokens:
            tokens.append(dict(type=token['type'], value=lToken, offset=offset, loc=token['loc']));
            offset = offset + 1;
      # append macros
      elif token['type'] == 'macro':
        tokens.append(dict(type=token['type'], value=token['value'], offset=offset, argument=token['argument'], loc=token['loc']));
        offset = offset + self.MacroLength(token);
      # interpret and append symbols
      elif token['type'] == 'symbol':
        newToken = self.ExpandSymbol(token,singleValue=False);
        newToken['offset'] = offset;
        newToken['loc'] = token['loc'];
        tokens.append(newToken);
        if token['type'] == 'constant':
          ix = self.symbols['list'].index(newToken['value']);
          offset = offset + len(self.symbols['body'][ix]);
        else:
          offset = offset + 1;
      # anything else is a program bug
      else:
        raise Exception('Program bug:  unexpected token type "%s"' % token['type']);
    return dict(tokens=tokens, length=offset);

  def FillRawTokens(self,rawTokens):
    """
    Do one of the following as required for the specified directive:
      .constant         add the constant and its body to the list of symbols
      .function         add the function and its body, along with the relative
                        addresses, to the list of symbols
      .interrupt        record the function body and relative addresses
      .macro            register the user-defined macro
      .main             record the function body and relative addresses
      .memory           record the definition of the memory and make it current
                        for subsequent variable definitions.
      .variable         add the variable and its associated memory, length, and
                        initial values to the list of symbols
    """
    firstToken = rawTokens[0];
    secondToken = rawTokens[1];
    # Perform syntax check common to several directives.
    if firstToken['value'] in ('.constant','.function','.variable',):
      if secondToken['type'] != 'symbol':
        raise asmDef.AsmException('Expected symbol, not "%s", at %s' % (secondToken['value'],secondToken['loc'],));
      if self.IsSymbol(secondToken['value']):
        raise asmDef.AsmException('Symbol "%s" already defined at %s' % (secondToken['value'],secondToken['loc'],));
    # Perform syntax-specific processing.
    if firstToken['value'] == '.constant':
      byteList = self.ByteList(rawTokens[2:]);
      self.AddSymbol(secondToken['value'],'constant',body=byteList);
    # Process ".define" directive
    elif firstToken['value'] == '.define':
      self.AddSymbol(secondToken['value'],'define');
    # Process ".function" definition.
    elif firstToken['value'] == '.function':
      self.AddSymbol(secondToken['value'],'function',self.ExpandTokens(rawTokens[2:]));
    # Process ".interrupt" definition.
    elif firstToken['value'] == '.interrupt':
      if self.interrupt:
        raise asmDef.AsmException('Second definition of ".interrupt" at %s' % firstToken['loc']);
      self.interrupt = self.ExpandTokens(rawTokens[1:]);
    # Process user-defined macros (the ".macro XXX" directive can be repeated for non-built-in macros).
    elif firstToken['value'] == '.macro':
      macroName = secondToken['value'];
      fullMacroName = '.' + macroName;
      if fullMacroName in self.directives:
        raise asmDef.AsmException('Macro "%s" is a directive at %s' % (fullMacroName,secondToken['loc'],));
      if fullMacroName in self.instructions:
        raise asmDef.AsmException('Macro "%s" is an instruction at %s' % (fullMacroName,secondToken['loc'],));
      if self.IsBuiltInMacro(fullMacroName):
        raise asmDef.AsmException('Macro "%s" is a built-in macro at %s' % (fullMacroName,secondToken['loc'],));
      if fullMacroName not in self.macros['list']:
        self.AddUserMacro(macroName);
    # Process ".main" definition.
    elif firstToken['value'] == '.main':
      if self.main:
        raise asmDef.AsmException('Second definition of ".main" at %s' % firstToken['loc']);
      self.main = self.ExpandTokens(rawTokens[1:]);
    # Process ".memory" declaration.
    elif firstToken['value'] == '.memory':
      if len(rawTokens) != 3:
        raise asmDef.AsmException('".memory" directive requires exactly two arguments at %s' % firstToken['loc']);
      if (secondToken['type'] != 'symbol') or (secondToken['value'] not in ('RAM','ROM',)):
        raise asmDef.AsmException('First argument to ".memory" directive must be "RAM" or "RAM" at %s' % secondToken['loc']);
      thirdToken = rawTokens[2];
      if thirdToken['type'] != 'symbol':
        raise asmDef.AsmException('".memory" directive requires name for second argument at %s' % thirdToken['loc']);
      if self.IsSymbol(thirdToken['value']):
        ix = self.symbols['list'].index(thirdToken['value']);
        if self.symbols['type'] != secondToken['value']:
          raise asmDef.AsmException('Redefinition of ".memory %s %s" not allowed at %s' % (secondToken['value'],thirdToken['value'],firstToken['loc']));
      else:
        self.AddSymbol(thirdToken['value'],secondToken['value'],dict(length=0));
      self.currentMemory = thirdToken['value'];
    # Process ".variable" declaration.
    elif firstToken['value'] == '.variable':
      if not self.currentMemory:
        raise asmDef.AsmException('".memory" directive required before ".variable" directive at %s' % firstToken['line']);
      ixMem = self.symbols['list'].index(self.currentMemory);
      currentMemoryBody = self.symbols['body'][ixMem];
      byteList = self.ByteList(rawTokens[2:],limit=True);
      body = dict(memory=self.currentMemory, start=currentMemoryBody['length'], value=byteList);
      self.AddSymbol(secondToken['value'], 'variable', body=body);
      currentMemoryBody['length'] = currentMemoryBody['length'] + len(byteList);
      if currentMemoryBody['length'] > 256:
        raise asmDef.AsmException('Memory "%s" becomes too long at %s' % (self.currentMemory,firstToken['loc']));
    # Everything else is an error.
    else:
      raise Exception('Program Bug:  Unrecognized directive %s at %s' % (firstToken['value'],firstToken['loc']));

  def Main(self):
    """
    Return the body of the .main function.
    Note:  This is used by the top-level assembler to verify that the .main
           function has been defined.
    """
    return self.main;

  def Interrupt(self):
    """
    Return the body of the .interrupt function.
    Note:  This is used by the top-level assembler to verify that the .interrupt
           function has or has not been defined.
    """
    return self.interrupt;

  ################################################################################
  #
  # Compute the memory bank indices.
  #
  ################################################################################

  def EvaluateMemoryTree(self):
    """
    Ensure defined memories are used.  Add the memory name, type, and length to
    the list of memories.  Compute the bank index ascending from 0 for RAMs and
    descending from 3 for ROMs and add that index to the memory attributes.
    Ensure that no more than 4 memories are listed.
    """
    self.memories = dict(list=list(), type=list(), length=list(), bank=list());
    ramBank = 0;
    romBank = 3;
    for ix in range(len(self.symbols['list'])):
      if self.symbols['type'][ix] in ('RAM','ROM',):
        memBody = self.symbols['body'][ix];
        if memBody['length'] == 0:
          raise asmDef.AsmException('Empty memory:  %s' % self.symbols['list'][ix]);
        self.memories['list'].append(self.symbols['list'][ix]);
        self.memories['type'].append(self.symbols['type'][ix]);
        self.memories['length'].append(memBody['length']);
        if self.symbols['type'][ix] == 'RAM':
          self.memories['bank'].append(ramBank);
          ramBank = ramBank + 1;
        else:
          self.memories['bank'].append(romBank);
          romBank = romBank - 1;
    if len(self.memories['list']) > 4:
      raise asmDef.AsmException('Too many memory banks');

  ################################################################################
  #
  # Generate the list of required functions from the ".main" and ".interrupt"
  # bodies.
  #
  # Look for function calls with the bodies of the required functions.  If the
  # function has not already been identified as a required function then (1)
  # ensure it exists and is a function and then (2) add it to the list of
  # required functions.
  #
  # Whenever a function is added to the list, set its start address and get its
  # length.
  #
  ################################################################################

  def EvaluateFunctionTree(self):
    """
    Create a list of the functions required by the program, starting with the
    required .main function and the optional .interrupt function.\n
    Record the length of each function, its body, and its start address and
    calculate the addresses of the labels within each function body.\n
    Finally, ensure the function address space does not exceed the absolute
    8192 address limit.
    """
    self.functionEvaluation = dict(list=list(), length=list(), body=list(), address=list());
    nextStart = 0;
    # ".main" is always required.
    self.functionEvaluation['list'].append('.main');
    self.functionEvaluation['length'].append(self.main['length']);
    self.functionEvaluation['body'].append(self.main['tokens']);
    self.functionEvaluation['address'].append(nextStart);
    nextStart = nextStart + self.functionEvaluation['length'][-1];
    # ".interrupt" is optionally required (and is sure to exist by this function
    # call if it is required).
    if self.interrupt:
      self.functionEvaluation['list'].append('.interrupt');
      self.functionEvaluation['length'].append(self.interrupt['length']);
      self.functionEvaluation['body'].append(self.interrupt['tokens']);
      self.functionEvaluation['address'].append(nextStart);
      nextStart = nextStart + self.functionEvaluation['length'][-1];
    # Loop through the required function bodies as they are identified.
    ix = 0;
    while ix < len(self.functionEvaluation['body']):
      for token in self.functionEvaluation['body'][ix]:
        if (token['type'] == 'macro') and (token['value'] in ('.call','.callc',)):
          callName = token['argument'][0]['value'];
          if callName not in self.functionEvaluation['list']:
            if not self.IsSymbol(callName):
              raise asmDef.AsmException('Function "%s" not defined for function "%s"' % (callName,self.functionEvaluation['list'][ix],));
            ixName = self.symbols['list'].index(callName);
            if self.symbols['type'][ixName] != 'function':
              raise asmDef.AsmException('Function "%s" called by "%s" is not a function' % (callName, self.functionEvaluation['list'][ix],));
            self.functionEvaluation['list'].append(callName);
            self.functionEvaluation['length'].append(self.symbols['body'][ixName]['length']);
            self.functionEvaluation['body'].append(self.symbols['body'][ixName]['tokens']);
            self.functionEvaluation['address'].append(nextStart);
            nextStart = nextStart + self.functionEvaluation['length'][-1];
      ix = ix + 1;
    # Within each function, compute the list of label addresses and then fill in
    # the address for all jumps and calls.
    for ix in range(len(self.functionEvaluation['list'])):
      startAddress = self.functionEvaluation['address'][ix];
      labelAddress = dict(list=list(), address=list());
      for token in self.functionEvaluation['body'][ix]:
        if token['type'] == 'label':
          labelAddress['list'].append(token['value']);
          labelAddress['address'].append(startAddress + token['offset']);
      for token in self.functionEvaluation['body'][ix]:
        if token['type'] != 'macro':
          continue;
        if token['value'] in ('.jump','.jumpc',):
          ix = labelAddress['list'].index(token['argument'][0]['value']);
          token['address'] = labelAddress['address'][ix];
        elif token['value'] in ('.call','.callc',):
          ix = self.functionEvaluation['list'].index(token['argument'][0]['value']);
          token['address'] = self.functionEvaluation['address'][ix];
    # Sanity checks for address range
    if self.functionEvaluation['address'][-1] + self.functionEvaluation['length'][-1] >= 2**13:
      raise asmDef.AsmException('Max address for program requires more than 13 bits');

  ################################################################################
  #
  # Emit the meta code for the memories.
  #
  ################################################################################

  def EmitMemories(self,fp):
    """
    Print the memories to the metacode file.\n
    The first line for each memory has the format
      :memory type mem_name bank length
    where
      type              is RAM or ROM
      mem_name          is the name of the memory
      bank              is the assigned bank address
      length            is the number of bytes used by the memory\n
    The subsequent lines are sequences of
      - variable_name
      value(s)
    where
      '-'               indicates a variable name is present
      variable_name     is the name of the variable
      values(s)         is one or more lines for the values with one byte per line
                        Note:  because the lines with variable names start with
                               '-', negative values are converted to unsigned
                               values\n
    """
    # Emit the individual memories.
    for ixMem in range(len(self.memories['list'])):
      fp.write(':memory %s %s %d %d\n' % (self.memories['type'][ixMem],self.memories['list'][ixMem],self.memories['bank'][ixMem],self.memories['length'][ixMem]));
      memName = self.memories['list'][ixMem];
      address = 0;
      for ixSymbol in range(len(self.symbols['list'])):
        if self.symbols['type'][ixSymbol] != 'variable':
          continue;
        vBody = self.symbols['body'][ixSymbol];
        if vBody['memory'] != memName:
          continue;
        fp.write('- %s\n' % self.symbols['list'][ixSymbol]);
        for v in vBody['value']:
          if not (-128 <=v < 256):
            raise Exception('Program Bug -- value not representable by a byte');
          fp.write('%02X\n' % (v % 0x100,));
      fp.write('\n');

  ################################################################################
  #
  # Emit the metacode for the program.
  #
  ################################################################################

  #
  # Utilities for building opcodes or the associated description strings.
  #
  # Note:  These utilities do not write to the metacode file.
  #

  def Emit_AddLabel(self,name):
    """
    Append the label to the labels associated with the current program address.
    """
    self.emitLabelList += ':' + name + ' ';

  def Emit_EvalSingleValue(self,token):
    """
    Evaluate the optional single-byte value for a macro.
    """
    if token['type'] == 'symbol':
      token = self.ExpandSymbol(token,singleValue=True);
    if token['type'] == 'constant':
      name = token['value'];
      if not self.IsSymbol(name):
        raise Exception('Program Bug');
      ix = self.symbols['list'].index(name);
      if len(self.symbols['body'][ix]) != 1:
        raise asmDef.AsmException('Optional constant can only be one byte at %s' % token['loc']);
      return self.symbols['body'][ix][0]
    elif token['type'] == 'value':
      return token['value']
    else:
      raise asmDef.AsmException('Unrecognized optional argument "%s"' % token['value']);

  def Emit_GetAddrAndBank(self,token):
    """
    For the specified variable, return an ordered tuple of the memory address
    within its bank, the corresponding bank index, and the corresponding bank
    name.\n
    Note:  This is used by several user-defined macros that fetch from or store
           to variables.
    """
    name = token['value'];
    if not self.IsSymbol(name):
      raise asmDef.AsmException('"%s" is not a recognized symbol at %s' % (name,token['loc'],));
    ixName = self.symbols['list'].index(name);
    if self.symbols['type'][ixName] != 'variable':
      raise asmDef.AsmException('"%s" is not a variable at %s' % (name,token['loc'],));
    body = self.symbols['body'][ixName];
    bankName = body['memory'];
    ixMem = self.memories['list'].index(bankName);
    return (body['start'],self.memories['bank'][ixMem],bankName,);

  def Emit_GetBank(self,name):
    """
    For the specified variable, return the memory bank index.\n
    Note:  This is used by the .fetch, .fetch+, .fetch-, .store, .store+, and
           .store- macros.
    """
    if name not in self.memories['list']:
      raise asmDef.AsmException('"%s" not a memory' % name);
    ixMem = self.memories['list'].index(name);
    return self.memories['bank'][ixMem];

  def Emit_String(self,name=''):
    """
    Append the specified string to the list of labels for the current
    instruction, restart the list of labels, and return the composite string.
    """
    name = self.emitLabelList + name;
    self.emitLabelList = '';
    return name;

  def Emit_IntegerValue(self,token):
    """
    Return the integer value associated with a constant or a numeric expression.
    """
    if token['type'] == 'value':
      v = token['value'];
    elif token['type'] == 'symbol':
      name = token['value'];
      if not self.IsSymbol(name):
        raise asmDef.AsmException('Symbol "%s" not recognized at %s' % (token['value'],token['loc'],));
      ix = self.symbols['list'].index(name);
      v = self.symbols['body'][ix];
      if len(v) != 1:
        raise asmDef.AsmException('Argument can only be one value at %s' % token['loc']);
      v = v[0];
    else:
      raise asmDef.AsmException('Argument "%s" of type "%s" not recognized at %s' % (token['value'],token['type'],token['loc'],));
    if type(v) != int:
      raise Exception('Program Bug -- value should be an "int"');
    return v;

  #
  # Utilities to write single instructions to the metacode file.
  #
  # Note:  Other than the program header and the function names, these
  #        utilities write the function bodies.
  #

  def EmitOpcode(self,fp,opcode,name):
    """
    Write the specified opcode and the associated comment string.\n
    The leading bit for an opcode is always a '0'.
    """
    if not (0 <= opcode < 256):
      raise Exception('Program Bug -- opcode "0x%X" out of range');
    fp.write('0%02X %s\n' % (opcode,self.Emit_String(name)));

  def EmitParameter(self,fp,token):
    """
    Write the name (and range) of the specified parameter and the optional
    associated comment string.\n
    The string 'p' specifies that the parameter is to be inserted into the
    instruction body.\n
    Note:  The comment string may be the empty string if there were no labels
           immediately preceding the parameter.
    """
    name = token['value'];
    if not self.IsParameter(name):
      raise Exception('Program Bug');
    commentString = self.Emit_String();
    if commentString:
      fp.write('p %s%s %s\n' % (name,token['range'],commentString,));
    else:
      fp.write('p %s%s\n' % (name,token['range'],));

  def EmitPush(self,fp,value,name=None,tokenLoc=None):
    """
    Write the opcode to push a value onto the data stack.  Include the comment
    string including either the optionally provided symbol name or a printable
    representation of the value being pushed onto the stack.\n
    Note:  The printable value is included when a name is not provided so that
           the contents of single characters or of strings being pushed onto
           the stack can be read.\n
    Note:  The token location is an optional input required when the range of
           the provided value may not have been previously ensured to fit in
           one byte.
    """
    if not (-128 <= value < 256):
      if tokenLoc == None:
        raise Exception('Program Bug -- untrapped out-of-range token "%s"' % value);
      else:
        raise asmDef.AsmException('Value not representable by a byte at "%s"' % tokenLoc);
    if value < 0:
      value = value + 256;
    if type(name) == str:
      fp.write('1%02X %s\n' % ((value % 0x100),self.Emit_String(name)));
    elif (chr(value) in string.printable) and (chr(value) not in string.whitespace):
      fp.write('1%02X %s\n' % ((value % 0x100),self.Emit_String('%02X \'%c\'' % (value,value,))));
    else:
      fp.write('1%02X %s\n' % ((value % 0x100),self.Emit_String('0x%02X' % value)));

  def EmitVariable(self,fp,name):
    """
    Use the EmitPush method to push the address of a variable onto the data
    stack.
    """
    if not self.IsSymbol(name):
      raise asmDef.AsmException('Variable "%s" not recognized' % name);
    ixName = self.symbols['list'].index(name);
    if self.symbols['type'][ixName] != 'variable':
      raise asmDef.AsmException('"%s" is not a variable' % name);
    self.EmitPush(fp,self.symbols['body'][ixName]['start'],name);

  #
  # EmitOpcode, EmitMacro, and EmitProgram emit composite or more complicated
  # bodies.
  #

  def EmitOptArg(self,fp,token):
    """
    Write the metacode for optional arguments to macros.\n
    These must be single-instruction arguments.
    """
    # Symbols encountered in macros are expanded here instead of the
    # ExpandTokens method -- the code is much simpler this way even though the
    # associated error detection was deferred in the processing.  The symbol
    # must expand to a single value.
    if token['type'] == 'symbol':
      token = self.ExpandSymbol(token,singleValue=True);
    if token['type'] == 'constant':
      name = token['value'];
      if not self.IsSymbol(name):
        raise Exception('Program Bug');
      ix = self.symbols['list'].index(name);
      if len(self.symbols['body'][ix]) != 1:
        raise asmDef.AsmException('Optional constant can only be one byte at %s' % token['loc']);
      self.EmitPush(fp,self.symbols['body'][ix][0],self.Emit_String(name),tokenLoc=token['loc']);
    elif token['type'] in ('inport','outport','outstrobe'):
      name = token['value'];
      if not self.IsSymbol(name):
        raise Exception('Program Bug -- unrecognized inport/outport name "%s"');
      ix = self.symbols['list'].index(name);
      self.EmitPush(fp,self.symbols['body'][ix],self.Emit_String(name));
    elif token['type'] == 'instruction':
      self.EmitOpcode(fp,self.InstructionOpcode(token['value']),token['value']);
    elif token['type'] == 'parameter':
      self.EmitParameter(fp,token);
    elif token['type'] == 'value':
      self.EmitPush(fp,token['value'],tokenLoc=token['loc']);
    elif token['type'] == 'variable':
      self.EmitVariable(fp,token['value']);
    elif token['type'] == 'macro':
      self.EmitMacro(fp,token);
    else:
      raise asmDef.AsmException('Unrecognized optional argument "%s"' % token['value']);

  def EmitMacro(self,fp,token):
    """
    Write the metacode for a macro.\n
    The macros coded here are required to access intrinsics.
    """
    # .call
    if token['value'] == '.call':
      self.EmitPush(fp,token['address'] & 0xFF,'');
      self.EmitOpcode(fp,self.specialInstructions['call'] | (token['address'] >> 8),'call '+token['argument'][0]['value']);
      self.EmitOptArg(fp,token['argument'][1]);
    # .callc
    elif token['value'] == '.callc':
      self.EmitPush(fp,token['address'] & 0xFF,'');
      self.EmitOpcode(fp,self.specialInstructions['callc'] | (token['address'] >> 8),'callc '+token['argument'][0]['value']);
      self.EmitOptArg(fp,token['argument'][1]);
    # .fetch
    elif token['value'] == '.fetch':
      name = token['argument'][0]['value'];
      ixBank = self.Emit_GetBank(name);
      self.EmitOpcode(fp,self.specialInstructions['fetch'] | ixBank,'fetch '+name);
    # .fetch+
    elif token['value'] == '.fetch+':
      name = token['argument'][0]['value'];
      ixBank = self.Emit_GetBank(name);
      self.EmitOpcode(fp,self.specialInstructions['fetch+'] | ixBank,'fetch+('+name+')');
    # .fetch-
    elif token['value'] == '.fetch-':
      name = token['argument'][0]['value'];
      ixBank = self.Emit_GetBank(name);
      self.EmitOpcode(fp,self.specialInstructions['fetch-'] | ixBank,'fetch-('+name+')');
    # .jump
    elif token['value'] == '.jump':
      self.EmitPush(fp,token['address'] & 0xFF,'');
      self.EmitOpcode(fp,self.specialInstructions['jump'] | (token['address'] >> 8),'jump '+token['argument'][0]['value']);
      self.EmitOptArg(fp,token['argument'][1]);
    # .jumpc
    elif token['value'] == '.jumpc':
      self.EmitPush(fp,token['address'] & 0xFF,'');
      self.EmitOpcode(fp,self.specialInstructions['jumpc'] | (token['address'] >> 8),'jumpc '+token['argument'][0]['value']);
      self.EmitOptArg(fp,token['argument'][1]);
    # .return
    elif token['value'] == '.return':
      self.EmitOpcode(fp,self.specialInstructions['return'],'return');
      self.EmitOptArg(fp,token['argument'][0]);
    # .store
    elif token['value'] == '.store':
      name = token['argument'][0]['value'];
      ixBank = self.Emit_GetBank(name);
      self.EmitOpcode(fp,self.specialInstructions['store'] | ixBank,'store '+name);
    # .store+
    elif token['value'] == '.store+':
      name = token['argument'][0]['value'];
      ixBank = self.Emit_GetBank(name);
      self.EmitOpcode(fp,self.specialInstructions['store+'] | ixBank,'store+ '+name);
    # .store-
    elif token['value'] == '.store-':
      name = token['argument'][0]['value'];
      ixBank = self.Emit_GetBank(name);
      self.EmitOpcode(fp,self.specialInstructions['store-'] | ixBank,'store- '+name);
    # user-defined macro
    elif token['value'] in self.EmitFunction:
      self.EmitFunction[token['value']](self,fp,token['argument']);
    # error
    else:
      raise Exception('Program Bug -- Unrecognized macro "%s"' % token['value']);

  def EmitProgram(self,fp):
    """
    Write the program to the metacode file.\n
    The frist line for the program has the format
      :program address_main address_interrupt
    where
      address_main      is the address of the .main function (this should be 0)
      address_interrupt is either the address of the optional interrupt
                        function if it was defined or the 2-character string
                        '[]'\n
    The subsequent lines are sequences of
      - function_name   indicates the start of a new function body and the name
                        of the function
      instructions      is multiple lines, one for each instruction in the
                        function\n
    The formats of the instruction lines are as follows:
      value string      value is the next instruction to store and string is an
                        optional string describing the instruction
                        Note:  "value" must be a 3-digit hex string
                               representing a 9-bit value
                        Note:  The only place string should be empty is when
                               pushing the 8 lsb of an address onto the start
                               prior to a call, callc, jump, or jumpc
                               instruction
      p name            the single 'p' means that the name of a parameter and
                        its range are to be converted into an instruction
    """
    # Write the program marker, address of .main, address or "[]" of .interrupt,
    # and the total program length.
    fp.write(':program');
    fp.write(' %d' % self.functionEvaluation['address'][0]);
    if self.interrupt:
      fp.write(' %d' % self.functionEvaluation['address'][1]);
    else:
      fp.write(' []');
    fp.write(' %d' % (self.functionEvaluation['address'][-1] + self.functionEvaluation['length'][-1]));
    fp.write('\n');
    # Emit the bodies
    for ix in range(len(self.functionEvaluation['list'])):
      fp.write('- %s\n' % self.functionEvaluation['list'][ix]);
      self.emitLabelList = '';
      for token in self.functionEvaluation['body'][ix]:
        if token['type'] == 'value':
          self.EmitPush(fp,token['value'],tokenLoc=token['loc']);
        elif token['type'] == 'label':
          self.Emit_AddLabel(token['value']);
        elif token['type'] == 'constant':
          if not self.IsSymbol(token['value']):
            raise Exception('Program Bug');
          ix = self.symbols['list'].index(token['value']);
          body = self.symbols['body'][ix];
          self.EmitPush(fp,body[-1],token['value'],tokenLoc=token['loc']);
          for v in body[-2::-1]:
            self.EmitPush(fp,v,tokenLoc=token['loc']);
        elif token['type'] in ('inport','outport','outstrobe',):
          if not self.IsSymbol(token['value']):
            raise Exception('Program Bug');
          ix = self.symbols['list'].index(token['value']);
          self.EmitPush(fp,self.symbols['body'][ix],token['value'],tokenLoc=token['loc']);
        elif token['type'] == 'instruction':
          self.EmitOpcode(fp,self.InstructionOpcode(token['value']),token['value']);
        elif token['type'] == 'macro':
          self.EmitMacro(fp,token);
        elif token['type'] == 'parameter':
          self.EmitParameter(fp,token);
        elif token['type'] == 'symbol':
          self.EmitPush(fp,token['value'],token['name'],tokenLoc=token['loc']);
        elif token['type'] == 'variable':
          self.EmitVariable(fp,token['value']);
        else:
          raise Exception('Program Bug:  Unrecognized type "%s"' % token['type']);

  ################################################################################
  #
  # Initialize the object.
  #
  ################################################################################

  def __init__(self):
    """
    Initialize the tables definining the following:
      directly invokable instruction mnemonics and the associated opcodes
      indirectly inivoked instruction mnemonics and the associated opcodes
        Note:  These are accessed through macros since they require an argument
               or are part of multi-instruction sequences.
      directives (other than ".include")
      macros with type restrictions for required arguments and defaults and
        restrictions for optional arguments\n
    Initialize lists and members to record memory attributes, stack lengths,
    body of the .main function, body of the optional .interrupt function,
    current memory for variable definitions, etc.
    """

    #
    # Enumerate the directives
    # Note:  The ".include" directive is handled within asmDef.FileBodyIterator.
    #

    self.directives = dict();

    self.directives['list']= list();
    self.directives['list'].append('.constant');
    self.directives['list'].append('.define');
    self.directives['list'].append('.function');
    self.directives['list'].append('.interrupt');
    self.directives['list'].append('.macro');
    self.directives['list'].append('.main');
    self.directives['list'].append('.memory');
    self.directives['list'].append('.variable');

    #
    # Configure the instructions.
    #

    self.instructions = dict(list=list(), opcode=list());
    self.AddInstruction('&',            0x050);
    self.AddInstruction('+',            0x018);
    self.AddInstruction('+c',           0x00B);
    self.AddInstruction('-',            0x01C);
    self.AddInstruction('-1<>',         0x023);
    self.AddInstruction('-1=',          0x022);
    self.AddInstruction('-c',           0x00F);
    self.AddInstruction('0<>',          0x021);
    self.AddInstruction('0=',           0x020);
    self.AddInstruction('0>>',          0x004);
    self.AddInstruction('1+',           0x058);
    self.AddInstruction('1-',           0x05C);
    self.AddInstruction('1>>',          0x005);
    self.AddInstruction('<<0',          0x001);
    self.AddInstruction('<<1',          0x002);
    self.AddInstruction('<<msb',        0x003);
    self.AddInstruction('>r',           0x040);
    self.AddInstruction('^',            0x052);
    #self.AddInstruction('dis',          0x01C);
    self.AddInstruction('drop',         0x054);
    self.AddInstruction('dup',          0x008);
    #self.AddInstruction('ena',          0x019);
    self.AddInstruction('inport',       0x030);
    self.AddInstruction('lsb>>',        0x007);
    self.AddInstruction('msb>>',        0x006);
    self.AddInstruction('nip',          0x053);
    self.AddInstruction('nop',          0x000);
    self.AddInstruction('or',           0x051);
    self.AddInstruction('outport',      0x038);
    self.AddInstruction('over',         0x00A);
    self.AddInstruction('r>',           0x049);
    self.AddInstruction('r@',           0x009);
    self.AddInstruction('swap',         0x012);

    self.specialInstructions = dict();
    self.specialInstructions['call']    = 0x0C0;
    self.specialInstructions['callc']   = 0x0E0;
    self.specialInstructions['fetch']   = 0x068;
    self.specialInstructions['fetch+']  = 0x078;
    self.specialInstructions['fetch-']  = 0x07C;
    self.specialInstructions['jump']    = 0x080;
    self.specialInstructions['jumpc']   = 0x0A0;
    self.specialInstructions['return']  = 0x028;
    self.specialInstructions['store']   = 0x060;
    self.specialInstructions['store+']  = 0x070;
    self.specialInstructions['store-']  = 0x074;

    #
    # Configure the pre-defined macros
    # Note:  'symbol' is a catch-call for functions, labels, variables, etc.
    #        These are restricted to the appropriate types when the macros are
    #        expanded.
    #

    self.macros = dict(list=list(), length=list(), args=list(), nArgs=list(), builtIn = list(), doc = list());
    self.EmitFunction = dict();

    # Macros built in to the assembler (to access primitives).
    self.AddMacro('.call',              3, [
                                             ['','symbol'],
                                             ['nop','instruction','singlemacro','singlevalue','symbol']
                                           ]);
    self.AddMacro('.callc',             3, [
                                             ['','symbol'],
                                             ['drop','instruction','singlevalue','symbol']
                                           ]);
    self.AddMacro('.fetch',             1, [ ['','symbol'] ]);
    self.AddMacro('.fetch+',            1, [ ['','symbol'] ]);
    self.AddMacro('.fetch-',            1, [ ['','symbol'] ]);
    self.AddMacro('.jump',              3, [
                                             ['','symbol'],
                                             ['nop','instruction','singlemacro','singlevalue','symbol']
                                           ]);
    self.AddMacro('.jumpc',             3, [
                                             ['','symbol'],
                                             ['drop','instruction','singlemacro','singlevalue','symbol']
                                           ]);
    self.AddMacro('.return',            2, [ ['nop','instruction','singlemacro','singlevalue','symbol'] ]);
    self.AddMacro('.store',             1, [ ['','symbol'] ]);
    self.AddMacro('.store+',            1, [ ['','symbol'] ]);
    self.AddMacro('.store-',            1, [ ['','symbol'] ]);

    # User-defined macros in ./macros that are "built in" to the assembler.
    macroSearchPath = os.path.join(sys.path[0],'macros');
    for macroName in os.listdir(macroSearchPath):
      if not re.match(r'.*\.py$',macroName):
        continue;
      self.AddUserMacro(macroName[:-3],macroSearchPaths=[macroSearchPath]);
    for macroName in self.macros['list']:
      self.macros['builtIn'].append(macroName);

    #
    # List the macros that have special symbols for their first argument.
    #

    self.MacrosWithSpecialFirstSymbol = ('.call','.callc','.jump','.jumpc',);

    #
    # Externally defined parameters.
    #

    self.memoryLength = dict();
    self.stackLength = dict();

    #
    # Configure the containers for the expanded main, interrupt, function,
    # macro, etc. definitions.
    #

    self.currentMemory = None;
    self.interrupt = None;
    self.main = None;
    self.macroSearchPaths = ['.','./macros'];
    self.symbols = dict(list=list(), type=list(), body=list());
