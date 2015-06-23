module lfsr_tb
  (
   output OK
   );

   reg 	  clk,rst;

   reg 	  cke,clear,set,rew;

   initial
     begin
	#0 cke = 1'b0;
	#1000 cke = 1'b1;
     end
   
   initial
     begin
	#0 clear = 1'b0;
	#10000 clear = 1'b1;
	#10100 clear = 1'b0;	
     end

   initial
     begin
	#0 set = 1'b0;
	#5000 set = 1'b1;
	#100 set = 1'b0;	
     end
   
   initial
     begin
	#0 rew = 1'b0;
	#6000 rew = 1'b1;
     end
   
   initial
     begin
	#0 clk = 1'b0;
	forever
	#5 clk = !clk;   // 100MHz
     end
   
   initial
     begin
	#0 rst = 1'b1;
	#400 rst = 1'b0;	
     end

   vcnt DUT
     (
      .clear(clear),
      .cke(cke),
      .set(set),
      .rew(rew),
      .q(),
//      .q_next(),
//      .z(),
//      .zq(),
      .clk(clk),
      .rst(rst)
      );
   
endmodule // lfsr_tb
