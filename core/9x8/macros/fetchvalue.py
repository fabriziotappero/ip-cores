# Copyright 2014, Sinclair R.F., Inc.

def fetchvalue(ad):
  """
  Built-in macro to copy the value from the specified variable to the top of the
  data stack.\n
  Usage:
    .fetchvalue(variable)
  where
    variable    is a variable\n
  The effect is:  T = variable\n
  ( - u_mem )
  """

  # Add the macro to the list of recognized macros.
  ad.AddMacro('.fetchvalue', 2, [ ['','symbol'] ]);

  # Define the macro functionality.
  def emitFunction(ad,fp,argument):
    (addr,ixBank,bankName) = ad.Emit_GetAddrAndBank(argument[0]);
    ad.EmitPush(fp,addr,ad.Emit_String(argument[0]['value']),argument[0]['loc']);
    ad.EmitOpcode(fp,ad.specialInstructions['fetch'] | ixBank,'fetch '+bankName);

  ad.EmitFunction['.fetchvalue'] = emitFunction;
