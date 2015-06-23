################################################################################
#
# Copyright 2012-2013, Sinclair R.F., Inc.
#
################################################################################

from ssbccPeripheral import SSBCCperipheral

class adder_16bit(SSBCCperipheral):
  """The "adder_16bit" peripheral adds or subtracts two 16 bit values.\n
Usage:
  PERIPHERAL adder_16bit\n
The following OUTPORTs are provided by the peripheral:
  port                description
  O_ADDER_16BIT_MSB1  MSB of first argument
  O_ADDER_16BIT_LSB1  LSB of first argument
  O_ADDER_16BIT_MSB2  MSB of second argument
  O_ADDER_16BIT_LSB2  LSB of second argument
  O_ADDER_16BIT_OP    0 ==> add, 1 ==> subtract\n
The following INPORTs are provided by the peripheral:
  port                description
  I_ADDER_16BIT_MSB   MSB of the sum/difference
  I_ADDER_16BIT_LSB   LSB of the sum/difference\n
Example:  Incorporate the peripheral:\n
Example:  Add an 8-bit value and a 16-bit value from the stack:\n
  Within the processor architecture file include the configuration command:\n
  PERIPHERAL adder_16bit\n
  Use the following assembly code to perform the addition to implement a
  function that adds an 8-bit value at the top of the data stack to the 16-bit
  value immediately below it:\n
  ; ( u2_LSB u2_MSB u1 - (u1+u2)_LSB (u1+u2)_MSB
  .function add_u8_u16__u16
    ; write the 8-bit value to the peripheral (after converting it to a 16 bit
    ; value)
    0 .outport(O_ADDER_16BIT_MSB1) .outport(O_ADDER_16BIT_LSB1)
    ; write the 16-bit value to the peripheral
    .outport(O_ADDER_16BIT_MSB2) .outport(O_ADDER_16BIT_LSB2)
    ; command an addition
    0 .outport(O_ADDER_16BIT_OP)
    ; push the 16-bit sum onto the stack
    .inport(I_ADDER_16BIT_LSB) .inport(I_ADDER_16BIT_MSB)
  .return
"""

  def __init__(self,peripheralFile,config,params,loc):
    # Use the externally provided file name for the peripheral
    self.peripheralFile = peripheralFile;
    # List the signals to be declared for the peripheral.
    config.AddSignal('s__adder_16bit_out_MSB',8,loc);
    config.AddSignal('s__adder_16bit_out_LSB',8,loc);
    config.AddSignal('s__adder_16bit_in_MSB1',8,loc);
    config.AddSignal('s__adder_16bit_in_LSB1',8,loc);
    config.AddSignal('s__adder_16bit_in_MSB2',8,loc);
    config.AddSignal('s__adder_16bit_in_LSB2',8,loc);
    config.AddSignal('s__adder_16bit_in_op',1,loc);
    # List the input ports to the peripheral.
    config.AddInport(('I_ADDER_16BIT_MSB',
                     ('s__adder_16bit_out_MSB',8,'data',),
                    ),loc);
    config.AddInport(('I_ADDER_16BIT_LSB',
                     ('s__adder_16bit_out_LSB',8,'data',),
                    ),loc);
    # List the output ports from the peripheral.
    config.AddOutport(('O_ADDER_16BIT_MSB1',False,
                       ('s__adder_16bit_in_MSB1',8,'data',),
                     ),loc);
    config.AddOutport(('O_ADDER_16BIT_LSB1',False,
                      ('s__adder_16bit_in_LSB1',8,'data',),
                     ),loc);
    config.AddOutport(('O_ADDER_16BIT_MSB2',False,
                      ('s__adder_16bit_in_MSB2',8,'data',),
                     ),loc);
    config.AddOutport(('O_ADDER_16BIT_LSB2',False,
                      ('s__adder_16bit_in_LSB2',8,'data',),
                     ),loc);
    config.AddOutport(('O_ADDER_16BIT_OP',False,
                      ('s__adder_16bit_in_op',1,'data',),
                     ),loc);

  def GenAssembly(self,config):
    fp = file('adder_16bit.s','w');
    fp.write("""; Copyright 2012-2013, Sinclair R.F., Inc.
; adder_16bit.s
; library to facilitate using the 16-bit adder peripheral

; ( u_1_LSB u_1_MSB u_2_LSB u_2_MSB u_op - (u_1+u_2)_LSB (u_1+u_2)_MSB )
.function addsub_u16_u16__u16
  .outport(O_ADDER_16BIT_OP)
  .outport(O_ADDER_16BIT_MSB2) .outport(O_ADDER_16BIT_LSB2)
  .outport(O_ADDER_16BIT_MSB1) .outport(O_ADDER_16BIT_LSB1)
  .inport(I_ADDER_16BIT_LSB) I_ADDER_16BIT_MSB
.return(inport)
""");

  def GenVerilog(self,fp,config):
    body = """//
// PERIPHERAL adder_16bit:
//
always @ (posedge i_clk)
  if (s__adder_16bit_in_op == 1\'b0)
    { s__adder_16bit_out_MSB, s__adder_16bit_out_LSB }
      <= { s__adder_16bit_in_MSB1, s__adder_16bit_in_LSB1 }
       + { s__adder_16bit_in_MSB2, s__adder_16bit_in_LSB2 };
  else
    { s__adder_16bit_out_MSB, s__adder_16bit_out_LSB }
      <= { s__adder_16bit_in_MSB1, s__adder_16bit_in_LSB1 }
       - { s__adder_16bit_in_MSB2, s__adder_16bit_in_LSB2 };
""";
    body = self.GenVerilogFinal(config,body);
    fp.write(body);
