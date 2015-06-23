################################################################################
#
# Copyright 2012, Sinclair R.F., Inc.
#
# Verilog generation functions.
#
################################################################################

import math
import os
import random
import re

from ssbccUtil import *;

################################################################################
#
# Generate input and output core names.
#
################################################################################

def genCoreName():
  """
  Return the name of the file to use for the processor core.
  """
  return 'core.v';

def genOutName(rootName):
  """
  Return the name for the output micro controller module.
  """
  if re.match('.*\.v$',rootName):
    return rootName;
  else:
    return ("%s.v" % rootName);

################################################################################
#
# Generate the code to run the INPORT selection, the associated output
# strobes,and the set-reset latches.
#
################################################################################

def genFunctions(fp,config):
  """
  Output the optional bodies for the following functions and tasks:
    clog2               when $clog2 isn't available by commanding "--define_clog2"
                        on the ssbcc command line
    display_opcode      human-readable version of the opcode suitable for
                        waveform viewers
    display_trace       when the trace or monitor_stack peripherals are included
  """
  if 'display_opcode' in config.functions:
    displayOpcodePath = os.path.join(config.Get('corepath'),'display_opcode.v');
    fpDisplayOpcode = open(displayOpcodePath,'rt');
    if not fpDisplayOpcode:
      raise Exception('Program Bug -- "%s" not found' % displayOpcodePath);
    body = fpDisplayOpcode.read();
    fpDisplayOpcode.close();
    fp.write(body);
  if ('clog2' in config.functions) and config.Get('define_clog2'):
    fp.write("""
// Use constant function instead of builtin $clog2.
function integer clog2;
  input integer value;
  integer temp;
  begin
    temp = value - 1;
    for (clog2=0; temp>0; clog2=clog2+1)
      temp = temp >> 1;
  end
endfunction
""");
  if 'display_trace' in config.functions:
    displayTracePath = os.path.join(config.Get('corepath'),'display_trace.v');
    fpDisplayTrace = open(displayTracePath,'rt');
    if not fpDisplayTrace:
      raise Exception('Program Bug -- "%s" not found' % displayTracePath);
    body = fpDisplayTrace.read();
    fpDisplayTrace.close();
    fp.write(body);

def genInports(fp,config):
  """
  Generate the logic for the input signals.
  """
  if not config.inports:
    fp.write('// no input ports\n');
    return
  haveBitInportSignals = False;
  for ix in range(config.NInports()):
    thisPort = config.inports[ix][1:];
    for jx in range(len(thisPort)):
      signal = thisPort[jx];
      signalType = signal[2];
      if signalType in ('data','set-reset',):
        haveBitInportSignals = True;
  if haveBitInportSignals:
    fp.write('always @ (*)\n');
    fp.write('  case (s_T)\n');
  for ix in range(config.NInports()):
    thisPort = config.inports[ix][1:];
    nbits = 0;
    bitString = '';
    for jx in range(len(thisPort)):
      signal = thisPort[jx];
      signalName = signal[0];
      signalSize = signal[1];
      signalType = signal[2];
      if signalType == 'data':
        nbits = nbits + signalSize;
        if len(bitString)>0:
          bitString += ', ';
        bitString = bitString + signalName;
      if signalType == 'set-reset':
        fp.write('      8\'h%02X : s_T_inport = (%s || s_SETRESET_%s) ? 8\'hFF : 8\'h00;\n' % (ix, signalName, signalName));
    if nbits == 0:
      pass;
    elif nbits < 8:
      fp.write('      8\'h%02X : s_T_inport = { %d\'h0, %s };\n' % (ix,8-nbits,bitString));
    elif nbits == 8:
      fp.write('      8\'h%02X : s_T_inport = %s;\n' % (ix,bitString));
    else:
      fp.write('      8\'h%02X : s_T_inport = %s[0+:8];\n' % (ix,bitString));
  if haveBitInportSignals:
    fp.write('    default : s_T_inport = 8\'h00;\n');
    fp.write('  endcase\n');
    fp.write('\n');
  # Generate all the INPORT strobes.
  for ix in range(config.NInports()):
    thisPort = config.inports[ix][1:];
    for jx in range(len(thisPort)):
      signal = thisPort[jx];
      signalName = signal[0];
      signalType = signal[2];
      if signalType == 'strobe':
        fp.write('always @ (posedge i_clk)\n');
        fp.write('  if (i_rst)\n');
        fp.write('    %s <= 1\'b0;\n' % signalName);
        fp.write('  else if (s_inport)\n');
        fp.write('    %s <= (s_T == 8\'h%02X);\n' % (signalName,ix));
        fp.write('  else\n');
        fp.write('    %s <= 1\'b0;\n' % signalName);
        fp.write('\n');
  # Generate all the INPORT "set-reset"s.
  for ix in range(config.NInports()):
    thisPort = config.inports[ix][1:];
    if thisPort[0][2] == 'set-reset':
      signalName = thisPort[0][0];
      fp.write('always @(posedge i_clk)\n');
      fp.write('  if (i_rst)\n');
      fp.write('    s_SETRESET_%s <= 1\'b0;\n' % signalName);
      fp.write('  else if (s_inport && (s_T == 8\'h%02X))\n' % ix);
      fp.write('    s_SETRESET_%s <= 1\'b0;\n' % signalName);
      fp.write('  else if (%s)\n' % signalName);
      fp.write('    s_SETRESET_%s <= 1\'b1;\n' % signalName);
      fp.write('  else\n');
      fp.write('    s_SETRESET_%s <= s_SETRESET_%s;\n' % (signalName,signalName));

