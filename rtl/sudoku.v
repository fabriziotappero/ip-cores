module sudoku(/*AUTOARG*/
   // Outputs
   outGrid, unsolvedCells, timeOut, allDone, anyChanged, anyError,
   minIdx, minPoss,
   // Inputs
   clk, rst, clr, start, inGrid
   );
   input clk;
   input rst;
   input clr;
   
   input start;
   
   input [728:0] inGrid;
   output [728:0] outGrid;
   output [6:0]   unsolvedCells;
   output 	  timeOut;
   output 	  allDone;
   output 	  anyChanged;
   output 	  anyError;

   output [6:0]   minIdx;
   output [3:0]   minPoss;
      
   wire [8:0] 	  grid2d [80:0];
   wire [8:0] 	  currGrid [80:0];
   wire [80:0] 	  done;
   wire [80:0] 	  changed;
   wire [80:0] 	  error;
   
   wire [71:0] 	  rows [80:0];
   wire [71:0] 	  cols [80:0];
   wire [71:0] 	  sqrs [80:0];
   

   assign allDone = &done;
   assign anyChanged = |changed;
   //assign anyError = |error;
   
   reg [3:0] 	  r_cnt;
   assign timeOut = (r_cnt == 4'b1111);
   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_cnt <= 4'd0;
	  end
	else
	  begin
	     r_cnt <= start ? 4'd0 : (|changed ? 4'd0 : r_cnt + 4'd1);
	  end
     end // always@ (posedge clk)

   minPiece mP0 
     (
      .minPoss(minPoss),
      .minIdx(minIdx),
      .clk(clk),
      .rst(rst),
      .inGrid(outGrid)
      );
         
   
   genvar 	  i;
   generate
      for(i=0;i<81;i=i+1)
	begin: unflatten
	   assign grid2d[i] = inGrid[(9*(i+1))-1:9*i];
	end
   endgenerate

   wire [6:0] w_unSolvedCells;
   reg [6:0]  r_unSolvedCells;
   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_unSolvedCells <= 7'd81;
	  end
	else
	  begin
	     r_unSolvedCells <= start ? 7'd81 : w_unSolvedCells;
	  end
     end // always@ (posedge clk)
   assign unsolvedCells = r_unSolvedCells;
   
   ones_count81 oc0 (.in(~done), .out(w_unSolvedCells));
   
   generate
      for(i=0;i<81;i=i+1)
	begin: pieces
	   piece pg (
		  // Outputs
		     .changed			(changed[i]),
		     .done			(done[i]),
		     .curr_value			(currGrid[i]),
		     .error                     (error[i]),
		     // Inputs
		     .clk				(clk),
		     .rst				(rst),
		     .clr                               (clr),
		     .start			(start),
		     .start_value			(grid2d[i]),
		     .my_row			(rows[i]),
		     .my_col			(cols[i]),
		     .my_square			(sqrs[i])
		  );
	end // block: pieces
    endgenerate
   
   assign cols[0] = {currGrid[9],currGrid[18],currGrid[27],currGrid[36],currGrid[45],currGrid[54],currGrid[63],currGrid[72]};
assign rows[0] = {currGrid[1],currGrid[2],currGrid[3],currGrid[4],currGrid[5],currGrid[6],currGrid[7],currGrid[8]};
assign sqrs[0] = {currGrid[1],currGrid[2],currGrid[9],currGrid[10],currGrid[11],currGrid[18],currGrid[19],currGrid[20]};
assign cols[1] = {currGrid[10],currGrid[19],currGrid[28],currGrid[37],currGrid[46],currGrid[55],currGrid[64],currGrid[73]};
assign rows[1] = {currGrid[0],currGrid[2],currGrid[3],currGrid[4],currGrid[5],currGrid[6],currGrid[7],currGrid[8]};
assign sqrs[1] = {currGrid[0],currGrid[2],currGrid[9],currGrid[10],currGrid[11],currGrid[18],currGrid[19],currGrid[20]};
assign cols[2] = {currGrid[11],currGrid[20],currGrid[29],currGrid[38],currGrid[47],currGrid[56],currGrid[65],currGrid[74]};
assign rows[2] = {currGrid[0],currGrid[1],currGrid[3],currGrid[4],currGrid[5],currGrid[6],currGrid[7],currGrid[8]};
assign sqrs[2] = {currGrid[0],currGrid[1],currGrid[9],currGrid[10],currGrid[11],currGrid[18],currGrid[19],currGrid[20]};
assign cols[3] = {currGrid[12],currGrid[21],currGrid[30],currGrid[39],currGrid[48],currGrid[57],currGrid[66],currGrid[75]};
assign rows[3] = {currGrid[0],currGrid[1],currGrid[2],currGrid[4],currGrid[5],currGrid[6],currGrid[7],currGrid[8]};
assign sqrs[3] = {currGrid[4],currGrid[5],currGrid[12],currGrid[13],currGrid[14],currGrid[21],currGrid[22],currGrid[23]};
assign cols[4] = {currGrid[13],currGrid[22],currGrid[31],currGrid[40],currGrid[49],currGrid[58],currGrid[67],currGrid[76]};
assign rows[4] = {currGrid[0],currGrid[1],currGrid[2],currGrid[3],currGrid[5],currGrid[6],currGrid[7],currGrid[8]};
assign sqrs[4] = {currGrid[3],currGrid[5],currGrid[12],currGrid[13],currGrid[14],currGrid[21],currGrid[22],currGrid[23]};
assign cols[5] = {currGrid[14],currGrid[23],currGrid[32],currGrid[41],currGrid[50],currGrid[59],currGrid[68],currGrid[77]};
assign rows[5] = {currGrid[0],currGrid[1],currGrid[2],currGrid[3],currGrid[4],currGrid[6],currGrid[7],currGrid[8]};
assign sqrs[5] = {currGrid[3],currGrid[4],currGrid[12],currGrid[13],currGrid[14],currGrid[21],currGrid[22],currGrid[23]};
assign cols[6] = {currGrid[15],currGrid[24],currGrid[33],currGrid[42],currGrid[51],currGrid[60],currGrid[69],currGrid[78]};
assign rows[6] = {currGrid[0],currGrid[1],currGrid[2],currGrid[3],currGrid[4],currGrid[5],currGrid[7],currGrid[8]};
assign sqrs[6] = {currGrid[7],currGrid[8],currGrid[15],currGrid[16],currGrid[17],currGrid[24],currGrid[25],currGrid[26]};
assign cols[7] = {currGrid[16],currGrid[25],currGrid[34],currGrid[43],currGrid[52],currGrid[61],currGrid[70],currGrid[79]};
assign rows[7] = {currGrid[0],currGrid[1],currGrid[2],currGrid[3],currGrid[4],currGrid[5],currGrid[6],currGrid[8]};
assign sqrs[7] = {currGrid[6],currGrid[8],currGrid[15],currGrid[16],currGrid[17],currGrid[24],currGrid[25],currGrid[26]};
assign cols[8] = {currGrid[17],currGrid[26],currGrid[35],currGrid[44],currGrid[53],currGrid[62],currGrid[71],currGrid[80]};
assign rows[8] = {currGrid[0],currGrid[1],currGrid[2],currGrid[3],currGrid[4],currGrid[5],currGrid[6],currGrid[7]};
assign sqrs[8] = {currGrid[6],currGrid[7],currGrid[15],currGrid[16],currGrid[17],currGrid[24],currGrid[25],currGrid[26]};
assign cols[9] = {currGrid[0],currGrid[18],currGrid[27],currGrid[36],currGrid[45],currGrid[54],currGrid[63],currGrid[72]};
assign rows[9] = {currGrid[10],currGrid[11],currGrid[12],currGrid[13],currGrid[14],currGrid[15],currGrid[16],currGrid[17]};
assign sqrs[9] = {currGrid[0],currGrid[1],currGrid[2],currGrid[10],currGrid[11],currGrid[18],currGrid[19],currGrid[20]};
assign cols[10] = {currGrid[1],currGrid[19],currGrid[28],currGrid[37],currGrid[46],currGrid[55],currGrid[64],currGrid[73]};
assign rows[10] = {currGrid[9],currGrid[11],currGrid[12],currGrid[13],currGrid[14],currGrid[15],currGrid[16],currGrid[17]};
assign sqrs[10] = {currGrid[0],currGrid[1],currGrid[2],currGrid[9],currGrid[11],currGrid[18],currGrid[19],currGrid[20]};
assign cols[11] = {currGrid[2],currGrid[20],currGrid[29],currGrid[38],currGrid[47],currGrid[56],currGrid[65],currGrid[74]};
assign rows[11] = {currGrid[9],currGrid[10],currGrid[12],currGrid[13],currGrid[14],currGrid[15],currGrid[16],currGrid[17]};
assign sqrs[11] = {currGrid[0],currGrid[1],currGrid[2],currGrid[9],currGrid[10],currGrid[18],currGrid[19],currGrid[20]};
assign cols[12] = {currGrid[3],currGrid[21],currGrid[30],currGrid[39],currGrid[48],currGrid[57],currGrid[66],currGrid[75]};
assign rows[12] = {currGrid[9],currGrid[10],currGrid[11],currGrid[13],currGrid[14],currGrid[15],currGrid[16],currGrid[17]};
assign sqrs[12] = {currGrid[3],currGrid[4],currGrid[5],currGrid[13],currGrid[14],currGrid[21],currGrid[22],currGrid[23]};
assign cols[13] = {currGrid[4],currGrid[22],currGrid[31],currGrid[40],currGrid[49],currGrid[58],currGrid[67],currGrid[76]};
assign rows[13] = {currGrid[9],currGrid[10],currGrid[11],currGrid[12],currGrid[14],currGrid[15],currGrid[16],currGrid[17]};
assign sqrs[13] = {currGrid[3],currGrid[4],currGrid[5],currGrid[12],currGrid[14],currGrid[21],currGrid[22],currGrid[23]};
assign cols[14] = {currGrid[5],currGrid[23],currGrid[32],currGrid[41],currGrid[50],currGrid[59],currGrid[68],currGrid[77]};
assign rows[14] = {currGrid[9],currGrid[10],currGrid[11],currGrid[12],currGrid[13],currGrid[15],currGrid[16],currGrid[17]};
assign sqrs[14] = {currGrid[3],currGrid[4],currGrid[5],currGrid[12],currGrid[13],currGrid[21],currGrid[22],currGrid[23]};
assign cols[15] = {currGrid[6],currGrid[24],currGrid[33],currGrid[42],currGrid[51],currGrid[60],currGrid[69],currGrid[78]};
assign rows[15] = {currGrid[9],currGrid[10],currGrid[11],currGrid[12],currGrid[13],currGrid[14],currGrid[16],currGrid[17]};
assign sqrs[15] = {currGrid[6],currGrid[7],currGrid[8],currGrid[16],currGrid[17],currGrid[24],currGrid[25],currGrid[26]};
assign cols[16] = {currGrid[7],currGrid[25],currGrid[34],currGrid[43],currGrid[52],currGrid[61],currGrid[70],currGrid[79]};
assign rows[16] = {currGrid[9],currGrid[10],currGrid[11],currGrid[12],currGrid[13],currGrid[14],currGrid[15],currGrid[17]};
assign sqrs[16] = {currGrid[6],currGrid[7],currGrid[8],currGrid[15],currGrid[17],currGrid[24],currGrid[25],currGrid[26]};
assign cols[17] = {currGrid[8],currGrid[26],currGrid[35],currGrid[44],currGrid[53],currGrid[62],currGrid[71],currGrid[80]};
assign rows[17] = {currGrid[9],currGrid[10],currGrid[11],currGrid[12],currGrid[13],currGrid[14],currGrid[15],currGrid[16]};
assign sqrs[17] = {currGrid[6],currGrid[7],currGrid[8],currGrid[15],currGrid[16],currGrid[24],currGrid[25],currGrid[26]};
assign cols[18] = {currGrid[0],currGrid[9],currGrid[27],currGrid[36],currGrid[45],currGrid[54],currGrid[63],currGrid[72]};
assign rows[18] = {currGrid[19],currGrid[20],currGrid[21],currGrid[22],currGrid[23],currGrid[24],currGrid[25],currGrid[26]};
assign sqrs[18] = {currGrid[0],currGrid[1],currGrid[2],currGrid[9],currGrid[10],currGrid[11],currGrid[19],currGrid[20]};
assign cols[19] = {currGrid[1],currGrid[10],currGrid[28],currGrid[37],currGrid[46],currGrid[55],currGrid[64],currGrid[73]};
assign rows[19] = {currGrid[18],currGrid[20],currGrid[21],currGrid[22],currGrid[23],currGrid[24],currGrid[25],currGrid[26]};
assign sqrs[19] = {currGrid[0],currGrid[1],currGrid[2],currGrid[9],currGrid[10],currGrid[11],currGrid[18],currGrid[20]};
assign cols[20] = {currGrid[2],currGrid[11],currGrid[29],currGrid[38],currGrid[47],currGrid[56],currGrid[65],currGrid[74]};
assign rows[20] = {currGrid[18],currGrid[19],currGrid[21],currGrid[22],currGrid[23],currGrid[24],currGrid[25],currGrid[26]};
assign sqrs[20] = {currGrid[0],currGrid[1],currGrid[2],currGrid[9],currGrid[10],currGrid[11],currGrid[18],currGrid[19]};
assign cols[21] = {currGrid[3],currGrid[12],currGrid[30],currGrid[39],currGrid[48],currGrid[57],currGrid[66],currGrid[75]};
assign rows[21] = {currGrid[18],currGrid[19],currGrid[20],currGrid[22],currGrid[23],currGrid[24],currGrid[25],currGrid[26]};
assign sqrs[21] = {currGrid[3],currGrid[4],currGrid[5],currGrid[12],currGrid[13],currGrid[14],currGrid[22],currGrid[23]};
assign cols[22] = {currGrid[4],currGrid[13],currGrid[31],currGrid[40],currGrid[49],currGrid[58],currGrid[67],currGrid[76]};
assign rows[22] = {currGrid[18],currGrid[19],currGrid[20],currGrid[21],currGrid[23],currGrid[24],currGrid[25],currGrid[26]};
assign sqrs[22] = {currGrid[3],currGrid[4],currGrid[5],currGrid[12],currGrid[13],currGrid[14],currGrid[21],currGrid[23]};
assign cols[23] = {currGrid[5],currGrid[14],currGrid[32],currGrid[41],currGrid[50],currGrid[59],currGrid[68],currGrid[77]};
assign rows[23] = {currGrid[18],currGrid[19],currGrid[20],currGrid[21],currGrid[22],currGrid[24],currGrid[25],currGrid[26]};
assign sqrs[23] = {currGrid[3],currGrid[4],currGrid[5],currGrid[12],currGrid[13],currGrid[14],currGrid[21],currGrid[22]};
assign cols[24] = {currGrid[6],currGrid[15],currGrid[33],currGrid[42],currGrid[51],currGrid[60],currGrid[69],currGrid[78]};
assign rows[24] = {currGrid[18],currGrid[19],currGrid[20],currGrid[21],currGrid[22],currGrid[23],currGrid[25],currGrid[26]};
assign sqrs[24] = {currGrid[6],currGrid[7],currGrid[8],currGrid[15],currGrid[16],currGrid[17],currGrid[25],currGrid[26]};
assign cols[25] = {currGrid[7],currGrid[16],currGrid[34],currGrid[43],currGrid[52],currGrid[61],currGrid[70],currGrid[79]};
assign rows[25] = {currGrid[18],currGrid[19],currGrid[20],currGrid[21],currGrid[22],currGrid[23],currGrid[24],currGrid[26]};
assign sqrs[25] = {currGrid[6],currGrid[7],currGrid[8],currGrid[15],currGrid[16],currGrid[17],currGrid[24],currGrid[26]};
assign cols[26] = {currGrid[8],currGrid[17],currGrid[35],currGrid[44],currGrid[53],currGrid[62],currGrid[71],currGrid[80]};
assign rows[26] = {currGrid[18],currGrid[19],currGrid[20],currGrid[21],currGrid[22],currGrid[23],currGrid[24],currGrid[25]};
assign sqrs[26] = {currGrid[6],currGrid[7],currGrid[8],currGrid[15],currGrid[16],currGrid[17],currGrid[24],currGrid[25]};
assign cols[27] = {currGrid[0],currGrid[9],currGrid[18],currGrid[36],currGrid[45],currGrid[54],currGrid[63],currGrid[72]};
assign rows[27] = {currGrid[28],currGrid[29],currGrid[30],currGrid[31],currGrid[32],currGrid[33],currGrid[34],currGrid[35]};
assign sqrs[27] = {currGrid[28],currGrid[29],currGrid[36],currGrid[37],currGrid[38],currGrid[45],currGrid[46],currGrid[47]};
assign cols[28] = {currGrid[1],currGrid[10],currGrid[19],currGrid[37],currGrid[46],currGrid[55],currGrid[64],currGrid[73]};
assign rows[28] = {currGrid[27],currGrid[29],currGrid[30],currGrid[31],currGrid[32],currGrid[33],currGrid[34],currGrid[35]};
assign sqrs[28] = {currGrid[27],currGrid[29],currGrid[36],currGrid[37],currGrid[38],currGrid[45],currGrid[46],currGrid[47]};
assign cols[29] = {currGrid[2],currGrid[11],currGrid[20],currGrid[38],currGrid[47],currGrid[56],currGrid[65],currGrid[74]};
assign rows[29] = {currGrid[27],currGrid[28],currGrid[30],currGrid[31],currGrid[32],currGrid[33],currGrid[34],currGrid[35]};
assign sqrs[29] = {currGrid[27],currGrid[28],currGrid[36],currGrid[37],currGrid[38],currGrid[45],currGrid[46],currGrid[47]};
assign cols[30] = {currGrid[3],currGrid[12],currGrid[21],currGrid[39],currGrid[48],currGrid[57],currGrid[66],currGrid[75]};
assign rows[30] = {currGrid[27],currGrid[28],currGrid[29],currGrid[31],currGrid[32],currGrid[33],currGrid[34],currGrid[35]};
assign sqrs[30] = {currGrid[31],currGrid[32],currGrid[39],currGrid[40],currGrid[41],currGrid[48],currGrid[49],currGrid[50]};
assign cols[31] = {currGrid[4],currGrid[13],currGrid[22],currGrid[40],currGrid[49],currGrid[58],currGrid[67],currGrid[76]};
assign rows[31] = {currGrid[27],currGrid[28],currGrid[29],currGrid[30],currGrid[32],currGrid[33],currGrid[34],currGrid[35]};
assign sqrs[31] = {currGrid[30],currGrid[32],currGrid[39],currGrid[40],currGrid[41],currGrid[48],currGrid[49],currGrid[50]};
assign cols[32] = {currGrid[5],currGrid[14],currGrid[23],currGrid[41],currGrid[50],currGrid[59],currGrid[68],currGrid[77]};
assign rows[32] = {currGrid[27],currGrid[28],currGrid[29],currGrid[30],currGrid[31],currGrid[33],currGrid[34],currGrid[35]};
assign sqrs[32] = {currGrid[30],currGrid[31],currGrid[39],currGrid[40],currGrid[41],currGrid[48],currGrid[49],currGrid[50]};
assign cols[33] = {currGrid[6],currGrid[15],currGrid[24],currGrid[42],currGrid[51],currGrid[60],currGrid[69],currGrid[78]};
assign rows[33] = {currGrid[27],currGrid[28],currGrid[29],currGrid[30],currGrid[31],currGrid[32],currGrid[34],currGrid[35]};
assign sqrs[33] = {currGrid[34],currGrid[35],currGrid[42],currGrid[43],currGrid[44],currGrid[51],currGrid[52],currGrid[53]};
assign cols[34] = {currGrid[7],currGrid[16],currGrid[25],currGrid[43],currGrid[52],currGrid[61],currGrid[70],currGrid[79]};
assign rows[34] = {currGrid[27],currGrid[28],currGrid[29],currGrid[30],currGrid[31],currGrid[32],currGrid[33],currGrid[35]};
assign sqrs[34] = {currGrid[33],currGrid[35],currGrid[42],currGrid[43],currGrid[44],currGrid[51],currGrid[52],currGrid[53]};
assign cols[35] = {currGrid[8],currGrid[17],currGrid[26],currGrid[44],currGrid[53],currGrid[62],currGrid[71],currGrid[80]};
assign rows[35] = {currGrid[27],currGrid[28],currGrid[29],currGrid[30],currGrid[31],currGrid[32],currGrid[33],currGrid[34]};
assign sqrs[35] = {currGrid[33],currGrid[34],currGrid[42],currGrid[43],currGrid[44],currGrid[51],currGrid[52],currGrid[53]};
assign cols[36] = {currGrid[0],currGrid[9],currGrid[18],currGrid[27],currGrid[45],currGrid[54],currGrid[63],currGrid[72]};
assign rows[36] = {currGrid[37],currGrid[38],currGrid[39],currGrid[40],currGrid[41],currGrid[42],currGrid[43],currGrid[44]};
assign sqrs[36] = {currGrid[27],currGrid[28],currGrid[29],currGrid[37],currGrid[38],currGrid[45],currGrid[46],currGrid[47]};
assign cols[37] = {currGrid[1],currGrid[10],currGrid[19],currGrid[28],currGrid[46],currGrid[55],currGrid[64],currGrid[73]};
assign rows[37] = {currGrid[36],currGrid[38],currGrid[39],currGrid[40],currGrid[41],currGrid[42],currGrid[43],currGrid[44]};
assign sqrs[37] = {currGrid[27],currGrid[28],currGrid[29],currGrid[36],currGrid[38],currGrid[45],currGrid[46],currGrid[47]};
assign cols[38] = {currGrid[2],currGrid[11],currGrid[20],currGrid[29],currGrid[47],currGrid[56],currGrid[65],currGrid[74]};
assign rows[38] = {currGrid[36],currGrid[37],currGrid[39],currGrid[40],currGrid[41],currGrid[42],currGrid[43],currGrid[44]};
assign sqrs[38] = {currGrid[27],currGrid[28],currGrid[29],currGrid[36],currGrid[37],currGrid[45],currGrid[46],currGrid[47]};
assign cols[39] = {currGrid[3],currGrid[12],currGrid[21],currGrid[30],currGrid[48],currGrid[57],currGrid[66],currGrid[75]};
assign rows[39] = {currGrid[36],currGrid[37],currGrid[38],currGrid[40],currGrid[41],currGrid[42],currGrid[43],currGrid[44]};
assign sqrs[39] = {currGrid[30],currGrid[31],currGrid[32],currGrid[40],currGrid[41],currGrid[48],currGrid[49],currGrid[50]};
assign cols[40] = {currGrid[4],currGrid[13],currGrid[22],currGrid[31],currGrid[49],currGrid[58],currGrid[67],currGrid[76]};
assign rows[40] = {currGrid[36],currGrid[37],currGrid[38],currGrid[39],currGrid[41],currGrid[42],currGrid[43],currGrid[44]};
assign sqrs[40] = {currGrid[30],currGrid[31],currGrid[32],currGrid[39],currGrid[41],currGrid[48],currGrid[49],currGrid[50]};
assign cols[41] = {currGrid[5],currGrid[14],currGrid[23],currGrid[32],currGrid[50],currGrid[59],currGrid[68],currGrid[77]};
assign rows[41] = {currGrid[36],currGrid[37],currGrid[38],currGrid[39],currGrid[40],currGrid[42],currGrid[43],currGrid[44]};
assign sqrs[41] = {currGrid[30],currGrid[31],currGrid[32],currGrid[39],currGrid[40],currGrid[48],currGrid[49],currGrid[50]};
assign cols[42] = {currGrid[6],currGrid[15],currGrid[24],currGrid[33],currGrid[51],currGrid[60],currGrid[69],currGrid[78]};
assign rows[42] = {currGrid[36],currGrid[37],currGrid[38],currGrid[39],currGrid[40],currGrid[41],currGrid[43],currGrid[44]};
assign sqrs[42] = {currGrid[33],currGrid[34],currGrid[35],currGrid[43],currGrid[44],currGrid[51],currGrid[52],currGrid[53]};
assign cols[43] = {currGrid[7],currGrid[16],currGrid[25],currGrid[34],currGrid[52],currGrid[61],currGrid[70],currGrid[79]};
assign rows[43] = {currGrid[36],currGrid[37],currGrid[38],currGrid[39],currGrid[40],currGrid[41],currGrid[42],currGrid[44]};
assign sqrs[43] = {currGrid[33],currGrid[34],currGrid[35],currGrid[42],currGrid[44],currGrid[51],currGrid[52],currGrid[53]};
assign cols[44] = {currGrid[8],currGrid[17],currGrid[26],currGrid[35],currGrid[53],currGrid[62],currGrid[71],currGrid[80]};
assign rows[44] = {currGrid[36],currGrid[37],currGrid[38],currGrid[39],currGrid[40],currGrid[41],currGrid[42],currGrid[43]};
assign sqrs[44] = {currGrid[33],currGrid[34],currGrid[35],currGrid[42],currGrid[43],currGrid[51],currGrid[52],currGrid[53]};
assign cols[45] = {currGrid[0],currGrid[9],currGrid[18],currGrid[27],currGrid[36],currGrid[54],currGrid[63],currGrid[72]};
assign rows[45] = {currGrid[46],currGrid[47],currGrid[48],currGrid[49],currGrid[50],currGrid[51],currGrid[52],currGrid[53]};
assign sqrs[45] = {currGrid[27],currGrid[28],currGrid[29],currGrid[36],currGrid[37],currGrid[38],currGrid[46],currGrid[47]};
assign cols[46] = {currGrid[1],currGrid[10],currGrid[19],currGrid[28],currGrid[37],currGrid[55],currGrid[64],currGrid[73]};
assign rows[46] = {currGrid[45],currGrid[47],currGrid[48],currGrid[49],currGrid[50],currGrid[51],currGrid[52],currGrid[53]};
assign sqrs[46] = {currGrid[27],currGrid[28],currGrid[29],currGrid[36],currGrid[37],currGrid[38],currGrid[45],currGrid[47]};
assign cols[47] = {currGrid[2],currGrid[11],currGrid[20],currGrid[29],currGrid[38],currGrid[56],currGrid[65],currGrid[74]};
assign rows[47] = {currGrid[45],currGrid[46],currGrid[48],currGrid[49],currGrid[50],currGrid[51],currGrid[52],currGrid[53]};
assign sqrs[47] = {currGrid[27],currGrid[28],currGrid[29],currGrid[36],currGrid[37],currGrid[38],currGrid[45],currGrid[46]};
assign cols[48] = {currGrid[3],currGrid[12],currGrid[21],currGrid[30],currGrid[39],currGrid[57],currGrid[66],currGrid[75]};
assign rows[48] = {currGrid[45],currGrid[46],currGrid[47],currGrid[49],currGrid[50],currGrid[51],currGrid[52],currGrid[53]};
assign sqrs[48] = {currGrid[30],currGrid[31],currGrid[32],currGrid[39],currGrid[40],currGrid[41],currGrid[49],currGrid[50]};
assign cols[49] = {currGrid[4],currGrid[13],currGrid[22],currGrid[31],currGrid[40],currGrid[58],currGrid[67],currGrid[76]};
assign rows[49] = {currGrid[45],currGrid[46],currGrid[47],currGrid[48],currGrid[50],currGrid[51],currGrid[52],currGrid[53]};
assign sqrs[49] = {currGrid[30],currGrid[31],currGrid[32],currGrid[39],currGrid[40],currGrid[41],currGrid[48],currGrid[50]};
assign cols[50] = {currGrid[5],currGrid[14],currGrid[23],currGrid[32],currGrid[41],currGrid[59],currGrid[68],currGrid[77]};
assign rows[50] = {currGrid[45],currGrid[46],currGrid[47],currGrid[48],currGrid[49],currGrid[51],currGrid[52],currGrid[53]};
assign sqrs[50] = {currGrid[30],currGrid[31],currGrid[32],currGrid[39],currGrid[40],currGrid[41],currGrid[48],currGrid[49]};
assign cols[51] = {currGrid[6],currGrid[15],currGrid[24],currGrid[33],currGrid[42],currGrid[60],currGrid[69],currGrid[78]};
assign rows[51] = {currGrid[45],currGrid[46],currGrid[47],currGrid[48],currGrid[49],currGrid[50],currGrid[52],currGrid[53]};
assign sqrs[51] = {currGrid[33],currGrid[34],currGrid[35],currGrid[42],currGrid[43],currGrid[44],currGrid[52],currGrid[53]};
assign cols[52] = {currGrid[7],currGrid[16],currGrid[25],currGrid[34],currGrid[43],currGrid[61],currGrid[70],currGrid[79]};
assign rows[52] = {currGrid[45],currGrid[46],currGrid[47],currGrid[48],currGrid[49],currGrid[50],currGrid[51],currGrid[53]};
assign sqrs[52] = {currGrid[33],currGrid[34],currGrid[35],currGrid[42],currGrid[43],currGrid[44],currGrid[51],currGrid[53]};
assign cols[53] = {currGrid[8],currGrid[17],currGrid[26],currGrid[35],currGrid[44],currGrid[62],currGrid[71],currGrid[80]};
assign rows[53] = {currGrid[45],currGrid[46],currGrid[47],currGrid[48],currGrid[49],currGrid[50],currGrid[51],currGrid[52]};
assign sqrs[53] = {currGrid[33],currGrid[34],currGrid[35],currGrid[42],currGrid[43],currGrid[44],currGrid[51],currGrid[52]};
assign cols[54] = {currGrid[0],currGrid[9],currGrid[18],currGrid[27],currGrid[36],currGrid[45],currGrid[63],currGrid[72]};
assign rows[54] = {currGrid[55],currGrid[56],currGrid[57],currGrid[58],currGrid[59],currGrid[60],currGrid[61],currGrid[62]};
assign sqrs[54] = {currGrid[55],currGrid[56],currGrid[63],currGrid[64],currGrid[65],currGrid[72],currGrid[73],currGrid[74]};
assign cols[55] = {currGrid[1],currGrid[10],currGrid[19],currGrid[28],currGrid[37],currGrid[46],currGrid[64],currGrid[73]};
assign rows[55] = {currGrid[54],currGrid[56],currGrid[57],currGrid[58],currGrid[59],currGrid[60],currGrid[61],currGrid[62]};
assign sqrs[55] = {currGrid[54],currGrid[56],currGrid[63],currGrid[64],currGrid[65],currGrid[72],currGrid[73],currGrid[74]};
assign cols[56] = {currGrid[2],currGrid[11],currGrid[20],currGrid[29],currGrid[38],currGrid[47],currGrid[65],currGrid[74]};
assign rows[56] = {currGrid[54],currGrid[55],currGrid[57],currGrid[58],currGrid[59],currGrid[60],currGrid[61],currGrid[62]};
assign sqrs[56] = {currGrid[54],currGrid[55],currGrid[63],currGrid[64],currGrid[65],currGrid[72],currGrid[73],currGrid[74]};
assign cols[57] = {currGrid[3],currGrid[12],currGrid[21],currGrid[30],currGrid[39],currGrid[48],currGrid[66],currGrid[75]};
assign rows[57] = {currGrid[54],currGrid[55],currGrid[56],currGrid[58],currGrid[59],currGrid[60],currGrid[61],currGrid[62]};
assign sqrs[57] = {currGrid[58],currGrid[59],currGrid[66],currGrid[67],currGrid[68],currGrid[75],currGrid[76],currGrid[77]};
assign cols[58] = {currGrid[4],currGrid[13],currGrid[22],currGrid[31],currGrid[40],currGrid[49],currGrid[67],currGrid[76]};
assign rows[58] = {currGrid[54],currGrid[55],currGrid[56],currGrid[57],currGrid[59],currGrid[60],currGrid[61],currGrid[62]};
assign sqrs[58] = {currGrid[57],currGrid[59],currGrid[66],currGrid[67],currGrid[68],currGrid[75],currGrid[76],currGrid[77]};
assign cols[59] = {currGrid[5],currGrid[14],currGrid[23],currGrid[32],currGrid[41],currGrid[50],currGrid[68],currGrid[77]};
assign rows[59] = {currGrid[54],currGrid[55],currGrid[56],currGrid[57],currGrid[58],currGrid[60],currGrid[61],currGrid[62]};
assign sqrs[59] = {currGrid[57],currGrid[58],currGrid[66],currGrid[67],currGrid[68],currGrid[75],currGrid[76],currGrid[77]};
assign cols[60] = {currGrid[6],currGrid[15],currGrid[24],currGrid[33],currGrid[42],currGrid[51],currGrid[69],currGrid[78]};
assign rows[60] = {currGrid[54],currGrid[55],currGrid[56],currGrid[57],currGrid[58],currGrid[59],currGrid[61],currGrid[62]};
assign sqrs[60] = {currGrid[61],currGrid[62],currGrid[69],currGrid[70],currGrid[71],currGrid[78],currGrid[79],currGrid[80]};
assign cols[61] = {currGrid[7],currGrid[16],currGrid[25],currGrid[34],currGrid[43],currGrid[52],currGrid[70],currGrid[79]};
assign rows[61] = {currGrid[54],currGrid[55],currGrid[56],currGrid[57],currGrid[58],currGrid[59],currGrid[60],currGrid[62]};
assign sqrs[61] = {currGrid[60],currGrid[62],currGrid[69],currGrid[70],currGrid[71],currGrid[78],currGrid[79],currGrid[80]};
assign cols[62] = {currGrid[8],currGrid[17],currGrid[26],currGrid[35],currGrid[44],currGrid[53],currGrid[71],currGrid[80]};
assign rows[62] = {currGrid[54],currGrid[55],currGrid[56],currGrid[57],currGrid[58],currGrid[59],currGrid[60],currGrid[61]};
assign sqrs[62] = {currGrid[60],currGrid[61],currGrid[69],currGrid[70],currGrid[71],currGrid[78],currGrid[79],currGrid[80]};
assign cols[63] = {currGrid[0],currGrid[9],currGrid[18],currGrid[27],currGrid[36],currGrid[45],currGrid[54],currGrid[72]};
assign rows[63] = {currGrid[64],currGrid[65],currGrid[66],currGrid[67],currGrid[68],currGrid[69],currGrid[70],currGrid[71]};
assign sqrs[63] = {currGrid[54],currGrid[55],currGrid[56],currGrid[64],currGrid[65],currGrid[72],currGrid[73],currGrid[74]};
assign cols[64] = {currGrid[1],currGrid[10],currGrid[19],currGrid[28],currGrid[37],currGrid[46],currGrid[55],currGrid[73]};
assign rows[64] = {currGrid[63],currGrid[65],currGrid[66],currGrid[67],currGrid[68],currGrid[69],currGrid[70],currGrid[71]};
assign sqrs[64] = {currGrid[54],currGrid[55],currGrid[56],currGrid[63],currGrid[65],currGrid[72],currGrid[73],currGrid[74]};
assign cols[65] = {currGrid[2],currGrid[11],currGrid[20],currGrid[29],currGrid[38],currGrid[47],currGrid[56],currGrid[74]};
assign rows[65] = {currGrid[63],currGrid[64],currGrid[66],currGrid[67],currGrid[68],currGrid[69],currGrid[70],currGrid[71]};
assign sqrs[65] = {currGrid[54],currGrid[55],currGrid[56],currGrid[63],currGrid[64],currGrid[72],currGrid[73],currGrid[74]};
assign cols[66] = {currGrid[3],currGrid[12],currGrid[21],currGrid[30],currGrid[39],currGrid[48],currGrid[57],currGrid[75]};
assign rows[66] = {currGrid[63],currGrid[64],currGrid[65],currGrid[67],currGrid[68],currGrid[69],currGrid[70],currGrid[71]};
assign sqrs[66] = {currGrid[57],currGrid[58],currGrid[59],currGrid[67],currGrid[68],currGrid[75],currGrid[76],currGrid[77]};
assign cols[67] = {currGrid[4],currGrid[13],currGrid[22],currGrid[31],currGrid[40],currGrid[49],currGrid[58],currGrid[76]};
assign rows[67] = {currGrid[63],currGrid[64],currGrid[65],currGrid[66],currGrid[68],currGrid[69],currGrid[70],currGrid[71]};
assign sqrs[67] = {currGrid[57],currGrid[58],currGrid[59],currGrid[66],currGrid[68],currGrid[75],currGrid[76],currGrid[77]};
assign cols[68] = {currGrid[5],currGrid[14],currGrid[23],currGrid[32],currGrid[41],currGrid[50],currGrid[59],currGrid[77]};
assign rows[68] = {currGrid[63],currGrid[64],currGrid[65],currGrid[66],currGrid[67],currGrid[69],currGrid[70],currGrid[71]};
assign sqrs[68] = {currGrid[57],currGrid[58],currGrid[59],currGrid[66],currGrid[67],currGrid[75],currGrid[76],currGrid[77]};
assign cols[69] = {currGrid[6],currGrid[15],currGrid[24],currGrid[33],currGrid[42],currGrid[51],currGrid[60],currGrid[78]};
assign rows[69] = {currGrid[63],currGrid[64],currGrid[65],currGrid[66],currGrid[67],currGrid[68],currGrid[70],currGrid[71]};
assign sqrs[69] = {currGrid[60],currGrid[61],currGrid[62],currGrid[70],currGrid[71],currGrid[78],currGrid[79],currGrid[80]};
assign cols[70] = {currGrid[7],currGrid[16],currGrid[25],currGrid[34],currGrid[43],currGrid[52],currGrid[61],currGrid[79]};
assign rows[70] = {currGrid[63],currGrid[64],currGrid[65],currGrid[66],currGrid[67],currGrid[68],currGrid[69],currGrid[71]};
assign sqrs[70] = {currGrid[60],currGrid[61],currGrid[62],currGrid[69],currGrid[71],currGrid[78],currGrid[79],currGrid[80]};
assign cols[71] = {currGrid[8],currGrid[17],currGrid[26],currGrid[35],currGrid[44],currGrid[53],currGrid[62],currGrid[80]};
assign rows[71] = {currGrid[63],currGrid[64],currGrid[65],currGrid[66],currGrid[67],currGrid[68],currGrid[69],currGrid[70]};
assign sqrs[71] = {currGrid[60],currGrid[61],currGrid[62],currGrid[69],currGrid[70],currGrid[78],currGrid[79],currGrid[80]};
assign cols[72] = {currGrid[0],currGrid[9],currGrid[18],currGrid[27],currGrid[36],currGrid[45],currGrid[54],currGrid[63]};
assign rows[72] = {currGrid[73],currGrid[74],currGrid[75],currGrid[76],currGrid[77],currGrid[78],currGrid[79],currGrid[80]};
assign sqrs[72] = {currGrid[54],currGrid[55],currGrid[56],currGrid[63],currGrid[64],currGrid[65],currGrid[73],currGrid[74]};
assign cols[73] = {currGrid[1],currGrid[10],currGrid[19],currGrid[28],currGrid[37],currGrid[46],currGrid[55],currGrid[64]};
assign rows[73] = {currGrid[72],currGrid[74],currGrid[75],currGrid[76],currGrid[77],currGrid[78],currGrid[79],currGrid[80]};
assign sqrs[73] = {currGrid[54],currGrid[55],currGrid[56],currGrid[63],currGrid[64],currGrid[65],currGrid[72],currGrid[74]};
assign cols[74] = {currGrid[2],currGrid[11],currGrid[20],currGrid[29],currGrid[38],currGrid[47],currGrid[56],currGrid[65]};
assign rows[74] = {currGrid[72],currGrid[73],currGrid[75],currGrid[76],currGrid[77],currGrid[78],currGrid[79],currGrid[80]};
assign sqrs[74] = {currGrid[54],currGrid[55],currGrid[56],currGrid[63],currGrid[64],currGrid[65],currGrid[72],currGrid[73]};
assign cols[75] = {currGrid[3],currGrid[12],currGrid[21],currGrid[30],currGrid[39],currGrid[48],currGrid[57],currGrid[66]};
assign rows[75] = {currGrid[72],currGrid[73],currGrid[74],currGrid[76],currGrid[77],currGrid[78],currGrid[79],currGrid[80]};
assign sqrs[75] = {currGrid[57],currGrid[58],currGrid[59],currGrid[66],currGrid[67],currGrid[68],currGrid[76],currGrid[77]};
assign cols[76] = {currGrid[4],currGrid[13],currGrid[22],currGrid[31],currGrid[40],currGrid[49],currGrid[58],currGrid[67]};
assign rows[76] = {currGrid[72],currGrid[73],currGrid[74],currGrid[75],currGrid[77],currGrid[78],currGrid[79],currGrid[80]};
assign sqrs[76] = {currGrid[57],currGrid[58],currGrid[59],currGrid[66],currGrid[67],currGrid[68],currGrid[75],currGrid[77]};
assign cols[77] = {currGrid[5],currGrid[14],currGrid[23],currGrid[32],currGrid[41],currGrid[50],currGrid[59],currGrid[68]};
assign rows[77] = {currGrid[72],currGrid[73],currGrid[74],currGrid[75],currGrid[76],currGrid[78],currGrid[79],currGrid[80]};
assign sqrs[77] = {currGrid[57],currGrid[58],currGrid[59],currGrid[66],currGrid[67],currGrid[68],currGrid[75],currGrid[76]};
assign cols[78] = {currGrid[6],currGrid[15],currGrid[24],currGrid[33],currGrid[42],currGrid[51],currGrid[60],currGrid[69]};
assign rows[78] = {currGrid[72],currGrid[73],currGrid[74],currGrid[75],currGrid[76],currGrid[77],currGrid[79],currGrid[80]};
assign sqrs[78] = {currGrid[60],currGrid[61],currGrid[62],currGrid[69],currGrid[70],currGrid[71],currGrid[79],currGrid[80]};
assign cols[79] = {currGrid[7],currGrid[16],currGrid[25],currGrid[34],currGrid[43],currGrid[52],currGrid[61],currGrid[70]};
assign rows[79] = {currGrid[72],currGrid[73],currGrid[74],currGrid[75],currGrid[76],currGrid[77],currGrid[78],currGrid[80]};
assign sqrs[79] = {currGrid[60],currGrid[61],currGrid[62],currGrid[69],currGrid[70],currGrid[71],currGrid[78],currGrid[80]};
assign cols[80] = {currGrid[8],currGrid[17],currGrid[26],currGrid[35],currGrid[44],currGrid[53],currGrid[62],currGrid[71]};
assign rows[80] = {currGrid[72],currGrid[73],currGrid[74],currGrid[75],currGrid[76],currGrid[77],currGrid[78],currGrid[79]};
assign sqrs[80] = {currGrid[60],currGrid[61],currGrid[62],currGrid[69],currGrid[70],currGrid[71],currGrid[78],currGrid[79]};

  generate
     for(i=0;i<81;i=i+1)
       begin: outGridGen
	  assign outGrid[(9*(i+1)-1):(9*i)] = currGrid[i];

       end
  endgenerate
      
   
   genvar ii,jj;
   wire [80:0] c_rows [8:0];
   wire [80:0] c_cols [8:0];
   wire [80:0] c_grds [8:0];
   wire [26:0] w_correct;
   
   generate
      for(ii=0;ii<9;ii=ii+1)
	begin: row_check
	   assign c_rows[0][(9*(ii+1)-1):9*ii] = currGrid[ii];
	   assign c_rows[1][(9*(ii+1)-1):9*ii] = currGrid[9+ii];
	   assign c_rows[2][(9*(ii+1)-1):9*ii] = currGrid[18+ii];
	   assign c_rows[3][(9*(ii+1)-1):9*ii] = currGrid[27+ii];
	   assign c_rows[4][(9*(ii+1)-1):9*ii] = currGrid[36+ii];
	   assign c_rows[5][(9*(ii+1)-1):9*ii] = currGrid[45+ii];
	   assign c_rows[6][(9*(ii+1)-1):9*ii] = currGrid[54+ii];
	   assign c_rows[7][(9*(ii+1)-1):9*ii] = currGrid[63+ii];
	   assign c_rows[8][(9*(ii+1)-1):9*ii] = currGrid[72+ii];
	end
   endgenerate
   
   generate
      for(ii=0;ii<9;ii=ii+1)
	begin: col_check
	   assign c_cols[0][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 0];
	   assign c_cols[1][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 1];
	   assign c_cols[2][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 2];
	   assign c_cols[3][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 3];
	   assign c_cols[4][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 4];
	   assign c_cols[5][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 5];
	   assign c_cols[6][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 6];
	   assign c_cols[7][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 7];
	   assign c_cols[8][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 8];
	end
   endgenerate

   genvar iii,jjj;
   generate
      for(ii=0; ii < 3; ii=ii+1)
	begin: grd_check_y
	   for(jj = 0; jj < 3; jj=jj+1)
	     begin: grd_check_x
		for(iii=3*ii; iii < 3*(ii+1); iii=iii+1)
		  begin: gg_y
		     for(jjj=3*jj; jjj < 3*(jj+1); jjj=jjj+1)
		       begin: gg_x
			  			  
			  //(3*(iii-3*ii) + (jjj-3*jj))
			  assign c_grds[3*ii+jj][9*(3*(iii-3*ii) + (jjj-3*jj)+1)-1:9*(3*(iii-3*ii) + (jjj-3*jj))] = 														   currGrid[9*iii + jjj];
		       end 
		  end
	     end
	end
   endgenerate
         
   generate
      for(ii=0;ii<9;ii=ii+1)
	begin: checks
	   checkCorrect cC_R (.y(w_correct[ii]), .in(c_rows[ii]));
	   checkCorrect cC_C (.y(w_correct[9+ii]), .in(c_cols[ii]));
	   checkCorrect cC_G (.y(w_correct[18+ii]), .in(c_grds[ii]));
	end
   endgenerate
   
   assign anyError = ~(&w_correct);
   
endmodule