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

class inFIFO_async(SSBCCperipheral):
  """
  Input FIFO with an asynchronous clock.\n
  Usage:
    PERIPHERAL inFIFO_async     inclk=<i_clock>         \\
                                data=<i_data>           \\
                                data_wr=<i_data_wr>     \\
                                data_full=<o_data_full> \\
                                inport=<I_data>         \\
                                inempty=<I_empty>       \\
                                depth=<N>               \n
  Where:
    inclk=<i_clock>
      specifies the name of the asynchronous clock
    data=<i_data>
      specifies the name of the 8-bit incoming data
    data_wr=<i_data_wr>
      specifies the name if the write strobe
    data_full=<o_data_full>
      specifies the name of the output "full" status of the FIFO
    inport=<I_data>
      specifies the name of the port to read from the FIFO
    inempty=<I_empty>
      specifies the symbol used by the inport instruction to read the "empty"
      status of the FIFO
    depth=<N>
      specifies the depth of the FIFO
      Note:  N must be a power of 2 and must be at least 16.\n
  Example:  Provide a FIFO for an external device or IP that pushes 8-bit data
    to the processor.\n
    The PERIPHERAL statement would be:\n
      PERIPHERAL inFIFO_async   inclk=i_dev_clk           \\
                                data=i_dev_data           \\
                                data_wr=i_dev_data_wr     \\
                                data_full=o_dev_full      \\
                                inport=I_DATA_FIFO        \\
                                inempty=I_DATA_FIFO_EMPTY \\
                                depth=32\n
    To read from the FIFO and store the values on the data stack until the FIFO
    is empty and to track the number of values received, do the following:\n
      ; ( - u_first ... u_last u_N )
      0x00 :loop
        .inport(I_DATA_FIFO_EMPTY) .jumpc(done)
        .inport(I_DATA_FIFO) swap
        .jump(loop,1+)
      :done
  """

  def __init__(self,peripheralFile,config,param_list,loc):
    # Use the externally provided file name for the peripheral
    self.peripheralFile = peripheralFile;
    # Get the parameters.
    allowables = (
      ( 'inclk',        r'i_\w+$',      None,   ),
      ( 'data',         r'i_\w+$',      None,   ),
      ( 'data_wr',      r'i_\w+$',      None,   ),
      ( 'data_full',    r'o_\w+$',      None,   ),
      ( 'inport',       r'I_\w+$',      None,   ),
      ( 'inempty',      r'I_\w+$',      None,   ),
      ( 'depth',        r'[1-9]\d*$',   lambda v : self.IntPow2Method(config,v,lowLimit=16), ),
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
    config.AddIO(self.inclk,1,'input',loc);
    config.AddIO(self.data,8,'input',loc);
    config.AddIO(self.data_wr,1,'input',loc);
    config.AddIO(self.data_full,1,'output',loc);
    config.AddSignal('s__%s__data' % self.data,8,loc);
    config.AddSignal('s__%s__empty' % self.data,1,loc);
    self.ix_data = config.NInports();
    config.AddInport((self.inport,
                     ('s__%s__data' % self.data,8,'data',),
                    ),loc);
    config.AddInport((self.inempty,
                     ('s__%s__empty' % self.data,1,'data',),
                    ),loc);

  def GenVerilog(self,fp,config):
    body = self.LoadCore(self.peripheralFile,'.v');
    for subpair in (
        ( r'@DATA@',            self.data,                      ),
        ( r'@DATA_FULL@',       self.data_full,                 ),
        ( r'@DATA_WR@',         self.data_wr,                   ),
        ( r'@DEPTH@',           str(self.depth),                ),
        ( r'@DEPTH-1@',         str(self.depth-1),              ),
        ( r'@DEPTH_NBITS@',     str(CeilLog2(self.depth)),      ),
        ( r'@DEPTH_NBITS-1@',   str(CeilLog2(self.depth)-1),    ),
        ( r'@INCLK@',           self.inclk,                     ),
        ( r'@IX_DATA@',         str(self.ix_data),              ),
        ( r'@NAME@',            self.data,                      ),
        ( r'\bgen__',           'gen__%s__' % self.data,        ),
        ( r'\bix__',            'ix__%s__' % self.data,         ),
        ( r'\bs__',             's__%s__' % self.data,          ),
      ):
      body = re.sub(subpair[0],subpair[1],body);
    body = self.GenVerilogFinal(config,body);
    fp.write(body);
