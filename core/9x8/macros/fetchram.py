# Copyright 2014, Sinclair R.F., Inc.

def fetchram(ad):
  """
  Built-in macro for the fetch instruction where the memory is specified by the
  variable name instead of the memory name.\n
  Usage:
    .fetchram(variable)
  where
    variable    is a variable\n
  The effect is:  T = variable\n
  ( u_addr - u_mem )
  """

  # Add the macro to the list of recognized macros.
  ad.AddMacro('.fetchram', 1, [ ['','symbol'] ]);

  # Define the macro functionality.
  def emitFunction(ad,fp,argument):
    (addr,ixBank,bankName) = ad.Emit_GetAddrAndBank(argument[0]);
    emitString = 'fetch(%s) -- %s' % (bankName,argument[0]['value'],);
    ad.EmitOpcode(fp,ad.specialInstructions['fetch'] | ixBank,emitString);

  ad.EmitFunction['.fetchram'] = emitFunction;
