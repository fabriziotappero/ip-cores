################################################################################
#
# Copyright 2013-2014, Sinclair R.F., Inc.
#
################################################################################

import math
import re;

from ssbccPeripheral import SSBCCperipheral
from ssbccUtil import SSBCCException;

class AXI4_Lite_Master(SSBCCperipheral):
  """
  AXI-Lite master for 32-bit reads and 8, 16, and 32-bit writes.\n
  256 bytes addressable by a single 8-bit value.  The data is stored in little
  endian format (i.e., the LSB of the 32-bit word is stored in the lowest
  numbered address).\n
  Usage:
    PERIPHERAL AXI4_Lite_Master                                         \\
                                basePortName=<name>                     \\
                                address=<O_address>                     \\
                                data=<O_data>                           \\
                                command_read=<O_command_read>           \\
                                command_write=<O_command_write>         \\
                                busy=<I_busy>                           \\
                                error=<I_error>                         \\
                                read=<I_read>                           \\
                                address_width=<N>                       \\
                                synchronous={True|False}                \\
                                write_enable=<O_write_enable>|noWSTRB\n
  Where:
    basePortName=<name>
      specifies the name used to construct the multiple AXI4-Lite signals
    address=<O_address>
      specifies the symbol used to set the address used for read and write
      operations from and to the dual-port memory
      Note:  If the address is 8 bits or less, a single write to this port will
             set the address.  If the address is 9 bits or longer, then multiple
             writes to this address, starting with the MSB of the address, are
             required to set all of the address bits.  See the examples for
             illustrations of how this works.
      Note:  The 2 lsb of the address are ignored.  I.e., all addresses will be
             treated as 32-bit aligned.
    data=<O_data>
      specifies the symbol used to set the 32-bit data for write operations
      Note:  Four outputs to this address are required, starting with the MSB of
             the 32-bit value,  See the examples for illustrations of how this
             works.
    command_read=<O_command_read>
      specifies the symbol used to start the AXI4-Lite master core to issue a
      read and store the received data
    command_write=<O_command_write>
      specifies the symbol used to start the AXI4-Lite master core to issue a
      write
    busy=<I_busy>
      specifies the symbol used to read the busy/not-busy status of the core
      Note:  A non-zero value means the core is busy.
    error=<I_error>
      specified the symbol used to read the error status of the last write or
      read transaction on the core
      Note:  A non-zero value means an error was encountered.  Errors can be
             reset by resetting the interface or by re-attempting the write or
             read operation.
    read=<I_read>
      specifies the symbol used to read successive bytes of the received 32-bit
      value starting with the LSB
    address_width=<N>
      specifies the width of the 8-bit aligned address\n
    synchronous={True|False}
      indicates whether or not he micro controller clock and the AXI4-Lite bus
      are synchronous
    write_enable=<O_write_enable>
      optionally specify the symbol used to set the 4 write enable bits
      Note:  This must be used if one or more of the slaves includes the
             optional WSTRB      signals.
    noWSTRB
      indicates that the optional WSTRB signal should not be included
      Note:  This must be specified if write_enable is not specified.\n
  Vivado Users:
    The peripheral creates a TCL script to facilitate turning the micro
    controller into an IP core.  Look for a file with the name
    "vivado_<basePortName>.tcl".\n
  Example:  Xilinx' AXI_DMA core has a 7-bit address range for its register
    address map.  The PERIPHERAL configuration statement to interface to this
    core would be:\n
      PERIPHERAL AXI4_Lite_Master                                       \
                        basePortName=myAxiDmaDevice                     \
                        address=O_myAxiDmaDevice_address                \
                        data=O_myAxiDmaDevice_data                      \
                        command_read=O_myAxiDmaDevice_cmd_read          \
                        command_write=O_myAxiDmaDevice_cmd_write        \
                        busy=I_myAxiDmaDevice_busy                      \
                        error=I_myAxiDmaDevice_error                    \
                        read=I_myAxiDmaDevice_read                      \
                        address_width=7                                 \
                        synchronous=True                                \\
                        write_enable=O_myAxiDmaDevice_wen\n
    To write to the memory master to slave start address, use the
    following, where "start_address" is a 4-byte variable set elsewhere in the
    program:\n
      ; Set the 7-bit register address.
      0x18 .outport(O_myAxiDmaDevice_address)
      ; Read the 4-byte start address from memory.
      .fetchvector(start_address,4)
      ; write the address to the AXI4-Lite master
      ${4-1} :loop_data
        swap .outport(O_myAxiDmaDevice_data)
      .jumpc(loop_data,1-) drop
      ; Ensure all 4 bytes will be written.
      0x0F .outport(O_myAxiDmaDevice_wen)
      ; Issue the write strobe.
      .outstrobe(O_myAxiDmaDevice_cmd_write)
      ; Wait for the write operation to finish.
      :loop_write_wait
        .inport(I_myAxiDmaDevice_busy)
      .jumpc(loop_write_wait)\n
    Alternatively, a function could be defined as follows:\n
      ; Write the specified 32-bit value to the specified 7-bit address.
      ; ( u_LSB u u u_MSB u_addr - )
      .function myAxiDmaDevice_write
        ; Write the 7-bit register address.
        .outport(O_myAxiDmaDevice_address)
        ; Write the 32-bit value, starting with the MSB.
        ${4-1} :loop_data
          swap .outport(O_myAxiDmaDevice_data)
        .jumpc(loop_data,1-) drop
        ; Ensure all 4 bytes will be written.
        0x0F .outport(O_myAxiDmaDevice_wen)
        ; Issue the write strobe.
        .outstrobe(O_myAxiDmaDevice_cmd_write)
        ; Wait for the write operation to finish.
        :loop_write_wait
          .inport(I_myAxiDmaDevice_busy)
        .jumpc(loop_write_wait)
        ; That's all
        .return\n
    And the write could then be performed using the following code:\n
      .constant AXI_DMA_MM2S_Start_Address 0x18
      ...
      ; Write the start address to the AXI DMA.
      .fetchvector(start_address,4)
      .call(myAxiDmaDevice_write,AXI_DMA_MM2S_Start_Address)\n
  Example:  Suppose the AXI4-Lite Master peripheral is connected to a memory
    with a 22-bit address width, i.e., a 4 MB address range.  The PERIPHERAL
    configuration command would be similar to the above except the string
    "myAxiDmaDevice" would need to be changed to the new hardware peripheral and
    the address width would be set using "address_width=22".\n
    The 22-bit address would be set using 3 bytes.  For example, the address
    0x020100 would be set by:\n
      0x00 .outport(O_myAxiMaster_address)
      0x01 .outport(O_myAxiMaster_address)
      0x02 .outport(O_myAxiMaster_address)\n
    The 2 msb of the first, most-significant, address byte will be dropped by
    the shift register receiving the address and the 2 lsb of the last, least
    significant, address byte will be written as zeros to the AXI Lite
    peripheral.\n
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
      ('address',       r'O_\w+$',              None,           ),
      ('address_width', r'[1-9]\d*$',           int,            ),
      ('basePortName',  r'\w+$',                None,           ),
      ('command_read',  r'O_\w+$',              None,           ),
      ('command_write', r'O_\w+$',              None,           ),
      ('data',          r'O_\w+$',              None,           ),
      ('read',          r'I_\w+$',              None,           ),
      ('busy',          r'I_\w+$',              None,           ),
      ('error',         r'I_\w+$',              None,           ),
      ('noWSTRB',       None,                   None,           ),
      ('synchronous',   r'(True|False)$',       bool,           ),
      ('write_enable',  r'O_\w+$',              None,           ),
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
        'address_width',
        'basePortName',
        'command_read',
        'command_write',
        'data',
        'read',
        'busy',
        'error',
        'synchronous',
      ):
      if not hasattr(self,paramname):
        raise SSBCCException('Required parameter "%s" is missing at %s' % (paramname,loc,));
    # Ensure exclusive pair configurations are set and consistent.
    for exclusivepair in (
        ('write_enable','noWSTRB',None,None,),
      ):
      if hasattr(self,exclusivepair[0]) and hasattr(self,exclusivepair[1]):
        raise SSBCCException('Only one of "%s" and "%s" can be specified at %s' % (exclusivepair[0],exclusivepair[1],loc,));
      if not hasattr(self,exclusivepair[0]) and not hasattr(self,exclusivepair[1]) and exclusivepair[2]:
        setattr(self,exclusivepair[2],exclusivepair[3]);
    # Ensure one and only one of the complementary optional values are set.
    if not hasattr(self,'write_enable') and not hasattr(self,'noWSTRB'):
      raise SSBCCException('One of "write_enable" or "noWSTRB" must be set at %s' % loc);
    # Temporary:  Warning message
    if not self.synchronous:
      raise SSBCCException('synchronous=False has not been validated yet');
    # Add the I/O port, internal signals, and the INPORT and OUTPORT symbols for this peripheral.
    for signal in (
      ( '%s_aresetn',           1,                      'input',        ),
      ( '%s_aclk',              1,                      'input',        ),
      ( '%s_awvalid',           1,                      'output',       ),
      ( '%s_awready',           1,                      'input',        ),
      ( '%s_awaddr',            self.address_width,     'output',       ),
      ( '%s_wvalid',            1,                      'output',       ),
      ( '%s_wready',            1,                      'input',        ),
      ( '%s_wdata',             32,                     'output',       ),
      ( '%s_wstrb',             4,                      'output',       ) if hasattr(self,'write_enable') else None,
      ( '%s_bresp',             2,                      'input',        ),
      ( '%s_bvalid',            1,                      'input',        ),
      ( '%s_bready',            1,                      'output',       ),
      ( '%s_arvalid',           1,                      'output',       ),
      ( '%s_arready',           1,                      'input',        ),
      ( '%s_araddr',            self.address_width,     'output',       ),
      ( '%s_rvalid',            1,                      'input',        ),
      ( '%s_rready',            1,                      'output',       ),
      ( '%s_rdata',             32,                     'input',        ),
      ( '%s_rresp',             2,                      'input',        ),
    ):
      if not signal:
        continue
      thisName = signal[0] % self.basePortName;
      config.AddIO(thisName,signal[1],signal[2],loc);
    config.AddSignal('s__%s__address' % self.basePortName, self.address_width, loc);
    config.AddSignal('s__%s__rd' % self.basePortName, 1, loc);
    config.AddSignal('s__%s__wr' % self.basePortName, 1, loc);
    config.AddSignal('s__%s__busy' % self.basePortName, 5, loc);
    config.AddSignal('s__%s__error' % self.basePortName, 2, loc);
    config.AddSignal('s__%s__read' % self.basePortName, 32, loc);
    self.ix_address = config.NOutports();
    config.AddOutport((self.address,False,
                      # empty list -- disable normal output port signal generation
                      ),loc);
    self.ix_data = config.NOutports();
    config.AddOutport((self.data,False,
                      # empty list -- disable normal output port signal generation
                      ),loc);
    if hasattr(self,'write_enable'):
      config.AddOutport((self.write_enable,False,
                      ('%s_wstrb' % self.basePortName, 4, 'data', ),
                      ),loc);
    config.AddOutport((self.command_read,True,
                      ('s__%s__rd' % self.basePortName, 1, 'strobe', ),
                      ),loc);
    config.AddOutport((self.command_write,True,
                      ('s__%s__wr' % self.basePortName, 1, 'strobe', ),
                      ),loc);
    config.AddInport((self.busy,
                     ('s__%s__busy' % self.basePortName, 5, 'data', ),
                     ),loc);
    config.AddInport((self.error,
                     ('s__%s__error' % self.basePortName, 2, 'data', ),
                     ),loc);
    self.ix_read = config.NInports();
    config.AddInport((self.read,
                     ('s__%s__read' % self.basePortName, 32, 'data', ),
                     ),loc);

  def GenVerilog(self,fp,config):
    body = self.LoadCore(self.peripheralFile,'.v');
    # avoid i_clk and i_rst
    for subpair in (
        ( r'\bgen__',           'gen__@NAME@__',                        ),
        ( r'\bL__',             'L__@NAME@__',                          ),
        ( r'\bs__',             's__@NAME@__',                          ),
        ( r'\bi_a',             '@NAME@_a',                             ),
        ( r'\bi_b',             '@NAME@_b',                             ),
        ( r'\bi_rd',            '@NAME@_rd',                            ),
        ( r'\bi_rr',            '@NAME@_rr',                            ),
        ( r'\bi_rv',            '@NAME@_rv',                            ),
        ( r'\bi_w',             '@NAME@_w',                             ),
        ( r'\bo_',              '@NAME@_',                              ),
        ( r'@ADDRESS_WIDTH@',   str(self.address_width),                ),
        ( r'@ISSYNC@',          "1'b1" if self.synchronous else "1'b0", ),
        ( r'@IX_ADDRESS@',      str(self.ix_address),                   ),
        ( r'@IX_DATA@',         str(self.ix_data),                      ),
        ( r'@IX_READ@',         str(self.ix_read),                      ),
        ( r'@NAME@',            self.basePortName,                      ),
      ):
      body = re.sub(subpair[0],subpair[1],body);
    body = self.GenVerilogFinal(config,body);
    fp.write(body);