def genLocalParam(fp,config):
  """
  Generate the localparams for implementation-specific constants.
  """
  fp.write('localparam C_PC_WIDTH                              = %4d;\n' % CeilLog2(config.Get('nInstructions')['length']));
  fp.write('localparam C_RETURN_PTR_WIDTH                      = %4d;\n' % CeilLog2(config.Get('return_stack')));
  fp.write('localparam C_DATA_PTR_WIDTH                        = %4d;\n' % CeilLog2(config.Get('data_stack')));
  fp.write('localparam C_RETURN_WIDTH                          = (C_PC_WIDTH <= 8) ? 8 : C_PC_WIDTH;\n');

def genMemories(fp,fpMemFile,config,programBody):
  """
  Generate the memories for the instructions, data stack, return stack, and the
  memories and the operations to access these memories in this order.
  Initialize the instruction memory.\n
  fp            file handle for the output core
  fpMemFile     file handle for the memory initialization file
                Note:  This can be used to avoid running synthesis again.
  """
  combines = config.config['combine'];
  # Declare instruction ROM(s).
  instructionMemory = config.Get('nInstructions');
  instructionAddrWidth = (instructionMemory['nbits_blockSize']+3)/4;
  instructionNameIndexWidth = (instructionMemory['nbits_nBlocks']+3)/4;
  instructionMemNameFormat = 's_opcodeMemory_%%0%dX' % instructionNameIndexWidth;
  (combined,port,packing) = config.GetPacking('INSTRUCTION');
  instruction_mem_width = combined['memWidth'];
  for ixBlock in range(instructionMemory['nBlocks']):
    if instructionMemory['nBlocks'] == 1:
      memName = 's_opcodeMemory';
    else:
      memName = instructionMemNameFormat % ixBlock;
    if config.Get('synth_instr_mem'):
      fp.write('%s ' % config.Get('synth_instr_mem'));
    fp.write('reg [%d:0] %s[%d:0];\n' % (instruction_mem_width-1,memName,instructionMemory['blockSize']-1,));
  # Declare data stack RAM and return stacks RAM if they aren't combined into other memories.
  for memType in ('DATA_STACK','RETURN_STACK',):
    (combined,port,packing) = config.GetPacking(memType);
    if combined['port'][0]['packing'][0]['name'] != memType:
      continue;
    fp.write('reg [%d:0] %s[%d:0];\n' % (combined['memWidth']-1,combined['memName'],combined['nWords']-1,));
  # Declare the memories.
  for combined in combines:
    if combined['mems'][0] in ('INSTRUCTION','DATA_STACK','RETURN_STACK',):
      continue;
    fp.write('reg [%d:0] %s[%d:0];\n' % (combined['memWidth']-1,combined['memName'],combined['nWords']-1,));
  # Vertical separation between declarations and first initialization.
  fp.write('\n');
  # Initialize the instruction memory.
  (combined,port,packing) = config.GetPacking('INSTRUCTION');
  fp.write('initial begin\n');
  ixRecordedBody = 0;
  nbits = combined['memWidth'];
  ixInstruction = 0;
  instructionBodyLength = packing['length'];
  for ixBlock in range(instructionMemory['nBlocks']):
    if instructionMemory['nBlocks'] == 1:
      memName = 's_opcodeMemory';
    else:
      memName = instructionMemNameFormat % ixBlock;
    if nbits == 9:
      formatp = '  %s[\'h%%0%dX] = { 1\'b1, %%s };' % (memName,instructionAddrWidth,);
      formatn = '  %s[\'h%%0%dX] = 9\'h%%s; // %%s\n' % (memName,instructionAddrWidth,);
      formate = '  %s[\'h%%0%dX] = 9\'h%%03x;\n' % (memName,instructionAddrWidth,);
    else:
      formatp = '  %s[\'h%%0%dX] = { %d\'d0, 1\'b1, %%s };' % (memName,instructionAddrWidth,nbits-9,);
      formatn = '  %s[\'h%%0%dX] = { %d\'d0, 9\'h%%s }; // %%s\n' % (memName,instructionAddrWidth,nbits-9,);
      formate = '  %s[\'h%%0%dX] = { %d\'d0, 9\'h%%03x };\n' % (memName,instructionAddrWidth,nbits-9,);
    rand_instr_mem = config.Get('rand_instr_mem');
    for ixMem in range(instructionMemory['blockSize']):
      memAddr = instructionMemory['blockSize']*ixBlock+ixMem;
      if ixRecordedBody < len(programBody):
        for ixRecordedBody in range(ixRecordedBody,len(programBody)):
          if programBody[ixRecordedBody][0] == '-':
            fp.write('  // %s\n' % programBody[ixRecordedBody][2:]);
          else:
            if programBody[ixRecordedBody][0] == 'p':
              (parameterString,parameterComment) = re.findall(r'(\S+)(.*)$',programBody[ixRecordedBody][2:])[0];
              fp.write(formatp % (ixMem,parameterString,));
              fpMemFile.write('@%04X %03X\n' % (memAddr,0x100 + config.GetParameterValue(parameterString)));
              if len(parameterComment) > 0:
                fp.write(' // %s' % parameterComment[1:]);
              fp.write('\n');
            else:
              fp.write(formatn % (ixMem,programBody[ixRecordedBody][0:3],programBody[ixRecordedBody][4:]));
              fpMemFile.write('@%04X %s\n' % (memAddr,programBody[ixRecordedBody][0:3],));
            break;
        ixRecordedBody = ixRecordedBody + 1;
      elif ixInstruction < instructionBodyLength:
        fp.write(formate % (ixMem,0 if not rand_instr_mem else random.randint(0,2**9-1),));
        fpMemFile.write('@%04X 000\n' % memAddr);
      else:
        break;
      ixInstruction = ixInstruction + 1;
    # Save the last memory name for memories combined at the end of the instruction memory.
    combined['memName'] = memName;
  if len(combined['port']) > 1:
    offset0 = instructionMemory['blockSize']*(instructionMemory['nBlocks']-1);
    combined['port'][1]['offset'] -= offset0;
    genMemories_init(fp,config,combined,fpMemFile=fpMemFile,memName=memName,memLength=instructionMemory['blockSize']);
  fp.write('end\n\n');
  # Initialize the data stack.
  for combined in [thisCombined for thisCombined in combines if thisCombined['port'][0]['packing'][0]['name'] == 'DATA_STACK']:
    fp.write('initial begin\n');
    genMemories_init(fp,config,combined);
    fp.write('end\n\n');
    break;
  # Initialize the return stack.
  for combined in [thisCombined for thisCombined in combines if thisCombined['port'][0]['packing'][0]['name'] == 'RETURN_STACK']:
    fp.write('initial begin\n');
    genMemories_init(fp,config,combined);
    fp.write('end\n\n');
    break;
  # Initialize the memories
  for combined in [thisCombined for thisCombined in combines if thisCombined['port'][0]['packing'][0]['name'] not in ('INSTRUCTION','DATA_STACK','RETURN_STACK',)]:
    fp.write('initial begin\n');
    genMemories_init(fp,config,combined);
    fp.write('end\n\n');
  # Generate the opcode read logic.
  fp.write('//\n');
  fp.write('// opcode read logic\n');
  fp.write('//\n');
  fp.write('\n');
  fp.write('initial s_opcode = 9\'h000;\n');
  if instruction_mem_width == 10:
    fp.write('reg not_used_s_opcode = 1\'b0;\n');
  elif instruction_mem_width > 10:
    fp.write('reg [%d:0] not_used_s_opcode = %d\'d0;\n' % (instruction_mem_width-10,instruction_mem_width-9,));
  fp.write('always @ (posedge i_clk)\n');
  fp.write('  if (i_rst) begin\n');
  fp.write('    s_opcode <= 9\'h000;\n');
  if instruction_mem_width > 9:
    fp.write('    not_used_s_opcode <= %d\'d0;\n' % (instruction_mem_width-9,));
  if instruction_mem_width == 9:
    instructionReadTarget = 's_opcode';
  else:
    instructionReadTarget = '{ not_used_s_opcode, s_opcode }';
  if instructionMemory['nBlocks'] == 1:
    fp.write('  end else\n');
    fp.write('    %s <= s_opcodeMemory[s_PC];\n' % instructionReadTarget);
  else:
    fp.write('  end else case (s_PC[%d+:%d])\n' % (instructionMemory['nbits_blockSize'],instructionMemory['nbits_nBlocks'],));
    for ixBlock in range(instructionMemory['nBlocks']):
      memName = instructionMemNameFormat % ixBlock;
      thisLine = '%d\'h%X : %s <= %s[s_PC[0+:%d]];\n' % (instructionMemory['nbits_nBlocks'],ixBlock,instructionReadTarget,memName,instructionMemory['nbits_blockSize'],);
      while thisLine.index(':') < 12:
        thisLine = ' ' + thisLine;
      fp.write(thisLine);
    fp.write('    default : %s <= %d\'h000;\n' % (instructionReadTarget,instruction_mem_width,));
    fp.write('  endcase\n');
  fp.write('\n');
  #
  # Generate the data_stack read and write logic.
  #
  fp.write('//\n// data stack read and write logic\n//\n\n');
  (combined,port,packing) = config.GetPacking('DATA_STACK');
  genMemories_stack(fp,combined,port,packing,'s_N','s_Np','s_stack == C_STACK_INC');
  #
  # Generate the return_stack read and write logic.
  #
  fp.write('//\n// return stack read and write logic\n//\n\n');
  (combined,port,packing) = config.GetPacking('RETURN_STACK');
  genMemories_stack(fp,combined,port,packing,'s_R_pre','s_R','s_return == C_RETURN_INC');
  #
  # Coalesce the memory bank indices and the corresponding memory names, offsets, lengths, etc.
  #
  lclMemName = [];
  lclMemParam = [];
  for ixBank in range(4):
    memParam = config.GetMemoryByBank(ixBank);
    if not memParam:
      continue;
    lclMemName.append(memParam['name']);
    lclMemParam.append(dict(bank=memParam['bank'],type=memParam['type']));
  for combined in combines:
    for port in combined['port']:
      if port['packing'][0]['name'] in ('INSTRUCTION','DATA_STACK','RETURN_STACK',):
        continue;
      for packing in port['packing']:
        if packing['name'] not in lclMemName:
          print 'WARNING:  Memory "%s" not used in program' % packing['name'];
          continue;
        ixLclMem = lclMemName.index(packing['name']);
        thisLclMemParam = lclMemParam[ixLclMem];
        thisLclMemParam['combined'] = combined;
        thisLclMemParam['port'] = port;
        thisLclMemParam['packing'] = packing;
  # Generate the memory read/write logic.
  if config.NMemories() == 0:
    fp.write('// no memories\n\n');
  else:
    # Compute the address string / address string format for each RAM/ROM port.
    for combined in combines:
      for port in combined['port']:
        addrWidth = CeilLog2(port['nWords'])-CeilLog2(port['ratio']);
        addrString = '';
        if len(combined['port']) > 1:
          addrString = '{' + addrString;
          nMajorAddressBits = CeilLog2(combined['nWords']) - CeilLog2(port['nWords']);
          addrString += '%d\'h%x,' % (nMajorAddressBits,port['offset']/port['nWords'],);
        addrString += 's_T[%d:0]' % (addrWidth-1,);
        if port['ratio'] > 1:
          if '{' not in addrString:
            addrString = '{' + addrString;
          addrString += ',%d\'d%%d' % (CeilLog2(port['ratio']),);
        if '{' in addrString:
          addrString += '}';
        port['addrString'] = addrString;
    # Generate the memory read logic.
    fp.write('//\n// memory read logic\n//\n\n');
    for combined in combines:
      if combined['memArch'] != 'sync':
        continue;
      memName = combined['memName'];
      memWidth = combined['memWidth'];
      for port in combined['port']:
        if port['packing'][0]['name'] in ('INSTRUCTION','DATA_STACK','RETURN_STACK',):
          continue;
        addrString = port['addrString'];
        totalWidth = memWidth * port['ratio'];
        if combined['memArch'] == 'sync':
          fp.write('reg [%d:0] %s_reg = %d\'h0;\n' % (totalWidth-1,memName,totalWidth,));
        if port['ratio'] == 1:
          fp.write('always @ (%s[%s])\n' % (memName,addrString,));
          fp.write('  %s_reg = %s[%s];\n' % (memName,memName,addrString,));
        else:
          fp.write('always @ (');
          for ratio in range(port['ratio']):
            if ratio != 0:
              fp.write(',');
            fp.write('%s[%s]' % (memName,(addrString % ratio),));
          fp.write(') begin\n');
          for ratio in range(port['ratio']):
            fp.write('  %s_reg[%d+:%d] = %s[%s];\n' % (memName,ratio*memWidth,memWidth,memName,(addrString % ratio),));
          fp.write('end\n');
    for ixLclMemParam in range(len(lclMemParam)):
      thisLclMemParam = lclMemParam[ixLclMemParam];
      combined = thisLclMemParam['combined'];
      if ixLclMemParam == 0:
        fp.write('assign s_memory = ');
      else:
        fp.write('                : ');
      fp.write('(s_opcode[0+:2] == 2\'d%d) ? ' % thisLclMemParam['bank']);
      if combined['memArch'] == 'LUT':
        fp.write('%s[%s]\n' % (combined['memName'],thisLclMemParam['port']['addrString'],));
      else:
        fp.write('%s_reg[%d+:8]\n' % (combined['memName'],combined['memWidth']*thisLclMemParam['packing']['lane'],));
    fp.write('                : 8\'d0;\n');
    fp.write('\n');
    # Generate the memory write logic.
    fp.write('//\n// memory write logic\n//\n\n');
    for combined in combines:
      for port in combined['port']:
        if port['packing'][0]['name'] in ('INSTRUCTION','DATA_STACK','RETURN_STACK',):
          continue;
        thisRams = [];
        for packing in port['packing']:
          memParam = config.GetMemoryByName(packing['name']);
          if not memParam:
            continue;
          if memParam['type'] != 'RAM':
            continue;
          thisRams.append({ 'memParam':memParam, 'packing':packing });
        if not thisRams:
          continue;
        fp.write('always @ (posedge i_clk) begin\n');
        for ram in thisRams:
          memParam = ram['memParam'];
          packing = ram['packing'];
          if combined['memArch'] == 'LUT':
            fp.write('  if (s_mem_wr && (s_opcode[0+:2] == 2\'d%d))\n' % memParam['bank']);
            fp.write('    %s[%s] <= s_N; // memory %s\n' % (combined['memName'],port['addrString'],packing['name'],));
          else:
            addrString = port['addrString'];
            if '%' in addrString:
              addrString = addrString % packing['lane'];
            fp.write('  if (s_mem_wr && (s_opcode[0+:2] == 2\'d%d))\n' % memParam['bank']);
            if combined['memWidth'] == 8:
              source = 's_N';
            else:
              source = '{ %d\'d0, s_N }' % (combined['memWidth']-8);
            fp.write('    %s[%s] <= %s; // memory %s\n' % (combined['memName'],addrString,source,packing['name'],));
        fp.write('end\n\n');

