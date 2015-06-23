module notech_mux4 (S0,S1,A,B,C,D,Z);
input S0,S1,A,B,C,D;
output Z;
wire int1,int2;
assign int1 = S0 ? B:A;
assign int2 = S0 ? D:C;
assign Z=S1 ? int2 : int1;
endmodule
