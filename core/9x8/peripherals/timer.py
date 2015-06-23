################################################################################
#
# Copyright 2013-2014, Sinclair R.F., Inc.
#
################################################################################

import re;

from ssbccPeripheral import SSBCCperipheral
from ssbccUtil import SSBCCException;

class timer(SSBCCperipheral):
  """
  Simple timer to facilitate polled-loops.\n
  The timer sets a flag when the timer expires and clears the flag when it is
  read.\n
  Usage:
    PERIPHERAL timer inport=I_name \\
                     ratemethod={clk/rate|count}\n
  Where:
    inport=I_name
      specifies the symbol used by the inport instruction to get the
      unexpired/expired status of the timer
      Note:  The name must start with "I_"
    ratemethod
      specifies the method to generate the desired timer event rate:
      1st method:  clk/rate
        clk is the frequency of "i_clk" in Hz
          a number will be interpreted as the clock frequency in Hz
          a symbol will be interpreted as a constant or a parameter
            Note:  the symbol must be declared with the CONSTANT, LOCALPARARM,
                   or PARAMETER configuration command.
        rate is the desired baud rate
          this is specified as per "clk"
      2nd method:
        specify the number of "i_clk" clock cycles between timer events
      Note:  clk, rate, and count can be parameters or constants.  For example,
             the following uses the parameter G_CLK_FREQ_HZ for the clock
             frequency and a hard-wired event rate of 1 kHz
             "baudmethod=G_CLK_FREQ_HZ/1000".
      Note:  The numeric values can have Verilog-style '_' separators between
               the digits.  For example, 100_000_000 represents 100 million.\n
  Example:  Configure the timer for 1000 kHz events and monitor for these events
            in the micro controller code.\n
            PARAMETER G_CLK_FREQ_HZ 100_000_000
            PERIPHERAL timer inport=I_TIMER ratemethod=G_CLK_FREQ_HZ/1000\n
            ; See if the timer has expired since the last time it was polled and
            ; conditionally call "timer_event" if it has.
            .inport(I_TIMER)
              .callc(timer_event)
  """

  def __init__(self,peripheralFile,config,param_list,loc):
    # Use the externally provided file name for the peripheral
    self.peripheralFile = peripheralFile;
    # Get the parameters.
    allowables = (
      ('inport',        r'I_\w+$',      None,   ),
      ('ratemethod',    r'\S+$',        lambda v : self.RateMethod(config,v), ),
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
    name = 's__%s__expired' % self.inport;
    config.AddSignal(name, 1, loc);
    config.AddSignal('s_SETRESET_%s' % name,1,loc);
    config.AddInport((self.inport,
                     ('s__%s__expired' % self.inport, 1, 'set-reset'),
                    ),loc);
    # Add the 'clog2' function to the processor (if required).
    config.functions['clog2'] = True;

  def GenVerilog(self,fp,config):
    body = self.LoadCore(self.peripheralFile,'.v');
    for subs in (
        ( r'\bL__',             'L__@NAME@__',          ),
        ( r'\bs__',             's__@NAME@__',          ),
        ( r'@RATEMETHOD@',      str(self.ratemethod),   ),
        ( r'@NAME@',            self.inport,            ),
      ) :
      body = re.sub(subs[0],subs[1],body);
    body = self.GenVerilogFinal(config,body);
    fp.write(body);