def genMemories_assign(fp,mode,combined,port,packing,addr,sigName):
  """
  Utility function for genMemories.\n
  Generate the logic to perform memory writes, including writes to multiple
  memory locations (for the return stack) and writing zeros to otherwise unused
  bits.
  """
  if mode not in ['write','read']:
    raise Exception('Program Bug: %s' % mode);
  memName = combined['memName'];
  memWidth = combined['memWidth'];
  ratio = packing['ratio']
  sigWidth = packing['nbits'];
  nbitsRatio = CeilLog2(ratio);
  notUsedWidth = ratio*memWidth - sigWidth;
  isLUT = (combined['memArch'] == 'LUT');
  if not isLUT and port['nWords'] != combined['nWords']:
    memAddrWidth = CeilLog2(combined['nWords']);
    thisAddrWidth = CeilLog2(packing['nWords']);
    nbitsOffset = memAddrWidth - thisAddrWidth;
    addr = '{%d\'h%%0%dx,%s}' % (nbitsOffset,(nbitsOffset+3)/4,addr,) % (port['offset']/2**thisAddrWidth,);
  for ixRatio in range(ratio):
    ix0 = ixRatio*memWidth;
    ix1 = ix0+memWidth;
    if ratio == 1:
      thisAddr = addr;
    else:
      thisAddr = '%s, %d\'h%%0%dx' % (addr,nbitsRatio,(nbitsRatio+3)/4,) % ixRatio;
    if thisAddr.find(',') != -1:
      thisAddr = '{ %s }' % thisAddr;
    if ix1 <= sigWidth:
      thisSignal = '%s[%d:%d]' % (sigName,ix1-1,ix0,);
    elif ix0 <= sigWidth:
      nEmpty = ix1-sigWidth;
      if mode == 'write':
        thisSignal = '{ %d\'d0, %s[%d:%d] }' % (nEmpty,sigName,sigWidth-1,ix0,);
      elif notUsedWidth == 1:
        thisSignal = '{ not_used_%s, %s[%d:%d] }' % (sigName,sigName,sigWidth-1,ix0,);
      else:
        thisSignal = '{ not_used_%s[%d:0], %s[%d:%d] }' % (sigName,ix1-sigWidth-1,sigName,sigWidth-1,ix0,);
    else:
      if mode == 'write':
        thisSignal = '%d\'0' % memWidth;
      else:
        thisSignal = 'not_used_%s[%d:%d]' % (sigName,ix1-sigWidth-1,ix0-sigWidth,);
    if mode == 'write' and isLUT:
      fp.write('    %s[%s] <= %s;\n' % (memName,thisAddr,thisSignal,));
    elif mode == 'write' and not isLUT:
      fp.write('    %s[%s] = %s; // coerce write-through\n' % (memName,thisAddr,thisSignal,));
    elif mode == 'read' and not isLUT:
      fp.write('  %s <= %s[%s];\n' % (thisSignal,memName,thisAddr,));
    elif mode == 'read' and isLUT:
      fp.write('always @ (%s[%s],%s)\n' % (memName,thisAddr,thisAddr,));
      fp.write('  %s = %s[%s];\n' % (thisSignal,memName,thisAddr,));

