################################################################################
#
# Copyright 2013-2014, Sinclair R.F., Inc.
#
################################################################################

import math
import re;

from ssbccPeripheral import SSBCCperipheral
from ssbccUtil import SSBCCException;

class AXI4_Lite_Slave_DualPortRAM(SSBCCperipheral):
  """
  AXI-Lite slave implemented as a dual-port RAM.  The dual-port RAM has at most
  256 bytes addressable by a single 8-bit value.  The data is stored in little
  endian format (i.e., the LSB of the 32-bit word is stored in the lowest
  numbered address).\n
  Usage:
    PERIPHERAL AXI4_Lite_Slave_DualPortRAM              \\
                                basePortName=<name>     \\
                                address=<O_address>     \\
                                read=<I_read>           \\
                                write=<O_write>         \\
                                [size=<N>]              \\
                                [ram8|ram32]\n
  Where:
    basePortName=<name>
      specifies the name used to construct the multiple AXI4-Lite signals
    address=<O_address>
      specifies the symbol used to set the address used for read and write
      operations from and to the dual-port memory
    read=<I_read>
      specifies the symbol used to read from the dual-port memory
    write=<O_write>
      specifies the symbol used to write to the dual-port memory
    size=<N>
      optionally specify the size of the dual-port memory.
      Note:  N must be either a power of 2 in the range from 16 to 256 inclusive
             or it must be a local param with the same restrictions on its
             value.
      Note:  N=256, i.e., the largest memory possible, is the default.
      Note:  Using a localparam for the memory size provides a convenient way
             to use the size of the dual port RAM in the micro controller code.\n
    ram8
      optionally specifies using an 8-bit RAM for the dual-port memory instantiation
      Note:  This is the default
    ram32
      optionally specifies using a 32-bit RAM for the dual-port memory instantiation
      Note:  This is required for Vivado 2013.3.\n
  Vivado Users:
    The peripheral creates a TCL script to facilitate turning the micro
    controller into an IP core.  Look for a file with the name
    "vivado_<basePortName>.tcl".\n
  Example:  The code fragments
              <addr> .outport(O_address) .inport(I_read)
            and
              <addr> .outport(O_address) <value> .outport(O_write)
            will read from and write to the dual-port RAM.\n
  Example:  Function to read the byte at the specified address:
              ; ( u_addr - u_value)
              .function als_read
                .outport(O_address) .inport(I_read) .return
            or
              ; ( u_addr - u_value)
              .function als_read
                .outport(O_address) I_read .return(inport)
            To invoke the function:
              <addr> .call(als_read)
            or
              .call(als_read,<addr>)\n
  Example:  Function to write the byte at the specified address:
              ; ( u_value u_addr - )
              .function als_write
                .outport(O_address) O_write outport .return(drop)
            To invoke the function:
              <value> <addr> .call(als_write)
            or
              <value> .call(als_write,<addr>)\n
  Example:  Spin on an address, waiting for the host processor to write to the
            address, do something when the address is written to, and then
            clear its contents.
              0x00 .outport(O_address)
              :loop .inport(I_read) 0= .jumpc(loop)
              ; Avoid race conditions between the processor writes and the micro
              ; controller read.
              .inport(I_read)
              ...
              ; clear the value and start waiting again
              0x00 O_address outport O_write outport .jump(loop,drop)\n
  LEGAL NOTICE:  ARM has restrictions on what kinds of applications can use
  interfaces based on their AXI protocol.  Ensure your application is in
  compliance with their restrictions before using this peripheral for an AXI
  interface.
  """

  def __init__(self,peripheralFile,config,param_list,loc):
    # Use the externally provided file name for the peripheral
    self.peripheralFile = peripheralFile;
    # Get the parameters.
    allowables = (
      ( 'address',      r'O_\w+$',      None,           ),
      ( 'basePortName', r'\w+$',        None,           ),
      ( 'ram8',         None,           None,           ),
      ( 'ram32',        None,           None,           ),
      ( 'read',         r'I_\w+$',      None,           ),
      ( 'size',         r'\S+$',        lambda v : self.IntPow2Method(config,v,lowLimit=16,highLimit=256), ),
      ( 'write',        r'O_\w+$',      None,           ),
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
      'address',
      'basePortName',
      'read',
      'write',
    ):
      if not hasattr(self,paramname):
        raise SSBCCException('Required parameter "%s" is missing at %s' % (paramname,loc,));
    # Set optional parameters.
    for optionalpair in (
        ('size',        256,    ),
      ):
      if not hasattr(self,optionalpair[0]):
        setattr(self,optionalpair[0],optionalpair[1]);
    # Ensure exclusive pair configurations are set and consistent.
    for exclusivepair in (
        ('ram8','ram32','ram8',True,),
      ):
      if hasattr(self,exclusivepair[0]) and hasattr(self,exclusivepair[1]):
        raise SSBCCException('Only one of "%s" and "%s" can be specified at %s' % (exclusivepair[0],exclusivepair[1],loc,));
      if not hasattr(self,exclusivepair[0]) and not hasattr(self,exclusivepair[1]):
        setattr(self,exclusivepair[2],exclusivepair[3]);
    # Set the string used to identify signals associated with this peripheral.
    self.namestring = self.basePortName;
    # Add the I/O port, internal signals, and the INPORT and OUTPORT symbols for this peripheral.
    self.address_width = int(math.log(self.size,2));
    for signal in (
        ( '%s_aresetn',         1,                      'input',        ),
        ( '%s_aclk',            1,                      'input',        ),
        ( '%s_awvalid',         1,                      'input',        ),
        ( '%s_awready',         1,                      'output',       ),
        ( '%s_awaddr',          self.address_width,     'input',        ),
        ( '%s_wvalid',          1,                      'input',        ),
        ( '%s_wready',          1,                      'output',       ),
        ( '%s_wdata',           32,                     'input',        ),
        ( '%s_wstrb',           4,                      'input',        ),
        ( '%s_bresp',           2,                      'output',       ),
        ( '%s_bvalid',          1,                      'output',       ),
        ( '%s_bready',          1,                      'input',        ),
        ( '%s_arvalid',         1,                      'input',        ),
        ( '%s_arready',         1,                      'output',       ),
        ( '%s_araddr',          self.address_width,     'input',        ),
        ( '%s_rvalid',          1,                      'output',       ),
        ( '%s_rready',          1,                      'input',        ),
        ( '%s_rdata',           32,                     'output',       ),
        ( '%s_rresp',           2,                      'output',       ),
      ):
      thisName = signal[0] % self.basePortName;
      config.AddIO(thisName,signal[1],signal[2],loc);
    config.AddSignal('s__%s__mc_addr'  % self.namestring, self.address_width, loc);
    config.AddSignal('s__%s__mc_rdata' % self.namestring, 8, loc);
    config.AddOutport((self.address,False,
                      ('s__%s__mc_addr' % self.namestring, self.address_width, 'data', ),
                      ),loc);
    config.AddInport((self.read,
                      ('s__%s__mc_rdata' % self.namestring, 8, 'data', ),
                      ),loc);
    self.ix_write = config.NOutports();
    config.AddOutport((self.write,False,
                      # empty list
                      ),loc);
    # Add the 'clog2' function to the processor (if required).
    config.functions['clog2'] = True;

  def GenVerilog(self,fp,config):
    body = self.LoadCore(self.peripheralFile,'.v');
    for subpair in (
        ( r'\bL__',             'L__@NAME@__',                          ),
        ( r'\bgen__',           'gen__@NAME@__',                        ),
        ( r'\bi_a',             '@NAME@_a',                             ),
        ( r'\bi_b',             '@NAME@_b',                             ),
        ( r'\bi_r',             '@NAME@_r',                             ),
        ( r'\bi_w',             '@NAME@_w',                             ),
        ( r'\bix__',            'ix__@NAME@__',                         ),
        ( r'\bo_',              '@NAME@_',                              ),
        ( r'\bs__',             's__@NAME@__',                          ),
        ( r'@IX_WRITE@',        "8'h%02x" % self.ix_write,              ),
        ( r'@NAME@',            self.namestring,                        ),
        ( r'@SIZE@',            str(self.size),                         ),
        ( r'@MEM8@',            '1' if hasattr(self,'mem8') else '0',   ),
      ):
      body = re.sub(subpair[0],subpair[1],body);
    body = self.GenVerilogFinal(config,body);
    fp.write(body);
