################################################################################
#
# Copyright 2012-2014, Sinclair R.F., Inc.
#
################################################################################

import re

from ssbccUtil import IsIntExpr
from ssbccUtil import IsPosInt
from ssbccUtil import IsPowerOf2
from ssbccUtil import ParseIntExpr
from ssbccUtil import SSBCCException

class SSBCCperipheral:
  """Base class for peripherals"""

  def __init__(self,peripheralFile,config,param_list,loc):
    """
    Prototype constructor.
    peripheralFile      the full path name of the peripheral source
                        Note:  "__file__" doesn't work because 'execfile" and
                        "exec" are used to load the python script for the
                        peripheral.
    config              the ssbccConfig object for the processor core
    param_list          parameter list for the processor
    loc                 file name and line number for error messages
    """
    pass;

  def AddAttr(self,config,name,value,reformat,loc,optFn=None):
    """
    Add attribute to the peripheral:
    config      ssbccConfig object for the procedssor core
    name        attribute name
    value       possibly optional value for the attribute
    reformat    regular expression format for the attribute value
                Note:  reformat=None means the attribute can only be set to True
    loc         file name and line number for error messages
    optFn       optional function to set stored type
                Note:  See IntPow, RateMethod, etc. below for example methods.
    """
    if hasattr(self,name):
      raise SSBCCException('%s repeated at %s' % (name,loc,));
    if reformat == None:
      if value != None:
        raise SSBCCException('No parameter allowed for %s at %s' % (name,loc,));
      setattr(self,name,True);
    else:
      if value == None:
        raise SSBCCException('%s missing value at %s' % (name,loc,));
      if not re.match(reformat,value):
        raise SSBCCException('I/O symbol at %s does not match required format "%s":  "%s"' % (loc,reformat,value,));
      if optFn != None:
        try:
          value = optFn(value);
        except SSBCCException,msg:
          raise SSBCCException('Parameter "%s=%s" at %s:  %s' % (name,value,loc,str(msg),));
        except:
          raise SSBCCException('Value for "%s" not parsable at %s:  "%s"' % (name,loc,value,));
      setattr(self,name,value);

  def GenAssembly(self,config):
    """
    Virtual method to generate assembly modules associated with the peripheral.
    """
    pass;

  def GenHDL(self,fp,config):
    """
    Generate the peripheral HDL.
    fp          file pointer for the output processor
    config      ssbccConfig object for the procedssor core
    """
    if config.Get('hdl') == 'Verilog':
      self.GenVerilog(fp,config);
    elif config.Get('hdl') == 'VHDL':
      self.GenVHDL(fp,config);
    else:
      raise SSBCCException('HDL "%s" not implemented' % config.Get('hdl'));

  def GenVerilog(self,fp,config):
    """
    Virtual method to generate the Verilog version of the peripheral.
    Raise an exception if there is no Verilog version of the peripheral.
    """
    raise Exception('Verilog is not implemented for this peripheral');

  def GenVerilogFinal(self,config,body):
    """
    Clean up the peripheral code.
    Change "$clog2" to "clog2" for simulators and synthesis tools that don't
      recognize or process "$clog2."
    """
    if config.Get('define_clog2'):
      body = re.sub('\$clog2','clog2',body);
    return body;

  def GenVHDL(self,fp,config):
    """
    Virtual method to generate the VHDL version of the peripheral.
    Raise an exception if there is no VHDL version of the peripheral.
    """
    raise Exception('VHDL is not implemented for this peripheral');

  def LoadCore(self,filename,extension):
    """
    Read the source HDL for the peripheral from the same directory as the python
    script.
    filename    name for the python peripheral (usually "__file__")
    extension   the string such as ".v" or ".vhd" required by the HDL\n
    Note:  The '.' must be included in the extension.  For example, the UART
           peripheral uses '_Rx.v' and '_Tx.v' or similar to invoke the UART_Tx
           and UART_Rx HDL files.
    """
    hdlName = re.sub(r'\.py$',extension,filename);
    fp = open(hdlName,'rt');
    body = fp.read();
    fp.close();
    return body;

  ##############################################################################
  #
  # Methods to supplement python intrisics for the optFn argument of AddAttr
  #
  # Note:  AddAttr embelleshes exception messages with the symbol name and
  #        source code line number.
  #
  # Note:  One weird side effect of using lambda expressions is that the
  #        functions won't be recognized unless they're members of the
  #        SSBCCperipheral class.
  #
  ##############################################################################

  def IntPow2Method(self,config,value,lowLimit=1,highLimit=None):
    """
    Return the integer value of the argument if it is a power of 2 between the
    optional limits (inclusive).  Otherwise throw an error.\n
    Note:  Other than a lower limit of 1 for "lowLimit", IntMethod validates
           "lowLimit" and "highLimit".
    """
    value = self.IntMethod(config,value,lowLimit,highLimit)
    if lowLimit < 1:
      raise SSBCCException('Program bug:  lowLimit = %d is less than 1' % lowLimit);
    if not IsPowerOf2(value):
      raise SSBCCException('Must be a power of 2');
    return value;

  def IntMethod(self,config,value,lowLimit=None,highLimit=None):
    """
    Return the integer value of the argument.  Throw an error if the argument is
    unrecognized, not an integer, or is outside the optionally specified range.
    """
    if (lowLimit != None) and (highLimit != None) and (highLimit < lowLimit):
      raise SSBCCException('Program bug:  lowLimit = %d and highLimit = %d conflict' % (lowLimit,highLimit,));
    if re.match(r'L_\w+$',value):
      if not config.IsParameter(value):
        raise SSBCCException('Unrecognized parameter');
      ix = [param[0] for param in config.parameters].index(value);
      value = config.parameters[ix][1];
    elif re.match(r'C_\w+$',value):
      if not config.IsConstant(value):
        raise SSBCCException('Unrecognized constant');
      value = config.constants[value];
    value = ParseIntExpr(value);
    if (lowLimit != None) and value < lowLimit:
      if lowLimit == 1:
        raise SSBCCException('Must be a positive integer');
      else:
        raise SSBCCException('Cannot be less than %d' % lowLimit);
    if (highLimit != None) and value > highLimit:
      raise SSBCCException('Cannot be more than %d' % highLimit);
    return value;

  def RateMethod(self,config,value):
    """
    Return the string to evaluate the provided value or ratio of two values.
    The value can be an integer (including underscores), a constant, or a
    parameter.  Ratios are restated to do rounding instead of truncation.\n
    Examples:
      123456
      123_456
      L_DIVISION_RATIO
      G_CLOCK_FREQUENCY_HZ/19200
      C_CLOCK_FREQUENCY_HZ/19200
      G_CLOCK_FREQUENCY_HZ/L_BAUD_RATE
      100_000_000/G_BAUD_RATE
    """
    def LocalIntMethod(self,config,value,position=None):
      try:
        if config.IsParameter(value):
          return value;
        else:
          v = self.IntMethod(config,value,lowLimit=1);
          return str(v);
      except SSBCCException, msg:
        if not position:
          raise SSBCCException(msg);
        else:
          raise SSBCCException('%s in %s' % (msg,position,));
    if value.find('/') < 0:
      return LocalIntMethod(self,config,value);
    else:
      ratearg = re.findall('([^/]+)',value);
      if len(ratearg) != 2:
        raise SSBCCException('Only one "/" allowed in expression');
      ratearg[0] = LocalIntMethod(self,config,ratearg[0],'numerator');
      ratearg[1] = LocalIntMethod(self,config,ratearg[1],'denominator');
      return '(%s+%s/2)/%s' % (ratearg[0],ratearg[1],ratearg[1],);

  def TimeMethod(self,config,value,lowLimit=None,highLimit=None):
    """
    Convert the provided time from the specified units to seconds.
    """
    if not re.match(r'(0|[1-9]\d*)(\.\d*)?(e[+-]?\d+)?[mun]?s$',value):
      raise SSBCCException('Malformed time value');
    if value[-2:] == 'ms':
      v = float(value[:-2]) * 1.e-3;
    elif value[-2:] == 'us':
      v = float(value[:-2]) * 1.e-6;
    elif value[-2:] == 'ns':
      v = float(value[:-2]) * 1.e-9;
    else:
      v = float(value[:-1]);
    if (lowLimit != None) and (v < lowLimit):
      raise SSBCCException('%s must be %s or greater' % (v,lowLimit,));
    if (highLimit != None) and (v > highLimit):
      raise SSBCCException('%s must be %s or smaller' % (v,highLimit,));
    return v;
