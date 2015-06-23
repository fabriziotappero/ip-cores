module minPiece(/*AUTOARG*/
   // Outputs
   minPoss, minIdx,
   // Inputs
   clk, rst, inGrid
   );

   input clk;
   input rst;
   
   input [728:0] inGrid;
   
   output [3:0]  minPoss;
   output [6:0]  minIdx;
   
   reg [3:0] 	 r_minPoss;
   reg [6:0] 	 r_minIdx;

   assign minPoss = r_minPoss;
   assign minIdx = r_minIdx;
   
   
   wire [8:0] 	 grid2d [80:0];

   wire [6:0] 	 gridIndices [80:0];
   wire [3:0] 	 gridPoss [80:0];
      
   genvar 	 i;

   /* unflatten */
   generate
      for(i=0;i<81;i=i+1)
	begin: unflatten
	   assign grid2d[i] = inGrid[(9*(i+1))-1:9*i];
	   assign gridIndices[i] = i;
	   countPoss cP (.clk(clk), .rst(rst), .in(grid2d[i]), .out(gridPoss[i]));
	end
   endgenerate

   wire [6:0] 	 stage1_gridIndices [39:0];
   wire [3:0] 	 stage1_gridPoss [39:0];

   generate
      for(i=0;i<40;i=i+1)
	begin: stage1
	   cmpPiece cP_stage1
	    (
	     .outPoss(stage1_gridPoss[i]),
	     .outIdx(stage1_gridIndices[i]),
	     .inPoss_0(gridPoss[2*i]),
	     .inIdx_0(gridIndices[2*i]),
	     .inPoss_1(gridPoss[2*i+1]),
	     .inIdx_1(gridIndices[2*i+1])
	     );
	end
   endgenerate

   wire [6:0] 	 stage2_gridIndices [19:0];
   wire [3:0] 	 stage2_gridPoss [19:0];

   generate
      for(i=0;i<20;i=i+1)
	begin: stage2
	   cmpPiece cP_stage2
	    (
	     .outPoss(stage2_gridPoss[i]),
	     .outIdx(stage2_gridIndices[i]),
	     .inPoss_0(stage1_gridPoss[2*i]),
	     .inIdx_0(stage1_gridIndices[2*i]),
	     .inPoss_1(stage1_gridPoss[2*i+1]),
	     .inIdx_1(stage1_gridIndices[2*i+1])
	     );
	end
   endgenerate

   wire [6:0] 	 stage3_gridIndices [9:0];
   wire [3:0] 	 stage3_gridPoss [9:0];
   
   generate
      for(i=0;i<10;i=i+1)
	begin: stage3
	   cmpPiece cP_stage3
	    (
	     .outPoss(stage3_gridPoss[i]),
	     .outIdx(stage3_gridIndices[i]),
	     .inPoss_0(stage2_gridPoss[2*i]),
	     .inIdx_0(stage2_gridIndices[2*i]),
	     .inPoss_1(stage2_gridPoss[2*i+1]),
	     .inIdx_1(stage2_gridIndices[2*i+1])
	     );
	end
   endgenerate

   wire [6:0] 	 stage4_gridIndices [4:0];
   wire [3:0] 	 stage4_gridPoss [4:0];

   generate
      for(i=0;i<5;i=i+1)
	begin: stage4
	   cmpPiece cP_stage4
	    (
	     .outPoss(stage4_gridPoss[i]),
	     .outIdx(stage4_gridIndices[i]),
	     .inPoss_0(stage3_gridPoss[2*i]),
	     .inIdx_0(stage3_gridIndices[2*i]),
	     .inPoss_1(stage3_gridPoss[2*i+1]),
	     .inIdx_1(stage3_gridIndices[2*i+1])
	     );
	end
   endgenerate

   wire [6:0] 	 stage5_gridIndices [1:0];
   wire [3:0] 	 stage5_gridPoss [1:0];

   
   generate
      for(i=0;i<2;i=i+1)
	begin: stage5
	   cmpPiece cP_stage5
	    (
	     .outPoss(stage5_gridPoss[i]),
	     .outIdx(stage5_gridIndices[i]),
	     .inPoss_0(stage4_gridPoss[2*i]),
	     .inIdx_0(stage4_gridIndices[2*i]),
	     .inPoss_1(stage4_gridPoss[2*i+1]),
	     .inIdx_1(stage4_gridIndices[2*i+1])
	     );
	end
   endgenerate


   wire [6:0] stage6_gridIndices_A;
   wire [3:0] stage6_gridPoss_A;

   cmpPiece cP_stage6_A
     (
      .outPoss(stage6_gridPoss_A),
      .outIdx(stage6_gridIndices_A),
      .inPoss_0(stage5_gridPoss[0]),
      .inIdx_0(stage5_gridIndices[0]),
      .inPoss_1(stage5_gridPoss[1]),
      .inIdx_1(stage5_gridIndices[1])
      );
   
   wire [6:0] stage6_gridIndices_B;
   wire [3:0] stage6_gridPoss_B;
   
   cmpPiece cP_stage6_B
     (
      .outPoss(stage6_gridPoss_B),
      .outIdx(stage6_gridIndices_B),
      .inPoss_0(stage4_gridPoss[4]),
      .inIdx_0(stage4_gridIndices[4]),
      .inPoss_1(gridPoss[80]),
      .inIdx_1(gridIndices[80])
      );
   
   wire [6:0] stage7_gridIndices;
   wire [3:0] stage7_gridPoss;
   
   cmpPiece cP_stage7
     (
      .outPoss(stage7_gridPoss),
      .outIdx(stage7_gridIndices),
      .inPoss_0(stage6_gridPoss_A),
      .inIdx_0(stage6_gridIndices_A),
      .inPoss_1(stage6_gridPoss_B),
      .inIdx_1(stage6_gridIndices_B)
      );

   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_minIdx <= 7'd0;
	     r_minPoss <= 4'hf;
	  end
	else
	  begin
	     r_minIdx <= stage7_gridIndices;
	     r_minPoss <= stage7_gridPoss;
	  end
     end // always@ (posedge clk)
      
endmodule

module cmpPiece(/*AUTOARG*/
   // Outputs
   outPoss, outIdx,
   // Inputs
   inPoss_0, inIdx_0, inPoss_1, inIdx_1
   );
   input [3:0] inPoss_0;
   input [6:0] inIdx_0;

   input [3:0] inPoss_1;
   input [6:0] inIdx_1;

   output [3:0] outPoss;
   output [6:0] outIdx;

   wire 	w_cmp = (inPoss_0 < inPoss_1);

   assign outPoss = w_cmp ? inPoss_0 : inPoss_1;
   assign outIdx = w_cmp ? inIdx_0 : inIdx_1;
   
endmodule // cmpPiece

module countPoss(clk,rst,in,out);
   input [8:0] in;
   input       clk;
   input       rst;
   
   output [3:0] out;
   reg [3:0] 	r_out;
   assign out = r_out;
   
   wire [3:0] 	w_cnt;
      
   one_count9 c0(in, w_cnt);
   wire [3:0] w_out = (w_cnt == 4'd1) ? 4'd15 : w_cnt;

   always@(posedge clk)
     begin
	r_out <= rst ? 4'd15 : w_out;
     end
   
endmodule