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

class UART(SSBCCperipheral):
  """
  Transmit/receive UART:
    1 start bit
    8 data bits
    1 or 2 stop bits\n
  Usage:
    PERIPHERAL UART    inport=I_inport_name        \\
                       outport=O_outport_name      \\
                       inempty=I_inempty_name      \\
                       outstatus=I_outstatus_name  \\
                       baudmethod={clk/rate|count} \\
                       [insignal=i_name]           \\
                       [outsignal=o_name]          \\
                       [noSync|sync=n]             \\
                       [noDeglitch|deglitch=n]     \\
                       [noInFIFO|inFIFO=n]         \\
                       [noOutFIFO|outFIFO=n]       \\
                       [{CTS|CTSn}=i_cts_name]     \\
                       [{RTR|RTRn}=o_rtr_name]     \\
                       rtr_buffer=n                \\
                       [nStop={1|2}]\n
  Where:
    inport=I_inport_name
      specifies the symbol used by the inport instruction to read a received by
      from the peripheral
      Note:  The name must start with "I_".
    outport=O_outport_name
      specifies the symbol used by the outport instruction to write a byte to
      the peripheral
      Note:  The name must start with "O_".
    inempty=I_inempty_name
      specifies the symbol used by the inport instruction to get the empty
      status of the input side of the peripheral
      Note:  The name must start with "I_".
    outstatus=I_outstatus_name
      specifies the symbol used by the inport instruction to get the status of
      the output side of the peripheral
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
    outsignal=o_name
      optionally specifies the name of the output signal
      Default:  o_UART_Tx
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
    noOutFIFO
      optionally state that the peripheral will not have an output FIFO
      Note:  This is the default.
    outFIFO=n
      optionally add a FIFO of depth n to the output side of the UART
      Note:  n must be a power of 2.
    CTS=i_cts_name or CTSn=i_cts_name
      optionally specify an input handshake signal to control whether or not the
      peripheral transmits data
      Note:  If CTS is specified then the transmitter is active when i_cts_name
             is high.  If CTSn is specified then the transmitter is active when
             i_cts_name is low.
      Note:  The default, i.e., neither CTS nor CTSn is specified, is to always
             enable the transmitter.
      Note:  If there is no FIFO and the CTS/CTSn handshake indicates that the
             data flow is disabled, then the busy signal will be high and the
             processor code must not transmit the next byte.
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
      Note:  the peripheral does not accept 1.5 stop bits\n
  The following ports are provided by this peripheral:
    I_inport_name
      input a recieved byte from the peripheral
      Note:  If there is no input FIFO, then this is the last received byte.
             If there is an input FIFO, then this is the next byte in the FIFO.
      Note:  If there is an input FIFO and the read would cause a FIFO
             underflow, this will repeat the last received byte.
    O_outport_name
      output the next 8-bit value to transmit or to queue for transmission
      Note:  If there is no output FIFO or if there is an output FIFO and this
             write would cause a FIFO overflow, then this byte will be
             discarded.
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
    I_outstatus_name
      input the status of the output side of the peripheral
      bit 0:  output busy
        this bit will be high when the output side of the peripheral cannot
        accept more writes
        Note:  If there is no FIFO this means that the peripheral is still
               transmitting the last byte.  If there is an output FIFO it means
               that it is full.\n
        Note:  "Busy" is used rather that "ready" to facilitate loops that wait
               for a not-busy status to send the next byte.  See the examples below.\n
  WARNING:  The peripheral is very simple and does not protect against writing a
            new value in the middle of a transmition or writing to a full FIFO.
            Adding such logic would be contrary to the design principle of
            keeping the HDL small and relying on the assembly code to provide
            the protection.\n
  Example:  Configure the UART for 115200 baud using a 100 MHz clock and
            transmit the message "Hello World!"\n
    Within the processor architecture file include the configuration command:\n
    PERIPHERAL UART_Tx O_UART_TX I_UART_TX baudmethod=100_000_000/115200\n
    Use the following assembly code to transmit the message "Hello World!".
    This transmits the entire message whether or not the peripheral has a FIFO.\n
    N"Hello World!\\r\\n"
      :loop .outport(O_UART_TX) :wait .inport(I_UART_TX_BUSY) .jumpc(wait) .jumpc(loop,nop) drop
  """

  def __init__(self,peripheralFile,config,param_list,loc):
    # Use the externally provided file name for the peripheral
    self.peripheralFile = peripheralFile;
    # Get the parameters.
    allowables = (
      ( 'CTS',          r'i_\w+$',      None,           ),
      ( 'CTSn',         r'i_\w+$',      None,           ),
      ( 'RTR',          r'o_\w+$',      None,           ),
      ( 'RTRn',         r'o_\w+$',      None,           ),
      ( 'baudmethod',   r'\S+$',        lambda v : self.RateMethod(config,v), ),
      ( 'deglitch',     r'[1-9]\d*$',   int,            ),
      ( 'inFIFO',       r'[1-9]\d*$',   lambda v : self.IntPow2Method(config,v), ),
      ( 'inempty',      r'I_\w+$',      None,           ),
      ( 'inport',       r'I_\w+$',      None,           ),
      ( 'insignal',     r'i_\w+$',      None,           ),
      ( 'noDeglitch',   None,           None,           ),
      ( 'noInFIFO',     None,           None,           ),
      ( 'noOutFIFO',    None,           None,           ),
      ( 'noSync',       None,           None,           ),
      ( 'nStop',        r'[12]$',       int,            ),
      ( 'outFIFO',      r'[1-9]\d*$',   lambda v : self.IntPow2Method(config,v), ),
      ( 'outport',      r'O_\w+$',      None,           ),
      ( 'outsignal',    r'o_\w+$',      None,           ),
      ( 'outstatus',    r'I_\w+$',      None,           ),
      ( 'rtr_buffer',   r'[1-9]\d*$',   lambda v : self.IntPow2Method(config,v), ),
      ( 'sync',         r'[1-9]\d*$',   int,            ),
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
        'outport',
        'outstatus',
      ):
      if not hasattr(self,paramname):
        raise SSBCCException('Required parameter "%s" is missing at %s' % (paramname,loc,));
    # Set optional parameters.
    for optionalpair in (
        ( 'insignal',   'i_UART_Rx',    ),
        ( 'nStop',      1,              ),
        ( 'outsignal',  'o_UART_Tx',    ),
      ):
      if not hasattr(self,optionalpair[0]):
        setattr(self,optionalpair[0],optionalpair[1]);
    # Ensure the rtr_buffer, if specified, is consistent with the inFIFO
    # specification.
    if hasattr(self,'rtr_buffer'):
      if not hasattr(self,'inFIFO'):
        raise SSBCCException('rtr_buffer specification requires simultaneous inFIFO specification at %s' % loc);
      if self.rtr_buffer > self.inFIFO:
        raise SSBCCException('rtr_buffer=%d specification cannot exceed inFIFO=%d specification at %s' % (self.rtr_buffer,self.inFIFO,loc,));
    else:
      self.rtr_buffer = 1;
    # Ensure optional exclusive pair configurations are set and consistent.
    for exclusivepair in (
        ( 'CTS',        'CTSn',         None,           None,   ),
        ( 'RTR',        'RTRn',         None,           None,   ),
        ( 'noSync',     'sync',         'sync',         3,      ),
        ( 'noDeglitch', 'deglitch',     'noDeglitch',   True,   ),
        ( 'noInFIFO',   'inFIFO',       'noInFIFO',     True,   ),
        ( 'noOutFIFO',  'outFIFO',      'noOutFIFO',    True,   ),
      ):
      if hasattr(self,exclusivepair[0]) and hasattr(self,exclusivepair[1]):
        raise SSBCCException('Only one of "%s" and "%s" can be specified at %s' % (exclusivepair[0],exclusivepair[1],loc,));
      if not hasattr(self,exclusivepair[0]) and not hasattr(self,exclusivepair[1]) and exclusivepair[2]:
        setattr(self,exclusivepair[2],exclusivepair[3]);
    # Convert configurations to alternative format.
    for equivalent in (
        ( 'noDeglitch', 'deglitch',     0,      ),
        ( 'noInFIFO',   'inFIFO',       0,      ),
        ( 'noOutFIFO',  'outFIFO',      0,      ),
        ( 'noSync',     'sync',         0,      ),
      ):
      if hasattr(self,equivalent[0]):
        delattr(self,equivalent[0]);
        setattr(self,equivalent[1],equivalent[2]);
    # Set the string used to identify signals associated with this peripheral.
    self.namestring = self.outsignal;
    # Add the I/O port, internal signals, and the INPORT and OUTPORT symbols for this peripheral.
    for ioEntry in (
        ( 'insignal',   1,      'input',        ),
        ( 'outsignal',  1,      'output',       ),
        ( 'CTS',        1,      'input',        ),
        ( 'CTSn',       1,      'input',        ),
        ( 'RTR',        1,      'output',       ),
        ( 'RTRn',       1,      'output',       ),
      ):
      if hasattr(self,ioEntry[0]):
        config.AddIO(getattr(self,ioEntry[0]),ioEntry[1],ioEntry[2],loc);
    config.AddSignal('s__%s__Rx'                % self.namestring,8,loc);
    config.AddSignal('s__%s__Rx_empty'          % self.namestring,1,loc);
    config.AddSignal('s__%s__Rx_rd'             % self.namestring,1,loc);
    config.AddSignalWithInit('s__%s__Tx'        % self.namestring,8,None,loc);
    config.AddSignal('s__%s__Tx_busy'           % self.namestring,1,loc);
    config.AddSignalWithInit('s__%s__Tx_wr'     % self.namestring,1,None,loc);
    config.AddInport((self.inport,
                    ('s__%s__Rx'                % self.namestring,8,'data',),
                    ('s__%s__Rx_rd'             % self.namestring,1,'strobe',),
                   ),loc);
    config.AddInport((self.inempty,
                   ('s__%s__Rx_empty'           % self.namestring,1,'data',),
                  ),loc);
    config.AddOutport((self.outport,False,
                   ('s__%s__Tx'                 % self.namestring,8,'data',),
                   ('s__%s__Tx_wr'              % self.namestring,1,'strobe',),
                  ),loc);
    config.AddInport((self.outstatus,
                   ('s__%s__Tx_busy'            % self.namestring,1,'data',),
                 ),loc);
    # Add the 'clog2' function to the processor (if required).
    config.functions['clog2'] = True;

  def GenVerilog(self,fp,config):
    for bodyextension in ('_Rx.v','_Tx.v',):
      body = self.LoadCore(self.peripheralFile,bodyextension);
      if hasattr(self,'RTR') or hasattr(self,'RTRn'):
        body = re.sub(r'@RTR_BEGIN@\n','',body);
        body = re.sub(r'@RTR_END@\n','',body);
      else:
        if re.search(r'@RTR_BEGIN@',body):
          body = re.sub(r'@RTR_BEGIN@.*?@RTR_END@\n','',body,flags=re.DOTALL);
      for subpair in (
          ( r'@RTR_SIGNAL@',            self.RTR if hasattr(self,'RTR') else self.RTRn if hasattr(self,'RTRn') else '', ),
          ( r'@RTRN_INVERT@',           '!' if hasattr(self,'RTR') else '', ),
          ( r'\bL__',                   'L__@NAME@__',          ),
          ( r'\bgen__',                 'gen__@NAME@__',        ),
          ( r'\bs__',                   's__@NAME@__',          ),
          ( r'@INPORT@',                self.insignal,          ),
          ( r'@BAUDMETHOD@',            str(self.baudmethod),   ),
          ( r'@SYNC@',                  str(self.sync),         ),
          ( r'@DEGLITCH@',              str(self.deglitch),     ),
          ( r'@INFIFO@',                str(self.inFIFO),       ),
          ( r'@ENABLED@',               self.CTS if hasattr(self,'CTS') else ('!%s' % self.CTSn) if hasattr(self,'CTSn') else '1\'b1', ),
          ( r'@NSTOP@',                 str(self.nStop),        ),
          ( r'@OUTFIFO@',               str(self.outFIFO),      ),
          ( r'@NAME@',                  self.namestring,        ),
          ( r'@RTR_FIFO_COMPARE@',      str(CeilLog2(self.rtr_buffer)), ),
        ):
        if re.search(subpair[0],body):
          body = re.sub(subpair[0],subpair[1],body);
      body = self.GenVerilogFinal(config,body);
      fp.write(body);
