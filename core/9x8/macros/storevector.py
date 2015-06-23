# Copyright 2014, Sinclair R.F., Inc.

from asmDef import AsmException

def storevector(ad):
  """
  Built-in macro to move multiple bytes from the data stack to memory.  The MSB
  (top of the data stack) is store at the specified memory location with
  subsequent bytes stored at subsequent memory locations.\n
  Usage:
    .storevector(variable,N)
  where
    variable    is the name of a variable
    N           is the constant number of bytes to transfer\n
  The effect is:  variable[0]=u_MSB, ..., variable[N-1]=u_LSB\n
  ( u_LSB ... u_MSB - )
  """

  def length(ad,argument):
    N = ad.Emit_IntegerValue(argument[1]);
    return N+2;

  # Add the macro to the list of recognized macros.
  ad.AddMacro('.storevector', length, [
                                        ['','symbol'],
                                        ['','singlevalue','symbol'],
                                      ]);

  # Define the macro functionality.
  def emitFunction(ad,fp,argument):
    (addr,ixBank,bankName) = ad.Emit_GetAddrAndBank(argument[0]);
    N = ad.Emit_IntegerValue(argument[1]);
    if addr+N > 256:
      raise asmDef.AsmException('Unreasonable address+length=0x%02X+0x%02X > 256 at %s' % (addr,N,argument[0]['loc'],));
    ad.EmitPush(fp,addr,argument[0]['value']);
    for dummy in range(N):
      ad.EmitOpcode(fp,ad.specialInstructions['store+'] | ixBank,'store+ '+bankName);
    ad.EmitOpcode(fp,ad.InstructionOpcode('drop'),'drop -- .storevector(%s,%s)' % (argument[0]['value'],argument[1]['value'],) );

  ad.EmitFunction['.storevector'] = emitFunction;
