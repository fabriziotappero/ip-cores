# Copyright 2014, Sinclair R.F., Inc.

def outstrobe(ad):
  """
  Built-in macro to send strobes to the specified strobe-only output port.\n
  Usage:
    .outstrobe(O_name)
  where
    O_name      is the name of the output port\n
  The effect is:  To active the strobe at the specified output port.\n
  ( - )
  """

  # Add the macro to the list of recognized macros.
  ad.AddMacro('.outstrobe', 2, [ ['','symbol'] ]);

  # Define the macro functionality.
  def emitFunction(ad,fp,argument):
    if not ad.IsOutstrobe(argument[0]['value']):
      raise asmDef.AsmException('Symbol "%s" is not a strobe-only output port at %s' % (argument[0]['value'],argument[0]['loc']));
    name = argument[0]['value'];
    ad.EmitPush(fp,ad.OutportAddress(name) & 0xFF,name);
    ad.EmitOpcode(fp,ad.InstructionOpcode('outport'),'outport');

  ad.EmitFunction['.outstrobe'] = emitFunction;
