module aes_pipelined_key_expand_128(wo_0_0, wo_0_1, wo_0_2, wo_0_3, wo_0_4, wo_0_5, wo_0_6, wo_0_7, wo_0_8, wo_0_9,
                          wo_1_0, wo_1_1, wo_1_2, wo_1_3, wo_1_4, wo_1_5, wo_1_6, wo_1_7, wo_1_8, wo_1_9,
                          wo_2_0, wo_2_1, wo_2_2, wo_2_3, wo_2_4, wo_2_5, wo_2_6, wo_2_7, wo_2_8, wo_2_9,
                          wo_3_0, wo_3_1, wo_3_2, wo_3_3, wo_3_4, wo_3_5, wo_3_6, wo_3_7, wo_3_8, wo_3_9);

output	[31:0]	wo_0_0, wo_0_1, wo_0_2, wo_0_3, wo_0_4, wo_0_5, wo_0_6, wo_0_7, wo_0_8, wo_0_9,
                        wo_1_0, wo_1_1, wo_1_2, wo_1_3, wo_1_4, wo_1_5, wo_1_6, wo_1_7, wo_1_8, wo_1_9,
                        wo_2_0, wo_2_1, wo_2_2, wo_2_3, wo_2_4, wo_2_5, wo_2_6, wo_2_7, wo_2_8, wo_2_9,
                        wo_3_0, wo_3_1, wo_3_2, wo_3_3, wo_3_4, wo_3_5, wo_3_6, wo_3_7, wo_3_8, wo_3_9;

assign wo_0_0 = 32'ha7d3ab65;
assign wo_0_1 = 32'h4a805c1c;
assign wo_0_2 = 32'h47c73534;
assign wo_0_3 = 32'h9b1c7104;
assign wo_0_4 = 32'hbdde78b1;
assign wo_0_5 = 32'h9715a416;
assign wo_0_6 = 32'hea61be0a;
assign wo_0_7 = 32'h56f60697;
assign wo_0_8 = 32'h203cc708;
assign wo_0_9 = 32'hef7a391e;

assign wo_1_0 = 32'haa3fa688;
assign wo_1_1 = 32'he0bffa94;
assign wo_1_2 = 32'ha778cfa0;
assign wo_1_3 = 32'h3c64bea4;
assign wo_1_4 = 32'h81bac615;
assign wo_1_5 = 32'h16af6203;
assign wo_1_6 = 32'hfccedc09;
assign wo_1_7 = 32'haa38da9e;
assign wo_1_8 = 32'h8a041d96;
assign wo_1_9 = 32'h657e2488;

assign wo_2_0 = 32'ha19ebc56;
assign wo_2_1 = 32'h412146c2;
assign wo_2_2 = 32'he6598962;
assign wo_2_3 = 32'hda3d37c6;
assign wo_2_4 = 32'h5b87f1d3;
assign wo_2_5 = 32'h4d2893d0;
assign wo_2_6 = 32'hb1e64fd9;
assign wo_2_7 = 32'h1bde9547;
assign wo_2_8 = 32'h91da88d1;
assign wo_2_9 = 32'hf4a4ac59;

assign wo_3_0 = 32'haf615026;
assign wo_3_1 = 32'hee4016e4;
assign wo_3_2 = 32'h08199f86;
assign wo_3_3 = 32'hd224a840;
assign wo_3_4 = 32'h89a35993;
assign wo_3_5 = 32'hc48bca43;
assign wo_3_6 = 32'h756d859a;
assign wo_3_7 = 32'h6eb310dd;
assign wo_3_8 = 32'hff69980c;
assign wo_3_9 = 32'h0bcd3455;

endmodule
