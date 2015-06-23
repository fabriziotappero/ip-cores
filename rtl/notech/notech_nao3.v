module notech_nao3 (A,B,C,Z);
input A,B,C;
output Z;
assign Z=~(A&B&~C);
endmodule
