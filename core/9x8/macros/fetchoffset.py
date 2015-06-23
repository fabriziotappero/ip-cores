# Copyright 2014-2015, Sinclair R.F., Inc.

from asmDef import AsmException

def fetchoffset(ad):
  """
  Built-in macro to copy the value at the specified offset into the specified
  variable to the top of the data stack.\n
  Usage:
    .fetchoffset(variable,ix)
  where
    variable    is a variable
    ix          is the index into the variable\n
  The effect is:  T = variable[ix]\n
  ( - u_mem )
  """

  # Add the macro to the list of recognized macros.
  ad.AddMacro('.fetchoffset', 2, [
                                   ['','symbol'],
                                   ['','singlevalue','symbol']
                                 ]);

  # Define the macro functionality.
  def emitFunction(ad,fp,argument):
    (addr,ixBank,bankName) = ad.Emit_GetAddrAndBank(argument[0]);
    offset = ad.Emit_EvalSingleValue(argument[1]);
    if addr+offset >= 256:
      raise asmDef.AsmException('Unreasonable address+length=0x%02X+0x%02X >= 256 at %s' % (addr,N,argument[0]['loc'],))
    ad.EmitPush(fp,addr+offset,ad.Emit_String('%s+%s' % (argument[0]['value'],offset,)),argument[0]['loc']);
    ad.EmitOpcode(fp,ad.specialInstructions['fetch'] | ixBank,'fetch '+bankName);

  ad.EmitFunction['.fetchoffset'] = emitFunction;
