module notech_mux2 (A,B,Z,S);
input A,B,S;
output Z;
assign Z = S ? B: A;
endmodule
