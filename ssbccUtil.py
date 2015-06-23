################################################################################
#
# Copyright 2012, Sinclair R.F., Inc.
#
# Utilities required by ssbcc
#
################################################################################

import math
import os
import re

################################################################################
#
# Classes
#
################################################################################

class SSBCCException(Exception):
  """
  Exception class for ssbcc.
  """
  def __init__(self,message):
    self.message = message;
  def __str__(self):
    return self.message;

################################################################################
#
# Methods
#
################################################################################

def CeilLog2(v):
  """
  Return the smallest integer that has a power of 2 greater than or equal to
  the argument.
  """
  tmp = int(math.log(v,2));
  while 2**tmp < v:
    tmp = tmp + 1;
  return tmp;

def CeilPow2(v):
  """
  Return the smallest power of 2 greater than or equal to the argument.
  """
  return 2**CeilLog2(v);

def ExtractBits(v,bits):
  """
  Extract the bits specified by bits from v.
  bits must have a Verilog-type format.  I.e., [7:0], [0+:8], etc.
  """
  if type(v) != int:
    raise SSBCCException('%s must be an int' % v);
  if re.match(r'[[]\d+:\d+]$',bits):
    cmd = re.findall(r'[[](\d+):(\d+)]$',bits)[0];
    b0 = int(cmd[1]);
    bL = int(cmd[0]) - b0 + 1;
  elif re.match(r'[[]\d+\+:\d+]$',bits):
    cmd = re.findall(r'[[](\d+)\+:(\d+)]$',bits)[0];
    b0 = int(cmd[0]);
    bL = int(cmd[1]);
  else:
    raise SSBCCException('Unrecognized bit slice format:  %s' % bits);
  if not 1 <= bL <= 8:
    raise SSBCCException('Malformed range "%s" doesn\'t provide 1 to 8 bits' % bits)
  v /= 2**b0;
  v %= 2**bL;
  return v;

def IntValue(v):
  """
  Convert a Verilog format integer into an integer value.
  """
  save_v = v;
  if re.match(r'([1-9]\d*)?\'[bodh]',v):
    length = 0;
    while v[0] != '\'':
      length *= 10;
      length += ord(v[0]) - ord('0');
      v = v[1:];
    v=v[1:];
    if v[0] == 'b':
      base = 2;
    elif v[0] == 'o':
      base = 8;
    elif v[0] == 'd':
      base = 10;
    elif v[0] == 'h':
      base = 16;
    else:
      raise Exception('Program bug -- unrecognized base:  "%c"' % v[0]);
    v = v[1:];
  else:
    length = 0;
    base = 10;
  ov = 0;
  for vv in [v[i] for i in range(len(v)) if v[i] != '_']:
    ov *= base;
    try:
      dv = int(vv,base);
    except:
      raise SSBCCException('Malformed parameter value:  "%s"' % save_v);
    ov += dv;
  if length > 0 and ov >= 2**length:
    raise SSBCCException('Parameter length and value don\'t match:  "%s"' % save_v);
  return ov;

def IsIntExpr(value):
  """
  Test the string to see if it is a well-formatted integer or multiplication of
  two integers.
  Allow underscores as per Verilog.
  """
  if re.match(r'(0|-?[1-9][0-9_]*)$',value):
    return True;
  elif re.match(r'(-?[1-9][0-9_]*\(\*[1-9][0-9_]*\)+)$',value):
    return True;
  else:
    return False;

def IsPosInt(v):
  """
  Indicate whether or not the argument is a positive integer.
  """
  return re.match(r'[1-9][0-9_]*$',v);

def IsPowerOf2(v):
  """
  Indicate whether or not the argument is a power of 2.
  """
  return v == 2**int(math.log(v,2)+0.5);

def LoadFile(filename,config):
  """
  Load the file into a list with the line contents and line numbers.\n
  filename is either the name of the file or a file object.\n
  Note:  The file object is closed in either case.
  """
  if type(filename) == str:
    for path in config.includepaths:
      fullfilename = os.path.join(path,filename);
      if os.path.isfile(fullfilename):
        try:
          fp = file(fullfilename);
        except:
          raise SSBCCException('Error opening "%s"' % filename);
        break;
    else:
      raise SSBCCException('.INCLUDE file "%s" not found' % filename);
  elif type(filename) == file:
    fp = filename;
  else:
    raise Exception('Unexpected argument type:  %s' % type(filename))
  v = list();
  ixLine = 0;
  for tmpLine in fp:
    ixLine += 1;
    while tmpLine and tmpLine[-1] in ('\n','\r',):
      tmpLine = tmpLine[0:-1];
    v.append((tmpLine,ixLine,));
  fp.close();
  return v;

def ParseIntExpr(value):
  """
  Convert a string containing well-formatted integer or multiplication of two
  integers.
  Allow underscores as per Verilog.
  Note:  If this routine is called, then the value should have already been
         verified to be a well-formatted integer string.
  """
  if type(value) == int:
    return value;
  if not IsIntExpr(value):
    raise Exception('Program Bug -- shouldn\'t call with a badly formatted integer expression');
  return eval(re.sub('_','',value));

################################################################################
#
# Unit test.
#
################################################################################

if __name__ == "__main__":

  def Test_ExtractBits(v,bits,vExpect):
    vGot = ExtractBits(v,bits);
    if vGot != vExpect:
      raise Exception('ExtractBits failed: 0x%04X %s ==> 0x%02X instead of 0x%02X' % (v,bits,ExtractBits(v,bits),vExpect,));

  for v in (256,257,510,):
    Test_ExtractBits(v,'[0+:8]',v%256);
    Test_ExtractBits(v,'[7:0]',v%256);
    Test_ExtractBits(v,'[4+:6]',(v/16)%64);
    Test_ExtractBits(v,'[9:4]',(v/16)%64);

  print 'Unit test passed';