def genMemories_init(fp,config,combined,fpMemFile=None,memName=None,memLength=None):
  """
  Utility function for genMemories.\n
  Generate the logic to initialize memories based on the memory width and the
  initialization output from the assembler.
  """
  if not memName:
    memName = combined['memName'];
  if not memLength:
    memLength = combined['nWords'];
  memWidth = combined['memWidth'];
  # Compute the formatting for the initialization values
  nAddrBits = CeilLog2(memLength);
  if memWidth == 8:
    formatd = '%s[\'h%%0%dX] = 8\'h%%s;' % (memName,(nAddrBits+3)/4,);
  else:
    formatd = '%s[\'h%%0%dX] = { %d\'d0, 8\'h%%s };' % (memName,(nAddrBits+3)/4,memWidth-8,);
  formate = '%s[\'h%%0%dX] = %d\'h%s;' % (memName,(nAddrBits+3)/4,memWidth,'0'*((memWidth+3)/4),);
  # Create the list of initialization statements.
  for port in combined['port']:
    fills = list();
    values = list();
    if port['packing'][0]['name'] == 'INSTRUCTION':
      continue;
    for packing in port['packing']:
      thisMemName = packing['name'];
      if thisMemName in ('DATA_STACK','RETURN_STACK',):
        for thisRatio in range(port['ratio']):
          thisFill = list();
          fills.append(thisFill);
          thisValue = list();
          values.append(thisValue);
          curOffset = 0;
          while curOffset < port['packing'][0]['length']:
            addr = port['offset']+port['ratio']*curOffset+packing['lane']+thisRatio;
            thisFill.append({ 'assign':(formate % addr) });
            thisValue.append(0);
            curOffset += 1;
      else:
        memParam = config.GetMemoryByName(thisMemName);
        if not memParam:
          raise Exception('Program bug -- memory "%s" not found' % thisMemName);
        thisFill = list();
        fills.append(thisFill);
        thisValue = list();
        values.append(thisValue);
        curOffset = 0;
        if memParam['body'] != None:
          for line in memParam['body']:
            if line[0] == '-':
              varName = line[2:-1];
              continue;
            addr = port['offset']+port['ratio']*curOffset+packing['lane'];
            thisFill.append({ 'assign':(formatd % (addr,line[0:2],)) });
            thisFill[-1]['comment'] = varName if varName else '.';
            thisValue.append(int(line[0:2],16));
            varName = None;
            curOffset += 1;
      if (curOffset > packing['nWords']):
        raise Exception('Program Bug -- memory body longer than allocated memory space');
      while curOffset < packing['length']:
        addr = port['ratio']*curOffset+port['offset'];
        thisFill.append({ 'assign':(formate % addr) });
        thisValue.append(0);
        curOffset += 1;
    endLength = port['nWords']/port['ratio'];
    for ixFill in range(len(fills)):
      thisFill = fills[ixFill];
      thisValue = values[ixFill];
      curOffset = len(thisFill);
      if curOffset < endLength:
        addr = port['ratio']*curOffset+port['offset']+ixFill;
        thisFill.append({ 'assign':(formate % addr), 'comment':'***' });
        thisValue.append(0);
        curOffset += 1;
        while curOffset < endLength:
          addr = port['ratio']*curOffset+port['offset']+ixFill;
          thisFill.append({ 'assign':(formate % addr) });
          thisValue.append(0);
          curOffset += 1;
    for thisFill in fills:
      commentLengths = [len(entry['comment']) for entry in thisFill if 'comment' in entry];
      if not commentLengths:
        formatc = '%s';
      elif len(fills) == 1:
        formatc = '%s // %s';
      else:
        formatc = '%%s /* %%-%ds */' % max(commentLengths);
      for entry in thisFill:
        if 'comment' in entry:
          entry['output'] = formatc % (entry['assign'],entry['comment'],);
        elif commentLengths:
          entry['output'] = formatc % (entry['assign'],'',);
        else:
          entry['output'] = entry['assign'];
    lens = [len(thisFill) for thisFill in fills];
    if min(lens) < max(lens):
      raise Exception('Program Bug -- unequal fill lengths');
    formatLine = ' ';
    for thisFill in fills:
      formatLine += ' %%-%ds' % len(thisFill[0]['output']);
    formatLine += '\n';
    names = [packing['name'] for packing in port['packing']];
    while len(names) < len(fills):
      names.append('');
    names[0] = '// '+names[0];
    fp.write(formatLine % tuple(names));
    for ixFill in range(lens[0]):
      fp.write(formatLine % tuple([thisFill[ixFill]['output'] for thisFill in fills]));
    if fpMemFile:
      for port in combined['port']:
        if port['packing'][0]['name'] != 'INSTRUCTION':
          break;
      else:
        raise Exception('Program Bug:  Should have had a start address here.');
      addr = port['offset'];
      for ixFill in range(lens[0]):
        for ixCol in range(len(lens)):
          fpMemFile.write('@%04X %03X\n' % (addr,values[ixCol][ixFill],));
          addr += 1;

