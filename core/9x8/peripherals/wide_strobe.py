################################################################################
#
# Copyright 2014, Sinclair R.F., Inc.
#
################################################################################

import re;

from ssbccPeripheral import SSBCCperipheral
from ssbccUtil import SSBCCException;

class wide_strobe(SSBCCperipheral):
  """
  Generate more than one simultaneous strobe.\n
  Usage:
    PERIPHERAL wide_strobe                      \\
                        outport=O_name          \\
                        outsignal=o_name        \\
                        width=<N>\n
  Where:
    outport=O_name
      specifies the symbol used to write to the output port
    outsignal=o_name
      specifies the name of the signal output from the module
    width=<N>
      specifies the width of the I/O
      Note:  N must be between 1 and 8 inclusive.\n
  Example:  Generate up to 4 simultaneous strobes.\n
    PORTCOMMENT 4 bit wide strobe
    PERIPHERAL wide_strobe                      \\
                        outport=O_4BIT_STROBE   \\
                        outsignal=o_4bit_strobe \\
                        width=4\n
    Send strobes on bits 1 and 3 of the wide strobe as follows:\n
      ${2**1|2**3} .outport(O_4BIT_STROBE)
  """

  def __init__(self,peripheralFile,config,param_list,loc):
    # Get the parameters.
    allowables = (
      ( 'outport',      r'O_\w+$',              None,   ),
      ( 'outsignal',    r'o_\w+$',              None,   ),
      ( 'width',        r'(9|[1-9]\d*)$',       int,    ),
    );
    names = [a[0] for a in allowables];
    for param_tuple in param_list:
      param = param_tuple[0];
      if param not in names:
        raise SSBCCException('Unrecognized parameter "%s" at %s' % (param,loc,));
      param_test = allowables[names.index(param)];
      self.AddAttr(config,param,param_tuple[1],param_test[1],loc,param_test[2]);
    # Ensure the required parameters are provided (all parameters are required).
    for paramname in names:
      if not hasattr(self,paramname):
        raise SSBCCException('Required parameter "%s" is missing at %s' % (paramname,loc,));
    # There are no optional parameters.
    # Add the I/O port, internal signals, and the INPORT and OUTPORT symbols for this peripheral.
    config.AddIO(self.outsignal,self.width,'output',loc);
    self.ix_outport = config.NOutports();
    config.AddOutport((self.outport,False,
                      # empty list
                      ),
                      loc);

  def GenVerilog(self,fp,config):
    body = """//
// PERIPHERAL wide_strobe:  @NAME@
//
initial @NAME@ = @WIDTH@'d0;
always @ (posedge i_clk)
  if (i_rst)
    @NAME@ <= @WIDTH@'d0;
  else if (s_outport && (s_T == @IX_OUTPORT@))
    @NAME@ <= s_N[0+:@WIDTH@];
  else
    @NAME@ <= @WIDTH@'d0;
"""
    for subpair in (
        ( r'@IX_OUTPORT@',      "8'd%d" % self.ix_outport,      ),
        ( r'@WIDTH@',           str(self.width),                ),
        ( r'@NAME@',            self.outsignal,                 ),
      ):
      body = re.sub(subpair[0],subpair[1],body);
    body = self.GenVerilogFinal(config,body);
    fp.write(body);
