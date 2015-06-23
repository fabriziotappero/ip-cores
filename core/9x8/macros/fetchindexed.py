# Copyright 2014, Sinclair R.F., Inc.

def fetchindexed(ad):
  """
  Built-in macro to the N'th byte from a variable where N is specified by the
  top of the data stack.\n
  Usage:
    <N> .fetchindexed(variable)
  where
    <N>         represents a value of the top of the data stack
    variable    is a variable\n
  The effect is:  T = variable[n]\n
  ( u_offset - u_mem )
  """

  # Add the macro to the list of recognized macros.
  ad.AddMacro('.fetchindexed', 3, [ ['','symbol'] ]);

  # Define the macro functionality.
  def emitFunction(ad,fp,argument):
    (addr,ixBank,bankName) = ad.Emit_GetAddrAndBank(argument[0]);
    ad.EmitPush(fp,addr,ad.Emit_String(argument[0]['value']),argument[0]['loc']);
    ad.EmitOpcode(fp,ad.InstructionOpcode('+'),'+');
    ad.EmitOpcode(fp,ad.specialInstructions['fetch'] | ixBank,'fetch '+bankName);

  ad.EmitFunction['.fetchindexed'] = emitFunction;
