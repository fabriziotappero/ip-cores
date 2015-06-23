module notech_nand2 (A,B,Z);
input A,B;
output Z;
assign Z=~(A&B);
endmodule
