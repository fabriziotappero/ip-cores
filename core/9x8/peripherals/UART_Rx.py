################################################################################
#
# Copyright 2013-2015, Sinclair R.F., Inc.
#
################################################################################

import math;
import re;

from ssbccPeripheral import SSBCCperipheral
from ssbccUtil import CeilLog2
from ssbccUtil import SSBCCException

class UART_Rx(SSBCCperipheral):
  """
  Receive UART:
    1 start bit
    8 data bits
    1 or 2 stop bits\n
  Usage:
    PERIPHERAL UART_Rx inport=I_inport_name        \\
                       inempty=I_inempty_name      \\
                       baudmethod={clk/rate|count} \\
                       [insignal=i_name]           \\
                       [noSync|sync=n]             \\
                       [noDeglitch|deglitch=n]     \\
                       [noInFIFO|inFIFO=n]         \\
                       [{RTR|RTRn}=o_rtr_name]     \\
                       rtr_buffer=n                \\
                       [nStop={1|2}]               \n
  Where:
    inport=I_inport_name
      specifies the symbol used by the inport instruction to read a received by
      from the peripheral
      Note:  The name must start with "I_".
    inempty=I_inempty_name
      specifies the symbol used by the inport instruction to get the empty
      status of the input side of the peripheral
      Note:  The name must start with "I_".
    baudmethod
      specifies the method to generate the desired bit rate:
      1st method:  clk/rate
        clk is the frequency of "i_clk" in Hz
          a number will be interpreted as the clock frequency in Hz
          a symbol will be interpreted as a constant or a parameter
            Note:  the symbol must be declared with the CONSTANT, LOCALPARARM,
                   or PARAMETER configuration command.
        rate is the desired baud rate
          this is specified as per "clk"
      2nd method:
        specify the number of "i_clk" clock cycles between bit edges
      Note:  clk, rate, and count can be parameters or constants.  For example,
             the following uses the parameter G_CLK_FREQ_HZ for the clock
             frequency and a hard-wired baud rate of 9600:
             "baudmethod=G_CLK_FREQ_HZ/9600".
      Note:  The numeric values can have Verilog-style '_' separators between
             the digits.  For example, 100_000_000 represents 100 million.
    insignal=i_name
      optionally specifies the name of the single-bit transmit signal
      Default:  i_UART_Rx
    noSync
      optionally state no synchronization or registration is performed on the
      input signal.
    sync=n
      optionally state that an n-bit synchronizer will be performed on the
      input signal.
      Note:  sync=3 is the default.
    noDeglitch
      optionally state that no deglitching is performed on the input signal.
      Note:  This is the default.
    deglitching=n
      optionally state that an n-bit deglitcher is performed on the input signal
      Note:  Deglitching consists of changing the output state when n
             successive input bits are in the opposite state.
    noInFIFO
      optionally state that the peripheral will not have an input FIFO
      Note:  This is the default.
    inFIFO=n
      optionally add a FIFO of depth n to the input side of the UART
      Note:  n must be a power of 2.
    RTR=o_rtr_name or RTRn=o_rtr_name
      optionally specify an output handshake signal to indicate that the
      peripheral is ready to receive data
      Note:  If RTR is specified then the receiver indicates it is ready when
             o_rtr_name is high.  If RTRn is specified then the transmitter
             indicates it is ready when o_rtr_name is low.
      Note:  The default, i.e., neither CTS nor CTSn is specified, is to always
             enable the receiver.
      Note:  If there is no FIFO and the RTR/RTRn handshake indicates that the
             receiver is not ready as soon as it starts receiving data and
             until that data is read from the peripheral.
      Default:  1
    rtr_buffer=n
      optionally specify the number of entries in inFIFO to reserve for data
      received after the RTR/RTRn signal indicates to stop data flow.
      Note:  n must be a power of 2.
      Note:  This requires that inFIFO be specified.
      Note:  Some USB UARTs  will transmit several characters after the RTR/RTRn
             signal indicates to stop the data flow.
    nStop=n
      optionally configure the peripheral for n stop bits
      default:  1 stop bit
      Note:  n must be 1 or 2
      Note:  the peripheral does not accept 1.5 stop bits
  The following ports are provided by this peripheral:
    I_inport_name
      input a recieved byte from the peripheral
      Note:  If there is no input FIFO, then this is the last received byte.
             If there is an input FIFO, then this is the next byte in the FIFO.
      Note:  If there is an input FIFO and the read would cause a FIFO
             underflow, this will repeat the last received byte.
    I_inempty_name
      input the empty status of the input side of the peripheral
      bit 0:  input empty
        this bit will be high when the input side of the peripheral has one or
        more bytes read to be read
        Note:  If there is no FIFO this means that a single byte is ready to be
               read and has not been read.  If there is an input FIFO this
               means that there are one or more bytes in the FIFO.
        Note:  "Empty" is used rather than "ready" to facilitate loops that
               respond when there is a new byte ready to be processed.  See the
               examples below.
  """

  def __init__(self,peripheralFile,config,param_list,loc):
    # Use the externally provided file name for the peripheral
    self.peripheralFile = peripheralFile;
    # Get the parameters.
    allowables = (
      ( 'RTR',          r'o_\w+$',      None,   ),
      ( 'RTRn',         r'o_\w+$',      None,   ),
      ( 'baudmethod',   r'\S+$',        lambda v : self.RateMethod(config,v), ),
      ( 'deglitch',     r'[1-9]\d*$',   int,    ),
      ( 'inFIFO',       r'[1-9]\d*$',   lambda v : self.IntPow2Method(config,v), ),
      ( 'inempty',      r'I_\w+$',      None,   ),
      ( 'inport',       r'I_\w+$',      None,   ),
      ( 'insignal',     r'i_\w+$',      None,   ),
      ( 'noDeglitch',   None,           None,   ),
      ( 'noInFIFO',     None,           None,   ),
      ( 'noSync',       None,           None,   ),
      ( 'nStop',        r'[12]$',       int,    ),
      ( 'rtr_buffer',   r'[1-9]\d*$',   lambda v : self.IntPow2Method(config,v), ),
      ( 'sync',         r'[1-9]\d*$',   int,    ),
    );
    names = [a[0] for a in allowables];
    for param_tuple in param_list:
      param = param_tuple[0];
      if param not in names:
        raise SSBCCException('Unrecognized parameter "%s" at %s' % (param,loc,));
      param_test = allowables[names.index(param)];
      self.AddAttr(config,param,param_tuple[1],param_test[1],loc,param_test[2]);
    # Ensure the required parameters are provided.
    for paramname in (
        'baudmethod',
        'inempty',
        'inport',
      ):
      if not hasattr(self,paramname):
        raise SSBCCException('Required parameter "%s" is missing at %s' % (paramname,loc,));
    # Set optional parameters.
    for optionalpair in (
        ( 'insignal',   'i_UART_Rx',    ),
        ( 'nStop',      1,              ),
      ):
      if not hasattr(self,optionalpair[0]):
        setattr(self,optionalpair[0],optionalpair[1]);
    # Ensure the rtr_buffer, if specified, is consistent with the inFIFO
    # specification.
    if hasattr(self,'rtr_buffer'):
      if not hasattr(self,'inFIFO'):
        raise SSBCCException('rtr_buffer specification requires simultaneous inFIFO specification at %s' % loc);
      if not self.rtr_buffer < self.inFIFO:
        raise SSBCCException('rtr_buffer=%d specification must be less than the inFIFO=%d specification at %s' % (self.rtr_buffer,self.inFIFO,loc,));
    else:
      self.rtr_buffer = 1;
    # Ensure exclusive pair configurations are set and consistent.
    for exclusivepair in (
        ( 'RTR',        'RTRn',         None,           None,   ),
        ( 'noSync',     'sync',         'sync',         3,      ),
        ( 'noDeglitch', 'deglitch',     'noDeglitch',   True,   ),
        ( 'noInFIFO',   'inFIFO',       'noInFIFO',     True,   ),
      ):
      if hasattr(self,exclusivepair[0]) and hasattr(self,exclusivepair[1]):
        raise SSBCCException('Only one of "%s" and "%s" can be specified at %s' % (exclusivepair[0],exclusivepair[1],loc,));
      if not hasattr(self,exclusivepair[0]) and not hasattr(self,exclusivepair[1]) and exclusivepair[2]:
        setattr(self,exclusivepair[2],exclusivepair[3]);
    # Convert configurations to alternate format.
    for equivalent in (
        ( 'noDeglitch', 'deglitch',     0,      ),
        ( 'noInFIFO',   'inFIFO',       0,      ),
        ( 'noSync',     'sync',         0,      ),
      ):
      if hasattr(self,equivalent[0]):
        delattr(self,equivalent[0]);
        setattr(self,equivalent[1],equivalent[2]);
    # Set the value used to identify signals associated with this peripheral.
    self.namestring = self.insignal;
    # Add the I/O port, internal signals, and the INPORT and OUTPORT symbols for this peripheral.
    for ioEntry in (
        ( 'insignal',   1,      'input',        ),
        ( 'RTR',        1,      'output',       ),
        ( 'RTRn',       1,      'output',       ),
      ):
      if hasattr(self,ioEntry[0]):
        config.AddIO(getattr(self,ioEntry[0]),ioEntry[1],ioEntry[2],loc);
    config.AddSignal('s__%s__Rx'          % self.namestring,8,loc);
    config.AddSignal('s__%s__Rx_empty'    % self.namestring,1,loc);
    config.AddSignal('s__%s__Rx_rd'       % self.namestring,1,loc);
    config.AddInport((self.inport,
                    ('s__%s__Rx'          % self.namestring,8,'data',),
                    ('s__%s__Rx_rd'       % self.namestring,1,'strobe',),
                   ),loc);
    config.AddInport((self.inempty,
                    ('s__%s__Rx_empty'     % self.namestring,1,'data',),
                   ),loc);
    # Add the 'clog2' function to the processor (if required).
    config.functions['clog2'] = True;

  def GenVerilog(self,fp,config):
    for bodyextension in ('.v',):
      body = self.LoadCore(self.peripheralFile,bodyextension);
      if hasattr(self,'RTR') or hasattr(self,'RTRn'):
        body = re.sub(r'@RTR_BEGIN@\n','',body);
        body = re.sub(r'@RTR_END@\n','',body);
      else:
        body = re.sub(r'@RTR_BEGIN@.*?@RTR_END@\n','',body,flags=re.DOTALL);
      for subpair in (
          ( r'@RTR_SIGNAL@',    self.RTR if hasattr(self,'RTR') else self.RTRn if hasattr(self,'RTRn') else '', ),
          ( r'@RTRN_INVERT@',           '!' if hasattr(self,'RTR') else '', ),
          ( r'\bL__',                   'L__@NAME@__',          ),
          ( r'\bgen__',                 'gen__@NAME@__',        ),
          ( r'\bs__',                   's__@NAME@__',          ),
          ( r'@INPORT@',                self.insignal,          ),
          ( r'@BAUDMETHOD@',            str(self.baudmethod),   ),
          ( r'@SYNC@',                  str(self.sync),         ),
          ( r'@DEGLITCH@',              str(self.deglitch),     ),
          ( r'@INFIFO@',                str(self.inFIFO),       ),
          ( r'@NSTOP@',                 str(self.nStop),        ),
          ( r'@NAME@',                  self.namestring,        ),
          ( r'@RTR_FIFO_COMPARE@',      str(CeilLog2(self.rtr_buffer)), ),
        ):
        if re.search(subpair[0],body):
          body = re.sub(subpair[0],subpair[1],body);
      body = self.GenVerilogFinal(config,body);
      fp.write(body);
