# Copyright 2014, Sinclair R.F., Inc.

from asmDef import AsmException

def fetchvector(ad):
  """
  Built-in macro to move multiple bytes from memory to the data stack.  The byte
  at the specified memory address is stored at the top of the data stack with
  subsequent bytes store below it.\n
  Usage:
    .fetchvector(variable,N)
  where
    variable    is the name of a variable
    N           is the constant number of bytes to transfer\n
  The effect is to push the values u_LSB=variable[N-1], ..., u_msb=variable[0]
  onto the data stack.\n
  ( - u_LSB ... u_MSB )
  """

  def length(ad,argument):
    N = ad.Emit_IntegerValue(argument[1]);
    if not (N > 0):
      raise asmDef.AsmException('Vector length must be positive at %s' % argument[1]['loc']);
    return N+1;

  # Add the macro to the list of recognized macros.
  ad.AddMacro('.fetchvector', length, [
                                        ['','symbol'],
                                        ['','singlevalue','symbol']
                                      ]);

  # Define the macro functionality.
  def emitFunction(ad,fp,argument):
    (addr,ixBank,bankName) = ad.Emit_GetAddrAndBank(argument[0]);
    N = ad.Emit_IntegerValue(argument[1]);
    offsetString = '%s-1' % argument[1]['value'] if type(argument[0]['value']) == str else '%d-1' % N;
    ad.EmitPush(fp,addr+N-1,'%s+%s' % (argument[0]['value'],offsetString));
    for dummy in range(N-1):
      ad.EmitOpcode(fp,ad.specialInstructions['fetch-'] | ixBank,'fetch- '+bankName);
    ad.EmitOpcode(fp,ad.specialInstructions['fetch'] | ixBank,'fetch '+bankName);

  ad.EmitFunction['.fetchvector'] = emitFunction;
