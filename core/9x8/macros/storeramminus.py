# Copyright 2014, Sinclair R.F., Inc.

def storeramminus(ad):
  """
  Built-in macro for the store- instruction where the memory is specified by
  the variable name instead of the memory name.\n
  Usage:
    .storeram-(variable)
  where
    variable    is a variable\n
  The effect is:  RAM[T] = N
                  T = T-1
                  N = next in stack\n
  ( u_mem u_addr - u_addr-1 )
  """

  # Add the macro to the list of recognized macros.
  ad.AddMacro('.storeram-', 1, [ ['','symbol'] ]);

  # Define the macro functionality.
  def emitFunction(ad,fp,argument):
    (addr,ixBank,bankName) = ad.Emit_GetAddrAndBank(argument[0]);
    emitString = 'store-(%s) -- %s' % (bankName,argument[0]['value'],);
    ad.EmitOpcode(fp,ad.specialInstructions['store-'] | ixBank,emitString);

  ad.EmitFunction['.storeram-'] = emitFunction;