def genMemories_stack(fp,combined,port,packing,inSignalName,outSignalName,muxTest):
  nbits = packing['nbits'];                             # number of bits in the signal
  totalWidth = packing['ratio'] * combined['memWidth']; # width of the [multi-]word memory access
  # Generate the core.
  if combined['memArch'] == 'sync':
    fp.write('reg [%d:0] %s_reg = %d\'d0;\n' % (nbits-1,outSignalName,nbits,));
  if totalWidth == nbits+1:
    fp.write('reg not_used_%s_reg = 1\'b0;\n' % outSignalName);
  elif totalWidth > nbits+1:
    fp.write('reg [%d:0] not_used_%s_reg = %d\'d0;\n' % (totalWidth-nbits-1,outSignalName,totalWidth-nbits,));
  fp.write('always @ (posedge i_clk) begin\n');
  fp.write('  if (%s) begin\n' % muxTest);
  genMemories_assign(fp,'write',combined,port,packing,outSignalName+'_stack_ptr_next',inSignalName);
  fp.write('  end\n');
  if combined['memArch'] == 'sync':
    genMemories_assign(fp,'read',combined,port,packing,outSignalName+'_stack_ptr_next',outSignalName+'_reg');
  fp.write('end\n');
  if combined['memArch'] == 'LUT':
    if totalWidth == nbits+1:
      fp.write('wire not_used_%s_reg;\n' % outSignalName);
    elif totalWidth > nbits+1:
      fp.write('wire [%d:0] not_used_%s_reg;\n' % (totalWidth-nbits-1,outSignalName,));
    genMemories_assign(fp,'read',combined,port,packing,outSignalName+'_stack_ptr',outSignalName);
  else:
    fp.write('initial %s = %d\'d0;\n' % (outSignalName,nbits,));
    fp.write('always @ (%s_reg)\n' % outSignalName);
    fp.write('  %s = %s_reg;\n' % (outSignalName,outSignalName,));
  fp.write('\n');

