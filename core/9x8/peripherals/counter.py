################################################################################
#
# Copyright 2013-2014, Sinclair R.F., Inc.
#
################################################################################

import re;

from ssbccPeripheral import SSBCCperipheral
from ssbccUtil import SSBCCException;

class counter(SSBCCperipheral):
  """
  Count received strobes.\n
  Usage:
    PERIPHERAL counter \\
                        insignal=i_name \\
                        inport=I_NAME \\
                        [width=<N> outlatch=O_NAME]\n
  Where:
    insignal=i_name
      specifies the name of the signal input to the micro controller
    input=I_NAME
      specifies the symbol use to read the count
    width=<N>
      optionally specifies the width of the counter
      Note:  The default is 8 bits.
      Note:  If the width is more than 8 bits then the optional outlatch needs
             to be provided.  This is strobe outport is used to latch the value
             of the counter so that it can be input from its LSB to its MSB.\n
  Note:  The counter is not cleared when it is read.  Software must maintain the
         previous value of the count if delta-counts are required.\n
  Example:  Create an 8-bit count for the number of strobe events received.\n
    PORTCOMMENT external strobe (input to 8-bit counter)
    PERIPHERAL counter \\
                        insignal=i_strobe \\
                        inport=I_STROBE_COUNT\n
  Read the count:\n
    .inport(I_STROBE_COUNT)\n
  Example:  Create a 12-bit count for the number of strobe events received.\n
    PORTCOMMENT external strobe (input to 12-bit counter)
    PERIPHERAL counter \\
                        insignal=i_strobe \\
                        inport=I_STROBE_COUNT \\
                        width=12 \\
                        outlatch=O_LATCH_STROBE_COUNT\n
  Read the count:
    ; latch the count
    .outstrobe(O_LATCH_STROBE_COUNT)
    ; read the count LSB first
    ; ( - u_LSB u_MSB )
    .inport(I_STROBE_COUNT) .inport(I_STROBE_COUNT)
  """

  def __init__(self,peripheralFile,config,param_list,loc):
    # Use the externally provided file name for the peripheral
    self.peripheralFile = peripheralFile;
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
    # Ensure the optional width is set.
    if not hasattr(self,'width'):
      self.width=8;
    # Ensure the required parameters are provided.
    required = ['inport','insignal',];
    if self.width > 8:
      required.append('outlatch');
    for paramname in required:
      if not hasattr(self,paramname):
        raise SSBCCException('Required parameter "%s" is missing at %s' % (paramname,loc,));
    # There are no optional parameters.
    # Add the I/O port, internal signals, and the INPORT and OUTPORT symbols for this peripheral.
    config.AddIO(self.insignal,1,'input',loc);
    config.AddSignal('s__%s__inport' % self.insignal, self.width, loc);
    self.ix_inport = config.NInports();
    config.AddInport((self.inport,
                      ('s__%s__inport' % self.insignal, self.width, 'data', ),
                      ),loc);
    self.ix_latch = config.NOutports();
    if hasattr(self,'outlatch'):
      config.AddOutport((self.outlatch,True,
                        # empty list
                        ),loc);

  def GenVerilog(self,fp,config):
    if self.width <= 8:
      body = """//
// PERIPHERAL counter:  @INSIGNAL@
//
always @ (posedge i_clk)
  if (i_rst)
    @NAME@ <= @WIDTH@'d0;
  else if (@INSIGNAL@)
    @NAME@ <= @NAME@ + @WIDTH@'d1;
  else
    @NAME@ <= @NAME@;
""";
    else:
      body = """//
// PERIPHERAL counter:  @INSIGNAL@
//
reg [@WIDTH-1@:0] s__count = @WIDTH@'d0;
always @ (posedge i_clk)
  if (i_rst)
    s__count <= @WIDTH@'d0;
  else if (@INSIGNAL@)
    s__count <= s__count + @WIDTH@'d1;
  else
    s__count <= s__count;
always @ (posedge i_clk)
  if (i_rst)
    @NAME@ <= @WIDTH@'d0;
  else if (s_outport && (s_T == @IX_LATCH@))
    @NAME@ <= s__count;
  else if (s_inport && (s_T == @IX_INPORT@))
    @NAME@ <= { 8'd0, @NAME@[@WIDTH-1:8@] };
  else
    @NAME@ <= @NAME@;
""";
    for subpair in (
        ( r'\bs__',       's__@NAME@__',                                          ),
        ( r'@IX_LATCH@',  "8'd%d" % self.ix_latch,                                ),
        ( r'@IX_INPORT@', "8'd%d" % self.ix_inport,                               ),
        ( r'@WIDTH@',     str(self.width),                                        ),
        ( r'@WIDTH-1@',   str(self.width-1),                                      ),
        ( r'@WIDTH-1:8@', '%d:8' % (self.width-1) if self.width > 9 else '8'      ),
        ( r'@NAME@',      's__@INSIGNAL@__inport',                                ),
        ( r'@INSIGNAL@',  self.insignal,                                          ),
      ):
      body = re.sub(subpair[0],subpair[1],body);
    body = self.GenVerilogFinal(config,body);
    fp.write(body);
