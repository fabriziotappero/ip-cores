################################################################################
#
# Copyright 2012-2013, Sinclair R.F., Inc.
#
################################################################################

import re

from ssbccPeripheral import SSBCCperipheral
from ssbccUtil import SSBCCException;

class trace(SSBCCperipheral):
  """
  Generate a human readable printout of the processor execution.  The program
  counter and opcode are delayed so that they are aligned with the results of
  the opcode.\n
  Usage:
    PERIPHERAL trace\n
  The following values are displayed in this order during the execution:
    program counter
    numeric opcode
    human-readable opcode
    ':'
    data stack pointer
    next-to-top of the data stack
    top of the data stack
    ':'
    top of the return stack
    return stack pointer\n
  Example:  See core/9x8/tb/core which is used to validate correct operation of
            the core.
  """

  def __init__(self,peripheralFile,config,params,loc):
    # Use the externally provided file name for the peripheral
    self.peripheralFile = peripheralFile;
    config.functions['display_trace'] = True;

  def GenVerilog(self,fp,config):
    body = """
//
// Trace peripheral
//
generate
reg [C_PC_WIDTH-1:0] s__PC_s[1:0];
reg            [8:0] s__opcode_s = 9'h000;
reg        [7*8-1:0] s__opcode_name;
initial begin
  s__PC_s[0] = {(C_PC_WIDTH){1'b0}};
  s__PC_s[1] = {(C_PC_WIDTH){1'b0}};
end
always @ (posedge i_clk) begin
  s__PC_s[0] <= s_PC;
  s__PC_s[1] <= s__PC_s[0];
  s__opcode_s <= s_opcode;
  display_trace({ s__PC_s[1], s__opcode_s, s_Np_stack_ptr, 1'b1, s_N, 1'b1, s_T, 1'b1, s_R, s_R_stack_ptr });
end
endgenerate
""";
    body = re.sub(r'\bs__','s__trace__',body);
    fp.write(body);