def genModule(fp,config):
  """
  Generate the body of the module declaration and the parameter and localparam
  declarations.
  """
  # Insert the always-there stuff at the start of the module.
  config.ios.insert(0,('synchronous reset and processor clock',None,'comment',));
  if config.Get('invertReset'):
    config.ios.insert(1,('i_rstn',1,'input',));
  else:
    config.ios.insert(1,('i_rst',1,'input',));
  config.ios.insert(2,('i_clk',1,'input',));
  # Starting from the end, determine the termination character for each line of
  # the module declaration
  signalFound = False;
  for ix in range(len(config.ios),0,-1):
    thisIOs = config.ios[ix-1];
    signalType = thisIOs[2];
    if signalType == 'comment' or not signalFound:
      thisIOs = thisIOs + ('\n',);
    else:
      thisIOs = thisIOs + (',\n',);
    if signalType != 'comment':
      signalFound = True;
    config.ios[ix-1] = thisIOs;
  # Write the module declaration.
  fp.write('module %s(\n' % config.Get('outCoreName'));
  if config.ios:
    for ix in range(len(config.ios)):
      signal = config.ios[ix];
      signalName = signal[0];
      signalWidth = signal[1];
      signalType = signal[2];
      signalLineEnd = signal[3];
      if signalType == 'comment':
        fp.write('  // %s' % signalName);
      elif signalType == 'input':
        if signalWidth == 1:
          fp.write('  input  wire           %s' % signalName);
        elif signalWidth <= 10:
          fp.write('  input  wire     [%d:0] %s' % (signalWidth-1,signalName));
        else:
          fp.write('  input  wire    [%2d:0] %s' % (signalWidth-1,signalName));
      elif signalType == 'output':
        if signalWidth == 1:
          fp.write('  output reg            %s' % signalName);
        elif signalWidth <= 10:
          fp.write('  output reg      [%d:0] %s' % (signalWidth-1,signalName));
        else:
          fp.write('  output reg     [%2d:0] %s' % (signalWidth-1,signalName));
      elif signalType == 'inout':
        if signalWidth == 1:
          fp.write('  inout  wire           %s' % signalName);
        elif signalWidth <= 10:
          fp.write('  inout  wire     [%d:0] %s' % (signalWidth-1,signalName));
        else:
          fp.write('  inout  wire    [%2d:0] %s' % (signalWidth-1,signalName));
      else:
        raise Exception('Program Bug -- unrecognized ios "%s"' % signalType);
      fp.write(signalLineEnd);
  fp.write(');\n');
  # Write parameter and localparam statements (with separating blank lines).
  if config.parameters:
    isfirst = True;
    for parameter in config.parameters:
      if parameter[0][0] == 'G':
        if isfirst:
          fp.write('\n');
          isfirst = False;
        fp.write('parameter %s = %s;\n' % (parameter[0],parameter[1]));
    isfirst = True;
    for parameter in config.parameters:
      if parameter[0][0] == 'L':
        if isfirst:
          fp.write('\n');
          isfirst = False;
        fp.write('localparam %s = %s;\n' % (parameter[0],parameter[1]));
  # If an inverted reset is supplied, invert it.
  if config.Get('invertReset'):
    fp.write('\n');
    fp.write('// Invert received active-low reset\n');
    fp.write('wire i_rst = ~i_rstn;\n');

