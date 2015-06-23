
module Alignment_marker(reset,clk,Data_o,iba2xbar_start_pack,iba2xbar_end_pack,xbar2plu_start_pack,xbar2plu_end_pack);
    input reset,clk;
    input [7:0] T_q;
    input [31:0] Data_o;
    input  iba2xbar_end_pack , iba2xbar_start_pack;
    output xbar2plu_start_pack , xbar2plu_end_pack;
     reg [31:0] Data_o_delayed;
     reg flip;
     
    always @(posedge clk)
    begin
        Data_o_delayed <= Data_o;
        flip = Data_o_delayed^Data_o;
    end
      
endmodule
