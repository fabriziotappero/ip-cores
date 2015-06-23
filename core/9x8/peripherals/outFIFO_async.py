################################################################################
#
# Copyright 2013-2014, Sinclair R.F., Inc.
#
################################################################################

import math;
import re;

from ssbccPeripheral import SSBCCperipheral
from ssbccUtil import CeilLog2;
from ssbccUtil import IsPowerOf2;
from ssbccUtil import SSBCCException;

class outFIFO_async(SSBCCperipheral):
  """
  Output FIFO with an asynchronous clock.\n
  Usage:
    PERIPHERAL outFIFO_async    outclk=<i_clock>                \\
                                data=<o_data>                   \\
                                data_rd=<i_data_rd>             \\
                                data_empty=<o_data_empty>       \\
                                outport=<O_data>                \\
                                infull=<I_full>                 \\
                                depth=<N>                       \n
  Where:
    outclk=<i_clock>
      specifies the name of the asynchronous read clock
    data=<o_data>
      specifies the name of the 8-bit outgoing data
    data_rd=<i_data_rd>
      specifies the name if the read strobe
    data_empty=<o_data_empty>
      specifies the name of the output "empty" status of the FIFO
    outport=<O_data>
      specifies the name of the port to write to the FIFO
    infull=<I_full>
      specifies the symbol used by the inport instruction to read the "full"
      status of the FIFO
    depth=<N>
      specifies the depth of the FIFO
      Note:  N must be a power of 2 and must be at least 16.\n
  Example:  Provide a FIFO to an external device or IP.\n
    The PERIPHERAL statement would be:\n
      PERIPHERAL outFIFO_async  outclk=i_dev_clk          \\
                                data=o_dev_data           \\
                                data_rd=i_dev_data_rd     \\
                                data_empty=o_dev_empty    \\
                                outport=O_DATA_FIFO       \\
                                infull=I_DATA_FIFO_FULL   \\
                                depth=32\n
    To put a text message in the FIFO, similarly to a UART, do the following:\n
      N"message"
      :loop
        .inport(I_DATA_FIFO_FULL) .jumpc(loop)
        .outport(O_DATA_FIFO)
        .jumpc(loop,nop)
  """

  def __init__(self,peripheralFile,config,param_list,loc):
    # Use the externally provided file name for the peripheral
    self.peripheralFile = peripheralFile;
    # Get the parameters.
    allowables = (
      ('outclk',        r'i_\w+$',      None,   ),
      ('data',          r'o_\w+$',      None,   ),
      ('data_rd',       r'i_\w+$',      None,   ),
      ('data_empty',    r'o_\w+$',      None,   ),
      ('outport',       r'O_\w+$',      None,   ),
      ('infull',        r'I_\w+$',      None,   ),
      ('depth',         r'[1-9]\d*$',   lambda v : self.IntPow2Method(config,v,lowLimit=16),    ),
    );
    names = [a[0] for a in allowables];
    for param_tuple in param_list:
      param = param_tuple[0];
      if param not in names:
        raise SSBCCException('Unrecognized parameter "%s" at %s' % (param,loc,));
      param_test = allowables[names.index(param)];
      self.AddAttr(config,param,param_tuple[1],param_test[1],loc,param_test[2]);
    # Ensure the required parameters are provided.
    for paramname in names:
      if not hasattr(self,paramname):
        raise SSBCCException('Required parameter "%s" is missing at %s' % (paramname,loc,));
    # Add the I/O port, internal signals, and the INPORT and OUTPORT symbols for this peripheral.
    config.AddIO(self.outclk,1,'input',loc);
    config.AddIO(self.data,8,'output',loc);
    config.AddIO(self.data_rd,1,'input',loc);
    config.AddIO(self.data_empty,1,'output',loc);
    config.AddSignal('s__%s__full' % self.data,1,loc);
    self.ix_outport = config.NOutports();
    config.AddOutport((self.outport,False,
                      # empty list
                      ),loc);
    config.AddInport((self.infull,
                     ('s__%s__full' % self.data,1,'data',),
                    ),loc);

  def GenVerilog(self,fp,config):
    body = self.LoadCore(self.peripheralFile,'.v');
    for subpair in (
        ( r'@DATA@',            self.data,                      ),
        ( r'@DATA_EMPTY@',      self.data_empty,                ),
        ( r'@DATA_RD@',         self.data_rd,                   ),
        ( r'@DEPTH@',           str(self.depth),                ),
        ( r'@DEPTH-1@',         str(self.depth-1),              ),
        ( r'@DEPTH_NBITS@',     str(CeilLog2(self.depth)),      ),
        ( r'@DEPTH_NBITS-1@',   str(CeilLog2(self.depth)-1),    ),
        ( r'@OUTCLK@',          self.outclk,                    ),
        ( r'@IX_OUTPORT@',      str(self.ix_outport),           ),
        ( r'@NAME@',            self.data,                      ),
        ( r'\bgen__',           'gen__%s__' % self.data,        ),
        ( r'\bix__',            'ix__%s__' % self.data,         ),
        ( r'\bs__',             's__%s__' % self.data,          ),
      ):
      body = re.sub(subpair[0],subpair[1],body);
    body = self.GenVerilogFinal(config,body);
    fp.write(body);
