################################################################################
#
# Copyright 2013-2014, Sinclair R.F., Inc.
#
################################################################################

import re;

from ssbccPeripheral import SSBCCperipheral
from ssbccUtil import SSBCCException;

class big_inport(SSBCCperipheral):
  """
  Shift two or more writes to a single OUTPORT to construct a wide output
  signal.\n
  Usage:
    PERIPHERAL big_inport                       \\
                        outlatch=O_name         \\
                        inport=I_name           \\
                        insignal=i_name         \\
                        width=<N>\n
  Where:
    outlatch=O_name
      specifies the symbol used to latch the incoming value
    inport=I_name
      specifies the symbol used to read from the output port
    insignal=i_name
      specifies the name of the signal input to the module
    width=<N>
      specifies the width of the I/O register\n
  Example:  Create a 23-bit input signal to receive an external (synchronous)
  counter.\n
    PORTCOMMENT 23-bit counter
    PERIPHERAL big_inport                               \\
                        outlatch=O_LATCH_COUNTER        \\
                        inport=I_COUNTER                \\
                        insignal=i_counter              \\
                        width=23\n
  Reading the counter requires issuing a command to latch the current value and
  then 3 reads to the I/O port as follows:\n
    ; Latch the external counter.
    .outstrobe(O_LATCH_COUNTER)
    ; Read the 3-byte value of the count
    ; ( - u_LSB u u_MSB )
    .inport(I_COUNTER)
    .inport(I_COUNTER)
    .inport(I_COUNTER)
  """

  def __init__(self,peripheralFile,config,param_list,loc):
    # Get the parameters.
    allowables = (
      ( 'outlatch',     r'O_\w+$',              None,   ),
      ( 'inport',       r'I_\w+$',              None,   ),
      ( 'insignal',     r'i_\w+$',              None,   ),
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
    config.AddIO(self.insignal,self.width,'input',loc);
    config.AddSignal('s__%s__inport' % self.insignal, self.width, loc);
    self.ix_latch = config.NOutports();
    config.AddOutport((self.outlatch,True,
                      # empty list
                      ),loc);
    self.ix_inport = config.NInports();
    config.AddInport((self.inport,
                      ('s__%s__inport' % self.insignal, self.width, 'data', ),
                      ),loc);

  def GenVerilog(self,fp,config):
    body = """//
// PERIPHERAL big_inport:  @INSIGNAL@
//
always @ (posedge i_clk)
  if (i_rst)
    @NAME@ <= @WIDTH@'d0;
  else if (s_outport && (s_T == @IX_LATCH@))
    @NAME@ <= @INSIGNAL@;
  else if (s_inport && (s_T == @IX_INPORT@))
    @NAME@ <= { 8'd0, @NAME@[@WIDTH-1:8@] };
  else
    @NAME@ <= @NAME@;
"""
    for subpair in (
        ( r'@IX_LATCH@',        "8'd%d" % self.ix_latch,                                ),
        ( r'@IX_INPORT@',       "8'd%d" % self.ix_inport,                               ),
        ( r'@WIDTH@',           str(self.width),                                        ),
        ( r'@WIDTH-1:8@',       '%d:8' % (self.width-1) if self.width > 9 else '8'      ),
        ( r'@NAME@',            's__@INSIGNAL@__inport',                                ),
        ( r'@INSIGNAL@',        self.insignal,                                          ),
      ):
      body = re.sub(subpair[0],subpair[1],body);
    body = self.GenVerilogFinal(config,body);
    fp.write(body);
