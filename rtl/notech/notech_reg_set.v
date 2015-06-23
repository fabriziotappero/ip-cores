module notech_reg_set (CP,SD,D,Q);
input CP,SD,D;
output reg Q;
always @(posedge CP or negedge SD) if (SD==0) Q <= 1; else Q<=D;
endmodule

