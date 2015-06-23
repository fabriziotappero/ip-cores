# Copyright 2014, Sinclair R.F., Inc.

def storeindexed(ad):
  """
  Built-in macro to store the next-to-top of the data stack at the 
  offset into variable specified by the top of the data stack.\n
  Usage:
    <v> <ix> .storeindexed(variable[,op])
  where:
    <v>         is the value to be stored from the next-to-top of the data
                stack
    <ix>        is the index into the variable
    variable    is the name of the variable
    op          is an optional instruction to override the default "drop"
                instruction at the end of the instruction sequence\n
  The effect is:  variable[ix] = v\n
  ( u_value u_ix - )
  """

  # Add the macro to the list of recognized macros.
  ad.AddMacro('.storeindexed', 4, [
                                    ['','symbol'],
                                    ['drop','instruction','singlemacro','singlevalue','symbol']
                                  ]);

  # Define the macro functionality.
  def emitFunction(ad,fp,argument):
    (addr,ixBank,bankName) = ad.Emit_GetAddrAndBank(argument[0]);
    ad.EmitPush(fp,addr,ad.Emit_String(argument[0]['value']),argument[0]['loc']);
    ad.EmitOpcode(fp,ad.InstructionOpcode('+'),'+');
    ad.EmitOpcode(fp,ad.specialInstructions['store'] | ixBank,'store '+bankName);
    ad.EmitOptArg(fp,argument[1]);

  ad.EmitFunction['.storeindexed'] = emitFunction;
