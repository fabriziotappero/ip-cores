# Copyright 2014, Sinclair R.F., Inc.

def inport(ad):
  """
  Built-in macro to read the specified input port and save the value on the
  top of the data stack.\n
  Usage:
    .inport(I_name)
  where
    I_name      is the name of the input port.\n
  The effect is:  T = <value from the specified input port>\n
  ( - u )
  """

  # Add the macro to the list of recognized macros.
  ad.AddMacro('.inport', 2, [ ['','symbol'] ]);

  # Define the macro functionality.
  def emitFunction(ad,fp,argument):
    if not ad.IsInport(argument[0]['value']):
      raise asmDef.AsmException('Symbol "%s is not an input port at %s' % (argument[0]['value'],argument[0]['loc']));
    name = argument[0]['value'];
    ad.EmitPush(fp,ad.InportAddress(name) & 0xFF,name);
    ad.EmitOpcode(fp,ad.InstructionOpcode('inport'),'inport');

  ad.EmitFunction['.inport'] = emitFunction;
