module altsyncram_Z1 (wren_a,wren_b,rden_b,data_a,data_b,address_a,address_b,clock0,clock1,clocken0,clocken1,aclr0,aclr1,byteena_a,byteena_b,addressstall_a,addressstall_b,q_a,q_b);
input wren_a;
input wren_b;
input rden_b;
input [7:0]data_a;
input [7:0]data_b;
input [6:0]address_a;
input [6:0]address_b;
input clock0;
input clock1;
input clocken0;
input clocken1;
input aclr0;
input aclr1;
input [0:0]byteena_a;
input [0:0]byteena_b;
input addressstall_a;
input addressstall_b;
output [7:0]q_a;
output [7:0]q_b;
endmodule

module altsyncram_Z2 (wren_a,wren_b,rden_b,data_a,data_b,address_a,address_b,clock0,clock1,clocken0,clocken1,aclr0,aclr1,byteena_a,byteena_b,addressstall_a,addressstall_b,q_a,q_b);
input wren_a;
input wren_b;
input rden_b;
input [7:0]data_a;
input [0:0]data_b;
input [6:0]address_a;
input [0:0]address_b;
input clock0;
input clock1;
input clocken0;
input clocken1;
input aclr0;
input aclr1;
input [0:0]byteena_a;
input [0:0]byteena_b;
input addressstall_a;
input addressstall_b;
output [7:0]q_a;
output [0:0]q_b;
endmodule

