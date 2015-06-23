`include "timescale.v"

module eth_l3_checksum 
   (
     MRxClk ,Reset, RxData , ByteCnt, CheckSum ,CSready
   );

input    MRxClk;
input    Reset;
input [7:0] RxData;
input [15:0] ByteCnt;
output [15:0] CheckSum;
output        CSready;

reg   [15:0]   CheckSum;
reg   [31:0]   Sum;
reg            CSready;
reg   [1:0]    StartCalc;
reg            Divided_2_clk ;
reg            Divided_4_clk ;
reg [7:0] prev_latched_Rx;
reg [7:0] prev_latched_Rx1;

 initial Divided_2_clk=0;
 initial Divided_4_clk=0;

always @ (posedge MRxClk)
    begin
       Divided_2_clk <=  MRxClk^Divided_2_clk;
       if (ByteCnt[15:0] >= 16'h17 & ByteCnt[15:0] < (16'h17+16'd20))
           begin
           prev_latched_Rx[7:0] <= RxData[7:0];
           prev_latched_Rx1[7:0] <= prev_latched_Rx[7:0];
           end

    end

always @ (posedge Divided_2_clk)
      Divided_4_clk <= Divided_4_clk ^ Divided_2_clk;
       

always @ (posedge  Divided_2_clk or posedge Reset )
begin
    if (Reset)
        begin
        CheckSum[15:0] <= 16'd0;
        CSready <= 1'd0;
        end
    else
       if (ByteCnt[15:0]==16'h15)
           StartCalc[0] <= (RxData[7:0] == 8'h8);
       else
       if (ByteCnt[15:0]==16'h16)
           begin
           StartCalc[0] <= (RxData[7:0] == 8'h0) & StartCalc[0] ;
           CheckSum[15:0] <= 16'h0;
           Sum[31:0] <= 32'h0;
           CSready <= 1'b0;
           end
       else     
       if (ByteCnt[15:0] >= 16'h17 & ByteCnt[15:0] < (16'h17+16'd20))
           begin
           StartCalc[1]<= (ByteCnt[15:0] > 16'h17) & StartCalc[0] ;
           end
       else
         StartCalc[1:0] <= 2'h0;   
         
   if (ByteCnt[15:0]-16'h17== 16'd20)
       begin
         CSready <= 1'b1;
         CheckSum[15:0] <= ~(Sum[15:0]+Sum[31:16]);
       end
       
   end

 always @ (negedge Divided_4_clk)
 begin
      if (&StartCalc)
        Sum[31:0]<= Sum[31:0] + {prev_latched_Rx1[7:0] , RxData[7:0]};
      
  end

  

endmodule
