################################################################################
#
# Copyright 2013-2014, Sinclair R.F., Inc.
#
################################################################################

import re;

from ssbccPeripheral import SSBCCperipheral
from ssbccUtil import SSBCCException;

class big_outport(SSBCCperipheral):
  """
  Shift two or more writes to a single OUTPORT to construct a wide output
  signal.\n
  Usage:
    PERIPHERAL big_outport                      \\
                        outport=O_name          \\
                        outsignal=o_name        \\
                        width=<N>\n
  Where:
    outport=O_name
      specifies the symbol used to write to the output port
    outsignal=o_name
      specifies the name of the signal output from the module
    width=<N>
      specifies the width of the I/O\n
  Example:  Create a 26-bit output signal for output of 26-bit or 18-bit values
  from the processor to external IP.\n
    PORTCOMMENT 26-bit output for use by other modules
    PERIPHERAL big_outport                             \\
                        output=O_26BIT_SIGNAL          \\
                        outsignal=o_26bit_signal       \\
                        width=26
    OUTPORT     strobe  o_wr_26bit      O_WR_26BIT
    OUTPORT     strobe  o_wr_18bit      O_WR_18BIT\n
  Writing a 26-bit value requires 4 successive outports to O_26BIT_SIGNAL,
  starting with the MSB as follows:\n
    ; Write 0x024a_5b6c to the XXX module
    0x02 .outport(O_26BIT_SIGNAL)
    0x4a .outport(O_26BIT_SIGNAL)
    0x5b .outport(O_26BIT_SIGNAL)
    0x6c .outport(O_26BIT_SIGNAL)
    .outstrobe(O_WR_26BIT)\n
  Writing an 18-bit value requires 3 successive outports to O_26BIT_SIGNAL
  starting with the MSB as illustrated by the following function:\n
    ; Read the 18-bit value from memory and then write it to a peripheral.
    ; Note:  The multi-byte value is stored MSB first in memory.
    ; ( u_addr - )
    .function write_18bit_from_memory
      ${3-1} :loop r>
        .fetch+(ram) .outport(O_26BIT_SIGNAL)
      >r .jumpc(loop,1-) drop
      .outstrobe(O_WR_18BIT)
      .return(drop)
  """

  def __init__(self,peripheralFile,config,param_list,loc):
    # Get the parameters.
    allowables = (
      ( 'outport',      r'O_\w+$',              None,   ),
      ( 'outsignal',    r'o_\w+$',              None,   ),
      ( 'width',        r'(9|[1-9]\d+)$',       int,    ),
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
// PERIPHERAL big_outport:  @NAME@
//
initial @NAME@ = @WIDTH@'d0;
always @ (posedge i_clk)
  if (i_rst)
    @NAME@ <= @WIDTH@'d0;
  else if (s_outport && (s_T == @IX_OUTPORT@))
    @NAME@ <= { @NAME@[@WIDTH-9:0@], s_N };
  else
    @NAME@ <= @NAME@;
"""
    for subpair in (
        ( r'@IX_OUTPORT@',      "8'd%d" % self.ix_outport,                              ),
        ( r'@WIDTH@',           str(self.width),                                        ),
        ( r'@WIDTH-9:0@',       '%d:0' % (self.width-9) if self.width > 9 else '0'      ),
        ( r'@NAME@',            self.outsignal,                                         ),
      ):
      body = re.sub(subpair[0],subpair[1],body);
    body = self.GenVerilogFinal(config,body);
    fp.write(body);
