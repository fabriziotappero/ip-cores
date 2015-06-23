module notech_reg (CP,CD,D,Q);
input CP,CD,D;
output reg Q;
always @(posedge CP or negedge CD) if (CD==0) Q <= 0; else Q<=D;
endmodule
