################################################################################
#
# Copyright 2012-2013, Sinclair R.F., Inc.
#
# Utilities required by ssbcc
#
################################################################################

import math
import os
import re
import sys

from ssbccUtil import *

class SSBCCconfig():
  """
  Container for ssbcc configuration commands, the associated parsing, and
  program generation.
  """

  def __init__(self):
    """
    Initialize the empty dictionaries holding the processor configuration
    parameters.  Initialize the paths to search for peripherals.
    """
    self.config         = dict();               # various settings, etc.
    self.constants      = dict();               # CONSTANTs
    self.defines        = dict();               # defines
    self.functions      = dict();               # list of functions to define
    self.inports        = list();               # INPORT definitions
    self.ios            = list();               # List of I/Os
    self.outports       = list();               # OUTPORT definitions (see AddOutport)
    self.parameters     = list();               # PARAMETERs and LOCALPARAMs
    self.peripheral     = list();               # PERIPHERALs
    self.signals        = list();               # internal signals
    self.symbols        = list();               # constant, I/O, inport, etc.  names

    # list of memories
    self.memories = dict(name=list(), type=list(), maxLength=list());

    # list of how the memories will be instantiated
    self.config['combine'] = list();

    # initial search path for .INCLUDE configuration commands
    self.includepaths = list();
    self.includepaths.append('.');

    # initial search paths for peripherals
    self.peripheralpaths = list();
    self.peripheralpaths.append('.');
    self.peripheralpaths.append('peripherals');
    self.peripheralpaths.append(os.path.join(sys.path[0],'core/peripherals'));

  def AddConstant(self,name,value,loc):
    """
    Add the constant for the "CONSTANT" configuration command to the "constants"
    dictionary.\n
    name        symbol for the constant
    value       value of the constant
    loc         file name and line number for error messages
    """
    self.AddSymbol(name,loc);
    if name in self.constants:
      raise SSBCCException('CONSTANT "%s" already declared at %s' % (name,loc,));
    if not IsIntExpr(value):
      raise SSBCCException('Could not evaluate expression "%s" for constant at %s' % (value,loc,));
    self.constants[name] = ParseIntExpr(value);

  def AddDefine(self,name):
    """
    Add the defined symbol.\n
    name        name for the symbol (must start with "D_")\n
    Note:  This is only invoked for the command line arguments so there is no
           "loc" available.\n
    Note:  Defines can be declared more than once on the command line with no
           ill effects.
    """
    if not self.IsDefine(name):
      self.AddSymbol(name);
      self.defines[name] = 1;

  def AddIO(self,name,nBits,iotype,loc):
    """
    Add an I/O signal to the processor interface to the system.\n
    name        name of the I/O signal
    nBits       number of bits in the I/O signal
    iotype      signal direction:  "input", "output", or "inout"
    """
    if iotype != 'comment':
      self.AddSymbol(name,loc);
    self.ios.append((name,nBits,iotype,));

  def AddInport(self,port,loc):
    """
    Add an INPORT symbol to the processor.\n
    port        name of the INPORT symbol
    loc         file name and line number for error messages
    """
    name = port[0];
    self.AddSymbol(name,loc);
    self.inports.append(port);

  def AddMemory(self,cmd,loc):
    """
    Add a memory to the list of memories.\n
    cmd         3-element list as follows:
                [0] ==> type:  "RAM" or "ROM"
                [1] ==> memory name
                [2] ==> memory length (must be a power of 2)
    loc         file name and line number for error messages
    """
    self.memories['type'].append(cmd[0]);
    self.memories['name'].append(cmd[1]);
    maxLength = eval(cmd[2]);
    if not IsPowerOf2(maxLength):
      raise SSBCCException('Memory length must be a power of 2, not "%s", at %s' % (cmd[2],loc,));
    self.memories['maxLength'].append(eval(cmd[2]));

  def AddOutport(self,port,loc):
    """
    Add an OUTPORT symbol to the processor.\n
    port        tuple as follows:
                port[0] - name of the OUTPORT symbol
                port[1] - True if the outport is a strobe-only outport, false
                          otherwise
                port[2:] - zero or more tuples as follows:
                  (o_signal,width,type,[initialization],)
                where
                  o_signal is the name of the output signal
                  width is the number of bits in the signal
                  type is 'data' or 'strobe'
                  initialization is an optional initial/reset value for the
                    output signal
    loc         file name and line number for error messages
    """
    self.AddSymbol(port[0],loc);
    self.outports.append(port);

  def AddParameter(self,name,value,loc):
    """
    Add a PARAMETER to the processor.\n
    name        name of the PARAMETER
    value       value of the PARAMETER
    loc         file name and line number for error messages
    """
    if not re.match(r'[LG]_\w+$',name):
      raise Exception('Program Bug -- bad parameter name at %s' % loc);
    self.AddSymbol(name,loc);
    self.parameters.append((name,value,));

  def AddSignal(self,name,nBits,loc):
    """
    Add a signal without an initial value to the processor.\n
    name        name of the signal
    nBits       number of bits in the signal
    loc         file name and line number for error messages
    """
    self.AddSymbol(name,loc);
    self.signals.append((name,nBits,));

  def AddSignalWithInit(self,name,nBits,init,loc):
    """
    Add a signal with an initial/reset value to the processor.\n
    name        name of the signal
    nBits       number of bits in the signal
    init        initial/reset value of the signal
    loc         file name and line number for error messages
    """
    self.AddSymbol(name,loc);
    self.signals.append((name,nBits,init,));

  def AddSymbol(self,name,loc=None):
    """
    Add the specified name to the list of symbols.\n
    Note:  This symbol has no associated functionality and is only used for
           ".ifdef" conditionals.
    """
    if name in self.symbols:
      if loc == None:
        raise SSBCCException('Symbol "%s" already defined, no line number provided');
      else:
        raise SSBCCException('Symbol "%s" already defined before %s' % (name,loc,));
    self.symbols.append(name);

  def AppendIncludePath(self,path):
    """
    Add the specified path to the end of the paths to search for .INCLUDE
    configuration commands.\n
    path        path to add to the list
    """
    self.includepaths.insert(-1,path);

  def CompleteCombines(self):
    """
    Ensure all memories are assigned addresses.\n
    This modifies config['combine'] to include singleton entries for any
    memories not subject to the COMBINE configuration command.  It then computes
    how the memories will be packed together as well as properites for the
    packed memories.  These properties are:
      packing   how the memories will be packed as per PackCombinedMemory
      memName   HDL name of the memory
      memLength number of words in the memory
      memWidth  bit width of the memory words
    """
    # Create singleton entries for memory types and memories that aren't already listed in 'combine'.
    if not self.IsCombined('INSTRUCTION'):
      self.config['combine'].append({'mems':['INSTRUCTION',], 'memArch':'sync'});
    for memType in ('DATA_STACK','RETURN_STACK',):
      if not self.IsCombined(memType):
        self.config['combine'].append({'mems':[memType,], 'memArch':'LUT'});
    for memName in self.memories['name']:
      if not self.IsCombined(memName):
        self.config['combine'].append({'mems':[memName,], 'memArch':'LUT'});
    # Determine the HDL names for the memories.
    nRAMROMs = 0;
    for combined in self.config['combine']:
      if combined['mems'][0] == 'INSTRUCTION':
        combined['memName'] = 's_opcodeMemory';
      elif combined['mems'][0] == 'DATA_STACK':
        combined['memName'] = 's_data_stack';
      elif combined['mems'][0] == 'RETURN_STACK':
        combined['memName'] = 's_R_stack';
      else:
        nRAMROMs += 1;
    if nRAMROMs > 0:
      memNameFormat = 's_mem_%%0%dx' % ((CeilLog2(nRAMROMs)+3)/4);
    ixRAMROM = 0;
    for combined in self.config['combine']:
      if 'memName' in combined:
        continue;
      if nRAMROMs == 1:
        combined['memName'] = 's_mem';
      else:
        combined['memName'] = memNameFormat % ixRAMROM;
        ixRAMROM += 1;
    # Perform packing for all memories.
    for combined in self.config['combine']:
      self.PackCombinedMemory(combined);

  def Exists(self,name):
    """
    Return true if the requested attribute has been created in the ssbccConfig
    object.
    """
    return name in self.config;

  def Get(self,name):
    """
    Return the requested attribute from the ssbccConfig object.
    """
    if not self.Exists(name):
      raise Exception('Program Bug:  "%s" not found in config' % name);
    return self.config[name];

  def GetMemoryByBank(self,ixBank):
    """
    Return the parameters for a memory by its bank address.\n
    ixBank      index of the requested memory bank
    """
    if not 'bank' in self.memories:
      return None;
    if ixBank not in self.memories['bank']:
      return None;
    ixMem = self.memories['bank'].index(ixBank);
    return self.GetMemoryParameters(ixMem);

  def GetMemoryByName(self,name):
    """
    Return the parameters for a memory by its name.\n
    name        name of the requested memory
    """
    if not name in self.memories['name']:
      return None;
    ixMem = self.memories['name'].index(name);
    return self.GetMemoryParameters(ixMem);

  def GetMemoryParameters(self,rawIndex):
    """
    Return the parameters for a memory by its index in the list of memories.\n
    rawIndex    index within the list of memories
    """
    if type(rawIndex) == str:
      if not self.IsMemory(rawIndex):
        raise Exception('Program Bug:  reference to non-existent memory');
      ix = self.memories['name'].index(rawIndex);
    elif type(rawIndex) == int:
      if (rawIndex < 0) or (rawIndex >= len(self.memories['name'])):
        raise Exception('Program Bug:  bad memory index %d' % rawIndex);
      ix = rawIndex;
    else:
      raise Exception('Program Bug:  unrecognized index type "%s"' % type(rawIndex));
    outvalue = dict();
    outvalue['index'] = ix;
    for field in self.memories:
      outvalue[field] = self.memories[field][ix];
    return outvalue;

  def GetPacking(self,name):
    """
    Get the memory packing for the provided memory.
    """
    for combined in self.config['combine']:
      if name not in combined['mems']:
        continue;
      for port in combined['port']:
        for packing in port['packing']:
          if packing['name'] == name:
            return (combined,port,packing,);
    else:
      raise Exception('Program Bug -- %s not found in combined memories' % name);

  def GetParameterValue(self,name):
    """
    Get the value associated with the named parameter.
    """
    if name.find('[') != -1:
      ix = name.index('[');
      thisSlice = name[ix:];
      name = name[:ix];
    else:
      thisSlice = '[0+:8]';
    for ix in range(len(self.parameters)):
      if self.parameters[ix][0] == name:
        return ExtractBits(IntValue(self.parameters[ix][1]),thisSlice);
    else:
      raise Exception('Program Bug:  Parameter "%s" not found' % name);

  def InsertPeripheralPath(self,path):
    """
    Add the specified path to the beginning of the paths to search for
    peripherals.\n
    path        path to add to the list
    """
    self.peripheralpaths.insert(-1,path);

  def IsCombined(self,name):
    """
    Indicate whether or not the specified memory type has already been listed
    in a "COMBINE" configuration command.  The memory type should be one of
    DATA_STACK, INSTRUCTION, or RETURN_STACK.\n
    name        name of the specified memory type\n
    """
    for combined in self.config['combine']:
      if name in combined['mems']:
        return True;
    else:
      return False;

  def IsConstant(self,name):
    """
    Indicate whether or not the specified symbol is a recognized constant.
    """
    if re.match(r'C_\w+$',name) and name in self.constants:
      return True;
    else:
      return False;

  def IsDefine(self,name):
    """
    Indicate whether or not the specified symbol is a recognized define.
    """
    if re.match(r'D_\w+$',name) and name in self.defines:
      return True;
    else:
      return False;

  def IsMemory(self,name):
    """
    Indicate whether or not the specified symbol is the name of a memory.
    """
    return (name in self.memories['name']);

  def IsParameter(self,name):
    """
    Indicate whether or not the specified symbol is the name of a parameter.
    """
    if re.match(r'[GL]_\w+$',name) and name in self.symbols:
      return True;
    else:
      return False;

  def IsRAM(self,name):
    """
    Indicate whether or not the specified symbol is the name of a RAM.
    """
    if name not in self.memories['name']:
      return False;
    ix = self.memories['name'].index(name);
    return self.memories['type'][ix] == 'RAM';

  def IsROM(self,name):
    """
    Indicate whether or not the specified symbol is the name of a RAM.
    """
    if name not in self.memories['name']:
      return False;
    ix = self.memories['name'].index(name);
    return self.memories['type'][ix] == 'ROM';

  def IsStrobeOnlyOutport(self,outport):
    """
    Indicate whether or not the specified outport symbol only has strobes
    associated with it (i.e., it has no data signals).
    """
    return outport[1];

  def IsSymbol(self,name):
    """
    Indicate whether or not the specified name is a symbol.
    """
    return (name in self.symbols);

  def MemoryNameLengthList(self):
    """
    Return a list of tuples where each tuple is the name of a memory and its
    length.
    """
    outlist = list();
    for ix in range(len(self.memories['name'])):
      outlist.append((self.memories['name'][ix],self.memories['maxLength'][ix],));
    return outlist;

  def NInports(self):
    """
    Return the number of INPORTS.
    """
    return len(self.inports);

  def NMemories(self):
    """
    Return the number of memories.
    """
    return len(self.memories['name']);

  def NOutports(self):
    """
    Return the number of OUTPORTS.
    """
    return len(self.outports);

  def OverrideParameter(self,name,value):
    """
    Change the value of the specified parameter (based on the command line
    argument instead of the architecture file).\n
    name        name of the parameter to change
    value       new value of the parameter
    """
    for ix in range(len(self.parameters)):
      if self.parameters[ix][0] == name:
        break;
    else:
      raise SSBCCException('Command-line parameter or localparam "%s" not specified in the architecture file' % name);
    self.parameters[ix] = (name,value,);

  def PackCombinedMemory(self,combined):
    """
    Utility function for CompleteCombines.\n
    Determine packing strategy and resulting memory addresses and sizes.  This
    list has everything ssbccGenVerilog needs to construct the memory.\n
    The dual port memories can be used to do the following:
      1.  pack a single memory, either single-port or dual-port
      2.  pack two single-port memories sequentially, i.e., one at the start of
          the RAM and one toward the end of the RAM
      3.  pack one single-port memory at the start of the RAM and pack several
          compatible single-port memories in parallel toward the end of the RAM.
          Note:  Compatible means that they have the same address.
      4.  pack several compatible dual-port memories in parallel.\n
    These single-port or dual-port single or parallel packed memories are
    described in the 'port' list in combined.  Each entry in the port list has
    several parameters described below and a 'packing' list that describes the
    single or multiple memories attached to that port.\n
    The parameters for each of port is as follows:
      offset    start address of the memory in the packing
      nWords    number of RAM words reserved for the memory
                Note:  This can be larger than the aggregate number of words
                       required by the memory in order to align the memories to
                       power-of-2 address alignments.
      ratio     number of base memory entries for the memory
                Note:  This must be a power of 2.\n
    The contents of each entry in the packing are as follows:
      -- the following are from the memory declaration
      name      memory name
      length    number of elements in the memory based on the declared memory
                size
                Note:  This is based on the number of addresses required for
                       each memory entry (see ratio).
      nbits     width of the memory type
      -- the following are derived for the packing
      lane      start bit
                Note:  This is required in particular when memories are stacked
                       in parallel.
      nWords    number of memory addresses allocated for the memory based on
                the packing
                Note:  This will be larger than length when a small memory is
                       packed in parallel with a larger memory.  I.e., when
                       ratio is not one.
      ratio     number of base memory entries required to extract a single word
                for the memory type
                Note:  This allows return stack entries to occupy more than one
                       memory address when the return stack is combined with
                       other memory addresses.
                Note:  This must be a power of 2.\n
    The following entries are also added to "combined":
      nWords    number of words in the memory
      memWidth  bit width of the memory words\n
    Note:  If memories are being combined with the instructions space, they are
           always packed at the end of the instruction space, so the
           instruction space allocation is not included in the packing.
    """
    # Count how many memories of each type are being combined.
    nSinglePort = 0;
    nRAMs = 0;
    nROMs = 0;
    for memName in combined['mems']:
      if memName in ('INSTRUCTION','DATA_STACK','RETURN_STACK',):
        nSinglePort += 1;
      elif self.IsROM(memName):
        nROMs += 1;
      else:
        nRAMs += 1;
    if nRAMs > 0:
      nRAMs += nROMs;
      nROMs = 0;
    # Ensure the COMBINE configuration command is implementable in a dual-port RAM.
    if nSinglePort > 0 and nRAMs > 0:
      raise SSBCCException('Cannot combine RAMs with other memory types in COMBINE configuration command at %s' % combined['loc']);
    if nSinglePort > 2 or (nSinglePort > 1 and nROMs > 0):
      raise SSBCCException('Too many memory types in COMBINE configuration command at %s' % combined['loc']);
    # Start splitting the listed memories into the one or two output lists and ensure that single-port memories are listed in the correct order.
    mems = combined['mems'];
    ixMem = 0;
    split = list();
    if 'INSTRUCTION' in mems:
      if mems[0] != 'INSTRUCTION':
        raise SSBCCException('INSTRUCTION must be the first memory listed in the COMBINE configuration command at %s' % combined['loc']);
      split.append(['INSTRUCTION']);
      ixMem += 1;
    while len(mems[ixMem:]) > 0 and mems[ixMem] in ('DATA_STACK','RETURN_STACK',):
      split.append([mems[ixMem]]);
      ixMem += 1;
    for memName in ('DATA_STACK','RETURN_STACK',):
      if memName in mems[ixMem:]:
        raise SSBCCException('Single-port memory %s must be listed before ROMs in COMBINE configuration command at %s' % combined['loc']);
    if mems[ixMem:]:
      split.append(mems[ixMem:]);
    if not (1 <= len(split) <= 2):
      raise Exception('Program Bug -- bad COMBINE configuration command not caught');
    # Create the detailed packing information.
    combined['port'] = list();
    for thisSplit in split:
      packing = list();
      for memName in thisSplit:
        if memName == 'INSTRUCTION':
          packing.append({'name':memName, 'length':self.Get('nInstructions')['length'], 'nbits':9});
        elif memName == 'DATA_STACK':
          packing.append({'name':memName, 'length':self.Get('data_stack'), 'nbits':self.Get('data_width')});
        elif memName == 'RETURN_STACK':
          nbits = max(self.Get('data_width'),self.Get('nInstructions')['nbits']);
          packing.append({'name':memName, 'length':self.Get('return_stack'), 'nbits':nbits});
        else:
          thisMemory = self.GetMemoryParameters(memName);
          packing.append({'name':memName, 'length':CeilPow2(thisMemory['maxLength']), 'nbits':self.Get('data_width')});
      combined['port'].append({ 'packing':packing });
    # Calculate the width of the base memory.
    # Note:  This accommodates RETURN_STACK being an isolated memory.
    memWidth = combined['port'][0]['packing'][0]['nbits'] if len(combined['port']) == 1 else None;
    for port in combined['port']:
      for packing in port['packing']:
        tempMemWidth = packing['nbits'];
        if tempMemWidth > self.Get('sram_width'):
          tempMemWidth = self.Get('sram_width');
        if not memWidth:
          memWidth = tempMemWidth;
        elif tempMemWidth > memWidth:
          memWidth = tempMemWidth;
    combined['memWidth'] = memWidth;
    # Determine how the memories are packed.
    # Note:  "ratio" should be non-unity only for RETURN_STACK.
    for port in combined['port']:
      lane = 0;
      for packing in port['packing']:
        packing['lane'] = lane;
        ratio = CeilPow2((packing['nbits']+memWidth-1)/memWidth);
        packing['ratio'] = ratio;
        packing['nWords'] = ratio * packing['length'];
        lane += ratio;
    # Aggregate parameters each memory port.
    for port in combined['port']:
      ratio = CeilPow2(sum(packing['ratio'] for packing in port['packing']));
      maxLength = max(packing['length'] for packing in port['packing']);
      port['ratio'] = ratio;
      port['nWords'] = ratio * maxLength;
    combined['port'][0]['offset'] = 0;
    if len(combined['port']) > 1:
      if combined['mems'][0] == 'INSTRUCTION':
        nWordsTail = combined['port'][1]['nWords'];
        port0 = combined['port'][0];
        if port0['nWords'] <= nWordsTail:
          raise SSBCCException('INSTRUCTION length too small for "COMBINE INSTRUCTION,..." at %s' % combined['loc']);
        port0['nWords'] -= nWordsTail;
        port0['packing'][0]['nWords'] -= nWordsTail;
        port0['packing'][0]['length'] -= nWordsTail;
      else:
        maxNWords = max(port['nWords'] for port in combined['port']);
        for port in combined['port']:
          port['nWords'] = maxNWords;
      combined['port'][1]['offset'] = combined['port'][0]['nWords'];
    combined['nWords'] = sum(port['nWords'] for port in combined['port']);

  def ProcessCombine(self,loc,line):
    """
    Parse the "COMBINE" configuration command as follows:\n
    Validate the arguments to the "COMBINE" configuration command and append
    the list of combined memories and the associated arguments to "combine"
    property.\n
    The argument consists of one of the following:
      INSTRUCTION,{DATA_STACK,RETURN_STACK,rom_list}
      DATA_STACK
      DATA_STACK,{RETURN_STACK,rom_list}
      RETURN_STACK
      RETURN_STACK,{DATA_STACK,rom_list}
      mem_list
    where rom_list is a comma separated list of one or more ROMs and mem_list is
    a list of one or more RAMs or ROMs.
    """
    # Perform some syntax checking and get the list of memories to combine.
    cmd = re.findall(r'\s*COMBINE\s+(\S+)\s*$',line);
    if not cmd:
      raise SSBCCException('Malformed COMBINE configuration command on %s' % loc);
    mems = re.split(r',',cmd[0]);
    if (len(mems)==1) and ('INSTRUCTION' in mems):
      raise SSBCCException('"COMBINE INSTRUCTION" doesn\'t make sense at %s' % loc);
    if ('INSTRUCTION' in mems) and (mems[0] != 'INSTRUCTION'):
      raise SSBCCException('"INSTRUCTION" must be listed first in COMBINE configuration command at %s' % loc);
    recognized = ['INSTRUCTION','DATA_STACK','RETURN_STACK'] + self.memories['name'];
    unrecognized = [memName for memName in mems if memName not in recognized];
    if unrecognized:
      raise SSBCCException('"%s" not recognized in COMBINE configuration command at %s' % (unrecognized[0],loc,));
    alreadyUsed = [memName for memName in mems if self.IsCombined(memName)];
    if alreadyUsed:
      raise SSBCCException('"%s" already used in COMBINE configuration command before %s' % (alreadyUsed[0],loc,));
    repeated = [mems[ix] for ix in range(len(mems)-1) if mems[ix] in mems[ix+1:]];
    if repeated:
      raise SSBCCException('"%s" repeated in COMBINE configuration command on %s' % (repeated[0],loc,));
    # Count the number of the different memory types being combined and validate the combination.
    nSinglePort = sum([thisMemName in ('INSTRUCTION','DATA_STACK','RETURN_STACK',) for thisMemName in mems]);
    nROM = len([thisMemName for thisMemName in mems if self.IsROM(thisMemName)]);
    nRAM = len([thisMemName for thisMemName in mems if self.IsRAM(thisMemName)]);
    if nRAM > 0:
      nRAM += nROM;
      nROM = 0;
    if nROM > 0:
      nSinglePort += 1;
    nDualPort = 1 if nRAM > 0 else 0;
    if nSinglePort + 2*nDualPort > 2:
      raise SSBCCException('Too many ports required for COMBINE configuration command at %s' % loc);
    # Append the listed memory types to the list of combined memories.
    self.config['combine'].append({'mems':mems, 'memArch':'sync', 'loc':loc});

  def ProcessInport(self,loc,line):
    """
    Parse the "INPORT" configuration commands as follows:
      The configuration command is well formatted.
      The number of signals matches the corresponding list of signal declarations.
      The port name starts with 'I_'.
      The signal declarations are valid.
        n-bit where n is an integer
        set-reset
        strobe
      That no other signals are specified in conjunction with a "set-reset" signal.
      The total input data with does not exceed the maximum data width.\n
    The input port is appended to the list of inputs as a tuple.  The first
    entry in the tuple is the port name.  The subsequent entries are tuples
    consisting of the following:
      signal name
      signal width
      signal type
    """
    cmd = re.findall(r'\s*INPORT\s+(\S+)\s+(\S+)\s+(I_\w+)\s*$',line);
    if not cmd:
      raise SSBCCException('Malformed INPORT statement at %s: "%s"' % (loc,line[:-1],));
    modes = re.findall(r'([^,]+)',cmd[0][0]);
    names = re.findall(r'([^,]+)',cmd[0][1]);
    portName = cmd[0][2];
    if len(modes) != len(names):
      raise SSBCCException('Malformed INPORT configuration command -- number of options don\'t match on %s: "%s"' % (loc,line[:-1],));
    # Append the input signal names, mode, and bit-width to the list of I/Os.
    has__set_reset = False;
    nBits = 0;
    thisPort = (portName,);
    for ix in range(len(names)):
      if re.match(r'^\d+-bit$',modes[ix]):
        thisNBits = int(modes[ix][0:-4]);
        self.AddIO(names[ix],thisNBits,'input',loc);
        thisPort += ((names[ix],thisNBits,'data',),);
        nBits = nBits + thisNBits;
      elif modes[ix] == 'set-reset':
        has__set_reset = True;
        self.AddIO(names[ix],1,'input',loc);
        thisPort += ((names[ix],1,'set-reset',),);
        self.AddSignal('s_SETRESET_%s' % names[ix],1,loc);
      elif modes[ix] == 'strobe':
        self.AddIO(names[ix],1,'output',loc);
        thisPort += ((names[ix],1,'strobe',),);
      else:
        raise SSBCCException('Unrecognized INPORT signal type "%s"' % modes[ix]);
      if has__set_reset and len(names) > 1:
        raise SSBCCException('set-reset cannot be simultaneous with other signals in "%s"' % line[:-1]);
      if nBits > self.Get('data_width'):
        raise SSBCCException('Signal width too wide in "%s"' % line[:-1]);
    self.AddInport(thisPort,loc);

  def ProcessOutport(self,line,loc):
    """
    Parse the "OUTPORT" configuration commands as follows:
      The configuration command is well formatted.
      The number of signals matches the corresponding list of signal declarations.
      The port name starts with 'O_'.
      The signal declarations are valid.
        n-bit[=value]
        strobe
      The total output data with does not exceed the maximum data width.\n
    The output port is appended to the list of outports as a tuple.  The first
    entry in this tuple is the port name.  The subsequent entries are tuples
    consisting of the following:
      signal name
      signal width
      signal type
      initial value (optional)
    """
    cmd = re.findall(r'^\s*OUTPORT\s+(\S+)\s+(\S+)\s+(O_\w+)\s*$',line);
    if not cmd:
      raise SSBCCException('Malformed OUTPUT configuration command on %s: "%s"' % (loc,line[:-1],));
    modes = re.findall(r'([^,]+)',cmd[0][0]);
    names = re.findall(r'([^,]+)',cmd[0][1]);
    portName = cmd[0][2];
    if len(modes) != len(names):
      raise SSBCCException('Malformed OUTPORT configuration command -- number of widths/types and signal names don\'t match on %s: "%s"' % (loc,line[:-1],));
    # Append the input signal names, mode, and bit-width to the list of I/Os.
    nBits = 0;
    isStrobeOnly = True;
    thisPort = tuple();
    for ix in range(len(names)):
      if re.match(r'\d+-bit',modes[ix]):
        isStrobeOnly = False;
        a = re.match(r'(\d+)-bit(=\S+)?$',modes[ix]);
        if not a:
          raise SSBCCException('Malformed bitwith/bitwidth=initialization on %s:  "%s"' % (loc,modes[ix],));
        thisNBits = int(a.group(1));
        self.AddIO(names[ix],thisNBits,'output',loc);
        if a.group(2):
          thisPort += ((names[ix],thisNBits,'data',a.group(2)[1:],),);
        else:
          thisPort += ((names[ix],thisNBits,'data',),);
        nBits = nBits + thisNBits;
        self.config['haveBitOutportSignals'] = 'True';
      elif modes[ix] == 'strobe':
        self.AddIO(names[ix],1,'output',loc);
        thisPort += ((names[ix],1,'strobe',),);
      else:
        raise SSBCCException('Unrecognized OUTPORT signal type on %s: "%s"' % (loc,modes[ix],));
      if nBits > 8:
        raise SSBCCException('Signal width too wide on %s:  in "%s"' % (loc,line[:-1],));
    self.AddOutport((portName,isStrobeOnly,)+thisPort,loc);

  def ProcessPeripheral(self,loc,line):
    """
    Process the "PERIPHERAL" configuration command as follows:
      Validate the format of the configuration command.
      Find the peripheral in the candidate list of paths for peripherals.
      Execute the file declaring the peripheral.
        Note:  This is done since I couldn't find a way to "import" the
               peripheral.  Executing the peripheral makes its definition local
               to this invokation of the ProcessPeripheral function, but the
               object subsequently created retains the required functionality
               to instantiate the peripheral
      Go through the parameters for the peripheral and do the following for each:
        If the argument for the peripheral is the string "help", then print the
          docstring for the peripheral and exit.
        Append the parameter name and its argument to the list of parameters
          (use "None" as the argument if no argument was provided).
      Append the instantiated peripheral to the list of peripherals.
        Note:  The "exec" function dynamically executes the instruction to
               instantiate the peripheral and append it to the list of
               peripherals.
    """
    # Validate the format of the peripheral configuration command and the the name of the peripheral.
    cmd = re.findall(r'\s*PERIPHERAL\s+(\w+)\s*(.*)$',line);
    if not cmd:
      raise SSBCCException('Missing peripheral name in %s:  %s' % (loc,line[:-1],));
    peripheral = cmd[0][0];
    # Find and execute the peripheral Python script.
    # Note:  Because "execfile" and "exec" method are used to load the
    #        peripheral python script, the __file__ object is set to be this
    #        file, not the peripheral source file.
    for testPath in self.peripheralpaths:
      fullperipheral = os.path.join(testPath,'%s.py' % peripheral);
      if os.path.isfile(fullperipheral):
        break;
    else:
      raise SSBCCException('Peripheral "%s" not found' % peripheral);
    execfile(fullperipheral);
    # Convert the space delimited parameters to a list of tuples.
    param_list = list();
    for param_string in re.findall(r'(\w+="[^"]*"|\w+=\S+|\w+)\s*',cmd[0][1]):
      if param_string == "help":
        exec('helpmsg = %s.__doc__' % peripheral);
        if not helpmsg:
          raise SSBCCException('No help for peripheral %s is provided' % fullperipheral);
        print;
        print 'Help message for peripheral:  %s' % peripheral;
        print 'Located at:  %s' % fullperipheral;
        print;
        print helpmsg;
        raise SSBCCException('Terminated by "help" for peripheral %s' % peripheral);
      ix = param_string.find('=');
      if param_string.find('="') > 0:
        param_list.append((param_string[:ix],param_string[ix+2:-1],));
      elif param_string.find('=') > 0:
        param_list.append((param_string[:ix],param_string[ix+1:],));
      else:
        param_list.append((param_string,None));
    # Add the peripheral to the micro controller configuration.
    exec('self.peripheral.append(%s(fullperipheral,self,param_list,loc));' % peripheral);

  def Set(self,name,value):
    """
    Create or override the specified attribute in the ssbccConfig object.
    """
    self.config[name] = value;

  def SetMemoryBlock(self,name,value,errorInfo):
    """
    Set an attribute in the ssbccConfig object for the specified memory with
    the specified memory architecture.\n
    "value" must be a string with the format "\d+" or "\d+*\d+" where "\d+" is
    an integer.  The first format specifies a single memory with the stated
    size and the size must be a power of two.  The second format specified
    allocation of multiple memory blocks where the size is given by the first
    integer and must be a power of 2 and the number of blocks is given by the
    second integer and doesn't need to be a power of 2.
    """
    findStar = value.find('*');
    if findStar == -1:
      blockSize = int(value);
      nBlocks = 1;
    else:
      blockSize = int(value[0:findStar]);
      nBlocks = int(value[findStar+1:]);
    nbits_blockSize = int(round(math.log(blockSize,2)));
    if blockSize != 2**nbits_blockSize:
      raise SSBCCException('block size must be a power of 2 at %s: "%s"' % errorInfo);
    nbits_nBlocks = CeilLog2(nBlocks);
    self.Set(name, dict(
                   length=blockSize*nBlocks,
                   nbits=nbits_blockSize+nbits_nBlocks,
                   blockSize=blockSize,
                   nbits_blockSize=nbits_blockSize,
                   nBlocks=nBlocks,
                   nbits_nBlocks=nbits_nBlocks));

  def SetMemoryParameters(self,memParam,values):
    """
    Record the body of the specified memory based on the assembler output.
    """
    index = memParam['index'];
    for field in values:
      if field not in self.memories:
        self.memories[field] = list();
        for ix in range(len(self.memories['name'])):
          self.memories[field].append(None);
      self.memories[field][index] = values[field];

  def SignalLengthList(self):
    """
    Generate a list of the I/O signals and their lengths.
    """
    outlist = list();
    for io in self.ios:
      if io[2] == 'comment':
        continue;
      outlist.append((io[0],io[1],));
    return outlist;
