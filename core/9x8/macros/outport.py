# Copyright 2014, Sinclair R.F., Inc.

def outport(ad):
  """
  Built-in macro to write the top of the data stack to the specified output
  port.\n
  Usage:
    .outport(O_name[,op])
  where
    O_name      is the name of the output port
    op          is an optional argument to override the default "drop"
                instruction\n
  The effect is:  Write T to the specified output port.\n
  ( u - )
  """

  # Add the macro to the list of recognized macros.
  ad.AddMacro('.outport', 3, [
                               ['','symbol'],
                               ['drop','instruction','singlemacro','singlevalue','symbol']
                             ]);

  # Define the macro functionality.
  def emitFunction(ad,fp,argument):
    outportName = argument[0]['value'];
    if not ad.IsOutport(outportName):
      raise asmDef.AsmException('Symbol "%s" is either not an output port or is a strobe-only outport at %s' % (outportName,argument[0]['loc']));
    ad.EmitPush(fp,ad.OutportAddress(outportName) & 0xFF,outportName);
    ad.EmitOpcode(fp,ad.InstructionOpcode('outport'),'outport');
    ad.EmitOptArg(fp,argument[1]);

  ad.EmitFunction['.outport'] = emitFunction;
