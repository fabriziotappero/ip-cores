`timescale 1ns / 1ps
`include "aDefinitions.v"
module InstructionEntryPoint
(
input wire                          Clock,
input wire 								   Reset,
input wire 								   iTrigger,
input wire[`ROM_ADDRESS_WIDTH-1:0]  iInitialCodeAddress,
input wire [`INSTRUCTION_WIDTH-1:0] iIMemInput,

output wire                          oEPU_Busy,
output wire [`ROM_ADDRESS_WIDTH-1:0] oEntryPoint,
output wire                          oTriggerIFU,
output wire [`ROM_ADDRESS_WIDTH-1:0] oInstructionAddr
);

assign oInstructionAddr = (oTriggerIFU) ? oEntryPoint : iInitialCodeAddress;
assign oEPU_Busy = iTrigger | oTriggerIFU;



FFD_POSEDGE_ASYNC_RESET # ( 1 ) FFD1
(
.Clock(Clock),
.Clear( Reset ), 
.D(iTrigger),
.Q(oTriggerIFU)
); 

assign oEntryPoint = (oTriggerIFU) ? iIMemInput[`ROM_ADDRESS_WIDTH-1:0] : `ROM_ADDRESS_WIDTH'b0;

endmodule