def genOutports(fp,config):
  """
  Generate the logic for the output signals.\n
  Note:  Empty bodies are allowed for inport and outports (see for example
         big_outport generates the composite output signal instead of using the
         code that would have been auto-generated here).
  """
  if not config.outports:
    fp.write('// no output ports\n');
    return;
  for ix in range(config.NOutports()):
    thisPort = config.outports[ix][2:];
    if not thisPort:
      continue;
    bitWidth = 0;
    bitName = '';
    bitInit = '';
    for jx in range(len(thisPort)):
      signal = thisPort[jx];
      signalName = signal[0];
      signalWidth = signal[1];
      signalType = signal[2];
      signalInit = '%d\'d0' % signalWidth if len(signal)==3 else signal[3];
      if signalType == 'data':
        fp.write('initial %s = %s;\n' % (signalName,signalInit,));
        if bitWidth > 0:
          bitName += ', ';
          bitInit += ', '
        bitWidth = bitWidth + signalWidth;
        bitName += signalName;
        bitInit += signalInit;
    if bitWidth > 0:
      if ',' in bitName:
        bitName = '{ ' + bitName + ' }';
        bitInit = '{ ' + bitInit + ' }';
      fp.write('always @ (posedge i_clk)\n');
      fp.write('  if (i_rst)\n');
      fp.write('    %s <= %s;\n' % (bitName,bitInit,));
      fp.write('  else if (s_outport && (s_T == 8\'h%02X))\n' % ix);
      fp.write('    %s <= s_N[0+:%d];\n' % (bitName,bitWidth));
      fp.write('  else\n');
      fp.write('    %s <= %s;\n' % (bitName,bitName));
      fp.write('\n');
    for jx in range(len(thisPort)):
      signal = thisPort[jx];
      signalName = signal[0];
      signalType = signal[2];
      if signalType == 'data':
        pass;
      elif signalType == 'strobe':
        fp.write('initial %s = 1\'b0;\n' % signalName);
        fp.write('always @ (posedge i_clk)\n');
        fp.write('  if (i_rst)\n');
        fp.write('    %s <= 1\'b0;\n' % signalName);
        fp.write('  else if (s_outport)\n');
        fp.write('    %s <= (s_T == 8\'h%02X);\n' % (signalName,ix));
        fp.write('  else\n');
        fp.write('    %s <= 1\'b0;\n' % signalName);
        fp.write('\n');
      else:
        raise Exception('Program Bug -- unrecognized signal type "%s"' % signalType);

def genSignals(fp,config):
  """
  Insert the definitions of additional signals for the module.\n
  These can be signals required communications between the core and peripherals.
  """
  if not config.signals:
    fp.write('// no additional signals\n');
    return;
  maxLength = 0;
  for thisSignal in config.signals:
    signalName = thisSignal[0];
    if len(signalName) > maxLength:
      maxLength = len(signalName);
  maxLength = maxLength + 12;
  for thisSignal in config.signals:
    signalName = thisSignal[0];
    signalWidth = thisSignal[1];
    signalInit = "%d'd0" % signalWidth if len(thisSignal) < 3 else thisSignal[2];
    outString = 'reg ';
    if signalWidth == 1:
      outString += '       ';
    elif signalWidth <= 10:
      outString += (' [%d:0] ' % (signalWidth-1));
    else:
      outString += ('[%2d:0] ' % (signalWidth-1));
    outString += signalName;
    if signalInit != None:
      outString += ' '*(maxLength-len(outString));
      outString += ' = ' + signalInit;
    outString += ';\n'
    fp.write(outString);

def genUserHeader(fp,user_header):
  """
  Copy the user header to the output module.
  """
  for ix in range(len(user_header)):
    fp.write('// %s\n' % user_header[ix]);
